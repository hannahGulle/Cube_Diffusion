#!/usr/bin/sbcl --script

;; Hannah Gulle
;; CSC 330 Project 2 "Simplified 3D Diffusion Model"
;; Takes the single side dimension of a 3D cube with
;; an initial particle concentration of 1.0e21 particles
;; in the top left corner and simulates the amount of time
;; to fully diffuse the cube.

(defvar cube)			;; The 3D Cube
(defvar maxSize)		;; The Number of Cube Divisions in a Single Side Dimension
(defvar withPartition)		;; Determines if the Partition is Included
(defvar midpoint)		;; Integer Index Value of the Midpoint of a Single Side
(defvar diffusionCoef)		;; Coefficient Value for Diffusion Formula
(defvar roomDim)		;; Single Side Dimension of the Cube in Meters
(defvar gasSpeed)		;; Speed of the Gas Molecules within the Cube
(defvar sim-time)		;; Total Simulated Time to Diffuse
(defvar part-ratio)		;; Minimum to Maximum Particle Concentration Ratio
(defvar sum)			;; Total Sum of Particles in the Cube
(defvar maxVal)			;; Maximum Concentration of Particles in the Cube
(defvar minVal)			;; Minimum Concentration of Particles in the Cube
(defvar tStep)			;; Amount of Time in Seconds Lapsed after each "Round" of Diffusion
(defvar blockDist)		;; Distance in Meters between each Adjacent Cube Division
(defvar dTerm)			;; Diffusion Differential Term
(defvar change)			;; Difference in Particles of Adjacent Cube Divisions

; Arbitrary Value of Partition Cube Divisions
(defvar flag)
(setf flag -5.0)

; Request the Number of Cube Divisions in the 3D Cube Model
(format t "How big is the cube?~%")
(setf maxSize (read))
(setf midpoint (- (/ maxSize 2) 1))

; Request the Existence of the Partition
(format t "With Partition? (1/0) ~%")
(setf withPartition (read))

; Initialize the 3D Cube Model to the User Inputted Cube Division #
(setf cube (make-array (list maxSize maxSize maxSize)))

(setf change 0.0)		;; Initialize to No Change
(setf sim-time 0.0)		;; Initialize to No Simulated Time
(setf part-ratio 0.0)		;; Initialize to No Particle Ratio
(setf diffusionCoef 0.175)	;; Initialize to Constant
(setf roomDim 5.0)		;; Initialzie to 5.0 Meters
(setf gasSpeed 250.0)		;; Initialzie to 250.0 Meters/Second

; tStep = (roomDim / gasSpeed) / maxSize
(setf tStep (/ (/ roomDim gasSpeed) maxSize))

; blockDist = (roomDim / maxSize)
(setf blockDist (/ roomDim maxSize))

; dTerm = (tStep * diffusionCoef) / (blockDist^2)
(setf dTerm (/ (* tStep diffusionCoef) (* blockDist blockDist)))

; Set Parition Cubes to Flag; Otherwise Set to Zero
(dotimes (i maxSize)
  (dotimes (j maxSize)
    (dotimes (k maxSize)
	  (if (and (= i midpoint) (> j (- midpoint 1)) (= withPartition 1)) 
	    (setf (aref cube i j k) flag)
	    (setf (aref cube i j k) 0.0)
	  )
      )))

; Set Initial Value of the Top Left Corner
(setf (aref cube 0 0 0) 1.0e21)
	; Begin Diffusion Process
