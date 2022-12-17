!!****if* source/Simulation/SimulationMain/LaserSlab/Simulation_init
!!
!! NAME
!!
!!  Simulation_init
!!
!!
!! SYNOPSIS
!!
!!  Simulation_init()
!!
!!
!! DESCRIPTION
!!
!!  Initializes all the parameters needed for a particular simulation
!!
!!
!! ARGUMENTS
!!
!!  
!!
!! PARAMETERS
!!
!!***

subroutine Simulation_init()
  use Simulation_data
  use RuntimeParameters_interface, ONLY : RuntimeParameters_get
  use Logfile_interface, ONLY : Logfile_stamp
  
  implicit none

#include "constants.h"
#include "Flash.h"

  real :: xmin, xmax, ymin, ymax
  integer :: lrefine_max, nblockx, nblocky
  character(len=MAX_STRING_LENGTH) :: str

  call RuntimeParameters_get('sim_LL', sim_LL)
  call RuntimeParameters_get('sim_LR', sim_LR)
  call RuntimeParameters_get('sim_LT', sim_LT)
  call RuntimeParameters_get('sim_LB', sim_LB)
  call RuntimeParameters_get('sim_RL', sim_RL)
  call RuntimeParameters_get('sim_RR', sim_RR)  
  call RuntimeParameters_get('sim_RT', sim_RT)
  call RuntimeParameters_get('sim_RB', sim_RB)
  
  call RuntimeParameters_get('sim_VL', sim_VL)
  call RuntimeParameters_get('sim_VR', sim_VR)
    
  call RuntimeParameters_get('sim_rhoTarg', sim_rhoTarg)
  call RuntimeParameters_get('sim_teleTarg', sim_teleTarg)
  call RuntimeParameters_get('sim_tionTarg', sim_tionTarg)
  call RuntimeParameters_get('sim_tradTarg', sim_tradTarg)

  call RuntimeParameters_get('sim_rhoChamIn', sim_rhoChamIn)
  call RuntimeParameters_get('sim_rhoChamOut', sim_rhoChamOut)
  call RuntimeParameters_get('sim_teleCham', sim_teleCham)
  call RuntimeParameters_get('sim_tionCham', sim_tionCham)
  call RuntimeParameters_get('sim_tradCham', sim_tradCham)

  call RuntimeParameters_get('smallX', sim_smallX)

end subroutine Simulation_init
