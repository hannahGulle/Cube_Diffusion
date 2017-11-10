#!/usr/bin/python
import sys, timeit
# checked for consistency on 10/21/17

def main():
	
	maxSize = input("Enter the Number of Divisions: ")
	withPartition = input ("Enter the Existence of the Partition (1/0): ")
	mid = (maxSize / 2) - 1
	cube = [[[0.0 for k in range(maxSize)] for j in range(maxSize)] for i in range(maxSize)]
	
	# Zero Out Array and Set Partition
	flag = -5.0e0
	for i in range (0, maxSize):
		for j in range (0, maxSize):
			for k in range (0, maxSize):
				if ( (i==mid) and (j > mid-1) and (withPartition == 1)):
					cube[i][j][k] = flag
	diffusionCoef = 0.175
	roomDim = 5.
	gasSpeed = 250.0
	tStep = (roomDim / gasSpeed) / maxSize
	blockDist = roomDim / maxSize
	dTerm = diffusionCoef * tStep / (blockDist * blockDist)
	
	wrappedDiffusion = wrapper(diffusion, cube, maxSize, dTerm, flag, tStep)
	print "And ", timeit.timeit(wrappedDiffusion, number = 1), " seconds of Wall time"
	

def wrapper(func, *args, **kwargs):
	def wrapped():
		return func(*args, **kwargs)
	return wrapped


def diffusion(cube, maxSize, dTerm, flag, tStep):

	cube[0][0][0] = 1.0e21
	time = 0.0
	ratio = 0.0

	while (ratio < 0.99):
		for i in range (0, maxSize):
			for j in range (0, maxSize):
				for k in range (0, maxSize):
					if( cube[i][j][k] != flag):
						if( k+1 < maxSize and (cube[i][j][k+1] != flag)):
							change = (cube[i][j][k] - cube[i][j][k+1]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i][j][k+1] = cube[i][j][k+1] + change
						if( k-1 > -1 and (cube[i][j][k-1] != flag)):
							change = (cube[i][j][k] - cube[i][j][k-1]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i][j][k-1] = cube[i][j][k-1] + change
						if( j+1 < maxSize and (cube[i][j+1][k] != flag)):
							change = (cube[i][j][k] - cube[i][j+1][k]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i][j+1][k] = cube[i][j+1][k] + change
						if( j-1 > -1 and (cube[i][j-1][k] != flag)):
							change = (cube[i][j][k] - cube[i][j-1][k]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i][j-1][k] = cube[i][j-1][k] + change
						if( i+1 < maxSize and (cube[i+1][j][k] != flag)):
							change = (cube[i][j][k] - cube[i+1][j][k]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i+1][j][k] = cube[i+1][j][k] + change
						if( i-1 > -1 and (cube[i-1][j][k] != flag)):
							change = (cube[i][j][k] - cube[i-1][j][k]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i-1][j][k] = cube[i-1][j][k] + change
		time = time + tStep
		sumValue = 0.0
		maxValue = cube[0][0][0]
		minValue = cube[0][0][0]
		for i in range (0, maxSize):
			for j in range (0, maxSize):
				for k in range (0, maxSize):
					if( cube[i][j][k] != flag):
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


main()
