# Load required package
library(bestNormalize)

# Read data
data_raw <- read.csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_07072023_095/14042025_all_experiments_drums_guitar_zd_energy.csv')

# First process dancers (Artist == "P")
dancer_data <- data_raw[data_raw$Artist == "P", ]

# Get unique participants
dancer_participants <- unique(dancer_data$Participant)

# Initialize normalized columns
dancer_data$p_PE_wholebody_norm <- NA
dancer_data$p_KE_wholebody_norm <- NA

# Normalize per participant
for(participant in dancer_participants) {
  participant_data <- dancer_data[dancer_data$Participant == participant,]
  
  # PE normalization
  pe_norm <- bestNormalize(participant_data$p_PE_wholebody, allow_orderNorm = FALSE)
  print(paste("Dancer", participant, "- Best PE normalization method:"))
  print(class(pe_norm$chosen_transform)[1])
  print(pe_norm$norm_stats)
  
  # KE normalization
  ke_norm <- bestNormalize(participant_data$p_KE_wholebody, allow_orderNorm = FALSE)
  print(paste("Dancer", participant, "- Best KE normalization method:"))
  print(class(ke_norm$chosen_transform)[1])
  print(ke_norm$norm_stats)
  
  # Store normalized values
  dancer_data$p_PE_wholebody_norm[dancer_data$Participant == participant] <- predict(pe_norm)
  dancer_data$p_KE_wholebody_norm[dancer_data$Participant == participant] <- predict(ke_norm)
  
  # Plot histograms for this participant
  par(mfrow=c(2,2))
  hist(participant_data$p_PE_wholebody, main=paste("Original PE -", participant), xlab="PE")
  hist(predict(pe_norm), main=paste("Normalized PE -", participant), xlab="Normalized PE")
  hist(participant_data$p_KE_wholebody, main=paste("Original KE -", participant), xlab="KE")
  hist(predict(ke_norm), main=paste("Normalized KE -", participant), xlab="Normalized KE")
}

# Now process guitarists (Artist == "G")
guitarist_data <- data_raw[data_raw$Artist == "G", ]

# Get unique participants
guitarist_participants <- unique(guitarist_data$Participant)

# Initialize normalized columns
guitarist_data$g_PE_wholebody_norm <- NA
guitarist_data$g_KE_wholebody_norm <- NA

# Normalize per participant
for(participant in guitarist_participants) {
  participant_data <- guitarist_data[guitarist_data$Participant == participant,]
  
  # PE normalization
  pe_norm <- bestNormalize(participant_data$g_PE_wholebody, allow_orderNorm = FALSE)
  print(paste("Guitarist", participant, "- Best PE normalization method:"))
  print(class(pe_norm$chosen_transform)[1])
  print(pe_norm$norm_stats)
  
  # KE normalization
  ke_norm <- bestNormalize(participant_data$g_KE_wholebody, allow_orderNorm = FALSE)
  print(paste("Guitarist", participant, "- Best KE normalization method:"))
  print(class(ke_norm$chosen_transform)[1])
  print(ke_norm$norm_stats)
  
  # Store normalized values
  guitarist_data$g_PE_wholebody_norm[guitarist_data$Participant == participant] <- predict(pe_norm)
  guitarist_data$g_KE_wholebody_norm[guitarist_data$Participant == participant] <- predict(ke_norm)
  
  # Plot histograms for this participant
  par(mfrow=c(2,2))
  hist(participant_data$g_PE_wholebody, main=paste("Original PE -", participant), xlab="PE")
  hist(predict(pe_norm), main=paste("Normalized PE -", participant), xlab="Normalized PE")
  hist(participant_data$g_KE_wholebody, main=paste("Original KE -", participant), xlab="KE")
  hist(predict(ke_norm), main=paste("Normalized KE -", participant), xlab="Normalized KE")
}
