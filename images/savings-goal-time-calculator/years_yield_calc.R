# yield calc plot

# Load required libraries
library(tidyverse)
fcn_every_nth <- function(x, n) x[seq(1, length(x), by = n)]

# Define everything inside a list
model <- list( constant = 1e6,
  r_values = seq(0.02, 0.12, length.out = 25),
  y_values = seq(10e3, 50e3, length.out = 25) )

# Create grid and compute n
model$grid <- expand.grid(r = model$r_values, y = model$y_values) %>%
  mutate(n = log((model$constant / (y / r)) + 1, base = 1 + r))
model$labels <- model$grid %>%
  filter(r %in% fcn_every_nth(unique(model$r_values),n=3), 
         y %% 1000 == 0)

# Generate heatmap
ggplot(model$grid, aes(x=r*100, y=y/1e3, fill = n)) +
  geom_tile(color = "white", linewidth = 0.3) +  # Adds grid lines between tiles
  geom_text(data = model$labels, 
    aes(label = round(n, 1)), color = "white", size = 4) +  # Overlay n values
  # scale_fill_viridis_c(name = "n", option = "plasma") +
  labs(x = "annual return (%)",y = "yearly savings (thousand $)") +
  ggtitle(paste0("years needed to reach $",model$constant)) +
  scale_x_continuous(breaks=(1:6)*2) +
  coord_cartesian(expand=F) +  # key to remove axis padding
  theme_bw() + # theme_minimal(base_size = 12) +
  theme(panel.grid.major = element_line(color = "grey90", size = 0.2),
    panel.grid.minor = element_blank(),
    plot.margin=margin(5,5,5,5),
    plot.title = element_text(hjust=0.5,size = 15)
    )

# turn into shiny plot
library(shiny)