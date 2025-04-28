import pandas as pd
import glob 
import os

# Get all file names from each folder and process them consistently
def get_filenames(path, pattern, name_processor, original_names=False):
    files = glob.glob(os.path.join(path, pattern))
    if original_names:
        return {name_processor(file): os.path.basename(file) for file in files}
    return [name_processor(file) for file in files]

# Define paths
path_all_files = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels/27102023_ELAN_no_CDRS_onset_niels_4s_final.csv'
path_audio_drums = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/09_Oct_2023_niels_drums_4s'
path_video_files = '/Volumes/WHITE LOTUS/FlamencoProject/VIDEO_FPS/FRONT/'
path_csv_dancer = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_DANCER/'
path_csv_side = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_SIDE/'
path_csv_guitarist = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_GUITARIST/'
path_motion_side = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/MOTION_DATA_SIDE/'

# Get filenames from main CSV
df = pd.read_csv(path_all_files)
name_files = list(df['Name'].unique())

# Get filenames and original names from each folder
name_files_video = get_filenames(path_video_files, '*.mp4', 
                                lambda x: os.path.basename(x).replace('.mp4', ''),
                                original_names=True)

name_files_audio_drums = get_filenames(path_audio_drums, '*.csv',
                                     lambda x: os.path.basename(x).split('.csv')[0],
                                     original_names=True)

name_files_csv_dancer = get_filenames(path_csv_dancer, '*.csv',
                                    lambda x: os.path.basename(x).split('_pose_data_')[-1].split('_dancer')[0],
                                    original_names=True)

name_files_csv_side = get_filenames(path_csv_side, '*.csv',
                                   lambda x: os.path.basename(x).split('_pose_data_')[-1].split('.csv')[0],
                                   original_names=True)

name_files_csv_guitarist = get_filenames(path_csv_guitarist, '*.csv',
                                       lambda x: os.path.basename(x).split('_pose_data_')[-1].split('_guitarist')[0],
                                       original_names=True)

name_files_motion_side = get_filenames(path_motion_side, '*.csv',
                                      lambda x: os.path.basename(x).split('motionData_')[-1].strip('.csv'),
                                      original_names=True)

# Create a set of all unique filenames
all_unique_files = set()
for file_dict in [name_files_video, name_files_audio_drums, name_files_csv_dancer, 
                  name_files_csv_side, name_files_csv_guitarist, name_files_motion_side]:
    all_unique_files.update(file_dict.keys())
all_unique_files.update(name_files)

# Create comparison data
comparison_data = []
for filename in sorted(all_unique_files):
    presence = {
        'filename': filename,
        'general': filename in name_files,
        'video_front': filename in name_files_video,
        'audio_drums_4s': filename in name_files_audio_drums,
        'csv_dancer': filename in name_files_csv_dancer,
        'csv_side': filename in name_files_csv_side,
        'csv_guitarist': filename in name_files_csv_guitarist,
        'motion_side': filename in name_files_motion_side,
        'original_video_front': name_files_video.get(filename, ''),
        'original_audio_drums': name_files_audio_drums.get(filename, ''),
        'original_csv_dancer': name_files_csv_dancer.get(filename, ''),
        'original_csv_side': name_files_csv_side.get(filename, ''),
        'original_csv_guitarist': name_files_csv_guitarist.get(filename, ''),
        'original_motion_side': name_files_motion_side.get(filename, '')
    }
    comparison_data.append(presence)

print(len(comparison_data))
# Create DataFrame and filter for missing and complete files
comparison_df = pd.DataFrame(comparison_data)
print(comparison_data)

# Create mask for complete files
complete_mask = (comparison_df['general'] & 
                comparison_df['video_front'] & 
                comparison_df['audio_drums_4s'] &
                comparison_df['csv_dancer'] &
                comparison_df['csv_side'] &
                comparison_df['csv_guitarist'] & 
                comparison_df['motion_side'])

missing_df = comparison_df[~complete_mask]
complete_df = comparison_df[complete_mask]

# Print results and save to CSV
print("\nFiles with missing locations:")
print(missing_df)

print("\nComplete files:")
print(complete_df)

# Save both dataframes
output_path_missing = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/mdQRA/output/missing_files_report_17022024.csv'
output_path_complete = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/mdQRA/output/complete_files_report_17022024.csv'

missing_df.to_csv(output_path_missing, index=False)
complete_df.to_csv(output_path_complete, index=False)

print(f"\nMissing files report saved to: {output_path_missing}")
print(f"Complete files report saved to: {output_path_complete}")
