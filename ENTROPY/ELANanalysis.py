from asyncore import file_dispatcher
import pandas as pd
import numpy as np
import glob


#And have to add the response, from csv for subjective ratings. Does that make sense?

# One file or all in a specific folder
file_name = 'P5_D1_G3_M6_R1_T1' # Name file if loop_on = False
loop_on = True # True if you want to loop through folder
path_files = '/Users/atillajv/CODE/RITMO/FILES/ELAN/'
file_output = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/17_Dec_2022/' #check that this is the same as input file for entropy

# Default settings 
percentage = 0.1
frac_round = 1 #Round/frac_round for moving rating to the left 
dt_L = 2 #Number of seconds delay in rating of user. 


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
df_store = pd.DataFrame(columns=['Name', 'Music_Imp', 'Dance_Imp', 'Baile_Level','Guitarra_Level' ,'Step', 
'Imp_subj','Imp_avg', 'Flow_subj', 'Flow_avg',
'CTW', 'LZ','Assigned_Cat', 'Rounds', 
'Q1a',
'Q1b',
'Q2a',
'Q2b',
'Q2c',
'Q2d',
'Q2e',
'Q2f',
'Q2g',
'Q2h',
'Q2i',
'Q2j',
'Q3a',
'Q3b',
'Q4a',
'Q4b',
'Abs_Av',
'Perf_Av',
'SFS',
'Dance_mode',
'Music_mode',
'Palo',
'LZ_Av',
'CTW_Av',
'MIR_entropy',
'MIR_entropy_avg',
'MIR_rms',
'MIR_rms_avg',
'MIR_novelty',
'MIR_novelty_avg',
'var_entropy',
'var_entropy_avg'
])

for file_i, file_item in enumerate(list_files):
    print('FILE BEING ANALYSED: ', file_item)
    prefix = file_item.partition('_')[0]
    dfI = pd.read_csv ('/Users/atillajv/CODE/RITMO/FILES/ELAN/' + file_item + '.csv',  delimiter=';')
    dfR = pd.read_csv( '/Users/atillajv/CODE/RITMO/FILES/Ratings/'+ prefix +'_'+ file_item +'_IMPRO.csv' )
    dfR_flow = pd.read_csv( '/Users/atillajv/CODE/RITMO/FILES/Ratings/'+ prefix +'_'+ file_item +'_FLOW.csv' )
    #dfE = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/Entropy_LZ_CTW_(w=4000_s=[]_ds=4_b=on_abs=on_t0=0)_'+file_item+'.csv')[1:]
    dfE = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/28_Nov_2022/'+file_item+'.csv')[1:]
    dfS = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/Subjective/DuringExperiments_Sevilla_06102022_DropW_Entropy.csv')
    dfMIR_entropy = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/ENTROPY/' + file_item + '.csv')
    dfMIR_novelty = pd.read_csv('/Users/atillajv/CODE/RITMO/FILES/MIR/NOVELTY/' + file_item + '.csv')
    df_var = pd.read_csv('/Users/atillajv/CODE/RITMO/ENTROPY/output/main/17_Dec_2022/var/'+file_item+'.csv')[1:]
    #dfF =  pd.read_csv( '/Users/atillajv/CODE/RITMO/FILES/Ratings/P3_'+ file_name +'_FLOW.csv' )
    #print(dfE)


    # Estimate interval 
    # Add percentage 10%
    
    dtI = dfI['Duration - ss.msec']
    rounds = dfI['Bloques']
    tI_0 = dfI['Begin Time - ss.msec'] - (dtI * percentage )
    tI_1 = dfI['End Time - ss.msec'] + (dtI * percentage )
    dtI_2 = tI_1 - tI_0

    #Append end time to last row 
    dfR.loc[len(dfR.index)] = [tI_1.iloc[-1] ,dfR[' Value'].iloc[-1]]
    dfR_flow.loc[len(dfR_flow.index)] = [tI_1.iloc[-1] ,dfR[' Value'].iloc[-1]]
    #dfR.loc[len(dfR.index)] = [tI_1.iloc[-1] ,dfR[' Value'].iloc[-1]]


    #Estimate which values fall within interval. 
    # Move ratings to the left 1/2 round
  
    #dt_left = dtI/(rounds * frac_round)
    dfR['Time_2'] = dfR['Time'] - dt_L    
    # Add first row with time 0
    dfR.loc[-1] = [0, dfR[' Value'].iloc[0], 0]
    dfR.index = dfR.index + 1  # shifting index
    dfR = dfR.sort_index()  # sorting by index
    dfR.loc[len(dfR.index)] = [tI_1.iloc[-1], dfR[' Value'].iloc[-1], tI_1.iloc[-1]]
    dfR = dfR.sort_values(by = 'Time_2')
    tR_end = dfR['Time_2']
    #print(tR_end)

    #print(dfR, 'start')


    dfR_flow['Time_2'] = dfR_flow['Time'] - dt_L    
    # Add first row with time 0
    dfR_flow.loc[-1] = [0, dfR_flow[' Value'].iloc[0], 0]
    dfR_flow.index = dfR_flow.index + 1  # shifting index
    dfR_flow = dfR_flow.sort_index()  # sorting by index
    dfR_flow.loc[len(dfR_flow.index)] = [tI_1.iloc[-1], dfR_flow[' Value'].iloc[-1], tI_1.iloc[-1]]
    dfR_flow = dfR_flow.sort_values(by = 'Time_2')
    tR_end_flow = dfR_flow['Time_2']

   # print(dfR_flow, ' FLOOW')

   # Arrays for MIR values

    # Start a loop
    mean_array = []
    proportion_array = []
    mean_array_flow = []
    proportion_array_flow = []
    Imp_average = []
    LZ_average = []
    CTW_average = []
    MIR_entropy_avg = []
    MIR_rms_avg = []
    n=0
    m=0
 
    #print(dfR_flow, tR_end_flow, tI_0, tI_1, tR_end)

    for i, item in enumerate(tI_0):

        for j in np.arange(n,len(dfR)-1):
