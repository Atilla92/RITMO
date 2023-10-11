library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)

data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/22092023_ELAN_no_CDRS_onset_niels_1s.csv')
data <- data[grepl("P", data$Participant),] #only dancers

## Checl data## 

participant_name_counts <- subset_data %>%
  group_by(Participant) %>%
  summarise(Unique_Name_Count = n_distinct(Name))
print(participant_name_counts)


# ALl analysis
data$Dance_mode <- as.factor(data$Dance_mode)
data$Condition <- as.factor(data$Condition)
data$Condition <- relevel(data$Condition, "D6_M6")
data$Dance_mode <- factor(data$Dance_mode, levels = c("D1", 'D5', 'D6'))
data$Condition <- factor(data$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#data$Condition_order <- as.factor(data$Condition_order)
data$Palo <- as.factor(data$Palo)
data$Music_mode <- as.factor(data$Music_mode)
data$Music_mode <- factor(data$Music_mode, levels = c("M6",'M5','M1'))
data$Participant <- as.factor(data$Participant)
data$Pair <- as.factor(data$Pair)
data$Artist <- as.factor(data$Artist)

# MACRO Additional 
data$Q1 <- (data$Q1a + data$Q1b) / 2
data$Q3 <- (data$Q3a + data$Q3b) / 2
data$Q6 <- (data$Q6a + data$Q6b) /2
data$Q5 <-  (data$Q5a + data$Q5b) /2
data$Q4 <- (data$Q4a + data$Q4b + data$Q4c) /3
# Clustering
clustering_data <- data[, c("p_LZ", "p_dt_LZ", "p_IOI", "p_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Baile_Level', 'Name', 'Q3', 'Q4', 'Q5', 'Q6', 'Palo', 'Artist', 'Abs_Av', 'Perf_Av', 'Q1', 'Pair', 'Music_mode', 'number')]

clustering_data <- na.omit(clustering_data)
#scaled_data <- scale(clustering_data[,c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts")])


# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
clustering_data <- clustering_data %>%
  group_by(Participant) %>%
  mutate(
    kn_p_LZ = (p_LZ - min(p_LZ)) / (max(p_LZ) - min(p_LZ)),  # Scale to [0, 1]
    kn_p_dt_LZ = ((p_dt_LZ - min(p_dt_LZ)) / (max(p_dt_LZ) - min(p_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_p_IOI = (p_IOI - min(p_IOI)) / (max(p_IOI) - min(p_IOI)),  # Scale to [0, 1]
    kn_p_ncounts = (p_ncounts - min(p_ncounts)) / (max(p_ncounts) - min(p_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(clustering_data$kn_p_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_p_dt_LZ:", non_finite_count, "\n")




kmeans_data <- clustering_data[,c("kn_p_LZ", "kn_p_dt_LZ", "kn_p_IOI", "kn_p_ncounts")]


k <- 3
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
cluster_labels <- kmeans_result$cluster


# Add cluster labels to your original dataset
clustering_data$cluster <- factor(cluster_labels)
cluster_centers <- kmeans_result$centers
print(cluster_centers)

clustering_data <- clustering_data %>%
  mutate(cluster = case_when(
    cluster == 1 ~ "3",
    cluster == 2 ~ "1",
    cluster == 3 ~ "2",
    # Add more cases as needed
    TRUE ~ as.character(cluster)  # Keep other values unchanged
  ))



####

plot1 <- ggplot(clustering_data, aes(x = kn_p_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = kn_p_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots





# Calculate the total rounds for each name
df_filtered <- clustering_data %>%
  group_by(Name) %>%
  mutate(total_duration = sum(Duration))

# Calculate the percentage of dance step for each row
df_filtered <- df_filtered %>%
  mutate(percentage_duration = (Duration / total_duration) * 100)





# Check sums up to 1

library(dplyr)
library(tidyr)
# Create a summary table with one row per name
summary_table <- df_filtered %>%
  group_by(Name, cluster) %>%
  summarize(percentage_occurrence = sum(percentage_duration)) %>%
  pivot_wider(names_from = cluster, values_from = percentage_occurrence, values_fill = 0) %>%
  rowwise() %>%
  mutate(Total = sum(c_across(1:3)))

# View the summary table
head(summary_table)



name_dance_mode <- df_filtered %>%
  select(Name, Dance_mode) %>%
  distinct()  # Get unique combinations of Name and Dance_mode

summary_table <- summary_table %>%
  left_join(name_dance_mode, by = "Name")



# Group by Dance_mode and calculate the averages and standard errors for specific columns



summary_stats_by_mode <- summary_table %>%
  group_by(Dance_mode) %>%
  summarize(
    Avg_1 = mean(`1`),
    SE_1 = sd(`1`) / sqrt(n()),  # Standard Error for column 1
    Avg_2 = mean(`2`),
    SE_2 = sd(`2`) / sqrt(n()),  # Standard Error for column 2
    Avg_3 = mean(`3`),
    SE_3 = sd(`3`) / sqrt(n())   # Standard Error for column 3
  ) %>%
  mutate(
    cl_1 = paste(round(Avg_1, 2), round(SE_1, 2), sep = ", "),
    cl_2 = paste(round(Avg_2, 2), round(SE_2, 2), sep = ", "),
    cl_3 = paste(round(Avg_3, 2), round(SE_3, 2), sep = ", "),
    Total_Avg = rowSums(select(., starts_with("Avg_")))  # Calculate the total average
  ) %>%
  select(Dance_mode, cl_1, cl_2, cl_3, Total_Avg) %>%
  pivot_longer(cols = starts_with("cl_"), names_to = "Cluster", values_to = "Value") %>%
  separate("Value", into = c("Value", "SE"), sep = ", ", convert = TRUE)


# View the resulting summary statistics

print(summary_stats_by_mode)

custom_palette <- c("cl_1" = "#FF9999", "cl_2" = "#99CCFF", "cl_3" = "#99FF99")
ggplot(summary_stats_by_mode, aes(x = Dance_mode, y = Value, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = Value - SE, ymax = Value + SE),
                width = 0.3, position = position_dodge(0.7)) +
  labs(x = "Dance Condition", y = "Average Percentage") +
  ggtitle("Average Percentage Dance Level within each Dance Condition") +
  theme_minimal() +
  theme(legend.position = "top") +  # Move the legend to the top
  scale_x_discrete(
  name = "Dance_mode",
  labels = c("D1" = "Impro", "D5" = "Mixed", "D6" = "Choreo")) +
  scale_fill_manual(values = custom_palette,
                    name = "Cluster",
                    labels = c("cl_1" = "1", "cl_2" = "2", "cl_3" = "3"))

library(tidyr)


df_filtered <- df_filtered %>%
  group_by(Name, cluster) %>%
  mutate(sum_category = sum(percentage_duration)) %>%
  ungroup()


unique_data <- df_filtered %>%
  distinct(Name, cluster, .keep_all = TRUE)


unique_name_count_per_mode <- unique_data %>%
  group_by(Dance_mode) %>%
  summarise(unique_name_count = n_distinct(Name))


unique_name_count <- unique_data %>%
  distinct(Name) %>%
  n_distinct()

print(unique_name_count)

### T-test

# Create an empty data frame to store t-test results
t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(unique_data$cluster)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(cluster == baile_level)
  
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


t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
                                ifelse(t_test_results$p_value < 0.01, "**",
                                       ifelse(t_test_results$p_value < 0.05, "*", "")))


# View the t-test results
print(t_test_results)



### do t-test analysis accross conditions

t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(unique_data$Dance_mode)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Dance_mode == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$cluster), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(cluster == condition1)
    data_condition2 <- data_baile_level %>%
      filter(cluster == condition2)
    
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

###############################################################################################################
### Add vartiables to clustering_data





## Lmer Models


# View the resulting PDF data
print(pdf_data)

lmer_data <- clustering_data %>%
  group_by(Name) %>%
  mutate(
    mean_p_LZ = mean(kn_p_LZ),
    std_p_LZ = sd(kn_p_LZ),
    mean_p_dt_LZ = mean(kn_p_dt_LZ),
    std_p_dt_LZ = sd(kn_p_dt_LZ),
    mean_p_IOI = mean(kn_p_IOI),
    std_p_IOI = sd(kn_p_IOI),
    mean_p_ncounts = mean(kn_p_ncounts),
    std_p_ncounts = sd(kn_p_ncounts)
  ) %>%
  ungroup()


lmer_data <- clustering_data %>%
  group_by(Name, cluster) %>%
  mutate(
    cl_mean_LZ = mean(kn_p_LZ),
    cl_std_p_LZ = sd(kn_p_LZ),
    cl_mean_p_dt_LZ = mean(kn_p_dt_LZ),
    cl_std_p_dt_LZ = sd(kn_p_dt_LZ),
    cl_mean_p_IOI = mean(kn_p_IOI),
    cl_std_p_IOI = sd(kn_p_IOI),
    cl_mean_p_ncounts = mean(kn_p_ncounts),
    cl_std_p_ncounts = sd(kn_p_ncounts)
  ) %>%
  ungroup()


# View the resulting summary data
unique_lmer_data <- lmer_data %>%
  distinct(Name, cluster, .keep_all = TRUE)

# View the resulting dataset
print(unique_lmer_data)




# ALl analysis
lmer_data$Dance_mode <- as.factor(lmer_data$Dance_mode)
lmer_data$Condition <- as.factor(lmer_data$Condition)
lmer_data$Condition <- relevel(lmer_data$Condition, "D6_M6")
lmer_data$Dance_mode <- factor(lmer_data$Dance_mode, levels = c("D1", 'D5', 'D6'))
lmer_data$Condition <- factor(lmer_data$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#data$Condition_order <- as.factor(data$Condition_order)
lmer_data$Participant <- as.factor(lmer_data$Participant)
lmer_data$cluster <- as.factor(lmer_data$cluster)

lmer_data$Palo <- as.factor(lmer_data$Palo)
lmer_data$Music_mode <- as.factor(lmer_data$Music_mode)
lmer_data$Music_mode <- factor(lmer_data$Music_mode, levels = c("M6",'M5','M1'))
lmer_data$Pair <- as.factor(lmer_data$Pair)
lmer_data$Artist <- as.factor(lmer_data$Artist)



# ALl analysis
unique_lmer_data$Dance_mode <- as.factor(unique_lmer_data$Dance_mode)
unique_lmer_data$Condition <- as.factor(unique_lmer_data$Condition)
unique_lmer_data$Condition <- relevel(unique_lmer_data$Condition, "D6_M6")
unique_lmer_data$Dance_mode <- factor(unique_lmer_data$Dance_mode, levels = c("D1", 'D5', 'D6'))
unique_lmer_data$Condition <- factor(unique_lmer_data$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#data$Condition_order <- as.factor(data$Condition_order)
unique_lmer_data$Participant <- unique_lmer_data(lmer_data$Participant)


unique_lmer_data$Palo <- as.factor(unique_lmer_data$Palo)
unique_lmer_data$Music_mode <- as.factor(unique_lmer_data$Music_mode)
unique_lmer_data$Music_mode <- factor(unique_lmer_data$Music_mode, levels = c("M6",'M5','M1'))
unique_lmer_data$Pair <- as.factor(unique_lmer_data$Pair)
unique_lmer_data$Artist <- as.factor(unique_lmer_data$Artist)



library(lme4)
library(lmerTest)
m01  = lmer(Q3 ~   Condition + (1 | Participant)  , data = unique_lmer_data )
m02  = lmer(Q3 ~   mean_p_LZ  + std_p_LZ+ (1 | Participant)  , data = unique_lmer_data )
m03  = lmer(Q3 ~   Dance_mode + (1 | Participant)  , data = unique_lmer_data)
m04  = lmer(Q3 ~   mean_p_dt_LZ + (1 | Participant)  , data = unique_lmer_data)
m05  = lmer(Q3 ~   mean_p_ncounts + (1 | Participant)  , data = unique_lmer_data)
m06  = lmer(Q3 ~   mean_p_IOI + (1 | Participant)  , data = unique_lmer_data)


tab_model(m01, m02, m03, m04, m05, m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", 'm06'), digits = 5 )

m01  = lmer(mean_p_LZ ~   Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m02  = lmer(mean_p_IOI ~   Dance_mode+ (1 | Participant)  , data = unique_lmer_data )
m03  = lmer(mean_p_dt_LZ ~   Dance_mode + (1 | Participant)  , data = unique_lmer_data)
m04  = lmer(mean_p_ncounts ~   Dance_mode + (1 | Participant)  , data = unique_lmer_data)
m05  = lmer(Q3 ~   mean_p_dt_LZ * Condition + (1 | Participant)  , data = unique_lmer_data)
m06  = lmer(Q3 ~   mean_p_dt_LZ * Dance_mode+ (1 | Participant)  , data = unique_lmer_data)


tab_model(m01, m02, m03, m04, m05, m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", 'm06'), digits = 5 )

m01  = lmer(mean_p_LZ ~   Palo + (1 | Participant)  , data = unique_lmer_data )
m02  = lmer(mean_p_IOI ~   Palo+ (1 | Participant)  , data = unique_lmer_data )
m03  = lmer(mean_p_dt_LZ ~   Palo + (1 | Participant)  , data = unique_lmer_data)
m04  = lmer(mean_p_ncounts ~   Palo + (1 | Participant)  , data = unique_lmer_data)
m05  = lmer(Q1 ~   mean_p_LZ * Palo + (1 | Participant)  , data = unique_lmer_data)
m06  = lmer(Q1 ~   mean_p_IOI * Palo + (1 | Participant)  , data = unique_lmer_data)


tab_model(m01, m02, m03, m04, m05, m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", 'm06'), digits = 5 )


m01  = lmer(mean_p_dt_LZ ~   Q3 *Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m02  = lmer(mean_p_dt_LZ ~   Q4*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m03  = lmer(mean_p_dt_LZ ~   Q5*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m04  = lmer(mean_p_dt_LZ ~   Q6*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m05  = lmer(mean_p_dt_LZ ~   Abs_Av *Dance_mode+ (1 | Participant)  , data = unique_lmer_data )
m06  = lmer(mean_p_dt_LZ ~   Perf_Av *Dance_mode+ (1 | Participant)  , data = unique_lmer_data )


tab_model(m01, m02, m03, m04, m05, m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", 'm06'), digits = 5 )


m01  = lmer(mean_p_LZ ~   Q3 *Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m02  = lmer(mean_p_LZ ~   Q4*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m03  = lmer(mean_p_LZ ~   Q5*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m04  = lmer(mean_p_LZ ~   Q6*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m05  = lmer(mean_p_LZ ~   Abs_Av *Dance_mode+ (1 | Participant)  , data = unique_lmer_data )
m06  = lmer(mean_p_LZ ~   Perf_Av *Dance_mode+ (1 | Participant)  , data = unique_lmer_data )


tab_model(m01, m02, m03, m04, m05, m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", 'm06'), digits = 5 )

m01  = lmer(cl_mean_LZ ~   cluster * Dance_mode + (1 | Name)  , data = lmer_data )
m02  = lmer(cl_std_p_LZ ~   cluster * Dance_mode + (1 | Name)  , data = lmer_data )
m03  = lmer(cl_mean_p_ncounts ~   cluster * Dance_mode + (1 | Name)  , data = lmer_data )
m04  = lmer(cl_std_p_ncounts ~   cluster * Dance_mode + (1 | Name)  , data = lmer_data )
m05  = lmer(cl_mean_LZ ~   cluster *Condition + (1 | Name) + (1 | Participant) , data = lmer_data )
m06  = lmer(cl_mean_LZ ~   cluster *Q3+ (1 | Name)  , data = lmer_data )


tab_model(m01, m02, m03, m04, m05, m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", 'm06'), digits = 5 )


m01  = lmer(Q3 ~   cl_mean_LZ *cluster + (1 | Name)  , data = unique_lmer_data )
m02  = lmer(mean_p_LZ ~   Q4*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m03  = lmer(mean_p_LZ ~   Q5*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m04  = lmer(mean_p_LZ ~   Q6*Dance_mode + (1 | Participant)  , data = unique_lmer_data )
m05  = lmer(mean_p_LZ ~   Abs_Av *Dance_mode+ (1 | Participant)  , data = unique_lmer_data )
m06  = lmer(mean_p_LZ ~   Perf_Av *Dance_mode+ (1 | Participant)  , data = unique_lmer_data )


tab_model(m01, m02, m03, m04, m05, m06, p.style = "stars", show.aic = TRUE, show.ci=FALSE,   show.r2 = FALSE,
          dv.labels=c("m01", "m02","m03","m04", "m05", 'm06'), digits = 5 )

