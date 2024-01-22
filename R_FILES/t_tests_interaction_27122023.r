library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)
library(tidyr)
library(emmeans)
library(gridExtra)


data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/27102023_ELAN_no_CDRS_onset_niels_4s_final.csv')
#data <- data[grepl("P", data$Participant),] #only dancers

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
      print('pair')
      condition1 <- pair[1]
      condition2 <- pair[2]
      
      # Subset the data for the two conditions
      data_condition1 <- data_artist_level[data_artist_level[[condition_col]] == condition1, ]
      data_condition2 <- data_artist_level[data_artist_level[[condition_col]] == condition2, ]
   
      # Perform t-test
      t_test_result <- t.test(data_condition1[{{ variable_col }}], data_condition2[{{ variable_col }}])
      print(t_test_result)
      # # Extract mean and standard deviation for each variable

      
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
Q1a_DxA_2 <- perform_t_tests(data_ole, "FIXvsOther", "Artist", "Q1a")
Q1a_DxA_2


# Sort the dataframe by FIXvsOther column
data_ole_sorted <- data_ole[order(data_ole$FIXvsOther), ]
# Group by Artist and FIXvsOther columns and calculate mean and std for Q1a
summary_table <- aggregate(Q1a ~ Artist + FIXvsOther, data_ole_sorted, function(x) c(mean = mean(x), std = sd(x)))
# Display the summary table
summary_table




data_ole <- data_ole %>%
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


# Sort the dataframe by FIXvsOther column
data_ole_sorted <- data_ole[order(data_ole$INDvsGR), ]
# Group by Artist and FIXvsOther columns and calculate mean and std for Q1a
summary_table <- aggregate(Q1b ~ Artist + INDvsGR, data_ole_sorted, function(x) c(mean = mean(x), std = sd(x)))
# Display the summary table
summary_table



Q4a_ExA <- perform_t_tests(data_ole, "Palo", "FIXvsOther", "Q4a")
Q4a_ExA
Q4a_ExA_2 <- perform_t_tests(data_ole, "FIXvsOther","Palo", "Q4a")
Q4a_ExA_2


# Sort the dataframe by FIXvsOther column
data_ole_sorted <- data_ole[order(data_ole$FIXvsOther), ]
# Group by Artist and FIXvsOther columns and calculate mean and std for Q1a
summary_table <- aggregate(Q4a ~ Palo + FIXvsOther, data_ole_sorted, function(x) c(mean = mean(x), std = sd(x)))
# Display the summary table
summary_table


# Create a new dataset by omitting NA values in the column "Q6a"
data_filtered_Q6a <- na.omit(data_ole[, "Q6a"])

# Copy all columns from the original dataset to the filtered dataset
data_filtered_Q6a <- data_ole[which(!is.na(data_ole$Q6a)), ]


# Create a new dataset by omitting NA values in the column "Q6a"
data_filtered_Q6 <- na.omit(data_filtered_Q6a[, "INDvsGR"])

# Copy all columns from the original dataset to the filtered dataset
data_filtered_Q6 <- data_filtered_Q6a[which(!is.na(data_filtered_Q6a$INDvsGR)), ]


# Display the filtered dataset
print(data_filtered_Q6)
Q6a_ExA <- perform_t_tests(data_filtered_Q6, "Artist", "INDvsGR", "Q6a")
Q6a_ExA
Q6a_ExA_2 <- perform_t_tests(data_filtered_Q6, "INDvsGR","Artist", "Q6a")
Q6a_ExA_2


# Sort the dataframe by FIXvsOther column
data_ole_sorted <- data_filtered_Q6[order(data_filtered_Q6$INDvsGR), ]
# Group by Artist and FIXvsOther columns and calculate mean and std for Q1a
summary_table <- aggregate(Q6a ~ Artist + INDvsGR, data_ole_sorted, function(x) c(mean = mean(x), std = sd(x)))
# Display the summary table
summary_table


# Display the filtered dataset
data_filtered_Abs_Av <- na.omit(data_ole[, "Abs_Av"])

# Copy all columns from the original dataset to the filtered dataset
data_filtered_Abs_Av <- data_[which(!is.na(data_ole$Abs_Av)), ]


