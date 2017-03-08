viewRadiomicaFilter = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  filterView<-tagList(
    "Verranno estratte le seguenti Features",
    uiOutput(ns('tableFilter')),
    uiOutput(ns("filters"))
  )
  return(filterView)
}