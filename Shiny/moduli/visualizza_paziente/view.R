viewVisualizzaPaziente = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  absPanel<-conditionalPanel(condition = "output['visualizzaPaziente-area_brushed']=='brushed'",
  absolutePanel(
    width="100%",
    draggable = TRUE,
    plotOutput(ns('plot2')),
    style = "z-index: 1000 ;opacity: 0.85;"
  ))
  plotPanel <- tagList(div(id = "plot-container",
                           tags$img(src = "img/loading.gif",
                                    id = "loading-spinner"),
                           plotOutput(ns('plot1'),brush = brushOpts(
    id = ns("plot2_brush"),
    resetOnNew = FALSE
  ),height="auto")
  #plotOutput(ns('plot3'),height="auto")
  ))
  sidebarHeader <- wellPanel(plotOutput(ns('hist'),height="250px"))
  sidebar <- wellPanel(
    absPanel,
    h4("Parametri"),
    sliderInput(ns('imageLevel'),'Image level',min=0,max=255,value=c(0,255)),
    sliderInput(ns('imageGamma'),'Image gamma',min=1,max=10,value=2,step=.1),
    #uiOutput(ns('columnsROI')),
    uiOutput(ns('imageSlider')),
    bsModal("modalExample", "Finestra modale", "histBut", size = "large",
            "test")
    #actionButton("histBut", "Histograms",width="100%"),
    #actionButton("roiFeatValBut", "ROI feature values",width="100%")
  )
  daticlinici_e_roi<-fluidRow(column(6,viewDatoClinico_paziente("datoClinico_paziente")),
           column(6,viewROI_paziente("roi_paziente")))
  navBarOutput<-navbarPage(title="",
             tabPanel("Pazienti",viewPaziente("paziente")),
             tabPanel("Visualizza Paziente",
                      headerPanel(textOutput(ns("patientName"))),
                      fluidRow(column(8,plotPanel),column(4,sidebar)),
                      daticlinici_e_roi),
             id=ns("paziente_tab"))
  return(navBarOutput)
}