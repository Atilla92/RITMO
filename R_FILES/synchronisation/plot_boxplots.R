

#Normalize dataset

# Load the required package for normalization
library(bestNormalize)

# Read the CSV file
data_raw <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/14042025_all_experiments_drums_guitar_zd_energy.csv')


# Recode dance mode labels
data_raw$Dance_mode <- factor(data_raw$Dance_mode, 
                              levels = c("D6", "D5", "D1"),
                              labels = c("Fixed", "Mixed", "Improvised"))

data_raw$Music_mode <- factor(data_raw$Music_mode, 
                              levels = c("M6", "M5", "M1"),
                              labels = c("Fixed", "Mixed", "Improvised"))

data_raw$Palo <- factor(data_raw$Palo, 
                        levels = c("R1", "R2"),
                        labels = c("Tangos", "Solea"))

# Filter data for Participant 'P'
data_P <- data_raw[data_raw$Artist == "P", ]

# Normalize Potential Energy for 'P'
pe_norm_P <- bestNormalize(data_P$p_PE_wholebody, allow_orderNorm = FALSE)
print("Best normalization method for Potential Energy (P):")
print(pe_norm_P$chosen_transform)
print("Method used (P):")
print(class(pe_norm_P$chosen_transform)[1])
print(pe_norm_P$norm_stats)

# Normalize Kinetic Energy for 'P'
ke_norm_P <- bestNormalize(data_P$p_KE_wholebody, allow_orderNorm = FALSE)
print("Best normalization method for Kinetic Energy (P):")
print(ke_norm_P$chosen_transform)
print("Method used (P):")
print(class(ke_norm_P$chosen_transform)[1])
print(ke_norm_P$norm_stats)

# Add normalized columns for 'P'
data_P$PE_wholebody_norm <- predict(pe_norm_P)
data_P$KE_wholebody_norm <- predict(ke_norm_P)

# Filter data for Participant 'G'
data_G <- data_raw[data_raw$Artist == "G", ]

# Normalize Potential Energy for 'G'
pe_norm_G <- bestNormalize(data_G$g_PE_wholebody, allow_orderNorm = FALSE)
print("Best normalization method for Potential Energy (G):")
print(pe_norm_G$chosen_transform)
print("Method used (G):")
print(class(pe_norm_G$chosen_transform)[1])
print(pe_norm_G$norm_stats)

# Normalize Kinetic Energy for 'G'
ke_norm_G <- bestNormalize(data_G$g_KE_wholebody, allow_orderNorm = FALSE)
print("Best normalization method for Kinetic Energy (G):")
print(ke_norm_G$chosen_transform)
print("Method used (G):")
print(class(ke_norm_G$chosen_transform)[1])
print(ke_norm_G$norm_stats)

# Add normalized columns for 'G'
data_G$PE_wholebody_norm <- predict(pe_norm_G)
data_G$KE_wholebody_norm <- predict(ke_norm_G)

# Merge the two datasets together
combined_data <- rbind(data_P, data_G)

# Optionally, inspect the combined dataset
print(head(combined_data))




# If you'd like to plot histograms for the combined dataset
par(mfrow=c(2,2))
hist(data_P$p_PE_wholebody, main="Original PE Distribution (P)", xlab="PE")
hist(data_P$PE_wholebody_norm, main="Normalized PE Distribution (P)", xlab="Normalized PE")
hist(data_G$g_PE_wholebody, main="Original PE Distribution (G)", xlab="PE") 
hist(data_G$PE_wholebody_norm, main="Normalized PE Distribution (G)", xlab="Normalized PE")







