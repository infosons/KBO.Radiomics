viewDizionario = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  mainPanel<-navbarPage(
    title = 'Dizionari',
    tabPanel('Dizionario Dati Clinici',viewDatoClinico("datoClinico")),
    tabPanel('Dizionario ROI',viewRoi("roi")))
  return(mainPanel)
}