#!/bin/ksh
if [ $# = 0 ] ; then
   echo USAGE: RUN_calinter.ksh  year1 year2
   exit 1
fi
#set -x

# get configuration settings
. ./config_moy.ksh
. ./function_moy.ksh

# set additional variables
mkdir -p  $WPDIR


# copy required scripts there:
cp -f config_moy.ksh $WPDIR
cp -f function_moy.ksh $WPDIR

# get year to work with
year1=$1
year2=$2


cat << eof > zcalinter_${year1}-${year2}
#!/bin/bash
#PBS -q mpi
#PBS -l select=1:ncpus=28:mpiprocs=12:mem=65G
#PBS -l walltime=05:00:00

CTL_DIR=$WPDIR
cd \$CTL_DIR
. ./config_moy.ksh
. ./function_moy.ksh

interannual $year1 $year2

eof

qsub  zcalinter_${year1}-${year2}


