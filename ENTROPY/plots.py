import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

file_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/28_Nov_2022/'

df = pd.read_csv(file_input + '13122022_095' + '.csv')




def stdMean(column, variable, colour ):
    list_column = df[column].unique().tolist()
    list_column = np.sort(list_column).tolist()
    #print(list_column)
    list_mean = []
    list_std = []
    list_colour = []

    for i, item in enumerate(list_column):
        MI = df[df[str(column)].str.contains(str(item))]
        MI_mean = MI[str(variable)].mean()
        MI_std = MI[str(variable)].std()
        list_mean.append(MI_mean)
        list_std.append(MI_std)
        list_colour.append(colour)
        
    
    
    return list_mean, list_std, list_column, list_colour



variables = ['LZ', 'Imp_subj', 'Flow_subj', 'Abs_Av', 'Perf_Av', 'MIR_entropy', 'MIR_rms', 'MIR_novelty' ]

for j, itemj in enumerate(variables):
    list_columns = ['Music_Imp','Dance_Imp', 'Music_mode', 'Dance_mode', 'Palo',  'Guitarra_Level','Baile_Level']
    list_colour = ['black', 'red', 'black', 'red','cyan', 'green', 'blue','green']
    lsts_mean = []
    lsts_std  = []
    lsts_col  = []
    lsts_colour = []
    
    for i, item in enumerate(list_columns):

        lst_mean, lst_std, lst_col, lst_colour = stdMean(item, itemj, list_colour[i])
        lsts_mean = lsts_mean + lst_mean
        lsts_std = lsts_std + lst_std
        lsts_col = lsts_col + lst_col
        lsts_colour = lsts_colour + lst_colour



    plt.figure()
    x = np.arange(len(lsts_col))
    y = lsts_mean
    plt.xticks(x, lsts_col)
    plt.ylabel(itemj)
    plt.bar(x,y, yerr = lsts_std,   align='center',
        alpha=0.5,
        ecolor='black',
        color= lsts_colour,
        capsize=10)

    #plt.show() 
    plt.savefig('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/'+'Mean_Std_'+ itemj +  '.png')

