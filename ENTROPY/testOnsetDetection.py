import soundfile
from matplotlib import pyplot as plt
from OnsetDetection import OnsetDetection
import numpy as np
import scipy

audio_path = '/Volumes/WHITE LOTUS/FlamencoProject/L_Lausanne/Audio/all_guitar_zoom/'
file_name = 'P8_D1_G4_M6_R1_T1.wav'

downsample_factor = 32

[inputSignal, fs] = soundfile.read(audio_path + file_name)

dataDown = scipy.signal.decimate(inputSignal[:,0], downsample_factor)
signal = dataDown[10*int(fs/downsample_factor): int(20 * int(fs/downsample_factor))]

t = np.linspace(0, len(signal) / (fs/downsample_factor), len(signal))

onsetDetection = OnsetDetection(signal,fs = fs/downsample_factor, threshold = 0.7, hopTime=0.01 )
onsetTimes = onsetDetection.getOnsetTimes()


new_values_array = np.zeros(len(t), dtype=int)
matching_indices = np.searchsorted(t, onsetTimes)
new_values_array[matching_indices] = 1



f, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)

ax1.plot(t, signal)
ax1.set_ylabel('Level')
ax2.plot(onsetDetection.timeStamp+0.02, onsetDetection.detectionFunc)
ax2.set_ylabel('Onset Detection Function')
for i in range(len(onsetTimes)):
	ax1.axvline(x=onsetTimes[i], color='r', linestyle='--')
	ax2.plot([onsetTimes[i], onsetTimes[i]], [-1, 6.2], '--r')

ax2.set_ylim(-1, 6.2)
ax3.plot(t,new_values_array)
# plt.subplot(3, 1, 3)
# for i in range(len(pitches) - 1):
# 	plt.plot(pitchEstimation.timeStamp[i: i + 2], [pitches[i], pitches[i]], linewidth = 3, color='blue')
# plt.ylim(65, max(pitches) + 10)
# plt.xlabel('Time (seconds)')
# plt.ylabel('Frequency (Hz)')

plt.show()


# need to fill with ones 