# Create boxplot for Imp_subj by Dance_Mode and Artist
imp_plot <- ggplot(data_raw, aes(x=Dance_mode, y=Imp_subj, fill=Artist)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Dance Mode", y="Improvisation Rating", title="Improvisation Ratings by Dance Mode and Artist")

# Create boxplot for Flow_subj by Dance_Mode and Artist  
flow_plot <- ggplot(data_raw, aes(x=Dance_mode, y=Flow_subj, fill=Artist)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Dance Mode", y="Flow Rating", title="Flow Ratings by Dance Mode and Artist")




# Create boxplot for Flow_subj by Dance_Mode and Artist  
flow_plot <- ggplot(data_raw, aes(x=Dance_mode, y=Flow_subj, fill=Artist)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Dance Mode", y="Flow Rating", title="Flow Ratings by Dance Mode and Artist")


# Filter data for dancers (Artist == P)
dancer_data <- subset(data_raw, Artist == "P")

# Create boxplots for dancer kinetic and potential energy
dancer_ke_plot <- ggplot(data_P, aes(x=Dance_mode, y=KE_wholebody_norm, fill = Palo)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18)) +
  labs(x="Dance Mode", y="Kinetic Energy", title="Dancer Kinetic Energy by Dance Mode")

print(dancer_ke_plot)

dancer_pe_plot <- ggplot(data_P, aes(x=Dance_mode, y=PE_wholebody_norm, fill= Palo)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18)) +
  labs(x="Dance Mode", y="Potential Energy", title="Dancer Potential Energy by Dance Mode")


print(dancer_pe_plot)

p_imp_plot_2 <- ggplot(dancer_data, aes(x=Dance_mode, y=Imp_subj, fill=Dance_Imp)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Baile Level", y="Improvisation Rating", title="Improvisation Ratings by Baile Level")

print(p_imp_plot_2)


dancer_pe_plot <- ggplot(dancer_data, aes(x=Dance_mode, y=p_PE_wholebody, fill= Palo)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18)) +
  labs(x="Dance Mode", y="Potential Energy", title="Dancer Potential Energy by Dance Mode")



p_imp_plot_3 <- ggplot(dancer_data, aes(x=Dance_Imp, y=Imp_subj, fill = Baile_Level)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Baile Level", y="Improvisation Rating", title="Improvisation Ratings by Baile Level")

print(p_imp_plot_3)

p_flow_plot_3 <- ggplot(dancer_data, aes(x=Dance_Imp, y=Flow_subj, fill = Baile_Level)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Baile Level", y="Flow Rating", title="Flow Ratings by Baile Level")

print(p_flow_plot_3)



p_flow_plot_2 <- ggplot(dancer_data, aes(x=Dance_mode, y=Flow_subj, fill=Dance_Imp)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Dance Mode", y="Flow Rating", title="Flow Ratings by Dance Mode and Artist")

print(p_flow_plot_2)




p_PE_plot_3 <- ggplot(data_P, aes(x=Dance_Imp, y= PE_wholebody_norm, fill=Baile_Level)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Dance Mode", y="PE", title="PE Dancer")

print(p_PE_plot_3)


p_PE_plot_3 <- ggplot(data_P, aes(x=Dance_Imp, y= KE_wholebody_norm, fill=Palo)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Dance Mode", y="KE", title="KE Dancer")

print(p_PE_plot_3)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_KE_plot_DanceMode_Palo.png",width = 6, height = 3, p_PE_plot_3)

###### GUITARIST ###### 
# Filter data for guitarists (Artist == G)
guitarist_data <- subset(data_raw, Artist == "G")

# Create boxplots for guitarist kinetic and potential energy
guitarist_ke_plot <- ggplot(guitarist_data, aes(x=Dance_mode, y=g_KE_wholebody)) +
  geom_boxplot() +
  facet_wrap(~Palo, labeller = labeller(Palo = c("R1" = "Tangos", "R2" = "Solea"))) +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18)) +
  labs(x="Dance Mode", y="Kinetic Energy", title="Guitarist Kinetic Energy by Dance Mode")

guitarist_pe_plot <- ggplot(guitarist_data, aes(x=Dance_mode, y=g_PE_wholebody)) +
  geom_boxplot() +
  facet_wrap(~Palo, labeller = labeller(Palo = c("R1" = "Tangos", "R2" = "Solea"))) +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18)) +
  labs(x="Dance Mode", y="Potential Energy", title="Guitarist Potential Energy by Dance Mode")


g_imp_plot_3 <- ggplot(data_G, aes(x=Music_mode, y=Imp_subj, fill = Music_Imp)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Guitarra Level", y="Improvisation Rating", title="Improvisation Ratings by Guitarra Level")

print(g_imp_plot_3)

g_flow_plot_3 <- ggplot(data_G, aes(x=Music_mode, y=Flow_subj, fill = Music_Imp)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18),
        legend.text = element_text(size=16),
        legend.title = element_text(size=16)) +
  labs(x="Guitarra Level", y="Flow Rating", title="Flow Ratings by Guitarra Level")

print(g_flow_plot_3)


# Create boxplots for dancer kinetic and potential energy
guitarist_ke_plot <- ggplot(data_G, aes(x=Music_mode, y=KE_wholebody_norm, fill = Palo)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18)) +
  labs(x="Music Mode", y="Kinetic Energy", title="Guitarist Kinetic Energy by Music Mode")

print(guitarist_ke_plot)

guitarist_pe_plot <- ggplot(data_G, aes(x=Music_mode, y=PE_wholebody_norm, fill= Palo)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text = element_text(size=16),
        axis.title = element_text(size=16),
        plot.title = element_text(size=18)) +
  labs(x="Music Mode", y="Potential Energy", title="Guitarist Potential Energy by Music Mode")


print(guitarist_pe_plot)



# Save all plots as PNG files
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/improvisation_ratings.png", imp_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/flow_ratings.png", flow_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/dancer_ke.png", dancer_ke_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/dancer_pe.png", dancer_pe_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/guitarist_ke.png", guitarist_ke_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/guitarist_pe.png", guitarist_pe_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_improvisation_ratings_2.png", p_imp_plot_2)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_flow_ratings_2.png", p_flow_plot_2)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_improvisation_ratings_3.png", p_imp_plot_3)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_flow_ratings_3.png", p_flow_plot_3)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/g_improvisation_ratings_MusicMode_MusicIimp.png",width = 6, height = 3, g_imp_plot_3)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/g_flow_ratings_MusicMode_MusicImp.png",width = 6, height = 3,g_flow_plot_3)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_PE_plot_2.png",width = 6, height = 3, p_PE_plot_2)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_KE_plot_DanceMode_Palo.png",width = 6, height = 3, p_PE_plot_3)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/g_KE_plot_28042025.png",width = 6, height = 3, guitarist_ke_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/g_PE_plot_28042025.png",width = 6, height = 3, guitarist_pe_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_KE_plot_28042025.png",width = 6, height = 3, dancer_ke_plot)
ggsave("/Users/atillajv/CODE/RITMO/R_FILES/synchronisation/plots/p_PE_plot_28042025.png",width = 6, height = 3, dancer_pe_plot)




