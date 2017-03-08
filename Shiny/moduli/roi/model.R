modelROI<- function(input,output,session) {
  table<-"ROI"
  columns<-c("nome")
  updateFuns<-c(updateTextInput)
  standardValues<-c("")
  tableOutput<-modelTable(input,output,session,table,updateFuns,standardValues,columns)
  return(tableOutput)
}
