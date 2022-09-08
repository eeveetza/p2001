function p2001 = tl_p2001(d, h, z, GHz, Tpc, Phire, Phirn, Phite, Phitn, Hrg, Htg, Grx, Gtx, FlagVP) 
%tl_p2001 WRPM in the frequency range 30 MHz to 50 GHz ITU-R P.2001-4
%   This function computes path loss due to both signal enhancements and fading 
%   over the range from 0% to 100% of an average year according to the
%   general purpose wide-range model as described in Recommendation ITU-R
%   P.2001-4. The model covers the frequency range from 30 MHz to 50 GHz
%   and it is most accurate for distances from 3 km to at least 1000 km.
%   There is no specific lower limit, although the path length 
%   must be greater than zero. A prediction of basic transmission loss less 
%   than 20 dB should be considered unreliable. Similarly, there is no 
%   specific maximum distance. Antennas heights above ground level must be 
%   greater than zero. There is no specific maximum height above ground. 
%   The method is believed to be reliable for antenna altitudes 
%   up to 8000 m above sea level.
%
% Inputs
% 
% Variable    Unit  Type    Ref         Description
% d           km    float   (2.1a)      Distance from transmitter of i-th profile point          
% h           m     float   (2.1b)      Height of i-th profile point (amsl)
% z           z     int     (2.1c)      Zone code at distance di from transmitter 
%                                       (1 = Sea, 3 = Coastal Land, 4 = Inland) 
% GHz         GHz   float   T.2.2.1     Frequency
% Tpc         %     float   T.2.2.1     Percentage of average year for which the predicted basic transmission loss is not exceeded
% Phire       deg   float   T.2.2.1     Receiver longitude, positive to east
% Phirn       deg   float   T.2.2.1     Receiver latitude, positive to north
% Phite       deg   float   T.2.2.1     Transmitter longitude, positive to east
% Phitn       deg   float   T.2.2.1     Transmitter latitude, positive to north
% Hrg         m     float   T.2.2.1     Receiving antenna height above ground
% Htg         m     float   T.2.2.1     Transmitting antenna height above ground
% Grx         dBi   float   T.2.2.1     Receiving antenna gain in the direction of the ray to the transmitting antenna
% Gtx         dBi   float   T.2.2.1     Transmitting antenna gain in the direction of the ray to the receiving antenna
% FlagVp            bool    T.2.2.1     Polarisation: 1 = vertical; 0 = horizontal
% 
% Outputs: 
%
% p2001     A structure with the fields as described below 
%           (in alphabetical order). Note that p2001.Lb contains the final 
%           result: Basic transmission loss not exceeded Tpc % time.
%
% Variable  Unit    Type    Ref         Description
% A1        dB      float   (4.1.2)     Combined clear-air and rain/wet-snow fade for path close to surface
% A2        dB      float   (4.3.6)     Combined clear-air and rain/wet-snow fade for troposcatter path
% A2r       dB      float   (4.3.4)     Combined clear-air and rain/wet-snow fade for receiver to common-volume path
% A2t       dB      float   (4.3.2)     Combined clear-air and rain/wet-snow fade for transmitter to common-volume path
% Aac       dB      float   (D.5.1)     Antennas to anomalous propagation mechanism loss
% Aad       dB      float   (D.6.4)     Anomalous propagation angular-distance dependent loss
% Aat       dB      float   (D.7.7)     Adjusted anomalous propagation time dependent loss
% Ags       dB      float   (4.3.7)     Total gaseous attenuation on troposcatter path under non-rain conditions
% Agsur     dB      float   (3.10.1)    Total gaseous attenuation on surface path under non-rain conditions
% Aorcv     dB      float   (F.3.2a)    Oxygen attenuation on receiver to common-volume path
% Aos       dB      float   (F.3.3a)    Oxygen attenuation on troposcatter path
% Aosur     dB      float   (F.2.2a)    Oxygen attenuation on surface path
% Aotcv     dB      float   (F.3.1a)    Oxygen attenuation on transmitter to common-volume path
% Awrcv     dB      float   (F.3.2b)    Water-vapour attenuation on receiver to common-volume path under non-rain conditions
% Awrrcv    dB      float   (F.3.2c)    Water-vapour attenuation on receiver to common-volume path under rain conditions
% Awrs      dB      float   (F.3.3c)    Water-vapour attenuation on troposcatter path under rain conditions
% Awrsur    dB      float   (F.2.2c)    Water-vapour attenuation on surface path under rain conditions
% Awrtcv    dB      float   (F.3.1c)    Water-vapour attenuation on transmitter to common-volume path under rain conditions
% Aws       dB      float   (F.3.3b)    Water-vapour attenuation on troposcatter path under non-rain conditions
% Awsur     dB      float   (F.2.2b)    Water-vapour attenuation on surface path under non-rain conditions
% Awtcv     dB      float   (F.3.1b)    Water-vapour attenuation on transmitter to common-volume path under non-rain conditions
% Bt2rDeg   deg     float               Bearing from transmitter to receiver, east of true north
% Cp        1/km    float   (3.5.2)     Effective Earth curvature not exceeded p% time
% D         km      float   S.2.1       Path length derived from profile
% Dcr       km      float   D.4.1b)     Distance from receiver to coast
% Dct       km      float   (D.4.1a)    Distance from transmitter to coast
% Dgc       km      float   (H.2.4)     Great-circle path length calculated from terminal coordinates
% Dlm       km      float   D.1         Longest continuous inland section of path
% Dlr       km      float   S.3.7       Receiver horizon distance
% Dlt       km      float   S.3.7       Transmitter horizon distance
% Drcv      km      float   (3.9.1b)    Receiver to common-volume horizontal distance
% Dtcv      km      float   (3.9.1a)    Transmitter to common-volume horizontal distance
% Dtm       km      float   D.1         Longest continuous land (inland or coastal) section of path
% Foes1     MHz     float   G.2         FoEs for one-hop sporadic-E propagation
% Foes2     MHz     float   G.3         FoEs for two-hop sporadic-E propagation
% Fsea              float   S.3.2       Fraction of path over sea ('omega' )
% Fwvr              float   (C.2.13)    Rain water-vapour factor
% Fwvrr             float   S.4.3       Rain water-vapour factor for receiver to common-volume segment of path
% Fwvrt             float   S.4.3       Rain water-vapour factor for transmitter to common-volume segment of path
% Gam1      dB      float   (G.2.1)     Ionospheric loss for one hop (large 'gamma')
% Gam2      dB      float   (G.3.1)     Ionospheric loss for two hops (large 'gamma')
% Gamo      dB/km   float   (F.6.1)     Sea-level specific attenuation due to oxygen
% Gamw      dB/km   float   F.4         Sea-level specific attenuation due to water-vapour under non-rain conditions
% Gamwr     dB/km   float   F.4         Sea-level specific attenuation due to water-vapour under rain conditions
% H1        m       float   S.3.3       First (tx) profile point height above sea level
% Hcv       m       float   (3.9.2)     Troposcatter common volume height above sea level
% Hhi       m       float   (3.3.2a)    Higher antenna height above sea level
% Hlo       m       float   (3.3.2b)    Lower antenna height above sea level
% Hm        m       float   (3.8.7)     Path roughness parameter
% Hmid      m       float   S.3.2       Profile mid-point height above sea level
% Hn        m       float   S.3.3       Last (rx) profile point height above sea level
% Hrea      m       float   (3.8.6b)    Receiver effective height for anomalous propagation
% Hrep      m       float   (3.8.11b)   Receiver effective height for diffraction
% Hrs       m       float   (3.3.1b)    Receiver antenna height above sea level
% Hsrip     m       float   (3.8.3b)    Initial smooth-surface height at rx
% Hsripa    m       float   (3.8.4b)    Smooth surface height at rx not exceeding ground level
% Hstip     m       float   (3.8.3a)    Initial smooth-surface height at tx
% Hstipa    m       float   (3.8.4a)    Smooth surface height at tx not exceeding ground level
% Htea      m       float   (3.8.6a)    Transmitter effective height for anomalous propagation
% Htep      m       float   (3.8.11a)   Transmitter effective height for diffraction
% Hts       m       float   (3.3.1a)    Transmitter antenna height above sea level
% Lb        dB      float   (5.2.1)     FINAL RESULT. Basic transmission loss not exceeded Tpc % time
% Lba       dB      float   (D.8.1)     Basic transmission loss associated with anomalous propagation
% Lbes1     dB      float   (G.2.8)     Sporadic-E basic transmission loss, 1-hop path
% Lbes2     dB      float   (G.3.8)     Sporadic-E basic transmission loss, 2-hop path
% Lbfs      dB      float   (3.11.2)    Free-space basic transmission loss
% Lbm1      dB      float   (4.1.4)     Basic transmission loss: sub-model 1
% Lbm2      dB      float   (4.2.1)     Basic transmission loss: sub-model 2
% Lbm3      dB      float   (4.3.8)     Basic transmission loss: sub-model 3
% Lbm4      dB      float   (4.4.1)     Basic transmission loss: sub-model 4
% Lbs       dB      float   (E.16)      Troposactter basic transmission loss (note also eq.E.17)
% Ld        dB      float   (A.1.1)     Diffraction loss
% Ldba      dB      float   (A.4.9)     Bullington diffaction loss, actual path
% Ldbka     dB      float   (A.4.4)     Knife-edge diffraction loss for Bullington point: actual path
% Ldbks     dB      float   (A.5.4)     Knife-edge diffraction loss for Bullington point: smooth path
% Ldbs      dB      float   (A.5.9)     Bullington diffaction loss, smooth path
% Ldsph     dB      float   (A.2.5)     Spherical-earth diffraction loss
% Lp1r      dB      float   (G.2.7b)    Diffraction loss for 1-hop sporadic-E path at receiver
% Lp1t      dB      float   (G.2.7a)    Diffraction loss for 1-hop sporadic-E path at transmitter
% Lp2r      dB      float   (G.3.7b)    Diffraction loss for 2-hop sporadic-E path at receiver
% Lp2t      dB      float   (G.3.7a)    Diffraction loss for 2-hop sporadic-E path at transmitter
% Mses      m/km    float   (3.8.5)     Smooth surface slope
% N                 int     S.2.1       Number of profile points
% Nd1km50   N-units float   (3.4.1.1)   Refractivity gradient in first 1 km above surface not exceeded 50 % time
% Nd1kmp    N-units float   (3.4.1.2)   Refractivity gradient in first 1 km above surface not exceeded p % time
% Nd65m1    N-units float   S.3.4.2     Refractivity gradient in first 65 m above surface not exceeded 1 % time
% Nlr               int                 Profile index of receiver horizon point under median conditions
% Nlt               int                 Profile index of transmitter horizon point under median conditions
% Nsrima            int                 Profile index of receiver horizon point at p% time for actual path
% Nsrims            int                 Profile index of receiver horizon point at p% time for smooth path
% Nstima            int                 Profile index of transmitter horizon point at p% time for actual path
% Nstims            int                 Profile index of transmitter horizon point at p% time for smooth path
% Phi1qe    deg     float   G.3         Longitude at one-quarter of path length
% Phi1qn    deg     float   G.3         Latitude at one-quarter of path length
% Phi3qe    deg     float   G.3         Longitude at three-quarters of path length
% Phi3qn    deg     float   G.3         Latitude at three-quarters of path length
% Phicve    deg     float   S.3.9       Longitude at troposcatter common volume
% Phicvn    deg     float   S.3.9       Latitude at troposcatter common volume
% Phime     deg     float   S.3.2       Longitude at mid-point of path
% Phimn     deg     float   S.3.2       Latitude at mid-point of path
% Phircve   deg     float   S.3.9       Longitude of receiver-to-common-volume path segment mid point
% Phircvn   deg     float   S.3.9       Latitude of receiver-to-common-volume path segment mid point
% Phitcve   deg     float   S.3.9       Longitude of transmitter-to-common-volume path segment mid point
% Phitcvn   deg     float   S.3.9       Latitude of transmitter-to-common-volume path segment mid point
% Qoca      %       float   (B.2.5)     Notional clear-air zero-fade annual percentage time
% Reff50    km      float   (3.5.1)     Median effectve Earth radius (a-subscript-e)
% Reffp     km      float   (3.5.3a,b)  Effectve Earth radius  exceeded p% time, limited 1,000,000 km
% Sp        mrad    float   (3.3.3)     Positive path slope
% Thetae    rad     float   (3.5.4)     Path angular distance
% Thetar    mrad    float   (3.7.5b)    Receiver horizon angle relative to local horizontal under median conditions
% Thetarpos mrad    float   (3.7.11b)   Positive receiver horizon angle relative to local horizontal under median conditions
% Thetas    mrad    float   E.1         Tropospheric scatter angle
% Thetat    mrad    float   (3.7.5a)    Transmitter horizon angle relative to local horizontal under median conditions
% Thetatpos mrad    float   (3.7.11a)   Positive transmitter horizon angle relative to local horizontal under median conditions
% Tpcp      %       float   (3.1.1)     Percentage time Lb not exceeded used for calculation
% Tpcq      %       float   (3.1.2)     Percentage time Lb exceeded used for calculation
% Tpcscale          float               Utility dual-log scale for plotting temporal distribution, see examples in cols B and C below
% Wave      m       float   (3.6.1)     Wavelength
% Wvsurmid  g/m^3   float   F.2         Surface water-vapour content at path mid-point, see note 2 below
% Wvsurrx   g/m^3   float   F.3         Surface water-vapour content at receiver, see note 2 below
% Wvsurtx   g/m^3   float   F.3         Surface water-vapour content at transmitter, see note 2 below
% Ztropo            int     E           Troposcatter zone code
%
%
%   Example:
%   p2001 = tl_p2001(d, h, z, GHz, Tpc, Phire, Phirn, Phite, Phitn, Hrg, Htg, Grx, Gtx, FlagVP) 

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    19JUL16     Ivica Stevanovic, OFCOM         Initial version
%     v1    29MAY17     Ivica Stevanovic, OFCOM         Corrected a bug (typo) in dl_bull_smooth
%     v2    13JUN17     Ivica Stevanovic, OFCOM         Replaced load function calls to increase computational speed
%     v3    26APR18     Ivica Stevanovic, OFCOM         Declared empty arrays G and P for no-rain path and 
%                                                       included additional validation checks
%     v4    28OCT19     Ivica Stevanovic, OFCOM         Changes in angular distance dependent loss according to ITU-R P.2001-3
%                                                       (in tl_anomalous_reflection.m)
%     v5    13JUL21     Ivica Stevanovic, OFCOM         Changes in free-space loss according to ITU-R P.2001-4
%                                                       Renaming subfolder "src" into "private" which is automatically in the MATLAB search path
%                                                       (as suggested by K. Konstantinou, Ofcom UK)   
%     v6    20APR23     Ivica Stevanovic, OFCOM         introduced get_interp2 to increase computational speed