#            print(tR_end.iloc[j],tR_end.iloc[j+1],'TR' ,tI_0.iloc[i], 'TI', tI_1.iloc[i],j, i )
            if tR_end.iloc[j] == 0 and tR_end.iloc[j+1] < tI_0.iloc[i]:
#                print('Test0')
                continue

            elif tR_end.iloc[j]< tI_0.iloc[i] and tR_end.iloc[j+1] >tI_0.iloc[i]:
#                print('Test1')     
                if tR_end.iloc[j+1] <= tI_1.iloc[i]:
                    mean_array.append(dfR[' Value'].iloc[j])
                    proportion_array.append(np.divide(tR_end.iloc[j+1]-tI_0.iloc[i] ,dtI_2.iloc[i]))
                elif tR_end.iloc[j+1] >= tI_1.iloc[i]:
                    mean_array.append(dfR[' Value'].iloc[j])
                    proportion_array.append(1)
            
            elif tR_end.iloc[j] > tI_0.iloc[i] and tR_end.iloc[j+1] < tI_1.iloc[i]:
#                print('Test2')
                mean_array.append(dfR[' Value'].iloc[j])
                proportion_array.append(np.divide(tR_end.iloc[j+1]-tR_end.iloc[j] ,dtI_2.iloc[i]))
        
            elif tR_end.iloc[j] < tI_1.iloc[i] and tR_end.iloc[j+1] >= tI_1.iloc[i]:
#                print('Test3')            
                mean_array.append(dfR[' Value'].iloc[j])
                proportion_array.append(np.divide(tI_1.iloc[i]-tR_end.iloc[j] ,dtI_2.iloc[i]))

            elif tR_end.iloc[j] < tI_0.iloc[i] and tR_end.iloc[j+1] > tI_1.iloc[i]:
#                print('Test4')
                mean_array.append(dfR[' Value'].iloc[j])
                proportion_array.append(1)
            
            elif proportion_array == [] and tR_end.iloc[j] > tI_0.iloc[i]:
#                print('test new2')
                mean_array.append(dfR[' Value'].iloc[j])
                proportion_array.append(np.divide(tR_end.iloc[j]-tI_0.iloc[i] ,dtI_2.iloc[i]))

            elif tR_end.iloc[j]>= tI_1.iloc[i]:
