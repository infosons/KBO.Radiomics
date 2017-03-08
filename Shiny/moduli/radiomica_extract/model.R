modelRadiomicaExtract<- function(input,output,session,roi,patientTable,extractOutputs,filters) {
  source("./moduli/radiomica_extract/run_fun.R")
  
  ns<-session$ns
  
  loadProgress<-function(stringRepresentation) {
    rawRepresentation<-charToRaw(stringRepresentation)
    obj<-unserialize(rawRepresentation)
    obj
  }
  
  progress<-shiny::Progress$new()
  
  status<-reactiveValues(running=FALSE,done=FALSE)
  
  pendingJobs<-function() {
    executeQuery("select count(*) FROM Radiomica_Run WHERE status='pending'")[["count(*)"]]
  }
  
  totalJobs<-function() {
    executeQuery("select count(*) FROM Radiomica_Run")[["count(*)"]]
  }
  
  setJobStatusDone<-function() {
    if (totalJobs()>0 && pendingJobs()==0) {
      status$done=TRUE
    }
    else{
      status$done=FALSE
    }
  }
  setJobStatusDone()
  
  if(pendingJobs()>1) {
    status$running=TRUE
  }
  
  observeEvent(status$running,{
    if (status$running) {
      status$done=FALSE
      progress$close()
      progress$initialize(session)
      status$cl<-snow::makeSOCKcluster("localhost")
      tryCatch({
        snow::sendCall(status$cl[[1]], radiomicaRunFun,list(xrange=xrange))
      })
    }
    else {
      progress$close()
      setJobStatusDone()
    }
  })
  
  getHeaders <- function(features,rois,pazienti,filters_selected,duplicate_filters) {
    rois_string<-paste(rois,collapse=", ")
    pazienti_string<-paste(pazienti,collapse = ", ")
    filters_string<-paste(filters_selected,collapse=", ")
    summary<-sprintf("Procedendo con una nuova estrazione, verranno estrettate: <ul><li>le seguenti features: %s</li>
                     <li> per i roi: %s</li><li> applicando i filtri: %s</li><li> per i pazienti: %s</li></ul>"
                     ,features,rois_string,filters_string,pazienti_string)
    output<-tagList()
    if (duplicate_filters) {
      output<-tagAppendChild(output,getWarning("Hai scelto pi&ugrave; volte lo stesso filtro. Ne verr&agrave; considerato solo uno."))
    }
    output<-tagAppendChild(output,getInfo(summary))
    output
  }
  
  output$main = renderUI({
    if (status$running) {
      actionButton(ns("cancel"), "Cancel")
    }
    else {
      features<-paste(moddicomV2::RAD.getFeaturesListNames(),collapse=", ")
      rois<-lapply(getRoisSelected(),function(x)x$roi)
      pazienti<-patientTable()[["patient_name"]]
      filters_raw<-filters()
      unique_filters<-unique(filters_raw)
      filters_selected<-lapply(unique_filters,function(x) sprintf("%s(sigma=%s)",x[1],x[2]))
      output<-tagList()
      if (status$done) {
        output<-tagAppendChild(output,getSuccess("L'estrazione precedente &egrave; andata a buon fine!"))
      }
      if (length(pazienti)<2) {
        output<-tagAppendChild(output,getWarning("Devi selezionare almeno due pazienti prima di procedere con una nuova estrazione"))
      }
      else if (length(rois)==0) {
        output<-tagAppendChild(output,getWarning("Devi selezionare almeno un ROI prima di procedere con una nuova estrazione"))
      }
      else {
        headers<-getHeaders(features,rois,pazienti,filters_selected,duplicate_filters = length(filters_raw)>length(unique_filters))
        tagList(headers,actionButton(ns("run"), "Run"))
        output<-tagAppendChildren(output,list(headers,actionButton(ns("run"), "Run")))
      }
      output
    }
  })
  
  getRoisSelected<-reactive({
    roiTable<-roi()
    roiExtracts<-extractOutputs()
    id_pazienti<-patientTable()[["id"]]
    iList<-unlist(lapply(xrange(length(roiExtracts)), function(i) if(!is.null(roiExtracts[[i]]) && roiExtracts[[i]]==TRUE) i))
    lapply(iList,function(i) {
      id_roi<-roiTable[["id"]][i]
      roi_moddicom<-function(id_paziente) {
        roi<-executeQuery(sprintf("SELECT nome_roi_paziente FROM ROI_ROIPaziente WHERE id_roi=%i AND id_paziente=%i LIMIT 1",id_roi,id_paziente))
        roi[["nome_roi_paziente"]]
      }
      roi<-roiTable[["nome"]][i]
      list(roi=roi,moddicom=roi_moddicom)
    })
  })
  
  
  observeEvent(input$run, {
    status$running<-TRUE
    executeQuery("DELETE FROM Radiomica_Run")
    id_pazienti<-patientTable()[["id"]]
    roiExtracts<-getRoisSelected()
    filtersSelected<-unique(filters())
    for (id_paziente in id_pazienti) {
      for (roi in roiExtracts) {
        roiName<-roi[["roi"]]
        roiModdicom<-roi[["moddicom"]](id_paziente)
        for (filter in filtersSelected) {
          query<-sprintf("INSERT INTO Radiomica_Run (id_paziente,filtro,sigma,roi,roi_moddicom,status) VALUES (%i,'%s',%s,'%s','%s','pending')",id_paziente,filter[1],filter[2],roiName,roiModdicom)
          executeQuery(query)
        }
      }
    }
  })
  
  observeEvent(input$cancel, {
    executeQuery("DELETE FROM Radiomica_Run")
    if (file.exists("lock")) {
      file.remove("lock")
    }
    status$running<-FALSE
  })
  
  progressTableData <- reactivePoll(4000, session,
                                    # This function returns the time that the logfile was last
                                    # modified
                                    checkFunc = function() {
                                      numPen<-pendingJobs()
                                      tot<-totalJobs()
                                      if (status$running && numPen>0) {
                                        progress$set(message = "Calcolando...",detail = sprintf("Computazione %i/%i in corso", tot-numPen+1,tot),
                                                     value=1-numPen/tot)
                                      }
                                      if (status$running && numPen==0) {
                                        status$running=FALSE
                                      }
                                      numPen
                                    },
                                    # This function returns the content of the logfile
                                    valueFunc = function() {
                                      query<-"SELECT rr.id, p.patient_name, rr.roi, rr.filtro,rr.sigma, rr.status FROM Radiomica_Run rr INNER JOIN Paziente p ON p.id=rr.id_paziente"
                                      executeQuery(query)
                                    }
  )
  
  #
  
  output$progress <- renderUI({
    dataTable<-progressTableData()
    onClick=sprintf('Shiny.onInputChange(\"%s\",  Math.random()+this.id)',ns("vis_button"))
    dataTable[["risultati"]]<-lapply(xrange(nrow(dataTable)),function (i) {
      if (dataTable[["status"]][i]=="done") {
        risultato<-actionButton(paste('visbutton_',dataTable[["id"]][i],sep = ""),label="",icon = icon("eye"),onClick=onClick)
      }
      else {
        risultato<-""
      }
      risultato
    })
    dataTable[["id"]]<-NULL
    colnames(dataTable)<-c("Patient Name","Roi","Filtro","Sigma","Status","Risultati")
    table<-getTable(dataTable)
    table
  })
  
  dataTableRadiomica<-reactive({
    id <- as.numeric(strsplit(input$vis_button, "_")[[1]][2])
    dataString<-executeQuery(sprintf("SELECT data FROM Radiomica_Run WHERE id=%i",id))[["data"]]
    data<-unserialize(charToRaw(dataString))
    data
  })
  
  observeEvent(input$vis_button,{
    toggleModal(session,"vis_data",toggle="open")
  })
  
  output$dataTable <- renderUI({
    if (!is.null(input$vis_button)) {
      id <- as.numeric(strsplit(input$vis_button, "_")[[1]][2])
      dataString<-executeQuery(sprintf("SELECT data FROM Radiomica_Run WHERE id=%i",id))[["data"]]
      data<-unserialize(charToRaw(dataString))$result
      datatable<-list()
      datatable[["Feature"]]<-names(data)
      datatable[["Valore"]]<-unlist(data,use.names=F) 
      table<-getTable(as.data.frame(datatable))
      bsModal(ns("vis_data"), "Risultati", ns("agg"), size = "large",
              table)
    }
  })
  
  return(status)
}
