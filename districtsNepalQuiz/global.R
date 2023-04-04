# app.R or global.R

# Load required packages
library(shiny)
library(leaflet)

library(sf)
library(dplyr)

# read the GeoJSON file
data <- st_read(dsn = "Districts_simplified.geojson")
data$id <- 1:nrow(data)

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

