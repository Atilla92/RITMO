from distutils.command.config import dump_file
import numpy as np 
import pyloudnorm as pyln
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
from scipy.signal import argrelextrema
from scipy.signal import butter, lfilter
import sensormotion as sm
import pandas as pd
from scipy import integrate
from matplotlib.backends.backend_pdf import PdfPages
from plot_signal import plot_signal
from cut_points import convert_counts

def setTimeWindow(df,t_peaks, t0,t1):
    '''
    Reduce dataset to a certain time window of steps
        df : dataframe 
        t_peaks : first peak of 6
        t0 : start of step
        t1 : end of step
    '''
    tStart = t0 + t_peaks
    tEnd = t1 + t0 + t_peaks
    df_start = df.loc[(df["Time"] >= tStart ) &(df["Time"] <= tEnd ) ]
    #print(df_start)
    #df_length = int(len(df_start.index))
    return df_start


def get_sec(time_str):
    """Get Seconds from time."""
    m, s, ms = time_str.split(':')
    return int(m) * 60 + int(s) + np.divide(int(ms),(100))

def list_sec (step_times):
    '''Get new list in seconds'''
    step_seconds = []
    for key in step_times:
        time_s = get_sec(key)
        step_seconds.append(time_s)
    return step_seconds


def labelColumns(df):

    df.columns.values[0] = "Time"
    df.columns.values[1] = "X"
    df.columns.values[2] = "Y"
    df.columns.values[3] = "Z"


def butter_bandpass(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a


def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = lfilter(b, a, data)
    return y


def plotRawData(df):
    '''Plotting acceleration raw in all three directions'''
    fig = plt.figure(figsize=(14,8))
    plt.plot(df.X, label='X') #plotting acceleration in the X axis direction
    plt.plot(df.Y, label='Y') #plotting acceleration in the Y axis direction
    plt.plot(df.Z, label='Z') #plotting acceleration in the Z axis direction
    plt.xlabel('Time', fontsize=14)
    plt.ylabel('Acceleration (g)', fontsize=14)
    plt.legend(loc='lower right', fontsize=14)


def plotRawAccSeperate(df):
    '''Plotting acceleration in each direction separately'''
    fig = plt.figure(figsize=(14,6))
    aa = plt.subplot(1, 3, 1)
    plt.plot(df.X, color='k') #Plotting column X
    plt.title('Acceleration X - Lateral', fontsize=14) #Title of the plot
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)

    ab = plt.subplot(1, 3, 2)
    plt.plot(df.Y, color='b') #Plotting column Y
    plt.title('Acceleration Y - Frontal', fontsize=14) #Title of the plot
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)


    ac = plt.subplot(1, 3, 3)
    plt.plot(df.Z, color='g') #Plotting column Z
    plt.title('Acceleration Z - Vertical', fontsize=14) #Title of the plot
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)


def filterData(df, f_low, f_high, fs, orderN):
    '''Creating filters for human movement data frequencies
       Using filters on data'''
    filtered_x = butter_bandpass_filter(df.X, f_low, f_high, fs, order=orderN)
    filtered_y = butter_bandpass_filter(df.Y, f_low, f_high, fs, order=orderN)
    filtered_z = butter_bandpass_filter(df.Z, f_low, f_high, fs, order=orderN)
    return filtered_x, filtered_y, filtered_z

def plotOneFilteredDirection(Time, unfilteredDirection, filterDirection):
    '''Plotting raw and filtered data in one direction'''
    fig = plt.figure(figsize=(14,8))
    plt.plot(Time, unfilteredDirection, label='Noisy data') #Plotting column Z
    plt.plot(Time, filterDirection, label='Filtered data')  #Plotting filtered data on Z
    plt.legend(loc='upper right', fontsize=16)
    plt.xlabel('Time (s)', fontsize=16)
    plt.ylabel('Acceleration (g)', fontsize=16)




def plotFilteredDataSM(Time, filtered_x, filtered_y, filtered_z, saveFig, figName):
    plot_signal(Time, [{'data': filtered_x, 'label': 'Lateral', 'line_width': 0.5},
                           {'data': filtered_y, 'label': 'Frontal', 'line_width': 0.5},
                           {'data': filtered_z, 'label': 'Vertical', 'line_width': 0.5}],
                    subplots=True, fig_size=(10,7), saveFig =saveFig, saveName = figName)

    


