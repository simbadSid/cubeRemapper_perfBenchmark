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
CC						= g++ -std=c++11
CFLAGS_UNIX				= -Wall -g -Werror -lrt -pthread
SRC_DIR_PTHREAD_WRAPPER	= srcPthreadWrapper/
BIN_DIR					= bin/

PATH_TRUNK		= ../DEV-SL-trunk
PATH_AIO		= ../DEV-SL-AIO
NB_CORES		= 22
CUBE_INPUT_SIZE	= 128
CUBE_INPUT_SIZE0= 0$(CUBE_INPUT_SIZE)
CUBE_INPUT_FILE	= ../remapperInputDataFile/work/jzam11/jzam1166/measuruments/NPB/NPB3.3-MZ-MPI_scorep-1.2/measurements/E/$(CUBE_INPUT_SIZE0)/scorep_sp-mz_E_$(CUBE_INPUT_SIZE)x64_sum_filt/profile.cubex 


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
	make -j $(NB_CORES) -I/usr/bin/include -I/usr/bin/include/scorep; \
	make install -j $(NB_CORES)
endef


define compileScorep
	cd $(1); \
	cd _build; \
	make -j $(NB_CORES)  CXX="scorep-g++ -DNO_INSTRUMENT" SCOREP_WRAPPER_INSTRUMENTER_FLAGS=" --user --nocompiler"; \
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
	cd /_build; \
	vendor/common/beautifier/beautify; \
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


cleanTrunk:
			$(call clean, $(PATH_TRUNK))


cleanAio:
			$(call clean, $(PATH_AIO))


compileTrunk:
			$(call compile, $(PATH_TRUNK))


compileAio:
			$(call compile, $(PATH_AIO))


compileTrunkScorep:
			$(call compileScorep, $(PATH_TRUNK))


compileAioScorep:
			$(call compileScorep, $(PATH_AIO))


checkTrunk:		compileTrunkScorep
			$(call compile, $(PATH_TRUNK))


checkAio:		compileAioScorep
			$(call compile, $(PATH_AIO))


printRemapperTimeTrunk:
			$(call remapperTime, $(PATH_TRUNK))


printRemapperTimeAio:
			$(call remapperTime, $(PATH_AIO))


preCommitTrunk:
			$(call preCommit, $(PATH_TRUNK))


preCommitAio:
			$(call preCommit, $(PATH_AIO))


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
runAllBenchmark:
			jube run benchmarkInstrumentation.xml --only-bench init_outputFile; \
			jube run benchmarkInstrumentation.xml --only-bench run_benchmark;


plotPointCompare:
			jube run benchmarkInstrumentation.xml --only-bench plotPointCompare


plotPoint:
			jube run benchmarkInstrumentation.xml --only-bench plotPoint



#-----------------------------------------------------------------------------------------------------------
#---------------------------------------- General Methodes -------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
.PHONY:		cleanJube 


cleanJube:
			rm -rf bench_run jube-parse.log

clean:
			rm $(BIN_DIR)*

