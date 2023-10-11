import os
import torch
import torchaudio
from torch.utils.data import DataLoader, Dataset
from demucs import pretrained

# Define paths to the folders containing mixed music and isolated guitar tracks
mixed_music_folder = "/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO_2/ORIGINAL/"
guitar_tracks_folder = "/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO_2/GUITAR/"


# Define hyperparameters
batch_size = 8
num_epochs = 10
learning_rate = 0.001
segment_duration_ms = 10000  # Duration of each audio segment in milliseconds

# Define a custom dataset for loading mixed music and isolated guitar tracks
class CustomDataset(Dataset):
    def __init__(self, mixed_folder, guitar_folder):
        self.mixed_folder = mixed_folder
        self.guitar_folder = guitar_folder
        self.file_names = os.listdir(mixed_folder)

    def __len__(self):
        return len(self.file_names)

    def __getitem__(self, idx):
        mixed_audio, _ = torchaudio.load(os.path.join(self.mixed_folder, self.file_names[idx]))
        guitar_audio, _ = torchaudio.load(os.path.join(self.guitar_folder, self.file_names[idx]))
        return mixed_audio, guitar_audio

# Create data loaders for training
dataset = CustomDataset(mixed_music_folder, guitar_tracks_folder)
dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)

# Load the pre-trained htdemucs_62 model
pretrained_model = pretrained.get_model("htdemucs_6s")

# Set the model to source separation mode
model = pretrained_model


model.source_names = ["guitar"]

# Define loss function and optimizer
criterion = torch.nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

# Training loop
for epoch in range(num_epochs):
    for mixed_audio, target_audio in dataloader:
        optimizer.zero_grad()
        output_audio = model(mixed_audio)
        loss = criterion(output_audio, target_audio)
        loss.backward()
        optimizer.step()
        print(f"Epoch [{epoch + 1}/{num_epochs}], Loss: {loss.item()}")



# model.eval()

# # Define loss function and optimizer
# criterion = torch.nn.MSELoss()
# optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

# # Training loop
# for epoch in range(num_epochs):
#     for mixed_segments, target_segments in dataloader:
#         optimizer.zero_grad()
        
#         # Perform source separation on each segment
#         output_segments = []
#         for mixed_segment in mixed_segments:
#             separated_audio = model.separate(mixed_segment, targets=["guitar"])
#             output_segments.append(separated_audio)
        
#         # Calculate loss for each segment
#         loss = sum(criterion(output, target) for output, target in zip(output_segments, target_segments))
        
#         # Backpropagate and optimize
#         loss.backward()
#         optimizer.step()
        
#         print(f"Epoch [{epoch + 1}/{num_epochs}], Loss: {loss.item()}")

# Save the trained model
torch.save(model.state_dict(), "/Users/atillajv/CODE/RITMO/source_separation/trained_demucs_model.pth")
