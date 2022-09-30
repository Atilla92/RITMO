from curses import window
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
from functionsE import plotAudio_2, calc_lz_df_2, quantize_vector

# Code settings:

loop_on = False # Set to True if you want to loop through a certain folder. Else not. 
loop_off = 'P3_D1_G1_M1_R1_T1.wav'
downsample_on = True #if you want to downsample. 
downsample_factor = 4
channel_num= 1 # 0 for Left channel, 1 for Right Channel. 
# Initiate variables
length_df = 40000 # Takes subset samples. Set to [] if you want to whole length. 
step_size = 4000  # Window of LZ/CTW estimation. 
preBinarise_on= True #If you want to binarise data prior to passing dataframe to LZ
absolute_on = True #Takes the absolute value of input data. 

##Empty lists
output_lz_array = []
output_ctw_array = [] 
audio_files = []


#Load Data
if loop_on:
    for filepath in glob.iglob('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/*.wav'):
        if filepath.endswith('.wav'):
            filepath_split = filepath.partition('Audio/')
            print (filepath_split)
            audio_files.append(filepath_split[2])
else:
 audio_files = [loop_off]


print(audio_files, 'audio_files')


# Read Audio WAV file
# starting time
start = time.time()
for i, item in enumerate(audio_files):
    print('Loop: ', item ,i)
    file_name = item
    samplerate, data = read(str('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/'+ file_name))
    data = data[:,channel_num]

    if downsample_on:
        data = scipy.signal.decimate(data, downsample_factor)
    print(data)
    if absolute_on:
        data = np.abs(data)
    
    print(data, 'AFTER ABSOLUTE')

    if preBinarise_on:
        data = quantize_vector(data)
    
    print(data, 'AFTER BINARISE')

    #Create a pandas dataframe for estimating LZ. Need to place 
    if length_df:
        df = pd.DataFrame({
            #"Left" : data[:4000,0],
            "Audio": data [:length_df]
        })

    else:
        df = pd.DataFrame({
            #"Left" : data[:4000,0],
            "Audio": data [:]
        })

    print(len(df), 'Length df')

    # Calculate Entropy
    output_lz, temp_lz  =calc_lz_df_2(df, style='LZ', window=step_size)
    output_ctw, temp_ctw =calc_lz_df_2(df, style='CTW', window=step_size, binarise=preBinarise_on)

    
    # Create time array for entropy, divide by samplerate of audio. 
    n_windows = int( len(df) / step_size ) 
    time_array  = np.divide(np.arange(0,n_windows* step_size ,step_size), samplerate)


    # Store data in dataframe
    df_out = pd.DataFrame(index = time_array, columns=['t0', 'LZ','CTW'])
    df_out['t0']= time_array
    df_out['LZ'] = temp_lz
    df_out['CTW'] = temp_ctw
    df_out = pd.DataFrame([[len(df),output_lz.values[0], output_ctw.values[0]]], index = ['mean'], columns=df_out.columns).append(df_out)
    file_output = "/Users/atillajv/CODE/RITMO/ENTROPY/output/main/"
    df_out.to_csv(file_output + 'Entropy_LZ_CTW_(w='+ str(step_size)+'_s='+str(length_df) +')_'+ file_name.strip('.wav') + '.csv')


    # Plot data
    f, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)
    ax1.plot(time_array ,temp_lz, label = 'LZ' )
    ax2.plot(time_array,temp_ctw, label = 'CTW' )
    plotAudio_2(data, samplerate, length_df, ax3)
    plt.legend()
    f.suptitle('Entropy (w: ' + str(step_size) + ' s:'+ str(length_df) +') ' + file_name.strip('.wav') )
    ax3.set_xlabel('Time (s)')
    ax1.set_ylabel('LZ')
    ax2.set_ylabel('CTW')
    ax3.set_ylabel('Amplitude')

    #plt.show()
    plt.savefig(file_output + 'Entropy_LZ_CTW_(w='+ str(step_size)+'_s='+str(length_df) +')_'+ file_name.strip('.wav') +'.png')

    # end time
    end = time.time()
    # total time taken
    print (end-start, 'runtime')
    print(f"Runtime of the program is {end - start}")






### What has to be done: Align with ratings. See how big of intervals. One could perhaps estimate the entropy based on the intervals of the sections?
### Either you divide by equal time intervals, or you divide by the blocks of the rating,which would make more sense. in the end you would take the mean of that as well. Yet there could also be something in the direction of entropy. 
### For example if it goes up or down prior to the moment of rating. The behaviour or entropy around the point of rating. What would that imply?
### If for example the rating changes to lower, does the entropy do the same? That is basically what we would be looking at, does the change in entropy explain the change in improvisation. 
### In that case it is probably better to just divide it in equal sections, then it is also easier to see whether there is a change. 


# FB from Fernando September 2022:
# 1. Downsample by 4. scipy.signal.decimate(x, q) x = array, q = factor of downsampling
# 2. Positive amplitude, absolute value or squared. np.abs()
# 3. Binarise the whole thing prior to windowing. 