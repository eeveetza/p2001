function [Lbe, Lbes1, Lbes2, Lp1t, Lp2t, Lp1r, Lp2r, Gamma1, Gamma2, FoEs1hop, FoEs2hop, Phi1qe, Phi1qn, Phi3qe, Phi3qn] = tl_sporadic_e(f, dt, thetat, thetar, phimn, phime, phitn, phite, phirn, phire, dlt, dlr, ae, Re, p)
%tl_sporadic_e Sporadic-E transmission loss
%   This function computes the basic transmission loss due to sporadic-E
%   propagation as defined in ITU-R P.2001-2 (Attachment G)
%
%     Input parameters:
%     f       -   Frequency GHz
%     dt      -   Total distance (km)
%     thetat  -   Tx horizon elevation angle relative to the local horizontal (mrad)
%     thetar  -   Rx horizon elevation angle relative to the local horizontal (mrad)
%     phimn   -   Mid-point latitude (deg)
%     phime   -   Mid-point longitude (deg)
%     phitn   -   Tx latitude (deg)
%     phite   -   Tx longitude (deg)
%     phirn   -   Rx latitude (deg)
%     phire   -   Rx longitude (deg)
%     dlt     -   Tx to horizon distance (km)
%     dlr     -   Rx to horizon distance (km)
%     ae      -   Effective Earth radius (km)
%     Re      -   Average Earth radius (km)
%     p       -   Percentage of average year for which predicted basic loss
%                 is not exceeded (%)
%
%     Output parameters:
%     Lbe    -   Basic transmission loss due to sporadic-E propagation (dB)
%     Lbes1  -   Sporadic-E 1-hop basic transmission loss (dB)
%     Lbes2  -   Sporadic-E 2-hop basic transmission loss (dB)
%     Lp1t/r -   Diffraction losses at the two terminals for 1-hop propagation (dB)
%     Lp2t/r -   Diffraction losses at the two terminals for 2-hop propagation (dB)
%     Gamma1/2   Ionospheric loss for 1/2 hops (dB)
%     FoEs1/2hop FoEs for 1/2 hop(s) sporadic-E propagation
%     Phi1qe -   Longitude of the one-quarter point
%     Phi1qn -   Latitude of the one-quarter point
%     Phi3qe -   Longitude of the three-quarter point
%     Phi3qn -   Latitude of the three-quarter point
%
%     Example:
%     [Lbe, Lbes1, Lbes2, Lp1t, Lp2t, Lp1r, Lp2r, Gamma1, Gamma2, foes1, foes2, Phi1qe, Phi1qn, Phi3qe, Phi3qn] = tl_sporadic_e(f, dt, thetat, thetar, phitn, phite, phirn, phire, dlt, dlr, ae, Re, p)

%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    18JUL16     Ivica Stevanovic, OFCOM         Initial version
%     v1    13JUN17     Ivica Stevanovic, OFCOM         replaced load function calls to increase computational speed
%     v2    20APR23     Ivica Stevanovic, OFCOM         introduced get_interp2 to increase computational speed


% Attachment G: Sporadic-E propagation

%% G.2 Derivation of FoEs

if p<1
    p1 = 0.1; 
    p2 = 1;
elseif (p > 10)
    p1 = 10; 
    p2 = 50;
else
    p1 = 1;
    p2 = 10;
end


%% G.2 1-hop propagation

% foes for the mid-point of the path
% Find foes1/2 from the correspoinding files for the path mid-point - as a bilinear interpolation

if p1 ==  0.1
    foes1 = get_interp2('FoEs0p1',phime,phimn);
    foes2 = get_interp2('FoEs01',phime,phimn);
elseif (p1 == 1)
    foes1 = get_interp2('FoEs01',phime,phimn);
    foes2 = get_interp2('FoEs10',phime,phimn);
else
    foes1 = get_interp2('FoEs10',phime,phimn);
    foes2 = get_interp2('FoEs50',phime,phimn);
end

FoEs1hop = foes1 + (foes2-foes1) * (log10(p/p1))/(log10(p2/p1));          % Eq (G.1.1)

% Ionospheric loss for one hop

Gamma1 = ( 40/ (1 + dt/130 + (dt/250)^2) + 0.2 * (dt/2600)^2 ) * (1000*f/FoEs1hop)^2 + exp((dt - 1660)/280);     % Eq (G.2.1)

% Slope path length

hes = 120;

l1 = 2*( ae^2 + (ae + hes)^2 -2 * ae *(ae + hes) * cos(dt/(2*ae))  )^0.5; % Eq (G.2.2)

% free space loss for the slope distance:

Lbfs1 = tl_free_space(f, l1);                                             % Eq (G.2.3)

% ray take-off angle above the horizontal at both terminals for 1 hop

alpha1 = dt/(2*ae);

epsr1 = 0.5*pi - atan(ae * sin(alpha1) /(hes + ae*( 1-cos(alpha1) ) )) - alpha1;    % Eq (G.2.4)

% Diffraction angles for the two terminals

delta1t = 0.001 * thetat - epsr1;
delta1r = 0.001 * thetar - epsr1;                                         % (G.2.5)

% Diffraction parameters (G.2.6)

