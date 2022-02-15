P2001 Version 2 (11.08.17)

MATLAB implementation of Recommendation ITU-R P.2001-2

GENERAL NOTES
--------------

Files and subfolders in the distribution .zip package.

 tl_p2001.m                 - MATLAB function implementing Recommendation ITU-R P.2001-2

 validate_p2001_prof4.m
 validate_p2001_b2iseac.m   - MATLAB scripts used to validate the implementation of Recommendation ITU-R P.2001-2
                              as defined in the file tl_p2001.m using a set of test terrain profiles provided in
                              the folder ./validation/

 ./validation/	            - Folder containing a set of test terrain profiles and results of validation of MATLAB
                              implementation (or any other software implementation) of Recommendation ITU-R P.2001-2

 ./src/	                    - Folder containing the functions used by tl_p2001.m and validate_p2001*.m


UPDATES AND FIXES
-----------------
Version 2 (11.08.17)
        - Corrected a bug (typo) in dl_bull_smooth
        - Replaced load function calls to increase computational speed
        - Introduced a validation example for mixed paths (validate_p2001_b2iseac.m)

Version 1 (29.06.16)
        - Initial implementation