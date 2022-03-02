from __future__ import print_function, division

import matplotlib.pyplot as plt
import numpy as np
import sensormotion.signal

def plot_signal(
    time,
    signal,
    title="",
    xlab="",
    ylab="",
    line_width=1,
    alpha=1,
    color="k",
    subplots=False,
    show_grid=True,
    fig_size=(10, 5),
    saveFig = False,
    saveName = "",
):
    """Plot signals over time.

    Convenience wrapper around pyplot to quickly create plots of signals
    over time. This is useful if you want to avoid remembering the syntax
    for matplotlib.

    Parameters
    ----------
    time : ndarray
        Time vector of the signal (X-axis)
    signal : ndarray or list of dicts
        If plotting a single line, you can pass in a single array.

        If you want to plot multiple lines (either on the same plot, or as
        subplots) you should pass in a list of dictionaries. Each dictionary
        represents a separate line and contains options for that line. The
        dictionary can hold the follow keys: 'data' (required), 'label',
        'color', 'alpha', 'line_width'.

        For example, a 2 line plot can be created like this:

        >>> plot.plot_signal(time_array, [{'data': line1_data,
                                           'label': 'line 1',
                                           'color': 'b'},
                                          {'data': line2_data,
                                           'label': 'second line',
                                           'line_Width': 4}])
    title : str, optional
        Title of the plot.
    xlab : str, optional
        Label for the x axis.
    ylab : str, optional
        Label for the y axis.
    line_width : int or float, optional
        Width of the plot lines.
    alpha : int or float, optional
        Alpha of the plot lines.
    color : str, optional
        Colour of the plot lines. Receives a string following the matplotlib
        colors API: http://matplotlib.org/api/colors_api.html
    subplots : bool, optional
        If multiple lines are passed in, should they be displayed on the same
        plot (False)? Or should each be displayed in separate subplots (True)?
    show_grid : bool, optional
        Toggle to display grid lines on the plot.
    fig_size : tuple, optional
        Set the figure size of the resulting plot.
    """

    if type(signal) == list:  # Multiple lines to be plotted
        if subplots:
            f, axarr = plt.subplots(len(signal), 1, figsize=fig_size)
        else:
            f, axarr = plt.subplots(figsize=fig_size)

        for i, line in enumerate(signal):  # Iterate through each plot line
            cur_data = line["data"]

            # Get options for the current line
            try:
                cur_label = line["label"]
            except KeyError:
                print("Warning: Label missing for signal")
                cur_label = ""
            try:
                cur_color = line["color"]
            except KeyError:
                cur_color = color
            try:
                cur_alpha = line["alpha"]
            except KeyError:
                cur_alpha = alpha
            try:
                cur_linewidth = line["line_width"]
            except KeyError:
                cur_linewidth = line_width

            if subplots:  # Show lines in separate plots, in the same figure
                axarr[i].plot(
                    time,
                    cur_data,
                    label=cur_label,
                    linewidth=cur_linewidth,
                    alpha=cur_alpha,
                    color=cur_color,
                )

                axarr[i].set_xlim(min(time), max(time))
                axarr[i].set_xlabel(xlab)
                axarr[i].set_ylabel(ylab)
                axarr[i].grid(show_grid)
                axarr[i].legend()
                f.subplots_adjust(hspace=0.5)
            else:  # Show all lines on the same plot
                axarr.plot(
                    time,
                    cur_data,
                    label=cur_label,
                    linewidth=cur_linewidth,
                    alpha=cur_alpha,
                    color=cur_color,
                )

                axarr.set_xlim(min(time), max(time))
                axarr.set_xlabel(xlab)
                axarr.set_ylabel(ylab)
                axarr.grid(show_grid)
                axarr.legend()
    else:  # Single line plot
        f, axarr = plt.subplots(figsize=fig_size)
        axarr.plot(time, signal, linewidth=line_width, alpha=alpha, color=color)
        axarr.set_xlim(min(time), max(time))
        axarr.set_xlabel(xlab)
        axarr.set_ylabel(ylab)
        axarr.grid(show_grid)

    plt.suptitle(title, size=16)
    if saveFig:
        plt.savefig('./Figures/Filtered_acc_xyz_'+ saveName + '.png')
    #plt.show()