from asyncore import file_dispatcher
import pandas as pd
import numpy as np

file_name = 'P3_D6_G1_M6_R2_T1'
dfI = pd.read_csv ('/Users/atillajv/CODE/RITMO/FILES/ELAN/' + file_name + '.csv')
dfR = pd.read_csv( '/Users/atillajv/CODE/RITMO/FILES/Ratings/P3_'+ file_name +'_IMPRO.csv' )
dfE = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/Entropy_LZ_CTW_(w=4000_s=[]_ds=4_b=on_abs=on_t0=0)_'+file_name +'.csv')
#dfF =  pd.read_csv( '/Users/atillajv/CODE/RITMO/FILES/Ratings/P3_'+ file_name +'_FLOW.csv' )
#print(dfE)

# Default settings 
percentage = 0.1
frac_round = 1 #Round/frac_round for moving rating to the left 
dt_L = 4.5 #Number of seconds delay in rating of user. 


# Add first row with time 0
dfR.loc[-1] =[0, dfR[' Value'].iloc[0]]
dfR.index = dfR.index + 1  # shifting index
dfR = dfR.sort_index()  # sorting by index


# Estimate interval 
# Add percentage 10%
dtI = dfI['Duration - ss.msec']
rounds = dfI['Bloques']
tI_0 = dfI['Begin Time - ss.msec'] - (dtI * percentage )
tI_1 = dfI['End Time - ss.msec'] + (dtI * percentage )
dtI_2 = tI_1 - tI_0

#Append end time to last row 
dfR.loc[len(dfR.index)] = [tI_1.iloc[-1] ,dfR[' Value'].iloc[-1]]

#Estimate which values fall within interval. 

# Move ratings to the left 1/2 round
dt_left = dtI/(rounds * frac_round)
tR_end = dfR['Time'] - dt_L
tR_end.loc[len(tR_end.index)] = tI_1.iloc[-1]


# Start a loop
mean_array = []
proportion_array = []
Imp_average = []
n=0

for i in np.arange(len(dfI)):

    for j in np.arange(n,len(dfR)):
        print(tR_end.iloc[j], tI_1.iloc[i], 'which value')
        if tR_end.iloc[j] == 0 and tR_end.iloc[j+1] < tI_0.iloc[i]:
            continue

        elif tR_end.iloc[j]< tI_0.iloc[i] and tR_end.iloc[j+1] >tI_0.iloc[i]:
            mean_array.append(dfR[' Value'].iloc[j])
            proportion_array.append(np.divide(tR_end.iloc[j+1]-tI_0.iloc[i] ,dtI_2.iloc[i]))
        
        elif tR_end.iloc[j] > tI_0.iloc[i] and tR_end.iloc[j+1] < tI_1.iloc[i]:
            mean_array.append(dfR[' Value'].iloc[j])
            proportion_array.append(np.divide(tR_end.iloc[j+1]-tR_end.iloc[j] ,dtI_2.iloc[i]))

        elif tR_end.iloc[j] < tI_1.iloc[i] and tR_end.iloc[j+1] >= tI_1.iloc[i]:
            mean_array.append(dfR[' Value'].iloc[j])
            proportion_array.append(np.divide(tI_1.iloc[i]-tR_end.iloc[j] ,dtI_2.iloc[i]))

        elif tR_end.iloc[j] < tI_0.iloc[i] and tR_end.iloc[j+1] > tI_1.iloc[i]:
            mean_array.append(dfR[' Value'].iloc[j])
            proportion_array.append(1)
        

        elif tR_end.iloc[j]>= tI_1.iloc[i]:
            n=j-2
            break
    Imp_average.append(np.sum(np.multiply(mean_array,proportion_array)))
    mean_array = []
    proportion_array = []

print(len(Imp_average))

dfI['Imp_Av'] = Imp_average
print(dfI)

# Assign Category per IMPRO
# IMP0 [0,3) Not improvised
# IMP1 [3,5)
# IMP2 [5,7]
dfI['Assigned_Cat'] = 'IMP0'
dfI.loc[dfI['Imp_Av']>= 3 , 'Assigned_Cat'] = 'IMP1'
dfI.loc[dfI['Imp_Av']>= 5 , 'Assigned_Cat'] = 'IMP2'
print(dfI)

# Left to do:
# Loop through files
# Store in DF, 