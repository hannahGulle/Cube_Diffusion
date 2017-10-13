using System;

public class Diffusion {
	static public void Main () {
		const int maxSize = 10;
		double[,,] cube = new double[maxSize, maxSize, maxSize];

		// Zero the Array
		for(int i = 0; i < maxSize; i++){
			for(int j = 0; j < maxSize; j++){
				for(int k = 0; k < maxSize; k++){
					cube[i,j,k] = 0.0;
				}
			}
		}

		double diffusionCoef = .175;
		double roomDim = 5;
		double gasSpeed = 250.0;
		double tStep = (roomDim / gasSpeed) / maxSize;
		double blockDist = roomDim / maxSize;

		double dTerm = diffusionCoef * tStep / (blockDist * blockDist);

		// Initialize the First Cell
		cube[0,0,0] = 1e21;

		int pass = 0;
		double time = 0.0;
		double ratio = 0.0;

		do{
			for(int i = 0; i < maxSize; i++){
				for(int j = 0; j < maxSize; j++){
					for(int k = 0; k < maxSize; k++){
						for(int l = 0; l < maxSize; l++){
							for(int m = 0; m < maxSize; m++){
								for(int n = 0; n < maxSize; n++){
		
									if( ((i==l) && (j==m) && (k==n+1)) ||
									  ( (i==l) && (j==m) && (k==n-1)) ||
									  ( (i==l) && (j==m+1) && (k==n)) ||
									  ( (i==l) && (j==m-1) && (k==n)) ||
									  ( (i==l+1) && (j==m) && (k==n)) ||
									  ( (i==l-1) && (j==m) && (k==n))) {
	
										double change = (cube[i,j,k] - cube[l,m,n]) * dTerm;
										cube[i,j,k] = cube[i,j,k] - change;
										cube[l,m,n] = cube[l,m,n] + change;
									}
								}
							}
						}
					}
				}
			}
			time = time + tStep;

			// Check for Conservation of Mass
			double sum = 0.0;
			double max = findMax(cube, maxSize);
			double min = findMin(cube, maxSize);

			ratio = min / max;

			Console.Write(time);
			Console.Write(ratio);
			Console.Write(cube[0,0,0]);
			Console.Write(cube[maxSize-1,maxSize-1,maxSize-1]);
			Console.Write(sum);

		} while(ratio < 0.99);

		Console.WriteLine("Box equilibriated in " + time + " seconds of simulated time.");
	}

	public static double findMin(double[,,] cube, int maxSize){
		double min = cube[0,0,0];
		for(int i = 0; i < maxSize; i++){
			for(int j = 0; j < maxSize; j++){
				for(int k = 0; k < maxSize; k++){
					if(cube[i,j,k] < min){
						min = cube[i,j,k];
					}
				}
			}
		}
		return min;
	}

	public static double findMax(double[,,] cube, int maxSize){
		double max = cube[0,0,0];
		for(int i = 0; i < maxSize; i++){
			for(int j = 0; j < maxSize; j++){
				for(int k = 0; k < maxSize; k++){
					if(cube[i,j,k] > max){
						max = cube[i,j,k];
					}
				}
			}
		}
		return max;
	}
}
