import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.interpolate import interp1d

# specifications
frame_rate = 60
start_time = 444343.54443876795


df = pd.read_csv (r'Data/2021_10_04/004/pupil_positions.csv', sep = ',')
df_f1 = (df.loc[df["method"]=="pye3d 0.0.4 real-time"])
df_f2 = df_f1[['pupil_timestamp','world_index','eye_id','diameter']]

# Adjust to timestamp to trigger 
df_start = (df_f2.loc[df_f2["pupil_timestamp"] >= start_time ])


#Length of sampling
downsample = 1
freq_down = frame_rate/downsample
df_length = int(len(df_start.index))
if (df_length % 2 ) != 0:

    df_start = df_start.iloc[:-1 , :]
    df_length = int(len(df_start.index))

df_length_half  = int(np.round(df_length/downsample))

# Split in two eyes
eye_0 = df_start.loc[df_start['eye_id']==0]
eye_1 = df_start.loc[df_start['eye_id']==1]

# Start time at 0
eye_0['pupil_timestamp'] = eye_0['pupil_timestamp']-eye_0['pupil_timestamp'].iloc[0]
eye_1['pupil_timestamp'] = eye_1['pupil_timestamp']-eye_1['pupil_timestamp'].iloc[0]


# x-axis elements
x0 = eye_0['pupil_timestamp']
x1 = eye_1['pupil_timestamp']

x0_start = x0.iloc[0]
x0_end =  x0.iloc[-1]



def downsample(array, npts, x_end):
    interpolated = interp1d(np.arange(len(array)), array, axis = 0, fill_value = 'extrapolate')
    downsampled = interpolated(np.linspace(0, len(array), npts))
    last_el = downsampled[-1,0]
    #x = np.divide(np.linspace(0, len(array), npts), freq)
    x = np.linspace(0, last_el, npts)
    return downsampled, x


#Downsample
eye0_down, x0_down = downsample(eye_0, df_length_half, x0_end)
eye1_down, x1_down = downsample(eye_0, df_length_half, x0_end)

# matrix_0 = [x0_down,eye0_down]
# matrix = matrix_0[(matrix_0[:,0] > 1)]



# eye_0['diameter'] = eye0_down
# eye_1['diameter'] = eye1_down

#print(eye_0, eye0_down, x0_down)

# remove zeros

# eye_0_f1 = (eye0_down.loc[eye0_down["diameter"] > 1 ] )
# eye_1_f1 = (eye1_down.loc[eye1_down["diameter"] > 1 ])
# eye_0_f1 = (eye_0_f1.loc[eye_0_f1["diameter"] <1 ])
# eye_1_f1 = (eye_1_f1.loc[eye_1_f1["diameter"] <1 ])

# mean and std

# eye_0_mean = eye_0_f1.mean()
# eye_0_std = eye_0_f1.std()
# eye_1_mean = eye_1_f1.mean()
# eye_1_std = eye_1_f1.std()

# # confidence interval 

# x0_f1 = eye_0_f1['pupil_timestamp']
# x1_f1 = eye_1_f1['pupil_timestamp']





eye0_60 = signal.resample(eye_0['diameter'], df_length_half)
x0_60 = np.linspace(x0.iloc[0], x0.iloc[-1], df_length_half)

print(len(x0_60)/120, 'length')

x0_120 = np.linspace(x0.iloc[0], x0.iloc[-1], df_length)
eye0_60_inter = interp1d(x0_60, eye0_60)
eye0_60_inter = interp1d(x0_60, eye0_60)






#print(x0)
fig = plt.figure()
ax = plt.axes()

ax.plot(x0, eye_0['diameter'])
# ax.plot(x0_f1, eye_0_f1['diameter'], 'r')
# ax.plot(x0_60, downsampled_y)
ax.plot(x0_down, eye0_down[:,3])
#ax.plot(x1,eye_1['diameter'])
# ax.plot(x0_60,eye0_60)
# ax.plot(x0_120, eye0_60_inter(x0_120))
plt.show()



# Be careful when you align that you also take into account the frame rate. You might have to downsample. 
# Adjust to start at 0
# Adjust the sample rate to second. 