%%

% MATLAB Version 8.3.0.532 (R2014a) used in development of this code
%
% The Software is provided "AS IS" WITH NO WARRANTIES, EXPRESS OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO, THE WARRANTIES OF MERCHANTABILITY, FITNESS 
% FOR A PARTICULAR PURPOSE AND NON-INFRINGMENT OF INTELLECTUAL PROPERTY RIGHTS 
% 
% Neither the Software Copyright Holder (or its affiliates) nor the ITU 
% shall be held liable in any event for any damages whatsoever
% (including, without limitation, damages for loss of profits, business 
% interruption, loss of information, or any other pecuniary loss)
% arising out of or related to the use of or inability to use the Software.
%
% THE AUTHOR(S) AND OFCOM (CH) DO NOT PROVIDE ANY SUPPORT FOR THIS SOFTWARE
%
% This function calls other functions that are placed in the ./private folder



% Constants

c0 = 2.998e8;
Re = 6371;


% s = pwd;
% if ~exist('p838.m','file')
%     addpath([s '/src/'])
% end


%% 3.1 Limited percentage time

Tpcp = Tpc + 0.00001*(50-Tpc)/50;      % Eq (3.1.1)
Tpcq = 100 - Tpcp;                     % Eq (3.1.2)

% Ensure that vector d is ascending
if (~issorted(d))
    error('The array of path profile points d(i) must be in ascending order.');
