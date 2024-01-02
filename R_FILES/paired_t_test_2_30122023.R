
# Preparing data

data_ole <- data_ole %>%
  mutate(INDvsGR = case_when(
    Condition %in% c("D1_M1", "D5_M5") ~ "Group",
    Condition %in% c("D5_M6", "D1_M6") ~ "Indiv",
    TRUE ~ NA_character_
  ))


data_ole <- data_ole %>%
  mutate(FIXvsOther = ifelse(Condition == "D6_M6", "Fixed", "Other"))


#### 1 Quantity of improvisation, DxA
data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsOther) %>%
  mutate(mean_Q1a = mean(Q1a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, FIXvsOther, mean_Q1a, Artist) %>%
  filter(!is.na(FIXvsOther))  # Remove rows with missing FIXvsOther values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsOther, values_from = mean_Q1a)

print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Other_P <- grouped_P$Other
Other_G <- grouped_G$Other
# subset weight data after treatment
Fixed_P <- grouped_P$Fixed
Fixed_G <- grouped_G$Fixed
# Plot paired data




# Calculate means and standard deviations
Mean_Other_P <- mean(Other_P)
SD_Other_P <- sd(Other_P)
Mean_Other_G <- mean(Other_G)
SD_Other_G <- sd(Other_G)
Mean_Fixed_P <- mean(Fixed_P)
SD_Fixed_P <- sd(Fixed_P)
Mean_Fixed_G <- mean(Fixed_G)
SD_Fixed_G <- sd(Fixed_G)

# Print means and standard deviations for Other_P and Other_G
cat("Mean_Other_P:", Mean_Other_P, "\n")
cat("SD_Other_P:", SD_Other_P, "\n")
cat("Mean_Other_G:", Mean_Other_G, "\n")
cat("SD_Other_G:", SD_Other_G, "\n")

# Print means and standard deviations for Fixed_P and Fixed_G
cat("Mean_Fixed_P:", Mean_Fixed_P, "\n")
cat("SD_Fixed_P:", SD_Fixed_P, "\n")
cat("Mean_Fixed_G:", Mean_Fixed_G, "\n")
cat("SD_Fixed_G:", SD_Fixed_G, "\n")


library(PairedData)
pd_P <- paired(Other_P, Fixed_P)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Other_G, Fixed_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Fixed_P, Other_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Fixed_G, Other_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Fixed_P)
shapiro.test(Other_P)
shapiro.test(Fixed_G)
shapiro.test(Other_G)

wilcox.test(Fixed_P, Other_P, paired = TRUE)
wilcox.test(Fixed_G, Other_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)

#### Quantity of improvisation DxC

data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1a = mean(Q1a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, INDvsGR, mean_Q1a, Artist) %>%
  filter(!is.na(INDvsGR))  # Remove rows with missing INDvsGR values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1a)

print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Group_P <- grouped_P$Group
Group_G <- grouped_G$Group
# subset weight data after treatment
Indiv_P <- grouped_P$Indiv
Indiv_G <- grouped_G$Indiv
# Plot paired data




# Calculate means and standard deviations
Mean_Group_P <- mean(Group_P)
SD_Group_P <- sd(Group_P)
Mean_Group_G <- mean(Group_G)
SD_Group_G <- sd(Group_G)
Mean_Indiv_P <- mean(Indiv_P)
SD_Indiv_P <- sd(Indiv_P)
Mean_Indiv_G <- mean(Indiv_G)
SD_Indiv_G <- sd(Indiv_G)

