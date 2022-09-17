import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from glob import glob
from functions import *
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np


# Load Data
# audio_path = "../../FILES/PILOT_SEV_APRIL_2022/Audio/"
# audio_files = []
# for filepath in glob.iglob('../../FILES/PILOT_SEV_APRIL_2022/Audio/*.wav'):
#     if filepath.endswith('.wav'):
#         audio_files.append(filepath)




# Read Audio WAV file
#samplerate, data = read('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/P3_D0_G1_M6_R2_T1.wav')


# def plotAudio(data, samplerate):
#     """Plot left and right channel of Audio Data"""
#     length = data.shape[0] / samplerate
#     time = np.linspace(0., length, data.shape[0])
#     plt.plot(time, data[:, 0], label="Left channel")
#     plt.plot(time, data[:, 1], label="Right channel")
#     plt.legend()
#     plt.xlabel("Time [s]")
#     plt.ylabel("Amplitude")
#     plt.show()

output_lz_array = []
output_ctw_array = []

step_size = 0.1
prob_array  = np.arange(0.1,0.5 + step_size,step_size)

for i, item in enumerate(prob_array):
#Create a pandas dataframe for estimating LZ. Need to place 
    df = pd.DataFrame(
         np.random.binomial(size=20000, n=1, p= item)

    )


    #print(df)

    output_lz  =calc_lz_df_2(df, style='LZ', window=100)
    output_ctw =calc_lz_df_2(df, style='CTW', window=100)
    #print('LZ', output_ctw, 'CTW')
    output_lz_array.append(output_lz)
    output_ctw_array.append(output_ctw)

plt.plot(prob_array,output_lz_array )
plt.plot(prob_array,output_ctw_array )
plt.show()

### What has to be done: Align with ratings. See how big of intervals. One could perhaps estimate the entropy based on the intervals of the sections?
### Either you divide by equal time intervals, or you divide by the blocks of the rating,which would make more sense. in the end you would take the mean of that as well. Yet there could also be something in the direction of entropy. 
### For example if it goes up or down prior to the moment of rating. The behaviour or entropy around the point of rating. What would that imply?
### If for example the rating changes to lower, does the entropy do the same? That is basically what we would be looking at, does the change in entropy explain the change in improvisation. 
### In that case it is probably better to just divide it in equal sections, then it is also easier to see whether there is a change. 