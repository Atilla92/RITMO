
import numpy as np
import matplotlib.pyplot as plt
from multiSyncPy import data_generation as dg
from multiSyncPy import synchrony_metrics as sm
import scipy.signal
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.io.wavfile import read


from pyts.image import RecurrencePlot


# Create time-delayed version of the arrays. 
# First check with a simple sine wave, see if you get the same plots. 

# 1 create a noisy sine wave and plot

# 2 create a time delayed copy and plot

# 3 Create recurrence plot of these two time series. 

# Create a noisy sine wave
t = np.arange(0.0, 100.0, 0.1)
sine_wave = np.sin(2 * np.pi/25 * t)
noise = np.random.normal(0, 0.1, len(t))
noisy_sine_wave = sine_wave + noise

# Plot the noisy sine wave
plt.figure(1)
plt.subplot(211)
plt.plot(t, noisy_sine_wave)
plt.title('Noisy Sine Wave')

# Create a time delayed copy
delayed_sine_wave = np.roll(noisy_sine_wave, 30)  # 30 steps time delay

# Plot the time delayed copy
plt.subplot(212)
plt.plot(t, delayed_sine_wave)
plt.title('Time Delayed Sine Wave')
#plt.show()


stacked_array = np.vstack((noisy_sine_wave, delayed_sine_wave))


recurrence_matrix = sm.recurrence_matrix(
    stacked_array, radius= 0.3
)
rqa_metrics = sm.rqa_metrics(recurrence_matrix)

print(rqa_metrics)


# Create a heatmap using Seaborn
# sns.heatmap(recurrence_matrix, annot=True, cmap='YlGnBu', cbar=False, linewidths=.5)

# # Show the plot
# plt.show()

dense_matrix = np.array(recurrence_matrix)

# Display the dense matrix as a black and white image
plt.matshow(dense_matrix, cmap='binary')
#plt.show()



# Create recurrence plot of the two time series
rp = RecurrencePlot(threshold='point', percentage=30)
X_rp = rp.fit_transform([noisy_sine_wave, delayed_sine_wave])

# Plot the recurrence plot
plt.figure(2)
plt.imshow(X_rp[0], cmap='binary', origin='lower')
plt.title('Recurrence Plot')
#plt.show()




## PyRQA

from pyrqa.time_series import TimeSeries
from pyrqa.settings import Settings
from pyrqa.analysis_type import Classic
from pyrqa.neighbourhood import FixedRadius
from pyrqa.metric import EuclideanMetric
from pyrqa.computation import RQAComputation


time_series = TimeSeries(noisy_sine_wave,
                         embedding_dimension=2,
                         time_delay=30)

print(time_series)

settings = Settings(time_series,
                    analysis_type=Classic,
                    neighbourhood=FixedRadius(0.3),
                    similarity_measure=EuclideanMetric,
                    theiler_corrector=1)
computation = RQAComputation.create(settings,
                                    verbose=True)
result = computation.run()
result.min_diagonal_line_length = 2
result.min_vertical_line_length = 2
result.min_white_vertical_line_length = 2
print(result)


from pyrqa.computation import RPComputation
from pyrqa.image_generator import ImageGenerator
computation = RPComputation.create(settings)
result = computation.run()
ImageGenerator.save_recurrence_plot(result.recurrence_matrix_reverse,
                                    'recurrence_plot.png')


