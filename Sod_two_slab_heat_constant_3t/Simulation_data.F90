!!****if* source/Simulation/SimulationMain/Sod/Simulation_data
!!
!! NAME
!!  Simulation_data
!!
!! SYNOPSIS
!!
!!  use Simulation_data
!!
!! DESCRIPTION
!!
!!  Store the simulation data for the Sod problem
!!
!! ARGUMENTS
!!
!!
!! PARAMETERS
!!
!!  sim_rhoIn      Density of the slab
!!  sim_rhoOut     Density of the circumstance
!!  sim_pIn        Pressure of the slab
!!  sim_pOut       Pressure of the circumstance 
!!  sim_uLeft      fluid velocity of the left slab
!!  sim_uRight     fluid velocity of the right slab
!!  
!!  sim_LL         left coordinate of the left slab
!!  sim_LR         right coordinate of the left slab
!!  sim_LT         top coordinate of the left slab
!!  sim_LB         bottom coordinate of the left slab
!!  sim_RL         left coordinate of the right slab
!!  sim_RR         right coordinate of the right slab
!!  sim_RT         top coordinate of the right slab
!!  sim_RB         bottom coordinate of the right slab
!!
!!   
!!
!!***

module Simulation_data
#include "Flash.h"
  implicit none

  !! *** Runtime Parameters *** !!
  
  !yu
  real, save :: sim_rhoIn, sim_rhoOut, sim_pIn, sim_pOut
  real, save :: sim_uLeft, sim_uRight
  real, save :: sim_LL, sim_LR, sim_LT, sim_LB
  real, save :: sim_RL, sim_RR, sim_RT, sim_RB
  !yu

  real, save :: sim_gamma, sim_smallP, sim_smallX
#ifdef SIMULATION_TWO_MATERIALS
  real, save :: sim_abarLeft, sim_zbarLeft, sim_abarRight, sim_zbarRight
#endif

#ifdef FLASH_3T
  !! 3T Variables:
  real, save :: sim_pionIn
  real, save :: sim_pionOut
  real, save :: sim_peleIn
  real, save :: sim_peleOut
  real, save :: sim_pradIn
  real, save :: sim_pradOut

  real, save :: sim_gammaIon, sim_gammaEle
#endif

  !! *** Variables pertaining to Simulation Setup 'Sod' *** !!
  real, save :: sim_xCos, sim_yCos, sim_zCos
  logical, save :: sim_gCell

  integer, save :: sim_meshMe
end module Simulation_data


