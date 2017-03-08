viewSplash = function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  splashPage<-wellPanel(HTML(paste(readLines("views/splash-page.html"), collapse=" ")))
  splashPage
}
