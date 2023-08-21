import numpy as np
import pandas as pd
import glob
import matplotlib.pyplot as plt


input_drums = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095_drums/'
input_ensemble = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095/'
input_guitar = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/all_experiments_095_guitar_zd/'
loop_on = True


name_file = 'P7_D5_G1_M6_R1_T1.wav'



name_files = []
#Load Data
if loop_on:
    for files in glob.iglob(str(input_drums+ '*.csv')):
        name_files.append(files.rsplit('/')[-1])

else:
 name_files = [name_file]

averages_dict = {}
print(name_files)
#ns_file = np.random.randint(0, len(name_files), size = 1)

for i, name_file in enumerate(name_files):
    #name_file = name_files[ns_file[0]]
    try:
        #data_ensemble = pd.read_csv(input_ensemble + name_file)[1:]
        data_drums = pd.read_csv(input_drums + name_file)[1:]
        data_guitar = pd.read_csv(input_guitar + name_file)[1:]

        #t_ensemble = np.linspace(0,1 len(data_ensemble['LZ'].to_numpy()))

        
        #LZ_dt_ensemble = np.diff(data_ensemble['LZ'].to_numpy())
        LZ_dt_guitar = np.diff(data_guitar['LZ'].to_numpy())
        LZ_dt_drums = np.diff(data_drums['LZ'].to_numpy())





        # Define different time lags
        time_lags = range(0, 6)  # Lag values from 0 to 10
        max_length = min(len(LZ_dt_drums), len(LZ_dt_guitar))
        LZ_dt_guitar = LZ_dt_guitar[:max_length]
        LZ_dt_drums = LZ_dt_drums[:max_length]

        # Create a dictionary to store binary output for each time lag
        binary_output_dict = {}


        # Calculate and store binary output series for each time lag
        for lag in time_lags:
            shifted_series2 = np.roll(LZ_dt_drums, -lag)
            
            # Calculate the binary output based on your conditions
            binary_output = np.where((np.sign(LZ_dt_guitar) == np.sign(shifted_series2)), 1, 0)
            
            binary_output_dict[f"Lag_{lag}"] = binary_output

        # Create a DataFrame from the dictionary
        binary_output_df = pd.DataFrame(binary_output_dict, index=range(len(LZ_dt_drums)))


        # Calculate the average sum for each column and add as the last row
        average_row = binary_output_df.mean()  # Calculate average for each column
        avg_row = np.mean(average_row.to_numpy()) # Calculate avergae for all columns
        averages_dict[name_file.strip('.csv')] = average_row.to_numpy()
        #binary_output_df = binary_output_df.append(average_row, ignore_index=True)
    
    except:
        print('File not found:' + name_file)


# columns = [f"Lag_{lag}" for lag in time_lags]
# averages_df = pd.DataFrame.from_dict(averages_dict, orient="index", columns= columns)
# averages_df["Row_Avg"] = averages_df.mean(axis=1)



# Create a DataFrame from the dictionary
averages_df = pd.DataFrame.from_dict(averages_dict, orient="index", columns=[f"Lag_{lag}" for lag in time_lags])

# Add a new row at the beginning with average values per column
column_averages = averages_df.mean()
column_averages.name = "Column_Avg"
averages_df = pd.concat([pd.DataFrame([column_averages], columns=averages_df.columns), averages_df])

# Add a new column for row-wise averages
averages_df["Row_Avg"] = averages_df.mean(axis=1)



print(averages_df)


# print(binary_output_df)
# f, (ax1,ax2, ax3) = plt.subplots(3,1 , sharex= True)
# #ax1.plot(data_ensemble['t0'][1:max_length],np.sign(LZ_dt_ensemble[:max_length])  )
# ax2.plot(data_drums['t0'][1:max_length+1], np.sign(LZ_dt_drums)  )
# ax3.plot(data_guitar['t0'][1:max_length+1], np.sign(LZ_dt_guitar)  )
# plt.show()
# print(LZ_dt_drums)
# print(LZ_dt_guitar)
# print( np.where((np.sign(LZ_dt_drums) == np.sign(LZ_dt_guitar)), 1, 0))

# # Calculate differences at different time lags
# for lag in time_lags:
#     if lag == 0:
#         differences = LZ_dt_drums - LZ_dt_guitar
#     else:
#         differences = LZ_dt_drums[:-lag] - LZ_dt_guitar[lag:]

#     print(f"Differences at lag {lag}: {differences}")


#two things to store here, one is LZ_dt which i could probably implement in the mainOnset as well. 

