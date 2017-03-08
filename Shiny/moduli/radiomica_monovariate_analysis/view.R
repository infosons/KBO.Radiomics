viewRadiomicaMonovariateAnalysis = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  view<-tagList(
    downloadButton(ns("csv"),label = "Scarica CSV"),
    HTML("<h3>Selezionare almeno due features</h3>"),
    DT::dataTableOutput(ns("modelBuilding"))
  )
  return(view)
}