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



from util import findIndexInList, copyExceptInd, isEndOfFile, loggerError, nextArrayLine, nextMeaningfullLine, strPad, whereInsertInSortedLIst, insertInList







# ---------------------------------------
# Global parameters
# ---------------------------------------
PAD_PRINT       = 40
PAD_PRINT_DATA  = 20


class Data():
# -----------------------------
# Builder
# -----------------------------
    def __init__(self):
        self._benchmarkPatternInfo  = ""
        self._resultFileName        = ""
        self._variableDimName       = []
        self._variableDimValue      = [[]]
        self._resultDimName         = []
        self._resultDimValue        = [[]]
        self._resultNbTry           = None
        self._resultDimValueMin     = [[]]
        self._resultDimValueMax     = [[]]


# -----------------------------
# Local methods
# -----------------------------
    def isVariableDim(self, variableDimName):
        for v in self._variableDimName:
            if (v == variableDimName):
                return True
        return False


    ##
    # @brief Computes all the existing values of the dim "dimName".
    # @details Each value is returned only once
    def getAllUnicValueFromDim(self, dimName):
        dimName_id  = findIndexInList(self._variableDimName, dimName)
        res         = []
        for val in self._variableDimValue[dimName_id]:
            if not val in res:
                res.append(val)

        return res


    def getBenchmarkPatternInfo(self):
        return self._benchmarkPatternInfo


    def getNbVariableDim(self):
        return len(self._variableDimName)


    def getVariableDim(self):
        return self._variableDimName


    def getNbResultDim(self):
        return len(self._resultDimName)


    def getVariableDimName(self, variableDimIndex):
        return self._variableDimName[variableDimIndex]


    def getResultDimName(self, resultDimIndex):
        return self._resultDimName[resultDimIndex]


    def getResultDimNameVect(self):
        return self._resultDimName


    def getVariableDimVect(self, variableDimIndex):
        return self._variableDimValue[variableDimIndex]


    def getResultDimVect(self, resultName):
        for i in xrange(len(self._resultFileName)):
            if (self._resultDimName[i] == resultName):
                return self._resultDimValue[i]
        assert False


    ##
    # @brief Computes the list of projections of the data on the dimension "dimProjectionName" and the value "dimProjectionListValue"
    # @details Assumes that there are to variable dimension, and that one of them is namesas "dimProjectionName"
    # @returns X_list           The list of all possible input that are not named "dimProjectionName" (1 list per dimension)
    # @returns X_dimName_list   The name of the dimension represented by X
    # @returns Z_list           The list of all the possible resultValues corresponding to X (1 list per result dimension)
    def getVariableDimVect_projection(self, dimProjectionName, dimProjectionValue):
        dimProjectionName_id    = findIndexInList(self._variableDimName, dimProjectionName)
        X_list                  = [[] for _ in xrange(len(self._variableDimName) - 1)]
        Z_list                  = [[] for _ in xrange(len(self._resultDimName))]
        X_dimName_list          = copyExceptInd(self._variableDimName, dimProjectionName_id)
        if (self._resultNbTry != None):
            Z_error_Min_list    = [[] for i in xrange(len(self._resultDimName))]
            Z_error_Max_list    = [[] for i in xrange(len(self._resultDimName))]

        for y in xrange(len(self._variableDimValue[0])):
            if (self._variableDimValue[dimProjectionName_id][y] != dimProjectionValue):
                continue
            shift = 0
            for x in xrange(len(self._variableDimName)):
                if (x == dimProjectionName_id):
                    shift = -1
                    continue
                X_list[x+shift].append(self._variableDimValue[x][y])
            for x in xrange(len(self._resultDimName)):
                Z_list[x].append(self._resultDimValue[x][y])
                Z_error_Min_list[x].append(self._resultDimValueMin[x][y])
                Z_error_Max_list[x].append(self._resultDimValueMax[x][y])

        if (self._resultNbTry != None):
            Z_error_list = [[Z_error_Min_list[i], Z_error_Max_list[i]] for i in xrange(len(self._resultDimName))]
        else:
            Z_error_list = None
        return (X_list, Z_list, Z_error_list, X_dimName_list)


    ##
    # @brief Parse the result file to build the current object
    # The parameter "multipleTry" has been added to stay compatible with previous version of result file: old version don't contain the value for multiple try per assessment
    # @parameter variableDimForSort indicates the variable dim following which we sort the results
    def parseAndSet(self, resultFileName, multipleTry=False, variableDimForSort=None):
        self._resultFileName = resultFileName
        try:
            resultFile = open(resultFileName, 'r')
        except:
            loggerError(msg="Failed to open the result file", param=resultFileName, exitNow=True)
        self._benchmarkPatternInfo  = nextMeaningfullLine(resultFile)
        self._variableDimName       = nextArrayLine(resultFile)
        nbVariableDim               = len(self._variableDimName)
        self._variableDimValue      = [[] for _ in xrange(nbVariableDim)]
        self._resultDimName         = nextArrayLine(resultFile)
        nbResultDim                 = len(self._resultDimName)
        self._resultDimValue        = [[] for _ in xrange(nbResultDim)]
        if (multipleTry == True):
            self._resultNbTry       = int(nextMeaningfullLine(resultFile))
        else:
            self._resultNbTry       = 1
        self._resultDimValueMin = [[] for _ in xrange(nbResultDim)]
        self._resultDimValueMax = [[] for _ in xrange(nbResultDim)]
