# Savizky-Golay-Filter-for-Spectro-Measurements
The Savitzky-Golay technique is a smoothing filter commonly used in signal processing to enhance the quality of noisy data. In your R script, it is used for:

-Smoothing Spectral Data: It applies the Savitzky-Golay filter to clean noisy data.
-Computing the First Derivative: This helps analyze trends and variations in spectral intensity.
-Generating Visualizations: The script creates plots for original, smoothed, and derivative data using ggplot2.
-Saving Processed Data: It saves the cleaned dataset in an Excel file
# Key Functions in Your Code
1 apply_sg_filter(data, polynomial_degree = 3, frame_length = 5)
-Uses sgolayfilt() to apply the Savitzky-Golay filter for smoothing.

2 compute_derivative(data, polynomial_degree = 3, frame_length = 5)
-Computes the first derivative using Savitzky-Golay coefficients.
# Looping Over Spectral Data
-The script applies filtering and derivative computation to all columns except "Bands" (assumed to be the identifier).
-It generates individual plots for each column and saves them as PNG files.
# Plotting and Saving
-The script creates a directory to save plots.
-It combines all plots into a single visualization.

# Saving Processed Data
-The final smoothed dataset is saved as processed_data.xlsx.