# Print means and standard deviations for Group_P and Group_G
cat("Mean_Group_P:", Mean_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Mean_Group_G:", Mean_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print means and standard deviations for Indiv_P and Indiv_G
cat("Mean_Indiv_P:", Mean_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("Mean_Indiv_G:", Mean_Indiv_G, "\n")
cat("SD_Indiv_G:", SD_Indiv_G, "\n")


library(PairedData)
pd_P <- paired(Group_P, Indiv_P)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Group_G, Indiv_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Indiv_P, Group_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_G, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Group_P, paired = TRUE)
wilcox.test(Indiv_G, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)



#### Quanlity of improvisation DxC

data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q1b = mean(Q1b, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, INDvsGR, mean_Q1b, Artist) %>%
  filter(!is.na(INDvsGR))  # Remove rows with missing INDvsGR values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q1b)

print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Group_P <- grouped_P$Group
Group_G <- grouped_G$Group
# subset weight data after treatment
Indiv_P <- grouped_P$Indiv
Indiv_G <- grouped_G$Indiv
# Plot paired data


# Calculate means and standard deviations
Mean_Group_P <- mean(Group_P)
SD_Group_P <- sd(Group_P)
Mean_Group_G <- mean(Group_G)
SD_Group_G <- sd(Group_G)
Mean_Indiv_P <- mean(Indiv_P)
SD_Indiv_P <- sd(Indiv_P)
Mean_Indiv_G <- mean(Indiv_G)
SD_Indiv_G <- sd(Indiv_G)

# Print means and standard deviations for Group_P and Group_G
cat("Mean_Group_P:", Mean_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Mean_Group_G:", Mean_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print means and standard deviations for Indiv_P and Indiv_G
cat("Mean_Indiv_P:", Mean_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("Mean_Indiv_G:", Mean_Indiv_G, "\n")
cat("SD_Indiv_G:", SD_Indiv_G, "\n")


library(PairedData)
pd_P <- paired(Group_P, Indiv_P)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Group_G, Indiv_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Indiv_P, Group_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_G, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Group_P, paired = TRUE)
wilcox.test(Indiv_G, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)



#### Communication with partner ExA

data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsOther) %>%
  mutate(mean_Q1b = mean(Q4a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, FIXvsOther, mean_Q1b, Palo) %>%
  filter(!is.na(FIXvsOther))  # Remove rows with missing FIXvsOther values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = FIXvsOther, values_from = mean_Q1b)

print(grouped_data)

# Split in two groups
grouped_R1 <- grouped_data[grepl("R1", grouped_data$Palo),] #only dancers
print(grouped_R1)


grouped_R2 <- grouped_data[grepl("R2", grouped_data$Palo),] #only dancers
print(grouped_R2)


# Subset weight data before treatment
Fixed_R1 <- grouped_R1$Fixed
Fixed_R2 <- grouped_R2$Fixed
# subset weight data after treatment
Other_R1 <- grouped_R1$Other
Other_R2 <- grouped_R2$Other
# Plot paired data



# Calculate means and standard deviations
Mean_Fixed_R1 <- mean(na.omit(Fixed_R1))
SD_Fixed_R1 <- sd(na.omit(Fixed_R1))
Mean_Fixed_R2 <- mean(na.omit(Fixed_R2))
SD_Fixed_R2 <- sd(na.omit(Fixed_R2))
Mean_Other_R1 <- mean(na.omit(Other_R1))
SD_Other_R1 <- sd(na.omit(Other_R1))
Mean_Other_R2 <- mean(na.omit(Other_R2))
SD_Other_R2 <- sd(na.omit(Other_R2))

# Print means and standard deviations for Fixed_R1 and Fixed_R2
cat("Mean_Fixed_R1:", Mean_Fixed_R1, "\n")
cat("SD_Fixed_R1:", SD_Fixed_R1, "\n")
cat("Mean_Fixed_R2:", Mean_Fixed_R2, "\n")
cat("SD_Fixed_R2:", SD_Fixed_R2, "\n")

# Print means and standard deviations for Other_R1 and Other_R2
cat("Mean_Other_R1:", Mean_Other_R1, "\n")
cat("SD_Other_R1:", SD_Other_R1, "\n")
cat("Mean_Other_R2:", Mean_Other_R2, "\n")
cat("SD_Other_R2:", SD_Other_R2, "\n")


library(PairedData)
pd_R1 <- paired(Fixed_R1, Other_R1)
p1 <- plot(pd_R1, type = "profile") + theme_bw()

pd_R2 <- paired(Fixed_R2, Other_R2)
p2 <- plot(pd_R2, type = "profile") + theme_bw()

t.test(Other_R1, Fixed_R1, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Other_R2, Fixed_R2, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Other_R1)
shapiro.test(Fixed_R1)
shapiro.test(Other_R2)
shapiro.test(Fixed_R2)

wilcox.test(Other_R1, Fixed_R1, paired = TRUE)
wilcox.test(Other_R2, Fixed_R2, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)






#### Complexity of piece DxC
data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, INDvsGR) %>%
  mutate(mean_Q6a = mean(Q6a, na.rm = TRUE))

filtered_data <- data_ole %>%
  distinct(Participant, Palo, INDvsGR, mean_Q6a, Artist) %>%
  filter(!is.na(INDvsGR))  # Remove rows with missing INDvsGR values

grouped_data <- filtered_data %>%
  pivot_wider(names_from = INDvsGR, values_from = mean_Q6a)

print(grouped_data)

# Split in two groups
grouped_P <- grouped_data[grepl("P", grouped_data$Artist),] #only dancers
print(grouped_P)


grouped_G <- grouped_data[grepl("G", grouped_data$Artist),] #only dancers
print(grouped_G)


# Subset weight data before treatment
Group_P <- grouped_P$Group
Group_G <- grouped_G$Group
# subset weight data after treatment
Indiv_P <- grouped_P$Indiv
Indiv_G <- grouped_G$Indiv
# Plot paired data



# Calculate means and standard deviations
Mean_Group_P <- mean(na.omit(Group_P))
SD_Group_P <- sd(na.omit(Group_P))
Mean_Group_G <- mean(na.omit(Group_G))
SD_Group_G <- sd(na.omit(Group_G))
Mean_Indiv_P <- mean(na.omit(Indiv_P))
SD_Indiv_P <- sd(na.omit(Indiv_P))
Mean_Indiv_G <- mean(na.omit(Indiv_G))
SD_Indiv_G <- sd(na.omit(Indiv_G))

# Print means and standard deviations for Group_P and Group_G
cat("Mean_Group_P:", Mean_Group_P, "\n")
cat("SD_Group_P:", SD_Group_P, "\n")
cat("Mean_Group_G:", Mean_Group_G, "\n")
cat("SD_Group_G:", SD_Group_G, "\n")

# Print means and standard deviations for Indiv_P and Indiv_G
cat("Mean_Indiv_P:", Mean_Indiv_P, "\n")
cat("SD_Indiv_P:", SD_Indiv_P, "\n")
cat("Mean_Indiv_G:", Mean_Indiv_G, "\n")
cat("SD_Indiv_G:", SD_Indiv_G, "\n")





library(PairedData)
pd_P <- paired(Group_P, Indiv_P)
p1 <- plot(pd_P, type = "profile") + theme_bw()

pd_G <- paired(Group_G, Indiv_G)
p2 <- plot(pd_G, type = "profile") + theme_bw()

t.test(Indiv_P, Group_P, paired = TRUE, correct = TRUE, alternative = 'two.sided')
t.test(Indiv_G, Group_G, paired = TRUE, correct = TRUE, alternative = 'two.sided')


shapiro.test(Indiv_P)
shapiro.test(Group_P)
shapiro.test(Indiv_G)
shapiro.test(Group_G)

wilcox.test(Indiv_P, Group_P, paired = TRUE)
wilcox.test(Indiv_G, Group_G, paired = TRUE)

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p1, p2, ncol = 2
  
)

















