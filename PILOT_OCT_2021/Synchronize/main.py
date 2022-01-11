from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.fft import rfft, rfftfreq, fft, fftfreq 
import seaborn as sns; sns.set_theme()
from sklearn import preprocessing
from scipy.signal import argrelextrema
import sys

sys.path.insert(0, '../EMG')
from functions import labelColumns, setStart, separateData

# Audio - read samples
input_data = read("../Audio/Data/Buleria_IMP_P1_1.wav")
print(input_data)
audio = input_data[1]
sampleRate = input_data[0]


# Audio - Align with clapper 
threshold = 1.25 * 10**9
click_position = np.argmax(audio > threshold)
audio_threshold = audio[click_position:]


# FSR - Read samples

df = pd.read_csv (r'../EMG/Data/Buleria_IMP_P1_1_Rep_1_5.csv', sep = ',', skiprows=32) #Good one
labelColumns(df, False)
sampleRate_FSR = 5.185185 *10**2


# FSR - Align with Clapper (time in seconds from video)
df_start, df_length =setStart(df,9.2)
x_FSR, y1_FSR, y2_FSR, y3_FSR = separateData(df_start)
x_array_FSR = np.arange(df_length)
x_array_FSR = np.divide(x_array_FSR, sampleRate_FSR)
#x_FSR = x_FSR/sampleRate_FSR
print(df_length)




#Plot figures
f, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, sharex=True)
x_array = np.arange(len(audio_threshold))
x_array = np.divide(x_array,sampleRate)
ax1.plot(x_array, audio_threshold)
ax2.plot(x_array_FSR, y1_FSR)
ax3.plot(x_array_FSR, y2_FSR)
ax4.plot(x_array_FSR, y3_FSR)
plt.show()
