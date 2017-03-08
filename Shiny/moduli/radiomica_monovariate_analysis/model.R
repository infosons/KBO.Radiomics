modelRadiomicaMonovariateAnalysis<- function(input,output,session,results) {
  
  ns<-session$ns
  
  modelBuilding<-reactive({
    matriciona<-results()
    output<-data.frame()
    covariates<-sprintf("`%s`",colnames(matriciona))
    outputCol<-tail(covariates,1)
    for (covariata in covariates) {
      print(paste(outputCol,"~",covariata,sep=""))
      a<-glm(formula=as.formula(paste(outputCol,"~",covariata,sep="")),family=binomial(link = "logit"),data=matriciona)
      b<-summary(a)
      coeff<-as.data.frame(b$coefficients)
      if (nrow(coeff)>1) {
        output<-rbind(output,coeff[2,])
      }
    }
    rownames(output)<-gsub("`","",rownames(output))
    output
  })
  
  output$csv=downloadHandler("model_building.csv",function(file) {
    write.csv(modelBuilding(), file)
  })
  
  output$modelBuilding=DT::renderDataTable({
    output<-modelBuilding()
    DT::datatable(output)
  })
  observe({
    if(length(input$modelBuilding_rows_selected)<2) {
      shinyjs::js$disableTab(id="radiomica-tabs",tab="Features Selection")
    }
    else {
      shinyjs::js$enableTab(id="radiomica-tabs",tab="Features Selection")
    }
  })
  
  return(reactive(input$modelBuilding_rows_selected))
}
