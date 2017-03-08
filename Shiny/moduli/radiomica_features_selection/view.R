viewRadiomicaFeaturesSelection = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  modalContent<-tagList(
    selectInput(ns("method"),"Method",choices = c("number","color","shade","ellipse","circle","square","pie"),selected="number"),
    plotOutput(ns("crossPlot"),height="auto")
  )
  view<-tagList(
    HTML("<h3>Selezionare almeno una feature</h3>"),
    actionButton(ns("crossPlot"), "Plot Cross Correlation"),
    DT::dataTableOutput(ns("cross")),
    bsModal(ns("modal"),"Cross Correlation",ns("crossPlot"),modalContent,size="large")
  )
  return(view)
}