# app.R or global.R

# Load required packages
library(shiny)

#load('data.RData')
#load(url("https://github.com/pratik-tan10/backend/blob/master/rapp/data.RData?raw=true"))
load('Data.RData')

# Wrap shinyApp call in a tryCatch block
tryCatch({
  # Load ui.R and server.R
  source("ui.R")
  source("server.R")
  
  shinyApp(ui = ui, server = server)
  
}, error = function(e) {
  if (grepl("object 'ui' not found", e$message)) {
    # Wait for 1 second and try again
    Sys.sleep(2)
    tryCatch({
      shinyApp(ui = ui, server = server)
    }, error = function(e) {})
  }
}, finally = {
  # Ensure that shinyApp is called at least once
  # Load ui.R and server.R
  source("ui.R")
  source("server.R")
  shinyApp(ui = ui, server = server)
})

