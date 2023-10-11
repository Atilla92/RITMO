from curses import window
#from turtle import down
import numpy as np
import scipy
import pandas as pd
import matplotlib.pyplot as plt
import glob
import os
#from functionsE import *
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
import time
from functionsE import plotAudio_2, calc_lz_df_2, InterOnsetInterval, findDivisor
import json
import matplotlib.pyplot as plt
import time
from scipy.io import wavfile
from scipy.signal import resample
from OnsetDetection import OnsetDetection




# Output settings:
#file_output = "/Users/atillajv/CODE/RITMO/ENTROPY/output/main/22_Sep_2023_niels_drums/" # 
file_output = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/09_Oct_2023_niels_guitar_4s/'
#Name of folder to store plots. 


if not os.path.exists(file_output):
    os.mkdir(file_output)
    print("Directory " , file_output ,  " Created ")
else:    
    print("Directory " , file_output ,  " already exists")


# Input directory
audio_path = '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO_PART_1/guitar/'
csv_path = '/Users/atillajv/CODE/RITMO/ONSET/output_guitar/'
#csv_path = '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/HALF_AUDIO_PART_1/output_drums/'

loop_on = True # Set to True if you want to loop through a certain folder. Else not. 
loop_off = 'P3_D1_G1_M1_R1_T1.wav' 



dt = 0.001 # Set step interval for t of binarised data
preBinarise_on= True #If you want to binarise data prior to passing dataframe to LZ
channel_num= 1 # 0 for Left channel, 1 for Right Channel. 
t_start = 0 #[s] if you want analysis to start from different time frame.Need to set to 0 if whole length.  
tempMiddle = True # If you want to displace entropy values a bit further than beginning of window. 
tempNum = 2 # start + windowsize/tempNum  (where windowsize = step_size)
# Initiate variables
length_df = [] # Takes subset samples. Set to [] if you want to whole length. 
dt_interval = 4 # Give the amount of seconds you would like to have for time-window 
 

##Empty lists, default values
output_lz_array = []
output_ctw_array = [] 
audio_files = []


#Load Data
if loop_on:
    for filepath in glob.iglob(str(audio_path + '*.wav')):
        if filepath.endswith('.wav'):
            filepath_split = filepath.partition(audio_path[len(audio_path)-10:])
            #print (filepath_split)
            audio_files.append(filepath_split[2])
else:
 audio_files = [loop_off]

print('Number of files to analyse: ' , len(audio_files))

