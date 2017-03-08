modelDatoClinico<- function(input,output,session) {
  table<-"DatoClinico"
  columns<-c("nome","io","tipo")
  updateFuns<-c(updateTextInput,updateSelectInput,updateSelectInput)
  standardValues<-c("","INPUT","Numeric")
  tableOutput<-modelTable(input,output,session,table,updateFuns,standardValues,columns)
  return(tableOutput)
}