end
% Ensure that d(1) = 0 (Tx position)
if d(1) > 0
    error (['The first path profile point d(1) = ' num2str(d(1)) ' must be zero.']);
end

% 3.2 Path length, intermediate points, and fraction over sea

dt = d(end);                        % Eq (3.2.1)

% make sure that there is enough points in the path profile 
if (length(d) <= 10)
    error('The number of points in path profile should be larger than 10');
end

if ~isempty(find(~(z==1 | z == 3 | z == 4 )))
    error ('The vector of zones z may contain only integers 1, 3, or 4.');
end

if ~(Tpc> 0 && Tpc <100)
   error ('The percentage of the average year Tpc must be in the range (0, 100)');
end

if (Htg <=0 || Hrg <= 0)
    error('The antenna heights above ground Htg and Hrg must be positive.');
end

if ~(FlagVP == 0 || FlagVP ==1)
    error('The polarization FlagVP can be either 0 (horizontal) or 1 (vertical).');
end

if dt < 0.1
    FlagShort = 1;
else
    FlagShort = 0;
end

% Calculate the longitude and latitude of the mid-point of the path, Phime,
% and Phimn for dpnt = 0.5dt

dpnt = 0.5*dt;
[Phime, Phimn, Bt2r, Dgc] = great_circle_path(Phire, Phite, Phirn, Phitn, Re, dpnt);

