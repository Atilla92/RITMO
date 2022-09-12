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

#Create a pandas dataframe for estimating LZ. Need to place 
df = pd.DataFrame({
    "Left" : data[:20000,0],
    "Right": data [:20000,1]
})

print(df)

output  =calc_lz_df_2(df, style='CTW', window=1000)
print(output)
