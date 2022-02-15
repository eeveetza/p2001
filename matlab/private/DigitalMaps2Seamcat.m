%y = DigitalMaps_DN_Median();
%y = DigitalMaps_DN_SupSlope();
%y = DigitalMaps_DN_SubSlope();
%y = DigitalMaps_dndz_01();
% y = DigitalMaps_surfwv_50_fixed()
%y = DigitalMaps_Esarain_Pr6_v5();
%y = DigitalMaps_Esarain_Mt_v5();
%y = DigitalMaps_Esarain_Beta_v5();
%y = DigitalMaps_h0();
%y = DigitalMaps_TropoClim()
%y = DigitalMaps_FoEs0p1();
%y = DigitalMaps_FoEs01();
%y = DigitalMaps_FoEs10();
y = DigitalMaps_FoEs50();
[m,n] = size(y);

fprintf(1,'double[][] y = {\n');
for i = 1:m
    fprintf(1,'{');
    for j = 1:n
        if j == n
            fprintf(1,'%15g},\n',y(i,j));
        else
            fprintf(1,'%15g, ',y(i,j));
        end
    end
end
fprintf(1,'};');
        