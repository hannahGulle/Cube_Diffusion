// Hannah Gulle
// CSC 330 Project 2 "Simplified 3D Diffusion Model"

package main

import (
	"fmt"
        "testing"
	)

func main(){

	// TO CHANGE NUMBER OF CUBE DIVISIONS
	const maxSize int = 25

	// Determines the existence of the partition
	// Defaults to false (NO Partition)
	var withPartition bool = false

	fmt.Println("Current number of Cube Divisions: ", maxSize)
	fmt.Println("To change the Number of Cube Divisions,")
	fmt.Println("change the constant variable 'maxSize' at the top of the source code.")
	fmt.Println("Then, run again.")

	// Request the Partition Existence from the Keyboard
	fmt.Print("With Partition? Input 1 or 0 where Yes(1) and No(0).")
	intPart := -1
	fmt.Scanln(&intPart)
	fmt.Println(&intPart)

	// No Partition if value is anything but '1'
	if intPart == 1 {
		withPartition = true
	}

	var mid int = (maxSize/2)-1					// Mid cube of one side dimension
	var flag float64 = -5.0e0					// Arbitrary Value of a partition cube
	var cube [maxSize][maxSize][maxSize]float64			// 3D Cube Array
	var diffusionCoef float64 = 0.175				
	var roomDim float64 = 5.0					// Single Side Dimension of the Cube in Meters
	var gasSpeed float64 = 250.0					// Speed of the gas particles in Meters/Second
	var tStep float64 = (roomDim / gasSpeed) / float64(maxSize)	// Increase of time (seconds) for every "round" of diffusion
	var blockDist float64 = roomDim / float64(maxSize)		// Distance between blocks along one side of the cube given 
										// maxSize divisions in Meters
	var dTerm float64 = diffusionCoef * tStep / (blockDist * blockDist)	// Diffusion (Differential) term between Adjacent cubes
	var time float64 = 0.0							// Total simulated time in Seconds
	var ratio float64 = 0.0							// Ratio of maximum concentration to minimum concentration cubes
	
	// Zero the Array and Set the Partition Flags
	for i := 0; i < maxSize; i++ {
		for j := 0; j < maxSize; j++ {
			for k := 0; k < maxSize; k++ {
				if ( (i == mid) && (j > (mid-1)) && withPartition){
					cube[i][j][k] = flag
				} else{
					cube[i][j][k] = 0.0
				}
			}
		}
	}

	// Initialize the Particle Concentration in the top left corner of the cube
	cube[0][0][0] = 1.0e21

	timer := testing.Benchmark(func(b *testing.B){

		// Diffusion Process Begins
		for ratio < 0.99 {
			for i := 0; i < maxSize; i++ {
				for j := 0; j < maxSize; j++ {
					for k := 0; k < maxSize; k++ {
						// No Diffusion through partition cubes
						if cube[i][j][k] != flag {
							// Diffuse to adjacent cube one ahead of the k dimension value
							if( (k+1 < maxSize) && cube[i][j][k+1] != flag){
								var change float64 = (cube[i][j][k] - cube[i][j][(k+1)]) * dTerm
								cube[i][j][k] = cube[i][j][k] - change
								cube[i][j][(k+1)] = cube[i][j][(k+1)] + change
							}
							// Diffuse to adjacent cube one behind the k dimension value
							if( (k-1 > -1) && cube[i][j][(k-1)] != flag){
								var change float64 = ( cube[i][j][k] - cube[i][j][(k-1)]) * dTerm
								cube[i][j][k] = cube[i][j][k] - change
								cube[i][j][(k-1)] = cube[i][j][(k-1)] + change
							}
							// Diffuse to adjacent cube one ahead of the j dimension value
							if( (j+1 < maxSize) && cube[i][(j+1)][k] != flag){
								var change float64 = ( cube[i][j][k] - cube[i][(j+1)][k]) * dTerm
								cube[i][j][k] = cube[i][j][k] - change
								cube[i][(j+1)][k] = cube[i][(j+1)][k] + change
							}
							// Diffuse to adjacent cube one behind the j dimension value
							if( (j-1 > -1) && cube[i][(j-1)][k] != flag){
								var change float64 = ( cube[i][j][k] - cube[i][(j-1)][k]) * dTerm
								cube[i][j][k] = cube[i][j][k] - change
								cube[i][(j-1)][k] = cube[i][(j-1)][k] + change
							}	
							// Diffuse to adjacent cube one ahead of the i dimension value
							if( (i+1 < maxSize) && cube[(i+1)][j][k] != flag){
								var change float64 = ( cube[i][j][k] - cube[(i+1)][j][k]) * dTerm
								cube[i][j][k] = cube[i][j][k] - change
								cube[(i+1)][j][k] = cube[(i+1)][j][k] + change
							}
							// Diffuse to adjacent cube one behind the i dimension value
							if( (i-1 > -1) && cube[(i-1)][j][k] != flag){
								var change float64 = ( cube[i][j][k] - cube[(i-1)][j][k]) * dTerm
								cube[i][j][k] = cube[i][j][k] - change
								cube[(i-1)][j][k] = cube[(i-1)][j][k] + change
							}
						}
					}
				}
			}	
			// Increase the simulated time by one time step (one diffusion "round" has passed)
			time = time + tStep
	
			var sum float64 = 0.0			// Reset the Total Particle Sum value
			var max float64 = cube[0][0][0]		// Arbitrarily set maximum concentration value
			var min float64 = cube[0][0][0]		// Arbitrarily set minimum concentration value

			// CHECK CONSERVATION OF MASS
			// And find the minimum and maximum concentration values (not including partition cubes)
			for r := 0; r < maxSize; r++ {
				for s := 0; s < maxSize; s++ {
					for t := 0; t < maxSize; t++ {
						if cube[r][s][t] != flag {
							if cube[r][s][t] > max {
								max = cube[r][s][t]
							}
							if cube[r][s][t] < min {
								min = cube[r][s][t]
							}
							sum = sum + cube[r][s][t]
						}
					}
				}
			}

			// Update the minimum:maximum concentration value
			ratio = min / max

			fmt.Printf("%f  %f   %f   %f  %f  %f  %f \n", time, ratio, min, max, cube[0][0][0], cube[(maxSize-1)][(maxSize-1)][(maxSize-1)], sum)
		} // End Diffusion Process
		fmt.Printf("Box equilibrated in %f seconds of simulated time\n", time)
	}) // End Timer Benchmark
	fmt.Printf("And %12.4f seconds of runtime\n", float64(timer.T.Seconds())/float64(timer.N))
}


