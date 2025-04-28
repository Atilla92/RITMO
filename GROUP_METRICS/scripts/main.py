

# In this script would like to important the wav files of dancer and guitarist and import the functions to estimate:
# Granger causality between the dancer and guitarist
# Spectral synchronization between the dancer and guitarist
# Mutual information between the dancer and guitarist.


# Comment 21.04.2025:
# They are now sort of aligned, should check in the future. 
# Downsample and filter, probably helps. Do next and save.
# Also estimate the mutual information at different time lags.


import json
import os
import pandas as pd
import numpy as np
import soundfile as sf
import matplotlib.pyplot as plt
# Step 1: important the wav files and clap times and check whether the same length of the two time series.





input_paths = json.load(open('input/input_paths.json'))
files = os.listdir(input_paths['input_audio_dancer'])
plot_on = False
guitar_adjustment = False
files_different_length = {
    'filename': [],
    'dancer_length': [],
    'guitarist_length': [],
    'length_difference': []
}

adjust_time_first_clap = False
for file in files:
    name = file.split('.')[0]
    print(name)
    dancer_wav = input_paths['input_audio_dancer'] + file
    guitarist_wav = input_paths['input_audio_guitar'] + file
    
    # Import wav files and sample rates using soundfile

    
    # Read wav fil
    # Read the clap time CSVs
    guitar_claps_df = pd.read_csv(input_paths['input_clap_times_guitar'])
    dancer_claps_df = pd.read_csv(input_paths['input_clap_times_video'])
    p13_clap_times_df = pd.read_csv(input_paths['input_clap_times_video_P13'])

    if name.split('_')[-1] == 'T2':
        continue

    if adjust_time_first_clap:
        if name in p13_clap_times_df['filename'].values:
            guitar_clap_time = p13_clap_times_df.loc[p13_clap_times_df['filename'] == name, 'peak_time'].values[0]
            dancer_clap_time = p13_clap_times_df.loc[p13_clap_times_df['filename'] == name, 'peak_time'].values[0]
        elif name in guitar_claps_df['filename'].values:
            guitar_adjustment = True
            guitar_clap_time = guitar_claps_df.loc[guitar_claps_df['filename'] == name, 'peak_time'].values[0]
            dancer_clap_time = dancer_claps_df.loc[dancer_claps_df['filename'] == name, 'peak_time'].values[0]
        else:
            dancer_clap_time = dancer_claps_df.loc[dancer_claps_df['filename'] == name, 'peak_time'].values[0]
            guitar_clap_time = dancer_clap_time

    # Clear DataFrames from memory
        del guitar_claps_df, dancer_claps_df, p13_clap_times_df
    
    # Read ELAN annotation file for this recording
    elan_path = input_paths['input_ELAN'] + file.strip('.wav') + '.csv'
    if os.path.exists(elan_path):
        elan_df = pd.read_csv(elan_path, sep=';')
        t_ELAN_start = elan_df['Begin Time - ss.msec'].iloc[0]
        t_ELAN_end = elan_df['End Time - ss.msec'].iloc[-1]
        del elan_df
    else:
        print(f"No ELAN file found for {elan_path}")
        continue

    # Read and process audio files one at a time
    dancer_audio, dancer_sr = sf.read(dancer_wav)
    t_start_dancer = np.floor((t_ELAN_start)* dancer_sr)
    t_end_dancer = np.floor((t_ELAN_end)* dancer_sr)
    dancer_audio = dancer_audio.flatten()[int(t_start_dancer):int(t_end_dancer)]

    guitarist_audio, guitarist_sr = sf.read(guitarist_wav)
    print(guitarist_audio.shape)
    t_start_guitar = np.floor((t_ELAN_start)* guitarist_sr)
    t_end_guitar = np.floor((t_ELAN_end)* guitarist_sr)
    guitarist_audio = guitarist_audio.flatten()[int(t_start_guitar):int(t_end_guitar)]

    # Check if the two audio signals have the same length
    if np.divide(len(dancer_audio),dancer_sr) != np.divide(len(guitarist_audio),guitarist_sr):
        print(f"Warning: The length of dancer_audio ({len(np.divide(dancer_audio,dancer_sr))}) and guitarist_audio ({len(np.divide(guitarist_audio,guitarist_sr))}) are different.")
        print(np.divide(len(dancer_audio),dancer_sr), np.divide(len(guitarist_audio),guitarist_sr))
        files_different_length['filename'].append(name)
        files_different_length['dancer_length'].append(np.divide(len(dancer_audio),dancer_sr))
        files_different_length['guitarist_length'].append(np.divide(len(guitarist_audio),guitarist_sr))
        files_different_length['length_difference'].append(np.divide(len(dancer_audio),dancer_sr) - np.divide(len(guitarist_audio),guitarist_sr))
    
    if plot_on and not os.path.exists(input_paths['output_wav_plots'] + "soundfiles_dancer_guitar_"+ name + '.png'):
        fig, axes = plt.subplots(2,1)
        
        # Create time arrays and plot in chunks to save memory
        chunk_size = 100000  # Adjust chunk size based on available memory
        
        for i in range(0, len(dancer_audio), chunk_size):
            chunk_end = min(i + chunk_size, len(dancer_audio))
            t_chunk = np.arange(i/dancer_sr, chunk_end/dancer_sr, 1/dancer_sr)[:chunk_end-i]
            axes[0].plot(t_chunk, dancer_audio[i:chunk_end])
            
        for i in range(0, len(guitarist_audio), chunk_size):
            chunk_end = min(i + chunk_size, len(guitarist_audio))
            t_chunk = np.arange(i/guitarist_sr, chunk_end/guitarist_sr, 1/guitarist_sr)[:chunk_end-i]
            axes[1].plot(t_chunk, guitarist_audio[i:chunk_end])
            
        axes[0].set_title('Dancer')
        axes[1].set_title('Guitarist')  
        axes[1].set_xlabel('Time (s)')
        axes[0].set_ylabel('Amplitude')
        axes[1].set_ylabel('Amplitude')
        fig.suptitle(name)
        fig.savefig(input_paths['output_wav_plots'] + "soundfiles_dancer_guitar_"+ name + '.png')
        plt.close(fig)  # Close figure to free memory
        
    # Clear audio data from memory
    del dancer_audio, guitarist_audio

if len(files_different_length['filename']) > 0:
    files_different_length_df = pd.DataFrame(files_different_length)
    files_different_length_df.to_csv(input_paths['output_folder'] + 'files_different_length.csv', index=False)

# def import_wav_files(inputfile, input_paths):
#     # Import the wav files of dancer and guitarist
#     dancer_wav = input_paths['input_audio_dancer']
#     guitarist_wav = input_paths['input_audio_guitar']
#     clap_times_guitar = input_paths['input_clap_times_guitar']

#     clap_times_dancer = input_paths['input_clap_times_video']
#     # Check whether the same length of the two time series.
#     if dancer_wav.shape != guitarist_wav.shape:
#         raise ValueError('The length of the two time series is not the same.')