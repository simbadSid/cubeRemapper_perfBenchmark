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
CC										= g++ -std=c++11
CFLAGS_UNIX								= -Wall -g -Werror -lrt -pthread
SRC_DIR_PTHREAD_WRAPPER					= srcPthreadWrapper/
BIN_DIR									= bin/

PATH_TRUNK								= ../DEV-SL-trunk
PATH_AIO								= ../DEV-SL-AIO
PATH_AIO_NO_FALSE_SHARING				= ../DEV-SL-AIO-noFalseSharing
PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC	= ../DEV-SL-AIO-noFalseSharing-customAlloc
PATH_STATISTIC							= resource/statistic
PATH_STATISTIC_ARCHIVE					= resource/statistic_archive

NB_CORES								= 22
CUBE_INPUT_SIZE							= 128
CUBE_INPUT_SIZE0						= 0$(CUBE_INPUT_SIZE)
CUBE_INPUT_FILE							= ../remapperInputDataFile/work/jzam11/jzam1166/measuruments/NPB/NPB3.3-MZ-MPI_scorep-1.2/measurements/E/$(CUBE_INPUT_SIZE0)/scorep_sp-mz_E_$(CUBE_INPUT_SIZE)x64_sum_filt/profile.cubex 


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
	make clean;
endef


define compile
	cd $(1); \
	cd _build; \
	make -j $(NB_CORES) CXX="$(CC) $(2)" ; \
	make install -j $(NB_CORES)
endef


define compileScorep
	cd $(1); \
	cd _build; \
	make -j $(NB_CORES)  CXX="scorep-g++ $(2)" SCOREP_WRAPPER_INSTRUMENTER_FLAGS=" --user --nocompiler"; \
	make install -j $(NB_CORES)
endef


define check
	cd $(1); \
	cd _build; \
	make check; \
	vim build-frontend/test-suite.log;
endef


define preCommit
	cd $(1); \
	cd _build; \
	../vendor/common/beautifier/beautify ../src/*; \
	cd ../; \
	meld . ;

endef


define remapperTime
	cd $(1); \
	cd _build; \
	rm -rf scorep-*; \
	_install/bin/cube_remap2 -r ../examples/tools/ReMap2/remapping.spec -d -o ../OUTPUT_ASSYNCHRONOUS.cubex ../../$(CUBE_INPUT_FILE); \
	rm ../OUTPUT_ASSYNCHRONOUS.cubex; \
	cube_dump scorep-*/profile.cubex -m time -z incl
endef


## -------------------------------
## Local functions
## -------------------------------
preCompileTrunk:
			$(call preCompile, $(PATH_TRUNK))


preCompileAio:
			$(call preCompile, $(PATH_AIO))


preCompileAioNoFalseSharing:
			$(call preCompile, $(PATH_AIO_NO_FALSE_SHARING))


preCompileAioNoFalseSharingCustomAlloc:
			$(call preCompile, $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC))


cleanTrunk:
			$(call clean, $(PATH_TRUNK))


cleanAio:
			$(call clean, $(PATH_AIO))


cleanAioNoFalseSharing:
			$(call clean, $(PATH_AIO_NO_FALSE_SHARING))


cleanAioNoFalseSharingCustomAlloc:
			$(call clean, $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC))


compileTrunk:
			$(call compile, $(PATH_TRUNK), "-DNO_INSTRUMENT")


compileAio:
			$(call compile, $(PATH_AIO), "-DNO_INSTRUMENT")


compileAioNoFalseSharing:
			$(call compile, $(PATH_AIO_NO_FALSE_SHARING), "-DNO_INSTRUMENT -DNO_FALSE_SHARING")


compileAioNoFalseSharingCustomAlloc:
			$(call compile, $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC), "-DNO_INSTRUMENT -DNO_FALSE_SHARING"); \
			mv $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC)_install/bin/cube_remap2 $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC)_install/bin/cube_remap2_main ;\
			cat srcTool/templateWrapRemapperExec > $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC)_insta


