modelRadiomica<- function(input,output,session,paziente,roi,patientData) {
  
  ns<-session$ns

  tableOutput(output,"tablePazientiRadiomica",paziente,list(patient_name="Patient name",cartella_immagini="Cartella immagini"))
  
  output$tablePazientiSelected=renderPrint(paziente()[input$tablePazientiRadiomica_rows_selected,])
  
  getIcons<- function(checked) {
    if (checked) {
      return(icon("check-square-o"))
    }
    else {
      return(icon("square-o"))
    }
  }
  
  getExtractList <- function(matrix,id) {
    output<-list(tags$b("Estrarre?"))
    for (i in xrange(ncol(matrix))) {
      if (all(matrix[,i]) && nrow(matrix)>0) {
        curr<-list(checkboxInput(ns(paste(id,i,sep = "")),""))
      }
      else {
        curr <- ""
      }
      output[i+1]<-curr
    }
    output[i+2]=""
    return(output)
  }
  
  extractOutputs<-reactive({
    lapply(xrange(nrow(roi())),function(i)input[[ns(paste("extract",i,sep = ""))]])
  })
  
  onClick=sprintf('Shiny.onInputChange(\"%s\",  Math.random()+this.id)',"visualizzaPaziente-vis_button")
  
  output$RadiomicaRoiPazienteTable <- DT::renderDataTable(DT::datatable(pazienteRoi(),escape=FALSE,selection=c("none")))
  
  getPazienteTable<-reactive(paziente()[input$tablePazientiRadiomica_rows_selected,])
  
  output$panelROI = renderUI({
    tableEvents$ROI_ROIPaziente
    roiTable<-roi()
    pazienteTable<-getPazienteTable()
    roiPatientTable<-checkMany2Many("ROI_ROIPaziente","id_paziente", pazienteTable[["id"]],"id_roi", roiTable[["id"]])
    roiNames<-roiTable[["nome"]]
    patientNames<-pazienteTable[["patient_name"]]
    trList=list()
    currTr<-getTr(c("",roiNames,""),tags$th)
    trList<-list(trList,tags$thead(currTr))
    for (i in xrange(length(patientNames))) {
      iconRow<-lapply(roiPatientTable[i,],function(j) getIcons(j))
      currTr<-getTr(c(patientNames[i],iconRow),tags$td)
      visButton<-actionButton(paste(ns('visbutton_'),pazienteTable[["id"]][i],sep = ""),label="",icon = icon("eye"),onClick=onClick)
      currTr<-tagAppendChild(currTr,tags$td(visButton))
      trList<-list(trList,currTr)
    }
    currTr<-getTr(getExtractList(roiPatientTable,"extract"),tags$td)
    trList<-list(trList,currTr)
    table<-tags$table(class="table")
    table<-tagAppendChildren(table,trList)
    table
  })
  
  filter<-callModule(modelRadiomicaFilter,"radiomica_filter")
  callModule(modelRadiomicaMathmodel,"radiomica_math_model")
  status<-callModule(modelRadiomicaExtract,"radiomica_extract",roi,getPazienteTable,extractOutputs,filter)
  results<-callModule(modelRadiomicaResults,"radiomica_results",status)
  covariate_selected<-callModule(modelRadiomicaMonovariateAnalysis,"radiomica_monovariate_analysis",results)
  features_selected<-callModule(modelRadiomicaFeaturesSelection,"radiomica_features_selection",results,covariate_selected)
  callModule(modelRadiomicaRun,"radiomica_run",results,features_selected)
  
  observe({
    if (status$running) {
      shinyjs::js$disableTabs(id="radiomica-tabs",tab="Extract")
    }
    else {
      shinyjs::js$enableTabs("radiomica-tabs")
    }
  })
  
  observe({
  for (tab in c("Results","Monovariate Analysis","Features Selection","Run")) {
      if(status$done) {
        shinyjs::js$showTab(id="radiomica-tabs",tab=tab)
        if (tab %in% c("Features Selection","Run")) {
          shinyjs::js$disableTab(id="radiomica-tabs",tab=tab)
        }
      }
      else {
        shinyjs::js$hideTab(id="radiomica-tabs",tab=tab)
      }
    }
  })
  
}