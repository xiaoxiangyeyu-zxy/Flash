!!****if* source/Simulation/SimulationMain/Sod/Simulation_initBlock
!!
!! NAME
!!
!!  Simulation_initBlock
!!
!!
!! SYNOPSIS
!!
!!  Simulation_initBlock(integer(IN) :: blockID) 
!!                       
!!
!!
!!
!! DESCRIPTION
!!
!!  Initializes fluid data (density, pressure, velocity, etc.) for
!!  a specified block.  This version sets up the Sod shock-tube
!!  problem.
!!
!!  Reference: Sod, G. A., 1978, J. Comp. Phys., 27, 1
!!
!! 
!! ARGUMENTS
!!
!!  blockID -           the number of the block to update
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
!!***

subroutine Simulation_initBlock(blockID)

#include "constants.h"
#include "Flash.h"
#include "Eos.h"

!yu
  use Simulation_data, ONLY:  sim_xCos, sim_yCos, sim_zCos, &    
     &  sim_rhoIn,  sim_pIn, sim_uLeft, sim_rhoOut, sim_pOut, sim_uRight, &
     &  sim_smallX, sim_gamma, sim_smallP, sim_LL, sim_LR, &
     &  sim_LT, sim_LB, sim_RL, sim_RR, sim_RT, sim_RB
!yu
#ifdef FLASH_3T
  use Simulation_data, ONLY : &
       sim_pionLeft, sim_peleLeft, sim_pradLeft, &
       sim_pionRight, sim_peleRight, sim_pradRight, &
       sim_gammaIon, sim_gammaEle
#endif
     
  use Grid_interface, ONLY : Grid_getBlkIndexLimits, &
    Grid_getCellCoords, Grid_putPointData
  use Eos_interface, ONLY : Eos, Eos_wrapped


  implicit none

  ! compute the maximum length of a vector in each coordinate direction 
  ! (including guardcells)
  
  integer, intent(in) :: blockID
  

  integer :: i, j, k, n
  integer :: iMax, jMax, kMax
  


  real :: xx, yy,  zz, xxL, xxR
  
  real :: lPosn0, lPosn
  

  real,allocatable, dimension(:) ::xCenter,xLeft,xRight,yCoord,zCoord

  integer, dimension(2,MDIM) :: blkLimits, blkLimitsGC
  integer :: sizeX,sizeY,sizeZ
  integer, dimension(MDIM) :: axis

  
  real :: rhoZone, velxZone, velyZone, velzZone, presZone, & 
       eintZone, enerZone, ekinZone, gameZone, gamcZone

#ifdef SIMULATION_TWO_MATERIALS
  real, dimension(EOS_NUM) :: eosData
  real, dimension(NSPECIES) :: mfrac
#endif

#ifdef FLASH_3T
  real :: peleZone, eeleZone
  real :: pionZone, eionZone
  real :: pradZone, eradZone
#endif
  
  logical :: gcell = .true.

  
  ! dump some output to stdout listing the paramters
!!$  if (sim_meshMe == MASTER_PE) then
!!$     
!!$     
!!$1    format (1X, 1P, 4(A7, E13.7, :, 1X))
!!$2    format (1X, 1P, 2(A7, E13.7, 1X), A7, I13)
!!$     
!!$  endif
  
  
  ! get the integer index information for the current block
  call Grid_getBlkIndexLimits(blockId,blkLimits,blkLimitsGC)
  
  sizeX = blkLimitsGC(HIGH,IAXIS)
  sizeY = blkLimitsGC(HIGH,JAXIS)
  sizeZ = blkLimitsGC(HIGH,KAXIS)
  allocate(xLeft(sizeX))
  allocate(xRight(sizeX))
  allocate(xCenter(sizeX))
  allocate(yCoord(sizeY))
  allocate(zCoord(sizeZ))
  xCenter = 0.0
  xLeft = 0.0
  xRight = 0.0
  yCoord = 0.0
  zCoord = 0.0

  if (NDIM == 3) call Grid_getCellCoords&
                      (KAXIS, blockId, CENTER,gcell, zCoord, sizeZ)
  if (NDIM >= 2) call Grid_getCellCoords&
                      (JAXIS, blockId, CENTER,gcell, yCoord, sizeY)

  call Grid_getCellCoords(IAXIS, blockId, LEFT_EDGE, gcell, xLeft, sizeX)
  call Grid_getCellCoords(IAXIS, blockId, CENTER, gcell, xCenter, sizeX)
  call Grid_getCellCoords(IAXIS, blockId, RIGHT_EDGE, gcell, xRight, sizeX)

