import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import librosa
import soundfile as sf

# Set input directory path for audio files
audio_dir = '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO_2/ORIGINAL/'

# List of specific audio files to process
# audio_files = [
#     'P11_D1_G6_M1_R1_T1.wav',
#     'P9_D1_G4_M1_R1_T1.wav',
#     'P9_D1_G4_M6_R1_T1.wav',
#     'P9_D6_G4_M6_R1_T1.wav',
#     'P8_D6_G4_M6_R1_T1.wav'
# ]

audio_files = [
    'P13_D6_G5_M6_R1_T1.wav',
    'P13_D5_G5_M6_R1_T1.wav',
    'P13_D1_G5_M6_R1_T1.wav',
    'P13_D5_G5_M5_R1_T1.wav',
    'P13_D1_G5_M1_R1_T1.wav',
    'P13_D6_G5_M6_R2_T1.wav',
    'P13_D5_G5_M6_R2_T1.wav',
    'P13_D1_G5_M6_R2_T1.wav',
    'P13_D5_G5_M5_R2_T1.wav',
    'P13_D1_G5_M1_R2_T1.wav',
]

# Initialize list to store results
results = []

def onclick(event):
    global clicked_x
    clicked_x = event.xdata
    plt.close()

# Process each audio file
for audio_file in audio_files:
    print(f"\nProcessing {audio_file}")
    
    # Load audio file
    audio_path = os.path.join(audio_dir, audio_file)
    audio_data, sr = librosa.load(audio_path, sr=None, duration=60)
    
    # Create time array for first 30 seconds
    time = np.linspace(0, len(audio_data)/sr, len(audio_data))
    
    print(f"Sample rate: {sr}, Duration: {len(audio_data)/sr:.2f}s")
    
    # Plot audio waveform
    fig = plt.figure(figsize=(15,5))
    plt.plot(time, audio_data)
    plt.title(f"First 30s Audio Waveform - {audio_file}\nClick on the peak you want to mark")
    plt.xlabel("Time (s)")
    plt.ylabel("Amplitude")
    plt.grid(True)
    
    # Connect click event
    fig.canvas.mpl_connect('button_press_event', onclick)
    plt.show()
    
    # Store results
    results.append({
        'filename': audio_file.replace('.wav', ''),
        'peak_time': clicked_x
    })

# Create and save dataframe
results_df = pd.DataFrame(results)
results_df.to_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/peak_times_audio_P13.csv', index=False)
print("\nResults saved to peak_times.csv")
