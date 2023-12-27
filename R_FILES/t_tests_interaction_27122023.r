library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(tidyr)


data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/27102023_ELAN_no_CDRS_onset_niels_4s_final.csv')
data <- data[grepl("P", data$Participant),] #only dancers

data_ole <- data %>%
  distinct(Name, Artist, .keep_all = TRUE)


# Create a new column with concatenated strings
data_ole$instruction <- paste(data_ole$Condition, data_ole$Artist, sep = "_")
data_ole$instruction_2 <- paste(data_ole$instruction, data_ole$Palo, sep = "_")
# Print the updated data frame
unique_instructions <- unique(data_ole$instruction)
print(unique_instructions)

unique_instructions_2 <- unique(data_ole$instruction_2)
print(unique_instructions_2)

# MACRO Check
data_ole$Q1 <- (data_ole$Q1a + data_ole$Q1b) / 2
data_ole$Q3 <- (data_ole$Q3a + data_ole$Q3b) / 2
data_ole$Q6 <- (data_ole$Q6a + data_ole$Q6b) /2
data_ole$Q5 <-  (data_ole$Q5a + data_ole$Q5b) /2
data_ole$Q4 <- (data_ole$Q4a + data_ole$Q4b) /3


# Factorize
# ALl analysis
data_ole$Dance_mode <- as.factor(data_ole$Dance_mode)
data_ole$Condition <- as.factor(data_ole$Condition)
data_ole$Condition <- relevel(data_ole$Condition, "D6_M6")
data_ole$Dance_mode <- factor(data_ole$Dance_mode, levels = c("D6", 'D5', 'D1'))
data_ole$Condition <- factor(data_ole$Condition, levels = c('D6_M6', 'D5_M6', 'D1_M6', 'D5_M5', 'D1_M1'))
#data_ole$Condition_order <- as.factor(data_ole$Condition_order)
data_ole$Palo <- as.factor(data_ole$Palo)
data_ole$Music_mode <- as.factor(data_ole$Music_mode)
data_ole$Music_mode <- factor(data_ole$Music_mode, levels = c("M6",'M5','M1'))
data_ole$Participant <- as.factor(data_ole$Participant)
data_ole$Pair <- as.factor(data_ole$Pair)
#data_ole$Artist <- ifelse(data_ole$Artist == "G", 0, ifelse(data_ole$Artist == "P", 1, data_ole$Artist))
data_ole$Artist <- as.factor(data_ole$Artist)
data_ole$Fam <- as.factor(data_ole$Fam)
# Instructions
data_ole$instruction <- as.factor(data_ole$instruction)
data_ole$instruction <-factor(data_ole$instruction, levels = c("D5_M6_P", "D5_M6_G",  "D1_M6_P", "D1_M6_G","D6_M6_P", "D6_M6_G",  "D5_M5_P", "D5_M5_G","D1_M1_P", "D1_M1_G"))
data_ole$instruction_2 <- as.factor(data_ole$instruction_2)
data_ole$instruction_2 <-factor(data_ole$instruction_2, levels = c("D5_M6_P_R1", "D5_M6_G_R1",  "D1_M6_P_R1", "D1_M6_G_R1","D6_M6_P_R1", "D6_M6_G_R1",  "D5_M5_P_R1", "D5_M5_G_R1","D1_M1_P_R1", "D1_M1_G_R1",
                                                                   "D5_M6_P_R2", "D5_M6_G_R2",  "D1_M6_P_R2", "D1_M6_G_R2","D6_M6_P_R2", "D6_M6_G_R2",  "D5_M5_P_R2", "D5_M5_G_R2","D1_M1_P_R2", "D1_M1_G_R2"
))

# Checking contrasts without including Palos
# Check levels
levels(data_ole$instruction_2)


# Add a new column based on a condition
data_ole <- data_ole %>%
  mutate(FIXvsOther = ifelse(Condition == "D6_M6", "Fixed", "Other"))

unique_data <- data_ole
### do t-test analysis accross conditions



#### Tests for Q1a 
t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(unique_data$Artist)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Artist == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$FIXvsOther), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(FIXvsOther == condition1)
    data_condition2 <- data_baile_level %>%
      filter(FIXvsOther == condition2)
    
    # Perform t-test
    t_test_result <- t.test(data_condition1$Q1a, data_condition2$Q1a)
    
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




#### Tests for Q1a 
t_test_results <- data.frame()
# Loop through unique Baile_Levels
unique_baile_levels <- unique(unique_data$Artist)
for (baile_level in unique_baile_levels) {
  # Subset the data for the current Baile_Level
  data_baile_level <- unique_data %>%
    filter(Artist == baile_level)
  
  # Perform t-tests for each pair of conditions
  condition_pairs <- combn(unique(data_baile_level$FIXvsOther), 2, simplify = FALSE)
  for (pair in condition_pairs) {
    condition1 <- pair[1]
    condition2 <- pair[2]
    
    # Subset the data for the two conditions
    data_condition1 <- data_baile_level %>%
      filter(FIXvsOther == condition1)
    data_condition2 <- data_baile_level %>%
      filter(FIXvsOther == condition2)
    
    # Perform t-test
    t_test_result <- t.test(data_condition1$Q1a, data_condition2$Q1a)
    
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




#### Code Peter Keller to Plot 
Adapt   = lmer(Q1a ~ Artist * FIXvsOther + (1 | Participant), data = data_ole )
summary(Adapt)

Adapt_Alpha.effects <- ggemmeans(Adapt, c("FIXvsOther", "Artist"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q1a - Quanitity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p0 <- Adapt_Alpha.effects.plot




Adapt_Alpha.effects <- ggemmeans(Adapt, c("Artist", "FIXvsOther"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q1a - Quanitity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p1 <- Adapt_Alpha.effects.plot

library(gridExtra)
grid.arrange(
  # First column with plots p1, p2, and p3
  p0, p1, ncol = 2
  
)
