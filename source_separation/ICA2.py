#https://scikit-learn.org/stable/auto_examples/decomposition/plot_ica_blind_source_separation.html

from scipy import signal
import numpy as np
from sklearn.decomposition import FastICA, PCA
from scipy.io.wavfile import read
import matplotlib.pyplot as plt


import numpy as np
from scipy import signal

np.random.seed(0)
n_samples = 2000
time = np.linspace(0, 8, n_samples)

s1 = np.sin(2 * time)  # Signal 1 : sinusoidal signal
s2 = np.sign(np.sin(3 * time))  # Signal 2 : square signal
s3 = signal.sawtooth(2 * np.pi * time)  # Signal 3: saw tooth signal

S = np.c_[s1, s2, s3]
S += 0.2 * np.random.normal(size=S.shape)  # Add noise

S /= S.std(axis=0)  # Standardize data
# Mix data
A = np.array([[1, 1, 1], [0.5, 2, 1.0], [1.5, 1.0, 2.0]])  # Mixing matrix
X = np.dot(S, A.T)  # Generate observations
print(X.shape)



audio_path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Source_Separation/'
file_name = 'P7_D5_G1_M6_R1_T1.wav'
file_1 = 'P3_D0_G1_M6_R2_T1.wav'
file_2 = 'P3_D1_G1_M1_R2_T1.wav'
name_file = file_2


samplerate, s1 = read(str( audio_path+ file_1))
s1 = s1[:,1]
samplerate2, s2 = read(str( audio_path+ file_2))
s2 = s2[:,1]

print(s1.shape, s2.shape)

def mix_sources(sources, apply_noise=False):
    for i in range(len(sources)):
        max_val = np.max(sources[i])
        if(max_val > 1 or np.min(sources[i]) < 1):
            sources[i] = sources[i] / (max_val / 2) - 0.5
            
    mixture = np.c_[[source for source in sources]]
    
    if(apply_noise):
        mixture += 0.02 * np.random.normal(size=X.shape)
        
    return mixture


x = mix_sources([s1, s2[:s1.shape[0]]], False)
print (x.shape)
x = x.T
print(x.shape)

ica = FastICA(n_components=2, whiten="arbitrary-variance")
S_ = ica.fit_transform(x)  # Reconstruct signals
A_ = ica.mixing_  # Get estimated mixing matrix

# We can `prove` that the ICA model applies by reverting the unmixing.
#assert np.allclose(x, np.dot(S_, A_.T) + ica.mean_)

pca = PCA(n_components=2)
H = pca.fit_transform(x) 



plt.figure()

models = [x, S_, H]
names = [
    "Observations (mixed signal)",
    "True Sources",
    "ICA recovered signals",
    "PCA recovered signals",
]
colors = ["red", "steelblue", "orange"]

for ii, (model, name) in enumerate(zip(models, names), 1):
    plt.subplot(3, 1, ii)
    plt.title(name)
    for sig, color in zip(model.T, colors):
        plt.plot(sig, color=color)

plt.tight_layout()
plt.show()