!------------------------------------------------------------------------------

! Loop over cells in the block.  For each, compute the physical position of 
! its left and right edge and its center as well as its physical width.  
! Then decide which side of the initial discontinuity it is on and initialize 
! the hydro variables appropriately.


  do k = blkLimits(LOW,KAXIS),blkLimits(HIGH,KAXIS)
     
     ! get the coordinates of the cell center in the z-direction
     zz = zCoord(k)
     
     ! Where along the x-axis the shock intersects the xz-plane at the current z.
     !lPosn0 = sim_posn - zz*sim_zCos/sim_xCos
     
     do j = blkLimits(LOW,JAXIS),blkLimits(HIGH,JAXIS)
        
        ! get the coordinates of the cell center in the y-direction
        yy = yCoord(j)
        
        ! The position of the shock in the current yz-row.
        !lPosn = lPosn0 - yy*sim_yCos/sim_xCos
        
        do i = blkLimits(LOW,IAXIS),blkLimits(HIGH,IAXIS)
           
           ! get the cell center, left, and right positions in x
           xx  = xCenter(i)
           
           xxL = xLeft(i)
           xxR = xRight(i)
          
           !yu

           ! initialize cells to the left of the initial shock.
           if ((xx >= sim_LL) .and. (xx <= sim_LR) .and. (yy <= sim_LT) .and. (yy >= sim_LB)) then
#ifdef FLASH_3T
              peleZone = sim_peleLeft
              pionZone = sim_pionLeft
              pradZone = sim_pradLeft
#else
              presZone = sim_pIn
#endif              

              rhoZone = sim_rhoIn
              velxZone = sim_uLeft
              velyZone = 0.
              velzZone = 0.

#ifdef SIMULATION_TWO_MATERIALS
              mfrac(LEFT_SPEC - SPECIES_BEGIN+1) = 1.0
              mfrac(RGHT_SPEC - SPECIES_BEGIN+1) = 0.0
#endif
              
              ! initialize cells which straddle the shock.  Treat them as though 1/2 of 
              ! the cell lay to the left and 1/2 lay to the right.
           elseif ((xx >= sim_RL) .and. (xx <= sim_RR) .and. (yy <= sim_RT) .and. (yy >= sim_RB)) then              
#ifdef FLASH_3T
              peleZone = 0.5 * (sim_peleLeft + sim_peleRight)
              pionZone = 0.5 * (sim_pionLeft + sim_pionRight)
              pradZone = 0.5 * (sim_pradLeft + sim_pradRight)
#else
              presZone = sim_pIn
#endif              
              
              rhoZone = sim_rhoIn
              velxZone = sim_uRight
              velyZone = 0.
              velzZone = 0.
              
#ifdef SIMULATION_TWO_MATERIALS
              mfrac(LEFT_SPEC - SPECIES_BEGIN+1) = 0.5
              mfrac(RGHT_SPEC - SPECIES_BEGIN+1) = 0.5
#endif

              ! initialize cells to the right of the initial shock.
           else              
#ifdef FLASH_3T
              peleZone = sim_peleRight
              pionZone = sim_pionRight
              pradZone = sim_pradRight
#else
              presZone = sim_pOut
#endif              
              
              rhoZone = sim_rhoOut
              velxZone = 0.
              velyZone = 0.
              velzZone = 0.