compileTrunkScorep:
			$(call compileScorep, $(PATH_TRUNK))


compileAioScorep:
			$(call compileScorep, $(PATH_AIO))


compileAioNoFalseSharingScorep:
			$(call compileScorep, $(PATH_AIO_NO_FALSE_SHARING), "-DNO_FALSE_SHARING")


compileAioNoFalseSharingCustomAllocScorep:
			$(call compileScorep, $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC), "-DNO_FALSE_SHARING"); \
			mv $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC)_install/bin/cube_remap2 $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC)_install/bin/cube_remap2_main ;\
			cat srcTool/templateWrapRemapperExec > $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC)_install/bin/cube_remap2_main; \


checkTrunk:		compileTrunk
			$(call check, $(PATH_TRUNK))


checkAio:		compileAio
			$(call check, $(PATH_AIO))


checkAioNoFalseSharing:		compileAioNoFalseSharing
			$(call check, $(PATH_AIO_NO_FALSE_SHARING))


checkAioNoFalseSharingCustomAlloc:		compileAioNoFalseSharingCustomAlloc
			$(call check, $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC))


printRemapperTimeTrunk:
			$(call remapperTime, $(PATH_TRUNK))


printRemapperTimeAio:
			$(call remapperTime, $(PATH_AIO))


printRemapperTimeAioNoFalseSharing:
			$(call remapperTime, $(PATH_AIO_NO_FALSE_SHARING))


printRemapperTimeAioNoFalseSharingCustomAlloc:
			$(call remapperTime, $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC))


preCommitTrunk:
			$(call preCommit, $(PATH_TRUNK))


preCommitAio:
			$(call preCommit, $(PATH_AIO))


preCommitAioNoFalseSharing:
			$(call preCommit, $(PATH_AIO_NO_FALSE_SHARING))


preCommitAioNoFalseSharingCustomAlloc:
			$(call preCommit, $(PATH_AIO_NO_FALSE_SHARING_CUSTOM_ALLOC))


#-----------------------------------------------------------------------------------------------------------
#---------------------------------------- Pthread Wrapper Methods -------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
pthreadWrapper.so:
			$(CC) -fPIC -c -o $(BIN_DIR)pthreadProxy.o		$(SRC_DIR_PTHREAD_WRAPPER)pthreadProxy.cc	-Wall -g -Werror  -pthread;\
			$(CC) -fPIC -c -o $(BIN_DIR)pthreadWrapper.o	$(SRC_DIR_PTHREAD_WRAPPER)pthreadWrapper.cc	-Wall -g -Werror -DNB_CPU=$(NB_CORES);\
			$(CC) -shared -Wl,-soname,$@ $(BIN_DIR)pthreadWrapper.o $(BIN_DIR)pthreadProxy.o -o $(BIN_DIR)$@


#-----------------------------------------------------------------------------------------------------------
#---------------------------------------- Experimentation Methodes -----------------------------------------
#-----------------------------------------------------------------------------------------------------------
runAllBenchmark:	compileTrunkScorep compileAioScorep compileAioNoFalseSharingScorep
			jube run benchmarkInstrumentation.xml --only-bench init_outputFile; \
			jube run benchmarkInstrumentation.xml --only-bench run_benchmark;


plotPointCompare:
			jube run benchmarkInstrumentation.xml --only-bench plotPointCompare


plotPoint:
			jube run benchmarkInstrumentation.xml --only-bench plotPoint


plotPointCompareArchive:
			srcTool/setStatisticFromArchiveInteractive.sh $(PATH_STATISTIC) $(PATH_STATISTIC_ARCHIVE); \
			jube run benchmarkInstrumentation.xml --only-bench plotPointCompare



#-----------------------------------------------------------------------------------------------------------
#---------------------------------------- General Methodes -------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
.PHONY:		cleanJube 


cleanJube:
			rm -rf bench_run jube-parse.log

clean:
			rm $(BIN_DIR)*