# Read Audio WAV file
# starting time
start = time.time()
for i, item in enumerate(audio_files):
    print('Loop: ', item ,i)
    file_name = item

    if os.path.exists(file_output + file_name.strip('.wav') + '.csv'):
        print(f"Skipping {file_name} as it already exists.")
        continue

    samplerate, data_raw = read(str( audio_path+ file_name))
    data = data_raw[:,channel_num]
    data_raw = data_raw[:,channel_num]
    
    data_csv = pd.read_csv(str(csv_path + file_name.strip('.wav') + '.csv'))
    #Converting back to time-resolution array
    length_audio = len(data)/samplerate
    t = np.linspace(0,int(length_audio), int(length_audio/dt))
    onset_times = data_csv['t_onset']
    
    try: 
        new_values_array = np.zeros(len(t), dtype=int)
        matching_indices = np.searchsorted(t, onset_times)
        new_values_array[matching_indices] = 1  
    
    except IndexError:
        new_values_array = np.zeros(len(t) + 1, dtype=int)
        matching_indices = np.searchsorted(t, onset_times)
        new_values_array[matching_indices] = 1  
    
    data = new_values_array



    downsample_factor = int(dt * samplerate)
    step_size = int(dt_interval/dt)   
    print(samplerate,'samplerate', downsample_factor, 'downsample', ' seconds:',np.divide(downsample_factor * step_size,samplerate), step_size, 'step size')

    #Create a pandas dataframe for estimating LZ. Need to place 
    t_start = t_start * samplerate
    if length_df:
        df = pd.DataFrame({
            "Audio": data [t_start:(t_start+length_df)]
        })
        data_raw = data_raw[t_start:(t_start+length_df)]
        new_values_array = new_values_array[t_start:(t_start+length_df)]

    else:
        data_raw = data_raw[t_start:]
        df = pd.DataFrame({
            #"Left" : data[:4000,0],
            "Audio": data [t_start:]
        })


    # Calculate Entropy
    output_lz, temp_lz  =calc_lz_df_2(df, style='LZ', window=step_size, binarise=preBinarise_on)

    # Estimate inter onset intervals based on binarised data. 
    IOIs, nCounts = InterOnsetInterval(df, step_size, dt_interval)    
    
    # Create time array for entropy, divide by samplerate of audio. 
    n_windows = int( len(df) / step_size ) 
    array_simple = np.arange(0,n_windows* step_size ,step_size)
    time_array =  np.divide(array_simple, 1/dt)
    time_binary = np.arange(0,len(df['Audio']))/samplerate*downsample_factor

    # Adjust temp_lz to middle
    if tempMiddle:
        time_array_ent = np.divide( array_simple + (step_size/tempNum),1/dt )
    else:
        time_array_ent = time_array
    
    # Estimate first order differentiation
    dy_LZ = np.diff(temp_lz)
    dx_LZ = np.diff(time_array_ent)
    d_LZ = dy_LZ/dx_LZ


    # Store data in dataframe
    df_out = pd.DataFrame(index = time_array, columns=['t0', 'LZ', 'dt_LZ', 'IOI', 'nCounts'])
    df_out['t0']= time_array
    df_out['LZ'] = temp_lz
    df_out['dt_LZ'] = np.insert(d_LZ,0,0)
    df_out['IOI'] = IOIs
    df_out['nCounts'] = nCounts
    df_out.to_csv(file_output + file_name.strip('.wav') + '.csv')


    # Plot data

    f, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, sharex=True)
    #ax3.plot(t, data)

    
    t_raw = np.arange(0, len(data_raw)/samplerate, 1/samplerate)
    ax1.plot(time_array_ent ,temp_lz, label = 'LZ' )
    ax2.plot(time_array_ent, df_out['dt_LZ'], label = 'dt_LZ', color = 'g')
    ax3.plot(time_binary,df['Audio'], lw = 0.4, color = 'black' )
    ax3.set_yticklabels([])
    ax4.set_yticklabels([])
    

    if t_raw.shape != data_raw.shape:
        print("x and y must have the same dimensions.")
        t_raw = np.arange(0, len(data_raw)/samplerate, 1/samplerate)[:-1]
        ax4.plot(t_raw, data_raw, color = 'black')
    else:
        ax4.plot(t_raw, data_raw, color = 'black')
    

    
    f.suptitle('Entropy (w: ' + str(step_size) +', ' + file_name.strip('.wav') )

    ax1.set_ylabel('LZ')
    ax2.set_ylabel('dt_LZ')
    ax3.set_ylabel('Binarised')
    ax4.set_ylabel('Audio')
    ax4.set_xlabel('Time (s)')
    plt.savefig(file_output + file_name.strip('.wav')+ '.png')
    plt.close()
    end = time.time()
    # total time taken
    print (end-start, 'runtime')
    print(f"Average runtime of the program is {(end - start)/(i+1)}")
    print(f"Total runtime of the program is {end - start}")

variables_dict = {
    "tempNum" : tempNum,
    "tempMiddle" : str(tempMiddle),
    "windowSize": step_size,
    "sampleRate": samplerate,
    "dt" : dt, 
}
json_object = json.dumps(variables_dict, indent = 4)
with open(str(file_output + "variables.json"), "w") as outfile:
    outfile.write(json_object)