% Calculate the ground height in masl at the mid-point of the profile
% according to whether the number of profile points n is odd or even
% (3.2.2)

n = length(d);

if mod(n,2) == 1 %n is odd (3.2.2a)
    mp = 0.5*(n+1);
    Hmid = h(mp);
else             %n is even (3.2.2b) 
    mp = 0.5*n;
    Hmid = 0.5*(h(mp) + h(mp+1));
    
end

%Hmid = 2852.9;

% Set the fraction of the path over sea, omega, (radio meteorological code 1)

omega = path_fraction(d, z, 1);

if omega >= 0.75
    FlagSea = 1;
else
    FlagSea = 0;
end

%% 3.3 Antenna altitudes and path inclinations

% The Tx and Rx heights masl according to (3.3.1)

Hts = Htg + h(1);
Hrs = Hrg + h(end);
H1 = h(1);
Hn = h(end);

% Assign the higher and lower antenna heights above sea level (3.3.2)

Hhi = max(Hts, Hrs);
Hlo = min(Hts, Hrs);

% Calculate the positive value of path inclination (3.3.3)

Sp = (Hhi - Hlo)/dt;

%% 3.4 Climatic parameters
% 3.4.1 Refractivity in the lowest 1 km

% Find SdN from file DN_Median.txt for the path mid-pint at Phime (lon),
% Phimn (lat) - as a bilinear interpolation

