// Hannah Gulle
// Submitted for: CSC 330 - Project "Simplified 3D Diffusion Model"
// This program takes a set cube division size and a boolean to determine
// the simulated time it would take to diffused 1e21 particles through a
// 5 meter by 5 meter room with and without a partition

#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>
#include<time.h>

// Determines the Wall Time Necessary for the Diffusion Process
extern double wallTime();
int main(){

	int intPartition;		// Intial Parition Existence User Input Value
	bool withPartition = false;	// Determines if the partition is added to the cube
	int maxSize; 			// Number of divisions in 3D Array Cube
	double flag = -5.0;		// Flagged Partition Value; number of particles cannot
						// be negative, and does not coincide with out
						// of bounds value (-1)

	// Request the Number of Divisions from the Keyboard
	printf("How many Divisions?\n");
	scanf("%i", &maxSize);
	int mid = ((int)maxSize / 2) - 1;	// Midpoint of one side of the 3D Array Cube
	
	// Request the Existence of the Partition from the Keyboard as an Integer
	printf("With a Partition? 1/0\n");
	scanf("%i", &intPartition);

	// Convert to Boolean Value if Necessary
	if(intPartition == 1){
		withPartition = true;
	}


	// Alloc 3D Array Cube
	// DYNAMICALLY ALLOCATED
	double ***cube = malloc(maxSize*sizeof(double**));
	for(int i = 0; i < maxSize; i++){
		cube[i] = malloc(maxSize*sizeof(double*));
			for(int j = 0; j < maxSize; j++){
				cube[i][j] = malloc(maxSize*sizeof(double));
			}
	}

	// Zero the Array Cube and Set the Partition
	// Partition values set to flag (-5.0) which will be ignored
	// during diffusion and conservation of mass.
	for(int i = 0; i < maxSize; i++){
		for(int j = 0; j < maxSize; j++){
			for(int k = 0; k < maxSize; k++){
				// See README for partition value design graphics
				if( (i==mid) && (j > mid-1) && withPartition){
					cube[i][j][k] = flag;
				}
				else{ // Non-partition values zeroed
					cube[i][j][k] = 0.0;
				}
			}
		}
	}

	double diffusionCoef = 0.175;	
	double roomDim = 5.0;				// meters
	double gasSpeed = 250.0;			// meters/second
	double tStep = (roomDim / gasSpeed) / maxSize;	// seconds
	double blockDist = roomDim / maxSize;		// meters
	double dTerm = diffusionCoef * tStep / (blockDist * blockDist);

	// Initialize the First Cell
	cube[0][0][0] = 1e21;

	double time = 0.0;	// Simulated Time Variable
	double ratio = 0.0;	// Maximum Concentration to Minimum Concentration Ratio
	double change;		// Difference between adjacent cube divisions

	do{
		for(int i = 0; i < maxSize; i++){
			for(int j = 0; j < maxSize; j++){
				for(int k = 0; k < maxSize; k++){
					// Diffusion CANNOT occur between flagged/partitioned cubes
					if( cube[i][j][k] != flag){
						// k+1 ; Cube one ahead on the z-axis
						if( k+1 < maxSize && ( cube[i][j][k+1] != flag)){
							change = ( cube[i][j][k] - cube[i][j][k+1]) * dTerm;
							cube[i][j][k] = cube[i][j][k] - change;
							cube[i][j][k+1] = cube[i][j][k+1] + change;
						}
						// k-1 ; Cube one behind on the z-axis
						if( k-1 > -1 && ( cube[i][j][k-1] != flag)){
							change = ( cube[i][j][k] - cube[i][j][k-1]) * dTerm;
							cube[i][j][k] = cube[i][j][k] - change;
							cube[i][j][k-1] = cube[i][j][k-1] + change;
						}
						// j+1 ; Cube one ahead on the y-axis
						if( (j+1 < maxSize) && ( cube[i][j+1][k] != flag)){
							change = ( cube[i][j][k] - cube[i][j+1][k]) * dTerm;
							cube[i][j][k] = cube[i][j][k] - change;
							cube[i][j+1][k] = cube[i][j+1][k] + change;
						}
						// j-1 ; Cube one behind on the y-axis
						if( j-1 > -1 && ( cube[i][j-1][k] != flag)){
							change = ( cube[i][j][k] - cube[i][j-1][k]) * dTerm;
							cube[i][j][k] = cube[i][j][k] - change;
							cube[i][j-1][k] = cube[i][j-1][k] + change;
						}
						// i+1 ; Cube one ahead on the x-axis
						if( (i+1 < maxSize) && ( cube[i+1][j][k] != flag)){
							change = ( cube[i][j][k] - cube[i+1][j][k]) * dTerm;
							cube[i][j][k] = cube[i][j][k] - change;
							cube[i+1][j][k] = cube[i+1][j][k] + change;
						}
						// i-1 ; Cube one behind on the x-axis
						if( i-1 > -1 && ( cube[i-1][j][k] != flag)){
							change = ( cube[i][j][k] - cube[i-1][j][k]) * dTerm;
							cube[i][j][k] = cube[i][j][k] - change;
							cube[i-1][j][k] = cube[i-1][j][k] + change;
						}
					}
				}
			}
		}
		// For each loop, add a time step to the total simulated time
		time = time + tStep;

		// Check for Conservation of Mass
		double sum = 0.0;
		double min = cube[0][0][0];	// Arbitrary initial minimum value that is not a flag
		double max = cube[0][0][0];	// Arbitrary initial maximum value that is not a flag

		for(int i = 0; i < maxSize; i++){
			for(int j = 0; j < maxSize; j++){
				for(int k = 0; k < maxSize; k++){
					// Partition/flagged cubes ignored during conservation of mass checks
					if( cube[i][j][k] != flag){	
						if(cube[i][j][k] > max){
							max = cube[i][j][k];
						}
						if( cube[i][j][k] < min){
							min = cube[i][j][k];
						}
						sum = sum + cube[i][j][k];
					}
				}
			}
		}

		ratio = min / max;
		printf("%f %f %f %f %f \n", time, ratio, cube[0][0][0], cube[maxSize-1][maxSize-1][maxSize-1], sum);

	} while(ratio < 0.99);	// After 0.99, particles have diffused to most of the room.
	
	printf("Box equilibrated in %f seconds of simulated time\n", time);
	printf("And %f seconds of wall time", wallTime());
	free(cube);	// Memory Deallocated
	return 0;
}

double wallTime(){
	return (double) clock() / (double) CLOCKS_PER_SEC;
}

