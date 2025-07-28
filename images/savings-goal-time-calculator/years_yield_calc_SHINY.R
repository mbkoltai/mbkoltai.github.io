library(shiny); library(tidyverse); library(plotly)
fcn_every_nth <- function(x, n) x[seq(1, length(x), by = n)]

# Static vectors for r and y
shiny_model <- list()
shiny_model$r_values <- seq.default(0.02,0.12,by = 0.005)
shiny_model$y_values <- seq(10e3, 50e3, length.out = 25)

# UI inside the list
shiny_model$ui <- fluidPage(
  titlePanel("How many years to reach a wealth goal of..."),
  tags$head(tags$style(HTML("
  .js-irs-0 .irs-single,   /* slider value */
  .js-irs-0 .irs-bar, 
  .js-irs-0 .irs-from, 
  .js-irs-0 .irs-to {
    font-size: 12px !important;
  }
  .control-label {  /* slider label */
    font-size: 16px;
    font-weight: bold;
  }
"))),
  sidebarLayout(
    sidebarPanel(
  sliderInput("constant", "Target wealth ($):",
              min = 5e5, max = 3e6, value = 1e6, step = 1e5, pre = "$"),
  br(),
  helpText("This app shows how many years it takes to reach target wealth,"),
  helpText("depending on yearly savings and investment return."),
  br(),
  helpText("The calculation is based on:"),
  HTML("<code>n = log(target / (y / r) + 1, base = 1 + r)</code>"),
  br(),
  helpText("where:"),
  helpText("n = number of years required to hit target"),
  helpText("y = annual saving"),
  helpText("r = annual rate of return")
),
    mainPanel(
      # plotOutput("heatmapPlot", height = "600px")
      plotlyOutput("heatmapPlot", height = "600px")
    )
  )
)

# Server inside the list
shiny_model$server <- function(input, output, session) {
  # reactive grid calculation based on input$constant
  reactive_grid <- reactive({
    expand.grid(r = shiny_model$r_values, y = shiny_model$y_values) %>%
      mutate(n = log((input$constant / (y / r)) + 1, base = 1 + r))
  })

  # reactive labels filtering
  reactive_labels <- reactive({
    grid <- reactive_grid()
    r_labels <- fcn_every_nth(shiny_model$r_values, 2)
    grid %>% filter(r %in% r_labels, y %% 1000 == 0)
  })

  output$heatmapPlot <- renderPlotly({
  grid <- reactive_grid()
  labels <- reactive_labels()

  p <- ggplot(grid, aes(x = r * 100, y = y / 1e3, fill = n, text = paste0("Years: ", round(n, 1)))) +
    geom_tile(color = "red", linewidth=0.1) +
    geom_text(data=labels,aes(label=round(n, 1)),color="white",size=4) +
    scale_x_continuous(breaks=2:12) + scale_y_continuous(breaks=(2:10)*5) +
    coord_cartesian(expand=F) +
    labs(x="annual return (%)",y="yearly savings (thousand $)",fill="years") +
    theme_bw() +
    theme(axis.title = element_text(size =18),
      axis.text = element_text(size = 14),
      plot.margin = margin(t = 5, r = 5,b=30,l=5),
      legend.title = element_text(size=16),
      legend.text = element_text(size=12) )

  ggplotly(p, tooltip = "text")
})
}

# Run the app with UI and server from shiny_model list
shinyApp(ui=shiny_model$ui, server=shiny_model$server)

### ### ### ### ### ### ### ### ### ### ### ### 
### ### ### ### ### ### ### ### ### ### ### ### 
# library(rsconnect)

  # output$heatmapPlot <- renderPlot({
  #   grid <- reactive_grid()
  #   labels <- reactive_labels()
  # 
  #   ggplot(grid, aes(x = r * 100, y = y / 1e3, fill = n)) +
  #     geom_tile(color = "white", linewidth = 0.3) +
  #     geom_text(data=labels,aes(label=round(n, 1)),color="white",size=4.5) +
  #     labs(x = "annual return (%)", y = "yearly savings (thousand $)",fill="years") +
  #     # ggtitle(paste0("years needed to reach $", input$constant)) +
  #     scale_x_continuous(breaks=2:12) + scale_y_continuous(breaks = (2:10)*5) +
  #     coord_cartesian(expand = FALSE) +
  #     theme_bw() +
  #     theme(
  #     axis.title = element_text(size = 22),          # bigger axis labels
  #     axis.text = element_text(size = 16),           # bigger tick labels
  #     plot.margin = margin(t=5, r=5, b=30, l=5),  # more padding below (bottom = 20)
  #     plot.title = element_text(hjust=0.5,size=30),
  #     legend.title=element_text(size=18),legend.text=element_text(size=14) )
  # })
  