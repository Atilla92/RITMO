
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
#from sklearn import preprocessing

# name_file = 'Data/Buleria_BAI_P1_1_Rep1_8.csv'

df = pd.read_csv (r'Data/Buleria_IMP_P1_1_Rep_1_5.csv', sep = ',', skiprows=32)
# df.rename(index={0: "Time", 1: "A", 2: "B", 3:'C', 4:'D'})
df.columns.values[0] = "Time"
df.columns.values[1] = "A"
df.columns.values[2] = "B"
df.columns.values[3] = "C"
df.columns.values[4] = "D"
print(df)


fig = plt.figure()
ax = plt.axes()
x = df['Time']
y1 = df['A']
y2 = df['B']
y3 = df['C']
#y4 = df['D']

ax.plot(x,y1)
ax.plot(x,y2)
ax.plot(x,y3)
#ax.plot(x,y4)
plt.show()