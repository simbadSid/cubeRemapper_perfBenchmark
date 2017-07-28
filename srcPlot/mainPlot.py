##*************************************************************************##
##  CUBE        http://www.scalasca.org/                                   ##
##*************************************************************************##
##  Copyright (c) 1998-2017                                                ##
##  Forschungszentrum Juelich GmbH, Juelich Supercomputing Centre          ##
##                                                                         ##
##  Copyright (c) 2009-2015                                                ##
##  German Research School for Simulation Sciences GmbH,                   ##
##  Laboratory for Parallel Programming                                    ##
##                                                                         ##
##  This software may be modified and distributed under the terms of       ##
##  a BSD-style license.  See the COPYING file in the package base         ##
##  directory for details.                                                 ##
##*************************************************************************##


import matplotlib as mpl
PLOT_LIB_LIST = ['TkAgg', 'GtkAgg', 'Agg']
for lib in PLOT_LIB_LIST:
    try:
        mpl.use(lib)
        break
    except:
        print "Failed to use library: " + lib
        if (lib == PLOT_LIB_LIST[len(PLOT_LIB_LIST)-1]):
            print "No Python graphical backend library found"

import matplotlib.pyplot as plt
#from mpl_toolkits.mplot3d import Axes3D
#from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import numpy as np
import sys

from data import Data
from util import loggerError, LIST_SEPARATOR, find, generateMappedRandomColor, findStartWith









# ---------------------------------------
# Local variables
# ---------------------------------------
ARGUMENT_INPUT_HELP                 = "-help"
ARGUMENT_PLOT_TYPE                  = "-plotType="
ARGUMENT_LOG_X                      = "-logScaleX"
ARGUMENT_LOG_Y                      = "-logScaleY"
ARGUMENT_RESULT_DIM_TEXT            = "-resultDimText="
ARGUMENT_MULTIPLE_TRY               = "-multipleTry"
ARGUMENT_ALL_PROJECTION_IN_1_FRAME  = "-allProjectionIn1Frame"
ARGUMENT_ALL_DATA_IN_1_FRAME        = "-allDataIn1Frame"
ARGUMENT_SORT_DIM                   = "-sortDim="

PLOT_TYPE_SURFACE                   = "surface"
PLOT_TYPE_CLOUD                     = "cloud"
PLOT_TYPE_BAR                       = "bar"
PLOT_TYPE_POINT                     = "point"

COLOR_DEFAULT                       = 'magenta'
COLOR_LIST                          = ['green',                'black',                    'red',                               'purple',                               'blue',                                     'red',          'blue',                     'black',        'green',                    'purple',                              'black']
COLOR_CORRESPONDENCE                = ['./posixGlibcIO_sleep', './posixGlibcAIO_sleep',    './posixGlibcAIO_sleep_noSignal',    './posixGlibcIO_sleep_memoryFootprint', './posixGlibcAIO_sleep_memoryFootprint',    'DEV-SL-trunk', 'DEV-SL-trunk-tcmalloc',    'DEV-SL-AIO',   'DEV-SL-AIO-noFalseSharing','DEV-SL-AIO-noFalseSharing-tcmallocs', 'DEV-SL-AIO-pthreadWrap']

POINT_TYPE_LIST                     = ['p',     'x',        'o',                    '<',                        '^',                     '*', 'D', 'x', '|', 'H']
POINT_TYPE_CORRESPONDENCE           = ['Total', 'Compute',  'Compute is row wise',  'Compute[get_sevs_raw]',    'Compute[set_sevs_raw]', 'Write']

RESULT_DIM_TEXT_DEFAULT             = "Time (s)"
BAR_SIZE                            = 3


# ---------------------------------------
# Local methods
# ---------------------------------------
def printHelp(progName):
    print "Usage: " + progName + ": [options] <dataFileName>"
    print "Options:"
    print "\t"+ ARGUMENT_PLOT_TYPE                  + "<type>\tTo set the type of plot.  <type> is in: "\
                                                    + "\n\t\t\t\t<"\
                                                    + "\n\t\t\t\t | " + PLOT_TYPE_SURFACE \
                                                    + "\n\t\t\t\t | <" + PLOT_TYPE_POINT + "|" + PLOT_TYPE_BAR + ">:<dim projection>:<all|list of values>"\
                                                    + "\n\t\t\t\t | " + PLOT_TYPE_CLOUD\
                                                    + "\n\t\t\t\t> "
    print "\t"+ ARGUMENT_LOG_X                      + "\t\tTo use a logarithmic scale for the abscissa plot"
    print "\t"+ ARGUMENT_LOG_Y                      + "\t\tTo use a logarithmic scale for the ordinate plot"
    print "\t"+ ARGUMENT_RESULT_DIM_TEXT            + "<text>\tTo set the text to print as a result dimension"
    print "\t"+ ARGUMENT_SORT_DIM                   + "<variable dim>\tTo sort all the data following to the given variable dimension"
    print "\t"+ ARGUMENT_ALL_PROJECTION_IN_1_FRAME  + "\tTo print all the different projections in a single frame"
    print "\t"+ ARGUMENT_ALL_DATA_IN_1_FRAME        + "\tTo print all the data in a single frame"
    print "\t"+ ARGUMENT_MULTIPLE_TRY               + "\t\tTo consider the data as average of multpile try (inly available with 2d plots)"
    print "\t"+ ARGUMENT_INPUT_HELP                 + "\t\t\tTo print the current help"
    exit(2)


