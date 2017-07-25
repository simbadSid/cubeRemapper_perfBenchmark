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



## export size=2048; \
## export ficName=profile.cubex; \
## export fic=../../remapperInputDataFile/work/jzam11/jzam1166/measuruments/NPB/NPB3.3-MZ-MPI_scorep-1.2/measurements/E/${size}/scorep_sp-mz_E_${size}x64_sum_filt/${ficName} ;\
## cp ${fic} .; \
## mv ${ficName} resource/cubeInput/${size}_sum_filt_profile.cubex





## -------------------------------
## Global variables
## -------------------------------
CC										=g++ -std=c++11
CFLAGS_UNIX								=-Wall -g -Werror -lrt -pthread
SRC_DIR_PTHREAD_WRAPPER					=srcPthreadWrapper/
BIN_DIR									=bin/

PATH_TRUNK								=../DEV-SL-trunk/
PATH_TRUNK_TCMALLOC						=../DEV-SL-trunk-tcmalloc/
PATH_AIO								=../DEV-SL-AIO/
PATH_AIO_PTHREAD_WRAP					=../DEV-SL-AIO-pthreadWrap/
PATH_AIO_NO_FALSE_SHARING				=../DEV-SL-AIO-noFalseSharing/
PATH_AIO_NO_FALSE_SHARING_TCMALLOC		=../DEV-SL-AIO-noFalseSharing-tcmalloc/
PATH_STATISTIC							=resource/statistic/
PATH_STATISTIC_ARCHIVE					=resource/statistic_archive/
PATH_CUBE_RAMAPPER_BIN					=_build/_install/bin/cube_remap2

NB_CORES								=48
NB_CORES_COMPILE						=22
CUBE_INPUT_SIZE							=128
CUBE_INPUT_SIZE0						=0$(CUBE_INPUT_SIZE)
CUBE_INPUT_FILE							=../remapperInputDataFile/work/jzam11/jzam1166/measuruments/NPB/NPB3.3-MZ-MPI_scorep-1.2/measurements/E/$(CUBE_INPUT_SIZE0)/scorep_sp-mz_E_$(CUBE_INPUT_SIZE)x64_sum_filt/profile.cubex 


## -------------------------------
## Generic functions (take the target directory as first parameter)
## -------------------------------
define preCompile
	cd $(1); \
	rm -rf _build; \
	mkdir _build; \
	./bootstrap; \
	cd _build; \
	../configure --prefix=`pwd`/_install
endef


define clean
	cd $(1); \
	cd _build; \
	make clean
endef


define compile
	cd $(1); \
	cd _build; \
	make -j $(NB_CORES_COMPILE) CXX="$(CC) $(2)" ; \
	make install -j $(NB_CORES_COMPILE)
endef


define compileScorep
	cd $(1)/_build; \
	make -j $(NB_CORES_COMPILE)  CXX="scorep-g++ $(2)" SCOREP_WRAPPER_INSTRUMENTER_FLAGS=" --user --nocompiler"; \
	make install -j $(NB_CORES_COMPILE); \
	cd -
endef


define check
	cd $(1); \
	cd _build; \
	make check; \
	vim build-frontend/test-suite.log
endef


define preCommit
	cd $(1); \
	cd _build; \
	../vendor/common/beautifier/beautify ../src/*; \
	cd ../; \
	meld .
endef


define remapperTime
	cd $(1); \
	cd _build; \
	rm -rf scorep-*; \
	_install/bin/cube_remap2 $(2) -r ../examples/tools/ReMap2/remapping.spec -d -o ../OUTPUT_ASSYNCHRONOUS.cubex ../../$(CUBE_INPUT_FILE); \
	rm ../OUTPUT_ASSYNCHRONOUS.cubex; \
	cube_dump scorep-*/profile.cubex -m time -z incl
endef


define createTcmallocWrapper  
	pwd; \
	mv $(1)$(PATH_CUBE_RAMAPPER_BIN) $(1)$(PATH_CUBE_RAMAPPER_BIN)_payloadBin ;\
	echo '#!/bin/bash'															>  $(1)$(PATH_CUBE_RAMAPPER_BIN); \
	echo "REMAPPER_BIN_TARGET="`pwd`"/$(1)$(PATH_CUBE_RAMAPPER_BIN)_payloadBin"	>> $(1)$(PATH_CUBE_RAMAPPER_BIN); \
	cat srcTool/templateWrapRemapper_tcMalloc									>> $(1)$(PATH_CUBE_RAMAPPER_BIN); \
	chmod +777 $(1)$(PATH_CUBE_RAMAPPER_BIN);
endef


