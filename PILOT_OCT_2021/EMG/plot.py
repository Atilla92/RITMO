
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.fft import rfft, rfftfreq, fft, fftfreq 
import seaborn as sns; sns.set_theme()
from sklearn import preprocessing



# Input variables

samplingF = 120 #Hz


df = pd.read_csv (r'Data/Buleria_IMP_P1_1_Rep_1_5.csv', sep = ',', skiprows=32) #Good one
#df = pd.read_csv (r'Data/Buleria_IMP_P1_2_Rep_1_6.csv', sep = ',', skiprows=32)
#df = pd.read_csv (r'Data/Buleria_IMP_P2_1_Rep_1_4.csv', sep = ',', skiprows=32) #37, 90
#df = pd.read_csv (r'Data/Buleria_BAI_P1_1_Rep1_8.csv', sep = ',', skiprows=32) #31, 126
#df = pd.read_csv (r'Data/GUAJIRA_IMP_P1_1_Rep_1_8.csv', sep = ',', skiprows=32) #103, 174
#df = pd.read_csv (r'Data/SEGUIRYA_IMP_P1_1_Rep_1_7.csv', sep = ',', skiprows=32) #64, 148
#df = pd.read_csv (r'Data/SEGUIRYA_IMP_P2_1_Rep_1_5.csv', sep = ',', skiprows=32) #80, 143 REAL GOOD
#df = pd.read_csv (r'Data/SOLEA_IMP_P1_1_Rep_1_4.csv', sep = ',', skiprows=32) #54, 190 crashing
#df = pd.read_csv (r'Data/SEGUIRYA_COM_P1_1_REP_1_10.csv', sep = ',', skiprows=32)
#df = pd.read_csv (r'Data/SOLEA_IMP_P1_1_REP_1_7.csv', sep = ',', skiprows=32)
#df = pd.read_csv (r'Data/SOLEA_IMP_P2_2_REP_1_3.csv', sep = ',', skiprows=32)
#df.rename(index={0: "Time", 1: "A", 2: "B", 3:'C', 4:'D'})


def  labelColumns(df, p):

    df.columns.values[0] = "Time"
    df.columns.values[1] = "A"
    df.columns.values[2] = "B"
    df.columns.values[3] = "C"
    df.columns.values[4] = "D"
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


def setTimeWindow(df,t0,t1):
    '''Reduce dataset to a certain time window '''
    tStart = t0
    tEnd = t1
    df_start = (df.loc[(df["Time"] >= tStart ) &(df["Time"] <= tEnd ) ])
    df_length = int(len(df_start.index))

    return df_start, df_length



def calculateSampleRate(df_start, df_length):
    '''Estimate sample rate'''
    t0 = df_start['Time'].iloc[0]
    t1 = df_start['Time'].iloc[-1]
    sampleRate = df_length/(t1 - t0)
    return sampleRate


def executeFFT(x,y1,y2,y3, p):
    '''Fast Fourier Transform Data'''
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

def createHeatMap(df_start):
    matrixHeat = df_start[['A','B','C']].to_numpy().transpose(1,0)
    fig = plt.figure()
    ax = sns.heatmap(matrixHeat)
    plt.show()



# Execute Functions
labelColumns(df, False)
createFigure(df,False)
df_start, df_length = setTimeWindow (df, 37, 90)
sampleRate = calculateSampleRate(df_start,df_length)
x, y1, y2, y3 = createFigure(df_start, False)



# Get max length of spikes
max_counter = 0 
counter = 0
nSpikes = 0

#Initiate arrays
y1_store = []
y2_store = []
y3_store = []
y2_time = []

y1_array = np.array(y1)
y2_array  = np.array(y2)
y3_array = np.array(y3)

for i,item in enumerate(y2_array):

    if item>0:
        counter = counter + 1
    else:
        max_counter = np.maximum(counter, max_counter)
        counter = 0
        nSpikes = nSpikes+1
        
print (max_counter,'max count', nSpikes)
y1_spikes = np.zeros((nSpikes, max_counter))
y2_spikes = np.zeros((nSpikes, max_counter))
y3_spikes = np.zeros((nSpikes, max_counter))
time_spikes = np.zeros((nSpikes, max_counter))
j = 0
k= 0

