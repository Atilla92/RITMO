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
from functionsE import plotAudio_2, calc_lz_df_2, InterOnsetInterval
import json
import matplotlib.pyplot as plt
import time
from scipy.io import wavfile
from scipy.signal import resample
import sounddevice as sd
from OnsetDetection import OnsetDetection




# Output settings:
file_output = "/Users/atillajv/CODE/RITMO/ENTROPY/output/main/21_Aug_2023_all_Onset/" # Name of folder to store plots. 
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
audio_path = '/Volumes/Seagate/AUDIO/ORIGINAL/'
loop_on = True # Set to True if you want to loop through a certain folder. Else not. 
#loop_off = 'P7_D1_G1_M6_R2_T1.wav'
loop_off = 'P8_D1_G4_M6_R1_T1.wav'
downsample_on = True #if you want to downsample. 
downsample_factor = 32 # Set to 1 if False. 
butter_filter_on = True
onsetDetection_on = True
preBinarise_on= True #If you want to binarise data prior to passing dataframe to LZ
channel_num= 1 # 0 for Left channel, 1 for Right Channel. 
t_start = 0 #[s] if you want analysis to start from different time frame.Need to set to 0 if whole length.  
tempMiddle = True # If you want to displace entropy values a bit further than beginning of window. 
tempNum = 2 # start + windowsize/tempNum  (where windowsize = step_size)
# Initiate variables
length_df = [] # Takes subset samples. Set to [] if you want to whole length. 
#step_size = 6000  # Window of LZ/CTW estimation. 
dt_interval = 4 # Give the amount of seconds you would like to have for time-window 



##Empty lists, default values
output_lz_array = []
output_ctw_array = [] 
audio_files = []

# Strings for storing files
binString = 'off'
absString = 'off'
t_str = str(t_start)


if not downsample_factor:
    downsample_factor = 1

#Load Data
if loop_on:
    for filepath in glob.iglob(str(audio_path + '*.wav')):
        if filepath.endswith('.wav'):
            filepath_split = filepath.partition(audio_path[len(audio_path)-10:])
            print (filepath_split)
            audio_files.append(filepath_split[2])
else:
 audio_files = [loop_off]


# Read Audio WAV file
# starting time
start = time.time()
for i, item in enumerate(audio_files):
    print('Loop: ', item ,i)
    file_name = item
    samplerate, data_raw = read(str( audio_path+ file_name))
    step_size = int(dt_interval * samplerate / downsample_factor) 
    print(samplerate,'samplerate', ' seconds:',np.divide(downsample_factor * step_size,samplerate))
    data = data_raw[:,channel_num]
    

    # Downsample
    if downsample_on:
        dataDown = scipy.signal.decimate(data, downsample_factor)
        data = dataDown
    

    if onsetDetection_on:
        t= np.linspace(0, len(data) / (samplerate/downsample_factor), len(data))
        onsetDetection = OnsetDetection(data,fs = samplerate/downsample_factor, threshold = 1.2, hopTime=0.01 )
        onsetTimes = onsetDetection.getOnsetTimes()
        new_values_array = np.zeros(len(t), dtype=int)
        matching_indices = np.searchsorted(t, onsetTimes)
        new_values_array[matching_indices] = 1  
        data = new_values_array


    
    print(data, 'AFTER BINARISE')

    #Create a pandas dataframe for estimating LZ. Need to place 

    t_start = t_start * samplerate
    if length_df:
        df = pd.DataFrame({
            "Audio": data [t_start:(t_start+length_df)]
        })
        data_raw = data_raw[t_start:(t_start+length_df), channel_num]
        #dataAbs = dataAbs[t_start:(t_start+length_df)]
        dataDown = dataDown[t_start:(t_start+length_df)]
        new_values_array = new_values_array[t_start:(t_start+length_df)]

    else:
        data_raw = data_raw[t_start:, channel_num]
        #dataAbs = dataAbs[t_start:]
        dataDown = dataDown[t_start:]
        new_values_array = dataDown[t_start:]
        df = pd.DataFrame({
            #"Left" : data[:4000,0],
            "Audio": data [t_start:]
        })

    print(len(df), 'Length df')

    # Calculate Entropy
    output_lz, temp_lz  =calc_lz_df_2(df, style='LZ', window=step_size, binarise=preBinarise_on)
    #output_ctw, temp_ctw =calc_lz_df_2(df, style='CTW', window=step_size, binarise=preBinarise_on)

    IOIs = InterOnsetInterval(df, step_size, dt_interval)
    print(IOIs)
    
    # Create time array for entropy, divide by samplerate of audio. 
    n_windows = int( len(df) / step_size ) 
    if downsample_on:
        array_simple = np.arange(0,n_windows* step_size ,step_size)
        time_array =  np.divide(array_simple, samplerate/downsample_factor)
        time_binary = np.arange(0,len(df['Audio']))/samplerate*downsample_factor
    else:
        time_array  = np.divide(np.arange(0,n_windows* step_size ,step_size), samplerate)

    # Adjust temp_lz to middle
    if tempMiddle:
        time_array_ent = np.divide( array_simple + (step_size/tempNum),samplerate/downsample_factor )
    else:
        time_array_ent = time_array
    


    # Store data in dataframe
    df_out = pd.DataFrame(index = time_array, columns=['t0', 'LZ', 'dt_LZ', 'IOI'])
    df_out['t0']= time_array
    df_out['LZ'] = temp_lz
    df_out['dt_LZ'] = np.insert(np.diff(temp_lz),0,0)
    df_out['IOI'] = IOIs
    #df_out['CTW'] = temp_ctw
    #df_out = pd.DataFrame([[len(df),output_lz.values[0], output_ctw.values[0]]], index = ['mean'], columns=df_out.columns).append(df_out)

    #df_out.to_csv(file_output + 'Entropy_LZ_CTW_(w='+ str(step_size)+'_s='+str(length_df) +'_ds='+str(downsample_factor)+'_b=' + binString + '_abs='+ absString +'_t0=' +str(t_str) + ')_'+ file_name.strip('.wav') + '.csv')
    df_out.to_csv(file_output + file_name.strip('.wav') + '.csv')


    # Plot data

    f, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, sharex=True)
    ax1.plot(time_array_ent ,temp_lz, label = 'LZ' )
    #ax2.plot(time_array_ent, temp_ctw, label = 'CTW' )
    ax2.plot(time_binary,df['Audio'] )
    #plotAudio_2(data, samplerate, length_df*downsample_factor, ax3)
    plotAudio_2(data_raw, samplerate, length_df*downsample_factor, ax4)
    ax3.plot(time_binary, dataDown)
    #ax4.plot(time_binary, dataDown)
    ax4.plot(time_binary, new_values_array)
    f.suptitle('Entropy (w: ' + str(step_size) + file_name.strip('.wav') )
    ax4.set_xlabel('Time (s)')
    ax1.set_ylabel('LZ')
    ax3.set_ylabel('Squared')
    ax2.set_ylabel('Binarised')
    ax4.set_ylabel('Audio')
    plt.show()

    plt.savefig(file_output + file_name.strip('.wav')+ '.png')

    end = time.time()
    # total time taken
    print (end-start, 'runtime')
    print(f"Runtime of the program is {end - start}")



### Next steps
# Store again plots, and .csv also check whether it works for the source_separated guitar files, probably do a comparisson between these. 

# but overall, GOOD WORK!!!

