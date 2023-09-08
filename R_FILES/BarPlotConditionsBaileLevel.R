# Different plots for Paper 1. 
library(dplyr)
library(stringr)

# 1. Unerstanding the distribution of the data 
data_lag <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Aug_2023/23082023_ELAN_no_CDRS_onset_dt_LZ_sync.csv')
df <- data_lag %>% distinct(Name,Participant,number, .keep_all = TRUE)
df_filtered <- df %>%
  filter(str_trim(Baile_Level) != "")

df_filtered <- df %>%
  filter(!grepl("[^[:alnum:]]", Baile_Level) | Baile_Level == "")



# Calculate the total rounds for each name
df_filtered <- df_filtered %>%
  group_by(Name) %>%
  mutate(total_duration = sum(Duration))

# Calculate the percentage of dance step for each row
df_filtered <- df_filtered %>%
  mutate(percentage_duration = (Duration / total_duration) * 100)

# View the updated dataset
head(df_filtered$percentage_duration)



df_filtered <- df_filtered %>%
  group_by(Name, Baile_Level) %>%
  mutate(sum_category = sum(percentage_duration)) %>%
  ungroup()




# Group by condition and dance level, and calculate the average percentage
average_per_condition <- df_filtered %>%
  group_by(Condition, Baile_Level) %>%
  summarize(avg_percentage = mean(sum_category, na.rm = TRUE))


average_per_condition <- df_filtered %>%
  group_by(Condition, Baile_Level) %>%
  summarize(
    avg_percentage = mean(sum_category, na.rm = TRUE),
    se_percentage = sd(sum_category) / sqrt(n())
  )

ggplot(average_per_condition, aes(x = Condition, y = avg_percentage, fill = Baile_Level)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Condition", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Condition and Baile_Level") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top



# Create an empty data frame to store t-test results
t_test_results <- data.frame()

# Loop through pairs of conditions and perform t-tests
condition_pairs <- combn(unique(df_filtered$sum_category), 2, simplify = FALSE)
for (pair in condition_pairs) {
  condition1 <- pair[1]
  condition2 <- pair[2]
  
  # Subset the data for the two conditions
  data_condition1 <- sum_category %>%
    filter(Condition == condition1)
  data_condition2 <- sum_category %>%
    filter(Condition == condition2)
  
  # Perform t-test
  t_test_result <- t.test(data_condition1$sum_category, data_condition2$sum_category)
  
  # Store the results in the data frame
  result_row <- data.frame(
    Condition1 = condition1,
    Condition2 = condition2,
    p_value = t_test_result$p.value,
    significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
  )
  
  t_test_results <- bind_rows(t_test_results, result_row)
}

# View the t-test results
print(t_test_results)
t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
                                ifelse(t_test_results$p_value < 0.01, "**",
                                       ifelse(t_test_results$p_value < 0.05, "*", "")))

print(t_test_results)
#########

### Reverse

# Create a barplot with average and standard error
ggplot(average_per_condition, aes(x = Baile_Level, y = avg_percentage, fill = Condition)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Baile_Level", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Baile_Level and Condition") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top

# Create an empty data frame to store t-test results
t_test_results <- data.frame()

# Loop through unique Baile_Levels
unique_baile_levels <- unique(df_filtered$Baile_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- df_filtered %>%
    filter(Baile_Level == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Condition), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Condition == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Condition == condition2)
    
    # Perform t-test
    t_test_result <- t.test(data_condition1$sum_category, data_condition2$sum_category)
    
    # Store the results in the data frame
    result_row <- data.frame(
      Baile_Level = baile_level,
      Condition1 = condition1,
      Condition2 = condition2,
      p_value = t_test_result$p.value,
      significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
    )
    
    t_test_results <- bind_rows(t_test_results, result_row)
  }
}

# View the t-test results
print(t_test_results)


# View the resulting table
average_per_condition
average_per_condition <- average_per_condition %>%
  filter(Baile_Level != "")

ggplot(df_filtered, aes(x = Baile_Level, y = percentage_duration)) +
  geom_violin(fill = "lightblue", color = "blue") +
  geom_boxplot(width = 0.15, fill = "white", color = "black", outlier.shape = NA) +
  labs(x = "Baile_Level", y = "Percentage_Dance") +
  ggtitle("Distribution of Percentage_Dance by Baile_Level") +
  theme_minimal()


# Create violin plots with facets for each condition
ggplot(df_filtered, aes(x = Baile_Level, y = percentage_duration)) +
  geom_violin(fill = "lightblue", color = "blue") +
  geom_boxplot(width = 0.15, fill = "white", color = "black", outlier.shape = NA) +
  labs(x = "Baile_Level", y = "Percentage_Dance") +
  ggtitle("Distribution of Percentage_Dance by Baile_Level") +
  facet_wrap(~ Condition, scales = "free_y", ncol = 2) +  # Add facet_wrap
  theme_minimal()


library(dplyr)
library(tidyr)

# Assuming your original dataset is named df
# First, calculate the total rounds for each name
df <- df %>%
  group_by(Name) %>%
  mutate(total_rounds = sum(Duration))

# Calculate the percentage of dance step for each row
df <- df %>%
  mutate(percentage_dance = (Duration / total_rounds) * 100)

# Create a summary table with one row per name
summary_table <- df %>%
  group_by(Name, Baile_Level) %>%
  summarize(percentage_occurrence = sum(percentage_dance)) %>%
  pivot_wider(names_from = Baile_Level, values_from = percentage_occurrence, values_fill = 0)

# View the summary table
head(summary_table)


