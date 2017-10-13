program diffusion
use cube_mem

real*8 :: diffusionCoef, roomDim, gasSpeed, tStep, blockDist, dTerm
integer:: passes,i,j,k,l,m,n,r,s,t
real*8:: time, ratio, change, maxValue, minValue, sumValue

print *, "How big is the cube?"
read *, maxSize

! Zero the Cube
forall(i=1:maxSize, j=1:maxSize, k=1:maxSize) cube(i,j,k) = 0.0

diffusionCoef = 0.175
roomDim = 5
gasSpeed = 250.0
tStep = (roomDim / gasSpeed) / maxSize
blockDist = roomDim / maxSize

dTerm = diffusionCoef * tStep / (blockDist * blockDist)

! Initialize the First Cell
cube(0,0,0) = 1e21

passes = 0
time = 0.0
ratio = 0.0

do while (ratio < 0.99)

do i = 0, maxSize, 1
   do j = 0, maxSize, 1
      do k = 0, maxSize, 1
         do l = 0, maxSize, 1
            do m = 0, maxSize, 1
               do n = 0, maxSize, 1
                        if( ((i==l) .and. (j==m) .and. (k==n+1)) .or. &
&                          ( (i==l) .and. (j==m) .and. (k==n-1)) .or. &
&                          ( (i==l) .and. (j==m+1) .and. (k==n)) .or. &
&                          ( (i==l) .and. (j==m-1) .and. (k==n)) .or. &
&                          ( (i==l+1) .and. (j==m) .and. (k==n)) .or. &
&                          ( (i==l-1) .and. (j==m) .and. (k==n)) ) then
                        
                            change = (cube(i,j,k) - cube(l,m,n))*dTerm
                            cube(i,j,k) = cube(i,j,k) - change
                            cube(l,m,n) = cube(l,m,n) + change
                        end if
end do 
 end do
   end do
     end do
      end do
       end do ! Diffusion Check Loops i,j,k,l,m,n
        
time = time + tStep

! Check for Conservation of Mass
sumValue = 0.0
maxValue = cube(0,0,0)
minValue = cube(0,0,0)

do r = 0, maxSize, 1
        do s = 0, maxSize, 1
                do t = 0, maxSize, 1
                        if(cube(r,s,t) > maxValue) then
                                maxValue = cube(r,s,t)
                        end if

                        if(cube(r,s,t) < minValue) then
                                minValue = cube(r,s,t)
                        end if
        
                        sumValue = sumValue + cube(r,s,t)
end do
 end do
  end do ! Max and Min Loops r,s,t

ratio = minValue/maxValue

write (*,10)time,ratio,cube(0,0,0),cube(maxSize-1,maxSize-1,maxSize-1),sumValue
10 format (d10.0, d10.10, d20.10, d20.10,d10.0)

end do ! Do While Loop

write (*,20) "Box equilibrated in ", time, " seconds of simulated time"
20 format(d10.0)

end program diffusion
