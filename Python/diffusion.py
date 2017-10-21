#!#/usr/bin/python

# checked for consistency on 10/21/17

maxSize = 10

# Zero Out Array
cube = [[[0.0 for k in range(maxSize)] for j in range(maxSize)] for i in range(maxSize)]

diffusionCoef = 0.175
roomDim = 5.
gasSpeed = 250.0
tStep = (roomDim / gasSpeed) / maxSize
blockDist = roomDim / maxSize

dTerm = diffusionCoef * tStep / (blockDist * blockDist)

cube[0][0][0] = 1.0e21

#pass = 0
time = 0.0
ratio = 0.0

while (ratio < 0.99):
	
	for i in range (0, maxSize):
		for j in range (0, maxSize):
			for k in range (0, maxSize):
				for l in range (0, maxSize):
					for m in range (0, maxSize):
						for n in range (0, maxSize):

							if( ((i==l) and (j==m) and (k==n+1)) or
								((i==l) and (j==m) and (k==n-1)) or
								((i==l) and (j==m+1) and (k==n)) or
								((i==l) and (j==m-1) and (k==n)) or
								((i==l+1) and (j==m) and (k==n)) or
								((i==l-1) and (j==m) and (k==n)) ):

									change = (cube[i][j][k] - cube[l][m][n]) * dTerm
									cube[i][j][k] = cube[i][j][k] - change
									cube[l][m][n] = cube[l][m][n] + change
	time = time + tStep

	sumValue = 0.0
	maxValue = cube[0][0][0]
	minValue = cube[0][0][0]

	for i in range (0, maxSize):
		for j in range (0, maxSize):
			for k in range (0, maxSize):
	
				if(cube[i][j][k] > maxValue):
					maxValue = cube[i][j][k]
				if(cube[i][j][k] < minValue):
					minValue = cube[i][j][k]

				sumValue = sumValue + cube[i][j][k]	

	ratio = minValue / maxValue

	print time, " ", ratio, " ", cube[0][0][0], " ", cube[maxSize-1][maxSize-1][maxSize-1], " ", sumValue

	if(ratio > 0.99):
		break

print "Box equilibrated in ", time, " seconds of simulated time."
