function y = get_interp2(mapstr, phie, phin)
%get_inter2 Interpolates the value from Map at a given phie,phin
%
%     Input parameters:
%     map     -   string pointing to the radiometeorological map
%                 alowed strings: 'surfwv', 'h0', 'FoEs50', 'FoEs10',
%                 'FoEs01', 'F0Es0p1', 'Esarain_Pr6', 'Esarain_Mt',
%                 'Esarain_Beta', 'dndz_01', 'DN_SupSlope', 'DN-SubSlope',
%                 'DN_Median'
%                 (rows-latitude: 90 to -90, columns-longitude: 0 to 360)
%     phie    -   Longitude, positive to east (deg)
%     phin    -   Latitude, positive to north (deg)
%     spacing -   Resolution in latitude/longitude (deg)
%
%     Output parameters:
%     y      -    Interpolated value from the radiometeorological map at point (phie,phin)
%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    17APR23     Ivica Stevanovic, OFCOM         Initial version

switch mapstr
    
    case 'DN_Median'
        map = DigitalMaps_DN_Median();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'DN_SupSlope'
        map = DigitalMaps_DN_SupSlope();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'DN_SubSlope'
        map = DigitalMaps_DN_SubSlope();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'dndz_01'
        map = DigitalMaps_dndz_01();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'FoEs0p1'
        map = DigitalMaps_FoEs0p1();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'FoEs01'
        map = DigitalMaps_FoEs01();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'FoEs10'
        map = DigitalMaps_FoEs10();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'FoEs50'
        map = DigitalMaps_FoEs50();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'Esarain_Pr6'
        map = DigitalMaps_Esarain_Pr6_v5();
        nr = 161;
        nc = 321;
        spacing = 1.125;

    case 'Esarain_Mt'
        map = DigitalMaps_Esarain_Mt_v5();
        nr = 161;
        nc = 321;
        spacing = 1.125;

    case 'Esarain_Beta'
        map = DigitalMaps_Esarain_Beta_v5();
        nr = 161;
        nc = 321;
        spacing = 1.125;

    case 'h0'
        map = DigitalMaps_h0();
        nr = 121;
        nc = 241;
        spacing = 1.5;

    case 'surfwv'
        map = DigitalMaps_surfwv_50_fixed();
        nr = 121;
        nc = 241;
        spacing = 1.5;
end

longitudeOffset = phie;

if (phie < 0.0)
    longitudeOffset = phie + 360;
end

latitudeOffset = 90.0 - phin;

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
