P2001 Version 4.1 (21.04.23)

MATLAB implementation of Recommendation ITU-R P.2001-4

GENERAL NOTES
--------------

Files and subfolders in the distribution .zip package.

 tl_p2001.m             - MATLAB function implementing Recommendation ITU-R P.2001-4
  
 ./private/             - Folder containing the functions used by tl_p2001.m and validate_p2001*.m

 validate_p2001.m       - MATLAB scripts used to validate the implementation of Recommendation ITU-R P.2001-4
                              as defined in the file tl_p2001.m using a set of test terrain profiles provided in
                              the folder ./validation_examples/

 ./validation_examples/ - Folder containing validation examples for Recommendation ITU-R P.2001-4

 ./validation_results/  - Folder containing the results of the validation tests using tl_p2001.m on the terrain
                                profiles that correspond to the profiles defined in ./validation_examples/


UPDATES AND FIXES
-----------------
Version 4.1 (21.04.23)
        - Introduced a new routine get_interp2 instead of interp2 for interpolation from radiometeorological maps,
          which results in a ~7x increase in computational speed (MATLAB). 
          Validation files are updated with minor numerical changes (<1e-12 dB)
        - Corrected an indexing issue in path_fraction.m and longest_cont_dist.m 
        - Corrected an issue in dl_se.m to cap to zero only the polarization component that is negative 
        - Corrected an issue in validate_p2001.m when reporting the differences larger than the tolerance

Version 4 (22.05.22)
        - Modifications in free space loss according to ITU-R P.2001-4
	- Corrected Rx Lon/Lat in the profile b2iseac
        - Changed the format of validation examples from .xlsx to .csv and updated validation scripts
        - Update to validation examples
	- Renaming subfolder "src" to "private"

Version 3.1 (28.10.19)
        - Modifications in angular distance dependent loss according to ITU-R P.2001-3 (in tl_anomalous_reflection.m)
	- Restructured and improved the tests

Version 3 (28.06.18)
        - Corrections according to feedback obtained from CG 3J-3M-13:
            - Declared empty arrays G and P for no-rain path (precipitation_fade_initial.m)
            - Introduced additional validation checks for input arguments
	- Validation examples are recreated to account for the change in calculation of angular distance dependent loss 
          according to ITU-R P.2001-3
	- Restructured and improved the tests 
        - Included octave specific commands for reading/writing xlsx data.
        - Included script compare_results_vs_reference.m

Version 2 (11.08.17)
        - Corrected a bug (typo) in dl_bull_smooth
        - Replaced load function calls to increase computational speed
        - Introduced a validation example for mixed paths (validate_p2001_b2iseac.m)

Version 1 (29.06.16)
        - Initial implementation



License and copyright notice

Swiss Federal Office of Communications OFCOM (hereinafter the "Software Copyright Holder") makes the accompanying software 
(hereinafter the "Software") available free from copyright restriction.

The Software Copyright Holder represents and warrants that to the best of its knowledge,
it has the necessary copyright rights to waive all of the copyright rights as permissible under national law in the Software
such that the Software can be used by implementers without further licensing concerns.

No patent licence is granted, nor is a patent licensing commitment made, by implication, estoppel or otherwise.

Disclaimer: Other than as expressly provided herein,

(1) the Software is provided "AS IS" WITH NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO,
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGMENT OF INTELLECTUAL PROPERTY RIGHTS and

(2) neither the Software Copyright Holder (or its affiliates) nor the ITU shall be held liable in any event for any damages whatsoever
(including, without limitation, damages for loss of profits, business interruption, loss of information, or any other pecuniary loss)
arising out of or related to the use of or inability to use the Software.
