ui <- fluidPage(
  tags$head(
    tags$style("@import url(https://use.fontawesome.com/releases/v5.7.2/css/all.css);"),
    tags$script(
      src="https://kit.fontawesome.com/a076d05399.js", crossorigin="anonymous"
    )),
  
  titlePanel("Districts of Nepal", tags$span("How well do you know" )),
  div(
    tags$h3("This is an interactive map that asks you to click on different districts of Nepal.", tags$br(), "Let's see how well you know the districts of Nepal."),
    tags$p("The district name appers only after you click on a certain district. You can zoom and pan around the map.", tags$br(), "There is a button below map on the left side to reset the view.", tags$br(), "Have fun!")
  ),
  div(
    leafletOutput("map"),
    tags$div(
      style = "position: relative; top: 10px; left: 10px; z-index: 1000;",
      actionButton("resetView", "Reset View")
    )
  )
  ,
  
  fluidRow(column(
    width = 6,
    tags$h3(style = "text-decoration: underlined;", "Click on the following district"),
    uiOutput("district_name")
  ),
  column(
    width = 6,
    
    
    fluidRow(tags$br()),
    fluidRow(style = "text-align: right; padding-right: 10px;",
             tags$a(
               href = "https://www.linkedin.com/in/pratik-dhungana-452951228/",
               tags$i(class = "fab fa-linkedin", style = "font-size: 1.2em;"),
               "LinkedIn"
             ),
             tags$a(
               href = "https://github.com/pratik-tan10",
               tags$i(class = "fab fa-github", style = "font-size: 1.2em;"),
               "GitHub"
             ),
             tags$a(
               href = "https://pratik-tan10.github.io/",
               tags$i(class = "fas fa-globe", style = "font-size: 1.2em;"),
               "Personal Webpage"
             )
    )
    
  ))
  
  ,
  # add a div to display clicked districts
  div(id = "clicked_districts", style = "display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));")
)
