import pandas as pd
import os
import glob


participant='dancer'
# Load clap times data
clap_times = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/peak_times_video_front_small.csv')

# Load video lengths data
video_lengths = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/video_small_video_front/video_front_video_small_combined.csv')

print(video_lengths)
# Initialize lists to store results
results = []

# Process each video file
for _, row in clap_times.iterrows():
    filename = row['filename']
    clap_time = row['peak_time']  # Using the video clap time
    
    # Get corresponding mocap file path by searching for matching filename pattern
    if participant == 'dancer':
        mocap_files = glob.glob(f'/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_DANCER/*{filename}*_dancer.csv')
    if participant == 'guitarist':      
        mocap_files = glob.glob(f'/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_GUITARIST/*{filename}*_guitarist.csv')
    
    # Store results for all versions of this file
    file_versions = []
    
    for mocap_path in mocap_files:
        mocap_filename = os.path.basename(mocap_path)
        
        # Skip files containing '_W_' or '_D0_'
        if participant == 'dancer' and ('_W_' in mocap_filename or '_D0_' in mocap_filename):
            continue
        if participant == 'guitarist' and '_W_' in mocap_filename:
            continue
        # if '_W_' in mocap_filename or '_D0_' in mocap_filename:
        #     continue
            
        # Read mocap file and get total duration from first row
        mocap_df = pd.read_csv(mocap_path)
        mocap_duration = mocap_df['time_s'].iloc[0]
        
        # Get video length and calculate adjusted length
        video_length_series = video_lengths.loc[video_lengths['filename'] == str(filename + '.mp4'), 'length_video_small']
        
        if not video_length_series.empty:
            video_length = video_length_series.iloc[0]
            print(video_length, 'video_length', filename)
            video_adjusted = video_length - clap_time
            
            # Calculate difference between mocap and adjusted video length
            time_difference = mocap_duration - video_adjusted
            
            # Check if difference is within 10% threshold
            within_threshold = time_difference <= (abs(mocap_duration) * 0.1)
            
            file_versions.append({
                'filename': filename,
                'mocap_filename': mocap_filename,
                'clap_time': clap_time,
                'video_length_adjusted': video_adjusted,
                'mocap_duration': mocap_duration,
                'time_difference': time_difference,
                'time_difference_absolute': abs(time_difference),  # Use absolute value for comparison
                'within_threshold': within_threshold
            })
        else:
            print(f"No matching video length found for {filename}")
            # Handle case where no matching video length is found
            file_versions.append({
                'filename': filename,
                'mocap_filename': mocap_filename,
                'clap_time': clap_time,
                'video_length_adjusted': 0,
                'mocap_duration': mocap_duration,
                'time_difference': float('inf'),  # Use infinity for comparison when no video length
                'time_difference_absolute': float('inf'),  # Use infinity for comparison when no video length
                'within_threshold': False
            })
    
    # Find version with smallest time difference
    if file_versions:
        min_diff_version = min(file_versions, key=lambda x: x['time_difference_absolute'])
        
        # Add keep_version flag to all versions
        for version in file_versions:
            version['keep_version'] = (version == min_diff_version)
            results.append(version)

# Create results dataframe
sync_results = pd.DataFrame(results)

# Save full results
if participant == 'dancer':
    sync_results.to_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/mocap_video_sync_results_front_small_dancer.csv', index=False)
if participant == 'guitarist':
    sync_results.to_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/mocap_video_sync_results_front_small_guitar.csv', index=False)

# Save only kept files
kept_files = sync_results[sync_results['keep_version']]
if participant == 'dancer':
    kept_files.to_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/mocap_video_sync_results_front_small_dancer_kept.csv', index=False)
if participant == 'guitarist':
    kept_files.to_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/mocap_video_sync_results_front_small_guitar_kept.csv', index=False)
