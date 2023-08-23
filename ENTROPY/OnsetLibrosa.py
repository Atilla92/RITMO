import librosa
from scipy.io.wavfile import read
import numpy as np
import matplotlib.pyplot as plt
import scipy
from functionsE import findDivisor

audio_path = '/Volumes/WHITE LOTUS/FlamencoProject/AUDIO/DRUMS_DEMUCS/'
loop_off = 'P10_D0_G5_M6_R1_T1.wav'
target_divisor = 8


#sr, y = read(str( audio_path+ loop_off))
y1, sr = librosa.load(audio_path + loop_off, sr=None, mono=True, dtype='float32')






dFactor = findDivisor(target_divisor, sr)

y2 = scipy.signal.decimate(y1, dFactor)

sr2 = int(sr/dFactor)
print(sr, sr2, dFactor, 'SAMPLINGRATES')
x1  = np.arange(len(y1))
x2  = np.arange(len(y2))/sr2
# plt.plot(x, y)
# plt.show()
onset_t1 = librosa.onset.onset_detect(y=y1, sr=sr, units='time')
onset_t2 = librosa.onset.onset_detect(y=y2, sr=sr2, units='time')
new_values_array = np.zeros(len(x2), dtype=int)
matching_indices = np.searchsorted(x2, onset_t2)
new_values_array[matching_indices] = 1  
data2 = new_values_array



# o_env = librosa.onset.onset_strength(y=y1, sr=sr)

# times = librosa.times_like(o_env, sr=sr)
# onset_frames = librosa.onset.onset_detect(onset_envelope=o_env, sr=sr)
# print(len(times), len(onset_frames), 'lenght no down')

# o_env2 = librosa.onset.onset_strength(y=y2, sr=sr2)
# times2 = librosa.times_like(o_env2, sr=sr2)
# onset_frames2 = librosa.onset.onset_detect(onset_envelope=o_env2, sr=sr2)
# print(len(onset_t2),len(o_env2),len(times2), len(onset_frames2), 'len downsampled')

# f, (ax1, ax2) = plt.subplots(2,1, sharex= True)
# ax1.plot(x1,onset_t1)
# ax2.plot(x2,onset_t2)
# plt.show()





# print(times, times[onset_frames])

#D = np.abs(librosa.stft(y))
fig, ax = plt.subplots(nrows=3, sharex=True)
# librosa.display.specshow(librosa.amplitude_to_db(D, ref=np.max),
#                          x_axis='time', y_axis='log', ax=ax[0])
# ax[0].set(title='Power spectrogram')
# ax[0].label_outer()
ax[0].plot(x2, y2)

# #ax[0].axvline(x=times[onset_frames], color='r', linestyle='--')
# ax[0].vlines(times2[onset_frames2], -0.2, 0.2, color='r', alpha=0.9,
# #            linestyle='--', label='Onsets')
# ax[2].plot(times2, o_env2, label='Onset strength')
# ax[2].vlines(times2[onset_frames2], 0, o_env.max(), color='r', alpha=0.9,
#            linestyle='--', label='Onsets')

ax[1].plot(x2, data2 )
ax[1].legend()
plt.show()


