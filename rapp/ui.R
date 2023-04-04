#library(shiny)
library(leaflet)
library(plotly)


ui <- fluidPage(
  tags$head(
    tags$style("@import url(https://use.fontawesome.com/releases/v5.7.2/css/all.css);"),
    
    tags$script(
      src="https://kit.fontawesome.com/a076d05399.js", crossorigin="anonymous"
    ),
    tags$style("label { font-size: 1.3em; }")
  ),
  
  class = "no-gutters",
  titlePanel("Covid Cases Throughout The World"),
  
  fluidRow(
    class = "no-gutters",
    column(
      width = 8,
      
      tags$div(
        style = "height: 20%; background-color: #f0f0f0; border-radius: 5px; padding: 10px;",
        h2(textOutput("total_cases"),
           style = "color: #C4292B; font-size: 48px; margin: 0px; padding: 0px;"),
        
        h3(style = "color: #7B7070; font-size: 24px; margin: 0px; padding: 0px;",
           "Total New Cases from"),
        tags$span(style = "color:#088129; display: inline;",
                  textOutput("start_date")
        ),
        tags$span(style = "display: inline;", "to"),
        tags$span(style = "color:#810860; display: inline;",
                  textOutput("end_date")
        )
      ),
      div(style= "border-radius: 5px;",
          id = "map-container",
          class = "panel panel-default",
          leafletOutput("map", width = "100%")
      ),
      
      fluidRow(
        column(
          width = 12,
          plotlyOutput("timeseries", height = "400px")
        )
      )
    ),
    
    column(
      width = 4,
      div(
        id = "date-control",
        class = "panel panel-default",
        fluidRow(
          column(
            width = 12,
            sliderInput(
              inputId = "date",
              label = "Select a date range",
              min = as.Date("2020-01-26"),
              max = as.Date("2021-08-03"),
              value = c(as.Date("2020-03-01"), as.Date("2020-08-01")),
              timeFormat = "%b %d, %Y", 
              ticks = FALSE
            )
          )
        )
      ),
      
      div(
        width = 10,
        style = "background-color:lightblue; text-align:center;",
        div(style = "height: 33%; border: 5px outset whitesmoke; background-color:lightblue; text-align:center; padding: 20px; text-decoration: none; font-size: 1.2em;",
            tags$a(href = "https://www.linkedin.com/in/pratik-dhungana-452951228/", tags$i(class = "fab fa-linkedin", style = "font-size: 2em;"), "LinkedIn")
        ),
        div(style = "height: 33%; border: 5px outset whitesmoke; background-color:lightblue; text-align:center; padding: 20px; text-decoration: none; font-size: 1.2em;",
            tags$a(href = "https://github.com/pratik-tan10", tags$i(class = "fab fa-github", style = "font-size: 2em;"), "GitHub")
        ),
        div(style = "height: 33%; border: 5px outset whitesmoke; background-color:lightblue; text-align:center; padding: 20px; text-decoration: none; font-size: 1.2em;",
            tags$a(href = "https://pratik-tan10.github.io/", tags$i(class = "fas fa-globe", style = "font-size: 2em;"), "Personal Website")
        )
        
      ),
      
      div(
        id = "controls",
        class = "panel panel-default",
        fluidRow(
          column(
            width = 12,
            selectInput(
              inputId = "country",
              label = "Select a Country",
              choices = country_state$Country.Region,
              selected = "USA"
            ),
            selectInput(
              inputId = "region",
              label = "Select Region",
              choices = NULL)
          )
        )
      ),
      
      fluidRow(
        column(
          width = 12,
          h4("Data source"),
          p("The data used here is obtained from COVID-19 Data Repository by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University."),
          p("It is available in their",
            tags$a(style="text-decoration:none; display: inline;",
                   href = "https://github.com/CSSEGISandData/COVID-19",
                   "GitHub"),
            "Repository")
        )
      )
    )
  )
)
