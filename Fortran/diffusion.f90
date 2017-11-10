! Hannah Gulle
! Project 2 CSC 330 "Simplified 3D Diffusion Model"
! Calculates the Simulated Time in Seconds for 1e21
! Particles in the Top Left Corner of a Rank 3 Array
! 'Cube' to Diffuse through 99% of the Cube's Entirety
! Given the Single Side Dimension of the cube, 'maxSize'.

program diffusion
! Includes Rank 3 Array Named 'cube'
! and Integer 'maxSize' (Size of Rank 3 Array)
USE cube_mem

real*8::flag            ! Arbitrary Value for Partition Cubes
real*8::time            ! Total Simulated Time in Seconds
integer::mem_stat       ! Cube Memory Error Status
integer::withPartition  ! Integer boolean (1/0) for the Existence of the
                                !Partition

! For Run Time Purposes
integer(kind=8)::start,finish,rate

interface
! Set All Cube Indices to 0.0 or the Flag Value if the Partition
! Exists
subroutine fill_cube(flag, withPartition)
        integer::withPartition
        real*8::flag
        end subroutine fill_cube

! Diffusion Through the Rank 3 Cube Array
subroutine diffuse_cube(flag, time)
        real*8::time
        real*8::flag
        end subroutine diffuse_cube
end interface

! Request the Rank 3 Cube Array Size from the Keyboard
print *, "How big is the cube?"
read *, maxSize

! Request the Existence of the Partition from the Keyboard
print *, "With a Partition? Yes(1) or No(0)"
read *, withPartition

! Defaults to False(0) if the Input is Anything Other than 1
if (withPartition .ne. 1) then
        withPartition = 0
else
        withPartition = 1
endif

flag = -5.d0    ! Flag Set to Arbitrary Double

call fill_cube(flag, withPartition)

! System_Clock Used to Compute the Wall Time of the Diffusion Function
call system_clock(count_rate=rate)
call system_clock(start)
call diffuse_cube(flag, time)
call system_clock(finish)

print *, "And ", float(finish-start)/rate, " seconds of Wall Time"

end program diffusion



! Diffusion of the Rank 3 Array Cube
! Initial Particle Concentration in the Top Left Corner of the Cube
! Diffusion Only Occurs Across Adjacent Cubes on the x, y, or z axis
subroutine diffuse_cube(flag, time)
        USE cube_mem
        
        ! Diffusion Process Variables
        real*8 :: diffusionCoef, roomDim, gasSpeed, tStep, blockDist, dTerm
        integer:: i,j,k,l,m,n,r,s,t, mem_stat
        real*8:: time, ratio, change, maxValue, minValue, sumValue, flag

        diffusionCoef = 0.175           ! Constant Value
        roomDim = 5.0                   ! Single Side Dimension in Meters
        gasSpeed = 250.0                ! Particle Speed in Meters/Second
        tStep = (roomDim / gasSpeed) / maxSize  ! Time Addition for each
                                        ! "round" of Diffusion
        blockDist = roomDim / maxSize   ! Distance between Adjacent Blocks
                                                ! in Meters
        ! Diffusion Term or the Differential Between Adjacent Blocks
        dTerm = diffusionCoef * tStep / (blockDist * blockDist)

        ! Initialize the First Cell
        cube(1,1,1) = 1e21

        ! Initial Simulated Time and Concentration Ratio is Zero
        time = 0.0
        ratio = 0.0

