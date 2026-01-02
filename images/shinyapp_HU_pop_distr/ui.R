# UI definition
library(shiny)
library(plotly)

ui <- fluidPage(
  titlePanel(div(style="text-align: center;",
    "Magyarország lakosság-eloszlása településméret szerint")),
  fluidRow(
    # Left column for controls and comments
    column(3,
      # Controls panel
      div(
        class = "well",
        tabsetPanel(
        id="plotTabs",
        tabPanel("százalék",
          numericInput("min1", "min. település-méret:", value=0),
          numericInput("max1", "max. település-méret:", value=1000),
          h4("Az ország lakosainak/választóinak:"),
          uiOutput("results1")
        ),
        tabPanel("szám",
          numericInput("min2", "min. település-méret:", value = 0),
          numericInput("max2", "max. település-méret:", value = 1000),
          h4("Lakosok/választók száma:"),
          uiOutput("results2")
        )
      )
      ),
      # Comments below controls, same width
      div(
        style = "margin-top: 20px;",
        h4(""),
        p(HTML("[Megjegyzések: <br>
        1) Az 50 lakosnál kisebb települések nincsenek feltüntetve. Az ország kevesebb mint 0,1%-a él ekkora településeken.
        <br>
        2) Budapest nincsen adatpontként feltüntetve, de a százalék-számításnak része. BP-en lakik:<br>
          - 1.69 millió lakos (ország 17.6%-a)<br>
          - 1.21 millió választó (ország 16.2%-a)]"))
      )
    ),
    
    # Right column for plot
    column(9,
      plotlyOutput("selectedPlot", height = "780px")  # Made plot taller
    )
  )

)

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 