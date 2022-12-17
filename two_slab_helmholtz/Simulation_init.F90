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

  call RuntimeParameters_get('sim_rhoHE4In', sim_rhoHE4In)
  call RuntimeParameters_get('sim_rhoHE4Out', sim_rhoHE4Out)
  call RuntimeParameters_get('sim_tempHE4', sim_tempHE4)

  call RuntimeParameters_get('smallX', sim_smallX)

end subroutine Simulation_init