SdN = get_interp2('DN_Median',Phime,Phimn);

% Obtain Nd1km50 as in (3.4.1.1)

Nd1km50 = -SdN;

% Find SdNsup from DN_SupSlope for the mid-point of the path

SdNsup = get_interp2('DN_SupSlope',Phime,Phimn);

% Find SdNsub from DN_SubSlope for the mid-point of the path

SdNsub = get_interp2('DN_SubSlope',Phime,Phimn);

% Obtain Nd1kmp as in (3.4.1.2)

if Tpcp < 50
    Nd1kmp = Nd1km50 + SdNsup*log10(0.02*Tpcp);
else
    Nd1kmp = Nd1km50 - SdNsub*log10(0.02*Tpcq);
end

% 3.4.2 Refractivity in the lowest 65 m
% Obtain Nd65m1 from file dndz_01.txt for the midpoint of the path

Nd65m1 = get_interp2('dndz_01',Phime,Phimn);

%% 3.5 Effective Earth-radius geometry
% Median effective Earth radius (3.5.1)

Reff50 = 157*Re/(157+Nd1km50);

% Effective Earth curvature (3.5.2)

Cp = (157 + Nd1kmp)/(157*Re);

% Effective Earth radius exceeded for p% time limited not to become
% infinite (3.5.3)

if (Cp > 1e-6)
    Reffp = 1/Cp;
else 
    Reffp = 1e6;
end

% The path length expressed as the angle subtended by d km at the center of
% a sphere of effective Earth radius (3.5.4)

Thetae = dt/Reff50; % radians

%% 3.6 Wavelength (3.6.1)

Wave = 1e-9*c0/GHz;

%% 3.7 Path classification and terminal horizon parameters
%  3.8 Effective heights and path roughness parameter

[Thetat, Thetar, Thetatpos, Thetarpos, Dlt, Dlr, Ilt, Ilr, Hstip, Hsrip, Hstipa, Hsripa, Htea, Hrea, Mses, Hm, Hst, Hsr, Htep, Hrep, FlagLos50] = smooth_earth_heights(d, h, Hts, Hrs, Reff50, Wave);

%% 3.9 Troposhperic-scatter path segments