def countActivityHistogramSM(df, filtered_x, filtered_y, filtered_z, nameFig):
    x_counts = convert_counts(filtered_x, df.Time, time_scale='s', epoch=1, rectify='full', integrate='simpson', plot=True, saveFig = True, nameFig =nameFig ,  direction ='x')
    y_counts = convert_counts(filtered_y, df.Time, time_scale='s', epoch=1, rectify='full', integrate='simpson', plot=True, saveFig = True, nameFig =nameFig , direction = 'y')
    z_counts = convert_counts(filtered_z, df.Time, time_scale='s', epoch=1, rectify='full', integrate='simpson', plot=True, saveFig = True, nameFig =nameFig, direction = 'z')
    return  x_counts, y_counts, z_counts


def plotFilteredAcc3Planes(filtered_x, filtered_y, filtered_z, saveFig, nameFig):
    
    fig = plt.figure(figsize=(16,8))
    ax1 = plt.subplot(1, 3, 1)
    plt.plot(filtered_y, filtered_z, color='red',alpha=0.3, label='YZ') #We plot filtered acceleration in Y vs filtered acceleration in Z
    plt.legend(loc='lower right', fontsize=16)
    plt.xlabel('Frontal acceleration (g)',fontsize=16)
    plt.ylabel('Vertical acceleration  (g)',fontsize=16)
    ax1.set_facecolor("white")

    ax2 = plt.subplot(1, 3, 2)
    plt.plot(filtered_x, filtered_z, color='blue',alpha=0.4, label='XZ') #We plot filtered acceleration in X vs filtered acceleration in Z
    plt.legend(loc='lower right', fontsize=16)
    plt.xlabel('Lateral acceleration (g)',fontsize=16)
    plt.ylabel('Vertical acceleration  (g)',fontsize=16)
    ax2.set_facecolor("white")


    ax3 = plt.subplot(1, 3, 3)
    plt.plot(filtered_x, filtered_y, color='green',alpha=0.4, label='XY') #We plot filtered acceleration in X vs filtered acceleration in Y
    plt.legend(loc='lower right', fontsize=16)
    plt.ylabel('Lateral acceleration (g)',fontsize=16)
    plt.xlabel('Frontal acceleration  (g)',fontsize=16)
    ax3.set_facecolor("white")

    if saveFig:
        plt.savefig('./Figures/Filtered_Acc_3Planes_'+ nameFig +'.png')


def getAbsAcc(df, filtered_x, filtered_y, filtered_z):
    filtered_accx = pd.DataFrame(data=filtered_x, index=df.Time, columns=['X'])
    filtered_accy = pd.DataFrame(data=filtered_y, index=df.Time, columns=['Y'])
    filtered_accz = pd.DataFrame(data=filtered_z, index=df.Time, columns=['Z'])

    rectified_accx = filtered_accx.abs()
    rectified_accy = filtered_accy.abs()
    rectified_accz = filtered_accz.abs()

    return rectified_accx, rectified_accy, rectified_accz


def plotRectifiedAccOneDirection (rectified_acc, direction, saveFig, nameFig):
    stringLabel = 'Rectified Acceleration in '+ direction + ' direction'
    fig = plt.figure(figsize=(14,8))
    plt.plot(rectified_acc, label=stringLabel ) #Plotting Z
    plt.legend(loc='upper right', fontsize=16)
    plt.xlabel('Time (s)', fontsize=16)
    plt.ylabel('Acceleration (g)', fontsize=16)

    if saveFig:
        plt.savefig('./Figures/Rectified_'+direction+ '_direction_'+ nameFig +'.png')


def cumulativeAcceleration(rectified_accx,rectified_accy,rectified_accz):
    sumacc_x = rectified_accx.cumsum()
    sumacc_y = rectified_accy.cumsum()
    sumacc_z = rectified_accz.cumsum()
    return sumacc_x, sumacc_y, sumacc_z


def plotCumulativeAcc(sumacc_x, sumacc_y, sumacc_z, saveFig, nameFig):

    fig = plt.figure(figsize=(14,8))
    plt.plot(sumacc_x, label='X') #Plotting cumulative acc in X
    plt.plot(sumacc_y, label='Y') #Plotting cumulative acc in Y
    plt.plot(sumacc_z, label='Z') #Plotting cumulative acc in Z
    plt.xlabel('Time (s)', fontsize=14)
    plt.ylabel('Acceleration (g)', fontsize=14)
    plt.legend(loc='upper left', fontsize=16)
    plt.title('Cumulative acceleration', fontsize=16)
    if saveFig:
        plt.savefig('./Figures/Cumulative_Acc_'+ nameFig +'.png')

    #plt.show()



