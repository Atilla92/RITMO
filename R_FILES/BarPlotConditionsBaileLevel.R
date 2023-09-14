# Different plots for Paper 1. 
library(dplyr)
library(stringr)
library(ggplot2)

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


df_filtered <- df_filtered %>%
  group_by(Name, Baile_Level) %>%
  mutate(sum_category = sum(percentage_duration)) %>%
  ungroup()


# Group by condition and dance level, and calculate the average percentage

average_per_condition <- df_filtered %>%
  group_by(Condition, Baile_Level) %>%
  summarize(
    avg_percentage = mean(sum_category, na.rm = TRUE),
    se_percentage = sd(sum_category) / sqrt(n())
  )

average_per_condition <- average_per_condition %>%
  filter(Baile_Level != "")


#Plot

ggplot(average_per_condition, aes(x = Condition, y = avg_percentage, fill = Baile_Level)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Condition", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Condition and Baile_Level") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top


##### ANOVA

library(dplyr)

# Perform one-way ANOVA for Z1
data_Z1 <- unique_data %>%
  filter(Baile_Level == "Z1")

data_Z2 <- unique_data %>%
  filter(Baile_Level == "Z2")

data_Z3 <- unique_data %>%
  filter(Baile_Level == "Z3")

data_R1 <- unique_data %>%
  filter(Palo == "R1")

data_D1 <- unique_data %>%
  filter(Dance_mode == "D1")

anova_result <- aov(sum_category ~ Baile_Level, data = data_Z2)
# Summarize the ANOVA results
summary(anova_result)

m01 = lmer(sum_category ~  Condition + (1 | Participant), data = data_Z1 )
m02 = lmer(sum_category ~  Condition + (1 | Participant), data = data_Z2 )
m03 = lmer(sum_category ~  Condition + (1 | Participant), data = data_Z3 )
m04 = lmer(sum_category ~  Palo + (1 | Participant), data = data_Z1 )
m05 = lmer(sum_category ~  Palo + (1 | Participant), data = data_Z2 )
m06 = lmer(sum_category ~  Palo + (1 | Participant), data = data_Z3 )
m07 = lmer(sum_category ~  Condition * Palo + (1 | Participant), data = data_Z1 )
tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )

m01 = lmer(sum_category ~  Palo* Baile_Level + (1 | Participant), data = unique_data )
m02 = lmer(sum_category ~  Condition * Baile_Level + (1 | Participant), data = data_R1 )
m03 = lmer(sum_category ~  Condition + (1 | Participant), data = data_Z3 )
m04 = lmer(sum_category ~  Palo + (1 | Participant), data = data_Z1 )
m05 = lmer(sum_category ~  Palo + (1 | Participant), data = data_Z2 )
m06 = lmer(sum_category ~  Palo + (1 | Participant), data = data_Z3 )
m07 = lmer(sum_category ~  Condition * Palo + (1 | Participant), data = data_Z1 )
tab_model(m01, m02, m03, m04, m05,m06, m07,  p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", "m06", "m07"), digits = 5 )


library(sjPlot)
library(sjlabelled)
library(sjmisc)
####

# Assuming you have anova_result from your ANOVA analysis
library(stats)

# Perform Tukey's HSD test
tukey_result <- TukeyHSD(anova_result)

# View the results
summary(tukey_result)



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




#### Filter dataset

unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)

# Count the number of unique names
unique_name_count <- unique_data %>%
  distinct(Name) %>%
  n_distinct()

# Print the count
cat("Number of unique names:", unique_name_count, "\n")


average_per_condition_unique <- unique_data %>%
  group_by(Condition, Baile_Level) %>%
  summarize(
    avg_percentage = mean(sum_category, na.rm = TRUE),
    se_percentage = sd(sum_category) / sqrt(n())
  )

ggplot(average_per_condition_unique, aes(x = Condition, y = avg_percentage, fill = Baile_Level)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Condition", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Condition and Baile_Level") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top

# Create a barplot with average and standard error
ggplot(average_per_condition_unique, aes(x = Baile_Level, y = avg_percentage, fill = Condition)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Baile_Level", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Baile_Level and Condition") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top

####



t_test_results <- data.frame()


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


t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
                                ifelse(t_test_results$p_value < 0.01, "**",
                                       ifelse(t_test_results$p_value < 0.05, "*", "")))


# View the t-test results
print(t_test_results)




###### UNIQUE 

#### Filter dataset

unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)

# Create an empty data frame to store t-test results
t_test_results <- data.frame()

