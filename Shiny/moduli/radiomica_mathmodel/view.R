viewRadiomicaMathModel = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  view<-tagList(uiOutput(ns("model"))
  )
  return(view)
}