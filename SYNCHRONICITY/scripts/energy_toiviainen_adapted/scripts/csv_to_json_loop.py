# First step in 

import pandas as pd
import json
import glob, os



# Load clap times data
# clap_times = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/peak_times_video_front_small.csv')
# filenames = clap_times['filename'].tolist()

participant = 'guitarist'

ignored_files = pd.read_csv('/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/synch_audio_video/output/ignore_files.csv')
filenames = ignored_files['file_name'].tolist()



if participant == 'dancer':
    output_folder = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/input/json_dancer_28032025/'
    #output_folder = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/input/test/'
if participant == 'guitarist':
    output_folder = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/input/json_guitarist_28032025/'

# Get list of filenames from clap_times

print(filenames)
# Loop through each filename
for filename in filenames:
    # Get corresponding mocap files
    if participant == 'dancer':
        mocap_files = glob.glob(f'/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_DANCER/*{filename}*_dancer.csv')
    if participant == 'guitarist':
        mocap_files = glob.glob(f'/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_GUITARIST/*{filename}*_guitarist.csv')
    
    # Process each mocap file
    if mocap_files:
        mocap_path = mocap_files[0]       
        mocap_filename = os.path.basename(mocap_path)
        
        # Read mocap file and get total duration from first row
        mocap_df = pd.read_csv(mocap_path)


        df = mocap_df.iloc[:, 1:-1]


        # NECK	(11+12)/2
        # HEAD	(8 + 7)/2
        # PELVIS_CENTER	(24+23)/2
        # THORAX_CENTER	(11+12)/2
        # ABDOMEN_CENTER	(33-35)*[1/2,0.38,1/2]

        df['NECK_X'] = (df['LEFT_SHOULDER_X'] + df['RIGHT_SHOULDER_X'])/2
        df['NECK_Y'] = (df['LEFT_SHOULDER_Y'] + df['RIGHT_SHOULDER_Y'])/2
        df['NECK_Z'] = (df['LEFT_SHOULDER_Z'] + df['RIGHT_SHOULDER_Z'])/2
        df['HEAD_X'] = (df['LEFT_EAR_X'] + df['RIGHT_EAR_X'])/2
        df['HEAD_Y'] = (df['LEFT_EAR_Y'] + df['RIGHT_EAR_Y'])/2
        df['HEAD_Z'] = (df['LEFT_EAR_Z'] + df['RIGHT_EAR_Z'])/2
        df['PELVIS_CENTER_X'] = (df['LEFT_HIP_X']+ df['LEFT_HIP_X'])/2	
        df['PELVIS_CENTER_Y'] = (df['LEFT_HIP_Y']+ df['LEFT_HIP_Y'])/2	
        df['PELVIS_CENTER_Z'] = (df['LEFT_HIP_Z']+ df['LEFT_HIP_Z'])/2	
        df['ABDOMEN_CENTER_X'] = (df['LEFT_HIP_X']+ df['LEFT_HIP_X'])/2
        df['ABDOMEN_CENTER_Y'] = (df['NECK_Y']-df['PELVIS_CENTER_Y'] * 0.38 ) + df['PELVIS_CENTER_Y']
        df['ABDOMEN_CENTER_Z'] = (df['LEFT_HIP_Z']+ df['LEFT_HIP_Z'])/2


        # Get the column names
        column_names = df.columns



        # Create the dictionary
        dictionary = {}
        count = 0

        # Process each column name
        for column_name in column_names:
            # Split the column name by the last underscore
            split_names = column_name.rsplit('_', 1)
            name = split_names[0]  # First part before the last underscore
            variable = split_names[1]  # Second part after the last underscore

            # Check if the name is already present in the dictionary
            if name in dictionary:
                # Append the variable as a new element in the dictionary
                dictionary[name][variable] = df[column_name].tolist()

            else:
                # Add the name as a new element in the dictionary
                dictionary[name] = {variable: df[column_name].tolist()}

                # Store ID as the nth element added to the dictionary
                dictionary[name]['ID'] = count
                count += 1

        #print(dictionary.keys)

        # Store the dictionary as JSON
        with open(output_folder +'dict_pose_data_' + filename + '.json', 'w') as file:
            json.dump(dictionary, file, indent=4)

        print("Dictionary stored as JSON'")


        for key, value in dictionary.items():
            print("Key:", key)
            print("ID:", value['ID'])
            print()


