function y = test_get_interp2(mapstr)
% This script tests the interpolation routines against MATLAB 2D
% interpolation routines

% N-random latitudes and longitudes to define N^2 points in which we will
% be interpolating
N = 10;
Phin = (2*rand(N,1)-1)*90;
Phie = (2*rand(N,1)-1)*180;


N1 = zeros(length(Phin),length(Phie));
N2 = zeros(length(Phin),length(Phie));

fprintf(1,'Testing get_interp2(''%s'',.):\n',mapstr)

tic
for nn = 1:length(Phin)
    for ee = 1:length(Phie)
        phim_e = Phie(ee);
        phim_n = Phin(nn);
        N2(nn,ee) = get_interp2(mapstr, phim_e,phim_n);

    end
end
toc


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

loncnt = 0:spacing:360;
latcnt = 90:-spacing:-90;


[LON,LAT] = meshgrid(loncnt, latcnt);


tic
for nn = 1:length(Phin)
    for ee = 1:length(Phie)
        phim_e = Phie(ee);
        phim_n = Phin(nn);

        N1(nn,ee) = interp2(LON,LAT,map,phim_e,phim_n);


    end
end
toc

fprintf(1,'Maximum deviation from MATLAB interpolation is: %g\n', max(max(abs(N2-N1))) );

end