(defun diffusion (maxSize cube flag)
	(loop
	  (dotimes (i maxSize)
	    (dotimes (j maxSize)
	      (dotimes (k maxSize)
		; Diffuse Across Non-partition Type Cubes
		(if (not (eq (aref cube i j k) flag))
		  (progn
			; Diffuse Across Adjacent Cubes One Ahead of the i Axis
			; That Are Not Partition Cubes
		    (if (and (< (+ i 1) maxSize) (not (eq (aref cube (+ i 1) j k) flag)))
		      (progn
			(setf change (* dTerm (- (aref cube i j k) (aref cube (+ i 1) j k))))
			(setf (aref cube i j k) (- (aref cube i j k) change))
			(setf (aref cube (+ i 1) j k) (+ (aref cube (+ i 1) j k) change))
			)
		      )
			; Adjacent One Behind i Axis -- Not Partition
		    (if (and (>= (- i 1) 0) (not (eq (aref cube (- i 1) j k) flag)))
		      (progn
			(setf change (* dTerm (- (aref cube i j k) (aref cube (- i 1) j k))))
			(setf (aref cube i j k) (- (aref cube i j k) change))
			(setf (aref cube (- i 1) j k) (+ change (aref cube (- i 1) j k)))
			)
		      )
			; Adjacent One Ahead j Axis -- Not Partition
		    (if (and (< (+ j 1) maxSize) (not (eq (aref cube i (+ j 1) k) flag)))
		      (progn
			(setf change (* dTerm (- (aref cube i j k) (aref cube i (+ j 1) k))))
			(setf (aref cube i j k) (- (aref cube i j k) change))
			(setf (aref cube i (+ j 1) k) (+ (aref cube i (+ j 1) k) change))
			)
		      )
			; Adjacent One Behind j Axis -- Not Partition
		    (if (and (>= (- j 1) 0) (not (eq (aref cube i (- j 1) k) flag)))
		      (progn
			(setf change (* dTerm (- (aref cube i j k) (aref cube i (- j 1) k))))
			(setf (aref cube i j k) (- (aref cube i j k) change))
			(setf (aref cube i (- j 1) k) (+ change (aref cube i (- j 1) k)))   
			)
		      )
			; Adjacent One Ahead k Axis -- Not Partition
		    (if (and (< (+ k 1) maxSize) (not (eq (aref cube i j (+ k 1)) flag)))
		      (progn
			(setf change (* dTerm (- (aref cube i j k) (aref cube i j (+ k 1)))))
			(setf (aref cube i j k) (- (aref cube i j k) change))
			(setf (aref cube i j (+ k 1)) (+ (aref cube i j (+ k 1)) change))  
			)
		      )
			; Adjacent One Behind k Axis -- Not Partition
		    (if (and (>= (- k 1) 0) (not (eq (aref cube i j (- k 1)) flag)))
		      (progn
			(setf change (* dTerm (- (aref cube i j k) (aref cube i j (- k 1)))))
			(setf (aref cube i j k) (- (aref cube i j k) change))
			(setf (aref cube i j (- k 1)) (+ change (aref cube i j (- k 1))))   
			)
		      )
	  	  ))		
		)	
	      )
	    )
	
	; Increase Simulation Time for Each "Round" of Diffusion
	  (setf sim-time (+ sim-time tStep))

	  (setf sum 0.0)
	  (setf maxVal (aref cube 0 0 0))
	  (setf minVal (aref cube 0 0 0))

	; Find each Minimum and Maximum Concentration Value for the Diffusion
	; Ratio and Find the Sum to Check for Conservation of Matter for
	; Non-partition Type Cubes
	  (dotimes (i maxSize)
	    (dotimes (j maxSize)
	      (dotimes (k maxSize)
		(if (not (eq (aref cube i j k) flag))
		  (progn
		    (setf maxVal (max (aref cube i j k) maxVal))
		    (setf minVal (min (aref cube i j k) minVal))
		    (setf sum (+ sum (aref cube i j k)))
		    ))	
		)))

	  (format t "~$ ~%" sim-time)
	  (setf part-ratio (/ minVal maxVal))
	  (when (> part-ratio 0.99) (return part-ratio))); End of Diffuse Loop
(format t "Box equilibrated in ~$ seconds of simulated time.~%" sim-time)
)

(time (reduce #'+ (diffusion maxSize cube flag))) 
