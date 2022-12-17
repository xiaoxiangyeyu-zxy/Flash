!!****if* source/Simulation/SimulationMain/LaserSlab/Simulation_data
!!
!! NAME
!!  Simulation_data
!!
!! SYNOPSIS
!!  Use Simulation_data
!!
!! DESCRIPTION
!!
!!  Store the simulation data
!!
!! 
!!***
module Simulation_data

  implicit none

#include "constants.h"

  !! *** Runtime Parameters *** !!  
  real, save :: sim_VL
  real, save :: sim_VR

  real, save :: sim_LL
  real, save :: sim_LR
  real, save :: sim_LT
  real, save :: sim_LB
  real, save :: sim_RL
  real, save :: sim_RR
  real, save :: sim_RT
  real, save :: sim_RB

  real,    save :: sim_rhoTarg  
  real,    save :: sim_teleTarg 
  real,    save :: sim_tionTarg 
  real,    save :: sim_tradTarg 
  real,    save :: sim_zminTarg
  integer, save :: sim_eosTarg

  real,    save :: sim_rhoChamIn
  real,    save :: sim_rhoChamOut 
  real,    save :: sim_teleCham 
  real,    save :: sim_tionCham 
  real,    save :: sim_tradCham 
  integer, save :: sim_eosCham  

  real, save :: sim_smallX

end module Simulation_data


