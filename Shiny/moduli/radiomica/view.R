viewRadiomica = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  seleziona_pazienti<- fluidRow(DT::dataTableOutput("tablePazientiRadiomica"))
  radiomica_navbar<-tagList(shinyjs::useShinyjs(),shinyjs::extendShinyjs("www/js/shinyjs.extensions.js"),navbarPage(
    title = 'Radiomica',
    tabPanel('Seleziona Pazienti',seleziona_pazienti),
    tabPanel('ROI',tagList(uiOutput('panelROI'))),
    tabPanel('Feature',viewRadiomicaFilter("radiomica_filter")),
    tabPanel('Math Model',viewRadiomicaMathModel("radiomica_math_model")),
    tabPanel('Extract',viewRadiomicaExtract("radiomica_extract")),
    tabPanel('Results',viewRadiomicaResults("radiomica_results")),
    tabPanel('Monovariate Analysis',viewRadiomicaMonovariateAnalysis("radiomica_monovariate_analysis")),
    tabPanel('Features Selection',viewRadiomicaFeaturesSelection("radiomica_features_selection")),
    tabPanel('Run',viewRadiomicaRun("radiomica_run")),
    id="radiomica-tabs"))
  return(wellPanel(radiomica_navbar))
}