# Create a new dataset by omitting NA values in the column "Abs_Av"
data_filtered_Abs <- na.omit(data_filtered_Abs_Av[, "MIXvsIMP"])

# Copy all columns from the original dataset to the filtered dataset
data_filtered_Abs <- data_filtered_Abs_Av[which(!is.na(data_filtered_Abs_Av$MIXvsIMP)), ]



Abs_Av_ExA <- perform_t_tests(data_filtered_Abs, "Artist", "MIXvsIMP", "Abs_Av")
Abs_Av_ExA
Abs_Av_ExA_2 <- perform_t_tests(data_filtered_Abs, "MIXvsIMP","Artist", "Abs_Av")
Abs_Av_ExA_2


Q2a_DxA <- perform_t_tests(data_ole, "Artist", "FIXvsOther", "Q2a")
Q2a_DxA
Q2a_DxA_2 <- perform_t_tests(data_ole, "FIXvsOther","Artist", "Q2a")
Q2a_DxA_2

# Sort the dataframe by FIXvsOther column
data_ole_sorted <- data_ole[order(data_ole$FIXvsOther), ]
# Group by Artist and FIXvsOther columns and calculate mean and std for Q1a
summary_table <- aggregate(Q2a ~ Artist + FIXvsOther, data_ole_sorted, function(x) c(mean = mean(x), std = sd(x)))
# Display the summary table
summary_table


# Create a new dataset by omitting NA values in the column "Q6a"
data_filtered_Q6 <- na.omit(data_ole[, "INDvsGR"])

# Copy all columns from the original dataset to the filtered dataset
data_filtered_Q6 <- data_filtered_Q6a[which(!is.na(data_filtered_Q6a$INDvsGR)), ]
Q2a_DxC <- perform_t_tests(data_filtered_Q6, "Artist", "INDvsGR", "Q2a")
Q2a_DxC
Q2a_DxC_2 <- perform_t_tests(data_filtered_Q6, "INDvsGR","Artist", "Q2a")
Q2a_DxC_2

# Sort the dataframe by FIXvsOther column
data_ole_sorted <- data_ole[order(data_ole$INDvsGR), ]
# Group by Artist and FIXvsOther columns and calculate mean and std for Q1a
summary_table <- aggregate(Q2a ~ Artist + INDvsGR, data_ole_sorted, function(x) c(mean = mean(x), std = sd(x)))
# Display the summary table
summary_table






#### Code Peter Keller to Plot 


data_ole$FIXvsOther <- as.factor(data_ole$FIXvsOther)

common_theme <- theme(
  axis.text.y = element_text(size = 10),   # Adjust y-axis text size
  axis.text.x = element_text(size = 10),   # Adjust y-axis text size
  strip.text = element_text(size = 12)     # Adjust facet titles size
  #plot.margin = margin(1, 1, 1, 1, "cm")
) 
Adapt   = lmer(Q1a ~ Artist * FIXvsOther + (1 | Pair/Participant), data = data_ole )
summary(Adapt)

