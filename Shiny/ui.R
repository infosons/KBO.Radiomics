library(shinyBS)
library(shiny)
mycss <- "
#plot-container {
position: relative;
}
#loading-spinner {
position: absolute;
left: 50%;
top: 50%;
z-index: -1;
margin-top: -33px;  /* half of the spinner's height */
margin-left: -33px; /* half of the spinner's width */
}
#plot.recalculating {
z-index: -2;

.shiny-progress .progress-text {
          background-color: #337ab7;
          color: white;
}
"

header <- HTML(paste(readLines("views/header.html"), collapse=" "))
shinyUI(fluidPage(
  tags$head(tags$style(HTML(mycss))),
  fluidRow(header),
  navlistPanel(id="visualizzaPaziente-main_menu",
    tabPanel("Home",viewSplash("model_splash")),
    tabPanel("Radiomica", viewRadiomica("radiomica")),
    tabPanel("Pazienti",viewVisualizzaPaziente("visualizzaPaziente")),
    tabPanel("Dizionari",viewDizionario("dizionario")),
    tabPanel("PACS Server",wellPanel(navbarPage(title="PACS Server",tabPanel("PACS Server Administration",HTML("<h1>Solo con Enterprise</h1>"))))),
    widths = c(2, 10)
  )
  ))