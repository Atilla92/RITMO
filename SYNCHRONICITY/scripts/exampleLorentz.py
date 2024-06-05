
#Lorenz system example


import numpy as np
import matplotlib.pyplot as plt
import nolds 


# Define the Lorenz system parameters
sigma = 10.0
rho = 28.0
beta = 8.0 / 3.0

# Define the time step and number of iterations
dt = 0.0162
num_iterations = int(20/dt)

# Initialize the arrays to store the x, y, and z values
x = np.zeros(num_iterations)
y = np.zeros(num_iterations)
z = np.zeros(num_iterations)

# Set the initial values
x[0], y[0], z[0] = (10.0, 10.0, 10.0)

# Generate the time series data
for i in range(1, num_iterations):
    dx = sigma * (y[i-1] - x[i-1])
    dy = x[i-1] * (rho - z[i-1]) - y[i-1]
    dz = x[i-1] * y[i-1] - beta * z[i-1]
    x[i] = x[i-1] + dt * dx
    y[i] = y[i-1] + dt * dy
    z[i] = z[i-1] + dt * dz

t_array = np.arange(0, num_iterations*dt, dt)

# Plot x, y, and z in separate plots
plt.figure()

plt.subplot(311)
plt.plot(t_array,x)
plt.xlabel('Time')
plt.ylabel('X')

plt.subplot(312)
plt.plot(t_array, y)
plt.xlabel('Time')
plt.ylabel('Y')

plt.subplot(313)
plt.plot(t_array, z)
plt.xlabel('Time')
plt.ylabel('Z')

plt.tight_layout()
#plt.show()


# # Plot the time series data
# fig = plt.figure()
# ax = fig.gca(projection='3d')
# ax.plot(x, y, z)
# ax.set_xlabel('X')
# ax.set_ylabel('Y')
# ax.set_zlabel('Z')
# plt.show()

# Convert the time series data into a DataFrame
# data = { "X": x, "Y": y, "Z": z }
# df = pyEDM.SampleData(dataFrame=data, E=3, tau=4)


# Perform time embedding for each individual dimension
embedding_dim = 3
time_delay = 4



def takensEmbedding (data, delay, dimension):
    "This function returns the Takens embedding of data with delay into dimension, delay*dimension must be < len(data)"
    if delay*dimension > len(data):
        raise NameError('Delay times dimension exceed length of data!')    
    embeddedData = np.array([data[0:len(data)-delay*dimension]])
    for i in range(1, dimension):
        embeddedData = np.append(embeddedData, [data[i*delay:len(data) - delay*(dimension - i)]], axis=0)
    return embeddedData


embedded_x = takensEmbedding(x, time_delay, embedding_dim)
embedded_y = takensEmbedding(y, time_delay, embedding_dim)
fig, ax = plt.subplots(nrows=3,ncols=1);
ax = fig.add_subplot(3, 1, 3, projection='3d')
ax.plot(embedded_y[0,:],embedded_x[1,:],embedded_x[2,:]);

plt.show()
# embedded_y = np.array([y[i:(i+embedding_dim)] for i in range(len(y) - (embedding_dim-1)*time_delay)])
# embedded_z = np.array([z[i:(i+embedding_dim)] for i in range(len(z) - (embedding_dim-1)*time_delay)])
