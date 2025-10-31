# app.R
library(shiny)
library(plotly)
library(tidyverse)
library(WDI)

#   WDI(country = c("PL","CZ","HU","SK","RO","BG","SI","HR","LT","EE","LV"),
#             indicator = c(gdp_pc_ppp="NY.GDP.PCAP.PP.KD",
#                           gdp_pc_const2015="NY.GDP.PCAP.KD",
#                           gni_pc_ppp="NY.GNP.PCAP.PP.KD"),
#             start = 1990, end = 2024)
# 
# write_csv(data,file = "wdi_data.csv")


wdi_data <- read_csv("wdi_data.csv")

# ---- UI ----
ui <- fluidPage(
  
  tags$style(HTML("html, body {height:95%;}
  .container-fluid {height:95%;}
  .row {height:100%;}
  .col-sm-9, .col-sm-3 {height:95%;} /* mainPanel/sidebarPanel */")),
  
  titlePanel("CEE Countries: 1990 vs 2024 (GDP or GNI per capita, 2015/2021 constant USD + PPP)"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("indicator", "Select indicator:",
                  choices = c("GDP per capita (PPP)" = "gdp_pc_ppp",
                              "GDP per capita (constant 2015 usd)" = "gdp_pc_const2015",
                              "GNI per capita (PPP)" = "gni_pc_ppp")),
      helpText("Each point shows one country — 1990 value on X, 2024 value on Y.")
    ),
    
    mainPanel( plotlyOutput("plot", height = "85vh"),
      br(), p("Data: World Bank WDI")   )
    
  )
)

# ---- Server ----
server <- function(input, output, session) {
  output$plot <- renderPlotly({
    # Filter for the two years of interest
      start_year <- if (input$indicator == "gni_pc_ppp") {1996} else {1990}
      end_year <- 2024
    x_col <- paste0("y", start_year)
    y_col <- paste0("y", end_year)

    # create df
    df_wide <- wdi_data %>%
        select(iso2c, year, value = all_of(input$indicator)) %>%
        filter(year %in% c(start_year, end_year)) %>%
        pivot_wider(names_from = year, values_from = value, names_prefix = "y") %>%
        drop_na()

    
max_val <- max(df_wide[[x_col]],na.rm = TRUE) # , df_wide[[y_col]], 

# Scatter plot
p <- plot_ly(df_wide,
             x = df_wide[[x_col]], y = df_wide[[y_col]],
             type = "scatter", mode = "markers+text",
             text = ~iso2c,
             hoverinfo = "text",
             textposition = "top center",
             hovertext = ~paste0(iso2c,
               "<br>", start_year, ": ", round(df_wide[[x_col]], 0),
               "<br>", end_year, ": ", round(df_wide[[y_col]], 0),
               "<br>Growth ×", round(df_wide[[y_col]] / df_wide[[x_col]], 1)),
             marker = list(size=13)
)

# 1× reference line
p <- add_lines(
  p,
  x = c(0, max_val),
  y = c(0, max_val),
  line = list(dash = "dot", color = "gray"),
  hoverinfo = "text",
  text = "no growth",
  showlegend = FALSE,
  inherit = FALSE
)


# 2× growth line
p <- add_lines(
  p,
  x = c(0, max_val),
  y = c(0, 2*max_val),
  line = list(dash = "dot", color = "lightblue"),
  hoverinfo = "text",
  text = "2× growth",
  showlegend = F,
  inherit = F)

# 3× growth line
p <- add_lines(
  p,
  x = c(0, max_val),
  y = c(0, 3*max_val),
  line = list(dash = "dot", color = "lightgreen"),
  hoverinfo = "text",
  text = "3× growth",
  showlegend = F,
  inherit = F)

    p
  })
}

# ---- Run the app ----
shinyApp(ui, server)