shapiro.test(unique_data$sum_category)


# Loop through unique Baile_Levels
unique_baile_levels <- unique(unique_data$Baile_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
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


#####
t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_conditions <- unique(unique_data$Condition)
for (condition in unique_conditions) {
  # Subset the data for the current Baile_Level
  data_conditions <- unique_data %>%
    filter(Condition == condition)
  
  # Perform t-tests for each pair of conditions
  baile_level_pairs <- combn(unique(data_conditions$Baile_Level), 2, simplify = FALSE)
  for (pair in baile_level_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_conditions %>%
      filter(Baile_Level == condition1)
    data_condition2 <- data_conditions %>%
      filter(Baile_Level == condition2)
    
    # Perform t-test
    t_test_result <- t.test(data_condition1$sum_category, data_condition2$sum_category)
    
    # Store the results in the data frame
    result_row <- data.frame(
      Condition = condition,
      Condition1 = condition1,
      Condition2 = condition2,
      p_value = t_test_result$p.value,
      significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
    )
    
    t_test_results <- bind_rows(t_test_results, result_row)
  }
}

#Star format
t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
                                ifelse(t_test_results$p_value < 0.01, "**",
                                       ifelse(t_test_results$p_value < 0.05, "*", "")))


# View the t-test results
print(t_test_results)





# View the resulting table
average_per_condition


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



##### Same analysis per dance mode, t-test
# Calculate the total rounds for each name
df_filtered <- df_filtered %>%
  group_by(Name) %>%
  mutate(total_duration = sum(Duration))

# Calculate the percentage of dance step for each row
df_filtered <- df_filtered %>%
  mutate(percentage_duration = (Duration / total_duration) * 100)


df_filtered <- df_filtered %>%
  group_by(Name, Baile_Level) %>%
  mutate(sum_category = sum(percentage_duration)) %>%
  ungroup()



# Group by 'Condition' and calculate the total sum of 'avg_percentage'
total_sum_per_name <- df_filtered %>%
  group_by(Name) %>%
  summarise(Total_Sum = sum(percentage_duration, na.rm = TRUE)) %>%
  ungroup()

# Print the result
print(total_sum_per_name)


unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)


average_per_dance <- unique_data %>%
  group_by(Dance_mode, Baile_Level) %>%
  summarize(
    avg_percentage = mean(sum_category, na.rm = TRUE),
    se_percentage = sd(sum_category) / sqrt(n()),
  )
average_per_dance


average_per_dance <- average_per_dance %>%
  filter(Baile_Level != "")


total_sum_per_dance <- average_per_dance %>%
  group_by(Dance_mode) %>%
  summarise(Total_Sum = sum(avg_percentage, na.rm = TRUE)) %>%
  ungroup()

# Print the result
print(total_sum_per_dance)


average_per_dance <- average_per_dance %>%
  filter(Baile_Level != "")





ggplot(average_per_dance, aes(x = Dance_mode, y = avg_percentage, fill = Baile_Level)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Condition", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Condition and Baile_Level") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top



custom_palette <- c("D1" = "#FF9999", "D5" = "#99CCFF", "D6" = "#99FF99")

ggplot(average_per_dance, aes(x = Baile_Level, y = avg_percentage, fill = Dance_mode)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Dance Level", y = "Average Percentage Dance Mode") +
  ggtitle("Barplot of Average Percentage Dance with SE by Dance_Mode and Baile_Level") +
  theme_minimal() +
  # Move the legend to the top
  theme(legend.position = "top") +
  scale_x_discrete(
                    name = "Baile_Level",
                    labels = c("Z1" = "Baile", "Z2" = "Marcaje", "Z3" = "Zapateado")) +
  scale_fill_manual(values = custom_palette,
                    name = "Dance",
                   labels = c("D1" = "Impro", "D5" = "Impro/Fixed", "D6" = "Fixed"))



unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)

unique_data <- unique_data %>%
  filter(Baile_Level != "")

unique_data

#T-test

t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_conditions <- unique(unique_data$Dance_mode)
for (condition in unique_conditions) {
  # Subset the data for the current Baile_Level
  data_conditions <- unique_data %>%
    filter(Dance_mode == condition)
  
  # Perform t-tests for each pair of conditions
  baile_level_pairs <- combn(unique(data_conditions$Baile_Level), 2, simplify = FALSE)
  for (pair in baile_level_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_conditions %>%
      filter(Baile_Level == condition1)
    data_condition2 <- data_conditions %>%
      filter(Baile_Level == condition2)
    
    # Perform t-test
    t_test_result <- t.test(data_condition1$sum_category, data_condition2$sum_category)
    
    # Store the results in the data frame
    result_row <- data.frame(
      Condition = condition,
      Condition1 = condition1,
      Condition2 = condition2,
      p_value = t_test_result$p.value,
      significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
    )
    
    t_test_results <- bind_rows(t_test_results, result_row)
  }
}

