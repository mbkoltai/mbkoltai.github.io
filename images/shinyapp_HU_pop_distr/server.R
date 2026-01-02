### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
# Server logic
library(shiny)
library(plotly)
library(tidyverse)

server <- function(input, output, session) {
  
  # Function to calculate area between two x values for a cumulative distribution
  calc_area <- function(trace_data, min_val, max_val) {
    # Extract x and y values from the plotly trace
    x_vals <- 10^trace_data$x
    y_vals <- trace_data$y
    
    # Find indices for the bounds
    min_idx <- which(x_vals >= min_val)[1]
    max_idx <- tail(which(x_vals <= max_val), 1)
    
    if (is.na(min_idx) || is.na(max_idx)) {
      return(NA)
    }
    
    # Get y values at bounds
    y_at_max <- y_vals[max_idx]
    y_at_min <- y_vals[min_idx]
    
    # Calculate difference
    area <- y_at_max - y_at_min
    return(round(area, 2))  # Convert to percentage
  }
  
  ### ### ### ### ### ### 
l_telep_meret <- readRDS(file = "l_telep_meret.RDS")
l_telep_meret$sel_pop_sizes=c(50,l_telep_meret$sel_pop_sizes)

#
# GGPLOT SETTINGS
standard_plot_theme <- theme(plot.title=element_text(hjust=0.5,size=21),
                  axis.title.x=element_text(size=18),axis.title.y=element_text(size=18),
                  axis.text.x=element_text(size=16,angle=90,vjust=0.5),axis.text.y=element_text(size=16),
                  plot.caption=element_text(size=12),plot.caption.position="plot",
                  strip.text=element_text(size=18),legend.title =element_text(size=20),
                  panel.grid.major.y=element_blank(), 
                  legend.text=element_text(size=15))
# PLOT cumul distrib
p_l_telep_meret_cumul_pop <- lapply(1:2, function(k_plot)
l_telep_meret$df_cumul_pop %>% # lakonep
  filter(pop_ertek>=min(l_telep_meret$sel_pop_sizes) & 
           !grepl("Budap",telep_nev) & 
           grepl(c("teljes","szám")[k_plot],valt_tipus) ) %>%
  mutate(value=value*ifelse(grepl("teljes",valt_tipus),100,1) ) %>%
ggplot(aes(x=pop_ertek,y=value,group=pop_tipus,color=pop_tipus,
           text=paste0(telep_nev," | településméret: ", pop_ertek, " | ",
                       ifelse(grepl("teljes",valt_tipus),round(value,1),round(value/1e3,1)), 
                       ifelse(grepl("teljes",valt_tipus),"% (él ennél kisebb településen)",
                              " ezer lakos (él ennél kisebb településen)") ))) + 
  geom_point(shape=21,alpha=2/3,size=2) + # geom_line() +
  # geom_text(label="lakok",color="red") +
  # geom_text(label="lakok",color="red"), 
  scale_size_continuous(range=c(0.1,3)) + # Controls the min and max size
  scale_x_log10(breaks=l_telep_meret$sel_pop_sizes,expand=expansion(mult=c(0.01))) + 
  scale_y_continuous(limits=c(0,NA),expand=expansion(mult=c(0.03)),
            breaks=l_telep_meret$y_breaks[[c("perc","abs_num")[k_plot]]]) + 
  xlab("településméret (lakosok/választók száma)") + 
  ylab(paste0(c("%","")[k_plot]," lakos/választó ennél kisebb településen")) +
  labs(color="") +
  theme_bw() + standard_plot_theme + 
  theme(legend.position="top") # plot.title=element_text(size=15) 
)

# create plotly files
plotly_list <- lapply(1:2, function(x) ggplotly(p_l_telep_meret_cumul_pop[[x]],tooltip="text") %>% 
    layout( legend = list(
      x = 0,      # Set x position (0 is left)
      y = 1,      # Set y position (1 is top)
      xanchor = 'left',  # Anchor the x position to the left
      yanchor = 'top'    # Anchor the y position to the top
    ) ) )

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 

  
  
  
  # Reactive expression for selected plot
  output$selectedPlot <- renderPlotly({
    if (input$plotTabs == "százalék") {
      plotly_list[[1]]
    } else {
      plotly_list[[2]]
    }
  })
  
  # Generate results for Plot 1
  output$results1 <- renderUI({
    # Calculate areas for both traces in plot 1
    areas <- lapply(seq_along(plotly_list[[1]]$x$data), function(i) {
      trace <- plotly_list[[1]]$x$data[[i]]
      area <- calc_area(trace, input$min1, input$max1)
      pop_type <- trace$name  # Get population type from trace name
      
      if (!is.na(area)) {
        div(
          style = "margin-bottom: 10px;",
          tags$b(pop_type,":"),
          paste0(" ", area, "%-a (ilyen méretű településen él)")
        )
      } else {
        div(
          style = "margin-bottom: 10px;",
          tags$b(pop_type, ":"),
          " Invalid bounds selected"
        )
      }
    })
    
    # Return all results
    div(areas)
  })
  
  # Generate results for Plot 2
  output$results2 <- renderUI({
    # Calculate areas for both traces in plot 2
    areas <- lapply(seq_along(plotly_list[[2]]$x$data), function(i) {
      trace <- plotly_list[[2]]$x$data[[i]]
      area <- calc_area(trace, input$min2, input$max2)
      pop_type <- trace$name  # Get population type from trace name
      
      if (!is.na(area)) {
        div(
          style = "margin-bottom: 10px;",
          tags$b(pop_type,":"),
          paste0(" ", round(area/1e3,1), " ezer (ilyen méretű településen él)")
        )
      } else {
        div(
          style = "margin-bottom: 10px;",
          tags$b(pop_type, ":"),
          " Invalid bounds selected"
        )
      }
    })
    
    # Return all results
    div(areas)
  })
}

