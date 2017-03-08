
modelVisualizzaPaziente<- function(input,output,session) {
  # Combine the selected variables into a new data frame
  ns<-session$ns
  
  greyCol<-reactive({grey.colors(255,gamma = input$imageGamma,start = input$imageLevel[1]/255,end = input$imageLevel[2]/255)})
  
  observeEvent(patientData$cartella_immagini,{
    shinyjs::js$showLoading()
  },priority = 2)
  
  openDicomFolder<-function(obj) {
    reactive(obj$openDICOMFolder(pathToOpen = patientData$cartella_immagini))
  }
  
  patientData<-reactiveValues()
  
  getVoxCube<-reactive({
    obj <- moddicomV2::geoLet()
    patientData$geoletObj<-obj
    openDicomFolder(patientData$geoletObj)()
    obj<-patientData$geoletObj
    save(obj,file="obj")
    voxCube <- patientData$geoletObj$getImageVoxelCube()
    voxCube
  })
  
  output$imageSlider<-renderUI({
    lenVoxCube<-length(getVoxCube()[1,1,])
    sliderInput(ns('imageSlider'),'Image Slider',min=1,max=lenVoxCube,value=1,step = 1)
  })
  
  getImage<-reactive({
    voxCube<-getVoxCube()
    voxCube[,,input$imageSlider]
    })
  
  output$plot1 <- renderPlot({
    image(getImage(), col = greyCol())
    shinyjs::js$hideLoading()
  },height = function() {
    session$clientData[[paste("output",ns("plot1"),"width",sep="_")]]
  })
  
  output$plot3 <- renderPlot({
    obj<-patientData$geoletObj
    img<-obj$getROIVoxels(input$roi)$masked.images$voxelCube[,,input$imageSlider]
    image(img, col = greyCol())
  },height = function() {
    session$clientData[[paste("output",ns("plot3"),"width",sep="_")]]
  })
  
  zoomAspectRatio <- reactive({
    brush<-input$plot2_brush
    if (!is.null(brush) && (brush$xmax-brush$xmin)!=0) {
      (brush$ymax-brush$ymin)/(brush$xmax-brush$xmin)
    }
    else {
      1
    }
  })
  
  output$area_brushed<-renderText({
    if(!is.null(input$plot2_brush)) {
      "brushed"
    }
    else {
      "not brushed"
    }
  })
  outputOptions(output, "area_brushed", suspendWhenHidden = FALSE)
  
  output$plot2 <- renderPlot({
    brush<-input$plot2_brush
    if (!is.null(brush)) {
      x_lims <- c(brush$xmin, brush$xmax)
      y_lims <- c(brush$ymin, brush$ymax)
      image(getImage(), col = greyCol(),xlim=x_lims,ylim=y_lims)
    } else {
      NULL
    }
  },height = function() {
    zoomAspectRatio()*session$clientData[[paste("output",ns("plot2"),"width",sep="_")]]
  })
  
  output$hist <- renderPlot({
    img<-getImage()
    d <- density(getImage())
    plot(d, main="",xlim=c(0,255),sub="",ylab="",xlab="")
    polygon(d, col="red", border="blue")
  })
  
  output$table <- DT::renderDataTable(DT::datatable(table,extensions = 'Buttons', options = list(
    dom = 'Bfrtip',
    buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
  )))
  
  output$columnsROI = renderUI({
    columns<-obj$getROIList()[2,]
    selectInput(ns('roi'), 'Regions of Interest', c(columns))
  })
  
  output$patientName = renderText(patientData$patient_name)
  
  shinyjs::js$hideTabOnClick(id=ns("paziente_tab"),tabClick="Pazienti",tabHide="Visualizza Paziente")
  shinyjs::js$hideTab(ns("paziente_tab"),"Visualizza Paziente")
  
  observeEvent(input$vis_button,{
    shinyjs::js$showTab(ns("paziente_tab"),"Visualizza Paziente")
    id <- as.numeric(strsplit(input$vis_button, "_")[[1]][2])
    record<-getRecord("Paziente",id)
    for (col in names(record)) {
      patientData[[col]]<-record[[col]]
    }
    updateTabsetPanel(session,"main_menu",selected="Pazienti")
    updateNavbarPage(session, "paziente_tab", selected = "Visualizza Paziente")
  })
  return(patientData)
}
