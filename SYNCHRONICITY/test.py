# Testing multiSync.py package. 

import numpy as np
import scipy
from multiSyncPy import data_generation as dg
from multiSyncPy import synchrony_metrics as sm
import scipy.signal


# Creating some sampling data to work with


kuramoto_test_data = dg.kuramoto_data(
K = 0.5,
phases = np.array([0, 0.4 * np.pi, 0.8 * np.pi, 1.2 * np.pi, 1.6 * np.pi]),
omegas = np.array ([1.0, 1.5, 2.0, 2.5, 3.0]),
alpha = 0.5, 
d_t = 0.01,
length = 1000
)

print(kuramoto_test_data.shape)

autoregressive_test_data = dg.autoregressive_data(
    length=1000,
    phi_1= 0.7, 
    phi_2= 0.3,
    epsilon= 0.1,
    c = 0
)


symbolic_entropy = sm.symbolic_entropy(kuramoto_test_data)
print(autoregressive_test_data.shape)

print('symbolic entropy:', sm.symbolic_entropy(kuramoto_test_data))

recurrence_matrix = sm.recurrence_matrix(kuramoto_test_data, radius= 0.1)

rqa_metrics = sm.rqa_metrics(recurrence_matrix)

print(recurrence_matrix.shape, ' metrics: ', rqa_metrics)


cohorence_k = sm.coherence_team(kuramoto_test_data)
sm.sum_normalized_csd(kuramoto_test_data)
print(cohorence_k)

kuramoto_test_data_phases = np.angle(scipy.signal.hilbert(kuramoto_test_data - kuramoto_test_data.mean(axis=1).reshape(-1,1)))

rho_k = sm.rho(kuramoto_test_data_phases)

#print(rho_k)


# Windowing function

symbolic_entropy_windowed = sm.apply_windowed(
    kuramoto_test_data,
    sm.symbolic_entropy,
    window_length= 100,
    step = 100 # if step 100, window length 100, there is no overlap
)

print(symbolic_entropy)
print(symbolic_entropy_windowed)


# Statistical testing

# Creating a sample dataset as a list
rng = np.random.default_rng()
kuramoto_test_data_sample = []

for trial in range(100):
    kuramoto_test_data_sample.append(
        dg.kuramoto_data(
            K = 0.5,
            phases = np.array([0, 0.4 * np.pi, 0.8 * np.pi, 1.2 * np.pi, 1.6 * np.pi]),
            omegas = rng.exponential(1, 5) * 2,
            alpha = 0.5,
            d_t = 0.01,
            length= 1000

        )
    )


# Getting phases of sample data
kuramoto_test_data_sample_phases = [np.angle(scipy.signal.hilbert(
    kuramoto_test_data - kuramoto_test_data.mean(axis = 1).reshape(-1,1))) for trial in kuramoto_test_data_sample
]

test_results = sm.kuramoto_weak_null(kuramoto_test_data_sample)

print(test_results)