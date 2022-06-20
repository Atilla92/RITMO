import glob
import matplotlib.pyplot as plt
import pandas as pd
import os
import scipy as sp
import numpy as np
from scipy.io.wavfile import read
from scipy.stats import entropy
from scipy.stats import norm
from sklearn import preprocessing
from functions import *

# Initial Variables

time_shift = -2
df_store = pd.DataFrame()

### Fetch all files for analysis
path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio'
paths_audio = glob.glob(os.path.join(path, '*.wav'))

audio_files = os.listdir(path)
#print(paths_audio)
# print(filelist)

#filelist = []
for filepath in glob.iglob('Ratings/'+'*.csv'):
    
  
    if (filepath.endswith('_IMPRO.csv')):

        f, axs = plt.subplots(3, 1, sharex=True, sharey=False)
        df= pd.read_csv(filepath, sep = ',')
        df['Time'] = df['Time'] + time_shift
        current_file  = filepath.rsplit('_', 1)[0].rsplit('/')[1].split('_',1)[1] 
        path_audio_file = path + '/' + current_file + '.wav'
        sampleRate =  read(path_audio_file)[0]
        audio_data = read(path_audio_file)[1]
        lst1_audio = [item[0] for item in audio_data]
   
        x_array = np.arange(len(audio_data))
        x_array = np.divide(x_array,sampleRate)

    
        axs[0].plot(x_array,np.divide(lst1_audio,1))
        axs[1].step(df['Time'] ,df[' Value'], where='post')


        t_start = 0
        entropy_values = []
        mu_values = []
        name_array = []
        for i in df['Time']:
            axs[0].axvline(x=(i), color ='red')
            # Computing entropy
            #t_end = i
            
            t_start_index = np.argmax(x_array>= t_start)
            t_end_index = np.argmax (x_array >= i)
            #print (t_start, 'start', i, 'end')

            audio_segment = lst1_audio[t_start_index:t_end_index]
            x_array_segment = x_array[t_start_index:t_end_index]

            counts, bins = np.histogram(audio_segment, bins = 10, density= True)
            mu, sigma = norm.fit(audio_segment)
            pdf_hist  = counts/ sum(counts)
            entropy_hist = entropy(pdf_hist, base = 2)
            #print(entropy_hist,'ENTROPY Value')
            entropy_values.append(entropy_hist)
            mu_values.append(mu)

            t_start = i
        
        axs[2].step(df['Time'] , entropy_values, where='pre')

        # Create new dataframe to store entropy
        df_intermediate = pd.DataFrame({
            'Time' : df['Time'], 
            'Value': df[' Value'],
            'Entropy': entropy_values,
            'mu': mu,
            'Name': np.arange(len(entropy_values))

        })

        df_intermediate['Name'] = current_file
        #print(df_intermediate)
        df_store = pd.concat([df_intermediate, df_store])
       # print(d_store)
        #print (d_intermediate)
        #plt.show()

InfotoColumns(df_store)


print(df_store)
df_store.to_csv('output/Ratings_Entropy.csv', index=False)
    
     
       #print( preprocessing.normalize(np.array(df[' Value']).reshape(1,-1)), 'normalized data')
     

        # need to normalize values and plot on the same graph, and store in df, see whether makes sense.
        # Make one big df, where everything is stored. Will get many data points.  
        # Talk with Fernando whether some other entropic analysis could be done? 
        # Get matrices from anna maria. 
        #plt.show()

            
    

            
        

        
        # Compute entropy


        #plt.show()



    # if filepath.endswith('_FLOW.csv'):
    #     plt.scatter(df['Time'], df[' Value'], color = 'blue')

#print(filelist.sort())
#plt.show()
    




        # filepath_split = filepath.partition('/')
        # filepath_split = filepath_split[2].partition('/')
        # filepath_split = filepath_split[2].partition('-')
        # name_files.append(filepath_split[0])
        # audio_files.append(filepath)

# for filepath in glob.iglob('FSR/'+ dateFile + '/*.csv'):
#     if filepath.endswith('.csv'):
#         FSR_files.append(filepath)