#Star format
t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
                                ifelse(t_test_results$p_value < 0.01, "**",
                                       ifelse(t_test_results$p_value < 0.05, "*", "")))


# View the t-test results
print(t_test_results)


###### Reversed test
t_test_results <- data.frame()
unique_baile_levels <- unique(unique_data$Baile_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Baile_Level == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Dance_mode), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Dance_mode == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Dance_mode == condition2)
    
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



##### Same analysis per Music mode, t-test
# Calculate the total rounds for each name
df_filtered <- df_filtered %>%
  group_by(Name) %>%
  mutate(total_duration = sum(Duration))

# Calculate the percentage of dance step for each row
df_filtered <- df_filtered %>%
  mutate(percentage_duration = (Duration / total_duration) * 100)


df_filtered <- df_filtered %>%
  group_by(Name, Guitarra_Level) %>%
  mutate(sum_category = sum(percentage_duration)) %>%
  ungroup()



# Group by 'Condition' and calculate the total sum of 'avg_percentage'
total_sum_per_name <- df_filtered %>%
  group_by(Name) %>%
  summarise(Total_Sum = sum(percentage_duration, na.rm = TRUE)) %>%
  ungroup()

# Print the result
print(total_sum_per_name)


unique_data <- df_filtered %>%
  distinct(Name, Guitarra_Level, .keep_all = TRUE)


average_per_music <- unique_data %>%
  group_by(Music_mode, Guitarra_Level) %>%
  summarize(
    avg_percentage = mean(sum_category, na.rm = TRUE),
    se_percentage = sd(sum_category) / sqrt(n()),
  )
average_per_music


total_sum_per_music <- average_per_music %>%
  group_by(Music_mode) %>%
  summarise(Total_Sum = sum(avg_percentage, na.rm = TRUE)) %>%
  ungroup()

# Print the result
print(total_sum_per_music)


average_per_music <- average_per_music %>%
  filter(Guitarra_Level != "")





ggplot(average_per_music, aes(x = Music_mode, y = avg_percentage, fill = Guitarra_Level)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Condition", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Condition and Baile_Level") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top



custom_palette <- c("D1" = "#FF9999", "D5" = "#99CCFF", "D6" = "#99FF99")

ggplot(average_per_music, aes(x = Guitarra_Level, y = avg_percentage, fill = Music_mode)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Music Level", y = "Average Percentage Music Mode") +
  ggtitle("Barplot of Average Percentage Music_Level with SE by Music_Mode and Music_Level") +
  theme_minimal() +
  # Move the legend to the top
  theme(legend.position = "top")




unique_data <- df_filtered %>%
  distinct(Name, Guitarra_Level, .keep_all = TRUE)

#T-test

t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_conditions <- unique(unique_data$Music_mode)
for (condition in unique_conditions) {
  # Subset the data for the current Baile_Level
  data_conditions <- unique_data %>%
    filter(Music_mode == condition)
  
  # Perform t-tests for each pair of conditions
  baile_level_pairs <- combn(unique(data_conditions$Guitarra_Level), 2, simplify = FALSE)
  for (pair in baile_level_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_conditions %>%
      filter(Guitarra_Level == condition1)
    data_condition2 <- data_conditions %>%
      filter(Guitarra_Level == condition2)
    
    # Perform t-test
    t_test_result <- t.test(data_condition1$sum_category, data_condition2$sum_category)
    
    # Store the results in the data frame
    result_row <- data.frame(
      Condition = condition,
      Condition1 = condition1,
      Condition2 = condition2,
      p_value = t_test_result$p.value,
      significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
    )
    
    t_test_results <- bind_rows(t_test_results, result_row)
  }
}

#Star format
t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
                                ifelse(t_test_results$p_value < 0.01, "**",
                                       ifelse(t_test_results$p_value < 0.05, "*", "")))


# View the t-test results
print(t_test_results)


###### Reversed test
t_test_results <- data.frame()
unique_baile_levels <- unique(unique_data$Guitarra_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Guitarra_Level == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Music_mode), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Music_mode == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Music_mode == condition2)
    
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