def parseInputArg(argList):
    dataFileName            = []
    plotType                = PLOT_TYPE_SURFACE
    logX                    = False
    logY                    = False
    allProjectionIn1Frame   = False
    allDataIn1Frame         = False
    multipleTry             = False
    variableDimForSort      = None
    resultDimText           = RESULT_DIM_TEXT_DEFAULT

    for i in range(1, len(argList)):
        arg = argList[i]
        if (arg == ARGUMENT_INPUT_HELP):
            printHelp(argList[0])
            exit()
        elif (arg == ARGUMENT_LOG_X):
            logX = True
        elif (arg == ARGUMENT_LOG_Y):
            logY = True
        elif (arg == ARGUMENT_ALL_PROJECTION_IN_1_FRAME):
            allProjectionIn1Frame = True
        elif (arg == ARGUMENT_ALL_DATA_IN_1_FRAME):
            allDataIn1Frame = True
        elif (arg == ARGUMENT_MULTIPLE_TRY):
            multipleTry = True
        elif (arg.startswith(ARGUMENT_SORT_DIM)):
            variableDimForSort = arg[len(ARGUMENT_SORT_DIM) : ]
        elif (arg.startswith(ARGUMENT_PLOT_TYPE)):
            plotType = arg[len(ARGUMENT_PLOT_TYPE) : ]
        elif (arg.startswith(ARGUMENT_RESULT_DIM_TEXT)):
            resultDimText = arg[len(ARGUMENT_RESULT_DIM_TEXT) : ]
        else:
            dataFileName.append(arg)

    if (len(dataFileName) == 0):
        loggerError("Unspecified data file name", exitNow=True)

    return (dataFileName, plotType, logX, logY, resultDimText, allProjectionIn1Frame, allDataIn1Frame, multipleTry, variableDimForSort)


def parsePlotType(plotType, data):
    if ((not plotType.startswith(PLOT_TYPE_BAR)) and (not plotType.startswith(PLOT_TYPE_POINT))):
        return (plotType, None, None)

    listL        = plotType.split(":")
    plotTypeId  = listL[0]
    assert((plotTypeId == PLOT_TYPE_BAR) or (plotTypeId == PLOT_TYPE_POINT))
    if (len(listL) != 3):
        loggerError("Malformed input plot type (0)", param=plotType, exitNow=True)

    dimProjectionName = listL[1]
    if (not data.isVariableDim(dimProjectionName)):
        loggerError("Malformed input plot type (1)", param=dimProjectionName, exitNow=True)

    if(listL[2] == "all"):
        dimProjectionListValue = data.getAllUnicValueFromDim(dimProjectionName)
    else:
        dimProjectionListValue = [float(valStr) for valStr in listL[2].split(LIST_SEPARATOR)]

    return (plotTypeId, dimProjectionName, dimProjectionListValue)


def plotModel(ax):
    writeTime   = 1.45
    n           = 4
    maxC        = 7
    ax.plot([0,         writeTime], [n*writeTime, n*writeTime],     "--", color='cyan', label="Theoretical model (C << W)")
    ax.plot([writeTime, maxC],      [n*writeTime, n*maxC],           "--", color='blue', label="Theoretical model (C >> W)")


def plotModel_hpc(ax, nbIoDevice=1):
    writeTime   = 0.57
    n           = 40
    maxC        = 5
    ax.plot([0,                     writeTime/nbIoDevice],  [(n-1)*writeTime/nbIoDevice + writeTime,    n*writeTime/nbIoDevice+writeTime],  "--", color='cyan',  label="Theoretical model (C << W)")
    ax.plot([writeTime/nbIoDevice,  maxC],                  [n*writeTime/nbIoDevice + writeTime,        n*maxC+writeTime],                  "--", color='blue',  label="Theoretical model (C >> W)") 
    ax.plot([writeTime/nbIoDevice,  writeTime/nbIoDevice],  [0,                                         200],                               "--", color='purple',label="Write time / nb IO devices") 


