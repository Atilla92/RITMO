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
from functionsE import plotAudio_2, calc_lz_df_2, quantize_vector, quartile_vector
import json

# Output settings:
file_output = "/Users/atillajv/CODE/RITMO/ENTROPY/output/main/05_Jan_2023_095/var/" # Name of folder to store plots. 



if not os.path.exists(file_output):
    os.mkdir(file_output)
    print("Directory " , file_output ,  " Created ")
else:    
    print("Directory " , file_output ,  " already exists")


# Save settings: 
save_fig  = True # To save figure
save_variables = True # To save variables in json. 
save_csv = True # Store ouput in CSV.
plot_data = True # To plot data
show_plot = False # To show data instead of plotting, if saving data set to False. 

# Code settings:
audio_path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/'
loop_on = True # Set to True if you want to loop through a certain folder. Else not. 
#loop_off = 'P7_D1_G1_M6_R2_T1.wav'
loop_off = 'P7_D5_G1_M6_R1_T1.wav'

downsample_on = True #if you want to downsample. 
downsample_factor = 32 # Set to 1 if False. 
preBinarise_on= False #If you want to binarise data prior to passing dataframe to LZ
absolute_on = True #Takes the absolute value of input data. 
channel_num= 1 # 0 for Left channel, 1 for Right Channel. 
t_start = 0 #[s] if you want analysis to start from different time frame.Need to set to 0 if whole length.  
tempMiddle = True # If you want to displace entropy values a bit further than beginning of window. 
tempNum = 2 # start + windowsize/tempNum  (where windowsize = step_size)
# Initiate variables
length_df = [] # Takes subset samples. Set to [] if you want to whole length. 
step_size = 6000  # Window of LZ/CTW estimation. 
quartile = 0.95 #Set threshold for binarisation. 

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
            filepath_split = filepath.partition('Audio/')
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
    data = data_raw[:,channel_num]

    # Downsample
    if downsample_on:
        dataDown = scipy.signal.decimate(data, downsample_factor)
        data = dataDown
    
    if absolute_on:
        #data = np.abs(data)
        data = data**2
        dataAbs = data
        absString = 'on'

        print(data, 'AFTER ABSOLUTE')

    if preBinarise_on:
        #data = quantize_vector(data)
        data = quartile_vector(data,  quartile)
        binString = 'on'
        print(data, 'AFTER BINARISE')

    #Create a pandas dataframe for estimating LZ. Need to place 

    t_start = t_start * samplerate
    if length_df:
        df = pd.DataFrame({
            #"Left" : data[:4000,0],
            "Audio": data [t_start:(t_start+length_df)]
        })
        data_raw = data_raw[t_start:(t_start+length_df)*downsample_factor, channel_num]

    else:
        data_raw = data_raw[t_start:, channel_num]
        df = pd.DataFrame({
            #"Left" : data[:4000,0],
            "Audio": data [t_start:]
        })

    print(len(df), 'Length df')

    # Calculate Entropy
    #output_lz, temp_lz  =calc_lz_df_2(df, style='LZ', window=step_size, binarise=preBinarise_on)
    #output_ctw, temp_ctw =calc_lz_df_2(df, style='CTW', window=step_size, binarise=preBinarise_on)
    output_var, temp_var =calc_lz_df_2(df, style='var', window=step_size, binarise=preBinarise_on)

    
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
    df_out = pd.DataFrame(index = time_array, columns=['t0', 'var'])
    df_out['t0']= time_array
    df_out['var'] = temp_var
    #df_out['CTW'] = temp_ctw
    #df_out = pd.DataFrame([[len(df),output_lz.values[0], output_ctw.values[0]]], index = ['mean'], columns=df_out.columns).append(df_out)

    #df_out.to_csv(file_output + 'Entropy_LZ_CTW_(w='+ str(step_size)+'_s='+str(length_df) +'_ds='+str(downsample_factor)+'_b=' + binString + '_abs='+ absString +'_t0=' +str(t_str) + ')_'+ file_name.strip('.wav') + '.csv')
    if save_csv: 

        df_out.to_csv(file_output + file_name.strip('.wav') + '.csv')


    # Plot data
    if plot_data: 
        f, (ax1, ax2, ax4) = plt.subplots(3, 1, sharex=True)
        ax1.plot(time_array_ent ,temp_var, label = 'var' )
        #ax2.plot(time_array_ent, temp_ctw, label = 'CTW' )
        ax2.plot(time_binary,df['Audio'] )
        #plotAudio_2(data, samplerate, length_df*downsample_factor, ax3)
        plotAudio_2(data_raw, samplerate, length_df*downsample_factor, ax4)

        plt.legend()
        f.suptitle('Entropy (w: ' + str(step_size) + ' qnt:'+ str(quartile) +') ' + file_name.strip('.wav') )
        ax4.set_xlabel('Time (s)')
        ax1.set_ylabel('Entropy f(var)')
        ax2.set_ylabel('Squared')
        ax4.set_ylabel('Audio')
        
        if show_plot: 
            plt.show()

        if save_fig :
            plt.savefig(file_output + file_name.strip('.wav')+ '.png')

 
    # end time
    end = time.time()
    # total time taken
    print (end-start, 'runtime')
    print(f"Runtime of the program is {end - start}")




if save_variables:

    variables_dict = {
    "downsample" : downsample_factor,
    "preBinarise" : preBinarise_on,
    "quantile" : quartile,
    "absoluteOn": absolute_on,
    "windowSize": step_size

    } 
    json_object = json.dumps(variables_dict, indent = 4)
    with open(str(file_output + "variables.json"), "w") as outfile:
        outfile.write(json_object)



### What has to be done: Align with ratings. See how big of intervals. One could perhaps estimate the entropy based on the intervals of the sections?
### Either you divide by equal time intervals, or you divide by the blocks of the rating,which would make more sense. in the end you would take the mean of that as well. Yet there could also be something in the direction of entropy. 
### For example if it goes up or down prior to the moment of rating. The behaviour or entropy around the point of rating. What would that imply?
### If for example the rating changes to lower, does the entropy do the same? That is basically what we would be looking at, does the change in entropy explain the change in improvisation. 
### In that case it is probably better to just divide it in equal sections, then it is also easier to see whether there is a change. 


# FB from Fernando September 2022:
# 1. Downsample by 4. scipy.signal.decimate(x, q) x = array, q = factor of downsampling
# 2. Positive amplitude, absolute value or squared. np.abs()
# 3. Binarise the whole thing prior to windowing. 
# 4. Entropy value in middle of window instead first point. use temp, in the middle. 


# To Do:
# 1. Go through code and clean dataframes. 
# 2. Compare non binarised with binarised version. DONE
# 3. Plot only binarised if binarised necessary. 
# 4. Store mean in a new dataframe, own csv so we can throw in mixed models analysis. 
# 5. Also set a starting frame so you can take small random snippets.


## Next step:
# 1. Windowing in CWS
# 2. Compare with ratings from dancers/musicians. 