Adapt_Alpha.effects <- ggemmeans(Adapt, c("FIXvsOther", "Artist"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .8, dot.alpha = .5, dot.size = 2, limit.range = TRUE, jitter = TRUE) +
  labs(x= "", y = "Predictor", title = "Q1a - Quanitity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=TRUE,fullrange=FALSE) +
  geom_line(size=1.75)+
  common_theme
p0 <- Adapt_Alpha.effects.plot
p0


plot_data <- data.frame(
  FIXvsOther = c("Fixed", "Other", "Fixed", "Other"),
  Artist = c("G", "G", "P", "P"),
  Predicted = c(3.16, 4.58, 2.78, 6.27),
  CI_low = c(2.64, 4.23, 2.26, 5.92),
  CI_high = c(3.68, 4.94, 3.30, 6.62)
)

Adapt_Alpha.effects.plot <- ggplot(plot_data, aes(x = "FIXvsOther", y = "Predicted", fill = "FIXvsOther")) +
  geom_boxplot() +
  labs(x = "FIXvsOther", y = "Predicted", title = "Q1a - Quantity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_fill_manual(values = c("red", "darkred")) +
  geom_errorbar(aes(ymax = CI_high, ymin = CI_low), width = 0.2) +
  facet_wrap(vars(Artist)) +
  theme_bw()

print(Adapt_Alpha.effects.plot)

ggplot(Adapt_Alpha.effects, aes(x = x, y = y, color = group, fill = group)) +
  geom_boxplot(width = 0.5, fill = "transparent", outlier.shape = NA) +
  geom_point(alpha = 0.8, size = 2) +
  geom_smooth(method = "lm", se = TRUE, fullrange = FALSE) +
  labs(x = "", y = "Predictor", title = "Q1a - Quantity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red", "darkred")) +
  scale_fill_manual(values = c("red", "darkred")) +
  theme_bw()

p0
# Significance data
significance_data <- data.frame(
  x = c(1.2,1.45),  # Replace x1, x2, x3 with the x-coordinates of the points where you want to add significance indicators
  y = c(4, 4.5),  # Replace y1, y2, y3 with the y-coordinates of the points where you want to add significance indicators
  significance = c("***", "***"),
  color = c("red","darkred")   # Replace "***" with your actual significance labels
)

# Add significance labels to the plot
 
p0 <- Adapt_Alpha.effects.plot + 
  geom_text(data = significance_data, aes(x = x, y = y, label = significance, fill = color ), size = 8, vjust = -1, inherit.aes = FALSE) +
  theme(legend.position = "none")  # Optional: If you want to hide the legend

# Print the plot
p0


Adapt_Alpha.effects <- ggemmeans(Adapt, c("Artist", "FIXvsOther"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = ~Participant, rawdata = TRUE, alpha = .8, dot.alpha = .5, dot.size = 2, limit.range = TRUE, jitter = TRUE) +
  labs(x= "", y = "Predictor", title = "Q1a - Quanitity of Improvisation") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) +
  common_theme
p1 <- Adapt_Alpha.effects.plot

p1
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



##### Q4a CxD

Adapt   = lmer(Q4a ~ Palo * FIXvsOther + (1 | Pair/Participant), data = data_ole )
summary(Adapt)

Adapt_Alpha.effects <- ggemmeans(Adapt, c("FIXvsOther", "Palo"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q4a - Connection with partner") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p0 <- Adapt_Alpha.effects.plot



Adapt_Alpha.effects <- ggemmeans(Adapt, c("Palo", "FIXvsOther"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q4a - Connection with partner") +
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

Adapt   = lmer(Q6a ~ Artist * INDvsGR + (1 | Pair/Participant), data = data_ole )
summary(Adapt)

Adapt_Alpha.effects <- ggemmeans(Adapt, c("Artist", "INDvsGR"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q6a - Complexity of Piece") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p0 <- Adapt_Alpha.effects.plot



Adapt_Alpha.effects <- ggemmeans(Adapt, c("INDvsGR", "Artist"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Q6a - Complexity of Piece") +
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



##### Abs_Av BxD

Adapt   = lmer(Abs_Av ~ Artist * MIXvsIMP + (1 | Pair/Participant), data = data_ole )
summary(Adapt)

Adapt_Alpha.effects <- ggemmeans(Adapt, c("Artist", "MIXvsIMP"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Absorption of Activity") +
  coord_cartesian(ylim = c(0, 7)) +
  scale_colour_manual(values = c("red","darkred")) +
  scale_fill_manual(values= c("red","darkred")) +
  geom_smooth(method=lm,se=FALSE,fullrange=FALSE) +
  geom_line(size=1.75) 
p0 <- Adapt_Alpha.effects.plot



Adapt_Alpha.effects <- ggemmeans(Adapt, c("MIXvsIMP", "Artist"))
Adapt_Alpha.effects.plot <- plot(Adapt_Alpha.effects, facet = FALSE, rawdata = TRUE, alpha = .2, dot.alpha = .2, dot.size = 2, limit.range = TRUE, jitter = NULL) +
  labs(x= "", y = "Predictor", title = "Absorption of Activity") +
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