def projectionPlotHeader(dataLis, dimProjectionName, dimProjectionValue, ax, fig):
    plt.legend()
    frameTitle = dataLis[0].getBenchmarkPatternInfo()
    for dataCompare in dataLis[1:]:
        frameTitle += " VS " + dataCompare.getBenchmarkPatternInfo()
    fig.canvas.set_window_title(frameTitle)
    # Shrink current axis by 20%
    ax = plt.subplot(111)
    box = ax.get_position()
    ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    ax.legend(loc='center left', bbox_to_anchor=(1, 0.5))
    plt.grid()
    plt.show(block=False)


# ---------------------------------------
# Plotting methods (per chart page)
# ---------------------------------------
def plotCloud(X, Y, Z, fig, X_label, Y_label, Z_label):
    ax = plt.scatter(X,Y, s=75, c=Z)
    fig.colorbar(ax, label=Z_label)
    plt.xlabel(X_label)
    plt.ylabel(Y_label)


def plotSurface(X, Y, Z, fig, X_label, Y_label, Z_label):
    ax = fig.gca(projection='3d')
    X,Y = np.meshgrid(X, Y)
    surf= ax.plot_surface(X, Y, Z, rstride=10, cstride=10, linewidth=0, antialiased=False)#, cmap=cm.jet)
    fig.colorbar(surf, label=Z_label)
#TODO
#   ax.set_zlim3d(-1.01, 1.01)
#TODO end
    ax.w_zaxis.set_major_locator(LinearLocator(10))
    ax.w_zaxis.set_major_formatter(FormatStrFormatter('%.03f'))
    ax.set_xlabel(X_label)
    ax.set_ylabel(Y_label)
    ax.set_zlabel(Z_label)

def plotPoint(X, Z, Z_error, fig, ax, X_label, Z_label, legend, barSize, logX, logY, legendExtra="", pointType=0, generateRandomColor=False):
    pt = findStartWith (legendExtra, POINT_TYPE_CORRESPONDENCE)
    if (pt < 0):
        pointType = POINT_TYPE_LIST[pointType]
    else:
        pointType = POINT_TYPE_LIST[pt]

    if (generateRandomColor):
        col = generateMappedRandomColor()
    else:
        col = find (legend, COLOR_CORRESPONDENCE)
        if (col < 0):
            col = COLOR_DEFAULT
        else:
            col = COLOR_LIST[col]

    legend = legend + " (" + legendExtra + ")"
    ax.plot(X, Z, "-"+pointType, color=col, label=legend, markersize =7)

    if (Z_error != None):
        ax.fill_between(X, Z_error[1], Z_error[0], color=col, alpha=0.1)

    ax.set_ylabel(Z_label)
    ax.set_xlabel(X_label)
    if (logX):
        ax.set_xscale('log')
    if (logY):
        ax.set_yscale('log')


def plotBar(X, Z, Z_error, fig, ax, X_label, Z_label, legend, barSize, logX, logY, legendExtra="", transparency=1, generateRandomColor=False):
    if (generateRandomColor):
        col = generateMappedRandomColor()
    else:
        col = find (legend, COLOR_CORRESPONDENCE)
        if (col < 0):
            col = COLOR_DEFAULT
        else:
            col = COLOR_LIST[col]
    legend = legend + " (" + legendExtra + ")"
    ax.bar(X, Z,  barSize, color=col, label=legend, alpha=transparency, yerr=Z_error)
    ax.set_ylabel(Z_label)
    ax.set_xlabel(X_label)
    if (logX):
        ax.set_xscale('log')
    if (logY):
        ax.set_yscale('log')
        


