import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from glob import glob
from functions import *
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np
from numpy.random import seed

# Create empty array to store outputs
output_lz_array = []
output_ctw_array = []


# Create binomial testing array. 
step_array = 0.1
prob_array  = np.arange(0.1,0.5 + step_array,step_array)


seed(1234)
for i, item in enumerate(prob_array):
    #
    df = pd.DataFrame(
         np.random.binomial(size=1000, n=1, p= item)
    )
    #
    output_lz,_  =calc_lz_df_2(df, style='LZ', window=100)
    output_ctw,_ =calc_lz_df_2(df, style='CTW', window=100)
    output_lz_array.append(output_lz.values[0])
    output_ctw_array.append(output_ctw.values[0])

# Store data
df = pd.DataFrame(index=prob_array, columns=['LZ','CTW'])
df['LZ'] = output_lz_array
df['CTW'] = output_ctw_array
df.to_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/output_test_fernando.csv')

#Plot LZ and CTW 
plt.plot(prob_array,output_lz_array, label = 'LZ' )
plt.plot(prob_array,output_ctw_array, label = 'CTW' )
plt.legend()
plt.show()

# Output should be
