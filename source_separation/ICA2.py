#https://scikit-learn.org/stable/auto_examples/decomposition/plot_ica_blind_source_separation.html

from scipy import signal
import numpy as np
from sklearn.decomposition import FastICA, PCA
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
from scipy.io import wavfile as wf
from coroica import CoroICA
import pandas as pd
import scipy
import matplotlib.pyplot as plt
import numpy as np
from scipy import signal

# For no xtrain and xtest are the same, try with another test .wav file. 
# Perhaps try with different mics from goPro. Perhaps front view and feet on last recordings. or zoom360 and feet. See whether it makes a difference. 


#audio_path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Source_Separation/'
audio_path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/'
drums_path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/separated/htdemucs_6s/separated/all_drums/'

# Output folder
output_folder = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Audio/separated/htdemucs_6s/separated/ICA2/'
#file_name = 'P7_D6_G1_M6_R2_T1'
file_name = 'P3_D1_G1_M1_R1_T1'

#file_1 = 'GoProFeet_P7_D6_G1_M6_R2_T1.wav'
#file_2 = 'GoProFeet_P3_D1_G1_M1_R1_T1.wav'
#file_2 = 'Mic360_P7_D6_G1_M6_R2_T1.wav'
#file_1 = 'Mic360_P3_D1_G1_M1_R1_T1.wav'



#name_file = file_2

df = pd.read_csv ('/Users/atillajv/CODE/RITMO/FILES/ELAN/' + file_name + '.csv',  delimiter=';')

# Code settings
downsample = 1 #How much to downsample
set_threshold  = False #Set threshold manually in plot
get_labels = True #Get group labels from ELAN

def plotFig_SetCoord(x):
    """
    Fetch coordinates when clicking on plot
    Fetches the last clicked event
    x: list 
    y: list
    returns coordinates [x,y]
    """
    fig = plt.figure()
    plt.plot(x)

    def onclick(event):
        global ix, iy
        ix, iy = event.xdata, event.ydata
        #print ('x = %d, y = %d'%(ix, iy))

        global coords
        coords = [ix, iy]
        return coords

    cid = fig.canvas.mpl_connect('button_press_event', onclick)
    plt.show()
    return coords



def setThreshold(s1):
    """"Set threshold for analysis"""

    coords = plotFig_SetCoord(s1)
    print(coords, 'coords')
    
    plt.close()
    return coords


# Import audio
samplerate, s1 = read(str( audio_path+ file_name + '.wav'))
samplerate2, s2 = read(str( drums_path+ file_name + '.wav'))



# Downsample
s1 = scipy.signal.decimate(s1[:,1], downsample)
s2 = scipy.signal.decimate(s2[:,1], downsample)

#Setting threshold

if set_threshold:
    th_s1 = int(setThreshold(s1)[0])
    th_s2 = int(setThreshold(s2)[0])

else:
    # th_s1 = 2867
    # th_s2 = 1925    
    th_s1 = 9626
    th_s2 = 5097


s1 = s1[th_s1:]
s1 = s2[th_s2:]

#Minimum length
length = min(len(s1), len(s2))
s1 = s1[:length]
s2 = s2[:length]



if set_threshold:
    plt.figure()
    plt.plot(s1)
    plt.plot(s2)
    plt.show()


def getLabels(samplerate, s1, s2, df):
    sub_s1 = []
    sub_s2 = []
    s1_full =[]
    s2_full = []
    labels_full = []
    parts_full = []
    dt = np.divide(np.arange(len(s1)), samplerate)

    for index, row in df.iterrows():
        begin= np.argmax(dt >= row['Begin Time - ss.msec'])
        end = np.argmax(dt > row['End Time - ss.msec'])
        sub_s1 = s1[begin:(end-1)].tolist()
        sub_s2 = s2[begin:(end-1)].tolist()
        labels = [row['Baile'] for x in range(len(sub_s1))]
        parts =  [index for x in range(len(sub_s1))]
        s1_full = s1_full + sub_s1 
        s2_full = s2_full + sub_s2
        labels_full = labels_full + labels
        parts_full = parts_full + parts
    return s1_full, s2_full, np.array(labels_full), np.array(parts_full)


if get_labels:
    s1, s2, groups, partition  =getLabels(samplerate, s1, s2, df)


x = np.c_[[s1,s2]]
print (x.shape)
x = x.T
print(x.shape)



#x = np.asarray_chkfinite(x)
#print('PASSED CHECK')

c = CoroICA()

#c.fit(x)

c.fit(x, group_index = groups)
# c.V_ holds the unmixing matrix

recovered_sources = c.transform(x)
print(recovered_sources.shape)

#s3 = recovered_sources[:,1] - recovered_sources[:,0]

plt.figure()
plt.plot(recovered_sources[:,0])
plt.plot(recovered_sources[:,1])
#.plot(s3)
plt.show()



wf.write(str(output_folder  +file_name +'_s1_predicted_ICA2.wav'), int(samplerate/downsample),recovered_sources[:,0].astype(np.float32))
wf.write(str(output_folder +file_name +'_s2_predicted_ICA2.wav'), int(samplerate/downsample),recovered_sources[:,1].astype(np.float32))
#wf.write(str(audio_path +name_file +'_s3_predicted_ICA2.wav'), int(samplerate/downsample),s3.astype(np.float32))



#https://scikit-learn.org/stable/auto_examples/decomposition/plot_ica_blind_source_separation.html
# plt.figure()
# plt.plot(recovered_sources)
# plt.show()
# ica = FastICA(n_components=2, whiten="arbitrary-variance")
# S_ = ica.fit_transform(x)  # Reconstruct signals
# A_ = ica.mixing_  # Get estimated mixing matrix

# # We can `prove` that the ICA model applies by reverting the unmixing.
# #assert np.allclose(x, np.dot(S_, A_.T) + ica.mean_)

# pca = PCA(n_components=2)
# H = pca.fit_transform(x) 

# #print(S_[:,1].shape)
# plt.figure()
# # plt.plot(S_[:,1])
# # plt.show()
# models = [x, S_]
# names = [
#     "Observations (mixed signal)",
#     "ICA recovered signals",
#     "PCA recovered signals",
#     'A'
# ]
# colors = ["red", "steelblue", "orange"]

# for ii, (model, name) in enumerate(zip(models, names), 1):
#     plt.subplot(2, 1, ii)
#     plt.title(name)
#     for sig, color in zip(model.T, colors):
#         plt.plot(sig, color=color)

# plt.tight_layout()
# plt.show()

# wf.write(str(audio_path +file_name +'_s1_predicted.wav'), samplerate, S_[:,0].astype(np.float32))
# wf.write(str(audio_path +file_name +'_s2_predicted.wav'), samplerate, S_[:,1].astype(np.float32))