! Until 99% of the Cube is Diffused, Continue the Diffusion Process.
do while (ratio < 0.99)

        do i = 1, maxSize, 1
        do j = 1, maxSize, 1
        do k = 1, maxSize, 1
        if( cube(i,j,k) /= flag) then

        ! Diffuse Across Adjacent Cubes One Ahead on the k axis
        if( k+1 < maxSize .and. cube(i,j,k+1) /= flag) then
        change = (cube(i,j,k) - cube(i,j,k+1))*dTerm
        cube(i,j,k) = cube(i,j,k) - change
        cube(i,j,k+1) = cube(i,j,k+1) + change
        endif

        ! Diffuse Across Adjacent Cubes One Behind on the k axis
        if( k-1 > 0 .and. cube(i,j,k-1) /= flag) then
        change = (cube(i,j,k) - cube(i,j,k-1))*dTerm
        cube(i,j,k) = cube(i,j,k) - change
        cube(i,j,k-1) = cube(i,j,k-1) + change
        endif
        
        ! Diffuse Across Adjacent Cubes One Ahead on the j axis
        if( j+1 < maxSize .and. cube(i,j+1,k) /= flag) then
        change = (cube(i,j,k) - cube(i,j+1,k))*dTerm
        cube(i,j,k) = cube(i,j,k) - change
        cube(i,j+1,k) = cube(i,j+1,k) + change
        endif

        ! Diffuse Across Adjacent Cubes One Behind on the j axis
        if( j-1 > 0 .and. cube(i,j-1,k) /= flag) then
        change = (cube(i,j,k) - cube(i,j-1,k))*dTerm
        cube(i,j,k) = cube(i,j,k) - change
        cube(i,j-1,k) = cube(i,j-1,k) + change
        endif

        ! Diffuse Across Adjacent Cubes One Ahead on the i axis
        if( i+1 < maxSize .and. cube(i+1,j,k) /= flag) then
        change = (cube(i,j,k) - cube(i+1,j,k))*dTerm
        cube(i,j,k) = cube(i,j,k) - change
        cube(i+1,j,k) = cube(i+1,j,k) + change
        endif

        ! Diffuse Across Adjacent Cubes One Behind on the i axis
        if( i-1 > 0 .and. cube(i-1,j,k) /= flag) then           
        change = (cube(i,j,k) - cube(i-1,j,k))*dTerm
        cube(i,j,k) = cube(i,j,k) - change
        cube(i-1,j,k) = cube(i-1,j,k) + change
        end if
        endif
        enddo
        enddo
        enddo
        ! Increase Total Simulated Time for each "Round" of Diffusion
        time = time + tStep

        ! Check for Conservation of Mass
        sumValue = sum(cube)
        maxValue = cube(1,1,1)
        minValue = cube(1,1,1)

        do r = 1, maxSize, 1
        do s = 1, maxSize, 1
        do t = 1, maxSize, 1
        if( cube(r,s,t) /= flag) then
                if(cube(r,s,t) > maxValue) then
                        maxValue = cube(r,s,t)
                end if
                if(cube(r,s,t) < minValue) then
                        minValue = cube(r,s,t)
                end if
        end if
        enddo
        enddo
        enddo ! Max and Min Loops r,s,t

        ! Ratio of Lowest to Highest Concentration Cubes in the Rank3 Array
        ratio = minValue/maxValue

        print *, time, ratio, cube(1,1,1), cube(maxSize-1,maxSize-1,maxSize-1), sumValue

        end do ! Do While Loop

        print *, "Box equilibrated in ", time, " seconds of simulated time"

deallocate(cube, stat=mem_stat)
        if(mem_stat /= 0) STOP "Error Deallocating Array"

end subroutine diffuse_cube



! Set All Cube Divisions to 0.0 or Flag if the Partition Exists
subroutine fill_cube(flag, withPartition)
        USE cube_mem
        real*8::flag
        integer::mid 
        integer::withPartition

        ! Middle Index of a Single Side Dimension of the Cube
        mid = (maxSize / 2)

        allocate(cube(maxSize,maxSize,maxSize),STAT=mem_stat)
        if(mem_stat /= 0) STOP "Memory Allocation Error"

        ! Zero the Cube and Set the Partition
        do 1 l = 1, maxSize, 1
        do 2 m = 1, maxSize, 1
        do 3 n = 1, maxSize, 1
        if( (l==mid) .and. (m > mid-1)) then
                if( withPartition .eq. 1 ) then
                        cube(l,m,n) = flag
                end if
        else
                cube(l,m,n) = 0.0
        endif
        3 continue
        2 continue
        1 continue

end subroutine fill_cube