[Dtcv, Drcv, Phicve, Phicvn, Hcv, Phitcve, Phitcvn, Phircve, Phircvn] = tropospheric_path(dt, Hts, Hrs, Thetae, Thetatpos, Thetarpos, Reff50, Phire, Phite, Phirn, Phitn, Re);

%% 3.10 Gaseous absorbtion on surface paths
% Use the method given in Attachment F, Sec. F.2 to calculate gaseous
% attenuations due to oxygen, and for water vapour under both non-rain and
% rain conditions for a surface path

[Aosur, Awsur, Awrsur, Gamo, Gamw, Gamwr, Wvsurmid] = gaseous_abs_surface(Phime, Phimn, Hmid, Hts, Hrs, dt, GHz);

Agsur =  Aosur + Awsur;                 % Eq (3.10.1)

%% Sub-model 1

% Calculate the diffraction loss not exceeded for p% time, as described in
% Attachment A

[Ld_pol, Ldsph_pol, Ldba, Ldbs, Ldbka, Ldbks, FlagLospa, FlagLosps] = dl_p(d, h, Hts, Hrs, Htep, Hrep, GHz, omega, Reffp, Cp);

Ld = Ld_pol(FlagVP + 1);
Ldsph = Ldsph_pol(FlagVP + 1);

% Use the method given in Attachemnt B.2 to calculate the notional
% clear-air zero-fade exceedance percentage time Q0ca

Q0ca = multi_path_activity(GHz, dt, Hts, Hrs, Dlt, Dlr, h(Ilt), h(Ilr), Hlo, Thetat, Thetar, Sp, Nd65m1, Phimn, FlagLos50);

% Perform the preliminary rain/wet-snow calculations in Attachment C.2
% with the following inputs (4.1.1)

phi_e = Phime;
phi_n = Phimn;
h_rainlo = Hlo;
h_rainhi = Hhi;
d_rain = dt;

[a, b, c, dr, Q0ra, Fwvr, kmod, alpha_mod, Gm, Pm, flagrain] = precipitation_fade_initial(GHz, Tpcq, phi_n, phi_e, h_rainlo, h_rainhi, d_rain, FlagVP );

% Calculate A1 using (4.1.2)

flagtropo = 0; % Normal propagation close to the surface of the Earth

A1 = Aiter(Tpcq, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);

% Calculate the sub-model 1 basic transmission loss not exceeded for p%
% time

% Lbfs = tl_free_space(GHz, dt);                              % Eq (3.11.1)
dfs = sqrt(dt^2 + ((Hts- Hrs)/1000)^2);
Lbfs = tl_free_space(GHz, dfs);                               % Eq (3.11.1)

Lbm1 = Lbfs + Ld + A1 + Fwvr*(Awrsur - Awsur) + Agsur;        % Eq (4.1.4)

%% Sub-model 2. Anomalous propagation

% Use the method given in Attachment D to calculate basic transmission loss
% not exceeded for p% time due to anomalous propagation Eq (4.2.1)

[Lba, Aat, Aad, Aac, Dct, Dcr, Dtm, Dlm] = tl_anomalous_reflection(GHz, d, z, Hts, Hrs, Htea, Hrea, Hm, Thetat, Thetar, Dlt, Dlr, Phimn, omega, Reff50, Tpcp, Tpcq);

Lbm2 = Lba + Agsur;

%% Sub-model 3. Troposcatter propagation

% Use the method given in Attachment E to calculate the troposcatter basic
% transmission loss Lbs as given by equation (E.17)

[Lbs, Thetas, Ztropo] = tl_troposcatter(GHz, dt, Thetat, Thetar, Thetae, Phicvn, Phicve, Phitn, Phite, Phirn, Phire, Gtx, Grx, Reff50, Tpcp);

% To avoid under-estimating troposcatter for short paths, limit Lbs (E.17)

Lbs = max(Lbs, Lbfs);

% Perform the preliminary rain/wet-snow calculations in Attachment C.2 from
% the transmitter to common-volume path segment with the following inputs (4.3.1)

phi_e = Phitcve;
phi_n = Phitcvn;
h_rainlo = Hts;
h_rainhi = Hcv;
d_rain = Dtcv;

[a, b, c, dr, Q0ra, Fwvrtx, kmod, alpha_mod, Gm, Pm, flagrain] = precipitation_fade_initial(GHz, Tpcq, phi_n, phi_e, h_rainlo, h_rainhi, d_rain, FlagVP );