#ifdef SIMULATION_TWO_MATERIALS
              mfrac(LEFT_SPEC - SPECIES_BEGIN+1) = 0.0
              mfrac(RGHT_SPEC - SPECIES_BEGIN+1) = 1.0
#endif
              
           endif

           !yu

#ifdef FLASH_3T
           presZone = peleZone + pionZone + pradZone
#endif

           axis(IAXIS) = i
           axis(JAXIS) = j
           axis(KAXIS) = k

           !put in default mass fraction values of all species
           if (NSPECIES > 0) then
              call Grid_putPointData(blockID, CENTER, SPECIES_BEGIN, EXTERIOR, &
                   axis, 1.0e0-(NSPECIES-1)*sim_smallX)


              !if there is only 1 species, this loop will not execute
              do n = SPECIES_BEGIN+1,SPECIES_END
                 call Grid_putPointData(blockID, CENTER, n, EXTERIOR, &
                      axis, sim_smallX)
              enddo
           end if

           ! Compute the gas energy and set the gamma-values needed for the equation of 
           ! state.
           ekinZone = 0.5 * (velxZone**2 + & 
                velyZone**2 + & 
                velzZone**2)
           
#ifdef SIMULATION_TWO_MATERIALS
           eosData(EOS_DENS) = rhoZone
           eosData(EOS_PRES) = presZone
           eosData(EOS_TEMP) = 1.0e8
           call Eos(MODE_DENS_PRES, 1, eosData, mfrac)
           eintZone = eosData(EOS_EINT)
           gameZone = 1.0+eosData(EOS_PRES)/eosData(EOS_DENS)/eosData(EOS_EINT)
           gamcZone = eosData(EOS_GAMC)
#else
           eintZone = presZone / (sim_gamma-1.)
           eintZone = eintZone / rhoZone
           gameZone = sim_gamma
           gamcZone = sim_gamma
#endif
           enerZone = eintZone + ekinZone
           enerZone = max(enerZone, sim_smallP)

           ! store the variables in the current zone via Grid put methods
           ! data is put stored one cell at a time with these calls to Grid_putData           


           call Grid_putPointData(blockId, CENTER, DENS_VAR, EXTERIOR, axis, rhoZone)
           call Grid_putPointData(blockId, CENTER, PRES_VAR, EXTERIOR, axis, presZone)
           call Grid_putPointData(blockId, CENTER, VELX_VAR, EXTERIOR, axis, velxZone)
           call Grid_putPointData(blockId, CENTER, VELY_VAR, EXTERIOR, axis, velyZone)
           call Grid_putPointData(blockId, CENTER, VELZ_VAR, EXTERIOR, axis, velzZone)

#ifdef ENER_VAR
           call Grid_putPointData(blockId, CENTER, ENER_VAR, EXTERIOR, axis, enerZone)   
#endif
#ifdef EINT_VAR
           call Grid_putPointData(blockId, CENTER, EINT_VAR, EXTERIOR, axis, eintZone)   
#endif
#ifdef GAME_VAR          
           call Grid_putPointData(blockId, CENTER, GAME_VAR, EXTERIOR, axis, gameZone)
#endif
#ifdef GAMC_VAR
           call Grid_putPointData(blockId, CENTER, GAMC_VAR, EXTERIOR, axis, gamcZone)
#endif
#ifdef TEMP_VAR
# ifdef SIMULATION_TWO_MATERIALS
           call Grid_putPointData(blockId, CENTER, TEMP_VAR, EXTERIOR, axis, eosData(EOS_TEMP))
# else
           call Grid_putPointData(blockId, CENTER, TEMP_VAR, EXTERIOR, axis, 1.e-10)
# endif
#endif

