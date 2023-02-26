#https://pyroomacoustics.readthedocs.io/en/pypi-release/pyroomacoustics.bss.ilrma.html#
# TERRIBLE TERRIBLE SOUND. 
#Should look into to frequency spectrum and see whether we can do something with that. 


import pyroomacoustics 
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
from scipy.io import wavfile as wf
import pandas as pd
import scipy
import numpy as np

downsample = 1

#Path to files
audio_path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Source_Separation/'
file_name = 'P3_D1_G1_M1_R1_T1'
file_1 = 'Mic360_P3_D1_G1_M1_R1_T1.wav'
file_2 = 'Zoom_P3_D1_G1_M1_R1_T1.wav'
name_file = file_2

#Import annotations
df = pd.read_csv ('/Users/atillajv/CODE/RITMO/FILES/ELAN/' + file_name + '.csv',  delimiter=';')




#Import audio
samplerate, s1 = read(str( audio_path+ file_1))
samplerate2, s2 = read(str( audio_path+ file_2))


#Minimum length
length = min(len(s1), len(s2))
s1 = s1[:length,1]
s2 = s2[:length,1]

# Downsample
s1 = scipy.signal.decimate(s1, downsample)
s2 = scipy.signal.decimate(s2, downsample)

# STFT, returns f, t, Zxx
f1, t1, Zxx1 = scipy.signal.stft(s1, fs = samplerate/downsample)
f2, t2, Zxx2 = scipy.signal.stft(s2, fs = samplerate/downsample)



# Stack together
X = np.dstack((Zxx1, Zxx2))

# X = (nframes, nfrequencies, nchannels)
output = pyroomacoustics.bss.ilrma(X, n_src=2, n_iter=20, proj_back=True, W0=None, n_components=2, return_filters=False, callback=None)
print(output[:,:,0].shape)

t1_re, s1_re = scipy.signal.istft(output[:,:,0], fs = samplerate/downsample )
t2_re, s2_re = scipy.signal.istft(output[:,:,1], fs = samplerate/downsample )

print(np.array(s2_re))

plt.figure()
plt.plot(t1_re, s1_re)
plt.plot(t2_re, s2_re)
plt.show()

wf.write(str(audio_path +name_file +'_s1_predicted_ICA4.wav'), int(samplerate/downsample),s1_re.astype(np.float32))
wf.write(str(audio_path +name_file +'_s2_predicted_ICA4.wav'), int(samplerate/downsample),s2_re.astype(np.float32))