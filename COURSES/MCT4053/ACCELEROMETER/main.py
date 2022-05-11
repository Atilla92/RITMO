import sys

import pandas as pd
import numpy as np
import matplotlib
import random
import json
import csv

import matplotlib.pyplot as plt
import math
import sys
import pylab
import numpy.linalg 

from scipy import stats
import seaborn as sns
from IPython.display import display, Markdown

import sensormotion as sm
from functions import *
from scipy import integrate
from cut_points import cut_points


#Load json variables
f_json = open('variables.json')
variables = json.load(f_json)
dateFiles = '12.02.2022'


# Load data

currentFile = 'P1_D2_T2'
df = pd.read_csv (currentFile+'.csv', sep = ',', skiprows=144, encoding= 'unicode_escape') 
fs = 1.481481*10**2


foot_side = 'Left'

if foot_side == "Left":
    df_left = df[['X_acc [s]','FSR adapter 15: ACC.X 15 [g]', 'FSR adapter 15: ACC.Y 15 [g]', 'FSR adapter 15: ACC.Z 15 [g]']].copy()

if foot_side == "Right":
    df_left =df[['X_acc [s]','FSR adapter 16: ACC.X 16 [g]', 'FSR adapter 16: ACC.Y 16 [g]', 'FSR adapter 16: ACC.Z 16 [g]']].copy() 



labelColumns(df_left)
#labelColumns(df_right)


# Get particulat step 
for item in variables['details_files']:
    if item['name'] == currentFile:
        print ('TRUE', currentFile)
        n_splits = item["n_splits"]
        start_reaper = item["start_reaper"]
        step_labels = item["step_labels"]
        step_times =item["step_times"]
        duration_s = item["duration_s"]
        steps_start_s = list_sec(step_times)
    else: 
        print ('False', currentFile)

# First step [0]
id = 2
step = str(step_labels[id])
fileNameSave = str(currentFile + '_step_' + step +'_'+ foot_side +'_')

df_left = setTimeWindow(df_left, start_reaper, steps_start_s[id], duration_s[id] )
#df_right = setTimeWindow(df_right, start_reaper, steps_start_s[id], duration_s[id] )

# Bandpass filter
f_low = 0.5
f_high = 10

#Plotting Raw Data
#plotRawData(df_left)
#plotRawAccSeperate(df_left)

filtered_x, filtered_y, filtered_z = filterData(df_left, f_low, f_high, fs, 4)
#plotOneFilteredDirection(df_left.Time, df_left.Z, filtered_z)

#Plotting filtered data using SensorMotion library
plotFilteredDataSM(df_left.Time, filtered_x, filtered_y, filtered_z, True, fileNameSave)

#Plotting Physical activity counts (physical activity events every 1s for our short example).
x_counts, y_counts, z_counts = countActivityHistogramSM(df_left, filtered_x, filtered_y, filtered_z, nameFig=fileNameSave)

#Calculating vector magnitude (vm) of counts
vm = sm.signal.vector_magnitude(x_counts, y_counts, z_counts)  

#Categorizing physical activity. Based on thresholds found in literature. 
#(Light, moderate, vigourous, very vigourous)
categories, time_spent = cut_points(vm, set_name='freedson_adult', n_axis=3, plot=True, saveFig =True, fileName = fileNameSave) #Here, set_name is the pre-defined threshold based on research

#Comparing acceleration on each plane
plotFilteredAcc3Planes(filtered_x, filtered_y, filtered_z, saveFig=True, nameFig=fileNameSave)

#Rectifying accelerations - Absolute values
rectified_accx, rectified_accy, rectified_accz = getAbsAcc(df_left, filtered_x, filtered_y, filtered_z)
plotRectifiedAccOneDirection(rectified_accz, 'Z',  saveFig =True, nameFig = fileNameSave)

#Cumulative acceleration
sumacc_x, sumacc_y, sumacc_z = cumulativeAcceleration(rectified_accx, rectified_accy, rectified_accz)
plotCumulativeAcc(sumacc_x, sumacc_y, sumacc_z, saveFig =True, nameFig = fileNameSave)


###### INTEGRATION #########

#First we need to convert accelerometer data from g to SI units (m/s^2). 1 g-unit is equal to 9.80665 meter/square second.
filtered_x_si, filtered_y_si, filtered_z_si = GtoSI(9.80665, filtered_x, filtered_y, filtered_z)

#Integrating filtered acceleration to get velocity in each direction
velocity_x, velocity_y, velocity_z = integrateOneDegree(df_left, filtered_x_si, filtered_y_si, filtered_z_si)

#Plotting velocities in each direction
plotVelocities(df_left, velocity_x, velocity_y, velocity_z, saveFig =True, nameFig = fileNameSave)


#Integrating velocity to get position in each direction
position_x, position_y, position_z = integrateOneDegree(df_left, velocity_x, velocity_y, velocity_z)

#Plotting position in each direction
plotPosition(df_left, position_x, position_y, position_z, saveFig =True, nameFig = fileNameSave)

#Looking at position on each plane
plotPosition3Planes(position_x, position_y, position_z, saveFig =True, nameFig = fileNameSave)


# Save data in pd

pos_vel_acc = {
    'Time': np.array(df_left.Time),
    'Position X': position_x,
    'Position Y': position_y,
    'Position Z': position_z,
    'Velocity X': velocity_x,
    'Velocity Y': velocity_y,
    'Velocity Z': velocity_z,
    'Filtered Acc X': filtered_x,
    'Filtered Acc Y': filtered_y,
    'Filtered Axx Z': filtered_z,
}

sum_acc = {
    'Time': np.array(df_left.Time),
    'Sum Acc X' : sumacc_x['X'],
    'Sum Acc Y' : sumacc_y['Y'],
    'Sum Acc Z' : sumacc_z['Z'],
    'Time': sumacc_x.index

}

counts = {
    'Counts X' : x_counts,
    'Counts Y' : y_counts,
    'Counts Z' : z_counts
}




df_pos_vel_acc = pd.DataFrame(data=pos_vel_acc)
df_counts = pd.DataFrame(data=counts)
df_sum_acc = pd.DataFrame(data = sum_acc)

#print(sumacc_x.index)
df_pos_vel_acc.to_csv('./Analysis/'+'pos_vel_acc_'+ currentFile +'_'+ 'step_'+step + '_'+ foot_side +'.csv')
df_counts.to_csv('./Analysis/'+'counts_'+ currentFile +'_'+ 'step_'+step +'_'+ foot_side + '.csv')
df_sum_acc.to_csv('./Analysis/'+'sum_acc_'+ currentFile +'_'+ 'step_'+step + '_' + foot_side + '.csv')




# Set time window
# tStart = 40
# tEnd = 100 

# df_left = df_left.loc[(df_left["Time"] >= tStart ) &(df_left["Time"] <= tEnd ) ]
# df_left = df_right.loc[(df_right["Time"] >= tStart ) &(df_right["Time"] <= tEnd ) ]