#f, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)
for i, item in enumerate(y2_array):

    if item>0: #it is getting stuck here
        y2_store.append(item)
        y2_time.append(i)
        y1_store.append(y1_array[i])
        y3_store.append(y3_array[i])


    
    else:
        y1_spikes[j][0:len(y1_store)] = y1_store
        y2_spikes[j][0:len(y2_store)] = y2_store
        y3_spikes[j][0:len(y3_store)] = y3_store
        j = j+1
        y1_store =[]
        y2_store = []
        y3_store = []
        y2_time = [] 


f, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)
#fig = plt.figure()
xarray =np.arange(max_counter)
# ax = plt.axes()


ax1.plot(xarray, y1_spikes.T)
ax1.set_title('Y1')
ax2.plot(xarray, y2_spikes.T)
ax2.set_title('Y2')
ax3.plot(xarray,y3_spikes.T)
ax3.set_title('Y3')
plt.show()






print(y2_spikes)

    # if y1_store != []:
    #     #print('hello')

    #     xarray =np.arange(len(y2_time))
    #     xarray = np.divide(xarray,sampleRate)
    #     ax1.plot(xarray, y2_store)
    #     ax1.set_title('Y2')
    #     ax2.plot(xarray, y1_store)
    #     ax2.set_title('Y1')
    #     ax3.plot(xarray,y3_store)
    #     ax3.set_title('Y3')


        # ax.plot(xarray,y2_store)
        # ax.plot()    

plt.show()




def zeroLevelSpikes(y1, y2, y3):
    '''Bin into spikes with zero pressure on y2 as indicator'''
    # Initiate arrays
    y1_array = np.array(y1)
    y2_array  = np.array(y2)
    y3_array = np.array(y3)
    y1_store = []
    y2_store = []
    y3_store = []
    y2_time = []

    # # Initiate figure
    # fig = plt.figure()
    # ax = plt.axes()

    f, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)
    for i, item in enumerate(y2_array):

        if item>0: #it is getting stuck here
            #print (i,item)
            y2_store.append(item)
            y2_time.append(i)
            y1_store.append(y1_array[i])
            y3_store.append(y3_array[i])

        else:
            y1_store =[]
            y2_store = []
            y3_store = []
            y2_time = [] 
            #print('whazup')

        if y1_store != []:
            #print('hello')

            xarray =np.arange(len(y2_time))
            xarray = np.divide(xarray,sampleRate)
            ax1.plot(xarray, y2_store)
            ax1.set_title('Y2')
            ax2.plot(xarray, y1_store)
            ax2.set_title('Y1')
            ax3.plot(xarray,y3_store)
            ax3.set_title('Y3')


            # ax.plot(xarray,y2_store)
            # ax.plot()    

    plt.show()


#zeroLevelSpikes(y1,y2,y3)

# Bin into spikes with acceleration as indicator

# item_past = 0
# i_past =  0
# acceleration_past = 0
# yarray = np.array(y3)
# for i, item in enumerate(yarray):
    
#     acceleration  = (item - item_past)/
#     item_past = item 
#     i_past = i 






# x_scaled = np.concatenate((min_max_scaler.fit_transform(matrixHeat[0,:].reshape(1, -1)),
#                 min_max_scaler.fit_transform(matrixHeat[1,:].reshape(1, -1)),
#                 min_max_scaler.fit_transform(matrixHeat[2,:].reshape(1, -1))), axis = 0)

# x_scaled = np.concatenate((min_max_scaler.fit_transform(matrixHeat[0,:].reshape(1, -1)),
#                 matrixHeat[1,:],
#                 matrixHeat[2,:]), axis = 0)



# print(matrixHeat.shape, 'shape', len(matrixHeat2))




# Raw Heatmap 


# Normalised heatmap
# min_max_scaler = preprocessing.MinMaxScaler()
# x_scaled = min_max_scaler.fit_transform(matrixHeat)
# fig = plt.figure()
# ax = sns.heatmap(x_scaled)
# plt.show()