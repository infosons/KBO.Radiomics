modelRadiomicaMathmodel<- function(input,output,session) {
  
  ns<-session$ns
  
  output$model = renderUI({
    choices=c("Logistic Regression","SVM (Solo con Enterprise)","Random Forest (Solo con Enterprise)")
    shinyjs::useShinyjs()
    shinyjs::disabled(checkboxGroupInput(ns("model"),"Selezionare il modello",choices,selected = "Logistic Regression"))
  })
}