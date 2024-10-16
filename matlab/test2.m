% testing against ITM
d = union(linspace(0,100,101), linspace(100, 1000, 91));
h = zeros(size(d));
z = 4*ones(size(d));
GHz = 10;
Tpc = 50;
Phire = 70.5;
Phirn = -60;
Phite = 75;
Phitn = -60;
Re = 6371;
Hrg = 100; 
Htg = 100;
Grx = 0;
Gtx = 0;
FlagVP = 1;

count = 1;
imin = 6;
for ii = imin:length(d)
    dd = d(1:ii);
    hh = h(1:ii);
    zz = z(1:ii);
    dpnt = dd(end)-dd(1);
    [Phire_ii, Phirn_ii, bt2r, dgc] = great_circle_path(Phire, Phite, Phirn, Phitn, Re, dpnt);
    p2001 = tl_p2001(dd, hh, zz, GHz, Tpc, Phire_ii, Phirn_ii, Phite, Phitn, Hrg, Htg, Grx, Gtx, FlagVP, 0);
    L0(count) = p2001.Lbm3;

    p2001 = tl_p2001(dd, hh, zz, GHz, Tpc, Phire_ii, Phirn_ii, Phite, Phitn, Hrg, Htg, Grx, Gtx, FlagVP, 1);
    L1(count) = p2001.Lbm3;
    Lfs(count) = 92.4 + 20*log10(GHz) + 10*log10(dd(end).^2 + (Htg-Hrg).^2/1e6);
    count = count + 1;
end

plot(d(imin:end), L0, 'b', 'LineWidth', 2)
hold on
plot(d(imin:end), L1, 'r', 'LineWidth', 2)
grid on
plot(d(imin:end), Lfs, 'g', 'LineWidth', 2)
set(gca,'FontSize', 14)
legend('P.2001-4','P.2001 PDR', 'Free-Space')
xlabel('distance (km)')
ylabel('Lb (dB)')
titlestr = ['f = ' num2str(GHz) ' GHz, Htg = ' num2str(Htg) ' m, Hrg = ' num2str(Hrg) ' m' ]
title(titlestr)