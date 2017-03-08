library(moddicomV2)
library(shinyBS)
library(shiny)
library(DT)
source("persistenza.R")

shinyServer(function(input, output, session) {
  paziente<-callModule(modelPaziente,"paziente")
  datoClinico<-callModule(modelDatoClinico,"datoClinico")
  roi<-callModule(modelROI,"roi")
  pazienteDati<-callModule(modelVisualizzaPaziente,"visualizzaPaziente")
  paziente_datoClinico<-callModule(modelDatoClinico_paziente,"datoClinico_paziente",datoClinico,pazienteDati)
  paziente_roi<-callModule(modelROI_paziente,"roi_paziente",roi,pazienteDati)
  paziente_data<-reactive({
    data<-paziente()
    data<-addEditButtons(data,NS("paziente"))
    data<-addVisualizeButttons(data,NS("visualizzaPaziente"))
    data
  })
  tableOutput(output,"tablePazienti",paziente_data,list(patient_name="Patient name",cartella_immagini="Cartella immagini"),escape=FALSE,selection=c("none"))
  tableOutput(output,"datoClinicoTable",datoClinico,list(nome="Nome",tipo="Tipo",io="I/O"),escape=FALSE,selection=c("none"))
  tableOutput(output,"datoClinicoPazienteTable",paziente_datoClinico,list(nome="Nome",io="I/O",valore="Valore"),escape=FALSE,selection=c("none"))
  tableOutput(output,"RoiPazienteTable",paziente_roi,list(roi_nome="ROI",nome_roi_paziente="Nome ROI-Paziente"),escape=FALSE,selection=c("none"))
  tableOutput(output,"roiTable",roi,list(nome="Nome"),escape=FALSE,selection=c("none"))
  modelRadiomica(input,output,session,paziente,roi,pazienteDati)
  callModule(modelSplash,"model_splash")
  session$onSessionEnded(function() {
    if (file.exists("lock")) {
      file.remove("lock")
    }
    stopApp()
  })
})