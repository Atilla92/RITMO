import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


#import data
dataIMP1 = pd.read_csv (r'export/IMP1.csv')
dataIMP2 = pd.read_csv (r'export/IMP2.csv')
dataBuleria = pd.read_csv (r'export/Buleria.csv')
dataSeguirya = pd.read_csv(r'export/Seguirya.csv')
dataSolea = pd.read_csv(r'export/Solea.csv')
dataGuajira = pd.read_csv(r'export/Guajira.csv')
dataMeanStd = pd.read_csv(r'export/meanSummary.csv')


#Box plots

def plotBoxplotInverse (variable, data, dataLabels, title): #Variables to analyse from X datasets, Labels on graph

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

def plotBoxplot (variable, data, dataLabels, title, store, plot): #Variables to analyse from X datasets, Labels on graph

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
    print(variables, 'variables')
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

        #fig = plt.figure()
        # x_matrix.plot(kind = "barh", y = "mean", legend = False,
        #             title = column + ' mean', xerr = "std", xlim = [0,7])
        # plt.show()

        if store:
            fig = x_matrix.plot(kind = "barh", y = "mean", legend = False,
                                title = column + ' (mean, std)', xerr = "std", xlim = [0,xlim]).get_figure()
            name_file = str('Plots/' + column + ' (mean, std)' + '.png')
            fig.savefig(name_file)
        if show:
            plt.show()

    return


#histogramErrorPlot(['Buleria','Seguirya','Solea','Guajira'],[dataBuleria, dataSeguirya, dataSolea, dataGuajira], ['Move', 'Pleasure'], True, False, 5)
#histogramErrorPlot(['Buleria','Seguirya','Solea','Guajira'],[dataBuleria, dataSeguirya, dataSolea, dataGuajira], ['Meaning','Elevating','Carefree'], True, False, 7)



# plotBoxplot(['Move','Pleasure'], [dataIMP1, dataIMP2], ['IMP1', 'IMP2'],'IMP1 vs. IMP2 - Move & Pleasure', True, True)
# plotBoxplot(['Meaning','Elevating','Carefree'], [dataIMP1, dataIMP2], ['IMP1', 'IMP2'], 'IMP1 vs. IMP2 - Meaning, Elevating, Carefree', True, True )
plotBoxplot(['Expression','Technique','Harmony'], [dataIMP1, dataIMP2], ['IMP1', 'IMP2'], 'IMP1 vs. IMP2 - Expression, Technique, Harmony', True, True )





# x = np.array([1, 2, 3, 4, 5])
# y = np.power(x, 2) # Effectively y = x**2
# e = np.array([1.5, 2.6, 3.7, 4.6, 5.5])
#
# plt.errorbar(x, y, e, linestyle='None', marker='^')
#
# plt.show()

# data1 = dataIMP1['Move'][:-2]
# data2 = dataIMP2['Move'][:-2]
# data3 = dataIMP1['Pleasure'][:-2]
# data4 = dataIMP2['Pleasure'][:-2]



# print('Move IMP1 Mean: ', dataIMP1['Move'].iloc[-2], 'std: ' dataIMP1['Move'].iloc[-2])
# print('Move IMP2 Mean: ', dataIMP2['Move'].iloc[-2], 'std: ' dataIMP2['Move'].iloc[-2])
# print('Pleasure IMP1 Mean: ', dataIMP1['Pleasure'].iloc[-2], 'std: ' dataIMP1['Pleasure'].iloc[-2])
# print('Pleasure IMP1 Mean: ', dataIMP1['Pleasure'].iloc[-2], 'std: ' dataIMP1['Pleasure'].iloc[-2])
#
# fig2 = plt.figure()
# ax = fig2.add_subplot(111)
# dataIMP1.plot(kind = "barh", y =0.83, legend = False,
#             title = "Average Prices", xerr = dataIMP1['Move'].iloc[-1])
