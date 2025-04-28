
import os
import pandas as pd

# Set input directory path
input_dir = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/video_small_video_front'

# Get list of all CSV files in directory
csv_files = [f for f in os.listdir(input_dir) if f.endswith('.csv')]

# Initialize empty list to store dataframes
dfs = []

# Read each CSV file and append to list
for csv_file in csv_files:
    file_path = os.path.join(input_dir, csv_file)
    df = pd.read_csv(file_path)
    dfs.append(df)

# Concatenate all dataframes
combined_df = pd.concat(dfs, ignore_index=True)

# Save combined dataframe to CSV
output_path = os.path.join(input_dir, 'video_front_video_small_combined.csv')
combined_df.to_csv(output_path, index=False)

print(f"Combined {len(csv_files)} CSV files into {output_path}")
