library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(tidyr)

data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/22092023_ELAN_no_CDRS_onset_niels_1s.csv')
data <- data[grepl("P", data$Participant),] #only dancers
data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/05102023_ELAN_no_CDRS_onset_niels_1s_complete.csv')
data <- data[grepl("P", data$Participant),] #only dancers


# Check sums up to 1



df_filtered <- data %>%
  group_by(Name) %>%
  mutate(total_duration = sum(Duration))

# Calculate the percentage of dance step for each row
df_filtered <- df_filtered %>%
  mutate(percentage_duration = (Duration / total_duration) * 100)


# Create a summary table with one row per name
summary_table <- df_filtered %>%
  group_by(Name, Baile_Level) %>%
  summarize(percentage_occurrence = sum(percentage_duration)) %>%
  pivot_wider(names_from = Baile_Level, values_from = percentage_occurrence, values_fill = 0) %>%
  rowwise() %>%
  mutate(Total = sum(c_across(1:3)))

# View the summary table
head(summary_table)



name_dance_mode <- df_filtered %>%
  select(Name, Dance_Imp) %>%
  distinct()  # Get unique combinations of Name and Dance_Imp

summary_table <- summary_table %>%
  left_join(name_dance_mode, by = "Name")

name_palo <- df_filtered %>%
  select(Name, Palo) %>%
  distinct()  # Get unique combinations of Name and Dance_Imp

summary_table <- summary_table %>%
  left_join(name_palo, by = "Name")

head(summary_table)

# Group by Dance_Imp and calculate the averages and standard errors for specific columns



summary_stats_by_mode <- summary_table %>%
  group_by(Dance_Imp) %>%
  summarize(
    Avg_1 = mean(`Z1`),
    SE_1 = sd(`Z1`) / sqrt(n()),  # Standard Error for column 1
    Avg_2 = mean(`Z2`),
    SE_2 = sd(`Z2`) / sqrt(n()),  # Standard Error for column 2
    Avg_3 = mean(`Z3`),
    SE_3 = sd(`Z3`) / sqrt(n()),   # Standard Error for column 3
  ) %>%
  mutate(
    Z1 = paste(round(Avg_1, 2), round(SE_1, 2), sep = ", "),
    Z2 = paste(round(Avg_2, 2), round(SE_2, 2), sep = ", "),
    Z3 = paste(round(Avg_3, 2), round(SE_3, 2), sep = ", "),
    Total_Avg = rowSums(select(., starts_with("Avg_")))  # Calculate the total average
  ) %>%
  select(Dance_Imp, Z1, Z2, Z3, Total_Avg) %>%
  pivot_longer(cols = starts_with("Z"), names_to = "Cluster", values_to = "Value") %>%
  separate("Value", into = c("Value", "SE"), sep = ", ", convert = TRUE)


# View the resulting summary statistics

print(summary_stats_by_mode)

custom_palette <- c("Z1" = "#FF9999", "Z2" = "#99CCFF", "Z3" = "#99FF99")
ggplot(summary_stats_by_mode, aes(x = Dance_Imp, y = Value, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = Value - SE, ymax = Value + SE),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Dance Condition", y = "Average (%)") +
  ggtitle("Average (%) Dance Level") +
  theme_minimal() +
  # Move the legend to the top
  theme(legend.position = "top",
        axis.title.x = element_text(size = 16),  # Increase x-axis title size
        axis.title.y = element_text(size = 16),
        plot.title = element_text(size = 24)) +  # Increase y-axis title size
  
  scale_x_discrete(
    name = "Dance Condition",
    labels = c("D1" = "Impro", "D5" = "Mixed", "D6" = "Choreo")) +
  scale_fill_manual(values = custom_palette,
                    name = "Footwork Level",
                    labels = c("Z1" = "Low - Movements", "Z2" = "Middle - Marcajes ", "Z3" = "High - Zapateado"))


#### Per Palo


### Add distribution to dataset

df_filtered <- df_filtered %>%
  group_by(Name, Baile_Level) %>%
  mutate(sum_category = sum(percentage_duration)) %>%
  ungroup()


unique_data <- df_filtered %>%
  distinct(Name, Baile_Level, .keep_all = TRUE)


unique_name_count_per_mode <- unique_data %>%
  group_by(Dance_Imp) %>%
  summarise(unique_name_count = n_distinct(Name))


unique_name_count <- unique_data %>%
  distinct(Name) %>%
  n_distinct()

clustering_data <- na.omit(unique_data$Dance_Imp)
print(unique_name_count_per_mode)

#pairwise.t.test(unique_data$Baile_Level, unique_data$Dance_Imp, p.adjust.method = "bonferroni")





t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(unique_data$Baile_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Baile_Level == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Dance_Imp), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Dance_Imp == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Dance_Imp == condition2)
    
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






