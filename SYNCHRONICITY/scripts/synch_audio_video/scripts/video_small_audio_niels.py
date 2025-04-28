import os
import pandas as pd
import librosa

# Read the video comparison CSV
video_df = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/video_small_video_front/video_front_video_small_combined.csv')
output_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/video_small_audio/audio_video_comparison_drums_part_2.csv'

# Get list of audio files
audio_dir = '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO_2/DRUMS/'
audio_files = []

# Only include files that exist in audio_dir
for filename in video_df['filename']:
    audio_file = filename.replace('.mp4', '.wav')
    audio_path = os.path.join(audio_dir, audio_file)
    if os.path.exists(audio_path) and not audio_file.startswith('._'):
        audio_files.append(filename.replace('.mp4', ''))

# Create new dataframe starting with audio filenames
results_df = pd.DataFrame({'filename': [f + '.mp4' for f in audio_files]})

# Check if audio files are present in video df
results_df['both_present'] = results_df['filename'].isin(video_df['filename'])

# Get audio lengths
audio_lengths = []
for audio_file in audio_files:
    audio_path = os.path.join(audio_dir, audio_file + '.wav')
    duration = librosa.get_duration(path=audio_path)
    audio_lengths.append(duration)
    
results_df['audio_length'] = audio_lengths

# Merge with video data
results_df = results_df.merge(video_df[['filename', 'length_video_front', 'length_video_small']], 
                            on='filename', how='left')

# Compare lengths
results_df['matches_video_front'] = abs(results_df['audio_length'] - results_df['length_video_front']) < 2.5
results_df['matches_video_small'] = abs(results_df['audio_length'] - results_df['length_video_small']) < 2.5

# Save results
results_df.to_csv(output_path, index=False)
