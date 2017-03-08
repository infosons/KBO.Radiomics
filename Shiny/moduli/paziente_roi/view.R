viewROI_paziente = function(id,outputTable="RoiPazienteTable") {
  # Create a namespace function using the provided id
  ns <- NS(id)
  input<-tagList(uiOutput(ns("patient_id")),
    uiOutput(ns("roi")),
    uiOutput(ns("columnsROI")))
  return(viewTable(id,input,outputTable,title="ROI associati"))
}