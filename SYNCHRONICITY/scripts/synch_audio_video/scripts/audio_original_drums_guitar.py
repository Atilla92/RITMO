import os
import pandas as pd
import librosa

# Define folders to check
output_folder = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/audio_original_drums_guitar/'

folders = [
    '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/ORIGINAL/',
    '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO_2/DRUMS/', 
    '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO_2/GUITAR/'
]

# Get list of files from first folder, excluding hidden files
files = [f for f in os.listdir(folders[1]) if not f.startswith('._') and os.path.isfile(os.path.join(folders[1], f))]

results = []
for file in files:
    # Check if file exists in all folders
    exists_all = all(os.path.exists(os.path.join(folder, file)) for folder in folders)
    
    if exists_all:
        # Get lengths from each folder
        lengths = []
        for folder in folders:
            audio_path = os.path.join(folder, file)
            y, sr = librosa.load(audio_path)
            length = librosa.get_duration(y=y, sr=sr)
            lengths.append(length)
            
        # Check if lengths match between pairs
        matches_1_2 = abs(lengths[0] - lengths[1]) < 1  # Using 0.1s tolerance
        matches_2_3 = abs(lengths[1] - lengths[2]) < 1
        matches_3_1 = abs(lengths[2] - lengths[0]) < 1
            
        results.append({
            'filename': file,
            'present_in_all': exists_all,
            'length_original': lengths[0],
            'length_drums': lengths[1], 
            'length_guitar': lengths[2],
            'matches_original_drums': matches_1_2,
            'matches_drums_guitar': matches_2_3,
            'matches_guitar_original': matches_3_1
        })

# Create dataframe and save to CSV
df = pd.DataFrame(results)
df.to_csv(output_folder + 'audio_orignal_drums_guitar_part_2_redone.csv', index=False)

