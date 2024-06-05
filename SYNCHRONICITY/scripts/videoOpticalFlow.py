import musicalgestures
import json
import pandas as pd
import numpy as np

output_path = '/Users/atillajv/CODE/RITMO/SYNCHRONICITY/output/'
#input_folder = '/Volumes/WHITE LOTUS/FlamencoProject/C_Sevilla/23042022/Edited/Tangos/GoProFront/'
#input_folder = '/Volumes/WHITE LOTUS/FlamencoProject/VIDEOS_SMALL/'

variabel_artist = 'GUITARIST'
input_folder = str('/Volumes/WHITE LOTUS/SYNCHRONISATION/test_video/')
input_folder = '/Volumes/Seagate/FlamencoProject/SYNCH/'
#file_name = 'P3_TEST_3'
file_name = 'P3_D1_G1_M1_R2_T1'



source_video = musicalgestures.MgVideo(input_folder + file_name + '.mp4')
velocity = source_video.flow.dense(velocity=True)

print(velocity.data)

xvel = velocity.data['xvel'] # velocity x-axis
yvel = velocity.data['yvel'] # velocity y-axis

# Estimating velocity and angle 
# Double check these equations. 
vel_sum = np.sqrt(np.array(xvel) **2 + np.array(yvel) **2 )

vel_angle = np.arctan(np.array(yvel)/np.array(xvel))


# Estimate y acceleration



#print('LENGTHS:', len(xvel), len(velocity.data['time']), len(velocity.data['dt_v']), len(vel_sum), len(vel_angle), len(velocity.data['acceleration_y']), len(velocity.data['acceleration_y_entropy']))

df = pd.DataFrame({
        'time': velocity.data['time'],
        'x_vel': velocity.data['xvel'],
        'y_vel': velocity.data['yvel'],
        'dt_v_x': np.hstack((0,velocity.data['dt_v_x'])),
        'vel_sum': vel_sum,
        'vel_angle': vel_angle,
        'time_y': velocity.data['time_y'],
        'dt_v_y':np.hstack((0, velocity.data['dt_v_y'])),
        })


df.to_csv(output_path + 'OFD_' +file_name + '.csv')


# Create a json
variables_dict = {
    "FPS": velocity.data['FPS'],
    "path": velocity.data['path'],
    "dt_v_x_entropy": velocity.data['dt_v_x_entropy'],
    "dt_v_x_avg": velocity.data['dt_v_x_avg'],
    'dt_v_y_entropy': velocity.data['dt_v_y_entropy'],
    "dt_v_y_avg": velocity.data['dt_v_y_avg'],
}


json_object = json.dumps(variables_dict, indent = 4)
with open(str(output_path + file_name +  "_variables.json"), "w") as outfile:
    outfile.write(json_object)
