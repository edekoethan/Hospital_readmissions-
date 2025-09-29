library(readr)
library(dplyr)
library(ggplot2)

library(haven)

# Replace with your actual file path if needed
df_data <- read.csv(".\C:\Users\USER\Documents\Hospital_readmissions-\diabetic_data.csv", stringsAsFactors = FALSE)

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


#Using ggplot, we would plot age group vs count

ggplot(df_data, aes(x = age)) + 
  geom_bar(fill = "darkgreen") +
  labs(title = "Patient Age Distribution", x = "Age Group", y = "Count")


ggplot(df_data, aes(x = gender, fill = readmitted)) +
  geom_bar(position = "dodge") +
  labs(title = "Readmissions by gender", x = "Gender", y = "Count")

df_data %>%
  group_by(readmitted) %>%
  summarise(avg_meds = mean(num_medications, na.rm = TRUE)) %>%
  ggplot(aes(x = readmitted, y = avg_meds, fill = readmitted)) +
  geom_col() +
  labs(title = "Average Medications by Readmission Status",
       x = "Readmission", y = "Average Medications")

#Data Cleaning and processing 
#Lets drop unnecessary columns 


#Backup the data
df_raw <- df_data
df <- df_raw 

# missing counts and percent
missing_counts <- colSums(is.na(df))
missing_perc <- missing_counts / nrow(df) * 100

missing_df <- data.frame(
  column = names(missing_counts),
  missing = as.integer(missing_counts),
  pct_missing = round(missing_perc, 2),
  stringsAsFactors = FALSE
)

library(dplyr)
missing_df %>% arrange(desc(pct_missing)) -> missing_df_sorted
print(missing_df_sorted)


threshold <- 50   # percent missing threshold
cols_to_drop <- missing_df_sorted$column[missing_df_sorted$pct_missing > threshold]

# show which columns would be dropped
cols_to_drop
length(cols_to_drop)

# drop them
if(length(cols_to_drop) > 0) {
  df <- df[, !(names(df) %in% cols_to_drop)]
}

# new dimension and a fresh missing summary
dim(df)
new_missing <- data.frame(
  column = names(colSums(is.na(df))),
  missing = as.integer(colSums(is.na(df))),
  pct_missing = round(colSums(is.na(df)) / nrow(df) * 100, 2),
  stringsAsFactors = FALSE
) %>% arrange(desc(pct_missing))

print(head(new_missing, 20))   # show top 20 remaining missing columns

#IDs don’t help prediction and can leak information. Remove encounter_id and patient_nbr

ids <- c("encounter_id", "patient_nbr")
ids_present <- intersect(ids, names(df))
ids_present

if(length(ids_present) > 0) {
  df <- df[, !(names(df) %in% ids_present)]
}

dim(df)   # confirm dimensions after dropping IDs

#duplicate check
sum(duplicated(df))
# if > 0, you can inspect a few duplicates:
which_dup <- which(duplicated(df) | duplicated(df, fromLast = TRUE))
head(which_dup, 20)  # indices of duplicated rows (if any)


table(df$readmitted, useNA = "ifany")
# create binary 0/1 (keep original column too)
df$readmit_30 <- ifelse(df$readmitted == "<30", 1, 0)
df$readmit_30 <- factor(df$readmit_30, levels = c(0,1))
table(df$readmit_30)

write.csv(df, "diabetic_clean_step1.csv", row.names = FALSE)




























