# Trying to run open pose but runs into errors for now.

import musicalgestures
import json
import pandas as pd
import numpy as np

output_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/'
#input_folder = '/Volumes/WHITE LOTUS/FlamencoProject/C_Sevilla/23042022/Edited/Tangos/GoProFront/'
#input_folder = '/Volumes/WHITE LOTUS/FlamencoProject/VIDEOS_SMALL/'
input_folder = '/Volumes/WHITE LOTUS/SYNCHRONISATION/test_video/'
#input_folder = '/Volumes/Seagate/FlamencoProject/SYNCH/'
file_name = 'P3_TEST_3'
#file_name = 'P3_D1_G1_M1_R2_T1'


ds = 4
th = 0.05
model = 'coco'
device = 'cpu'

source_video = musicalgestures.MgVideo(input_folder + file_name + '.mp4')
pose = source_video.pose(downsampling_factor=4, threshold=0.05, model='coco', device='gpu', save_data= True, save_video= True)
# view result
pose.show() # either like this
source_video.show(key='pose') # or like this (referenced from source MgVideo)

variables_dict = {
    "ds": ds,
    'th': th,
    'model' : model,
    'device' : device
}


json_object = json.dumps(variables_dict, indent = 4)
with open(str(output_path + file_name +  "_variables_pose.json"), "w") as outfile:
    outfile.write(json_object)