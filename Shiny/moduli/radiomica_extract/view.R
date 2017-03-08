viewRadiomicaExtract = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  view<-tagList(
    uiOutput(ns("dataTable")),
    uiOutput(ns("main")),
    uiOutput(ns("progress"))
  )
  return(view)
}