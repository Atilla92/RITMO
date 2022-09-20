import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from glob import glob
from functions import *
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import numpy as np


# Create empty array to store outputs
output_lz_array = []
output_ctw_array = []


# Create binomial testing array. 
step_array = 0.1
prob_array  = np.arange(0.1,0.5 + step_array,step_array)


# Create a log increasinf array of windows. 
# Need to create a new calc_entropy function in functions, to take different step sizes with log. Create an array upfront.
# Probably integrate. You have c


for i, item in enumerate(prob_array):

    df = pd.DataFrame(
         np.random.binomial(size=1000, n=1, p= item)
    )

    output_lz  =calc_lz_df_2(df, style='LZ', window=100)
    output_ctw =calc_lz_df_2(df, style='CTW', window=100)
    output_lz_array.append(output_lz)
    output_ctw_array.append(output_ctw)





# Plot 
plt.plot(prob_array,output_lz_array, label = 'LZ' )
plt.plot(prob_array,output_ctw_array, label = 'CTW' )
plt.legend()
plt.show()

