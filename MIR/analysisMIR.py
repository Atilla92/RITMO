from scipy import io
import numpy as np
from functions import loadmat, InfotoColumns
import pandas as pd
import json
import os

# data = io.loadmat('./output/features.mat')

# print(data['fp1'][0][0][0][0][0][0][1][-1])

folder_name = 'features_07072023_guitar'
#data = loadmat('./output/features_dec_2022.mat') #Files used until 29.03.2023


# Create new folders to store if necessary
list_folders = ['ENTROPY', 'NOVELTY', 'SM']
for i, item in enumerate(list_folders):
    file_output = str('/Users/atillajv/CODE/RITMO/FILES/MIR/'+ folder_name + '/'+ item +'/') 
    if not os.path.exists(file_output):
        os.mkdir(file_output)
        print("Directory " , file_output ,  " Created ")
    else:    
        print("Directory " , file_output ,  " already exists")
    


data = loadmat(str('./output/' + folder_name + '.mat'))
print(data.keys())
df_store = pd.DataFrame()
#print(df_store)
print(data['fp1'][0][1])


name_files = data['filenames']
print(name_files)
frame_0 = data['fp1'][0][0]
frame_1 = data['fp2'][0][1]


metre = data['fp3']
sm = data ['fp4']
novelty = data['fp5']

rms = data['rms']
print(np.size(rms))


#print (np.size(frame_0), np.size(frame_1),np.size(metre[0]), 'metre', np.shape(sm), 'sm', name_files)
d_list = []
for i, item in enumerate(name_files):
   
    #av_entropy = np.nanmean(entropy[i])
    
    #print(entropy[i])
    #av_rms = np.nanmean(rms[i])
    #print (item, av_entropy, 'average ent', av_rms, 'average rms')

    # Create new dataframe to store entropy
    df_1 = pd.DataFrame({
        'rms_t0' : data['fp1'][i][0],
        'rms_t1' : data['fp1'][i][1],
        'rms': data['rms'][i],
        'rms_avg': data['rmsavg'][i],
        'entropy': data['entropy'][i],
        'entropy_t0': data['fp2'][i][0],
        'entropy_t1': data['fp2'][i][1],
        #'entropy_avg': data['entropyavg'][i],
        #'sm': [data['sm'][i]],
        #'sm_t0': [data['fp4'][i][0]],
        #'sm_t1': [data['fp4'][i][1]],
        }             
        )
    df_2 = pd.DataFrame({
        #'Name': str(item).strip('.wav'),
        #'rms_t0' :[ data['fp1'][i][0]],
        #'rms_t1' : [data['fp1'][i][1]],
        #'rms': [data['rms'][i]],
        #'rms_avg': data['rmsavg'][i],
        'novelty': data['novelty'][i],
        'novelty_t0' : data['fp5'][i][0],
        'novelty_t1' : data['fp5'][i][1],
        },             
        )

    df_3 = pd.DataFrame({
        #'Name': str(item).strip('.wav'),
        # 'rms_t0' :[ data['fp1'][i][0]],
        # 'rms_t1' : [data['fp1'][i][1]],
        # 'rms': [data['rms'][i]],
        # 'rms_avg': data['rmsavg'][i],
        # 'novelty': [data['novelty'][i]],
        # 'novelty_t0' :[ data['fp5'][i][0]],
        # 'novelty_t1' :[ data['fp5'][i][1]],
        # 'entropy': [data['entropy'][i]],
        # 'entropy_t0': [data['fp2'][i][0]],
        # 'entropy_t1': [data['fp2'][i][1]],
        # 'entropy_avg': data['entropyavg'][i],
        'sm': [data['sm'][i]],
        'sm_t0': [data['fp4'][i][0]],
        'sm_t1': [data['fp4'][i][1]],
        },             
        )


    #df_store = pd.concat([df_intermediate, df_store])



    df_1.to_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/'+ folder_name + '/ENTROPY/'+ str(item).strip('.wav') + '.csv', index=False)
    df_2.to_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/'+ folder_name + '/NOVELTY/'+ str(item).strip('.wav') + '.csv', index=False)
    df_3.to_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/'+ folder_name + '/SM/'+ str(item).strip('.wav') + '.csv', index=False)
#print(df_store)

#InfotoColumns(df_store)

#print(df_store)


    
    


    # dictionnary ={
    # 'name' : str(item),
    # 'rms_t0' :[ data['fp1'][i][0]],
    # 'rms_t1' : data['fp1'][i][1],
    # 'rms': data['rms'][i],
    # 'rms_avg': data['rmsavg'][i],
    # 'novelty': data['novelty'][i],
    # 'novelty_t0' : data['fp5'][i][0],
    # 'novelty_t1' : data['fp5'][i][1],
    # 'entropy': data['entropy'][i],
    # 'entropy_t0': data['fp2'][i][0],
    # 'entropy_t1': data['fp2'][i][1],
    # 'entropy_avg': data['entropyavg'][i],
    # 'sm': data['sm'][i],
    # 'sm_t0': data['fp4'][i][0],
    # 'sm_t1': data['fp4'][i][1],
    # }
    # d_list.append(dictionnary) 

# with open("./output/test.json", "w") as outfile:
#     json.dump(d_list, outfile)


