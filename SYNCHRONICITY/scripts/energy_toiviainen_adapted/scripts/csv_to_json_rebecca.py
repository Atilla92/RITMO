import pandas as pd
import json
import glob
import os

date = ''
name_file = 'G1_P3_D1_G1_M1_R2_T1'
#input_folder = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/node_output/pose_data/'

input_folder = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_DANCER_2/'
output_folder = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/scripts/energy_toiviainen_adapted/input/json_dancer_2/'
# Find all .mat files in the specified directory
name_files = glob.glob(os.path.join(input_folder, '*.csv'))

#name_files = [input_folder + '130924_pose_data_P6_D1_G1_M1_R1_T1_dancer.csv']
#print(name_files)

for file_path in name_files:
    print(file_path.split('_pose_data_'))



for name_file in name_files:
    data = pd.read_csv(name_file)


    df = data.iloc[:, 1:-1]


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
    with open(output_folder + date +'dict_pose_data_' + name_file.split('_pose_data_')[-1].strip('_dancer.csv') + '.json', 'w') as file:
        json.dump(dictionary, file, indent=4)

    print("Dictionary stored as JSON'")


    for key, value in dictionary.items():
        print("Key:", key)
        print("ID:", value['ID'])
        print()


