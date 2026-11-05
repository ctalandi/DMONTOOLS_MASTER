#!/bin/ksh
# RUN_calmoy version for DATARMOR
if [ $# = 0 ] ; then
   echo USAGE: RUN_calmoy.ksh  year
   exit 1
fi
#set -xv

# get configuration settings
. ./config_moy.ksh
. ./function_moy.ksh

pbsext=datarmor

# set additional variables WPDIR set in config_moy
mkdir -p $WPDIR

# copy required scripts there:
cp -f config_moy.ksh $WPDIR
cp -f function_moy.ksh $WPDIR

cp -f $MPDIR/mvcalmoy.ksh $WPDIR
cp -f $MPDIR/calannual.ksh $WPDIR

# get year to work with
year=$1

#prepare the 12 scripts in WPDIR

# due to problems with mpi_shell
# changes are made...     VH

jobids='afterok'

for m in $(seq 1 12) ; do
  mm=$(printf "%02d" $m )
  cat $MPDIR/calmoy_mm.ksh | sed -e "s/<year>/$year/g" -e "s/<mm>/$mm/g" -e "s/<m>/$m/g" > $WPDIR/zz_calmoy_${mm}_$year.ksh
  chmod 755 $WPDIR/zz_calmoy_${mm}_$year.ksh

  # submit calmoy.$pbsext
  cat $MPDIR/calmoy.$pbsext | sed -e "s/$MACHINE/PBS/" \
                     -e "s/<CONFIG>/$CONFIG/" -e "s/<CASE>/$CASE/" \
                     -e "s/<month>/${mm}/" -e "s/<year>/$year/g" \
                     -e "s@<WPDIR>@$WPDIR@" \
                     -e "s@<JBNAME>@zcalmoy.${year}${mm}@" \
                     -e "s@<MPITOOLS>@$MPITOOLS@"  > zcalmoy.$mm.$pbsext
  
  jobidmoy=$(submit zcalmoy.$mm.$pbsext  | awk '{print $NF}' )
  # collect all jobidmoy
  
  jobids="${jobids}:${jobidmoy}"
  
  \rm zcalmoy.$mm.$pbsext

#### NOT USED  #prepare the 12 scripts in WPDIR
#### NOT USED  
#### NOT USED    cat $MPDIR/calmoyvt_mm.ksh | sed -e "s/<year>/$year/g" -e "s/<mm>/$mm/g" -e "s/<m>/$m/g" > $WPDIR/zz_calmoyvt_${mm}_$year.ksh
#### NOT USED    chmod 755 $WPDIR/zz_calmoyvt_${mm}_$year.ksh
#### NOT USED  
#### NOT USED  # submit calmoyvt.$pbsext
#### NOT USED  cat $MPDIR/calmoyvt.$pbsext | sed  -e "s/$MACHINE/PBS/" \
#### NOT USED                     -e "s/<CONFIG>/$CONFIG/" -e "s/<CASE>/$CASE/" \
#### NOT USED                     -e "s/<month>/${mm}/" -e "s/<year>/$year/g" \
#### NOT USED                     -e "s@<WPDIR>@$WPDIR@" \
#### NOT USED                     -e "s@<MPITOOLS>@$MPITOOLS@" > zcalmoyvt.$mm.$pbsext
#### NOT USED  jobidvt=$(submit zcalmoyvt.$mm.$pbsext  | awk '{print $NF}' )
#### NOT USED  # collect all jobidvt
#### NOT USED  
#### NOT USED  jobids="${jobids}:${jobidvt}"
#### NOT USED  
#### NOT USED  \rm zcalmoyvt.$mm.$pbsext

done


# submit calanual script with dependencies afterok on jobidmoy and jobidvt

echo $jobids

cat $MPDIR/calannual.$pbsext | sed -e "s/$MACHINE/PBS/" \
     -e "s/<CONFIG>/$CONFIG/" -e "s/<CASE>/$CASE/" \
     -e "s/<JOBIDMOY>/$jobids/" -e "s/<year>/$year/g" \
     -e "s@<JBNAME>@zcalannual.${year}@" \
     -e "s@<WPDIR>@$WPDIR@"  > zcalannual_$year.$pbsext

submit zcalannual_$year.$pbsext

