#!/bin/bash
#PBS -V
#PBS -N s1rep_1
#PBS -q normal
#PBS -A gromacs
#PBS -l select=8:ncpus=64:mpiprocs=64
#PBS -l walltime=48:00:00
#PBS -W sandbox=PRIVATE
cd $PBS_O_WORKDIR
export OMP_NUM_THREADS=1
#-----------------------
# SET computational environments
#
proc=cpu # 
ncpu=512 # 

module purge
module load intel/18.0.3 impi/18.0.3 craype-mic-knl gromacs/2018.6
gmx_s="mpirun -np 1 $(which gmx_mpi)"
gmx_m="mpirun -np ${ncpu} $(which gmx_mpi)"

top=topol.top
tpr=topol.tpr

mdp=step7_production
pstep=step7_3
nstep=step7_4
if [[ ! -e ${pstep}.gro ]]; then

    if [[ -e ${pstep}.cpt ]]  ; then
        ${gmx_m} mdrun -ntomp 1 -cpi ${pstep}.cpt -v -deffnm ${pstep} 
    else
        echo system has big problem
        exit 0
    fi
else
    if [[ ! -e ${nstep}.gro ]]; then
        if [[ -e ${nstep}.cpt ]]  ; then
            sleep 5
            ${gmx_m} mdrun -ntomp 1 -cpi ${nstep}.cpt -v -deffnm ${nstep} 
        else
            ${gmx_s} grompp -f ../mdp/${mdp}.mdp -r ${pstep}.gro -c ${pstep}.gro -p ${top} -o ${nstep}.tpr -n index.ndx -maxwarn -1
            sleep 5
            ${gmx_m} mdrun -ntomp 1 -v -deffnm ${nstep} 
        fi
    fi
fi