# data_ole <- data_ole %>%
#   inner_join(name_palo, by = c("Participant", "Palo")) %>%
#   group_by(Participant, Palo, FIXvsOther) %>%
#   mutate(mean_Q1a = mean(Q1a, na.rm = TRUE))









# 
# 
# perform_t_tests_2 <- function(data, artist_col, artist_var, condition_col,condition_var, variable_col) {
#   
#   data <- data %>%
#     inner_join(name_palo, by = c("Participant", "Palo")) %>%
#     group_by(Participant, Palo, {{condition_col}}) %>%
#     mutate(mean_Q = mean({{variable_col}}, na.rm = TRUE))
#   
#   print(data$mean_Q)
#   
#   filtered_data <- data %>%
#   distinct(Participant, Palo, {{condition_col}}, mean_Q, {{artist_col}}) %>%
#     filter(!is.na({{condition_col}}))  # Remove rows with missing FIXvsOther values
#   print(filtered_data)
#   
#   grouped_data <- filtered_data %>%
#     pivot_wider(names_from = {{condition_col}}, values_from = mean_Q)
#   
#   print(grouped_data)
#   
#   
#   # Create an empty data frame to store the t-test results
#   t_test_results <- data.frame()
#   
#   # Loop through unique levels of the Artist column
#   unique_artists <- unique(grouped_data[,3])
#   print(unique_artists)
#   for (artist_level in unique_artists) {
#     # Subset the data for the current artist level
#     # data_artist_level <- data %>%
#     #   filter({{ artist_col }} == artist_level)
#     print(artist_level)
#     #data_artist_level <- grouped_data[grouped_data['Artist'] == artist_level, ]
#     data_artist_level <- grouped_data[grouped_data$Artist == artist_level, ]
#     
#     
#     cat(sprintf("Number of rows in data_artist_level for Artist '%s': %d\n", artist_level, nrow(data_artist_level)))
#     
#     # Check if there are at least 2 unique levels of the condition column
#     unique_conditions <- unique(data[[condition_var]])
#     if (length(unique_conditions) < 2) {
#       cat(sprintf("Cannot perform t-tests for artist level '%s Less than 2 unique conditions\n", artist_level))
#       next
#     }
#     print('hello2')
#     print(data_artist_level)
#     
#     # Perform t-tests for each pair of conditions
#     condition_pairs <- combn(unique_conditions, 2, simplify = FALSE)
#     print(condition_pairs)
#     for (pair in condition_pairs) {
#       print(pair)
#       condition1 <- pair[1]
#       condition2 <- pair[2]
#       
#       # Subset the data for the two conditions
#       data_condition1 <- data_artist_level[data_artist_level[[condition_col]] == condition1, ]
#       data_condition2 <- data_artist_level[data_artist_level[[condition_col]] == condition2, ]
#       
#       # Perform t-test
#       t_test_result <- t.test(data_condition1[{{ variable_col }}], data_condition2[{{ variable_col }}], paired = TRUE)
#       
#       # Store the results in the data frame
#       result_row <- data.frame(
#         Artist = artist_level,
#         Condition1 = condition1,
#         Condition2 = condition2,
#         p_value = t_test_result$p.value,
#         significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
#       )
#       
#       t_test_results <- bind_rows(t_test_results, result_row)
#     }
#   }
#   
#   # Add a "Result" column based on significance level
#   t_test_results$Result <- ifelse(t_test_results$p_value < 0.001, "***",
#                                   ifelse(t_test_results$p_value < 0.01, "**",
#                                          ifelse(t_test_results$p_value < 0.05, "*", "")))
#   
#   # Apply Bonferroni correction
#   alpha <- 0.05  # Desired significance level (e.g., 0.05)
#   num_comparisons <- nrow(t_test_results)  # Number of comparisons
#   
#   # Adjust p-values using Bonferroni correction
#   t_test_results$adjusted_p_value <- p.adjust(t_test_results$p_value, method = "bonferroni", n = num_comparisons)
#   
#   # Set the significance threshold
#   significance_threshold <- alpha / num_comparisons
#   
#   # Update the "significant" column based on the Bonferroni-corrected p-values
#   t_test_results$significant <- t_test_results$adjusted_p_value < significance_threshold
#   
#   # Add a "Result" column based on significance
#   t_test_results$Result <- ifelse(t_test_results$adjusted_p_value < 0.001, "***",
#                                   ifelse(t_test_results$adjusted_p_value < 0.01, "**",
#                                          ifelse(t_test_results$adjusted_p_value < 0.05, "*", "")))
#   
#   return(t_test_results)
# }
# 
# perform_t_tests_2(data_ole, Artist, 'Artist',FIXvsOther, "FIXvsOther", Q1a)
# 
# #### FUnction


