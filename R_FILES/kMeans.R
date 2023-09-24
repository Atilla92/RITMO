library(ggplot2)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(dplyr)


data <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/22092023_ELAN_no_CDRS_onset_niels_1s.csv')
data <- data[grepl("P", data$Participant),] #only dancers

# ALl analysis
data$Dance_mode <- as.factor(data$Dance_mode)
data$Condition <- as.factor(data$Condition)
data$Condition <- relevel(data$Condition, "D6_M6")
data$Dance_mode <- factor(data$Dance_mode, levels = c("D6", 'D5', 'D1'))
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


# Subset data
subset_data <- subset(data, number == 0)

# Sanity Check
participant_name_counts <- subset_data %>%
  group_by(Participant) %>%
  summarise(Unique_Name_Count = n_distinct(Name))
print(participant_name_counts)

subsetdata_P <- subset_data[grepl("P", subset_data$Participant),] #only dancers


# Histogram
ggplot(data_P, aes(x = p_ncounts, fill = Condition)) +
  geom_histogram(binwidth = 10, position = "dodge") +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_fill_discrete(name = "Condition") +  # Customize legend title
  theme_minimal()


ggplot(data, aes(x = norm_p_ncounts, fill = Dance_mode)) +
  geom_histogram(binwidth = 0.05, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple")) +  # Define colors
  facet_wrap(~ Dance_mode, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


ggplot(data, aes(x = norm_p_LZ, fill = Dance_mode)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple")) +  # Define colors
  facet_wrap(~ Dance_mode, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()



ggplot(data, aes(x = norm_p_dt_LZ, fill = Condition)) +
  geom_histogram(binwidth = 0.04, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Condition, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()

ggplot(data, aes(x = norm_p_IOI, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


ggplot(data, aes(x = norm_p_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


ggplot(data, aes(x = norm_g_ncounts, fill = Guitarra_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Guitarra_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()

ggplot(data, aes(x = norm_g_dt_LZ, fill = Guitarra_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Guitarra_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()

ggplot(data, aes(x = g_ncounts, fill = Guitarra_Level)) +
  geom_histogram(binwidth = 5, position = "dodge", color = "gray", alpha = 0.9) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_fill_discrete(name = "Condition") +  # Customize legend title
  facet_wrap(~ Guitarra_Level, ncol = 1) +  # Create separate subplots by "Condition"
  theme_minimal()

ggplot(data, aes(x = p_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 5, position = "dodge", color = "gray", alpha = 0.9) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_fill_discrete(name = "Condition") +  # Customize legend title
  facet_wrap(~ Baile_Level, ncol = 1) +  # Create separate subplots by "Condition"
  theme_minimal()


#norm_p_LZ, norm_p_dt_LZ, norm_p_IOI, norm_p_ncounts
# Clustering data
clustering_data <- data[, c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts")]
clustering_data <- na.omit(clustering_data)
scaled_data <- scale(clustering_data)

k <- 3
kmeans_result <- kmeans(clustering_data, centers = k, nstart = 20)
#kmeans_result <- kmeans(scaled_data, centers = k, nstart = 20)
# Assign cluster labels to the original data
cluster_labels <- kmeans_result$cluster

# Add cluster labels to your original dataset
clustering_data$cluster <- factor(cluster_labels)
#data$cluster <- factor(cluster_labels)

# View the cluster centers
cluster_centers <- kmeans_result$centers
print(cluster_centers)


# Plot
library(rgl)
library(plotly)
# Create a 3D scatter plot
plot_ly(
  data = clustering_data,
  x = ~norm_p_LZ,
  y = ~norm_p_dt_LZ,
  z = ~norm_p_IOI,
  color = I(kmeans_result$cluster),
  type = "scatter3d",
  mode = "markers",
  marker = list(size = 5),
  colors = "Set1"  # You can change the color palette
) %>%
  layout(
    scene = list(
      xaxis = list(title = "norm_p_LZ"),
      yaxis = list(title = "norm_p_dt_LZ"),
      zaxis = list(title = "norm_p_IOI")
    ),
    margin = list(l = 0, r = 0, b = 0, t = 0)
  ) %>%
  add_markers() %>%
  config(displayModeBar = TRUE)  # Display the interactive mode bar



# Distribution of cluster labels data$cluster


plot1 <- ggplot(data, aes(x = norm_p_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = norm_p_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots


######
plot1 <- ggplot(data, aes(x = norm_p_IOI, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = norm_p_IOI, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots


####
plot1 <- ggplot(data, aes(x = norm_p_LZ, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = norm_p_LZ, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots

####

plot1 <- ggplot(data, aes(x = norm_p_dt_LZ, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = norm_p_dt_LZ, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots






# See how similar distribution plots are
library(transport)
library(emdist)
filtered_data <- data %>%
  filter(Baile_Level == 'Z3')

#filtered_data <- na.omit(filtered_data$)

filtered_clustering_data <- clustering_data %>%
  filter(cluster == 3)



ks_test_result <- ks.test(filtered_data$norm_p_ncounts, filtered_clustering_data$norm_p_ncounts)
ks_test_result
