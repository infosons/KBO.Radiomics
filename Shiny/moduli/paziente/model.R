modelPaziente<- function(input,output,session) {
  ns<-session$ns
  feedBack<-function(message) {
    createAlert(session, ns("feedback"),content = message,append = FALSE)
  }
  table<-"Paziente"
  columns<-c("patient_name","cartella_immagini")
  updateFuns<-c(updateTextInput,updateDirectoryInput)
  standardValues<-c("","~")
  observeEvent(
    ignoreNULL = TRUE,
    eventExpr = {
      input$cartella_immagini
    },
    handlerExpr = {
      if (input$cartella_immagini > 0) {
        # condition prevents handler execution on initial app launch
        
        # launch the directory selection dialog with initial path read from the widget
        path = choose.dir(default = readDirectoryInput(session, 'cartella_immagini'))
        
        # update the widget value
        updateDirectoryInput(session, 'cartella_immagini', value = path)
      }
    }
  )
  
  output$cartella_immagini = renderText({readDirectoryInput(session, 'cartella_immagini')})
  
  paziente<-modelTable(input,output,session,table,updateFuns,standardValues,columns,standardSave=FALSE,editButtons=FALSE)
  
  getPazienteTable<-reactive({
    data<-paziente()
  })
  
  observeEvent(input$NuovosubmitBtn, {
    data<-c(input$patient_name,readDirectoryInput(session, 'cartella_immagini'))
    names(data)<-c("patient_name","cartella_immagini")
    saveData("Paziente",data,input$id)
    toggleModal(session, "form_nuovo", toggle = "close")
    tableEvents[[table]]=tableEvents[[table]]+1
    if (is.na(input$id)) {
      feedBack("Voce aggiunta con succeso")
    }
    else {
      feedBack("Voce modificata con succeso")
    }
  },priority=1)
  return(paziente)
}