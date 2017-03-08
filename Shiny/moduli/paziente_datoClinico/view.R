viewDatoClinico_paziente = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  input<-tagList(uiOutput(ns("patient_id")),
    uiOutput(ns("datoClinico")),
    textInput(inputId = ns("valore"), label = "Valore"))
  return(viewTable(id,input,"datoClinicoPazienteTable",title="Dati clinici associati"))
}