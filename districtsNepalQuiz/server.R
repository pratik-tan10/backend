server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
    m = leaflet()%>%addTiles(urlTemplate = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', 
                             options = tileOptions(minZoom = 6, maxZoom = 10))
    for (i in (1:nrow(data))){
      m = m%>%
        addPolygons(data = data[i, ],
                    layerId = data$DISTRICT[i],
                    stroke = TRUE,
                    color = "#FFFFFF",
                    weight = 2,
                    fillColor = "transparent",
                    opacity = 1,
                    fillOpacity = 0,
                    group = "polygons",
                    highlightOptions = highlightOptions(color = "red", bringToFront = TRUE, fillColor = "#73A2BA", fillOpacity = 1, weight = 3),
                    popup = ~paste0("Name: ", data$DISTRICT[i]),
                    smoothFactor = 0.5,
        )
    }
    m%>%fitBounds(80.6, 26.3, 88.2, 30.5)
  })
  
  # Randomly select  a district
  selected_district <- sample(data$DISTRICT, length(data$DISTRICT))
  click_count <-  reactiveVal(1)
  # create the district name output
  output$district_name <- renderUI({
    div(
      # randomly select a district name
      selected_district[click_count()]
    )
  })
  
  # initialize a list to store the clicked districts
  clicked_districts <- list()
  
  # observe clicks on the map
  observeEvent(input$map_shape_click, {
    
    # increment click_count every time the map is clicked
    click_count(click_count() + 1)
    
    # If click_count goes above 77 make it wrap back to 1
    if (click_count() > 77) {
      click_count(1)
    }
    
    # get the name of the clicked district
    district_name <- input$map_shape_click$id
    
    # add the district name to the list of clicked districts
    clicked_districts[[length(clicked_districts)+1]] <- district_name
    
    
    # create a new div for the clicked district
    insertUI(
      selector = "#clicked_districts",
      ui = tags$div(
        style = ifelse(as.character(input$map_shape_click$id) == as.character(selected_district[click_count()-1]), "border: 1px solid black; color: #f0f0f0; background-color: #73ba98; padding: 5px; margin: 5px;", "border: 1px solid black; background-color: #d5677b; color: #f0f0f0; padding: 5px; margin: 5px;"),
        #district_name,
        selected_district[click_count()-1]
      )
    )
    
    # create the district name output
    output$district_name <- renderUI({
      div(# randomly select a district name
        selected_district[click_count()])
    })
    
  })
  
  # render the clicked district divs
  output$clicked_districts <- renderUI({
    divs <- lapply(clicked_districts, function(district_name) {
      tags$div(
        style = "border: 1px solid black; background-color: #f0f0f0; padding: 5px; margin: 5px;",
        district_name
      )
    })
    do.call(tagList, divs)
  })
  
  observeEvent(input$resetView, {
    leafletProxy("map") %>%
      fitBounds(80.6, 26.3, 88.2, 30.5)
  })
  
}

