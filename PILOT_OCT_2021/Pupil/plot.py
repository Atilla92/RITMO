import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

# specifications
frame_rate = 120
start_time = 444343.54443876795


df = pd.read_csv (r'Data/2021_10_04/004/pupil_positions.csv', sep = ',')
df_f1 = (df.loc[df["method"]=="pye3d 0.0.4 real-time"])
df_f2 = df_f1[['pupil_timestamp','world_index','eye_id','diameter']]

# Adjust to timestamp 
df_start = (df_f2.loc[df_f2["pupil_timestamp"] >= start_time ])
df_start['pupil_timestamp'] = df_start['pupil_timestamp']-start_time
#time_list = np.array((df_start['pupil_timestamp']-start_time).values.tolist())

df_size = df_start.size
print(len(df_start.index))

#df_start = df_start.loc[df_start['diameter']!= 0] 


print(df_start)
eye_0 = df_start.loc[df_start['eye_id']==0]
eye_1 = df_start.loc[df_start['eye_id']==1]

# print(eye_0)

fig = plt.figure()
ax = plt.axes()
x0 = eye_0['pupil_timestamp']
x1 = eye_1['pupil_timestamp']
ax.plot(x0, eye_0['diameter'])
ax.plot(x1,eye_1['diameter'])
# plt.show()



# Be careful when you align that you also take into account the frame rate. You might have to downsample. 
# Adjust to start at 0
# Adjust the sample rate to second. 