viewTable = function(id,inputTagList,tableOutput,title=NULL) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  pazienteInputForm<-wellPanel(shinyjs::useShinyjs(),shinyjs::hidden(numericInput(ns("id"),value=NULL,label="id"))
                               ,inputTagList,
                               actionButton(inputId = ns("NuovosubmitBtn"), label = "Salva"))
  pazienteMain<-wellPanel(
    titlePanel(title),
    bsModal(ns("form_nuovo"), "Nuova/Modifica voce", ns("agg"), size = "large",
            pazienteInputForm),
    bsAlert(ns("feedback")),
    actionButton(ns("agg"), "Aggiungi Voce"), br(),
    DT::dataTableOutput(tableOutput)
  )
  return(pazienteMain)
}
