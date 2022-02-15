P2001 Version 2.2 (26.04.18)

MATLAB implementation of Recommendation ITU-R P.2001-2

GENERAL NOTES
--------------

Files and subfolders in the distribution .zip package.

 tl_p2001.m                 - MATLAB function implementing Recommendation ITU-R P.2001-2


 validate_p2001_b2iseac.m   - MATLAB scripts used to validate the implementation of Recommendation ITU-R P.2001-2
 validate_p2001_prof4.m       as defined in the file tl_p2001.m using a set of test terrain profiles provided in
                              the folder ./validation_results/

 ./validation_examples/     - Folder containing validation examples for Recommendation ITU-R P.2001-2

 ./validation_results/      - Folder containing the results of the validation tests using tl_p2001.m on the terrain
                              profiles that corespond to the profiles defined in ./validation_examples/

 ./src/	                    - Folder containing the functions used by tl_p2001.m and validate_p2001*.m


UPDATES AND FIXES
-----------------
Version 2.2 (26.04.18)
        - Corrections according to feedback obtained from CG 3J-3M-13:
            - Declared empty arrays G and P for no-rain path (precipitation_fade_initial.m)
            - Introduced additional validation checks for input arguments  

Version 2.1 (11.08.17)
        - Corrected a bug (typo) in dl_bull_smooth
        - Replaced load function calls to increase computational speed
        - Introduced a validation example for mixed paths (validate_p2001_b2iseac.m)

Version 1 (29.06.16)
        - Initial implementation