### do t-test analysis accross conditions

t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(unique_data$Dance_Imp)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Dance_Imp == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Baile_Level), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Baile_Level == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Baile_Level == condition2)
    
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


# Apply Bonferroni correction
alpha <- 0.05  # Desired significance level (e.g., 0.05)
num_comparisons <- nrow(t_test_results)  # Number of comparisons

# Adjust p-values using Bonferroni correction
t_test_results$adjusted_p_value <- p.adjust(t_test_results$p_value, method = "bonferroni", n = num_comparisons)

# Set the significance threshold
significance_threshold <- alpha / num_comparisons

# Update the "significant" column based on the Bonferroni-corrected p-values
t_test_results$significant <- t_test_results$adjusted_p_value < significance_threshold

# Add a "Result" column based on significance
t_test_results$Result <- ifelse(t_test_results$adjusted_p_value < 0.001, "***",
                                ifelse(t_test_results$adjusted_p_value < 0.01, "**",
                                       ifelse(t_test_results$adjusted_p_value < 0.05, "*", "")))

# View the results
print(t_test_results)



t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(unique_data$Baile_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Baile_Level == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Dance_Imp), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Dance_Imp == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Dance_Imp == condition2)
    
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


######################## PER PALO ####################################

df_filtered_R1 <- df_filtered[grepl("R1", df_filtered$Palo),] #only dancers 
df_filtered_R1$Palo
summary_table <- df_filtered_R1 %>%
  group_by(Name, Baile_Level) %>%
  summarize(percentage_occurrence = sum(percentage_duration)) %>%
  pivot_wider(names_from = Baile_Level, values_from = percentage_occurrence, values_fill = 0) %>%
  rowwise() %>%
  mutate(Total = sum(c_across(1:3)))

# View the summary table
head(summary_table)



name_dance_mode <- df_filtered_R1 %>%
  select(Name, Dance_Imp) %>%
  distinct()  # Get unique combinations of Name and Dance_Imp

summary_table <- summary_table %>%
  left_join(name_dance_mode, by = "Name")

name_palo <- df_filtered_R1 %>%
  select(Name, Palo) %>%
  distinct()  # Get unique combinations of Name and Dance_Imp

summary_table <- summary_table %>%
  left_join(name_palo, by = "Name")

head(summary_table)


summary_stats_by_mode <- summary_table %>%
  group_by(Dance_Imp) %>%
  summarize(
    Avg_1 = mean(`Z1`),
    SE_1 = sd(`Z1`) / sqrt(n()),  # Standard Error for column 1
    Avg_2 = mean(`Z2`),
    SE_2 = sd(`Z2`) / sqrt(n()),  # Standard Error for column 2
    Avg_3 = mean(`Z3`),
    SE_3 = sd(`Z3`) / sqrt(n()),   # Standard Error for column 3
  ) %>%
  mutate(
    Z1 = paste(round(Avg_1, 2), round(SE_1, 2), sep = ", "),
    Z2 = paste(round(Avg_2, 2), round(SE_2, 2), sep = ", "),
    Z3 = paste(round(Avg_3, 2), round(SE_3, 2), sep = ", "),
    Total_Avg = rowSums(select(., starts_with("Avg_")))  # Calculate the total average
  ) %>%
  select(Dance_Imp, Z1, Z2, Z3, Total_Avg) %>%
  pivot_longer(cols = starts_with("Z"), names_to = "Cluster", values_to = "Value") %>%
  separate("Value", into = c("Value", "SE"), sep = ", ", convert = TRUE)


# View the resulting summary statistics

print(summary_stats_by_mode)




plot1<- ggplot(summary_stats_by_mode, aes(x = Dance_Imp, y = Value, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = Value - SE, ymax = Value + SE),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Dance Condition", y = "Average (%)") +
  ggtitle("Average (%) Dance Level - Tangos") +
  theme_minimal() +
  theme(legend.position = "top",
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16),
        plot.title = element_text(size = 24)) +
  
  scale_x_discrete(
    name = "Dance Condition",
    labels = c("D1" = "Impro", "D5" = "Mixed", "D6" = "Choreo")) +
  scale_fill_manual(values = custom_palette,
                    name = "Footwork Level",
                    labels = c("Z1" = "Low - Movements", "Z2" = "Middle - Marcajes ", "Z3" = "High - Zapateado")) 


