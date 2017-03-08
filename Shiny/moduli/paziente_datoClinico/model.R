modelDatoClinico_paziente<- function(input,output,session,datoClinico,patientData) {
  ns<-session$ns
  table<-"DatoClinico_Paziente"
  columns<-c("id_paziente","id_dato_clinico","valore")
  updateFuns<-c(updateNumericInput,updateSelectInput,updateTextInput)
  standardValues<-c("IfsNoUpdate","","")
  selectQuery<-reactive({
    if(typeof(patientData)=="list") {
      sprintf("SELECT dcp.id, dc.nome, dc.io, dcp.valore FROM DatoClinico_Paziente dcp INNER JOIN 
                                DatoClinico dc ON dc.id=dcp.id_dato_clinico WHERE dcp.id_paziente=%i",patientData$id)
    }
  })
  tableOutput<-modelTable(input,output,session,table,updateFuns,standardValues,columns,selectQuery=selectQuery)
  datoClinico_many2One<-callModule(modelMany2One,ns("dato_clinico"),datoClinico,"nome",ns('id_dato_clinico'),"Dato Clinico")
  output$datoClinico=renderUI({
    datoClinico_many2One()
  })
  output$patient_id=renderUI({
    tagList(shinyjs::useShinyjs(),shinyjs::hidden(numericInput(ns("id_paziente"),"Patient id", value=patientData$id)))
  })
  return(tableOutput)
}
