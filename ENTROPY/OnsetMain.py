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
import sounddevice as sd
from OnsetDetection import OnsetDetection
import librosa


print('hello')

# Output settings:
file_output = "/Users/atillajv/CODE/RITMO/ENTROPY/output/main/24_Aug_2023_all_Onset_1s/" # Name of folder to store plots. 
#wav_output = '/Volumes/Seagate/FlamencoProject/E_SEVILLA/06102022/EDITED/Mic360/'
#file_output = "/Users/atillajv/CODE/RITMO/ENTROPY/output/main/Test/" # Name of folder to store plots. 


if not os.path.exists(file_output):
    os.mkdir(file_output)
    print("Directory " , file_output ,  " Created ")
else:    
    print("Directory " , file_output ,  " already exists")



# Code settings:
#audio_path = '/Volumes/Seagate/FlamencoProject/F_Andalucia/ensemble_rode/'
#audio_path = '/Volumes/Seagate/FlamencoProject/E_SEVILLA/06102022/EDITED/Mic360/'
#audio_path = '/Volumes/WHITE LOTUS/FlamencoProject/L_Lausanne/Audio/all_drums/'
audio_path = '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/ORIGINAL/'
#audio_path = '/Volumes/Seagate/AUDIO/ORIGINAL/'
#audio_path = '/Volumes/Seagate/AUDIO/ORIGINAL/'
loop_on = True # Set to True if you want to loop through a certain folder. Else not. 
#loop_off = 'P7_D1_G1_M6_R2_T1.wav'
loop_off = 'P8_D5_G4_M5_R1_T1.wav'
downsample_on = True #if you want to downsample. 
butter_filter_on = False
onsetDetection_on =False #Onset detection from OnsetDetection
onsetLibrosa_on = True #Onset detection from librosa
dt = 0.001 # Set step interval for t of binarised data
preBinarise_on= True #If you want to binarise data prior to passing dataframe to LZ
channel_num= 1 # 0 for Left channel, 1 for Right Channel. 
t_start = 0 #[s] if you want analysis to start from different time frame.Need to set to 0 if whole length.  
tempMiddle = True # If you want to displace entropy values a bit further than beginning of window. 
tempNum = 2 # start + windowsize/tempNum  (where windowsize = step_size)
# Initiate variables
length_df = [] # Takes subset samples. Set to [] if you want to whole length. 
#step_size = 6000  # Window of LZ/CTW estimation. 
dt_interval = 1 # Give the amount of seconds you would like to have for time-window 
 

##Empty lists, default values
output_lz_array = []
output_ctw_array = [] 
audio_files = []



# if not downsample_factor:
#     downsample_factor = 1

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

    if onsetDetection_on:
        samplerate, data_raw = read(str( audio_path+ file_name))
        data = data_raw[:,channel_num]
        data_raw = data_raw[:,channel_num]
    
    if onsetLibrosa_on:
        data_raw, d_samplerate = librosa.load(audio_path + file_name, sr=None, mono=True, dtype='float32')
        data = data_raw
    
    #Needs to be adjusted to dt = 0.001 if wanting to use it. 
    if onsetDetection_on: 
        t= np.linspace(0, len(data) / (d_samplerate), len(data))
        onsetDetection = OnsetDetection(data,fs = d_samplerate, threshold = 1.0, hopTime=0.01 )
        onsetTimes = onsetDetection.getOnsetTimes()
        new_values_array = np.zeros(len(t), dtype=int)
        matching_indices = np.searchsorted(t, onsetTimes)
        new_values_array[matching_indices] = 1  
        data = new_values_array
    
    if onsetLibrosa_on:  
        onset_t = librosa.onset.onset_detect(y=data, sr=d_samplerate, units='time')
        t = np.arange(0, len(data)/d_samplerate, dt)
        new_values_array = np.zeros(len(t), dtype=int)
        matching_indices = np.searchsorted(t, np.round(onset_t, 3))
        new_values_array[matching_indices] = 1  
        data = new_values_array

    downsample_factor = int(dt * d_samplerate)
    step_size = int(dt_interval/dt)
        
    print(d_samplerate,'samplerate', downsample_factor, 'downsample', ' seconds:',np.divide(downsample_factor * step_size,d_samplerate), step_size, 'step size')

    samplerate  = d_samplerate

    
    print(len(data), 'AFTER BINARISE', step_size, 'STEPSIZE')

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
    #output_ctw, temp_ctw =calc_lz_df_2(df, style='CTW', window=step_size, binarise=preBinarise_on)


    # Estimate inter onset intervals based on binarised data. 
    IOIs = InterOnsetInterval(df, step_size, dt_interval)    
    
    # Create time array for entropy, divide by samplerate of audio. 
    n_windows = int( len(df) / step_size ) 
    if downsample_on:
        array_simple = np.arange(0,n_windows* step_size ,step_size)
        time_array =  np.divide(array_simple, 1/dt)
        time_binary = np.arange(0,len(df['Audio']))/samplerate*downsample_factor
    else:
        time_array  = np.divide(np.arange(0,n_windows* step_size ,step_size), 1/dt)

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
    df_out = pd.DataFrame(index = time_array, columns=['t0', 'LZ', 'dt_LZ', 'IOI'])
    df_out['t0']= time_array
    df_out['LZ'] = temp_lz
    df_out['dt_LZ'] = np.insert(d_LZ,0,0)
    df_out['IOI'] = IOIs
    df_out.to_csv(file_output + file_name.strip('.wav') + '.csv')


    # Plot data

    f, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, sharex=True)
    #ax3.plot(t, data)

    
    t_raw = np.arange(0, len(data_raw)/d_samplerate, 1/d_samplerate)
  
    ax1.plot(time_array_ent ,temp_lz, label = 'LZ' )
    ax2.plot(time_array_ent, df_out['dt_LZ'], label = 'dt_LZ', color = 'g')
    ax3.plot(time_binary,df['Audio'], lw = 0.4, color = 'black' )
    

    if t_raw.shape != data_raw.shape:
        print("x and y must have the same dimensions.")
        t_raw = np.arange(0, len(data_raw)/d_samplerate, 1/d_samplerate)[:-1]
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
    "downsample" : downsample_on,
    "tempNum" : tempNum,
    "tempMiddle" : str(tempMiddle),
    "onsetLibrosa": str(onsetLibrosa_on),
    "onsetDetection" : str(onsetDetection_on),
    "windowSize": step_size,
    "sampleRate": d_samplerate,
    "dt" : dt, 

}
json_object = json.dumps(variables_dict, indent = 4)
with open(str(file_output + "variables.json"), "w") as outfile:
    outfile.write(json_object)
