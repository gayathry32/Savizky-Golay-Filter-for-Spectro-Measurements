# Load necessary libraries
library(dplyr)
library(readxl)
library(openxlsx)
library(signal)
library(ggplot2)
library(pracma)
library(cowplot)

# Load data from Excel
df <- read_excel ("D:/agriculture/March work/Data/Cleaned_Bands_removed_data.xlsx")

# Define columns to clean, excluding 'Bands' if it's an identifier
columns_to_clean <- setdiff(names(df), "Bands")

# Function to apply Savitzky-Golay smoothing filter
apply_sg_filter <- function(data, polynomial_degree = 3, frame_length = 5) {
  sgolayfilt(data, polynomial_degree, frame_length)
}

# Function to compute the first derivative using Savitzky-Golay filter
compute_derivative <- function(data, polynomial_degree = 3, frame_length = 5) {
  coefs <- sgolay(polynomial_degree, frame_length)
  deriv_filter <- diff(coefs, differences = 1)  # Compute the first derivative filter
  
  # Apply filter to each data point individually
  filtered_data <- numeric(length(data))
  for (i in seq_along(data)) {
    start_index <- max(1, i - floor(length(deriv_filter) / 2))
    end_index <- min(length(data), i + floor(length(deriv_filter) / 2))
    filtered_data[i] <- sum(data[start_index:end_index] * rev(deriv_filter[1:(end_index - start_index + 1)]))
  }
  return(filtered_data)
}

# Apply smoothing filter and derivative computation
df_smoothed <- df
df_derivative <- df  # Initialize the derivative data frame

# Create a directory to save plots
plot_dir <- "plots_for_publication"
if (!file.exists(plot_dir)) dir.create(plot_dir)

# Initialize a list to store ggplot objects
plot_list <- list()

for (column in columns_to_clean) {
  non_na_indices <- which(!is.na(df[[column]]))
  
  # Apply smoothing
  df_smoothed[[column]][non_na_indices] <- apply_sg_filter(df[[column]][non_na_indices])
  
  # Compute and store derivative
  df_derivative[[column]][non_na_indices] <- compute_derivative(df[[column]][non_na_indices])
  
  # Plot original, smoothed, and derivative data
  data_to_plot <- data.frame(
    Bands = df$Bands[non_na_indices],
    Intensity = c(df[[column]][non_na_indices], df_smoothed[[column]][non_na_indices], df_derivative[[column]][non_na_indices]),
    Type = rep(c("Original", "Smoothed", "Derivative"), each = length(non_na_indices)),
    Column = rep(column, times = 3)
  )
  
  p <- ggplot(data_to_plot, aes(x = Bands, y = Intensity, color = Type)) +
    geom_line(size = 1.5) +
    labs(title = paste("Data Processing for", column),
         x = "Bands", y = "Intensity",
         color = "Type") +
    theme_minimal(base_size = 18) +
    theme(legend.title = element_text(size = 16),
          legend.text = element_text(size = 14),
          axis.title = element_text(size = 16),
          axis.text = element_text(size = 14),
          plot.title = element_text(size = 20, face = "bold"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank())
  
  # Add the plot to the list
  plot_list[[column]] <- p
  
  # Save plot to file
  plot_file <- paste0(plot_dir, "/", column, "_plot.png")
  ggsave(plot_file, plot = p, width = 10, height = 6, dpi = 300)
  
  cat("Plot saved:", plot_file, "\n")
}

# Combine plots into a single plot
combined_plot <- cowplot::plot_grid(plotlist = plot_list, nrow = 1)

# Save the combined plot to file
combined_plot_file <- paste0(plot_dir, "/combined_plot.png")
ggsave(combined_plot_file, plot = combined_plot, width = 12, height = 6, dpi = 300)

# Display summary of smoothed (and differentiated) data
print(summary(df_smoothed))

# Define the path to save the cleaned and processed data
output_directory <- "path_to_your_directory"
output_file_path <- file.path(output_directory, "processed_data.xlsx")

# Check if the directory exists, if not, create it
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# Save the processed data to an Excel file
write.xlsx(df_smoothed,output_file_path)

