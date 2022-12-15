import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

file_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/28_Nov_2022/'

df = pd.read_csv(file_input + '13122022_095' + '.csv')




def stdMean(column, variable, colour ):
    list_column = df[column].unique().tolist()
    list_column = np.sort(list_column).tolist()
    #print(list_column, 'LIST COLUMNS')
    list_mean = []
    list_std = []
    list_colour = []
    list_data = []

    for i, item in enumerate(list_column):
        MI = df[df[str(column)].str.contains(str(item))]
        MI_mean = MI[str(variable)].mean()
        MI_std = MI[str(variable)].std()
        list_mean.append(MI_mean)
        list_std.append(MI_std)
        list_colour.append(colour)
        data = MI[str(variable)]
        data = data[~np.isnan(data)]
        list_data.append(data)

        
    
    
    return list_mean, list_std, list_column, list_colour, list_data



variables = ['LZ', 'Imp_subj', 'Flow_subj', 'Abs_Av', 'Perf_Av', 'MIR_entropy', 'MIR_rms', 'MIR_novelty', 'Q1a', 'Q1b', 'Q3a', 'Q3b' ]
#variables = ['MIR_novelty']
for j, itemj in enumerate(variables):
    list_columns = ['Music_Imp','Dance_Imp', 'Music_mode', 'Dance_mode', 'Palo',  'Guitarra_Level','Baile_Level']
    list_colour = ['black', 'red', 'black', 'red','cyan', 'green', 'blue','green']
    lsts_mean = []
    lsts_std  = []
    lsts_col  = []
    lsts_colour = []
    list_data = []
    
    plt.figure()

    for i, item in enumerate(list_columns):

        lst_mean, lst_std, lst_col, lst_colour,lst_data = stdMean(item, itemj, list_colour[i])
        lsts_mean = lsts_mean + lst_mean
        lsts_std = lsts_std + lst_std
        lsts_col = lsts_col + lst_col
        lsts_colour = lsts_colour + lst_colour
        list_data  = list_data + lst_data

        x = np.arange(len(list_data))
        plt.ylabel(itemj)

        violin_parts = plt.violinplot(list_data, x, points=60, widths=0.9, showmeans=False,
                     showextrema=False, showmedians=False, bw_method=0.5,
                    
                     )
        
    for pc in violin_parts['bodies']:
        pc.set_facecolor('green')
        pc.set_edgecolor('black')



   
 
  
    # violin_parts = plt.violinplot(list_data, x, points=60, widths=0.9, showmeans=False,
    #                  showextrema=False, showmedians=False, bw_method=0.5,
                    
    #                  )
    

  

    # sns.violinplot(y = df[itemj], x = df['Dance_mode']
    #                  #color = lsts_colour
                    
    #                  )
    plt.boxplot(list_data, positions = x)
    plt.xticks(x,  lsts_col)

    #plt.show()



    # plt.figure()
    # x = np.arange(len(lsts_col))
    # y = lsts_mean
    # plt.xticks(x, lsts_col)
    # plt.ylabel(itemj)
    # plt.bar(x,y, yerr = lsts_std,   align='center',
    #     alpha=0.5,
    #     ecolor='black',
    #     color= lsts_colour,
    #     capsize=10)

    # #plt.show() 
    plt.savefig('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/'+'ViolinPlots_'+ itemj +  '.png')

