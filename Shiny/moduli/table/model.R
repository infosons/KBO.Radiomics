modelTable<- function(input,output,session,table,updateFuns,standardValues,columns,standardSave=TRUE,editButtons=TRUE,selectQuery=NULL) {
  ns<-session$ns
  standardValues=c(NULL,standardValues)
  tableEvents[[table]]=0
  
  feedBack<-function(message) {
    createAlert(session, ns("feedback"),content = message,append = FALSE)
  }
  
  setInputs<-function(id=NA,values=standardValues) {
    updateNumericInput(session,"id",value=id)
    i<-1
    for (fun in updateFuns) {
      if (values[i]=="IfsNoUpdate") {
        i=i+1
        next
      }
      funInputs=names(formals(fun))
      if ("value" %in% funInputs) {
        fun(session,columns[i],value=values[i])
      }
      else if("selected" %in% funInputs) {
        fun(session,columns[i],selected=values[i])
      }
      i=i+1
    }
  }
  
  getTable<- reactive({
    input$delete_button
    input$NuovosubmitBtn
    tableEvents[[table]]
    if (!is.null(selectQuery)) {
      selectQuery<-selectQuery()
    }
    outTable<-loadData(table,selectQuery)
    if (editButtons) {
      outTable<-addEditButtons(outTable,ns) 
    }
    outTable
  })
  
  if(standardSave) {
    observeEvent(input$NuovosubmitBtn, {
      data<-sapply(columns,function(x) input[[x]])
      names(data)<-columns
      saveData(table,data,input$id)
      tableEvents[[table]]=tableEvents[[table]]+1
      toggleModal(session, "form_nuovo", toggle = "close")
      if (is.na(input$id)) {
        feedBack("Voce aggiunta con succeso")
      }
      else {
        feedBack("Voce modificata con succeso")
      }
    },priority=1)
  }
  
  observeEvent(input$agg, {
    setInputs()
  }) 
  
  observeEvent(input$delete_button, {
    id <- as.numeric(strsplit(input$delete_button, "_")[[1]][2])
    deleteRecord(table,id)
    tableEvents[[table]]=tableEvents[[table]]+1
    feedBack("Voce eliminata con succeso")
  })
  
  observeEvent(input$edit_button, {
    id <- as.numeric(strsplit(input$edit_button, "_")[[1]][2])
    record<-getRecord(table,id)
    values<-c()
    for (col in columns) {
      values<-c(values,record[[col]])
    }
    setInputs(id=record[["id"]],values=values)
    toggleModal(session, "form_nuovo", toggle = "open")
  })
  
  return(getTable)
}