define createPthreadWrapper
	pwd; \
	mv $(1)$(PATH_CUBE_RAMAPPER_BIN) $(1)$(PATH_CUBE_RAMAPPER_BIN)_payloadBin ;\
	echo '#!/bin/bash'															>  $(1)$(PATH_CUBE_RAMAPPER_BIN); \
	echo "REMAPPER_BIN_TARGET="`pwd`"/$(1)$(PATH_CUBE_RAMAPPER_BIN)_payloadBin"	>> $(1)$(PATH_CUBE_RAMAPPER_BIN); \
	echo "LIB_PTHREAD_WRAPPER="`pwd`"/$(BIN_DIR)pthreadWrapper.so"				>> $(1)$(PATH_CUBE_RAMAPPER_BIN); \
	cat srcTool/templateWrapRemapper_pthreadPin									>> $(1)$(PATH_CUBE_RAMAPPER_BIN); \
	chmod +777 $(1)$(PATH_CUBE_RAMAPPER_BIN);
endef


define generatepthreadWrapper.so
			$(CC) -fPIC -c -o $(BIN_DIR)pthreadProxy.o		$(SRC_DIR_PTHREAD_WRAPPER)pthreadProxy.cc	-Wall -g -Werror -pthread;\
			$(CC) -fPIC -c -o $(BIN_DIR)pthreadWrapper.o	$(SRC_DIR_PTHREAD_WRAPPER)pthreadWrapper.cc	-Wall -g -Werror -DNB_CORES=$(NB_CORES) -DCORE_SHIFT=$(1);\
			$(CC) -shared -Wl,-soname,$@ $(BIN_DIR)pthreadWrapper.o $(BIN_DIR)pthreadProxy.o -o $(BIN_DIR)pthreadWrapper.so_$(1)
endef


## -------------------------------
## Precompile target
## -------------------------------
preCompileTrunk:
			$(call preCompile,$(PATH_TRUNK))


preCompileTrunkTcmalloc:
			$(call preCompile,$(PATH_TRUNK_TCMALLOC))


preCompileAio:
			$(call preCompile,$(PATH_AIO))


preCompileAioNoFalseSharing:
			$(call preCompile,$(PATH_AIO_NO_FALSE_SHARING))


preCompileAioNoFalseSharingTcmalloc:
			$(call preCompile,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC))


preCompileAioPthreadWrap:
			$(call preCompile,$(PATH_AIO_PTHREAD_WRAP))


## -------------------------------
## Clean (local) target
## -------------------------------
cleanTrunk:
			$(call clean,$(PATH_TRUNK))


cleanTrunkTcmalloc:
			$(call clean,$(PATH_TRUNK_TCMALLOC))


cleanAio:
			$(call clean,$(PATH_AIO))


cleanAioNoFalseSharing:
			$(call clean,$(PATH_AIO_NO_FALSE_SHARING))


cleanAioNoFalseSharingTcmalloc:
			$(call clean,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC))


cleanAioPthreadWrap:
			$(call clean,$(PATH_AIO_PTHREAD_WRAP))


## -------------------------------
## Compile target
## -------------------------------
compileTrunk:
			$(call compile,$(PATH_TRUNK), "-DNO_INSTRUMENT")


compileTrunkTcmalloc:
			$(call compile,$(PATH_TRUNK_TCMALLOC), "-DNO_INSTRUMENT"); \;
			cd $(PATH_ROOT); \
			$(call createTcmallocWrapper,$(PATH_TRUNK_TCMALLOC))


compileAio:
			$(call compile,$(PATH_AIO), "-DNO_INSTRUMENT")


compileAioNoFalseSharing:
			$(call compile,$(PATH_AIO_NO_FALSE_SHARING), "-DNO_INSTRUMENT -DNO_FALSE_SHARING")


compileAioNoFalseSharingTcmalloc:
			$(call compile,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC), "-DNO_INSTRUMENT -DNO_FALSE_SHARING"); \
			cd $(PATH_ROOT); \
			$(call createTcmallocWrapper,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC))


compileAioPthreadWrap:
			$(call compile,$(PATH_AIO_PTHREAD_WRAP), "-DNO_INSTRUMENT")


## -------------------------------
## Compile (Scorep) target
## -------------------------------
compileTrunkScorep:
			$(call compileScorep,$(PATH_TRUNK))


compileTrunkTcmallocScorep:
			$(call compileScorep,$(PATH_TRUNK_TCMALLOC)); \
			$(call createTcmallocWrapper,$(PATH_TRUNK_TCMALLOC))


compileAioScorep:
			$(call compileScorep,$(PATH_AIO))


compileAioNoFalseSharingScorep:
			$(call compileScorep,$(PATH_AIO_NO_FALSE_SHARING), "-DNO_FALSE_SHARING")


compileAioNoFalseSharingTcmallocScorep:
			$(call compileScorep,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC), "-DNO_FALSE_SHARING"); \
			$(call createTcmallocWrapper,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC))


compileAioPthreadWrapScorep:
			$(call compileScorep,$(PATH_AIO_PTHREAD_WRAP)); \
			$(call createPthreadWrapper,$(PATH_AIO_PTHREAD_WRAP))