# ---------------------------------------
# Plotting methods (loop on all data)
# ---------------------------------------
def plotData_projection(dataLis, plotType, dimProjectionName, dimProjectionListValue, logX, logY, allProjectionIn1Frame, resultDimText, multipleTry):
    pointType   = 0
    if (allProjectionIn1Frame):
        fig     = plt.figure()
        ax      = fig.gca()
    for dimProjectionValue in dimProjectionListValue:
        transparency=1.
        if (allProjectionIn1Frame):
            resultName  = dimProjectionName + "(" + str(dimProjectionValue) + ")"
        if (not allProjectionIn1Frame):
            fig = plt.figure()
            ax  = fig.gca()
        for resultId in xrange(dataLis[0].getNbResultDim()):
            if (not allProjectionIn1Frame):
                resultName  = dataLis[0].getResultDimName(resultId)
            
            if (plotType == PLOT_TYPE_BAR):
                for data in dataLis:
                    (X_list, Z_list, Z_error_list, X_label_list) = data.getVariableDimVect_projection(dimProjectionName, dimProjectionValue)
                    assert(len(X_list) == len(X_label_list))
                    Z           = Z_list[resultId]
                    Z_error     = Z_error_list[resultId]
                    plotBar(X_list[0], Z, Z_error, fig, ax, X_label_list[0], resultDimText, data.getBenchmarkPatternInfo(), BAR_SIZE, logX, logY, legendExtra=resultName, transparency=transparency, generateRandomColor=allProjectionIn1Frame)
            elif (plotType == PLOT_TYPE_POINT):
                for data in dataLis:
                    (X_list, Z_list, Z_error_list, X_label_list) = data.getVariableDimVect_projection(dimProjectionName, dimProjectionValue)
                    assert(len(X_list) == len(X_label_list))
                    Z           = Z_list[resultId]
                    Z_error     = Z_error_list[resultId]
                    plotPoint(X_list[0], Z, Z_error, fig, ax, X_label_list[0], resultDimText, data.getBenchmarkPatternInfo(), BAR_SIZE, logX, logY, legendExtra=resultName, pointType=pointType)#, generateRandomColor=allProjectionIn1Frame)
                    pointType = (pointType + 1) % len(POINT_TYPE_LIST)
            else:
                loggerError("Unknown 2d plot type", param=plotType, exitNow=True)
            transparency = transparency / 2.

        if (not allProjectionIn1Frame):
            projectionPlotHeader(dataLis, dimProjectionName, dimProjectionValue, ax, fig)
    if (allProjectionIn1Frame):
        projectionPlotHeader(dataLis, dimProjectionName, dimProjectionValue, ax, fig)


def plotData_3d(data, plotType):
    X = data.getVariableDimVect(0)
    Y = data.getVariableDimVect(1)
    for resultName in data.getResultDimNameVect():
        print "\n\t=========================="
        print "\tPlot (" + plotType + ") " + str(resultName)
        Z   = data.getResultDimVect(resultName)
        fig = plt.figure()
        if (plotType == PLOT_TYPE_SURFACE):
            plotSurface(X, Y, Z, fig, data.getVariableDimName(0), data.getVariableDimName(1), resultName)
        elif (plotType == PLOT_TYPE_CLOUD):
            plotCloud(X, Y, Z, fig, data.getVariableDimName(0), data.getVariableDimName(1), resultName)
        else:
            loggerError("Unknown 3d plot type", param=plotType, exitNow=True)
        fig.canvas.set_window_title(str(data.getBenchmarkPatternInfo()))
        plt.grid()
        plt.show(block=False)


def plotData(dataLis, plotType, logX, logY, allProjectionIn1Frame, resultDimText, multipleTry):
#    plt.hold(True)  # Allows to add subsequent plots
    (plotType, dimProjectionName, dimProjectionListValue) = parsePlotType(plotType, dataLis[0])
    if ((plotType == PLOT_TYPE_BAR) or (plotType == PLOT_TYPE_POINT)):
        plotData_projection(dataLis, plotType, dimProjectionName, dimProjectionListValue, logX, logY, allProjectionIn1Frame, resultDimText, multipleTry)
    else:
#TODO add the log scal option
        plotData_3d(dataLis, plotType)


# ---------------------------------------
# Main method
# ---------------------------------------
if __name__ == "__main__":
    (dataFileName, plotType, logX, logY, resultDimText, allProjectionIn1Frame, allDataIn1Frame, multipleTry, variableDimForSort)  = parseInputArg(sys.argv)
    dataLis = []
    for i in xrange(len(dataFileName)):
        dataLis.append(Data())
        dataLis[i].parseAndSet(dataFileName[i], multipleTry=multipleTry, variableDimForSort=variableDimForSort)
        print "\t Parsing the data file: " + dataFileName[i]
        print dataLis[i].toString()

    nbFile = len(dataFileName)
    if ((nbFile == 1) or (allDataIn1Frame)):
        plotData(dataLis, plotType, logX, logY, allProjectionIn1Frame, resultDimText, multipleTry)
    else:
        for i in xrange(nbFile-1):
            for j in range(i+1, nbFile):
                dataLisBuffer = [ dataLis[i], dataLis[j] ]
                plotData(dataLisBuffer, plotType, logX, logY, allProjectionIn1Frame, resultDimText, multipleTry)
    plt.show()