def GtoSI(g, filtered_x, filtered_y, filtered_z):
    filtered_x_si = filtered_x* g
    filtered_y_si = filtered_y* g
    filtered_z_si = filtered_z* g
    return filtered_x_si, filtered_y_si, filtered_z_si

def integrateOneDegree(df, filtered_x_si, filtered_y_si, filtered_z_si):
    velocity_x = integrate.cumtrapz(filtered_x_si, df.Time, initial=0)
    velocity_y = integrate.cumtrapz(filtered_y_si, df.Time, initial=0)
    velocity_z = integrate.cumtrapz(filtered_z_si, df.Time, initial=0)
    return velocity_x, velocity_y, velocity_z



def plotVelocities(df, velocity_x, velocity_y, velocity_z, saveFig, nameFig): 

    fig = plt.figure(figsize=(14,6))
    aa = plt.subplot(1, 3, 1)
    plt.plot(df.Time, velocity_x, color='b') #Plotting  X
    plt.title('Velocity X - Lateral', fontsize=14) #Title of the plot
    plt.xlabel('Time (s)', fontsize=14)
    plt.ylabel('Velocity (m/s)', fontsize=14)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)

    ab = plt.subplot(1, 3, 2)
    plt.plot(df.Time, velocity_y, color='r') #Plotting  Y
    plt.title('Velocity Y - Frontal', fontsize=14) #Title of the plot
    plt.xlabel('Time (s)', fontsize=14)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)


    ac = plt.subplot(1, 3, 3)
    plt.plot(df.Time, velocity_z, color='g') #Plotting  Z
    plt.title('Velocity Z - Vertical', fontsize=14) #Title of the plot
    plt.xlabel('Time (s)', fontsize=14)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)
    if saveFig:
        plt.savefig('./Figures/Velocities_xyz_'+ nameFig +'.png')

    #plt.show()


def plotPosition(df, position_x, position_y, position_z, saveFig, nameFig):
    fig = plt.figure(figsize=(14,6))
    aa = plt.subplot(1, 3, 1)
    plt.plot(df.Time, position_x, color='b') #Plotting  X
    plt.title('Position X - Lateral', fontsize=14) #Title of the plot
    plt.xlabel('Time (s)', fontsize=14)
    plt.ylabel('Position (m)', fontsize=14)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)

    ab = plt.subplot(1, 3, 2)
    plt.plot(df.Time, position_y, color='r') #Plotting  Y
    plt.title('Position Y - Frontal', fontsize=14) #Title of the plot
    plt.xlabel('Time (s)', fontsize=14)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)

    ac = plt.subplot(1, 3, 3)
    plt.plot(df.Time, position_z, color='g') #Plotting  Z
    plt.title('Position Z - Vertical', fontsize=14) #Title of the plot
    plt.xlabel('Time (s)', fontsize=14)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)
    if saveFig:
        plt.savefig('./Figures/Position_xyz_'+ nameFig +'.png')

    #plt.show()


def plotPosition3Planes(position_x, position_y, position_z, saveFig, nameFig):
    fig = plt.figure(figsize=(24,8))
    ax1 = plt.subplot(1, 3, 1)
    plt.plot(position_y, position_z, color='red',alpha=0.3, label='YZ') #We plot position in Y vs position in Z
    plt.legend(loc='lower right', fontsize=16)
    plt.xlabel('Frontal position (m)',fontsize=16)
    plt.ylabel('Vertical position  (m)',fontsize=16)
    ax1.set_facecolor("white")


    ax2 = plt.subplot(1, 3, 2)
    plt.plot(position_x, position_z, color='blue',alpha=0.4, label='XZ') #We plot position in X vs position in Z
    plt.legend(loc='lower right', fontsize=16)
    plt.xlabel('Lateral position (m)',fontsize=16)
    plt.ylabel('Vertical position (m)',fontsize=16)
    ax2.set_facecolor("white")


    ax3 = plt.subplot(1, 3, 3)
    plt.plot(position_x, position_y, color='green',alpha=0.4, label='XY') #We plot position in X vs position in Y
    plt.legend(loc='lower right', fontsize=16)
    plt.xlabel('Lateral position (m)',fontsize=16)
    plt.ylabel('Frontal position (m)',fontsize=16)
    ax3.set_facecolor("white")
    if saveFig:
        plt.savefig('./Figures/Position_3Planes_'+ nameFig +'.png')

    #plt.show()