#ifdef SIMULATION_TWO_MATERIALS
           call Grid_putPointData(blockID, CENTER, LEFT_SPEC, EXTERIOR, &
                   axis, mfrac(LEFT_SPEC-SPECIES_BEGIN+1) )
           call Grid_putPointData(blockID, CENTER, RGHT_SPEC, EXTERIOR, &
                   axis, mfrac(RGHT_SPEC-SPECIES_BEGIN+1) )
#endif

#ifdef FLASH_3T
           ! We must now compute the internal energy from the pressure
           ! for the ions, electrons, and radiation field:
           
           ! Electrons...
           eeleZone = peleZone / (sim_gammaEle - 1.0) / rhoZone
           eionZone = pionZone / (sim_gammaIon - 1.0) / rhoZone
           eradZone = 3.0 * pradZone / rhoZone
           
           call Grid_putPointData(blockId, CENTER, EELE_VAR, EXTERIOR, axis, eeleZone)
           call Grid_putPointData(blockId, CENTER, EION_VAR, EXTERIOR, axis, eionZone)
           call Grid_putPointData(blockId, CENTER, ERAD_VAR, EXTERIOR, axis, eradZone)
#ifdef DFCF_VAR
           call Grid_putPointData(blockId, CENTER, DFCF_VAR, EXTERIOR, axis, eintZone)
#endif
           eintZone = eeleZone + eionZone + eradZone !recompute
           enerZone = eintZone + ekinZone
           enerZone = max(enerZone, sim_smallP/rhoZone)
#ifdef ENER_VAR
           call Grid_putPointData(blockId, CENTER, ENER_VAR, EXTERIOR, axis, enerZone)   
#endif
#ifdef EINT_VAR
           call Grid_putPointData(blockId, CENTER, EINT_VAR, EXTERIOR, axis, eintZone)   
#endif
#ifdef GAME_VAR
           call Grid_putPointData(blockId, CENTER, GAME_VAR, EXTERIOR, axis, presZone/(rhoZone*eintZone)+1.0)
#endif
#ifdef PION_VAR
           call Grid_putPointData(blockId, CENTER, PION_VAR, EXTERIOR, axis, pionZone)   
#endif
#ifdef PELE_VAR
           call Grid_putPointData(blockId, CENTER, PELE_VAR, EXTERIOR, axis, peleZone)   
#endif
#ifdef PRAD_VAR
           call Grid_putPointData(blockId, CENTER, PRAD_VAR, EXTERIOR, axis, pradZone)   
#endif
#endif
        enddo
     enddo
  enddo

! #ifdef EELE_VAR
!   call Eos_wrapped(MODE_DENS_EI_SCATTER,blkLimits,blockId)
! #endif

!   do k = blkLimits(LOW,KAXIS),blkLimits(HIGH,KAXIS)
!      do j = blkLimits(LOW,JAXIS),blkLimits(HIGH,JAXIS)
!         do i = blkLimits(LOW,IAXIS),blkLimits(HIGH,IAXIS)
!            axis(IAXIS) = i
!            axis(JAXIS) = j
!            axis(KAXIS) = k
! #ifdef ERAD_VAR
!            call Grid_putPointData(blockId, CENTER, ERAD_VAR, EXTERIOR, axis, 0.0  )   
! #endif
! #ifdef E3_VAR
!            call Grid_putPointData(blockId, CENTER, E3_VAR,   EXTERIOR, axis, 0.0  )   
! #endif

! #ifdef PRAD_VAR
!            call Grid_putPointData(blockId, CENTER, PRAD_VAR, EXTERIOR, axis, 0.0  )   
! #endif
! #ifdef TRAD_VAR
!            call Grid_putPointData(blockId, CENTER, TRAD_VAR, EXTERIOR, axis, 0.0  )   
! #endif
!         enddo
!      enddo
!   enddo

!! Cleanup!  Must deallocate arrays

  deallocate(xLeft)
  deallocate(xRight)
  deallocate(xCenter)
  deallocate(yCoord)
  deallocate(zCoord)

 
  return
end subroutine Simulation_initBlock
