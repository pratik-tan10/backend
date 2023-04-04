#library(shiny)
library(leaflet)
library(plotly)

# Define tile layer URL
jawg_url <- "https://{s}.tile.jawg.io/jawg-dark/{z}/{x}/{y}{r}.png?access-token={accessToken}"

# Define tile layer options
jawg_options <- leaflet::tileOptions(
  accessToken = "AlCigPp4YaN2JUsefJWRXct7SjzkS1yyY1KfR8h62oKf3VDJycPgPbIigjGrgdC7"
)

server <- function(input, output, session) {
  # Create table of all the states/provinces related to each country
  #country_state = df%>%select(Country.Region, Province.State)
  
  # Change the regions options whenever user selects a particular country
  observeEvent(input$country, {
    # Filter the regions for particular country
    regions <- unique(subset(country_state, Country.Region == input$country)$Province.State)
    updateSelectInput(session, "region", choices = ifelse(regions == "", c(""), regions))
  })
  
  df1 <- reactive({
    covid_data_tidy[covid_data_tidy$Date == input$date[1],]
  })
  
  df2 <- reactive({
    covid_data_tidy[covid_data_tidy$Date == input$date[2],]
  })
  
  dynamic_map_data <- reactive({
    
    filtered_data <- merge(x = df1(), y = df2(), by = c("Country.Region", "Province.State"), all = TRUE, suffixes = c("", "_new"))
    filtered_data <- subset(filtered_data, select = c("Country.Region", "Province.State", "Lat", "Long", "Cases", "Cases_new", "labels"))
    filtered_data$Cases <- filtered_data$Cases_new - filtered_data$Cases
    filtered_data <- subset(filtered_data, select = - Cases_new)
    
    filtered_data$circle_size = (filtered_data$Cases/max(filtered_data$Cases + 1)* 8 + 3)
    
    
    return(filtered_data)
  })
  
  
  
  # Render the Total cases and start and end dates
  output$total_cases <- renderText({
    format(sum(dynamic_map_data()$Cases, na.rm = TRUE), big.mark = ",")
  })
  
  date_bounds <- reactive({
    return(c(input$date[1], input$date[2]))
  })
  
  output$start_date <- renderText({
    format(date_bounds()[1], "%Y-%m-%d")
  })
  
  output$end_date <- renderText({
    format(date_bounds()[2], "%Y-%m-%d")
  })
  
  
  output$map <- renderLeaflet({
    # Create the leaflet map
    leaflet(data = dynamic_map_data()) %>%
      addTiles(urlTemplate = jawg_url, options = jawg_options) %>%
      addCircleMarkers(
        lat = ~Lat,
        lng = ~Long,
        radius = ~circle_size,
        color = "red",
        fillOpacity = 0.7,
        stroke = FALSE,
        label = ~paste0(labels ," ", format(Cases, big.mark = ","))
      )
  })
  
  
  filter_country <- reactive({
    covid_data_tidy%>%
      filter(Country.Region == input$country)%>%
      filter((Province.State == input$region) | (Province.State == ''))%>%
      mutate(Cases = round(Cases/1000))
  })
  
  # Render the timeseries plot
  output$timeseries <- renderPlotly({
    plot_ly(filter_country(), x = ~Date, y = ~Cases/1000, type = "scatter", mode = "lines")%>%
      layout(title = paste0("Covid Cases for ", input$country, ifelse(filter_country()[1, "Province.State"] == "", "",paste0(", ", input$region))),
             xaxis = list(title = "Date"),
             yaxis = list(title = "Counts (in thousands)", tickformat = ",.0"))
  })
}
