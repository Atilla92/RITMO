from curses import window
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from glob import glob
from functions import *
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
import time

# starting time
start = time.time()





# Load Data
# audio_path = "../../FILES/PILOT_SEV_APRIL_2022/Audio/"
# audio_files = []
# for filepath in glob.iglob('../../FILES/PILOT_SEV_APRIL_2022/Audio/*.wav'):
#     if filepath.endswith('.wav'):
#         audio_files.append(filepath)




# Read Audio WAV file
samplerate, data = read('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/P3_D0_G1_M6_R2_T1.wav')


def plotAudio(data, samplerate):
    """Plot left and right channel of Audio Data"""
    length = data.shape[0] / samplerate
    time = np.linspace(0., length, data.shape[0])
    plt.plot(time, data[:, 0], label="Left channel")
    plt.plot(time, data[:, 1], label="Right channel")
    plt.legend()
    plt.xlabel("Time [s]")
    plt.ylabel("Amplitude")
    plt.show()

def plotAudio_2(data, samplerate, length_df, ax):
    """Plot left and right channel of Audio Data"""
    data = data[0:length_df]
    length = data.shape[0] / samplerate
    time = np.linspace(0., length, data.shape[0])
    ax.plot(time, data[:,0], label="Left channel")
    #ax.plot(time, data[:, 1], label="Right channel")
    #ax.legend()
    #ax.xlabel("Time [s]")
    #ax.ylabel("Amplitude")
    #plt.show()


# Initiate variables
length_df = []
step_size = 400000

#Empty lists
output_lz_array = []
output_ctw_array = []

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



# Plot 
# Create time array for entropy, divide by samplerate of audio. 
n_windows = int( len(df) / step_size ) 
time_array  = np.divide(np.arange(0,n_windows* step_size ,step_size), samplerate)

f, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)
ax1.plot(time_array ,temp_lz, label = 'LZ' )
ax2.plot(time_array,temp_ctw, label = 'CTW' )
plotAudio_2(data, samplerate, length_df, ax3)
plt.legend()
plt.show()


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