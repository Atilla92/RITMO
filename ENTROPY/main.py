from curses import window
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import glob
import os
#from functionsE import *
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
import time
from functionsE import plotAudio_2, calc_lz_df_2

# starting time
start = time.time()


#Load Data
#audio_path = "/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/"

#os.chdir(audio_path) 
audio_files = []
for filepath in glob.iglob('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/*.wav'):
    if filepath.endswith('.wav'):
        filepath_split = filepath.partition('Audio/')
        print (filepath_split)
        audio_files.append(filepath_split[2])

print(audio_files, 'audio_files')


# Initiate variables
length_df = 35000
step_size = 4000

#Empty lists
output_lz_array = []
output_ctw_array = []


# Read Audio WAV file

for i, item in enumerate(audio_files):
    print('Loop: ', item ,i)
    file_name = item
    samplerate, data = read(str('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/'+ file_name))


    #Create a pandas dataframe for estimating LZ. Need to place 
    if length_df:
        df = pd.DataFrame({
            #"Left" : data[:4000,0],
            "Right": data [:length_df,1]
        })

    else:
        df = pd.DataFrame({
            #"Left" : data[:4000,0],
            "Right": data [:,1]
        })

    print(len(df), 'Length df')


    # Calculate Entropy
    output_lz, temp_lz  =calc_lz_df_2(df, style='LZ', window=step_size)
    output_ctw, temp_ctw =calc_lz_df_2(df, style='CTW', window=step_size)

    
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