plot1

plot2<- ggplot(summary_stats_by_mode, aes(x = Dance_Imp, y = Value, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = Value - SE, ymax = Value + SE),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Dance Condition", y = "Average (%)") +
  ggtitle("Average (%) Dance Level - Solea") +
  theme_minimal() +
  theme(legend.position = "top",
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16),
        plot.title = element_text(size = 24)) +
  
  scale_x_discrete(
    name = "Dance Condition",
    labels = c("D1" = "Impro", "D5" = "Mixed", "D6" = "Choreo")) +
  scale_fill_manual(values = custom_palette,
                    name = "Footwork Level",
                    labels = c("Z1" = "Low - Movements", "Z2" = "Middle - Marcajes ", "Z3" = "High - Zapateado")) 

plot2

library(patchwork)
combined_plots <- plot1 / plot2
combined_plots



t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(df_filtered_R1$Dance_Imp)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Dance_Imp == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Baile_Level), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Baile_Level == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Baile_Level == condition2)
    
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


# Apply Bonferroni correction
alpha <- 0.05  # Desired significance level (e.g., 0.05)
num_comparisons <- nrow(t_test_results)  # Number of comparisons

# Adjust p-values using Bonferroni correction
t_test_results$adjusted_p_value <- p.adjust(t_test_results$p_value, method = "bonferroni", n = num_comparisons)

# Set the significance threshold
significance_threshold <- alpha / num_comparisons

# Update the "significant" column based on the Bonferroni-corrected p-values
t_test_results$significant <- t_test_results$adjusted_p_value < significance_threshold

# Add a "Result" column based on significance
t_test_results$Result <- ifelse(t_test_results$adjusted_p_value < 0.001, "***",
                                ifelse(t_test_results$adjusted_p_value < 0.01, "**",
                                       ifelse(t_test_results$adjusted_p_value < 0.05, "*", "")))

# View the results
print(t_test_results)



# View the t-test results
print(t_test_results)


t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(df_filtered_R1$Baile_Level)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Baile_Level == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$Dance_Imp), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(Dance_Imp == condition1)
    data_condition2 <- data_baile_level %>%
      filter(Dance_Imp == condition2)
    
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



#########################################################
#### Just combine accross Palos, and different distribution plots####
### No difference accross Music_Modes, just difference accross Palos.


df_filtered <- data %>%
  group_by(Name) %>%
  mutate(total_duration = sum(Duration))

# Calculate the percentage of dance step for each row
df_filtered <- df_filtered %>%
  mutate(percentage_duration = (Duration / total_duration) * 100)


# Create a summary table with one row per name
summary_table <- df_filtered %>%
  group_by(Name, Baile_Level) %>%
  summarize(percentage_occurrence = sum(percentage_duration)) %>%
  pivot_wider(names_from = Baile_Level, values_from = percentage_occurrence, values_fill = 0) %>%
  rowwise() %>%
  mutate(Total = sum(c_across(1:3)))

# View the summary table
head(summary_table)



name_dance_mode <- df_filtered %>%
  select(Name) %>%
  distinct()  # Get unique combinations of Name and Dance_Imp

summary_table <- summary_table %>%
  left_join(name_dance_mode, by = "Palo")

name_palo <- df_filtered %>%
  select(Name, Dance_Imp) %>%
  distinct()  # Get unique combinations of Name and Dance_Imp

summary_table <- summary_table %>%
  left_join(name_palo, by = "Name")

head(summary_table)

# Group by Dance_Imp and calculate the averages and standard errors for specific columns



summary_stats_by_mode <- summary_table %>%
  group_by(Dance_Imp) %>%
  summarize(
    Avg_1 = mean(`Z1`),
    SE_1 = sd(`Z1`) / sqrt(n()),  # Standard Error for column 1
    Avg_2 = mean(`Z2`),
    SE_2 = sd(`Z2`) / sqrt(n()),  # Standard Error for column 2
    Avg_3 = mean(`Z3`),
    SE_3 = sd(`Z3`) / sqrt(n()),   # Standard Error for column 3
  ) %>%
  mutate(
    Z1 = paste(round(Avg_1, 2), round(SE_1, 2), sep = ", "),
    Z2 = paste(round(Avg_2, 2), round(SE_2, 2), sep = ", "),
    Z3 = paste(round(Avg_3, 2), round(SE_3, 2), sep = ", "),
    Total_Avg = rowSums(select(., starts_with("Avg_")))  # Calculate the total average
  ) %>%
  select(Dance_Imp, Z1, Z2, Z3, Total_Avg) %>%
  pivot_longer(cols = starts_with("Z"), names_to = "Cluster", values_to = "Value") %>%
  separate("Value", into = c("Value", "SE"), sep = ", ", convert = TRUE)