% Calculate A1 using (4.1.2)

flagtropo = 1; % for troposcatter

A2t = Aiter(Tpcq, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);

% Perform the preliminary rain/wet-snow calculations in Attachment C.2 from
% the receiver to common-volume path segment with the following inputs (4.3.1)

phi_e = Phircve;
phi_n = Phircvn;
h_rainlo = Hrs;
h_rainhi = Hcv;
d_rain = Drcv;

[a, b, c, dr, Q0ra, Fwvrrx, kmod, alpha_mod, Gm, Pm, flagrain] = precipitation_fade_initial(GHz, Tpcq, phi_n, phi_e, h_rainlo, h_rainhi, d_rain, FlagVP );

% Calculate A1 using (4.1.2)

flagtropo = 1; % for troposcatter

A2r = Aiter(Tpcq, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);

A2 = (A2t * (1 + 0.018 * Dtcv ) + A2r * (1 + 0.018 * Drcv))/(1 + 0.018*dt);  % Eq (4.3.6)

% Use the method given in Attachment F.3 to calculate gaseous attenuations
% due to oxygen and for water vapour under both non-rain and rain
% conditions for a troposcatter path (4.3.7)

[Aos, Aws, Awrs, Aotcv, Awtcv, Awrtcv, Aorcv, Awrcv, Awrrcv, Wvsurtx, Wvsurrx] = gaseous_abs_tropo(Phite, Phitn, Phire, Phirn, h(1), h(end), Thetatpos, Thetarpos,  Dtcv, Drcv,  GHz);

% Total gaseous attenuation under non-rain conditions is given by (4.3.7)

Ags = Aos + Aws;

%% Sub-model 3 basic transmission loss (4.3.8)

Lbm3 = Lbs + A2 + 0.5*(Fwvrtx + Fwvrrx)*(Awrs - Aws) + Ags;

%% 4.4 Sub-model 4. Sporadic - E

[Lbm4, Lbes1, Lbes2, Lp1t, Lp2t, Lp1r, Lp2r, Gam1, Gam2, Foes1, Foes2, Phi1qe, Phi1qn, Phi3qe, Phi3qn] = tl_sporadic_e(GHz, dt, Thetat, Thetar, Phimn, Phime, Phitn, Phite, Phirn, Phire, Dlt, Dlr, Reff50, Re, Tpcp);

%% 5 Combining sub-model results

% 5.1 Combining sub-models 1 and 2

Lm = min(Lbm1, Lbm2);

Lbm12 = Lm - 10 * log10( 10^(-0.1*(Lbm1-Lm)) + 10^(-0.1*(Lbm2-Lm) ) );

% 5.2  Combining sub-models 1+2, 3, and 4

Lm = min([Lbm12, Lbm3, Lbm4]);

Lb = Lm - 5 * log10( 10^(-0.2*(Lbm12-Lm)) + 10^(-0.2*(Lbm3-Lm)) + 10^(-0.2*(Lbm4-Lm)) );


% arrange outputs in struct variable p2001

