P2001 Version 3.1 (28.10.19)

MATLAB implementation of Recommendation ITU-R P.2001-3

GENERAL NOTES
--------------

Files and subfolders in the distribution .zip package.

 tl_p2001.m                 - MATLAB function implementing Recommendation ITU-R P.2001-2

 test_p2001_prof4.m
 test_p2001_b2iseac.m       - MATLAB scripts used to produce test results as computed by the implementation of Recommendation ITU-R P.2001-3
                              as defined in the file tl_p2001.m using a set of test terrain profiles provided in
                              the folder ./validation_examples/ (filenames are hardcoded)

 ./validation_examples/	    - Folder containing a set of test terrain profiles and validation examples for the MATLAB
                              implementation (or any other software implementation) of Recommendation ITU-R P.2001-3

 ./validation_results/      - Folder containing results of validation as computed using this implementatino of Recommendation ITU-R P.2001-3

 ./src/	                    - Folder containing the functions used by tl_p2001.m and test_p2001*.m


UPDATES AND FIXES
-----------------
Version 3.1 (28.10.19)
    - Modifications in angular distance dependent loss according to ITU-R P.2001-3 (in tl_anomalous_reflection.m)
	- Restructured and improved the tests

Version 2.2 (26.04.18)
        - Corrections according to feedback obtained from CG [3J-3M-12]:
            - Declared empty arrays G and P for no-rain path (precipitation_fade_initial.m)
            - Introduced additional validation checks for input arguments  

Version 2.1 (11.08.17)
        - Corrected a bug (typo) in dl_bull_smooth
        - Replaced load function calls to increase computational speed
        - Introduced a validation example for mixed paths (validate_p2001_b2iseac.m)

Version 1 (29.06.16)
        - Initial implementation