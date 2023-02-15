# MATLAB/Octave Implementation of Recommendation ITU-R P.2001


This code repository contains a MATLAB/Octave software implementation of [Recommendation ITU-R P.2001-4](https://www.itu.int/rec/R-REC-P.2001/en) with a general purpose wide-range terrestrial propagation model in the frequency range 30 MHz to 50 GHz.  

This development version implements PDR from WP 3M Chairman's Report [3M/364 Annex 2](https://www.itu.int/dms_ties/itu-r/md/19/wp3m/c/R19-WP3M-C-0364!N02!MSW-E.docx) with troposcatter transmission loss prediction model from [ITU-R P.617](https://www.itu.int/rec/R-REC-P.617/en), which is being evaluated by CG 3K-3M-18.

This is a development version of the code that does not necessarily correspond to the reference version approved by ITU-R Working Party 3M and published on [ITU-R SG 3 Software, Data, and Validation Web Page](https://www.itu.int/en/ITU-R/study-groups/rsg3/Pages/iono-tropo-spheric.aspx) as digital supplement to [Recommendation ITU-R P.2001](https://www.itu.int/rec/R-REC-P.2001/en).



The following table describes the structure of the folder `./matlab/` containing the MATLAB/Octave implementation of Recommendation ITU-R P.2001.

| File/Folder               | Description                                                         |
|----------------------------|---------------------------------------------------------------------|
|`tl_p2001.m`                | MATLAB function implementing Recommendation ITU-R P.2001-4         |           
|`validate_p2001.m`                  | MATLAB scripts used to validate this implementation using a set of test terrain profiles provided in `./validation_examples/` |   
|`./validation_examples/`    | Folder containing validation examples for Recommendation ITU-R P.2001-4 |
|`./validation_results/`	   | Folder containing the results of the validation tests using `tl_p2001.m` on the terrain profiles that corespond to the profiles defined in `./validation_examples/` |
|`./private/`   |             Folder containing the functions called by `tl_2001.m` and `validate_p2001*.m`|
|`./C3_1_profiles/`   |             Folder containing terrain profiles and measurement files for Terrestrial trans-horizon links in DBSG3 (`CG-3M-2/DBSG3 Repository/Part II Terrestrial trans-horizon.../ III-01)`|
|`read_C3_1_profile.m`   |             MATLAB script for reading the terrain profile|
|`read_data_table_C3_1.m`   |             MATLAB script for reading the measurement data|
|`compute_btl_table_C3_1.m`   |             MATLAB script for comuting the basic transmission loss according to ITU-R P.200-4 and the PDR on troposcatter for those paths from table C3_1 which have complete set of input parameters and computes the prediction errors of the two approaches in an Excel file `Results_Table_C3_1_P2001.xls`|

## Function Call

~~~
p2001 = tl_p2001(d, h, z, GHz, Tpc, Phire, Phirn, Phite, Phitn, Hrg, Htg, Grx, Gtx, FlagVP, pdr);
~~~

## Required input arguments of function `tl_p2001`

| Variable          | Type   | Units | Limits       | Description  |
|-------------------|--------|-------|--------------|--------------|
| `d`               | array double | km   | 0 < `max(d)` ≤ ~1000 | Terrain profile distances (in the ascending order from the transmitter)|
| `h`          | array double | m (asl)   |   | Terrain profile heights |
| `z`          | array int    |       |  1 - Sea, 3 - Coastal Land, 4 - Inland |  Zone code |
| `GHz`               | scalar double | GHz   | 0.3 ≤ `GHz` ≤ 50 | Frequency   |
| `Tpc`               | scalar double | %   | 0 < `Tpc` < 100 | Percentage of time (average year) for which the predicted basic transmission loss is not exceeded |
| `Phire`               | scalar double | deg   | -180 ≤ `Phire` ≤ 180 | Receiver longitude, positive to east   |
| `Phirn`               | scalar double | deg   | -90 ≤ `Phirn` ≤ 90 | Receiver latitude, positive to north     |
| `Phite`               | scalar double | deg   | -180 ≤ `Phite` ≤ 180 | Transmitter longitude, positive to east   |
| `Phitn`               | scalar double | deg   | -90 ≤ `Phitn` ≤ 90   | Transmitter latitude, positive to north     |
| `Hrg`                 | scalar double    | m      |   0 < `hrg`  < ~8000          |  Receiving antenna height above ground |
| `Htg`                 | scalar double    | m      |   0 < `htg`  < ~8000          |  Transmitting antenna height above ground |
| `Grg`                 | scalar double    | dBi      |                             |  Receiving antenna gain in the direction of the ray to the transmitting antenna |
| `Gtg`                 | scalar double    | dBi      |            |  Transmitting antenna gain in the direction of the ray to the receiving antenna |
| `flagVP`                 | scalar int    |        |   1, 0         |  Signal polarisation: 1 - vertical, 0 - horizontal |
| `pdr`                 | scalar int    |        |   1, 0         |  0 - uses ITU-R P.2001-4, 1 - uses PDR ITU-R P.2001-4 troposcatter |

## Outputs ##
The output is a structure with 122 fields (described in detail in `tl_p2001.m`) containing intermediate and final results, including the following basic transmission losses:

| Variable   | Type   | Units | Description |
|------------|--------|-------|-------------|
| `Lb`    | double | dB    | Basic transmission loss not exceeded Tpc % time |
| `Lbfs`    | double | dB    |Free-space basic transmission loss |
| `Ld`    | double | dB    | Diffraction loss |
| `Lba`    | double | dB    | Basic transmission loss associated with anomalous propagation |
| `Lbs`    | double | dB    | Troposcatter basic transmission loss |
| `Lbe1`, `Lbe2`    | double | dB    | Sporadic-E basic transmission loss for 1- and 2-hop paths, respectively |
| `...`    |  |    | ... |

## Software Versions
The code was tested and runs on:
* MATLAB version 2022a (MS Windows)



## References

* [Recommendation ITU-R P.2001](https://www.itu.int/rec/R-REC-P.2001/en)

* [ITU-R SG 3 Software, Data, and Validation Web Page](https://www.itu.int/en/ITU-R/study-groups/rsg3/Pages/iono-tropo-spheric.aspx)
