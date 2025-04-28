import os
import pandas as pd
import cv2
from moviepy.editor import VideoFileClip

# Input directories for the two video folders
folder1 = '/Volumes/WHITE LOTUS/FlamencoProject/F_Andalucia/07062023/Edited/Solea_R2/GoProFront/'  # Update with actual path
folder2 = '/Volumes/WHITE LOTUS/FlamencoProject/VIDEOS_SMALL/'  # Update with actual path
output_folder = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/video_small_video_front/'

# Get list of video files from folder1, ignoring hidden files
video_files = [f for f in os.listdir(folder1) if f.endswith(('.mp4', '.avi', '.mov')) and not f.startswith('._')]

# Initialize lists to store results
filenames = []
lengths1 = []
lengths2 = []
is_same_length = []
filesizes1 = []
filesizes2 = []
missing_in_folder2 = []

# Process each video file
for video_file in video_files:
    # Get paths for both folders
    path1 = os.path.join(folder1, video_file)
    path2 = os.path.join(folder2, video_file)
    
    # Check if corresponding file exists in folder2
    if os.path.exists(path2):
        # Get video lengths using cv2 (faster than loading full video)
        cap1 = cv2.VideoCapture(path1)
        length1 = int(cap1.get(cv2.CAP_PROP_FRAME_COUNT) / cap1.get(cv2.CAP_PROP_FPS))
        cap1.release()
        
        cap2 = cv2.VideoCapture(path2)
        length2 = int(cap2.get(cv2.CAP_PROP_FRAME_COUNT) / cap2.get(cv2.CAP_PROP_FPS))
        cap2.release()
        
        # Get file sizes in MB
        filesize1 = round(os.path.getsize(path1) / (1024 * 1024), 2)  # Convert bytes to MB
        filesize2 = round(os.path.getsize(path2) / (1024 * 1024), 2)  # Convert bytes to MB
        
        # Store results
        filenames.append(video_file)
        lengths1.append(length1)
        lengths2.append(length2)
        is_same_length.append(length1 == length2)
        filesizes1.append(filesize1)
        filesizes2.append(filesize2)
        missing_in_folder2.append(False)
    else:
        # Store results for missing files
        filenames.append(video_file)
        lengths1.append(None)
        lengths2.append(None)
        is_same_length.append(None)
        filesizes1.append(round(os.path.getsize(path1) / (1024 * 1024), 2))
        filesizes2.append(None)
        missing_in_folder2.append(True)

# Create DataFrame with results
results_df = pd.DataFrame({
    'filename': filenames,
    'length_video_front': lengths1,
    'length_video_small': lengths2,
    'same_length': is_same_length,
    'filesize_video_front_MB': filesizes1,
    'filesize_video_small_MB': filesizes2,
    'missing_in_folder2': missing_in_folder2
})

# Display results
print("\nResults:")
print(results_df)

# Save results to CSV
results_df.to_csv(output_folder + 'P11_R2.csv', index=False)