if delta1t >= 0
    
    nu1t =  3.651* sqrt(1000 * f * dlt * (1-cos(delta1t))/cos(0.001*thetat));
    
else
    
    nu1t = -3.651* sqrt(1000 * f * dlt * (1-cos(delta1t))/cos(0.001*thetat));

end


if delta1r >= 0
    
    nu1r =  3.651* sqrt(1000 * f * dlr * (1-cos(delta1r))/cos(0.001*thetar));
    
else
    
    nu1r = -3.651* sqrt(1000 * f * dlr * (1-cos(delta1r))/cos(0.001*thetar));

end

% Diffraction lossess at the two terminals (G.2.7)

Lp1t = dl_knife_edge(nu1t);

Lp1r = dl_knife_edge(nu1r);

% Sporadic-E 1-hop basic transmission loss (G.2.8)

Lbes1 = Lbfs1 + Gamma1 + Lp1t + Lp1r;

%% G.3 2-hop propagation

% Latitude and longitude of the one-quarter point

d1q = 0.25*dt;

[Phi1qe, Phi1qn] = great_circle_path(phire, phite, phirn, phitn, Re, d1q);

% Latitude and longitude of the one-quarter point

d3q = 0.75*dt;

[Phi3qe, Phi3qn] = great_circle_path(phire, phite, phirn, phitn, Re, d3q);

% foes for one-quarter point
% Map phime (-180, 180) to loncnt (0,360);

phie = Phi1qe;
phin = Phi1qn;

if p1 ==  0.1
    foes1 = get_interp2('FoEs0p1',phie,phin);
    foes2 = get_interp2('FoEs01',phie,phin);
elseif (p1 == 1)
    foes1 = get_interp2('FoEs01',phie,phin);
    foes2 = get_interp2('FoEs10',phie,phin);
else
    foes1 = get_interp2('FoEs10',phie,phin);
    foes2 = get_interp2('FoEs50',phie,phin);
end

FoEs2hop1q = foes1 + (foes2-foes1) * (log10(p/p1))/(log10(p2/p1));          % Eq (G.1.1)

% foes for three-quarter point
% Map phie (-180, 180) to loncnt (0,360);

phie = Phi3qe;
phin = Phi3qn;

if p1 ==  0.1
    foes1 = get_interp2('FoEs0p1',phie,phin);
    foes2 = get_interp2('FoEs01',phie,phin);
elseif (p1 == 1)
    foes1 = get_interp2('FoEs01',phie,phin);
    foes2 = get_interp2('FoEs10',phie,phin);
else
    foes1 = get_interp2('FoEs10',phie,phin);
    foes2 = get_interp2('FoEs50',phie,phin);
end


FoEs2hop3q = foes1 + (foes2-foes1) * (log10(p/p1))/(log10(p2/p1));          % Eq (G.1.1)

% Obtain FoEs2hop as the lower of the two values calculated above

FoEs2hop = min(FoEs2hop1q, FoEs2hop3q);

% Ionospheric laps for two hops (G.3.1)

Gamma2 = ( 40/(1 + (dt/260) + (dt/500)^2) + 0.2 * (dt/5200)^2 )* (1000*f/FoEs2hop)^2 + exp((dt-3220)/560); 

% Slope path lenght

l2 = 4*( ae^2 + (ae + hes)^2 -2*ae*(ae + hes)*cos(dt/(4*ae)) )^0.5;       % Eq (G.3.2)

% Free-space loss for this slope

Lbfs2 = tl_free_space(f, l2);                                             % Eq (G.3.3)

% Ray take-off angle above the local horiozntal at both terminals for 2
% hops (G.3.4)

alpha2 = dt/(4*ae);

epsr2 = 0.5*pi -atan( ae * sin(alpha2)/(hes + ae*(1-cos(alpha2))) ) - alpha2;  

% Diffraction angles for the two terminals (G.3.5)

delta2t = 0.001*thetat - epsr2;
delta2r = 0.001*thetar - epsr2;

% Corresponding diffraction parameters (G.3.6)

if delta2t >= 0
    
    nu2t =  3.651* sqrt(1000 * f * dlt * (1-cos(delta2t))/cos(0.001*thetat));
    
else
    
    nu2t = -3.651* sqrt(1000 * f * dlt * (1-cos(delta2t))/cos(0.001*thetat));

end


if delta2r >= 0
    
    nu2r =  3.651* sqrt(1000 * f * dlr * (1-cos(delta2r))/cos(0.001*thetar));
    
else
    
    nu2r = -3.651* sqrt(1000 * f * dlr * (1-cos(delta2r))/cos(0.001*thetar));

end

% Diffraction lossess at the two terminals (G.3.7)

Lp2t = dl_knife_edge(nu2t);

Lp2r = dl_knife_edge(nu2r);

% Sporadic-E two-hop basic transmission loss

Lbes2 = Lbfs2 + Gamma2 + Lp2t + Lp2r;

%% G.4 Basic transmission loss (G.4.1)

if Lbes1 < Lbes2-20
    Lbe = Lbes1;
elseif (Lbes2 < Lbes1 -20)
    Lbe = Lbes2;
else
    Lbe = -10*log10(10^(-0.1*Lbes1) + 10^(-0.1*Lbes2));
end

return
end