#                print('Test5')
                if n<1:
                    n=j-1
                else:
                    n = j-2
                  
                break

    
        Imp_average.append(np.sum(np.multiply(mean_array,proportion_array)))
        
        if np.sum(proportion_array) <0.8:
            print('CHECK ==1 : ', np.sum(proportion_array), 'array:', proportion_array, mean_array)
            #print(tR_end.iloc[j],tR_end.iloc[j+1],'TR' ,tI_0.iloc[i], 'TI', tI_1.iloc[i],j, i )
        #Fetching LZ entropy in intervals
        list_Entropy = dfE.loc[(dfE["t0"] >= tI_0.iloc[i] ) & (dfE['t0'] <= tI_1.iloc[i]  ) ]

        # Fetching Spectral Entropy MIR in intervals
        list_MIR_entropy = dfMIR_entropy.loc[(dfMIR_entropy["entropy_t0"] >= tI_0.iloc[i] ) & (dfMIR_entropy['entropy_t0'] <= tI_1.iloc[i]  ) ]
       
        # Fetching Novelty MIR in intervals
        list_MIR_novelty = dfMIR_novelty.loc[(dfMIR_novelty["novelty_t0"] >= tI_0.iloc[i] ) & (dfMIR_novelty['novelty_t0'] <= tI_1.iloc[i]  ) ]
       
        # Fetching Variance Entropy within interval
        list_var =  df_var.loc[(df_var["t0"] >= tI_0.iloc[i] ) & (df_var['t0'] <= tI_1.iloc[i]  ) ]

        #print(MIR_rms_avg, 'MIR!!!!')
       
    # for i, item in enumerate(tI_0):

        for k in np.arange(m,len(dfR_flow)-1):
            #print(tR_end[j],tR_end[j+1],'TR' ,tI_0[i], 'TI', tI_1[i], )
            #print(tR_end_flow.iloc[k],tR_end_flow.iloc[k+1],'TR' ,tI_0.iloc[i], 'TI', tI_1.iloc[i],k, i )
            if tR_end_flow.iloc[k] == 0 and tR_end_flow.iloc[k+1] < tI_0.iloc[i]:
                #print('Test0')
                continue

            elif tR_end_flow.iloc[k]< tI_0.iloc[i] and tR_end_flow.iloc[k+1] >tI_0.iloc[i]:
                #print('Test1')     
                if tR_end_flow.iloc[k+1] <= tI_1.iloc[i]:
                    #print('hello')
                    mean_array_flow.append(dfR_flow[' Value'].iloc[k])
                    proportion_array_flow.append(np.divide(tR_end_flow.iloc[k+1]-tI_0.iloc[i] ,dtI_2.iloc[i]))
                elif tR_end_flow.iloc[k+1] >= tI_1.iloc[i]:
                    #print('hello1')
                    mean_array_flow.append(dfR_flow[' Value'].iloc[k])
                    proportion_array_flow.append(1)
            
            elif tR_end_flow.iloc[k] > tI_0.iloc[i] and tR_end_flow.iloc[k+1] < tI_1.iloc[i]:
                #print('Test2')
                mean_array_flow.append(dfR_flow[' Value'].iloc[k])
                proportion_array_flow.append(np.divide(tR_end_flow.iloc[k+1]-tR_end_flow.iloc[k] ,dtI_2.iloc[i]))
        
            elif tR_end_flow.iloc[k] < tI_1.iloc[i] and tR_end_flow.iloc[k+1] >= tI_1.iloc[i]:
                #print('Test3', k)            
                mean_array_flow.append(dfR_flow[' Value'].iloc[k])
                proportion_array_flow.append(np.divide(tI_1.iloc[i]-tR_end_flow.iloc[k] ,dtI_2.iloc[i]))

            elif tR_end_flow.iloc[k] < tI_0.iloc[i] and tR_end_flow.iloc[k+1] > tI_1.iloc[i]:
                #print('Test4')
                mean_array_flow.append(dfR_flow[' Value'].iloc[k])
                proportion_array_flow.append(1)
            
            elif proportion_array_flow == [] and tR_end_flow.iloc[k] > tI_0.iloc[i]:
                #print('test new2')
                mean_array_flow.append(dfR_flow[' Value'].iloc[k])
                proportion_array_flow.append(np.divide(tR_end_flow.iloc[k]-tI_0.iloc[i] ,dtI_2.iloc[i]))

            elif tR_end_flow.iloc[k]>= tI_1.iloc[i]:
                #print('Test5')
                if m>1:
                    m = k-2
                break
        
        if  np.sum(proportion_array_flow) <0.8:
            print('CHECK ==1(2) : ', np.sum(proportion_array_flow), 'array:', proportion_array_flow, mean_array_flow, )
            #print(tR_end_flow.iloc[k],tR_end_flow.iloc[k+1],'TR' ,tI_0.iloc[i], 'TI', tI_1.iloc[i],k, i )






        # Store values in new dataframe
        dfTest = dfS[ (dfS['Name'].str.contains(file_item)) & (dfS['Participant'].str.contains(prefix)) ]
        #print(dfTest)
        df_store.loc[store_i] = {
            'Name': file_item,
            'Music_Imp': dfI['Music_Mode'].iloc[i],
            'Dance_Imp': dfI['Category'].iloc[i],
            'Step': dfI['Step'].iloc[i],
            'Imp_subj': np.sum(np.multiply(mean_array,proportion_array)),
            'Imp_avg' : dfR[' Value'].mean(),
            'Flow_subj': np.sum(np.multiply(mean_array_flow,proportion_array_flow)),
            'Flow_avg': dfR_flow[' Value'].mean(),
            'CTW': list_Entropy['CTW'].mean() ,
            'LZ': list_Entropy['LZ'].mean(),
            'Assigned_Cat': 'IMP0',
            'Baile_Level': dfI['Baile'].iloc[i],
            'Guitarra_Level': dfI['Guitarra'].iloc[i],
            'Rounds':dfI['Bloques'].iloc[i],
            "Q1a": dfTest["Q1a"].iloc[0],
            "Q1b": dfTest["Q1b"].iloc[0],
            "Q2a": dfTest["Q2a"].iloc[0],
            "Q2b": dfTest["Q2b"].iloc[0],
            "Q2c": dfTest["Q2c"].iloc[0],
            "Q2d": dfTest["Q2d"].iloc[0],
            "Q2e": dfTest["Q2e"].iloc[0],
            "Q2f": dfTest["Q2f"].iloc[0],
            "Q2g": dfTest["Q2g"].iloc[0],
            "Q2h": dfTest["Q2h"].iloc[0],
            "Q2i": dfTest["Q2i"].iloc[0],
            "Q2j": dfTest["Q2j"].iloc[0],
            "Q3a": dfTest["Q3a"].iloc[0],
            "Q3b": dfTest["Q3b"].iloc[0],
            "Q4a": dfTest["Q4a"].iloc[0],
            "Q4b": dfTest["Q4b"].iloc[0],
            "Abs_Av": dfTest["Abs_Av"].iloc[0],
            "Perf_Av": dfTest["Perf_Av"].iloc[0],
            "SFS": dfTest["SFS"].iloc[0],
            "Dance_mode": dfTest["Dance_mode"].iloc[0],
            "Music_mode": dfTest["Music_mode"].iloc[0],
            "Palo": dfTest["Palo"].iloc[0],
            "LZ_Av": dfTest["LZ"].iloc[0],
            "CTW_Av": dfTest["CTW"].iloc[0],
            'MIR_entropy' : list_MIR_entropy['entropy'].mean() ,
            'MIR_entropy_avg' : dfMIR_entropy['entropy'].mean(),
            'MIR_rms' : list_MIR_entropy['rms'].mean(),
            'MIR_rms_avg' : dfMIR_entropy['rms'].mean(),
            'MIR_novelty' : list_MIR_novelty['novelty'].mean() ,
            'MIR_novelty_avg' : dfMIR_novelty['novelty'].mean(),
            'var_entropy': list_var['var'].mean(),
            'var_entropy_avg': df_var['var'].mean(),
            }
        store_i = store_i+1

        mean_array = []
        proportion_array = []
        mean_array_flow = []
        proportion_array_flow = []
        
    dfI['Imp_subj'] = Imp_average
    # dfTest = dfS[ (dfS['Name'].str.contains(file_name)) & (dfS['Participant'].str.contains(prefix)) ]
    # print(dfTest, 'TESTING!!!!!!!!')



# Assign Category per IMPRO
# IMP0 [0,3) Not improvised
# IMP1 [3,5)
# IMP2 [5,7]
df_store['Assigned_Cat'] = 'IMP0'


df_store.loc[df_store['Imp_subj']>= 3 , 'Assigned_Cat'] = 'IMP1'
df_store.loc[df_store['Imp_subj']>= 5 , 'Assigned_Cat'] = 'IMP2'


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
#print(df_store)

#print(dfS)


df_store.to_csv(file_output + '17122022_095_2s' + '.csv')

