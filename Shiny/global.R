tableEvents=reactiveValues()
xrange<-function(n) {
  if (n<=0) {
    return(list())
  }
  else {
    return(1:n)
  }
}

getTr <- function(children,childrenTag) {
  tdList<-lapply(children,function(x) childrenTag(x))
  tr<-tags$tr()
  return(tagAppendChildren(tr,tdList))
}

getTable<- function(data) {
  trHeader<-getTr(names(data),tags$th)
  trBody<-lapply(xrange(nrow(data)),function(i) getTr(data[i,],tags$td))
  do.call(tags$table,list(trHeader,trBody,class="table"))
}

getWarning<-function(innerHtml) {
  tags$div(HTML(innerHtml),class="alert alert-warning")
}

getInfo<-function(innerHTML) {
  tags$div(HTML(innerHTML),class="alert alert-info")
}

getSuccess<-function(innerHTML) {
  tags$div(HTML(innerHTML),class="alert alert-success")
}

source("directoryInput.R")
source("persistenza.R")
for (folder in list.files('./moduli')) {
  viewFile<-paste("moduli/",folder,"/view.R",sep="")
  modelFile<-paste("moduli/",folder,"/model.R",sep="")
  if (file.exists(viewFile)) {
    source(viewFile)
  }
  if (file.exists(modelFile)) {
    source(modelFile)
  }
}
source("moduli/table/tableOutput.R")