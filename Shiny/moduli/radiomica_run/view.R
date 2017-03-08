viewRadiomicaRun = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  view<-tagList(
    plotOutput(ns("plot")),
    verbatimTextOutput(ns("auc"))
  )
  return(view)
}