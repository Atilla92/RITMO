#SCRIPTED 27.09.2024
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy
from scipy.io.wavfile import read
import os, glob
#from takensEmbedding import find_optimal_delay, find_optional_dimension
from multiSyncPy import synchrony_metrics as sm
import json
from scipy.optimize import curve_fit
import cv2

# Filename
check_fps_files_on = False
file_name = 'P8_D1_G4_M1_R1_T1'
# Audio input, raw or entropy


# Use glob to search for matching files
def load_fps(folder_path, name_file):
    search_pattern = os.path.join(folder_path, f"*{name_file}*.json")
    file_matches = glob.glob(search_pattern)

    # Filter out files containing 'W' in their names
    without_w = [f for f in file_matches if 'W' not in os.path.basename(f)]
    with_w = [f for f in file_matches if 'W' in os.path.basename(f)]

    # Ensure we found exactly one match
    if len(without_w) == 1:
        file_path = without_w[0]
        try:
            with open(file_path, 'r') as json_file:
                data = json.load(json_file)
                return data['fps']
        except FileNotFoundError:
            print(f"File {file_path} not found.")
        except json.JSONDecodeError:
            print(f"File {file_path} contains invalid JSON.")
    elif len(without_w) > 1:
        print(f"Multiple files matched: {without_w}")
    #else:
        #print(f"No files matched the pattern with substring {name_file}.")

files_ok = []

if check_fps_files_on: 
    path_json_files = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_DANCER'
    name_files = glob.glob(os.path.join(path_json_files, '*.json'))

    for file in name_files: 
        file_name = file.split('_pose_data')[-1].strip('_dancer.json')
        input_json_directory = '/Volumes/WHITE LOTUS/FlamencoProject/SYNCHED/SEPTEMBER_2024/POSE_DATA_'
        fps_side =  load_fps(input_json_directory + 'SIDE/', file_name)
        fps_dancer = load_fps(input_json_directory + 'DANCER/', file_name )
        fps_guitar = load_fps(input_json_directory + 'GUITARIST/', file_name)

        if fps_dancer != None and fps_guitar != None and fps_side != None:
            files_ok.append(file_name)

        print(file_name,'dancer: ', fps_dancer, ' side: ',fps_side,' guitar: ' , fps_guitar)


    print('Files ok: ', files_ok)


def get_fps_opencv(file_path):
    video = cv2.VideoCapture(file_path)
    fps = video.get(cv2.CAP_PROP_FPS)
    video.release()
    
    return fps

# Set path
file_path = '/Volumes/WHITE LOTUS/FlamencoProject/VIDEO_FPS/FRONT/'  # Replace with 

name_files = glob.glob(os.path.join(file_path, '*.mp4'))
df_fps = pd.read_csv('/Volumes/WHITE LOTUS/FlamencoProject/VIDEO_FPS/fps_data_with_consistency.csv')

print(df_fps)
print(df_fps['File Name'])

for file in name_files:
    name = file.split('FRONT/')[1]
    fps = get_fps_opencv(file)
    #print(name, f"The FPS of the video is: {fps}")
    #name_2 = str(name + '.MP4')
    #print(name_2)
    row = df_fps.loc[df_fps['File Name'] == name]
    if not row.empty:
        fps_2 = row['local_front'].values[0]
        fps_3 = row['cropped_guitarist'].values[0]
        #if float(fps_2) == float(fps):
            #print(f"Ok for:{name}")
        if float(fps_2) != float(fps) and float(fps_3) != float(fps) :
            print(f"Not the same fps for: {name} fps original = {fps} and rebecca = {fps_2} and guitarist {fps_3}")
        
    else:
        print (f"No matching row found for file: {name}")


