import matplotlib.pyplot as plt
import numpy as np
import pandas as pd



dataIMP1 = pd.read_csv (r'export/IMP1.csv')
dataIMP2 = pd.read_csv (r'export/IMP2.csv')




data1 = dataIMP1['Move'][:-2]
data2 = dataIMP2['Move'][:-2]
data3 = dataIMP1['Pleasure'][:-2]
data4 = dataIMP2['Pleasure'][:-2]
print(data2)
dataX = [data1,data2, data3, data4]
fig = plt.figure()
# ax = fig.add_axes([0,0,1,1])
plt.boxplot(dataX)
plt.show()
