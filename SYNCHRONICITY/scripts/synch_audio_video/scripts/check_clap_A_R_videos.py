# Checking whether the clap in the A and R videos are the same.

import pandas as pd

# Load the Rebecca claps
rebecca_claps = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/Rebecca_claps.csv')

# Load the own claps
own_claps = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/peak_times_video_front_small.csv')

# Find missing files in Rebecca claps
missing_files = own_claps[~own_claps['filename'].isin(rebecca_claps['filename'])]
missing_files.to_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/missing_rebecca_claps.csv', index=False)

# Merge the two dataframes on the filename column
merged_claps = pd.merge(rebecca_claps, own_claps, on='filename', how='inner')

print(merged_claps.head())
# Calculate the difference in time between the claps
merged_claps['time_diff'] = merged_claps['peak_time_x'] - merged_claps['peak_time_y']

# Calculate if claps are within 10% threshold
merged_claps['same_clap'] = abs(merged_claps['time_diff']) <= (merged_claps['peak_time_y'] * 0.1)

# Print the results
print(merged_claps[['filename', 'time_diff', 'same_clap']])

# Save the results
merged_claps.to_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/clap_time_diff.csv', index=False)