#TODO add asserts on all th read values
        nbEntry                 = -1
        variableDimForSortInd   = None
        if (not variableDimForSort is None):
            variableDimForSortInd= findIndexInList(self._variableDimName, variableDimForSort)
            if (variableDimForSortInd is None):
                loggerError(msg="Can't find the \"variable\" to sort from ", param=variableDimForSort, exitNow=True)
            
        while(not isEndOfFile(resultFile)):
            nbEntry += 1
            # Read/Set the variable dimensions
            line = nextArrayLine(resultFile)
            if (len(line) != (self.getNbVariableDim())):
                text = resultFileName + "\nExpected = " + str(self._variableDimName) + " Found = " + str(line)
                loggerError(msg="The result contains corrupted data lines", param=text, exitNow=True)
            pivot = None
            if (not variableDimForSort is None):
                pivot = float(line[variableDimForSortInd])
                pivot = whereInsertInSortedLIst(self._variableDimValue[variableDimForSortInd], pivot)
            for i in xrange(nbVariableDim):
                insertInList(self._variableDimValue[i], float(line[i]), pivot=pivot)

            # Read/Set the results dimensions
            for nbTry in xrange(self._resultNbTry):
                if (isEndOfFile(resultFile)):
                    loggerError(msg="The result contains data lines with missing result dim", param=resultFileName, exitNow=True)
                line = nextArrayLine(resultFile)
                if (len(line) != (self.getNbResultDim())):
                    text = resultFileName + "\nExpected = " + str(self._resultDimName) + " Found = " + str(line)
                    loggerError(msg="The result contains corrupted data lines", param=text, exitNow=True)
                for i in xrange(nbResultDim):
                    value = float(line[i])
                    if (nbTry == 0):
                        if (self._resultNbTry == 1):
                            insertInList(self._resultDimValue[i], value, pivot=pivot)
                        else:
                            insertInList(self._resultDimValue[i], value / float(self._resultNbTry), pivot=pivot)
                        insertInList(self._resultDimValueMin[i], value, pivot=pivot)
                        insertInList(self._resultDimValueMax[i], value, pivot=pivot)
                    else:
                        if (variableDimForSort is None):
                            j = nbEntry
                        else:
                            j = pivot
                        self._resultDimValue[i][j] += value / float(self._resultNbTry)
                        if (self._resultDimValueMin[i][j] > value):
                            self._resultDimValueMin[i][j] = value
                        if (self._resultDimValueMax[i][j] < value):
                            self._resultDimValueMax[i][j] = value
        resultFile.close()


    def toString(self, onlyHeader=False):
        res = ""
        res += strPad("benchmarkPatternInfo" , PAD_PRINT, endChar=': ') + strPad(self._benchmarkPatternInfo  , PAD_PRINT) + "\n"
        if (onlyHeader):
            return res
        res += "\n\t====================================\n"
        res += "\tData:\n\n"


        res         += "\t"
        extraLine   = "\t"
        for i in xrange(len(self._variableDimName)):
            res         += strPad(self._variableDimName[i], PAD_PRINT_DATA) + " "
            extraLine   += strPad("", PAD_PRINT_DATA, padChar='-') + "-"
        res         += " || "
        extraLine   += "-++-"
        for i in xrange(len(self._resultDimName)):
            res += strPad(self._resultDimName[i], PAD_PRINT_DATA) + " "
            extraLine   += strPad("", PAD_PRINT_DATA, padChar='-') + "-"
        res += "\n" + extraLine + "\n"

        for y in xrange(len(self._variableDimValue[0])):
            res += "\t"
            for i in xrange(len(self._variableDimName)):
                res += strPad(self._variableDimValue[i][y], PAD_PRINT_DATA) + " "
            res += " || "
            for i in xrange(len(self._resultDimName)):
                res += strPad(self._resultDimValue[i][y], PAD_PRINT_DATA) + " "
            res += "\n"

        return res

