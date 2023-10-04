# Script to analyse differences between distribution of quantitative measures accross dance conditions


data_all <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/22092023_ELAN_no_CDRS_onset_niels_1s.csv')
data<- data_all[grepl("P", data$Participant),] #only dancers

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





# Create a density plot and histogram for norm_p_ncounts by Dance_mode
ggplot(data, aes(x = norm_p_dt_LZ, fill = Dance_mode)) +
  geom_histogram(binwidth = 0.02, position = "dodge", color = "gray", alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency/Density") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +
  facet_wrap(~ Dance_mode, ncol = 1, scales = "free_y") +
  theme_minimal()

# Test either with permutation test, check whether distributions are different enough from each-other. 


# See how similar distribution plots are
library(transport)
library(emdist)
data1 <- clustering_data %>%
  filter(Dance_mode == 'D6' & cluster == '1')
data1 <- na.omit(data1$norm_p_dt_LZ)

#filtered_data <- na.omit(filtered_data$)

data2 <- clustering_data %>%
  filter(Dance_mode == "D1" & cluster == '1')
data2 <- na.omit(data2$norm_p_dt_LZ)


ks_test_result <- ks.test(data1, data2)
ks_test_result
observed_statistic <- ks.test(data1, data2)$statistic

# Mean statistic
#observed_statistic <- mean(data1) - mean(data2)
#max_length <- max(length(data1), length(data2))

combined_data <- c(data1, data2)


n_permutations <- 10000
permuted_statistics <- numeric(n_permutations)
for (i in 1:n_permutations){
  
  shuffled_data <- sample(combined_data)
  
  permuted_statistic <- ks.test(shuffled_data[1:length(data1)], shuffled_data[(length(data1) + 1):length(combined_data)])$statistic
  #permuted_statistic <- mean(shuffled_data[1:max_length]) - mean(shuffled_data[(max_length + 1):length(combined_data)])
  
  permuted_statistics[i] <- permuted_statistic
}

p_value <- mean(permuted_statistics >= observed_statistic)
# Calculate the p-value
#p_value <- mean(abs(permuted_statistics) >= abs(observed_statistic))



# Display the results
cat("Observed KS-Test Statistic:", observed_statistic, "\n")
cat("Permutation Test p-value:", p_value, "\n")




#### Probability Density Plots ####

data1 <- data %>%
  filter(Dance_mode == 'D6')
data1 <- na.omit(data1$norm_p_LZ)

#filtered_data <- na.omit(filtered_data$)

data2 <- data %>%
  filter(Dance_mode == "D1")
data2 <- na.omit(data2$norm_p_LZ)

# Perform kernel density estimation (KDE) for data1
density_data1 <- density(data1)
# Perform KDE for data2
density_data2 <- density(data2)




# Plot 1
plot(density_data1, main = "KDE for Z1 / cluster 1", xlim = c(0, 1), ylim = c(0, 10)) 
lines(density_data2$x, density_data2$y, col = "red")


library(philentropy)


matrix_data <- rbind(density_data1$y, density_data2$y)

# Compute the Jenson-Shannon Divergence (JSD)
jsd_value <- JSD(matrix_data)


jsd_value <- JSD(matrix_data)
cat("Jensen-Shannon Divergence:", jsd_value, "\n")

percentage_similarity <- 100 * (1 - jsd_value)

# Print the percentage similarity
cat("Percentage Similarity:", percentage_similarity, "%\n")



plot11 <- ggplot(clustering_data, aes(x = norm_p_dt_LZ, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge", color = "gray", alpha = 0.7) +
  labs(x = "norm_p_dt_LZ", y = "Frequency") +
  ggtitle("Distribution of norm_p_dt_LZ by Cluster and Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +
  facet_grid(cluster ~ Dance_mode, scales = "free_y") +  # Group by cluster and Condition
  theme_minimal()

print(plot11)



plot11 <- ggplot(clustering_data, aes(x = norm_p_dt_LZ, fill = cluster)) +
  geom_density(alpha = 0.5) +  # Density plot
  geom_histogram(binwidth = 0.02, position = "dodge", color = "gray", alpha = 0.5) +  # Histogram
  labs(x = "norm_p_dt_LZ", y = "Density/Frequency") +
  ggtitle("Distribution of norm_p_dt_LZ by Cluster and Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +
  facet_grid(cluster ~ Dance_mode, scales = "free_y") +  # Group by cluster and Condition
  theme_minimal()

print(plot11)

# Test with lmer model norm_lZ_avg~ Dance_mode , (which is the mean) 



PDE_data <- data %>%
  group_by(Name) %>%
  mutate(PDE_X = density(norm_p_dt_LZ)$y)
  ungroup()




