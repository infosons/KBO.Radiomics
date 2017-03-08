modelROI_paziente<- function(input,output,session,roi,patientData) {
  ns<-session$ns
  table<-"ROI_ROIPaziente"
  columns<-c("id_paziente","id_roi","nome_roi_paziente")
  updateFuns<-c(updateNumericInput,updateSelectInput,updateTextInput)
  standardValues<-c("IfsNoUpdate","","")
  selectQuery<-reactive({
    if(typeof(patientData)=="list") {
      sprintf("SELECT rrp.id, r.nome as roi_nome, rrp.nome_roi_paziente FROM ROI_ROIPaziente rrp INNER JOIN 
                                ROI r ON r.id=rrp.id_roi WHERE rrp.id_paziente=%i",patientData$id)
    }
  })
  tableOutput<-modelTable(input,output,session,table,updateFuns,standardValues,columns,selectQuery=selectQuery)
  roi_many2One<-callModule(modelMany2One,ns("roi"),roi,"nome",ns('id_roi'),"ROI")
  
  output$columnsROI = renderUI({
    obj<-patientData$geoletObj
    columns<-obj$getROIList()[2,]
    selectInput(inputId = ns("nome_roi_paziente"), label = "Nome ROI-Paziente", c(columns), multiple=FALSE, selectize=TRUE)
  })
  output$roi=renderUI({
    roi_many2One()
  })
  output$patient_id=renderUI({
    tagList(shinyjs::useShinyjs(),shinyjs::hidden(numericInput(ns("id_paziente"),"Patient id", value=patientData$id)))
  })
  return(tableOutput)
}
