modelRadiomicaFilter<- function(input,output,session) {
  
  ns<-session$ns
  
  filterRow<-function(i,selected="none",sigma_val=0) {
      tags$tr(
        tags$td(
          selectInput(ns(paste("filter_type",i,sep="")),"Tipo",choices = c("none","LoG"),selected = selected)
        ),
        tags$td(
          numericInput(ns(paste("sigma",i,sep="")),"Sigma",value = sigma_val,step = 0.1)
        )
      )
  }
  
  filters<-reactiveValues(n=1,m=0)
  
  output$tableFilter = renderUI({
    features<-moddicomV2::RAD.getFeaturesListNames()
    shinyjs::useShinyjs()
    shinyjs::disabled(checkboxGroupInput(ns("features"),"",choices=features,selected = features))
  })
  
  output$filters = renderUI({
    out<-tags$table(class="table")
    for (i in xrange(filters$n)) {
      if (i<=filters$m) {
        selected=filters$vals[[i]][1]
        sigma_val=filters$vals[[i]][2]
      }
      else {
        selected="none"
        sigma_val=0
      }
      out<-tagAppendChild(out,filterRow(i,selected,sigma_val))
    }
    buttons<-tagList(actionButton(ns("agg_filtro"),"Aggiungi filtro"))
    if (filters$n>1) {
      buttons<-tagAppendChild(buttons,actionButton(ns("el_filtro"),"Togli filtro"))
    }
    tagList("Selezionare i filtri da applicare",out,buttons)
  })
  
  outputOptions(output, "filters", suspendWhenHidden = FALSE)
  
  setFilters<-function() {
    filters$vals=lapply(xrange(filters$n),function(i) c(input[[paste("filter_type",i,sep="")]],input[[paste("sigma",i,sep="")]]))
    filters$m=filters$n
  }
  
  observeEvent(input$agg_filtro, {
    setFilters()
    filters$n=filters$n+1
  }
  )
  
  observeEvent(input$el_filtro, {
    filters$n=filters$n-1
    setFilters()
  }
  )
  
  reactive({
    setFilters()
    filters$vals
  })
}