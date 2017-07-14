# Performance assessment of the cube Remapper
This project allows to assess the performance of the [Cube](http://www.scalasca.org/software/cube-4.x/download.html) plugin: "remapper".</br>
We mainly compare the deployed implementation (refered to as [trunk](https://svn.version.fz-juelich.de/scalasca_soft/Cube2.0/CubeLib/trunk)) with our custom one (refered to as [AIO](https://svn.version.fz-juelich.de/scalasca_soft/Cube2.0/CubeLib/branches/DEV-SL-AIO)). </br>

## Prerequisite
Before installing or running any of the cited projects, one must insure that the following tools are installed:
  1. The [Score-P](http://www.vi-hps.org/projects/score-p/)(see the INSTALL file within this project).  The "orphaned pthreads" version needs to be used.</br>
  2. The [Cube](http://www.scalasca.org/software/cube-4.x/download.html) (see the INSTALL file within this project).  We will re install different version of it.   But this basic version is required for internal profiling needs.</br>
  3. The [Jube](http://www.fz-juelich.de/ias/jsc/EN/Expertise/Support/Software/JUBE/JUBE2/_node.html)</br>

## Install
Once the two previously cited project ([trunk](https://svn.version.fz-juelich.de/scalasca_soft/Cube2.0/CubeLib/trunk] and [AIO](https://svn.version.fz-juelich.de/scalasca_soft/Cube2.0/CubeLib/branches/DEV-SL-AIO]) have been downloaded and set as neighbor directories to the current project (outside the current project), the installation process of these two projects might be done through the Makefile within the current project.   One might achieve a basic installation through the following commands (from the current project):

### Install the trunk version of Cube
**>make preCompileTrunk**   </br>
**>make compileTrunkScorep** </br> 

### Install the custom (AIO) version of Cube
**>make preCompileAio**        </br>
**>make compileAioScorep**     </br>

## Run the performance evaluation
The performance evaluation might be runed through the command </br>
**>make runAllBenchmark** </br>
Then the results might be ploted through different graphical representations using the command </br>
**>make plotPointCompare** </br>
**>make plotPoint** </br>
