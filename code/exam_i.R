# BIOSTATS Exam – Data Manipulation in R (using mtcars dataset)

# tidyverse ---------------------------------------------------------------

# 1. Filter rows where number of cylinders (cyl) is 6
# Write code to create a new data frame that only includes rows where cyl == 6.
# Assign to: mtcars_cyl6

# 2. Filter rows where number of gears (gear) is either 3 or 5
# Use %in% to filter the mtcars dataset for these two gear values.
# Assign to: mtcars_gear_3_5

# 3. Filter rows where miles per gallon (mpg) is greater than 25
# Create a subset of mtcars where mpg > 25.
# Assign to: mtcars_mpg_gt25

# 4. Filter rows where weight (wt) is less than 2.5 and number of cylinders is 4
# Combine logical conditions using &.
# Assign to: mtcars_light_cyl4

# 5. Sort mtcars by horsepower (hp) in ascending order
# Use arrange() to sort the data.
# Assign to: mtcars_sorted_hp

# 6. Sort mtcars by quarter mile time (qsec) in descending order
# Use desc() inside arrange().
# Assign to: mtcars_sorted_qsec_desc

# 7. Select only mpg and cyl columns
# Use select() to retain only the two columns.
# Assign to: mtcars_mpg_cyl

# 8. Exclude the drat column
# Use select() with - to remove the column.
# Assign to: mtcars_no_drat

# 9. Select columns that start with "d"
# Use starts_with() inside select().
# Assign to: mtcars_d_columns

# 10. Add a new column power_to_weight = hp / wt
# Use mutate() to add the new column.
# Assign to: mtcars_with_ptw

# 11. Filter for cars with 4 cylinders and select mpg (use piping)
# Chain filter() and select() using %>%.
# Assign to: mtcars_cyl4_mpg

# 12. Group by number of gears and summarize mean mpg
# Use group_by() and summarize() to calculate mean mpg.
# Assign to: mtcars_mean_mpg_by_gear

# 13. Add column mean_hp showing group mean of hp by gear, then ungroup
# Use mutate() after group_by(), then ungroup().
# Assign to: mtcars_with_mean_hp

# 14. Reshape mtcars to wide format with an id column and mpg for each gear
# Add id using mutate(row_number()) and use pivot_wider().
# Assign to: mtcars_wide

# 15. Reshape mtcars_wide back to long format with gear and mpg columns
# Use pivot_longer() to convert back to long format.
# Assign to: mtcars_long

# ggplot ------------------------------------------------------------------

# Visualization in R (using iris dataset)

# 1. Simple scatter plot of Sepal.Length vs Sepal.Width using ggplot()
# Assign to: plot_scatter
# Write code to create a basic scatter plot with Sepal.Length on the y-axis and Sepal.Width on the x-axis.

# 2. Scatter plot colored by Species
# Assign to: plot_scatter_color
# Write code to create a scatter plot with points colored by Species.

# 3. Histogram of Sepal.Width with binwidth = 0.5
# Assign to: plot_histogram_binwidth
# Write code to plot a histogram with binwidth set to 0.5.

# Visualization in R (using PlantGrowth dataset)
  
# 4. Boxplot of weight grouped by group
# Assign to: plot_pg_boxplot_basic
# Write code to draw a boxplot of weight across different treatment groups in PlantGrowth.

# 5. Boxplot of weight grouped by group, filled by group
# Assign to: plot_pg_boxplot_fill
# Write code to draw a boxplot of weight grouped by group and filled by group.