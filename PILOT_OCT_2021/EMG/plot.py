
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.fft import rfft, rfftfreq, fft, fftfreq 
import seaborn as sns; sns.set_theme()
from sklearn import preprocessing
#from sklearn import preprocessing

# name_file = 'Data/Buleria_BAI_P1_1_Rep1_8.csv'


# Input variables

samplingF = 120 #Hz


df = pd.read_csv (r'Data/Buleria_IMP_P1_1_Rep_1_5.csv', sep = ',', skiprows=32)
#df = pd.read_csv (r'Data/SEGUIRYA_COM_P1_1_REP_1_10.csv', sep = ',', skiprows=32)
# df.rename(index={0: "Time", 1: "A", 2: "B", 3:'C', 4:'D'})
df.columns.values[0] = "Time"
df.columns.values[1] = "A"
df.columns.values[2] = "B"
df.columns.values[3] = "C"
df.columns.values[4] = "D"
print(df)


def createFigure (df, p):
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


# Plot data to set time window
createFigure(df,False)

# Time window 
tStart = 40
tEnd = 100
df_start = (df.loc[(df["Time"] >= tStart ) &(df["Time"] <= tEnd ) ])
df_length = int(len(df_start.index))


# Estimate sample rate
t0 = df_start['Time'].iloc[0]
t1 = df_start['Time'].iloc[-1]
sampleRate = df_length/(t1 - t0)

# Check the window is ok 
x, y1, y2, y3 = createFigure(df_start, True)



# FFT 
def executeFFT(x,y1,y2,y3, p):
    xf = fftfreq(df_length, 1/sampleRate)
    y1f = fft(np.array(y1))
    y2f = fft(np.array(y2))
    y3f = fft(np.array(y3))

    if p:
        fig = plt.figure()
        ax = plt.axes()
        ax.plot(xf,np.abs(y1f))
        ax.plot(xf,np.abs(y2f))
        ax.plot(xf,np.abs(y3f))
        plt.show()
    return xf, y1f, y2f, y3f

# Raw Heatmap 

matrixHeat = df_start[['A','B','C']].to_numpy().transpose(1,0)
fig = plt.figure()
ax = sns.heatmap(matrixHeat)
plt.show()

# Normalised heatmap
# min_max_scaler = preprocessing.MinMaxScaler()
# x_scaled = min_max_scaler.fit_transform(matrixHeat)
# fig = plt.figure()
# ax = sns.heatmap(x_scaled)
# plt.show()








# x_scaled = np.concatenate((min_max_scaler.fit_transform(matrixHeat[0,:].reshape(1, -1)),
#                 min_max_scaler.fit_transform(matrixHeat[1,:].reshape(1, -1)),
#                 min_max_scaler.fit_transform(matrixHeat[2,:].reshape(1, -1))), axis = 0)

# x_scaled = np.concatenate((min_max_scaler.fit_transform(matrixHeat[0,:].reshape(1, -1)),
#                 matrixHeat[1,:],
#                 matrixHeat[2,:]), axis = 0)



# print(matrixHeat.shape, 'shape', len(matrixHeat2))

