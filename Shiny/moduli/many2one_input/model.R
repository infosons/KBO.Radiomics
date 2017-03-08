modelMany2One<- function(input,output,session,sourceTable,labelCamps,inputId,label) {
  ns<-session$ns
  getInput<-reactive({
    table<-sourceTable()
    inputs<-table[["id"]]
    names(inputs)<-table[[labelCamps]]
    selectInput(inputId,label, inputs, multiple=FALSE, selectize=TRUE)
  })
  return(getInput)
}
