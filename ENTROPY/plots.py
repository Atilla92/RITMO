import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.graphics.mosaicplot import mosaic

file_input = '/Users/atillajv/CODE/RITMO/ENTROPY/output/main/28_Nov_2022/'
save_plot = '/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/' 

df = pd.read_csv(file_input + '13122022_095_2s' + '.csv')

plot_violin = False #Plot Violinplot of variables. Variables is list 
save_violin_plot = False
plotBoxPlot = False #Plot Boxplot on top of violin plot
bar_plot = True #Plot bar plot of all variables
plot_heatmap = True #Plot sns heatmap and mosaic 
plot_scatterplot = False #Plot a scatterplot of 3 variables


def stdMean(column, variable, colour ):
    '''
    Computes mean and std of a categories within a column. 
        column: is the subcategories column you want to estimate mean and std of a certain variable. 
        variable: is the parameter you want to estimate the mean and std of. 
        colour: is used for a bar_plot, if you want to give each column its specific colour.
                it creates a list of same length as amount of subcategories. 
        e.g. variable = 'LZ', column = 'Baile_Level'
        In this case it would compute the average LZ for each subcategory in 'Baile_Level'
    '''
    list_column = df[column].unique().tolist()
    list_column = np.sort(list_column).tolist()
    #print(list_column, 'LIST COLUMNS')
    list_mean = []
    list_std = []
    list_colour = []
    list_data = []
    counts = []

    for i, item in enumerate(list_column):
        MI = df[df[str(column)].str.contains(str(item))]
        counts.append(len(MI))
        MI_mean = MI[str(variable)].mean()
        MI_std = MI[str(variable)].std()
        list_mean.append(MI_mean)
        list_std.append(MI_std)
        list_colour.append(colour)
        data = MI[str(variable)]
        data = data[~np.isnan(data)]
        list_data.append(data)

    return list_mean, list_std, list_column, list_colour, list_data, counts


# def ViolinPots (variables, list_columns, list_colour = [], save_violin_plot = False):
# '''
# Give list of variables you want to create a violin plot off. 
#     e.g. variables = ['LZ', 'Imp_subj', 'Flow_subj', 'Abs_Av', 'Perf_Av', 'MIR_entropy', 'MIR_rms', 'MIR_novelty', 'Q1a', 'Q1b', 'Q3a', 'Q3b', 'var_entropy' ]
#     e.g.variables = ['var_entropy']

# Give a list of columns you want to look at:
#     e.g. list_columns = ['Music_Imp','Dance_Imp', 'Music_mode', 'Dance_mode', 'Palo',  'Guitarra_Level','Baile_Level']

# Give a list of colours you want to give each subcategory for simple barplot. Need to set barplot to True. 
#     e.g. list_colour = ['black', 'red', 'black', 'red','cyan', 'green', 'blue','green']

# '''

variables = ['Imp_subj']
for j, itemj in enumerate(variables):
    list_columns = ['Music_Imp','Dance_Imp', 'Music_mode', 'Dance_mode', 'Palo',  'Guitarra_Level','Baile_Level']
    list_colour = ['black', 'red', 'black', 'red','cyan', 'green', 'blue','green']
    lsts_mean = []
    lsts_std  = []
    lsts_col  = []
    lsts_colour = []
    lsts_counts = []
    list_data = []
    
    plt.figure()

    for i, item in enumerate(list_columns):

        lst_mean, lst_std, lst_col, lst_colour,lst_data, lst_counts = stdMean(item, itemj, list_colour[i])
        lsts_mean = lsts_mean + lst_mean
        lsts_std = lsts_std + lst_std
        lsts_col = lsts_col + lst_col
        lsts_colour = lsts_colour + lst_colour
        list_data  = list_data + lst_data
        lsts_counts = lsts_counts + lst_counts

        x = np.arange(len(list_data))
        plt.ylabel(itemj)



        violin_parts = plt.violinplot(list_data, x, points=60, widths=0.9, showmeans=False,
                        showextrema=False, showmedians=False, bw_method=0.5,
                        
                        )
    
            
    for pc in violin_parts['bodies']:
            pc.set_facecolor('green')
            pc.set_edgecolor('black')
                        
    plt.boxplot(list_data, positions = x)
    plt.xticks(x,  lsts_col)

    #plt.show()


    if bar_plot: 
        plt.figure()
        x = np.arange(len(lsts_col))
        print(lsts_mean)
        y = lsts_mean
        plt.xticks(x, lsts_col)
        plt.ylabel(itemj)
        plt.bar(x,y, yerr = lsts_std,   align='center',
            #alpha=0.5,
            ecolor='black',
            color= lsts_colour,
            capsize=10)

        #plt.show() 
    
    if save_violin_plot:
    
        plt.savefig('/Users/atillajv/CODE/RITMO/ENTROPY/output/plots/'+'ViolinPlots_'+ itemj +  '.png')



def BarPlot(lsts_col, lsts_counts, df, save_plot):
    '''
    Create a barplot of data.
    Need to run violinPlot to fetch lsts_colour
    Need to fix this definition if you want to run again, or put in violinPlot
    '''
    lsts_colour = ViolinPots()
    fig, ax  = plt.subplots()
    x= np.arange(len(lsts_col))
    y = np.multiply(np.divide(lsts_counts,len(df)), 100)
    y = [ round(elem, 0) for elem in y ]
    ax.set_xticks(x, lsts_col)
    bars = ax.bar(x,y, align = 'center', ecolor = 'black', color = lsts_colour, capsize = 10, alpha = 0.5)

    ax.bar_label(bars)
    plt.ylabel('Subcategory Percentage')
    plt.title('Overview Subcategories')
    plt.savefig(save_plot + 'SubCat_Percentage' + '.png')


# Other statistics

def heatMapCategories(categories, save_fig, save_plot):
    ds = df[categories].value_counts().reset_index(name='count')
    ds['percentage'] = (ds['count']/ds['count'].sum())*100
    ds = ds.sort_values(by = categories)  
    
    pivoted = ds.pivot(index= categories[0], columns= categories[1], values="percentage")


    fig,(ax1, ax2) = plt.subplots(1,2)
    sns.heatmap( ax = ax1, data = pivoted, annot = True, cmap="crest", cbar=False)
    mosaic(df, categories , ax= ax2)
   #if not save_fig:
    #    plt.show()
    if save_fig :
        plt.savefig(save_plot + str(categories) + '.png')


# Plot heatmaps

if plot_heatmap:
    heatMapCategories(['Baile_Level', 'Guitarra_Level'], False, save_plot )
    heatMapCategories(['Palo', 'Baile_Level'], False, save_plot)
    heatMapCategories(['Q1a', 'Dance_Imp'], False, save_plot)
    heatMapCategories(['Dance_Imp', 'Music_Imp'], False, save_plot)
    #heatMapCategories(['Palo'], True, save_plot)



if plot_scatterplot: 

    #sns.scatterplot(x = 'Imp_subj', y = 'LZ', data=df, hue='Dance_Imp')
    sns.catplot(x = 'Imp_subj', y = 'Guitarra_Level', data=df, hue='Palo')

    plt.show()