## -------------------------------
## Check target
## -------------------------------
checkTrunk:		compileTrunk
			$(call check,$(PATH_TRUNK))


checkTrunkTcmalloc:		compileTrunkTcmalloc
			$(call check,$(PATH_TRUNK_TCMALLOC))


checkAio:		compileAio
			$(call check,$(PATH_AIO))


checkAioNoFalseSharing:		compileAioNoFalseSharing
			$(call check,$(PATH_AIO_NO_FALSE_SHARING))


checkAioNoFalseSharingTcmalloc:		compileAioNoFalseSharingTcmalloc
			$(call check,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC))


checkAioPthreadWrap:		compileAioPthreadWrap
			$(call check,$(PATH_AIO_PTHREAD_WRAP))


## -------------------------------
## Print remapper time target
## -------------------------------
printRemapperTimeTrunk:
			$(call remapperTime,$(PATH_TRUNK))


printRemapperTimeTrunkTcmalloc:
			$(call remapperTime,$(PATH_TRUNK_TCMALLOC))


printRemapperTimeAio:
			$(call remapperTime,$(PATH_AIO))


printRemapperTimeAioNoFalseSharing:
			$(call remapperTime,$(PATH_AIO_NO_FALSE_SHARING))


printRemapperTimeAioNoFalseSharingTcmalloc:
			$(call remapperTime,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC))


printRemapperTimeAioPthreadWrap:
			$(call remapperTime,$(PATH_AIO_PTHREAD_WRAP),4)


## -------------------------------
## Precommit (local) target
## -------------------------------
preCommitTrunk:
			$(call preCommit,$(PATH_TRUNK))


preCommitAio:
			$(call preCommit,$(PATH_AIO))


preCommitAioNoFalseSharing:
			$(call preCommit,$(PATH_AIO_NO_FALSE_SHARING))


preCommitAioNoFalseSharingTcmalloc:
			$(call preCommit,$(PATH_AIO_NO_FALSE_SHARING_TCMALLOC))


#-----------------------------------------------------------------------------------------------------------
#---------------------------------------- Pthread Wrapper Methods ------------------------------------------
#-----------------------------------------------------------------------------------------------------------
pthreadWrapper.so:
			$(call generatepthreadWrapper.so,1)


pthreadWrapper.so_all:
			for i in `seq $(NB_CORES)`; do \
				$(call generatepthreadWrapper.so,$$i); \
			done

#-----------------------------------------------------------------------------------------------------------
#---------------------------------------- Experimentation Methodes -----------------------------------------
#-----------------------------------------------------------------------------------------------------------
runAllBenchmark:	compileTrunkScorep compileTrunkTcmallocScorep compileAioNoFalseSharingTcmallocScorep compileAioScorep compileAioNoFalseSharingScorep  
			jube run benchmarkInstrumentation.xml --only-bench init_outputFile; \
			jube run benchmarkInstrumentation.xml --only-bench run_benchmark;


runNumaSocketHopeBenchmark:	compileTrunkScorep compileAioNoFalseSharingTcmallocScorep pthreadWrapper.so_all
			jube run benchmarkInstrumentation_numaSocketHopeImpact.xml --only-bench init_outputFile; \
			jube run benchmarkInstrumentation_numaSocketHopeImpact.xml --only-bench run_benchmark;


plotPointCompare:
			jube run benchmarkInstrumentation.xml --only-bench plotPointCompare


plotPointCompareNumaSocketHopeBenchmark:
			jube run benchmarkInstrumentation_numaSocketHopeImpact.xml --only-bench plotPointCompare


plotPoint:
			jube run benchmarkInstrumentation.xml --only-bench plotPoint


plotPointNumaSocketHopeBenchmark:
			jube run benchmarkInstrumentation_numaSocketHopeImpact.xml --only-bench plotPoint


plotPointCompareArchive:
			srcTool/setStatisticFromArchiveInteractive.sh $(PATH_STATISTIC) $(PATH_STATISTIC_ARCHIVE); \
			jube run benchmarkInstrumentation.xml --only-bench plotPointCompare


plotPointCompareNumaSocketHopeBenchmarkArchive:
			srcTool/setStatisticFromArchiveInteractive.sh $(PATH_STATISTIC) $(PATH_STATISTIC_ARCHIVE); \
			jube run benchmarkInstrumentation_numaSocketHopeImpact.xml --only-bench plotPointCompare



#-----------------------------------------------------------------------------------------------------------
#---------------------------------------- General Methodes -------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
.PHONY:		cleanJube clean


cleanJube:
			rm -rf bench_run jube-parse.log

clean: cleanTrunk cleanAio cleanAioNoFalseSharing cleanAioNoFalseSharingTcmalloc cleanJube
			rm $(BIN_DIR)*

