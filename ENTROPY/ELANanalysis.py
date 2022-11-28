from asyncore import file_dispatcher
import pandas as pd
import numpy as np
import glob


#And have to add the response, from csv for subjective ratings. Does that make sense?

# One file or all in a specific folder
file_name = 'P4_D5_G2_M5_R2_T1' # Name file if loop_on = False
loop_on = True # True if you want to loop through folder
path_files = '/Users/atillajv/CODE/RITMO/FILES/ELAN/'
file_output = '/Users/atillajv/CODE/RITMO/ENTROPY/output/ELAN/'

# Default settings 
percentage = 0.1
frac_round = 1 #Round/frac_round for moving rating to the left 
dt_L = 4.5 #Number of seconds delay in rating of user. 


list_files = []
if loop_on:
    for filepath in glob.iglob( str(path_files + '*.csv')):
        if filepath.endswith('.csv'):
            filepath_split = filepath.partition('ELAN/')
            print (filepath_split[2].strip('.csv'))
            list_files.append(filepath_split[2].strip('.csv'))
else:
    list_files = [file_name]

print(list_files)

# Initiate dataframe before loop 
store_i = 0
df_store = pd.DataFrame(columns=['Name', 'Music_Imp', 'Dance_Imp', 'Baile_Level','Guitarra_Level' ,'Step', 'Imp_Av', 'CTW_Av', 'LZ_Av','Assigned_Cat', 'Rounds'])

for file_i, file_item in enumerate(list_files):
    print('FILE BEING ANALYSED: ', file_item)
    prefix = file_item.partition('_')[0]
    dfI = pd.read_csv ('/Users/atillajv/CODE/RITMO/FILES/ELAN/' + file_item + '.csv',  delimiter=';')
    dfR = pd.read_csv( '/Users/atillajv/CODE/RITMO/FILES/Ratings/'+ prefix +'_'+ file_item +'_IMPRO.csv' )
    dfE = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/Entropy_LZ_CTW_(w=4000_s=[]_ds=4_b=on_abs=on_t0=0)_'+file_item+'.csv')[1:]
    #dfF =  pd.read_csv( '/Users/atillajv/CODE/RITMO/FILES/Ratings/P3_'+ file_name +'_FLOW.csv' )
    #print(dfE)


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
 
    #dt_left = dtI/(rounds * frac_round)
    tR_end = dfR['Time'] - dt_L
    tR_end.loc[len(tR_end.index)] = tI_1.iloc[-1]


    # Start a loop
    mean_array = []
    proportion_array = []
    Imp_average = []
    LZ_average = []
    CTW_average = []
    n=0
 

    for i in np.arange(len(dfI)):

        for j in np.arange(n,len(dfR)):
            if tR_end.iloc[j] == 0 and tR_end.iloc[j+1] < tI_0.iloc[i]:
                continue

            elif tR_end.iloc[j]< tI_0.iloc[i] and tR_end.iloc[j+1] >tI_0.iloc[i]:
                mean_array.append(dfR[' Value'].iloc[j])
                if tR_end.iloc[j+1] < tI_1.iloc[i]:
                    proportion_array.append(np.divide(tR_end.iloc[j+1]-tI_0.iloc[i] ,dtI_2.iloc[i]))
                elif tR_end.iloc[j+1] > tI_1.iloc[i]:
                    proportion_array.append(1)
            
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
        print('CHECK ==1 : ', np.sum(proportion_array), 'array:', proportion_array)

      
        list_Entropy = dfE.loc[(dfE["t0"] >= tI_0.iloc[i] ) & (dfE['t0'] <= tI_1.iloc[i]  ) ]
        LZ_average.append(list_Entropy['LZ'].mean()) 
        CTW_average.append(list_Entropy['CTW'].mean())
        df_store.loc[store_i] = {
            'Name': file_item,
            'Music_Imp': dfI['Music_Mode'].iloc[i],
            'Dance_Imp': dfI['Category'].iloc[i],
            'Step': dfI['Step'].iloc[i],
            'Imp_Av': np.sum(np.multiply(mean_array,proportion_array)),
            'CTW_Av': list_Entropy['CTW'].mean() ,
            'LZ_Av': list_Entropy['LZ'].mean(),
            'Assigned_Cat': 'IMP0',
            'Baile_Level': dfI['Baile'].iloc[i],
            'Guitarra_Level': dfI['Guitarra'].iloc[i],
            'Rounds':dfI['Bloques'].iloc[i]}
        store_i = store_i+1
        


        mean_array = []
        proportion_array = []
        


    print(len(Imp_average), 'LZ:', LZ_average )

    dfI['Imp_Av'] = Imp_average
    print(dfI)

    # Assign Category per IMPRO
    # IMP0 [0,3) Not improvised
    # IMP1 [3,5)
    # IMP2 [5,7]

   # print(dfI)

#df_store['Assigned_Cat'] = 'IMP0'
df_store.loc[df_store['Imp_Av']>= 3 , 'Assigned_Cat'] = 'IMP1'
df_store.loc[df_store['Imp_Av']>= 5 , 'Assigned_Cat'] = 'IMP2'


def InfotoColumns(df):
    dance_array = []
    music_array = []
    palo_array = []
    participant_array = []
    for i, item in enumerate(df['Name']):

        split_array = item.split('_')
        participant_array.append(split_array[0])
        dance_array.append(split_array[1])
        music_array.append(split_array[3])
        palo_array.append(split_array[4])
        #print(split_array)

    df['Dance_mode'] = dance_array
    df['Music_mode'] = music_array
    df['Palo'] = palo_array
    df['Participant'] = participant_array

InfotoColumns(df_store)
print(df_store)
df_store.to_csv(file_output + 'Testing_All_ELAN_2' + '.csv')

