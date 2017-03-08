modelRadiomicaRun<- function(input,output,session,results,features_selected) {
  
  ns<-session$ns
  
  getModel<-reactive({
    matriciona<-results()
    colOutput<-tail(colnames(matriciona),1)
    formulaString<-paste(sprintf("`%s`",features_selected()),collapse = "+")
    formulaString<-paste(sprintf("`%s`",colOutput),formulaString,sep = "~")
    a<-glm(formula=as.formula(formulaString),family = binomial(),data=matriciona)
    b<-summary(a)
    b.0<-pROC::roc(matriciona[[colOutput]],predict(a))
    b.0
  })
  
  output$plot<-renderPlot(plot(getModel()))
  
  output$auc<-renderPrint(print(getModel()))
  
}
