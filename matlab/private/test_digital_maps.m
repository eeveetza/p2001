% test digital maps values
% Phime = 0;
% Phimn = 0;
Phime = -69.4801969319433;
Phimn = -36.0460523359984;
Phime = 53.222;
Phimn = 87.046;
%DN_Median = load('DigitalMaps/DN_Median.txt');
% map = DigitalMaps_DN_Median();

% %DN_SupSlope = load('DigitalMaps/DN_SupSlope.txt');
% map = DigitalMaps_DN_SupSlope();
% 
% %DN_SubSlope = load('DigitalMaps/DN_SubSlope.txt');
%map = DigitalMaps_DN_SubSlope();
% map = DigitalMaps_dndz_01();
%map = DigitalMaps_surfwv_50_fixed();
% map = DigitalMaps_Esarain_Pr6_v5();
% loncnt = 0:1.125:360; 
% latcnt = 90:-1.125:-90;               %Table 2.4.1

% map = DigitalMaps_Esarain_Mt_v5();
% loncnt = 0:1.125:360; 
% latcnt = 90:-1.125:-90;  

% map = DigitalMaps_Esarain_Beta_v5();
% loncnt = 0:1.125:360; 
% latcnt = 90:-1.125:-90;  

% map = DigitalMaps_h0();
% loncnt = 0:1.5:360; 
% latcnt = 90:-1.5:-90; 

% map = DigitalMaps_FoEs0p1();
% loncnt = 0:1.5:360; 
% latcnt = 90:-1.5:-90; 

map = DigitalMaps_TropoClim();
loncnt = -179.75:0.5:180; 
latcnt = 89.75:-0.5:-90; 

                %Table 2.4.1

[LON,LAT] = meshgrid(loncnt, latcnt);

% Map Phime (-180, 180) to loncnt (0,360);


Phime1 = Phime;
% if Phime < 0
%     Phime1 = Phime + 360;
% end

% Find SdN from file DN_Median.txt for the path mid-pint at Phime (lon),
% Phimn (lat) - as a bilinear interpolation

SdN = interp2(LON,LAT,map,Phime1,Phimn)