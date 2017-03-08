modelRadiomicaFeaturesSelection<- function(input,output,session,results,covariate_selected) {
  
  ns<-session$ns
  crossMatrix<-reactive({
    matrix.cross<-results()[,covariate_selected()]
    matrice.risultati<-cor(as.matrix(matrix.cross))
    matrice.risultati
  })
  
  output$cross=DT::renderDataTable({
    DT::datatable({
      as.data.frame(crossMatrix())
    },options = list(scrollX = TRUE,searching=FALSE))
  })
  
  output$crossPlot<-renderPlot({
    matrix<-crossMatrix()
    corrplot::corrplot(matrix, method=input$method)
    },
                               height = function() {
                                 session$clientData[[paste("output",ns("crossPlot"),"width",sep="_")]]
                               })
  
  observe({
    if(length(input$cross_rows_selected)<1) {
      shinyjs::js$disableTab(id="radiomica-tabs",tab="Run")
    }
    else {
      shinyjs::js$enableTab(id="radiomica-tabs",tab="Run")
    }
  })
  
  return(reactive(input$cross_rows_selected))
}
