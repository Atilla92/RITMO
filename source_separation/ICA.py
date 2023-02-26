#https://gowrishankar.info/blog/blind-source-separation-using-ica-a-practical-guide-to-separate-audio-signals/

import numpy as np 
from scipy.io.wavfile import read
from scipy.io import wavfile as wf

audio_path = '/Users/atillajv/CODE/FILES/PILOT_SEV_APRIL_2022/Source_Separation/'
file_name = 'P3_D1_G1_M1_R1_T1'
file_1 = 'Mic360_P3_D1_G1_M1_R1_T1.wav'
file_2 = 'Zoom_P3_D1_G1_M1_R1_T1.wav'
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
print(f'Shape of s1: {s1.shape}, s2: {s1.shape}, Linear Mix: {x.shape}')
wf.write(str(audio_path +name_file +'_mixed.wav'), samplerate, x.mean(axis=0).astype(np.float32))


def center(x):
    x = np.array(x)
    return x - x.mean(axis=1, keepdims=True)

def whiten(x):
    eigen_values, eigen_vectors = np.linalg.eigh(np.cov(x))
    D = np.diag(eigen_values)
    sqrt_inverse_D = np.sqrt(np.linalg.inv(D))
    x_whiten = eigen_vectors @ (sqrt_inverse_D @ (eigen_vectors.T @ x))
    
    print(f'Shape of Eigen Values: {eigen_values.shape}, Eigen Vectors: {eigen_vectors.shape}, Whitened Data: {x_whiten.shape}')
    
    return x_whiten, D, eigen_vectors

X_whiten, D, E = whiten(
    center(x)
)
D, E

def objFunc(x):
    return np.tanh(x)

def dObjFunc(x):
    return 1 - (objFunc(x) ** 2)

def calc_w_hat(W, X):
    # Implementation of the eqn. Towards Convergence
    w_hat = (X * objFunc(W.T @ X)).mean(axis=1) - dObjFunc(W.T @ X).mean() * W
    w_hat /= np.sqrt((w_hat ** 2).sum())
    
    return w_hat

def ica(X, iterations, tolerance=1e-5):
    num_components = X.shape[0]
    
    W = np.zeros((num_components, num_components), dtype=X.dtype)
    distances = {i: [] for i in range(num_components)}
    
    for i in np.arange(num_components):
        w = np.random.rand(num_components)
        for j in np.arange(iterations):
            w_new = calc_w_hat(w, X)
            if(i >= 1):
                w_new -= np.dot(np.dot(w_new, W[:i].T), W[:i])
            distance = np.abs(np.abs((w * w_new).sum()) - 1)
            
            w = w_new
            if(distance < tolerance):
                print(f'Convergence attained for the {i+1}/{num_components} component.')
                print(f'Component: {i+1}/{num_components}, Step: {j}/{iterations}, Distance: {distance}\n')
            
                break;
                
            distances[i].append(distance)
            
            if(j % 50 == 0):
                print(f'Component: {i+1}/{num_components}, Step: {j}/{iterations}, Distance: {distance}')
            
            
                
        W[i, :] = w
    S = np.dot(W, X)
    
    return S, distances

S, distances = ica(X_whiten, iterations=100)


wf.write(str(audio_path +name_file +'_s1_predicted_ICA1.wav'), samplerate, S[0].astype(np.float32))
wf.write(str(audio_path +name_file +'_s2_predicted_ICA1.wav'), samplerate, S[1].astype(np.float32))