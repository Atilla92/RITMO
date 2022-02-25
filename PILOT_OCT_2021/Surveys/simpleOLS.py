import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
import statsmodels.api as sm
import matplotlib.pyplot as plt

data = pd.read_csv (r'fixedParameters.csv', index_col=0)




def sklearnOls (dataIMP1):
    x = [np.array(dataIMP1['Like']), np.array(dataIMP1['Improvise'])]
    # # x = x.reshape(-1,1)
    # print(x)
    y = np.array(dataIMP1['Complexity'])

    xFit = []
    for i, item in enumerate(y):
            x1, x2, x3, x4 = dataIMP1['Like'][i], dataIMP1['Improvise'][i], dataIMP1['Express'][i], dataIMP1['Preference'][i]
            print (i,x1,x2)
            x = [x1, x2, x3, x4]
            xFit.append(x)


    model = LinearRegression().fit(xFit,y)
    r_sq = model.score(xFit, y)
    print('coefficient of determination:', r_sq)
    print('intercept:', model.intercept_)
    print('slope:', model.coef_)

# x = data[['Like', 'Improvise', 'Express', 'Preference']]
x = data[['Like','Express']]
y = data['Complexity']

x = sm.add_constant(x)
est = sm.OLS(y,x).fit()
print(est.summary())
fig = sm.graphics.plot_partregress_grid(est)
fig.tight_layout(pad=1.0)
plt.show()

#https://www.statsmodels.org/stable/examples/notebooks/generated/regression_plots.html
