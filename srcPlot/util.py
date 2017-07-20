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




from __future__ import print_function
import os
import sys


# ---------------------------------------
# Global parameters
# ---------------------------------------
LIST_SEPARATOR      = ','
DEFAULT_COMMENT     = "#"


# ---------------------------------------
# Global methods
# ---------------------------------------
def loggerError(msg, param=None, exitNow=False):
    print ("\n\n***********************************", file=sys.stderr)
    if (param == None):
        print (msg, file=sys.stderr)
    else:
        print (msg + ": " + param, file=sys.stderr)
    print ("***********************************", file=sys.stderr)

    if (exitNow == True):
        exit(12)


def findIndexInList(listL, valueToLook):
    for i in xrange(len(listL)):
        if (listL[i] == valueToLook):
            return i
    return None


def copyExceptInd(listL, idd):
    assert(idd >= 0)
    assert(idd < len(listL))
    return listL[:idd] + listL[idd+1:]


def equal (a, b):
    return (a == b)
def find(scalar, vector, equalFunc=equal):
    for i in xrange(len(vector)):
        if (equalFunc(scalar, vector[i])):
            return i
    return -1
def findStartWith(scalarStr, vector):
    for i in xrange(len(vector)):
        if (scalarStr.startswith(vector[i])):
            return i
    return -1


# ---------------------------------------
# Data file parser
# ---------------------------------------
def isEndOfFile(fic):
    return (fic.tell() == os.fstat(fic.fileno()).st_size)


def nextMeaningfullLine(fic, commentString=DEFAULT_COMMENT, raiseExceptionIfNon=True):
    while (not isEndOfFile(fic)):
        res = fic.readline().strip()
        if ((commentString != None) and (res.startswith(commentString))):
            continue
        elif (res == "\n" or res == ""):
            continue
        else:
            return res
    if (raiseExceptionIfNon):
        raise Exception("No useful string found in the file " + fic.name)
    else:
        return None


def nextArrayLine(fic, separator=LIST_SEPARATOR):
    return nextMeaningfullLine(fic).split(separator)


def strPad(strInput, nbrPadChar, endChar=None, padChar=' '):
    res = str(strInput)
    if (len(res) > nbrPadChar):
        return res[:nbrPadChar]
    for _ in xrange(nbrPadChar - len(str(strInput))):
        res += padChar
    if (endChar != None):
        res += endChar
    return res


def generateMappedRandomColor():
# TODO change to a result mapped to an f(input)
    import numpy as np
    np.random.rand(3,1)


##
# @brief find the index of the list where to insert the value pivot in order to keep the list sorted
# @details: assumes that the list is sorted in an assending way
def whereInsertInSortedLIst(listL, pivot):
    if ((len(listL) == 0) or (pivot <= listL[0])):
        return 0
    for i in xrange(1, len(listL)):
        if (pivot <= listL[i]):
            return i
    return len(listL)


def insertInList(listL, value, pivot=None):
    if (pivot is None):
        listL.append(value)
    else:
        listL.insert(pivot, value)
    

