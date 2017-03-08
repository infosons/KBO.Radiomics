tableOutput<- function(output,outputCol,data,colnames=list(),...) {
  tableWithoutId<-reactive({
    table<-data()
    table[["id"]]=NULL
    table[["create_date"]]=NULL
    table[["write_date"]]=NULL
    colnames(table)<-sapply(colnames(table),function(col) {
      if (col %in% names(colnames)) {
        colnames[[col]]
      }
      else {
        col
      }
    },simplify = TRUE)
    table
  })
  
  output[[outputCol]]<-DT::renderDataTable(do.call(DT::datatable,list(tableWithoutId(),...)))
}
