# app.R or global.R

# Load required packages
library(shiny)

# Load ui.R and server.R
source("ui.R")
source("server.R")

# Run the app
shinyApp(ui = ui, server = server)
