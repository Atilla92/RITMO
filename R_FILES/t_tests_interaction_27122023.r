library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(tidyr)
library(emmeans)


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



perform_t_tests <- function(data, artist_col, condition_col, variable_col) {
  # Create an empty data frame to store the t-test results
  t_test_results <- data.frame()
  
  # Loop through unique levels of the Artist column
  unique_artists <- unique(data[[artist_col]])
  print(unique_artists)
  for (artist_level in unique_artists) {
    # Subset the data for the current artist level
    # data_artist_level <- data %>%
    #   filter({{ artist_col }} == artist_level)
    
    data_artist_level <- data[data[[artist_col]] == artist_level, ]
    
    cat(sprintf("Number of rows in data_artist_level for Artist '%s': %d\n", artist_level, nrow(data_artist_level)))
    
    # Check if there are at least 2 unique levels of the condition column
    unique_conditions <- unique(data_artist_level[[ condition_col]])
    print(unique_conditions)
    if (length(unique_conditions) < 2) {
      cat(sprintf("Cannot perform t-tests for artist level '%s Less than 2 unique conditions\n", artist_level))
      next
    }
    
    # Perform t-tests for each pair of conditions
    condition_pairs <- combn(unique_conditions, 2, simplify = FALSE)
    for (pair in condition_pairs) {
      condition1 <- pair[1]
      condition2 <- pair[2]
      
      # Subset the data for the two conditions
      data_condition1 <- data_artist_level[data_artist_level[[condition_col]] == condition1, ]
      data_condition2 <- data_artist_level[data_artist_level[[condition_col]] == condition2, ]
      
      # Perform t-test
      t_test_result <- t.test(data_condition1[{{ variable_col }}], data_condition2[{{ variable_col }}], paired = TRUE)
      
      # Store the results in the data frame
      result_row <- data.frame(
        Artist = artist_level,
        Condition1 = condition1,
        Condition2 = condition2,
        p_value = t_test_result$p.value,
        significant = t_test_result$p.value < 0.05  # You can adjust the significance level here
      )
      
      t_test_results <- bind_rows(t_test_results, result_row)
    }
  }
  
  # Add a "Result" column based on significance level
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
  
  return(t_test_results)
}




#### DEBUGGING

data_ole <- data_ole %>%
  inner_join(name_palo, by = c("Participant", "Palo")) %>%
  group_by(Participant, Palo, FIXvsOther) %>%
  mutate(mean_Q1a = mean(Q1a, na.rm = TRUE))

print(data_ole)





data_ole <- data_ole %>%
  mutate(FIXvsOther = ifelse(Condition == "D6_M6", "Fixed", "Other"))

Q1a_DxA <- perform_t_tests(data_ole, "Artist", "FIXvsOther", "Q1a")
Q1a_DxA


data_ole_2 <- data_ole %>%
  mutate(INDvsGR = case_when(
    Condition %in% c("D1_M1", "D5_M5") ~ "Group",
    Condition %in% c("D5_M6", "D1_M6") ~ "Indiv",
    TRUE ~ NA_character_
  ))

data_ole_2 <- data_ole_2[complete.cases(data_ole_2$INDvsGR), ]


Q1a_DxC <- perform_t_tests(data_ole_2, "Artist", "INDvsGR", "Q1a")
Q1a_DxC
Q1a_DxC_2 <- perform_t_tests(data_ole_2, "INDvsGR","Artist", "Q1a")
Q1a_DxC_2


Q1b_DxC <- perform_t_tests(data_ole_2, "Artist", "INDvsGR", "Q1b")
Q1b_DxC
Q1b_DxC_2 <- perform_t_tests(data_ole_2, "INDvsGR","Artist", "Q1b")
Q1b_DxC_2


Q4a_ExA <- perform_t_tests(data_ole, "Palo", "FIXvsOther", "Q4a")
Q4a_ExA
Q4a_ExA_2 <- perform_t_tests(data_ole, "FIXvsOther","Palo", "Q4a")
Q4a_ExA_2

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


##### Q1a CxD

Adapt   = lmer(Q1a ~ Artist * INDvsGR + (1 | Participant), data = data_ole_2 )
summary(Adapt)

Adapt_Alpha.effects <- ggemmeans(Adapt, c("INDvsGR", "Artist"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q1a - Quanitity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p0 <- Adapt_Alpha.effects.plot



Adapt_Alpha.effects <- ggemmeans(Adapt, c("Artist", "INDvsGR"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q1a - Quanitity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p1 <- Adapt_Alpha.effects.plot


grid.arrange(
  # First column with plots p1, p2, and p3
  p0, p1, ncol = 2
  
)


##### Q1b CxD

Adapt   = lmer(Q1b ~ Artist * INDvsGR + (1 | Participant), data = data_ole_2 )
summary(Adapt)

Adapt_Alpha.effects <- ggemmeans(Adapt, c("INDvsGR", "Artist"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q1b - Quanitity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p0 <- Adapt_Alpha.effects.plot



Adapt_Alpha.effects <- ggemmeans(Adapt, c("Artist", "INDvsGR"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q1b - Quanitity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p1 <- Adapt_Alpha.effects.plot


grid.arrange(
  # First column with plots p1, p2, and p3
  p0, p1, ncol = 2
  
)
