viewRoi = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  input<-tagList(textInput(inputId = ns("nome"), label = "Nome"))
  return(viewTable(id,input,"roiTable"))
}