#####


##### Same analysis per Palo, Dance Mode t-test, ANOVA
# Calculate the total rounds for each name
df_filtered <- df_filtered %>%
  group_by(Name) %>%
  mutate(total_duration = sum(Duration))

# Calculate the percentage of dance step for each row
df_filtered <- df_filtered %>%
  mutate(percentage_duration = (Duration / total_duration) * 100)


df_filtered <- df_filtered %>%
  group_by(Name, Baile_Level) %>%
  mutate(sum_category = sum(percentage_duration)) %>%
  ungroup()



# Group by 'Condition' and calculate the total sum of 'avg_percentage'
total_sum_per_name <- df_filtered %>%
  group_by(Name) %>%
  summarise(Total_Sum = sum(percentage_duration, na.rm = TRUE)) %>%
  ungroup()

# Print the result
print(total_sum_per_name)


unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)


average_per_palo <- unique_data %>%
  group_by(Palo, Baile_Level) %>%
  summarize(
    avg_percentage = mean(sum_category, na.rm = TRUE),
    se_percentage = sd(sum_category) / sqrt(n()),
  )
average_per_palo


total_sum_per_palo <- average_per_palo %>%
  group_by(Palo) %>%
  summarise(Total_Sum = sum(avg_percentage, na.rm = TRUE)) %>%
  ungroup()

# Print the result
print(total_sum_per_palo)


average_per_palo <- average_per_palo %>%
  filter(Baile_Level != "")





ggplot(average_per_palo, aes(x = Palo, y = avg_percentage, fill =Baile_Level)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Condition", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Condition and Baile_Level") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top



custom_palette <- c("D1" = "#FF9999", "D5" = "#99CCFF", "D6" = "#99FF99")

ggplot(average_per_palo, aes(x = Baile_Level, y = avg_percentage, fill = Palo)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Music Level", y = "Average Percentage Music Mode") +
  ggtitle("Barplot of Average Percentage Music_Level with SE by Music_Mode and Music_Level") +
  theme_minimal() +
  # Move the legend to the top
  theme(legend.position = "top")




unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)

#T-test

t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_conditions <- unique(unique_data$Palo)
for (condition in unique_conditions) {
  # Subset the data for the current Baile_Level
  data_conditions <- unique_data %>%
    filter(Palo == condition)
  
  # Perform t-tests for each pair of conditions
  baile_level_pairs <- combn(unique(data_conditions$Baile_Level), 2, simplify = FALSE)
  for (pair in baile_level_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_conditions %>%
      filter(Baile_Level == condition1)
    data_condition2 <- data_conditions %>%
      filter(Baile_Level == condition2)
    
    # Perform t-test
    t_test_result <- t.test(data_condition1$sum_category, data_condition2$sum_category)
    
    # Store the results in the data frame
    result_row <- data.frame(
      Condition = condition,
      Condition1 = condition1,
      Condition2 = condition2,
      p_value = t_test_result$p.value,
      significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
    )
    
    t_test_results <- bind_rows(t_test_results, result_row)
  }
}

#Star format
t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
                                ifelse(t_test_results$p_value < 0.01, "**",
                                       ifelse(t_test_results$p_value < 0.05, "*", "")))


# View the t-test results
print(t_test_results)


###### Reversed test
t_test_results <- data.frame()
unique_baile_levels <- unique(unique_data$Baile_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Baile_Level == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Palo), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Palo == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Palo == condition2)
    
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



####### FILTER PER PALO #################
df_filtered <- df_filtered %>%
  filter(Palo == "R2")

df_filtered <- df_filtered %>%
  group_by(Name) %>%
  mutate(total_duration = sum(Duration))

# Calculate the percentage of dance step for each row
df_filtered <- df_filtered %>%
  mutate(percentage_duration = (Duration / total_duration) * 100)


df_filtered <- df_filtered %>%
  group_by(Name, Baile_Level) %>%
  mutate(sum_category = sum(percentage_duration)) %>%
  ungroup()



# Group by 'Condition' and calculate the total sum of 'avg_percentage'
total_sum_per_name <- df_filtered %>%
  group_by(Name) %>%
  summarise(Total_Sum = sum(percentage_duration, na.rm = TRUE)) %>%
  ungroup()

# Print the result
print(total_sum_per_name)


unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)


