viewRadiomicaResults = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  view<-tagList(
    downloadButton(ns("csv"),label = "Scarica CSV"),
    DT::dataTableOutput(ns("table"))
  )
  return(view)
}