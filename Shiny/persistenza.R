library(RSQLite)
sqlitePath <- "persistenza/db.s3db"

data=list(data=paste(serialize(moddicomV2::geoLet(),NULL)))
#saveData("t1",data,NA)

saveData <- function(table,data,id) {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the update query by looping over the data fields
  if (is.na(id)) {
    query <- sprintf(
      "INSERT INTO %s (%s) VALUES ('%s')",
      table, 
      paste(names(data), collapse = ", "),
      paste(data, collapse = "', '")
    )
  }
  else {
    updateVals=c("write_date=CURRENT_TIMESTAMP")
    for (col in names(data)) {
      updateVals=c(updateVals,sprintf("%s='%s'",col,data[[col]]))
    }
    query <- sprintf(
      "UPDATE %s SET %s WHERE id=%i",
      table, 
      paste(updateVals, collapse = ", "),
      id
    )
  }
  # Submit the update query and disconnect
  dbGetQuery(db, query)
  dbDisconnect(db)
}

shinyInput <- function(FUN, data, id, ...) {
  rowNames<-row.names(data)
  len<-length(rowNames)
  for (i in seq_len(len)) {
    htmlText<-as.character(FUN(paste0(id, data[i,1]), ...))
    rowNames[i] <- paste(rowNames[i],htmlText)
  }
  rowNames
}

loadData <- function(table,query=NULL) {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the fetching query
  if (is.null(query)) {
    query <- sprintf("SELECT * FROM %s", table)
  }
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

executeQuery<- function(query) {
  db <- dbConnect(SQLite(), sqlitePath)
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

executeQueryResponsive <-function(session,tables,query) {
  reactivePoll(4000, session,
               # This function returns the time that the logfile was last
               # modified
               checkFunc = function() {
                 innerQuery<-paste(sapply(tables,function(x) paste("SELECT write_date FROM",x)),collapse = " UNION ALL ")
                 print(sprintf("SELECT max(write_date) FROM (%s)",innerQuery))
                 executeQuery(sprintf("SELECT max(write_date) FROM (%s)",innerQuery))[["max(write_date)"]]
               },
               # This function returns the content of the logfile
               valueFunc = function() {
                 executeQuery(query)
               }
  )
}

addEditButtons<- function(data,ns) {
  onClick=sprintf('Shiny.onInputChange(\"%s\",  Math.random()+this.id)',ns("edit_button"))
  row.names(data)<-shinyInput(actionButton, data, 'editbutton_', label = "", onclick = onClick ,icon=icon("pencil"))
  onClick=sprintf('if(confirm("Sei sicuro?")) Shiny.onInputChange(\"%s\",  this.id)',ns("delete_button"))
  row.names(data)<-shinyInput(actionButton, data, 'deletebutton_', label = "", onclick = onClick,icon=icon("remove") )
  return(data)
}

addVisualizeButttons<-function(data,ns) {
  onClick=sprintf('Shiny.onInputChange(\"%s\",  Math.random()+this.id)',ns("vis_button"))
  row.names(data)<-shinyInput(actionButton, data, 'visbutton_', label = "", onclick = onClick,icon=icon("eye") )
  return(data)
}

getRecord<-function(table,id) {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s WHERE id=%i LIMIT 1", table,id)
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

deleteRecord <- function(table,id) {
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the update query by looping over the data fields
  query <- sprintf("DELETE FROM %s WHERE id=%i",table,id)
  # Submit the update query and disconnect
  dbGetQuery(db, query)
  dbDisconnect(db)
}

checkMany2Many <- function(table, col1, ids1, col2, ids2) {
  db <- dbConnect(SQLite(), sqlitePath)
  m<-length(ids1)
  n<-length(ids2)
  output<-matrix(nrow=m,ncol=n)
  for (i in xrange(m)) {
    for (j in xrange(n)) {
      query <- sprintf("SELECT id from %s WHERE %s=%i AND %s=%i",table,col1,ids1[i],col2,ids2[j])
      res<- dbGetQuery(db, query)
      output[i,j]=length(res[["id"]])>0
    }
  }
  dbDisconnect(db)
  output
}