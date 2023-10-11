library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)

data1 <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/22092023_ELAN_no_CDRS_onset_niels_1s.csv')
data1 <- data1[grepl("P", data1$Participant),] #only dancers

data2 <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/05102023_ELAN_no_CDRS_onset_niels_1s_part_1.csv')
data2 <- data2[grepl("P", data2$Participant),] #only dancers

data3 <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/05102023_ELAN_no_CDRS_onset_niels_1s_complete.csv')
data3 <- data3[grepl("P", data3$Participant),] #only dancers




### Clusterinf DATA 1
clustering_data1 <- data1[, c("p_LZ", "p_dt_LZ", "p_IOI", "p_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Baile_Level', 'Name', 'Palo', 'Artist', 'Abs_Av', 'Perf_Av', 'Pair', 'Music_mode', 'number')]

clustering_data1 <- na.omit(clustering_data1)
#scaled_data <- scale(clustering_data1[,c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts")])


# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
clustering_data1 <- clustering_data1 %>%
  group_by(Participant) %>%
  mutate(
    kn_p_LZ = (p_LZ - min(p_LZ)) / (max(p_LZ) - min(p_LZ)),  # Scale to [0, 1]
    kn_p_dt_LZ = ((p_dt_LZ - min(p_dt_LZ)) / (max(p_dt_LZ) - min(p_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_p_IOI = (p_IOI - min(p_IOI)) / (max(p_IOI) - min(p_IOI)),  # Scale to [0, 1]
    kn_p_ncounts = (p_ncounts - min(p_ncounts)) / (max(p_ncounts) - min(p_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(clustering_data1$kn_p_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_p_dt_LZ:", non_finite_count, "\n")

kmeans_data <- clustering_data1[,c("kn_p_LZ", "kn_p_dt_LZ", "kn_p_IOI", "kn_p_ncounts")]


k <- 3
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
cluster_labels <- kmeans_result$cluster


# Add cluster labels to your original dataset
clustering_data1$cluster <- factor(cluster_labels)
cluster_centers1 <- kmeans_result$centers
print(cluster_centers1)

clustering_data1 <- clustering_data1 %>%
  mutate(cluster = case_when(
    cluster == 1 ~ "3",
    cluster == 2 ~ "1",
    cluster == 3 ~ "2",
    # Add more cases as needed
    TRUE ~ as.character(cluster)  # Keep other values unchanged
  ))


#### CLustering data 2
clustering_data2 <- data2[, c("p_LZ", "p_dt_LZ", "p_IOI", "p_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Baile_Level', 'Name', 'Palo', 'Artist', 'Abs_Av', 'Perf_Av', 'Pair', 'Music_mode', 'number')]

clustering_data2 <- na.omit(clustering_data2)
#scaled_data <- scale(clustering_data2[,c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts")])


# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
clustering_data2 <- clustering_data2 %>%
  group_by(Participant) %>%
  mutate(
    kn_p_LZ = (p_LZ - min(p_LZ)) / (max(p_LZ) - min(p_LZ)),  # Scale to [0, 1]
    kn_p_dt_LZ = ((p_dt_LZ - min(p_dt_LZ)) / (max(p_dt_LZ) - min(p_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_p_IOI = (p_IOI - min(p_IOI)) / (max(p_IOI) - min(p_IOI)),  # Scale to [0, 1]
    kn_p_ncounts = (p_ncounts - min(p_ncounts)) / (max(p_ncounts) - min(p_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(clustering_data2$kn_p_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_p_dt_LZ:", non_finite_count, "\n")

kmeans_data <- clustering_data2[,c("kn_p_LZ", "kn_p_dt_LZ", "kn_p_IOI", "kn_p_ncounts")]


k <- 3
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
cluster_labels <- kmeans_result$cluster


# Add cluster labels to your original dataset
clustering_data2$cluster <- factor(cluster_labels)
cluster_centers2 <- kmeans_result$centers
print(cluster_centers2)

clustering_data2 <- clustering_data2 %>%
  mutate(cluster = case_when(
    cluster == 1 ~ "1",
    cluster == 2 ~ "3",
    cluster == 3 ~ "2",
    # Add more cases as needed
    TRUE ~ as.character(cluster)  # Keep other values unchanged
  ))


#### CLustering data 3
clustering_data3 <- data3[, c("p_LZ", "p_dt_LZ", "p_IOI", "p_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Baile_Level', 'Name', 'Palo', 'Artist', 'Abs_Av', 'Perf_Av', 'Pair', 'Music_mode', 'number')]

clustering_data3 <- na.omit(clustering_data3)
#scaled_data <- scale(clustering_data3[,c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts")])


# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
clustering_data3 <- clustering_data3 %>%
  group_by(Participant) %>%
  mutate(
    kn_p_LZ = (p_LZ - min(p_LZ)) / (max(p_LZ) - min(p_LZ)),  # Scale to [0, 1]
    kn_p_dt_LZ = ((p_dt_LZ - min(p_dt_LZ)) / (max(p_dt_LZ) - min(p_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_p_IOI = (p_IOI - min(p_IOI)) / (max(p_IOI) - min(p_IOI)),  # Scale to [0, 1]
    kn_p_ncounts = (p_ncounts - min(p_ncounts)) / (max(p_ncounts) - min(p_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(clustering_data3$kn_p_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_p_dt_LZ:", non_finite_count, "\n")

kmeans_data <- clustering_data3[,c("kn_p_LZ", "kn_p_dt_LZ", "kn_p_IOI", "kn_p_ncounts")]


k <- 3
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
cluster_labels <- kmeans_result$cluster


# Add cluster labels to your original dataset
clustering_data3$cluster <- factor(cluster_labels)
cluster_centers3 <- kmeans_result$centers
print(cluster_centers3)

clustering_data3 <- clustering_data3 %>%
  mutate(cluster = case_when(
    cluster == 1 ~ "2",
    cluster == 2 ~ "3",
    cluster == 3 ~ "1",
    # Add more cases as needed
    TRUE ~ as.character(cluster)  # Keep other values unchanged
  ))



### CREATE 3 PLOTS of CLUSTERS

plot1 <- ggplot(clustering_data1, aes(x = kn_p_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Manual annotations  - 2 audio sources - Ncounts ") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data1, aes(x = kn_p_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("k-means cluster  - 2 sources audio - Ncounts") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots




plot2 <- ggplot(clustering_data2, aes(x = kn_p_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Manual annotations  - 1 audio source - Ncounts ") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot21 <- ggplot(clustering_data2, aes(x = kn_p_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("k-means cluster  - 2 sources audio - Ncounts") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot2 + plot21
combined_plots



plot3 <- ggplot(clustering_data3, aes(x = kn_p_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Manual annotations  - all - Ncounts ") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot31 <- ggplot(clustering_data3, aes(x = kn_p_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("k-means cluster  - all - Ncounts") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot3 + plot31
combined_plots



combined_baile_plots <- plot1 + plot2 + plot3
combined_baile_plots

combined_cluster_plots <- plot11 + plot21 + plot31
combined_cluster_plots

#### Count number of assigned parts. 
merged_data <- merge(clustering_data1, clustering_data3, by = c("Name", "number"))
merged_data$cluster_match <- ifelse(merged_data$cluster.x == merged_data$cluster.y, "Match", "Not Match")

summary_table <- merged_data %>%
  group_by(cluster_match) %>%
  summarise(part_count = n())

print(summary_table)


merged_data <- merge(clustering_data2, clustering_data3, by = c("Name", "number"))
merged_data$cluster_match <- ifelse(merged_data$cluster.x == merged_data$cluster.y, "Match", "Not Match")

summary_table <- merged_data %>%
  group_by(cluster_match) %>%
  summarise(part_count = n())

print(summary_table)



### Check with Manual annotations

clustering_data1 <- clustering_data1 %>%
  mutate(Baile_Cluster = case_when(
    Baile_Level == "Z1" ~ "1",
    Baile_Level == "Z2" ~ "2",
    Baile_Level == "Z3" ~ "3",
    TRUE ~ Baile_Level  # For any other values, keep them as they are
  ))


# Create a new column "Match" that indicates whether "Baile_Cluster" and "cluster" match
clustering_data1 <- clustering_data1 %>%
  mutate(Match = ifelse(Baile_Cluster == as.character(cluster), "Match", "Not Match"))

# Count the number of similar and not similar values
count_result <- clustering_data1 %>%
  count(Match)

# Print the count result
print(count_result)



###

clustering_data2 <- clustering_data2 %>%
  mutate(Baile_Cluster = case_when(
    Baile_Level == "Z1" ~ "1",
    Baile_Level == "Z2" ~ "2",
    Baile_Level == "Z3" ~ "3",
    TRUE ~ Baile_Level  # For any other values, keep them as they are
  ))


# Create a new column "Match" that indicates whether "Baile_Cluster" and "cluster" match
clustering_data2 <- clustering_data2 %>%
  mutate(Match = ifelse(Baile_Cluster == as.character(cluster), "Match", "Not Match"))

# Count the number of similar and not similar values
count_result <- clustering_data2 %>%
  count(Match)

# Print the count result
print(count_result)


###

clustering_data3 <- clustering_data3 %>%
  mutate(Baile_Cluster = case_when(
    Baile_Level == "Z1" ~ "1",
    Baile_Level == "Z2" ~ "2",
    Baile_Level == "Z3" ~ "3",
    TRUE ~ Baile_Level  # For any other values, keep them as they are
  ))


# Create a new column "Match" that indicates whether "Baile_Cluster" and "cluster" match
clustering_data3 <- clustering_data3 %>%
  mutate(Match = ifelse(Baile_Cluster == as.character(cluster), "Match", "Not Match"))

# Count the number of similar and not similar values
count_result <- clustering_data3 %>%
  count(Match)

# Print the count result
print(count_result)


#########################################
########## GUITAR #######################
########################################

### Clusterinf DATA 1
clustering_data1 <- data1[, c("g_LZ", "g_dt_LZ", "g_IOI", "g_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Guitarra_Level', 'Name', 'Palo', 'Artist', 'Abs_Av', 'Perf_Av', 'Pair', 'Music_mode', 'number')]

clustering_data1 <- na.omit(clustering_data1)
#scaled_data <- scale(clustering_data1[,c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts")])


# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
clustering_data1 <- clustering_data1 %>%
  group_by(Participant) %>%
  mutate(
    kn_g_LZ = (g_LZ - min(g_LZ)) / (max(g_LZ) - min(g_LZ)),  # Scale to [0, 1]
    kn_g_dt_LZ = ((g_dt_LZ - min(g_dt_LZ)) / (max(g_dt_LZ) - min(g_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_g_IOI = (g_IOI - min(g_IOI)) / (max(g_IOI) - min(g_IOI)),  # Scale to [0, 1]
    kn_g_ncounts = (g_ncounts - min(g_ncounts)) / (max(g_ncounts) - min(g_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(clustering_data1$kn_g_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_g_dt_LZ:", non_finite_count, "\n")

kmeans_data <- clustering_data1[,c("kn_g_LZ", "kn_g_dt_LZ", "kn_g_IOI", "kn_g_ncounts")]


k <- 3
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
cluster_labels <- kmeans_result$cluster


# Add cluster labels to your original dataset
clustering_data1$cluster <- factor(cluster_labels)
cluster_centers1 <- kmeans_result$centers
print(cluster_centers1)

clustering_data1 <- clustering_data1 %>%
  mutate(cluster = case_when(
    cluster == 1 ~ "2",
    cluster == 2 ~ "1",
    cluster == 3 ~ "3",
    # Add more cases as needed
    TRUE ~ as.character(cluster)  # Keep other values unchanged
  ))


#### CLustering data 2
clustering_data2 <- data2[, c("g_LZ", "g_dt_LZ", "g_IOI", "g_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Guitarra_Level', 'Name', 'Palo', 'Artist', 'Abs_Av', 'Perf_Av', 'Pair', 'Music_mode', 'number')]

clustering_data2 <- na.omit(clustering_data2)
#scaled_data <- scale(clustering_data2[,c("norm_g_LZ", "norm_g_dt_LZ", "norm_g_IOI", "norm_g_ncounts")])


# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
clustering_data2 <- clustering_data2 %>%
  group_by(Participant) %>%
  mutate(
    kn_g_LZ = (g_LZ - min(g_LZ)) / (max(g_LZ) - min(g_LZ)),  # Scale to [0, 1]
    kn_g_dt_LZ = ((g_dt_LZ - min(g_dt_LZ)) / (max(g_dt_LZ) - min(g_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_g_IOI = (g_IOI - min(g_IOI)) / (max(g_IOI) - min(g_IOI)),  # Scale to [0, 1]
    kn_g_ncounts = (g_ncounts - min(g_ncounts)) / (max(g_ncounts) - min(g_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(clustering_data2$kn_g_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_g_dt_LZ:", non_finite_count, "\n")

kmeans_data <- clustering_data2[,c("kn_g_LZ", "kn_g_dt_LZ", "kn_g_IOI", "kn_g_ncounts")]


k <- 3
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
cluster_labels <- kmeans_result$cluster


# Add cluster labels to your original dataset
clustering_data2$cluster <- factor(cluster_labels)
cluster_centers2 <- kmeans_result$centers
print(cluster_centers2)

clustering_data2 <- clustering_data2 %>%
  mutate(cluster = case_when(
    cluster == 1 ~ "3",
    cluster == 2 ~ "2",
    cluster == 3 ~ "1",
    # Add more cases as needed
    TRUE ~ as.character(cluster)  # Keep other values unchanged
  ))


#### CLustering data 3
clustering_data3 <- data3[, c("g_LZ", "g_dt_LZ", "g_IOI", "g_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Guitarra_Level', 'Name', 'Palo', 'Artist', 'Abs_Av', 'Perf_Av', 'Pair', 'Music_mode', 'number')]

clustering_data3 <- na.omit(clustering_data3)
#scaled_data <- scale(clustering_data3[,c("norm_g_LZ", "norm_g_dt_LZ", "norm_g_IOI", "norm_g_ncounts")])


# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
clustering_data3 <- clustering_data3 %>%
  group_by(Participant) %>%
  mutate(
    kn_g_LZ = (g_LZ - min(g_LZ)) / (max(g_LZ) - min(g_LZ)),  # Scale to [0, 1]
    kn_g_dt_LZ = ((g_dt_LZ - min(g_dt_LZ)) / (max(g_dt_LZ) - min(g_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_g_IOI = (g_IOI - min(g_IOI)) / (max(g_IOI) - min(g_IOI)),  # Scale to [0, 1]
    kn_g_ncounts = (g_ncounts - min(g_ncounts)) / (max(g_ncounts) - min(g_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(clustering_data3$kn_g_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_g_dt_LZ:", non_finite_count, "\n")

kmeans_data <- clustering_data3[,c("kn_g_LZ", "kn_g_dt_LZ", "kn_g_IOI", "kn_g_ncounts")]


k <- 3
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
cluster_labels <- kmeans_result$cluster


# Add cluster labels to your original dataset
clustering_data3$cluster <- factor(cluster_labels)
cluster_centers3 <- kmeans_result$centers
print(cluster_centers3)

clustering_data3 <- clustering_data3 %>%
  mutate(cluster = case_when(
    cluster == 1 ~ "3",
    cluster == 2 ~ "1",
    cluster == 3 ~ "2",
    # Add more cases as needed
    TRUE ~ as.character(cluster)  # Keep other values unchanged
  ))



### CREATE 3 PLOTS of CLUSTERS

plot1 <- ggplot(clustering_data1, aes(x = kn_g_ncounts, fill = Guitarra_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_g_ncounts", y = "Frequency") +
  ggtitle("Manual annotations  - 2 audio sources - Ncounts ") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Guitarra_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data1, aes(x = kn_g_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_g_ncounts", y = "Frequency") +
  ggtitle("k-means cluster  - 2 sources audio - Ncounts") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots

#### Distribution plots




plot2 <- ggplot(clustering_data2, aes(x = kn_g_ncounts, fill = Guitarra_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_g_ncounts", y = "Frequency") +
  ggtitle("Manual annotations  - 1 audio source - Ncounts ") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Guitarra_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot21 <- ggplot(clustering_data2, aes(x = kn_g_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_g_ncounts", y = "Frequency") +
  ggtitle("k-means cluster  - 2 sources audio - Ncounts") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot2 + plot21
combined_plots



plot3 <- ggplot(clustering_data3, aes(x = kn_g_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_g_ncounts", y = "Frequency") +
  ggtitle("Manual annotations  - all - Ncounts ") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot31 <- ggplot(clustering_data3, aes(x = kn_g_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_g_ncounts", y = "Frequency") +
  ggtitle("k-means cluster  - all - Ncounts") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot3 + plot31
combined_plots



combined_baile_plots <- plot1 + plot2 + plot3
combined_baile_plots

combined_cluster_plots <- plot11 + plot21 + plot31
combined_cluster_plots



### Check with Manual annotations

clustering_data1 <- clustering_data1 %>%
  mutate(Baile_Cluster = case_when(
    Guitarra_Level == "A1" ~ "3",
    Baile_Level == "A2" ~ "2",
    Baile_Level == "A3" ~ "1",
    TRUE ~ Baile_Level  # For any other values, keep them as they are
  ))


# Create a new column "Match" that indicates whether "Baile_Cluster" and "cluster" match
clustering_data1 <- clustering_data1 %>%
  mutate(Match = ifelse(Baile_Cluster == as.character(cluster), "Match", "Not Match"))

# Count the number of similar and not similar values
count_result <- clustering_data1 %>%
  count(Match)

# Print the count result
print(count_result)



###

clustering_data2 <- clustering_data2 %>%
  mutate(Guitar_Cluster = case_when(
    Guitarra_Level == "A1" ~ "1",
    Guitarra_Level == "A2" ~ "3",
    Guitarra_Level == "A3" ~ "2",
    TRUE ~ Guitarra_Level  # For any other values, keep them as they are
  ))


# Create a new column "Match" that indicates whether "Baile_Cluster" and "cluster" match
clustering_data2 <- clustering_data2 %>%
  mutate(Match = ifelse(Guitar_Cluster == as.character(cluster), "Match", "Not Match"))

# Count the number of similar and not similar values
count_result <- clustering_data2 %>%
  count(Match)

# Print the count result
print(count_result)


###

clustering_data3 <- clustering_data3 %>%
  mutate(Baile_Cluster = case_when(
    Baile_Level == "Z1" ~ "1",
    Baile_Level == "Z2" ~ "2",
    Baile_Level == "Z3" ~ "3",
    TRUE ~ Baile_Level  # For any other values, keep them as they are
  ))


# Create a new column "Match" that indicates whether "Baile_Cluster" and "cluster" match
clustering_data3 <- clustering_data3 %>%
  mutate(Match = ifelse(Baile_Cluster == as.character(cluster), "Match", "Not Match"))

# Count the number of similar and not similar values
count_result <- clustering_data3 %>%
  count(Match)

# Print the count result
print(count_result)







#### Probability Density Plots ####

data11 <- clustering_data1 %>%
  filter(Guitarra_Level == 'A1')
data11 <- na.omit(data11$kn_g_ncounts)

#filtered_data <- na.omit(filtered_data$)

data21 <- clustering_data1 %>%
  filter(cluster == "3")
data21 <- na.omit(data21$kn_g_ncounts)

# Perform kernel density estimation (KDE) for data1
density_data11 <- density(data11)
# Perform KDE for data2
density_data21 <- density(data21)




data12 <- clustering_data1 %>%
  filter(Guitarra_Level == 'A2')
data12 <- na.omit(data12$kn_g_ncounts)

#filtered_data <- na.omit(filtered_data$)

data22 <- clustering_data1 %>%
  filter(cluster == "2")
data22 <- na.omit(data22$kn_g_ncounts)

# Perform kernel density estimation (KDE) for data1
density_data12 <- density(data12)
# Perform KDE for data2
density_data22 <- density(data22)



data13 <- clustering_data1 %>%
  filter(Guitarra_Level == 'A3')
data13 <- na.omit(data13$kn_g_ncounts)

#filtered_data <- na.omit(filtered_data$)

data23 <- clustering_data1%>%
  filter(cluster == "1")
data23 <- na.omit(data23$kn_g_ncounts)

# Perform kernel density estimation (KDE) for data1
density_data13 <- density(data13)
# Perform KDE for data2
density_data23 <- density(data23)




# Set up a 1x3 grid for the plots
par(mfrow = c(1, 3))

# Plot 1
plot(density_data11, main = "KDE for Z1 / cluster 1", xlim = c(0, 1), ylim = c(0, 10)) 
lines(density_data21$x, density_data21$y, col = "red")

# Plot 2
plot(density_data12, main = "KDE for Z2 / cluster 2", xlim = c(0, 1), ylim = c(0, 10)) 
lines(density_data22$x, density_data22$y, col = "red")

# Plot 3
plot(density_data13, main = "KDE for Z3 / cluster 3", xlim = c(0, 1), ylim = c(0, 10)) 
lines(density_data23$x, density_data23$y, col = "red")

# Reset the plotting parameters
par(mfrow = c(1, 1))



################################
########## 9 clusters #########
################################


# First determine how many groups]
clustering_data1 <- data1[, c("Guitarra_Level","g_LZ", "g_dt_LZ", "g_IOI", "g_ncounts","p_LZ", "p_dt_LZ", "p_IOI", "p_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Baile_Level', 'Name', 'Palo', 'Artist', 'Abs_Av', 'Perf_Av', 'Pair', 'Music_mode', 'number')]

clustering_data1 <- na.omit(clustering_data1)
#scaled_data <- scale(clustering_data1[,c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts")])



clustering_data1 <- clustering_data1 %>%
  mutate(Combined_Category = paste(Baile_Level, Guitarra_Level, sep = "_"))

# Count the occurrences of each combined category
count_result <- clustering_data1 %>%
  count(Combined_Category)

# Print the count result
print(count_result)





# Group your data by participant (assuming you have a participant identifier, e.g., "Participant_ID")
clustering_data1 <- clustering_data1 %>%
  group_by(Participant) %>%
  mutate(
    kn_p_LZ = (p_LZ - min(p_LZ)) / (max(p_LZ) - min(p_LZ)),  # Scale to [0, 1]
    kn_p_dt_LZ = ((p_dt_LZ - min(p_dt_LZ)) / (max(p_dt_LZ) - min(p_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_p_IOI = (p_IOI - min(p_IOI)) / (max(p_IOI) - min(p_IOI)),  # Scale to [0, 1]
    kn_p_ncounts = (p_ncounts - min(p_ncounts)) / (max(p_ncounts) - min(p_ncounts)),  # Scale to [0, 1]
    
    kn_g_LZ = (g_LZ - min(g_LZ)) / (max(g_LZ) - min(g_LZ)),  # Scale to [0, 1]
    kn_g_dt_LZ = ((g_dt_LZ - min(g_dt_LZ)) / (max(g_dt_LZ) - min(g_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_g_IOI = (g_IOI - min(g_IOI)) / (max(g_IOI) - min(g_IOI)),  # Scale to [0, 1]
    kn_g_ncounts = (g_ncounts - min(g_ncounts)) / (max(g_ncounts) - min(g_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping


non_finite_count <- sum(!is.finite(clustering_data1$kn_p_dt_LZ))
# Print the result
cat("Number of non-finite values in kn_p_dt_LZ:", non_finite_count, "\n")

kmeans_data <- clustering_data1[,c("kn_p_LZ", "kn_p_dt_LZ", "kn_p_IOI", "kn_p_ncounts", "kn_g_LZ", "kn_g_dt_LZ", "kn_g_IOI", "kn_g_ncounts")]


k <- 9
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
cluster_labels <- kmeans_result$cluster


# Add cluster labels to your original dataset
clustering_data1$cluster <- factor(cluster_labels)
cluster_centers1 <- kmeans_result$centers
print(cluster_centers1)

clustering_data1 <- clustering_data1 %>%
  mutate(cluster = case_when(
    cluster == 1 ~ "3",
    cluster == 2 ~ "1",
    cluster == 3 ~ "2",
    # Add more cases as needed
    TRUE ~ as.character(cluster)  # Keep other values unchanged
  ))



