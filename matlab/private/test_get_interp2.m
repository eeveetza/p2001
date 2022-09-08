latcnt = 90:-1.125:-90;               %Table 2.4.1
loncnt = 0:1.125:360;                 %Table 2.4.1
[LON,LAT] = meshgrid(loncnt, latcnt);


Phin = (2*rand(50,1)-1)*90;
Phie = rand(50,1)*360;

dN1 = zeros(length(Phin),length(Phie));
dN2 = zeros(length(Phin),length(Phie));

N1 = zeros(length(Phin),length(Phie));
N2 = zeros(length(Phin),length(Phie));


        map1 = DigitalMaps_Esarain_Beta_v5();
        map2 = DigitalMaps_Esarain_Mt_v5();


tic
for nn = 1:length(Phin)
    for ee = 1:length(Phie)
        phim_e = Phie(ee);
        phim_n = Phin(nn);


        % Map phicve (-180, 180) to loncnt (0,360);
        phim_e1 = phim_e;
        if phim_e1 < 0
            phim_e1 = phim_e + 360;
        end

        dN1(nn,ee) = interp2(LON,LAT,map1,phim_e1,phim_n);
        N1(nn,ee)  = interp2(LON,LAT,map2,phim_e1,phim_n);

    end
end
toc

tic
for nn = 1:length(Phin)
    for ee = 1:length(Phie)
        phim_e = Phie(ee);
        phim_n = Phin(nn);
        dN2(nn,ee) = get_interp2('Esarain_Beta', phim_e,phim_n);
        N2(nn,ee)  = get_interp2('Esarain_Mt', phim_e,phim_n);
    end
end
toc

max(max(abs(N2-N1)))
max(max(abs(dN2-dN1)))