average_per_dance <- unique_data %>%
  group_by(Dance_mode, Baile_Level) %>%
  summarize(
    avg_percentage = mean(sum_category, na.rm = TRUE),
    se_percentage = sd(sum_category) / sqrt(n()),
  )
average_per_dance


average_per_dance <- average_per_dance %>%
  filter(Baile_Level != "")


total_sum_per_dance <- average_per_dance %>%
  group_by(Dance_mode) %>%
  summarise(Total_Sum = sum(avg_percentage, na.rm = TRUE)) %>%
  ungroup()

# Print the result
print(total_sum_per_dance)


average_per_dance <- average_per_dance %>%
  filter(Baile_Level != "")





ggplot(average_per_dance, aes(x = Dance_mode, y = avg_percentage, fill = Baile_Level)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Condition", y = "Average Percentage Dance") +
  ggtitle("Barplot of Average Percentage Dance with SE by Condition and Baile_Level") +
  theme_minimal() +
  theme(legend.position = "top")  # Move the legend to the top



custom_palette <- c("D1" = "#FF9999", "D5" = "#99CCFF", "D6" = "#99FF99")

ggplot(average_per_dance, aes(x = Baile_Level, y = avg_percentage, fill = Dance_mode)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = avg_percentage - se_percentage, ymax = avg_percentage + se_percentage),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Dance Level", y = "Average Percentage Dance Mode") +
  ggtitle("Barplot of Average Percentage Dance with SE by Dance_Mode and Baile_Level") +
  theme_minimal() +
  # Move the legend to the top
  theme(legend.position = "top") +
  scale_x_discrete(
    name = "Baile_Level",
    labels = c("Z1" = "Baile", "Z2" = "Marcaje", "Z3" = "Zapateado")) +
  scale_fill_manual(values = custom_palette,
                    name = "Dance",
                    labels = c("D1" = "Impro", "D5" = "Impro/Fixed", "D6" = "Fixed"))



unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)

unique_data <- unique_data %>%
  filter(Baile_Level != "")

unique_data

#T-test

t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_conditions <- unique(unique_data$Dance_mode)
for (condition in unique_conditions) {
  # Subset the data for the current Baile_Level
  data_conditions <- unique_data %>%
    filter(Dance_mode == condition)
  
  # Perform t-tests for each pair of conditions
  baile_level_pairs <- combn(unique(data_conditions$Baile_Level), 2, simplify = FALSE)
  for (pair in baile_level_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_conditions %>%
      filter(Baile_Level == condition1)
    data_condition2 <- data_conditions %>%
      filter(Baile_Level == condition2)
    
    # Perform t-test
    t_test_result <- t.test(data_condition1$sum_category, data_condition2$sum_category)
    
    # Store the results in the data frame
    result_row <- data.frame(
      Condition = condition,
      Condition1 = condition1,
      Condition2 = condition2,
      p_value = t_test_result$p.value,
      significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
    )
    
    t_test_results <- bind_rows(t_test_results, result_row)
  }
}

#Star format
t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
                                ifelse(t_test_results$p_value < 0.01, "**",
                                       ifelse(t_test_results$p_value < 0.05, "*", "")))


# View the t-test results
print(t_test_results)


###### Reversed test
t_test_results <- data.frame()
unique_baile_levels <- unique(unique_data$Baile_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Baile_Level == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Dance_mode), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Dance_mode == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Dance_mode == condition2)
    
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



library(dplyr)
cleaned_data <- your_data %>%
  filter(percentage >= 0) %>%
  drop_na(percentage)

# Create a new data frame with unique names and their respective percentages for each dance level and condition
unique_data_chi <- unique_data %>%
  group_by(Name, Condition, Baile_Level) %>%
  summarise(percentage = sum_category)

cleaned_data <- unique_data_chi %>%
  filter(percentage >= 0) %>%
  drop_na(percentage)


# Pivot the data to create a table suitable for the chi-squared test
pivot_data <- pivot_wider(cleaned_data, names_from = Condition, values_from = percentage, values_fill = 0)
pivot_data_no_dance <- pivot_data[,-2]
# Extract the condition columns for the test (exclude 'Name')
condition_columns <- pivot_data_no_dance %>% select(-Name)

# Perform the chi-squared test
chi_squared_result <- chisq.test(pivot_data_no_dance[,-1])

# Print the chi-squared test result
print(chi_squared_result)

# Perform the chi-squared test
chi_squared_result <- chisq.test(pivot_data[, -2])  # Exclude the 'Dance_Level' column

# Print the chi-squared test result
print(chi_squared_result)
