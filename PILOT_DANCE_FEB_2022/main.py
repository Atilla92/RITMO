import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.fft import rfft, rfftfreq, fft, fftfreq 
import seaborn as sns; sns.set_theme()
from sklearn import preprocessing
from scipy.signal import argrelextrema
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np


#Import FSR/Audio data
#df = pd.read_csv (r'FSR/12.02.2022/N21_P1_D1_T1_12022022_Rep_1.5.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 

# P1_D1_T2, Standing
input_data = read("AUDIO/P1_D1_T2-220212_1647.wav")
df = pd.read_csv (r'FSR/12.02.2022/N20_P1_D1_T1_12022022_Rep_1.4.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 

# P1_D1_T3, Sitting
# input_data = read("AUDIO/P1_D1_T3-220212_1656.wav")
# df = pd.read_csv (r'FSR/12.02.2022/N21_P1_D1_T1_12022022_Rep_1.5.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 

# P1_D1_T4, Standing
#df = pd.read_csv (r'FSR/12.02.2022/N22_P1_D1_T1_12022022_Rep_1.6.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 
#input_data = read("AUDIO/P1_D1_T4-220212_1705.wav")

# # P1_D2_T1, Standing  
# df = pd.read_csv (r'FSR/12.02.2022/N23_P1_D2_T1_12022022_Rep_1.7.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 
# input_data = read("AUDIO/P1_D2_T1-220212_1808.wav")


# P1_D2_T2, Standing
# df = pd.read_csv (r'FSR/12.02.2022/N24_P1_D2_T2_12022022_Rep_1.8.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 
# input_data = read("AUDIO/P1_D2_T2-220212_1818.wav")






#print(input_data)
audio = input_data[1]
audio_SR = input_data[0]


def  labelColumns(df, p):

    df.columns.values[0] = "Time"
    df.columns.values[1] = "A"
    df.columns.values[3] = "B"
    df.columns.values[5] = "C"
    df.columns.values[7] = "D"
    if p:
        print(df)


def createFigure (df, p):
    ''' Plot raw data'''
    x = df['Time']
    y1 = df['A']
    y2 = df['B']
    y3 = df['C']
    #y4 = df['D']

    if p:
        fig = plt.figure()
        ax = plt.axes()
        ax.plot(x,y1)
        ax.plot(x,y2)
        ax.plot(x,y3)
        #ax.plot(x,y4)
        plt.show()

    return x, y1, y2, y3 

labelColumns(df, False)
x, y1, y2, y3 = createFigure(df,False)


def plot_audio_FSR(audio_data, audio_SR, x, y1, y2, y3):
    f, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, sharex=True)
    x_array = np.arange(len(audio_data))
    x_array = np.divide(x_array,audio_SR)
    ax1.plot(x_array, audio_data)
    ax2.plot(x, y1)
    ax3.plot(x, y2)
    ax4.plot(x, y3)
    plt.show()

plot_audio_FSR(audio, audio_SR, x, y1, y2, y3)