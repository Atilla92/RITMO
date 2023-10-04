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


ggplot(data, aes(x = p_ncounts, fill = Dance_mode)) +
  geom_histogram(binwidth = 1, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 100)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple")) +  # Define colors
  facet_wrap(~ Dance_mode, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


ggplot(data, aes(x = norm_p_LZ, fill = Dance_mode)) +
  geom_histogram(binwidth = 0.01, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple")) +  # Define colors
  facet_wrap(~ Dance_mode, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()

ggplot(data, aes(x = p_LZ, fill = Dance_mode)) +
  geom_histogram(binwidth = 0.001, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(min(data$p_LZ),  max(data$p_LZ))) +  # Set x-axis limits to [0, 1]
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
#clustering_data <- data[, c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts", 'Condition', 'Dance_mode', "Duration")]
clustering_data <- data[, c("p_LZ", "p_dt_LZ", "p_IOI", "p_ncounts", 'Condition', 'Dance_mode', "Duration", 'Participant', 'Baile_Level')]

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


data <- data %>%
  group_by(Participant) %>%
  mutate(
    kn_p_LZ = (p_LZ - min(p_LZ)) / (max(p_LZ) - min(p_LZ)),  # Scale to [0, 1]
    kn_p_dt_LZ = ((p_dt_LZ - min(p_dt_LZ)) / (max(p_dt_LZ) - min(p_dt_LZ))) - 0.5,  # Scale to [-0.5, 0.5]
    kn_p_IOI = (p_IOI - min(p_IOI)) / (max(p_IOI) - min(p_IOI)),  # Scale to [0, 1]
    kn_p_ncounts = (p_ncounts - min(p_ncounts)) / (max(p_ncounts) - min(p_ncounts))  # Scale to [0, 1]
  ) %>%
  ungroup()  # Remove grouping

non_finite_count <- sum(!is.finite(data$kn_p_IOI))
# Print the result
cat("Number of non-finite values in kn_p_IOI:", non_finite_count, "\n")


#kmeans_data <- clustering_data[,c("norm_p_LZ", "norm_p_dt_LZ", "norm_p_IOI", "norm_p_ncounts")]
#kmeans_data <- clustering_data[,c("p_LZ", "p_dt_LZ", "p_IOI", "p_ncounts")]
kmeans_data <- clustering_data[,c("kn_p_LZ", "kn_p_dt_LZ", "kn_p_IOI", "kn_p_ncounts")]


k <- 3
kmeans_result <- kmeans(kmeans_data, centers = k, nstart = 20)
#kmeans_result <- kmeans(scaled_data, centers = k, nstart = 20)
# Assign cluster labels to the original data
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

#data$cluster <- factor(cluster_labels)

# View the cluster centers





# Plot
library(rgl)
library(plotly)
# Create a 3D scatter plot
plot_ly(
  data = normalized_data,
  x = ~kn_p_LZ,
  y = ~kn_p_dt_LZ,
  z = ~kn_p_IOI,
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



### Non normalized data
plot1 <- ggplot(clustering_data, aes(x = p_ncounts, fill = Baile_Level)) +
  geom_histogram(binwidth = 1, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(min(data$p_ncounts),max(data$p_ncounts))) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = p_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 1, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of kn_p_ncounts by Condition") +
  scale_x_continuous(limits = c(min(data$p_ncounts),max(data$p_ncounts))) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()



combined_plots <- plot1 + plot11
combined_plots


######
# Count the number of non-finite values in clustering_data$kn_p_IOI


plot1 <- ggplot(clustering_data, aes(x = kn_p_IOI, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = kn_p_IOI, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()

combined_plots <- plot1 + plot11
combined_plots



plot1 <- ggplot(data, aes(x = p_IOI, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits =  c(min(data$p_IOI),max(data$p_IOI))) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = p_IOI, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(min(data$p_IOI),max(data$p_IOI))) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots


####
plot1 <- ggplot(clustering_data, aes(x = kn_p_LZ, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = kn_p_LZ, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()

combined_plots <- plot1 + plot11
combined_plots


plot1 <- ggplot(data, aes(x = p_LZ, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.001, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits =c(min(data$p_LZ),max(data$p_LZ))) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = p_LZ, fill = cluster)) +
  geom_histogram(binwidth = 0.001, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(min(data$p_LZ),max(data$p_LZ))) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots

####

plot1 <- ggplot(clustering_data, aes(x = kn_p_dt_LZ, fill = Baile_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Baile_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = kn_p_dt_LZ, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots





#### Run cluster for guitar
# Clustering data
clustering_data <- data[, c("norm_g_LZ", "norm_g_dt_LZ", "norm_g_IOI", "norm_g_ncounts")]
clustering_data <- na.omit(clustering_data)
#scaled_data <- scale(clustering_data)

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

plot1 <- ggplot(data, aes(x = norm_g_ncounts, fill = Guitarra_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Guitarra_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = norm_g_ncounts, fill = cluster)) +
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
plot1 <- ggplot(data, aes(x = norm_g_IOI, fill = Guitarra_Level)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ Guitarra_Level, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


plot11 <- ggplot(clustering_data, aes(x = norm_g_IOI, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge",  color = "gray" , alpha = 0.7) +
  labs(x = "norm_p_ncounts", y = "Frequency") +
  ggtitle("Distribution of norm_p_ncounts by Condition") +
  scale_x_continuous(limits = c(0, 1)) +  # Set x-axis limits to [0, 1]
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +  # Define colors
  facet_wrap(~ cluster, ncol = 1, scales = "free_y") +  # Create separate subplots by "condition"
  theme_minimal()


combined_plots <- plot1 + plot11
combined_plots




# See how similar distribution plots are
library(transport)
library(emdist)
data1 <- clustering_data %>%
  filter(Dance_mode == 'D6' & cluster == 1)
data1 <- na.omit(data1$kn_p_ncounts)

#filtered_data <- na.omit(filtered_data$)

data2 <- clustering_data %>%
  filter(Dance_mode == "D1" & cluster == 1)
data2 <- na.omit(data2$kn_p_ncounts)


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

data11 <- clustering_data %>%
  filter(Baile_Level == 'Z1')
data11 <- na.omit(data11$kn_p_dt_LZ)

#filtered_data <- na.omit(filtered_data$)

data21 <- clustering_data %>%
  filter(cluster == "1")
data21 <- na.omit(data21$kn_p_dt_LZ)

# Perform kernel density estimation (KDE) for data1
density_data11 <- density(data11)
# Perform KDE for data2
density_data21 <- density(data21)




data12 <- clustering_data %>%
  filter(Baile_Level == 'Z2')
data12 <- na.omit(data12$kn_p_dt_LZ)

#filtered_data <- na.omit(filtered_data$)

data22 <- clustering_data %>%
  filter(cluster == "2")
data22 <- na.omit(data22$kn_p_dt_LZ)

# Perform kernel density estimation (KDE) for data1
density_data12 <- density(data12)
# Perform KDE for data2
density_data22 <- density(data22)



data13 <- clustering_data %>%
  filter(Baile_Level == 'Z3')
data13 <- na.omit(data13$kn_p_dt_LZ)

#filtered_data <- na.omit(filtered_data$)

data23 <- clustering_data %>%
  filter(cluster == "3")
data23 <- na.omit(data23$kn_p_dt_LZ)

# Perform kernel density estimation (KDE) for data1
density_data13 <- density(data13)
# Perform KDE for data2
density_data23 <- density(data23)




# Set up a 1x3 grid for the plots
par(mfrow = c(1, 3))

# Plot 1
plot(density_data11, main = "KDE for Z1 / cluster 1", xlim = c(-0.5, 0.5), ylim = c(0, 10)) 
lines(density_data21$x, density_data21$y, col = "red")

# Plot 2
plot(density_data12, main = "KDE for Z2 / cluster 2", xlim = c(-0.5, 0.5), ylim = c(0, 10)) 
lines(density_data22$x, density_data22$y, col = "red")

# Plot 3
plot(density_data13, main = "KDE for Z3 / cluster 3", xlim = c(-0.5, 0.5), ylim = c(0, 10)) 
lines(density_data23$x, density_data23$y, col = "red")

# Reset the plotting parameters
par(mfrow = c(1, 1))


library(philentropy)


matrix_data <- rbind(density_data1$y, density_data2$y)

# Compute the Jenson-Shannon Divergence (JSD)
jsd_value <- JSD(matrix_data)


jsd_value <- JSD(matrix_data)
cat("Jensen-Shannon Divergence:", jsd_value, "\n")

percentage_similarity <- 100 * (1 - jsd_value)

# Print the percentage similarity
cat("Percentage Similarity:", percentage_similarity, "%\n")



plot11 <- ggplot(clustering_data, aes(x = norm_p_ncounts, fill = cluster)) +
  geom_histogram(binwidth = 0.02, position = "dodge", color = "gray", alpha = 0.7) +
  labs(x = "norm_p_dt_LZ", y = "Frequency") +
  ggtitle("Distribution of norm_p_dt_LZ by Cluster and Condition") +
  scale_x_continuous(limits = c(0, 1)) +
  scale_fill_manual(values = c("red", "blue", "green", "purple", "yellow")) +
  facet_grid(cluster ~ Dance_mode, scales = "free_y") +  # Group by cluster and Condition
  theme_minimal()

print(plot11)














