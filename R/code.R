# -------------------------------
# Daily Energy Consumption Analysis
# -------------------------------

# Load required libraries
library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)

# 1. Load dataset
data <- read.csv("household_power_consumption.txt",
                 sep=";",
                 header=TRUE,
                 na.strings="?",
                 stringsAsFactors=FALSE)

# 2. Inspect dataset
cat("Dataset Structure:\n")
str(data)

cat("\nFirst 5 rows:\n")
print(head(data))

cat("\nDataset shape:", nrow(data), "rows,", ncol(data), "columns\n")

# 3. Data Cleaning
# Convert Date column
data$Date <- as.Date(data$Date, format="%d/%m/%Y")

# Convert Global_active_power to numeric
data$Global_active_power <- as.numeric(data$Global_active_power)

# Remove missing values
data <- na.omit(data)

cat("\nAfter cleaning, total rows:", nrow(data), "\n")
cat("Date range:", as.character(min(data$Date)), "to", as.character(max(data$Date)), "\n")

# 4. Daily Aggregation
daily_consumption <- aggregate(Global_active_power ~ Date,
                               data=data,
                               sum)

cat("\nDaily Consumption Summary:\n")
summary(daily_consumption$Global_active_power)

# 5. Basic Statistics
avg_consumption <- mean(daily_consumption$Global_active_power)
max_consumption <- max(daily_consumption$Global_active_power)
min_consumption <- min(daily_consumption$Global_active_power)

cat("\nAverage Daily Consumption:", round(avg_consumption, 2), "kW\n")
cat("Maximum Daily Consumption:", round(max_consumption, 2), "kW\n")
cat("Minimum Daily Consumption:", round(min_consumption, 2), "kW\n")

# 6. Peak Consumption Day
peak_day <- daily_consumption[which.max(daily_consumption$Global_active_power), ]
cat("\nPeak Consumption Day:\n")
cat("Date:", as.character(peak_day$Date), "\n")
cat("Consumption:", round(peak_day$Global_active_power, 2), "kW\n")

# 7. Top 5 Highest Consumption Days
top5 <- daily_consumption[order(-daily_consumption$Global_active_power), ][1:5, ]
cat("\nTop 5 Highest Consumption Days:\n")
for(i in 1:nrow(top5)) {
  cat("Rank", i, ":", as.character(top5[i,]$Date), "-", 
      round(top5[i,]$Global_active_power, 2), "kW\n")
}

# ---------------------------------------
# VISUALIZATION SECTION
# ---------------------------------------

# 8. Daily Trend (Line Chart)
cat("\n=== Creating Daily Trend Visualization ===\n")
plot(daily_consumption$Date,
     daily_consumption$Global_active_power,
     type="l",
     xlab="Date",
     ylab="Daily Energy Consumption (kW)",
     main="Daily Energy Consumption Trend",
     col="blue",
     lwd=1.5)

# Add Average Line
abline(h=avg_consumption, col="red", lwd=2, lty=2)

# Highlight Peak Day
points(peak_day$Date, peak_day$Global_active_power, 
       pch=19, col="red", cex=2)

# Add legend
legend("topright", 
       legend=c("Daily Consumption", 
                paste("Average (", round(avg_consumption, 2), " kW)"),
                "Peak Day"),
       col=c("blue", "red", "red"),
       lty=c(1, 2, NA),
       pch=c(NA, NA, 19),
       lwd=c(1.5, 2, NA))

# 9. Histogram (Distribution)
cat("\n=== Creating Distribution Histogram ===\n")
hist(daily_consumption$Global_active_power,
     main="Distribution of Daily Energy Consumption",
     xlab="Energy Consumption (kW)",
     ylab="Frequency",
     col="skyblue",
     border="black",
     breaks=30)

# Add mean line
abline(v=avg_consumption, col="red", lwd=2, lty=2)
legend("topright", 
       legend=paste("Mean:", round(avg_consumption, 2), "kW"),
       col="red", lty=2, lwd=2)

# 10. Boxplot (Outliers & Spread)
cat("\n=== Creating Boxplot ===\n")
boxplot(daily_consumption$Global_active_power,
        main="Boxplot of Daily Energy Consumption",
        ylab="Energy Consumption (kW)",
        col="lightblue",
        border="black")

# 11. Top 10 Highest Consumption Days
cat("\n=== Creating Top 10 Bar Chart ===\n")
top10 <- daily_consumption[order(-daily_consumption$Global_active_power), ][1:10,]

# Create labels for dates
date_labels <- format(top10$Date, "%m/%d")

