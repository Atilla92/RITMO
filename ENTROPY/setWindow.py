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

# Read Audio WAV file
file_name = "P3_D1_G1_M6_R2_T1.wav"
samplerate, data = read(str('/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/'+ file_name))

# Initiate variables
length_df = []
step_size = 4000

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

length_df = len(df)
step_size = 1

x = np.log(np.divide(length_df,step_size))
array_x = np.e**np.arange((x))*step_size

if x%1> 0:
    array_x = np.append(array_x, [length_df])
    print('hello', array_x)

print(len(df),'length', array_x, np.sum(array_x), len(array_x))

# end time
end = time.time()
# total time taken
print (end-start, 'runtime')