library(shiny)
library(leaflet)
library(plotly)

library(tidyverse)

# Read data from url
url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"

df <- read.csv(url)
bounds = c(min(df$Lat, na.rm = TRUE), min(df$Long, na.rm = TRUE), max(df$Lat, na.rm = TRUE), max(df$Long, na.rm = TRUE))

# conver from wid to long format
location_cols <- c("Province.State", "Country.Region", "Lat", "Long")
# gather the daily cases into a "Date" and "Cases" column
covid_data_tidy <- df %>%
  gather(Date, Cases, -one_of(location_cols), na.rm = TRUE) %>%
  mutate(Date = as.Date(sub("X", "", Date), format = "%m.%d.%y"))

# show the first few rows of the tidy data
head(covid_data_tidy)

# function to filter data by country
get_cases_by_country <- function(covid_data_tidy, country) {
  covid_data_tidy%>%
    filter(Country.Region == country) %>%
    select(Confirmed) %>%
    unlist()
}


# Define tile layer URL
jawg_url <- "https://{s}.tile.jawg.io/jawg-dark/{z}/{x}/{y}{r}.png?access-token={accessToken}"

# Define tile layer options
jawg_options <- leaflet::tileOptions(
  accessToken = "AlCigPp4YaN2JUsefJWRXct7SjzkS1yyY1KfR8h62oKf3VDJycPgPbIigjGrgdC7"
)

server <- function(input, output, session) {
  # Create table of all the states/provinces related to each country
  country_state = df%>%select(Country.Region, Province.State)
  
  # Change the regions options whenever user selects a particular country
  observeEvent(input$country, {
    # Filter the regions for particular country
    regions <- unique(subset(country_state, Country.Region == input$country)$Province.State)
    updateSelectInput(session, "region", choices = ifelse(regions == "", c(""), regions))
  })
  
  df1 <- reactive({
    covid_data_tidy%>%filter(Date == input$date[1])
  })
  
  df2 <- reactive({
    covid_data_tidy%>%filter(Date == input$date[2])
  })
  
  dynamic_map_data <- reactive({
    
    #filtered_data <- covid_data_tidy%>%
    #filter(Date >= input$date[1] & Date <= input$date[2])%>%
    #group_by(Country.Region, Province.State, Lat, Long)%>%
    #summarize(Cases = sum(Cases))
    
    filtered_data <- merge(x = df1(), y = df2(), by = c("Country.Region", "Province.State"), all = TRUE, suffixes = c("", "_new"))%>%
      select(Country.Region, Province.State, Lat, Long, Cases, Cases_new)%>%
      mutate(Cases = Cases_new - Cases)%>%
      select(-Cases_new)
    
    filtered_data$circle_size = filtered_data$Cases/max(filtered_data$Cases + 1)* 7
    
    
    return(filtered_data%>%mutate(labels = paste0(Country.Region, ifelse(Province.State=="", "","-"),Province.State, ": ")))
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
        label = ~paste0(labels , format(Cases, big.mark = ","))
      )
  })
  
  
  filter_country <- reactive({
    covid_data_tidy%>%
      filter(Country.Region == input$country, Date <= as.Date("2021-08-04"))%>%
      filter(Province.State == input$region | Province.State == '')%>%
      mutate(Cases = round(Cases/1000))
  })
  
  # Render the timeseries plot
  output$timeseries <- renderPlotly({
    plot_ly(filter_country(), x = ~Date, y = ~Cases/1000, type = "scatter", mode = "lines")%>%
      layout(title = paste0("Covid Cases for ", input$country, ifelse(filter_country()[1, "Province.State"] == "", "",paste0(",", input$region))),
             xaxis = list(title = "Date"),
             yaxis = list(title = "Counts (in thousands)", tickformat = ",.0"))
  })
}

shinyApp(ui, server)