barplot(top10$Global_active_power,
        names.arg = paste("#", 1:10, sep=""),
        las=1,
        main="Top 10 Highest Energy Consumption Days",
        ylab="Energy Consumption (kW)",
        xlab="Rank",
        col="orange",
        border="black")

# Add value labels on top of bars
text(x=seq(0.7, by=1.2, length.out=10),
     y=top10$Global_active_power + max(top10$Global_active_power)*0.02,
     labels=round(top10$Global_active_power, 1),
     pos=3, cex=0.8)

cat("\nTop 10 dates with highest consumption:\n")
for(i in 1:nrow(top10)) {
  cat("#", i, ":", as.character(top10[i,]$Date), "-", 
      round(top10[i,]$Global_active_power, 2), "kW\n")
}

# 12. Monthly Trend
cat("\n=== Creating Monthly Trend ===\n")
daily_consumption$Month <- format(daily_consumption$Date, "%Y-%m")

monthly_data <- aggregate(Global_active_power ~ Month,
                          data=daily_consumption,
                          sum)

plot(1:nrow(monthly_data),
     monthly_data$Global_active_power,
     type="l",
     xaxt="n",
     xlab="Month",
     ylab="Monthly Consumption (kW)",
     main="Monthly Energy Consumption Trend",
     col="green",
     lwd=2)

# Add points
points(1:nrow(monthly_data), monthly_data$Global_active_power, 
       pch=19, col="green", cex=1)

# Add x-axis labels (show every other month to avoid crowding)
axis(1,
     at=seq(1, nrow(monthly_data), by=2),
     labels=monthly_data$Month[seq(1, nrow(monthly_data), by=2)],
     las=2,
     cex.axis=0.8)

# Monthly statistics
cat("\nMonthly consumption statistics:\n")
cat("Highest monthly consumption:", round(max(monthly_data$Global_active_power), 2), "kW\n")
cat("Lowest monthly consumption:", round(min(monthly_data$Global_active_power), 2), "kW\n")
cat("Average monthly consumption:", round(mean(monthly_data$Global_active_power), 2), "kW\n")

# 13. Weekday Pattern
cat("\n=== Creating Weekday Pattern ===\n")
daily_consumption$Weekday <- weekdays(daily_consumption$Date)

# Define weekday order
weekday_order <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

# Calculate average consumption by weekday
weekday_data <- aggregate(Global_active_power ~ Weekday,
                          data=daily_consumption,
                          mean)

# Reorder to match weekday order
weekday_data$Weekday <- factor(weekday_data$Weekday, levels=weekday_order)
weekday_data <- weekday_data[order(weekday_data$Weekday), ]

barplot(weekday_data$Global_active_power,
        names.arg = weekday_data$Weekday,
        las=2,
        main="Average Energy Consumption by Weekday",
        ylab="Average Consumption (kW)",
        col="purple",
        border="black")

# Add value labels on top of bars
text(x=seq(0.7, by=1.2, length.out=7),
     y=weekday_data$Global_active_power + max(weekday_data$Global_active_power)*0.02,
     labels=round(weekday_data$Global_active_power, 1),
     pos=3, cex=0.8)

cat("\nAverage consumption by weekday:\n")
for(i in 1:nrow(weekday_data)) {
  cat(weekday_data[i,]$Weekday, ":", round(weekday_data[i,]$Global_active_power, 2), "kW\n")
}

# 14. Summary Statistics
cat("\n" , paste(rep("=", 50), collapse=""), "\n")
cat("ANALYSIS SUMMARY\n")
cat(paste(rep("=", 50), collapse=""), "\n")
cat("Total days analyzed:", nrow(daily_consumption), "\n")
cat("Date range:", as.character(min(daily_consumption$Date)), "to", 
    as.character(max(daily_consumption$Date)), "\n")
cat("Average daily consumption:", round(avg_consumption, 2), "kW\n")
cat("Peak consumption day:", as.character(peak_day$Date), 
    "(", round(peak_day$Global_active_power, 2), "kW )\n")
cat("Consumption range:", round(min_consumption, 2), "-", round(max_consumption, 2), "kW\n")

# Find highest and lowest consumption weekdays
highest_weekday <- weekday_data[which.max(weekday_data$Global_active_power), ]
lowest_weekday <- weekday_data[which.min(weekday_data$Global_active_power), ]

cat("Highest consumption weekday:", as.character(highest_weekday$Weekday), 
    "(", round(highest_weekday$Global_active_power, 2), "kW avg )\n")
cat("Lowest consumption weekday:", as.character(lowest_weekday$Weekday), 
    "(", round(lowest_weekday$Global_active_power, 2), "kW avg )\n")
cat(paste(rep("=", 50), collapse=""), "\n")

cat("\n*** Analysis Complete! ***\n")