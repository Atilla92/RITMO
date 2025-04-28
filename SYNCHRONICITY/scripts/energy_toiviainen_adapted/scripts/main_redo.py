### Same as main.py, but process a specific list of files. 

# Next steps 27.03.2025:
### Need to run through script for dancer. Something is off. [CHECK]
### Have already run for guitarist. [CHECK]
### Need to check files and why some do not have peaks filtered out?

import pandas as pd
import json
from classes import Model, Participant, Segment, Joint
from functions import KineticEnergy, PotentialEnergy, calculate_cumulative_energy, EstimateEnergy
import matplotlib.pyplot as plt
import numpy as np
import glob, os

# Example usage
participant = 'guitarist'
# clap_times = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/peak_times_video_front_small.csv')
# name_files = clap_times['filename'].tolist()

ignored_files = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/redo_files.csv')
name_files = ignored_files[ignored_files['instruction'] != 'ignore']['file_name'].tolist()
print(name_files)

body_model = 'wholebody'
skip_existing = True
# Set output path based on participant
if participant == 'dancer':
    output_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/28032025_dancer/'
if participant == 'guitarist':
    output_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/output/28032025_guitarist/'
if not os.path.exists(output_path):
    os.makedirs(output_path)

# Load kept files mapping
if participant == 'dancer':
    kept_files = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/mocap_video_sync_results_front_small_dancer_kept.csv')
if participant == 'guitarist':
    kept_files = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/mocap_video_sync_results_front_small_guitar_kept.csv')

participant_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/models/participants_info.csv'

nonExisting_files = []
processed_files = []

print("Processing files:", name_files)

for name_file in name_files:
    print(f"\nProcessing {name_file} for {participant}")
    print(os.path.join(output_path, f'Energy_{body_model}_{name_file}.csv'), 'PATH to FILE')
    
    # # Skip if already processed
    # if name_file in processed_files:
    #     print(f"Skipping {name_file} - already processed")
    #     continue

        
    if participant == 'dancer':
        name = name_file.split('_pose_data')[-1].strip('_dancer.json')
        data_input_path = f'/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/input/json_dancer_28032025/dict_pose_data_{name}.json'
        mocap_files = glob.glob(f'/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_DANCER/*{name}*_dancer.json')
    if participant == 'guitarist':
        name = name_file.split('_pose_data')[-1].strip('_guitarist.json')
        data_input_path = f'/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/input/json_guitarist_28032025/dict_pose_data_{name}.json'
        mocap_files = glob.glob(f'/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_GUITARIST/*{name}*_guitarist.json')

    # Skip warmup files
    if name.split('_')[0] == 'W':
        print(f"Skipping warmup file {name}")
        nonExisting_files.append(name)
        continue


    if participant == 'dancer':
        analysis = '0' # 0 for dancer, 1 for guitarist, 2 for both
    if participant == 'guitarist':
        analysis = '1' # 0 for dancer, 1 for guitarist, 2 for both
    if participant == 'both':
        analysis = '2' # 0 for dancer, 1 for guitarist, 2 for both

    if analysis == '2':
        participant_list = [name.split('_')[0], name.split('_')[2]]
    elif analysis == '0':
        participant_list = [name.split('_')[0]]
    elif analysis == '1':
        participant_list = [name.split('_')[2]]

    if skip_existing:
        print(participant_list, 'PARTICIPANT LIST')
        if os.path.exists(os.path.join(output_path, f'Energy_{body_model}_{participant_list[0]}_{name_file}.csv')):
            print(f"Skipping {name_file} - already processed")
            continue

    # Process mocap file if exists
    if mocap_files:
        mocap_path = mocap_files[0]       
        mocap_filename = os.path.basename(mocap_path)
        print(f"Found mocap file: {mocap_filename}")
        
        with open(mocap_path) as json_file:
            info = json.load(json_file)



        print(f"Processing participants: {participant_list}")
        
        for participant_id in participant_list:
            # Create Participant and Model
            participant_obj = Participant(participant_id, False, info_path=participant_path)
            participant_obj.display_info()

            model = Model(artist=participant_id, segment_array=body_model, filter='lowpass')
            model.fps = info['fps']
            if os.path.exists(data_input_path):
                model.data_path = data_input_path
            else:
                print(f"No json file found for {mocap_filename}")
                nonExisting_files.append(mocap_filename)
                continue
            model.display_info()

            EstimateEnergy(participant_obj, model, output_path, name)

            # Store model info
            model_info = {
                'artist': model.artist,
                'body_parts': model.body_parts,
                'filter': model.filter,
                'fps': model.fps,
                'lowcut': model.lowcut,
                'highcut': model.highcut,
                'order': model.order,
                'data_path': model.data_path,
            }

            filename = f'model_{model.body_parts}_{participant_list[0]}_{name}.json'
            with open(os.path.join(output_path, filename), 'w') as f:
                json.dump(model_info, f)
            print(f"Stored model info in {filename}")

        processed_files.append(name_file)
        
    else:
        print(f"No mocap file found for {data_input_path}")
        nonExisting_files.append(name)

print("\nFiles that could not be processed:", nonExisting_files)

# Save list of unprocessed files to JSON
if nonExisting_files:
    output_file = os.path.join(output_path, f'unprocessed_files_{body_model}_{participant}.json')
    with open(output_file, 'w') as f:
        json.dump({'unprocessed_files': nonExisting_files}, f)
    print(f"\nSaved list of unprocessed files to {output_file}")



