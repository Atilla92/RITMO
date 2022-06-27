from scipy import io
import numpy as np
from functions import loadmat, InfotoColumns
import pandas as pd

# data = io.loadmat('./output/features.mat')

# print(data['fp1'][0][0][0][0][0][0][1][-1])


data = loadmat('./output/features.mat')
print(data.keys())
df_store = pd.DataFrame()
print(data['fp1'][0][1])


name_files = data['filenames']
frame_0 = data['fp1'][0][0]
frame_1 = data['fp2'][0][1]


rms = data['ml1']
entropy = data ['ml2']

print (np.size(frame_0), np.size(frame_1),np.size(rms[0]), 'rms', np.shape(entropy), 'entropy', name_files)

for i, item in enumerate(name_files):
   
    av_entropy = np.nanmean(entropy[i])
    
    #print(entropy[i])
    av_rms = np.nanmean(rms[i])
    print (item, av_entropy, 'average ent', av_rms, 'average rms')

    # Create new dataframe to store entropy
    df_intermediate = pd.DataFrame({
            'Name': str(item),
            'Entropy_Av' : av_entropy, 
            'RMS_Av': av_rms,

        },              index=[i]
        )
    
    df_store = pd.concat([df_intermediate, df_store])


InfotoColumns(df_store)

print(df_store)
df_store.to_csv('./output/Average_rms_ent.csv', index=False)

    
    


