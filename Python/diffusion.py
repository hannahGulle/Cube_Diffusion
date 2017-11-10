#!/usr/bin/python
import sys, timeit
# Hannah Gulle
# Project 2 CSC 330 "Simplified 3D Diffusion Process"
# checked for consistency on 10/21/17

def main():

	# Request the Number of Cube Divisions	
	maxSize = input("Enter the Number of Divisions: ")
	withPartition = input ("Enter the Existence of the Partition (1/0): ")
	# Middle Index of a Single Side Dimension According to Number of Cube Divisions
	mid = (maxSize / 2) - 1

	# Set All Cubes to 0.0
	cube = [[[0.0 for k in range(maxSize)] for j in range(maxSize)] for i in range(maxSize)]
	
	# Set Partition if the Partition Exists
	flag = -5.0e0 # to the Arbitrary Flag Value
	if (withPartition == 1):
		for i in range (0, maxSize):
			for j in range (0, maxSize):
				for k in range (0, maxSize):
					if ( (i==mid) and (j > mid-1) ):
						cube[i][j][k] = flag
	diffusionCoef = 0.175			# Constant Value
	roomDim = 5.				# Single Side Dimension in Meters
	gasSpeed = 250.0			# Speed of Molecues in Meters/Second
	tStep = (roomDim / gasSpeed) / maxSize	# Time Addition for each "Round" of Diffusion
	blockDist = roomDim / maxSize		# Distance between Adjacent Blocks in Meters
	# Diffusion/Differential Term for Adjacent Cubes
	dTerm = diffusionCoef * tStep / (blockDist * blockDist)
	
	# Wrapper Function for Run Time Purposes
	wrappedDiffusion = wrapper(diffusion, cube, maxSize, dTerm, flag, tStep)
	print "And ", timeit.timeit(wrappedDiffusion, number = 1), " seconds of Wall time"
	

def wrapper(func, *args, **kwargs):
	def wrapped():
		return func(*args, **kwargs)
	return wrapped

# Diffusion Process Occurs Across Non-partition Adjacent Cubes
def diffusion(cube, maxSize, dTerm, flag, tStep):
	# Initial Concentration in the Top Left Corner of the Cube
	cube[0][0][0] = 1.0e21
	time = 0.0
	ratio = 0.0

	# Until the Cube is 99% Diffused, Continue the Diffusion Process
	while (ratio < 0.99):
		for i in range (0, maxSize):
			for j in range (0, maxSize):
				for k in range (0, maxSize):
					if( cube[i][j][k] != flag):
						# Diffuse Across Adjacent Cubes One Ahead on the k axis
						if( k+1 < maxSize and (cube[i][j][k+1] != flag)):
							change = (cube[i][j][k] - cube[i][j][k+1]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i][j][k+1] = cube[i][j][k+1] + change
						# Diffuse Across Adjacent Cubes One Behind on the k axis
						if( k-1 > -1 and (cube[i][j][k-1] != flag)):
							change = (cube[i][j][k] - cube[i][j][k-1]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i][j][k-1] = cube[i][j][k-1] + change
						# Diffuse Across Adjacent Cubes One Ahead on the j axis
						if( j+1 < maxSize and (cube[i][j+1][k] != flag)):
							change = (cube[i][j][k] - cube[i][j+1][k]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i][j+1][k] = cube[i][j+1][k] + change
						# Diffuse Across Adjacent Cubes One Behind on the j axis
						if( j-1 > -1 and (cube[i][j-1][k] != flag)):
							change = (cube[i][j][k] - cube[i][j-1][k]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i][j-1][k] = cube[i][j-1][k] + change
						# Diffuse Across Adjacent Cubes One Ahead on the i axis
						if( i+1 < maxSize and (cube[i+1][j][k] != flag)):
							change = (cube[i][j][k] - cube[i+1][j][k]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i+1][j][k] = cube[i+1][j][k] + change
						# Diffuse Across Adjacent Cubes One Behind on the i axis
						if( i-1 > -1 and (cube[i-1][j][k] != flag)):
							change = (cube[i][j][k] - cube[i-1][j][k]) * dTerm
							cube[i][j][k] = cube[i][j][k] - change
							cube[i-1][j][k] = cube[i-1][j][k] + change
		# Increase Simulated Time for Each "Round of Diffusion
		time = time + tStep
		sumValue = 0.0
		maxValue = cube[0][0][0]
		minValue = cube[0][0][0]
		# Ensure Conservation of Mass and Find Maximum and Minimum Concentration Values for the
		# Concentration Ratio
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
