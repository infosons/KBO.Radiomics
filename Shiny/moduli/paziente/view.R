viewPaziente = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  input<-tagList(textInput(inputId = ns("patient_name"), label = "Patient name"),
                 directoryInput(ns("cartella_immagini"), label = 'Cartella Immagini'))
  return(viewTable(id,input,"tablePazienti"))
}