# View the resulting summary statistics

print(summary_stats_by_mode)


custom_palette <- c("Z1" = "#FF9999", "Z2" = "#99CCFF", "Z3" = "#99FF99")
ggplot(summary_stats_by_mode, aes(x = Dance_Imp, y = Value, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = Value - SE, ymax = Value + SE),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Flamenco Palo", y = "Average (%)") +
  ggtitle("Average (%) Dance Level") +
  theme_minimal() +
  # Move the legend to the top
  theme(legend.position = "top",
        axis.title.x = element_text(size = 16),  # Increase x-axis title size
        axis.title.y = element_text(size = 16),
        plot.title = element_text(size = 24)) +  # Increase y-axis title size
  
  scale_x_discrete(
    name = "Improvisation/Choreo",
    labels = c("DI" = "Improvised", "DC" = "Choreography")) +
  scale_fill_manual(values = custom_palette,
                    name = "Footwork Level",
                    labels = c("Z1" = "Low - Movement", "Z2" = "Middle - Marcajes ", "Z3" = "High - Zapateado"))




#########################################################
# Check whether there is a difference accross Palos. 
library(lme4)
library(lmerTest)

# Longformat 
summary_table_2 <- df_filtered %>%
  group_by(Name, Baile_Level, Palo) %>%
  summarize(percentage_occurrence = sum(percentage_duration)) %>%
  ungroup()
head(summary_table_2)
summary_table_2 <- left_join(summary_table_2, distinct(df_filtered %>% select(Name, Dance_Imp)))
summary_table_2 <- left_join(summary_table_2, distinct(df_filtered %>% select(Participant, Dance_Imp)))
head(summary_table_2)

# ALl analysis
summary_table_2$Dance_Imp <- as.factor(summary_table_2$Dance_Imp)
summary_table_2$Palo <- as.factor(summary_table_2$Palo)
summary_table_2$Dance_Imp <- factor(summary_table_2$Dance_Imp, levels = c("D6", 'D5', 'D1'))
data$Condition <- factor(data$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#data$Condition_order <- as.factor(data$Condition_order)
summary_table_2$Baile_Level <- as.factor(summary_table_2$Baile_Level)




m01  = lmer(percentage_occurrence ~   Baile_Level + (1 | Participant)  , data = summary_table_2 )
m02  = lmer(percentage_occurrence ~   Palo * Baile_Level + (1 | Participant)  , data = summary_table_2 )
m03  = lmer(percentage_occurrence ~   Palo * Dance_Imp + (1 | Participant)  , data = summary_table_2 )
m04  = lmer(percentage_occurrence ~   Dance_Imp * Baile_Level + (1 | Participant)  , data = summary_table_2 )
m05  = lmer(percentage_occurrence ~   Dance_Imp  + (1 | Participant)  , data = summary_table_2 )
m06  = lmer(percentage_occurrence ~   Palo  + (1 | Participant)  , data = summary_table_2 )

tab_model(m01, m02,m03,m04,m05, m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02", 'm03', 'm04', 'm05', 'm06'), digits = 5 )


m02  = lmer(Q3 ~   percentage_occurrence * Baile_Level+ (1 | Participant)  , data = summary_table_2 )
m02  = lmer(Q3 ~   mean_p_LZ  + std_p_LZ+ (1 | Participant)  , data = summary_table_2 )
m03  = lmer(Q3 ~   Dance_Imp + (1 | Participant)  , data = summary_table_2)
m04  = lmer(Q3 ~   mean_p_dt_LZ + (1 | Participant)  , data = summary_table_2)
m05  = lmer(Q3 ~   mean_p_ncounts + (1 | Participant)  , data = summary_table_2)
m06  = lmer(Q3 ~   mean_p_IOI + (1 | Participant)  , data = summary_table_2)




### Different t-test instead #####
pairwise.t.test(data$Q3a, data$Condition, p.adjust.method = "bonferroni")

#### 
