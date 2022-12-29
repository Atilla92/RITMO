from curses import window
from types import FunctionType
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from glob import glob
from functionsE import *
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
import time
from functionsE import calc_lz_df_2, plotAudio_2


'''
This script can be used to estimate how long the time window for the LZ estimation shoud be. 
Usually when you can see in the plot that the fluctuations start to dampen, thats a good estimate for window size. 
'''
file_output = "/Users/atillajv/CODE/RITMO/ENTROPY/output/set_window/"

# starting time
start = time.time()

# Read Audio WAV file
file_name = "P5_D1_G3_M6_R2_T1"
samplerate, data = read(str('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/'+ file_name + ".wav"))


# Initiate variables
t_start = 50 #seconds, set to zero if from beginning
length_df = 15000 # Samples If you want to only take a chunck of the data
a = 5 # a*e^x or a*x^2, where a = a
b = 50 # a
functionType = 'squared' # Set to 'e' for e function, 'squared' for x^2 function


if not length_df:
    length_df = len(data)



#Empty lists
output_lz_array = []
output_ctw_array = []

#Create a pandas dataframe for estimating LZ. Need to place 
start_time_df = t_start * samplerate

#Estimate number of steps, a*e^2 function
if functionType == 'e': 
    x = np.log(np.divide(length_df,a))
    array_x = np.e**np.arange((x))*a + b*np.arange(x)
    array_x = array_x.astype(int)


# Estimate number of steps, a*x^2 function.
if functionType == 'squared':
    x = (np.divide(length_df, a))**(1/2)
    array_x = a * (np.arange(x))**2 
    array_x = array_x.astype(int)[1:]


for i, item in enumerate(array_x):
    df = pd.DataFrame({
        #"Left" : data[:4000,0],
        "Right": data [start_time_df:(start_time_df + item),1]
    })
    start_loop = time.time()
    output_lz, __  =calc_lz_df_2(df, style= 'LZ', window=item)
    output_lz_array.append(output_lz.values[0])
    output_ctw, __ =calc_lz_df_2(df, style='CTW', window=item)
    output_ctw_array.append(output_lz.values[0])

    # end time
    end_loop = time.time()
    #total time taken
    print ('time taken:' , end_loop-start_loop, 'Loop: ' , i ,' Sample size: ', item)

print(output_lz_array, 'output array')


#Store values in dataframe
df_out = pd.DataFrame(columns=['sample', 'time','LZ', 'CTW'])
df_out['sample']= array_x
df_out['time'] = array_x/samplerate
df_out['LZ'] = output_lz_array
df_out['CTW'] = output_ctw_array

# Store file
df_out.to_csv(file_output + 'window_set_(a=' + str(a) + ', f=' +functionType + '_t0 =' + str(t_start) +'_s='+ str(length_df) + ' )_'+ file_name + '.csv')

# #Plot simple figure 
# plt.plot(array_x, output_lz_array, label = 'LZ')
# plt.plot(array_x, output_ctw_array, label = 'CTW')
# plt.title('Set LZ & CTW Entropy Window '+ file_name +' (a=' + str(a) + ', f=' +functionType +')')
# plt.xlabel('Windowsize (samples)')
# plt.ylabel('Entropy')


f, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=False)
ax1.plot(array_x ,output_lz_array, label = 'LZ' )
ax2.plot(array_x,output_ctw_array, label = 'CTW' )
plotAudio_2(data, samplerate, length_df, ax3, start_time_df)
plt.legend()
f.suptitle( file_name +' (a=' + str(a) + ', f=' +functionType +' t0 ='+str(t_start) + ' [s] s= '+ str(length_df) + ' )' )
ax3.set_xlabel('Time (s)')
ax1.set_ylabel('LZ')
ax2.set_ylabel('CTW')
ax2.set_xlabel('Windowsize (samples)')
ax3.set_ylabel('Amplitude')


#Store fifure
plt.savefig(file_output + 'window_set_(a=' + str(a) + '_f=' +functionType + '_t0 ='+str(t_start) +'_s='+str(length_df) + ')_'+ file_name +'.png')

# end time
end = time.time()
# total time taken
print (end-start, 'runtime')

