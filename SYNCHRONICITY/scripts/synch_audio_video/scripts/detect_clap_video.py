import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import librosa
import soundfile as sf

# Set input directory path for videos
video_dir = '/Volumes/WHITE LOTUS/FlamencoProject/VIDEOS_SMALL/'

# Get list of all video files, excluding hidden files
video_files = [f for f in os.listdir(video_dir) if f.endswith('.mp4') and not f.startswith('._')]

# Initialize list to store results
results = []

def onclick(event):
    global clicked_x
    clicked_x = event.xdata
    plt.close()

# Process each video file
for video_file in video_files:
    print(f"\nProcessing {video_file}")
    
    # Load video and extract audio
    video_path = os.path.join(video_dir, video_file)
    audio_data, sr = librosa.load(video_path, sr=None, duration=30)
    
    # Create time array for first 30 seconds
    time = np.linspace(0, len(audio_data)/sr, len(audio_data))
    
    print(f"Sample rate: {sr}, Duration: {len(audio_data)/sr:.2f}s")
    
    # Plot audio waveform
    fig = plt.figure(figsize=(15,5))
    plt.plot(time, audio_data)
    plt.title(f"First 30s Audio Waveform - {video_file}\nClick on the peak you want to mark")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")
    plt.grid(True)
    
    # Connect click event
    fig.canvas.mpl_connect('button_press_event', onclick)
    plt.show()
    
    # Store results
    results.append({
        'filename': video_file.replace('.mp4', ''),
        'peak_time': clicked_x
    })

# Create and save dataframe
results_df = pd.DataFrame(results)
results_df.to_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/peak_times.csv', index=False)
print("\nResults saved to peak_times.csv")