p2001.FlagLos50 =    FlagLos50;
p2001.FlagLospa =    FlagLospa;
p2001.FlagLosps =    FlagLosps;
p2001.FlagSea   =    FlagSea;
p2001.FlagShort =    FlagShort;
p2001.A1        =    A1;
p2001.A2        =    A2;
p2001.A2r       =    A2r;
p2001.A2t       =    A2t;
p2001.Aac       =    Aac;
p2001.Aad       =    Aad;
p2001.Aat       =    Aat;
p2001.Ags       =    Ags;
p2001.Agsur     =    Agsur;
p2001.Aorcv     =    Aorcv;
p2001.Aos       =    Aos;
p2001.Aosur     =    Aosur;
p2001.Aotcv     =    Aotcv;
p2001.Awrcv     =    Awrcv;
p2001.Awrrcv    =    Awrrcv;
p2001.Awrs      =    Awrs;
p2001.Awrsur    =    Awrsur;
p2001.Awrtcv    =    Awrtcv;
p2001.Aws       =    Aws;
p2001.Awsur     =    Awsur;
p2001.Awtcv     =    Awtcv;
p2001.Bt2rDeg   =    Bt2r;
p2001.Cp        =    Cp;
p2001.D         =    dt;
p2001.Dcr       =    Dcr;
p2001.Dct       =    Dct;
p2001.Dgc       =    Dgc;
p2001.Dlm       =    Dlm;
p2001.Dlr       =    Dlr;
p2001.Dlt       =    Dlt;
p2001.Drcv      =    Drcv;
p2001.Dtcv      =    Dtcv;
p2001.Dtm       =    Dtm;
p2001.Foes1     =    Foes1;
p2001.Foes2     =    Foes2;
p2001.Fsea      =    omega;
p2001.Fwvr      =    Fwvr;
p2001.Fwvrr     =    Fwvrrx;
p2001.Fwvrt     =    Fwvrtx;
p2001.Gam1      =    Gam1;
p2001.Gam2      =    Gam2;
p2001.Gamo      =    Gamo;
p2001.Gamw      =    Gamw;
p2001.Gamwr     =    Gamwr;
p2001.H1        =    H1;
p2001.Hcv       =    Hcv;
p2001.Hhi       =    Hhi;
p2001.Hlo       =    Hlo;
p2001.Hm        =    Hm;
p2001.Hmid      =    Hmid;
p2001.Hn        =    Hn;
p2001.Hrea      =    Hrea;
p2001.Hrep      =    Hrep;
p2001.Hrs       =    Hrs;
p2001.Hsrip     =    Hsrip;
p2001.Hsripa    =    Hsripa;
p2001.Hstip     =    Hstip;
p2001.Hstipa    =    Hstipa;
p2001.Htea      =    Htea;
p2001.Htep      =    Htep;
p2001.Hts       =    Hts;
p2001.Lb        =    Lb;
p2001.Lba       =    Lba;
p2001.Lbes1     =    Lbes1;
p2001.Lbes2     =    Lbes2;
p2001.Lbfs      =    Lbfs;
p2001.Lbm1      =    Lbm1;
p2001.Lbm2      =    Lbm2;
p2001.Lbm3      =    Lbm3;
p2001.Lbm4      =    Lbm4;
p2001.Lbs       =    Lbs;
p2001.Ld        =    Ld;
p2001.Ldba      =    Ldba;
p2001.Ldbka     =    Ldbka;
p2001.Ldbks     =    Ldbks;
p2001.Ldbs      =    Ldbs;
p2001.Ldsph     =    Ldsph;
p2001.Lp1r      =    Lp1r;
p2001.Lp1t      =    Lp1t;
p2001.Lp2r      =    Lp2r;
p2001.Lp2t      =    Lp2t;
p2001.Mses      =    Mses;
p2001.N         =    length(d);
p2001.Nd1km50   =    Nd1km50;
p2001.Nd1kmp    =    Nd1kmp;
p2001.Nd65m1    =    Nd65m1;
p2001.Nlr       =    Ilr;
p2001.Nlt       =    Ilt;
p2001.Nsrima    =    '';
p2001.Nsrims    =    '';
p2001.Nstima    =    '';
p2001.Nstims    =    '';
p2001.Phi1qe    =    Phi1qe;
p2001.Phi1qn    =    Phi1qn;
p2001.Phi3qe    =    Phi3qe;
p2001.Phi3qn    =    Phi3qn;
p2001.Phicve    =    Phicve;
p2001.Phicvn    =    Phicvn;
p2001.Phime     =    Phime;
p2001.Phimn     =    Phimn;
p2001.Phircve   =    Phircve;
p2001.Phircvn   =    Phircvn;
p2001.Phitcve   =    Phitcve;
p2001.Phitcvn   =    Phitcvn;
p2001.Q0ca      =    Q0ca;
p2001.Reff50    =    Reff50;
p2001.Reffp     =    Reffp;
p2001.Sp        =    Sp;
p2001.Thetae    =    Thetae;
p2001.Thetar    =    Thetar;
p2001.Thetarpos =    Thetarpos;
p2001.Thetas    =    Thetas;
p2001.Thetat    =    Thetat;
p2001.Thetatpos =    Thetatpos;
p2001.Tpcp      =    Tpcp;
p2001.Tpcq      =    Tpcq;
p2001.Tpcscale  =    log10(Tpcp/(100-Tpcp));
p2001.Wave      =    Wave;
p2001.Wvsurmid  =    Wvsurmid;
p2001.Wvsurrx   =    Wvsurrx;
p2001.Wvsurtx   =    Wvsurtx;
p2001.Ztropo    =    Ztropo;


return
