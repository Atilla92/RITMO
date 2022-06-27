from scipy import io
import numpy as np
from functions import loadmat

# data = io.loadmat('./output/features.mat')

# print(data['fp1'][0][0][0][0][0][0][1][-1])


data = loadmat('./output/features.mat')
print(data.keys())

print(data['fp1'][0][1])


name_files = data['filenames']
frame_0 = data['fp1'][0][0]
frame_1 = data['fp2'][0][1]


rms = data['ml1']
entropy = data ['ml2']

print (np.size(frame_0), np.size(frame_1),np.size(rms[0]), 'rms', np.shape(entropy), 'entropy', name_files)

for i, item in enumerate(name_files):
    print (item)
    
