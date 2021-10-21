import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


#import data
dataIMP1 = pd.read_csv (r'export/IMP1.csv')
dataIMP2 = pd.read_csv (r'export/IMP2.csv')
dataBuleria = pd.read_csv (r'export_all/Buleria.csv')
dataSeguirya = pd.read_csv(r'export_all/Seguirya.csv')
dataSolea = pd.read_csv(r'export_all/Solea.csv')
dataGuajira = pd.read_csv(r'export_all/Guajira.csv')
dataMeanStd = pd.read_csv(r'export/meanSummary.csv')


#Box plots


def plotBoxplotInverse (variable, data, dataLabels, title): #Variables to analyse from X datasets, Labels on graph
    """
    Description:
    Creates a default boxplot where first loop goes over data then variables
    So dataset with all variables are plotted in sequence
    
    Input Parameters:
        variable: list
             variables you want to compare, should be name of column in DataFrame
        data: list
             DataFrames you would like to compare, containing the variables e.g. [dataIMP1,
        dataLables: list
            Name of datasets you are comparing, will be added to Labels in Figure
        title: string
            title of image. Will be stored as png

    """
    dataX =[]
    labelList = []

    for j, dataItem in enumerate(data):
        dataLabel = dataLabels[j]
        for i, item in enumerate(variable):
            data = np.array(dataItem[item][:-2])

            dataX.append(data)
            labelName = str(item +' - '+ dataLabel)
            labelList.append(labelName)
    print(dataX)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.boxplot(dataX, labels=labelList)

    plt.show()
    name_file = str('Plots/' + title + '.png')
    fig.savefig(name_file)
    return


def plotBoxplot (variable, data, dataLabels, title, store, plot): #Variables to analyse from X datasets, Labels on graph
    """
    Description:
    Creates a default boxplot where first loop goes over variables, then dataset
    Different variables for each experiment mode (dataset) are plotted next to eachother. 
    e.g. Move IMP1, Move IMP2, Pleasure IMP1, Pleasure IMP2
    
    Input Parameters:
        variable: list
             variables you want to compare, should be name of column in DataFrame
        data: list
             DataFrames you would like to compare, containing the variables e.g. [dataIMP1,
        dataLables: list
            Name of datasets you are comparing, will be added to Labels in Figure
        title: string
            title of image. Will be stored as png
        store: Boolean 
            if True stores the images in 'Plots/' as png
        plot: Boolean
            if True plots the figures

    """

    dataX =[]
    labelList = []

    for i, item in enumerate(variable):
        print(item,'item')
        for j, dataItem in enumerate(data):
            print(j, dataItem, 'dataItem')
            dataLabel = dataLabels[j]
            dataArray = np.array(dataItem[item][:-2])
            dataX.append(dataArray)
            labelName = str(item +' - '+ dataLabel)
            print(labelName, 'labelName')
            labelList.append(labelName)
    print(dataX)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.boxplot(dataX, labels=labelList)

    if plot:
        plt.show()
    if store:
        name_file = str('Plots/' + title + '.png')
        fig.savefig(name_file)

    return



def histogramErrorPlot(palo, data, variables, store, show, xlim):
    """
    Description:
        Creates a mean and std hbar plot, with std plotted as an error line. 
        Mean and std are exported from last two lines of DataFrames. 
        Creates a new Dataframe with each of the "palo" or dataset mean and std. 
        "Palo" becomes the index in the dataframe. 
        Will create one plot per variable.

    Input Parameters:
        palo: list of strings 
            Name of Datasets you want to compare. Becomes index of Dataframe (first column) 
        data: list
             DataFrames you would like to compare, containing the variables e.g. [dataIMP1, dataIMP2]
             "mean" and "std" should be the last two lines of DataFrame
        variables: list
             variables (column in DataFrame) you want to plot mean and std for DataFrames. 
        store: Boolean 
            if True stores the images in 'Plots/' as png
        show: Boolean
            if True plots the figures
        xlim: int 
            set upper x limit of plot

    """
    for j, column in enumerate(variables):
        titles = []
        means = []
        stds = []
        for i, item in enumerate(data):
            title = palo[i]
            mean = item.iloc[-2][column]
            std = item.iloc[-1][column]
            means.append(mean)
            stds.append(std)
            titles.append(title)
        matrix = {
            'title': titles,
            'mean': means,
            'std': stds
        }

        print(column, j)
        x_matrix = pd.DataFrame(data=matrix)
        x_matrix = x_matrix.set_index('title')



        if store:
            fig = x_matrix.plot(kind = "barh", y = "mean", legend = False,
                                title = column + ' (mean, std)', xerr = "std", xlim = [0,xlim]).get_figure()
            name_file = str('Plots_All/' + column + ' (mean, std)' + '.png')
            fig.savefig(name_file)
        if show:
            plt.show()

    return


# Define plot

#histogramErrorPlot(['Buleria','Seguirya','Solea','Guajira'],[dataBuleria, dataSeguirya, dataSolea, dataGuajira], ['Move', 'Pleasure'], True, False, 5)
#histogramErrorPlot(['Buleria','Seguirya','Solea','Guajira'],[dataBuleria, dataSeguirya, dataSolea, dataGuajira], ['Meaning','Elevating','Carefree'], True, False, 7)

histogramErrorPlot(['Buleria','Seguirya','Solea','Guajira'],[dataBuleria, dataSeguirya, dataSolea, dataGuajira], ['Expression','Technique','Harmony'], True, False, 7)


# plotBoxplot(['Move','Pleasure'], [dataIMP1, dataIMP2], ['IMP1', 'IMP2'],'IMP1 vs. IMP2 - Move & Pleasure', True, True)
# plotBoxplot(['Meaning','Elevating','Carefree'], [dataIMP1, dataIMP2], ['IMP1', 'IMP2'], 'IMP1 vs. IMP2 - Meaning, Elevating, Carefree', True, True )
#plotBoxplot(['Expression','Technique','Harmony'], [dataIMP1, dataIMP2], ['IMP1', 'IMP2'], 'IMP1 vs. IMP2 - Expression, Technique, Harmony', True, True )


