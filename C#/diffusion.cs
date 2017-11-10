// Hannah Gulle
// Submitted for: CSC 330 - Project "Simplified 3D Diffusion Model"

using System;
using System.Diagnostics;
using System.Linq;
using System.Threading;

public class Diffusion {
	static public void Main () {

		int intPartition;		// Initial Partition Value Input Type
		bool withPartition = false;	// Partition Existence Value
		string strmaxSize;		// Initial Cube Division Input Type
		int maxSize;			// Cube Divisions

		// Request the Number of Cube Divisions from the Keyboard
		Console.WriteLine("Input Number of Cube Divisions: ");
		strmaxSize = Console.ReadLine();
		Int32.TryParse(strmaxSize, out maxSize);

		// Request the Existence of the Partition from the Keyboard
		Console.WriteLine("Is There a Partition? 1/0 ");
		intPartition = Console.Read();

		// Convert Keyboard Partition Value Type from Int to Boolean
		if(intPartition == 1){
			withPartition = true;
		}

		int mid = (maxSize / 2) - 1;	// Midpoint of Single Side

		// Create 3D Diffusion Model
		double[,,] cube = new double[maxSize, maxSize, maxSize];
		double flag = -5.0d;	// Arbitrary Value of Partition Cubes
		Stopwatch wallClock = new Stopwatch();	// Runtime Value Calculator

		// Zero the Array and Set Partition Flags
		for(int i = 0; i < maxSize; i++){
			for(int j = 0; j < maxSize; j++){
				for(int k = 0; k < maxSize; k++){
					if( (i==mid) && (j > mid-1) && withPartition){
						cube[i,j,k] = flag;
					}
					else{
						cube[i,j,k] = 0.0;
					}
				}
			}
		}

		double diffusionCoef = .175;
		double roomDim = 5.0;				// meters
		double gasSpeed = 250.0;			// meters/second
		double tStep = (roomDim / gasSpeed) / maxSize;	// seconds
		double blockDist = roomDim / (double)maxSize;	// meters

		double dTerm = diffusionCoef * tStep / (blockDist * blockDist);

		// Initialize the First Cell
		cube[0,0,0] = 1e21;

		double time = 0.0;	// Simulated Time Variable
		double ratio = 0.0;	// Maximum Concentration to Minimum Concentration Ratio Variable
		double change;		// Particle Difference between Adjacent Cubes

		wallClock.Start();
		// Diffusion Process Begins
		do{
			for(int i = 0; i < maxSize; i++){
				for(int j = 0; j < maxSize; j++){
					for(int k = 0; k < maxSize; k++){
						// Particles cannot diffuse across partitioned/flagged cubes
						if( cube[i,j,k] != flag){
							// k+1 ; One cube ahead on the z-axis
							if( (k+1 < maxSize) && (cube[i,j,k+1] != flag)){
								change = (cube[i,j,k] - cube[i,j,k+1]) * dTerm;
								cube[i,j,k] = cube[i,j,k] - change;
								cube[i,j,k+1] = cube[i,j,k+1] + change;
							}
							// k-1 ; One cube behind on the z-axis
							if( (k-1 > -1) && (cube[i,j,k-1] != flag)){
								change = (cube[i,j,k] - cube[i,j,k-1]) * dTerm;
								cube[i,j,k] = cube[i,j,k] - change;
								cube[i,j,k-1] = cube[i,j,k-1] + change;
							}
							// j+1 ; One cube ahead on the y-axis
							if( (j+1 < maxSize) && (cube[i,j+1,k] != flag)){
								change = (cube[i,j,k] - cube[i,j+1,k]) * dTerm;
								cube[i,j,k] = cube[i,j,k] - change;
								cube[i,j+1,k] = cube[i,j+1,k] + change;
							}
							// j-1 ; One cube behind on the y-axis
							if( (j-1 > -1) && (cube[i,j-1,k] != flag)){
								change = (cube[i,j,k] - cube[i,j-1,k]) * dTerm;
								cube[i,j,k] = cube[i,j,k] - change;
								cube[i,j-1,k] = cube[i,j-1,k] + change;
							}
							// i+1 ; One cube ahead on the x-axis
							if( (i+1 < maxSize) && (cube[i+1,j,k] != flag)){
								change = (cube[i,j,k] - cube[i+1,j,k]) * dTerm;
								cube[i,j,k] = cube[i,j,k] - change;
								cube[i+1,j,k] = cube[i+1,j,k] + change;
							}
							// i-1 ; One cube behind on the x-axis
							if( (i-1 > -1) && (cube[i-1,j,k] != flag)){
								change = (cube[i,j,k] - cube[i-1,j,k]) * dTerm;
								cube[i,j,k] = cube[i,j,k] - change;
								cube[i-1,j,k] = cube[i-1,j,k] + change;
							}
						} 
					}
				}
			}
			// For each loop, add one time step to the total simulated time
			time = time + tStep;

			// Check for Conservation of Mass
			double sum = 0.0;
			double max = cube[0,0,0];	// Arbitrary initial max that isn't flagged
			double min = cube[0,0,0];	// Arbitrary initial min that isn't flagged
			
			for(int i = 0; i < maxSize; i++){
				for(int j = 0; j < maxSize; j++){
					for(int k = 0; k < maxSize; k++){
						// Conservation of Matter check skips partition values
						if( cube[i,j,k] != flag){	
							if(cube[i,j,k] > max){
								max = cube[i,j,k];
							}
							if(cube[i,j,k] < min){
								min = cube[i,j,k];
							}
							sum += cube[i,j,k];
						}
					}
				}
			}

			ratio = min / max;

			Console.WriteLine(time + "\t" + ratio + "\t" + cube[0,0,0] + "\t" + cube[maxSize-1,maxSize-1,maxSize-1] + "\t" + sum);

		} while(ratio < 0.99);	// Diffusion ends when most (> 0.99) of the room is filled
					// evenly with the initial mass of particles

		Console.WriteLine("\nBox equilibriated in " + time + " seconds of simulated time.");
		wallClock.Stop();
		Console.WriteLine("And {0} seconds of Run Time", (wallClock.Elapsed.TotalMilliseconds / 1000));
	}
}
