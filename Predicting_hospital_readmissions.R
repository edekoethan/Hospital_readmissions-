library(readr)
library(dplyr)
library(ggplot2)

# Replace with your actual file path if needed
df_data <- read.csv("./my_projects/diabetic_data.csv", stringsAsFactors = FALSE)

# Replace "?" with NA
df_data[df_data == "?"] <- NA

# Check structure
dim(df_data)
head(df_data)
summary(df_data)

ggplot(df_data, aes(x = readmitted)) + 
  geom_bar(fill = "steelblue") +
  labs(title = "Distribution of Readmissions", 
       x = "Readmitted", 
       y = "Count")




 

