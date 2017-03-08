viewDatoClinico = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  input<-tagList(textInput(inputId = ns("nome"), label = "Nome"),
                 selectInput(inputId = ns("io"),label="I/O",c("INPUT","OUTPUT")),
                 selectInput(inputId = ns("tipo"),label="Tipo",c("Numeric","Text")))
  return(viewTable(id,input,"datoClinicoTable"))
}