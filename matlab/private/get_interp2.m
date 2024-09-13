function y = get_interp2(mapstr, phie, phin)
%get_inter2 Interpolates the value from Map at a given phie,phin
%
%     Input parameters:
%     mapstr   -   string pointing to the radiometeorological map
%                 alowed strings: 'surfwv', 'h0', 'FoEs50', 'FoEs10',
%                 'FoEs01', 'F0Es0p1', 'Esarain_Pr6', 'Esarain_Mt',
%                 'Esarain_Beta', 'dndz_01', 'DN_SupSlope', 'DN-SubSlope',
%                 'DN_Median'
%                 (rows-latitude: 90 to -90, columns-longitude: 0 to 360)
%     phie    -   Longitude, positive to east (deg)
%     phin    -   Latitude, positive to north (deg)
%     Output parameters:
%     y      -    Interpolated value from the radiometeorological map at point (phie,phin)
%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    17APR23     Ivica Stevanovic, OFCOM         Initial version
%     v1    13SEP24     Ivica Stevanovic, OFCOM         Streamlining datamaps and error messages

if (phin < -90 || phin > 90)
    error ('Latitude must be within the range -90 to 90 degrees');
end

if (phie < -180 || phie > 180)
    error('Longitude must be within the range -180 to 180 degrees');
end

errorstr = sprintf(['DigitalMaps_%s() not found. \n' ...
    '\nBefore running get_interp2, make sure to: \n' ...
    '    1. Download and extract the required maps to ./private/maps:\n' ...
    '        - From ITU-R P.2001-5:\n' ...
    '          DN_Median.txt        DN_SubSlope.txt           DN_SupSlope.txt     dndz_01.txt\n' ...
    '          Esarain_Beta_v5.txt  Esarain_Mt_v5.txt         Esarain_Pr6_v5.txt\n'  ...
    '          FoEs0.1.txt          FoEs01.txt  FoEs10.txt    FoEs50.txt\n' ...
    '          h0.txt               surfwv_50_fixed.txt       TropoClim.txt\n' ...
    '    2. Run the script initiate_digital_maps.m to generate the necessary functions.\n'], mapstr);

switch mapstr

    case 'DN_Median'
        try
            map = DigitalMaps_DN_Median();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'DN_SupSlope'
        try
            map = DigitalMaps_DN_SupSlope();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'DN_SubSlope'
        try
            map = DigitalMaps_DN_SubSlope();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'dndz_01'
        try
            map = DigitalMaps_dndz_01();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'FoEs0p1'
        try
            map = DigitalMaps_FoEs0p1();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'FoEs01'
        try
            map = DigitalMaps_FoEs01();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'FoEs10'
        try
            map = DigitalMaps_FoEs10();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'FoEs50'
        try
            map = DigitalMaps_FoEs50();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'Esarain_Pr6'
        try
            map = DigitalMaps_Esarain_Pr6_v5();
        catch
            error(errorstr);
        end
        nr = 161;
        nc = 321;
        spacing = 1.125;

    case 'Esarain_Mt'
        try
            map = DigitalMaps_Esarain_Mt_v5();
        catch
            error(errorstr);
        end
        nr = 161;
        nc = 321;
        spacing = 1.125;

    case 'Esarain_Beta'
        try
            map = DigitalMaps_Esarain_Beta_v5();
        catch
            error(errorstr);
        end
        nr = 161;
        nc = 321;
        spacing = 1.125;

    case 'h0'
        try
            map = DigitalMaps_h0();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'surfwv'
        try
            map = DigitalMaps_surfwv_50_fixed();
        catch
            error(errorstr);
        end
        nr = 121;
        nc = 241;
        spacing = 1.5;

    otherwise

        error('Error in function call. Uknown map: %s.\n',mapstr);
end

% lat starts with 90
latitudeOffset = 90 - phin;
% lon starts with 0
longitudeOffset = phie;
if phie < 0
    longitudeOffset = phie + 360;
end

latitudeIndex  = floor(latitudeOffset / spacing)  + 1;
longitudeIndex = floor(longitudeOffset / spacing) + 1;

latitudeFraction  = (latitudeOffset / spacing)  - (latitudeIndex  - 1);
longitudeFraction = (longitudeOffset / spacing) - (longitudeIndex - 1);

val_ul = map(latitudeIndex, longitudeIndex);
val_ur = map(latitudeIndex, min(longitudeIndex + 1, nc));
val_ll = map(min(latitudeIndex + 1, nr), longitudeIndex);
val_lr = map(min(latitudeIndex + 1, nr), min(longitudeIndex + 1, nc));

y1 = longitudeFraction  * ( val_ur - val_ul ) + val_ul;
y2 = longitudeFraction  * ( val_lr - val_ll ) + val_ll;
y  = latitudeFraction * ( y2 - y1 ) + y1;

return
end
