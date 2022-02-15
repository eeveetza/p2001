function [Lbs, theta, climzone] = tl_troposcatter(f, dt, thetat, thetar, thetae, phicvn, phicve, phitn, phite, phirn, phire, Gt, Gr, ae, p)
%tl_troposcatter Troposcatter basic transmission loss
%   This function computes the troposcatter basic transmission loss
%   as defined in ITU-R P.2001-2 (Attachment E)
%
%     Input parameters:
%     f       -   Frequency GHz
%     dt      -   Total distance (km)
%     thetat  -   Tx horizon elevation angle relative to the local horizontal (mrad)
%     thetar  -   Rx horizon elevation angle relative to the local horizontal (mrad)
%     thetae  -   Angle subtended by d km at centre of spherical Earth (rad)
%     phicvn  -   Troposcatter common volume latitude (deg)
%     phicve  -   Troposcatter common volume longitude (deg)
%     phitn   -   Tx latitude (deg)
%     phite   -   Tx longitude (deg)
%     phirn   -   Rx latitude (deg)
%     phire   -   Rx longitude (deg)
%     Gt, Gr  -   Gain of transmitting and receiving antenna in the azimuthal direction
%                 of the path towards the other antenna and at the elevation angle
%                 above the local horizontal of the other antenna in the case of a LoS
%                 path, otherwise of the antenna's radio horizon, for median effective
%                 Earth radius.
%     ae      -   Effective Earth radius (km)
%     p       -   Percentage of average year for which predicted basic loss
%                 is not exceeded (%)
%
%     Output parameters:
%     Lbs    -   Troposcatter basic transmission loss (dB)
%     theta  -   Scatter angle (mrad)
%     climzone-  Climate zone (0,1,2,3,4,5,6)
%
%     Example:
%     [Lbs, theta, climzone] = tl_troposcatter(f, dt, thetat, thetar, thetae, phicvn, phicve, phitn, phite, phirn, phire, Gt, Gr, ae, p)

%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    18JUL16     Ivica Stevanovic, OFCOM         Initial version
%     v1    13JUN17     Ivica Stevanovic, OFCOM         replaced load function calls to increase computational speed
%     v2    11AUG17     Ivica Stevanovic, OFCOM         introduced a correction in TropoClim vector indices to cover the case 
%                                                       when the point is equally spaced from the two closest grid points



% Attachment E: Troposcatter

%% E.2 Climatic classification

latcnt = 89.75:-0.5:-89.75;           %Table 2.4.1
loncnt = -179.75: 0.5: 179.75;        %Table 2.4.1

% Obtain TropoClim for phicvn, phicve from the data file "TropoClim.txt"

%TropoClim = load('DigitalMaps/TropoClim.txt');
TropoClim = DigitalMaps_TropoClim();

% The value at the closest grid point to phicvn, phicve should be taken

knorth = find (abs(phicvn - latcnt) == min(abs(phicvn-latcnt)));
keast = find (abs(phicve - loncnt) == min(abs(phicve-loncnt)));

climzone = TropoClim(knorth(1), keast(1));

% In case the troposcatter common volume lies over the sea the climates at
% both the transmitter and receiver locations should be determined

if climzone == 0
    
    knorth = find (abs(phirn - latcnt) == min(abs(phirn-latcnt)));
    keast = find (abs(phire - loncnt) == min(abs(phire-loncnt)));

    climzoner = TropoClim(knorth(1), keast(1));
    
    knorth = find (abs(phitn - latcnt) == min(abs(phitn-latcnt)));
    keast = find (abs(phite - loncnt) == min(abs(phite-loncnt)));
    
    climzonet = TropoClim(knorth(1), keast(1));
    
    % if both terminals have a climate zone corresponding to a land point,
    % the climate zone of the path is given by the smaller value of the
    % transmitter and receiver climate zones
    
    if (climzoner > 0 && climzonet > 0)
        climzone = min(climzoner, climzonet);
        
        % if only one terminal has a climate zone corresponding to a land
        % point, then that climate zone defines the climate zone of the path
        
    elseif (climzonet > 0)
        climzone = climzonet;
        
    elseif (climzoner > 0)
        climzone = climzoner;
        
    end
    
end

clear TropoClim

% From Table E.1 assign meteorological and atmospheric parameters M,
% gamma and equation

if climzone == 1
    M = 129.6;
    gamma = 0.33;
    eq = 8;
    
elseif (climzone == 2)
    M = 119.73;
    gamma = 0.27;
    eq = 6;
    
elseif (climzone == 3)
    M = 109.3;
    gamma = 0.32;
    eq = 9;
    
elseif (climzone == 4)
    M = 128.5;
    gamma = 0.27;
    eq = 10;
    
elseif (climzone == 5)
    M = 119.73;
    gamma = 0.27;
    eq = 6;
    
elseif (climzone == 6)
    M = 123.2;
    gamma = 0.27;
    eq = 6;
    
else % climzone == 0
    M = 116;
    gamma = 0.27;
    eq = 7;
end


%% E.3 Calculation of tropocscatter basic transmission loss

% The scatter angle (E.1)

theta = 1000* thetae + thetat + thetar; % mrad

% The loss term dependent on the common vaolume height

H = 0.25e-3 * theta * dt;                                                 % Eq (E.3)

htrop = 0.125e-6 * theta^2 * ae;                                          % Eq (E.4)

LN = 20*log10(5 + gamma * H) + 4.34 * gamma * htrop;                      % Eq (E.2)

% Angular distance of the scatter path based on median effective Earth
% radius

ds = 0.001 * theta * ae;                                                  % Eq (E.5)

% Calculate Y90 (dB) using one od equations (E.6)-(E.10) as selected from
% table E.1

if (eq == 6)
    
    Y90 = -2.2 - ( 8.1 - 0.23 * min(f,4) )* exp(-0.137 * htrop);          % Eq (E.6)
    
elseif (eq == 7)
    
    Y90 = -9.5 - 3 * exp(-0.137 * htrop);                                 % Eq (E.7)
    
elseif (eq == 8)
    
    if ds < 100
        Y90 = -8.2;
        
    elseif (ds >= 1000)
        Y90 = -3.4;
        
    else
        Y90 = 1.006e-8 * ds^3 - 2.569e-5 * ds^2 + 0.02242 * ds - 10.2;    % Eq (E.8)
    end
    
elseif (eq == 9)
    
    if ds < 100
        Y90 = -10.845;
        
    elseif (ds >= 465)
        Y90 = -8.4;
        
    else
        Y90 = -4.5e-7 * ds^3 + 4.45e-4 * ds^2 - 0.122 * ds - 2.645;       % Eq (E.9)
        
    end
    
elseif (eq == 10)
    
    if ds < 100
        Y90 = -11.5;
        
    elseif (ds >= 550)
        Y90 = -4;
        
    else
        Y90 = -8.519e-8 * ds^3 + 7.444e-5 * ds^2 - 4.18e-4 * ds - 12.1;   % Eq (E.10)
        
    end
    
end

% Conversion factor given by (E.11)

if p >= 50
    
    C = 1.26 * (-log10( (100-p)/50 ) )^0.63;
    
else
    C = -1.26 * (-log10( p/50 ) )^0.63;
    
end

% Parameter Yp not exceeded for p% time (E.12)

Yp = C * Y90;

% Limit the value of theta such that theta >= 1e-6

if theta < 1e-6
    theta = 1e-6;
end

% Distance and frequency dependent losses (E.13) and (E.14)

Ldist = max( 10*log10(dt) + 30*log10(theta) + LN, 20*log10(dt) + 0.573*theta + 20 );

Lfreq = 25*log10(f) - 2.5 * (log10(0.5*f))^2;

% Aperture-to-medium copuling loss (E.15)

Lcoup = 0.07 * exp(0.055 * (Gt + Gr));

% Troposcatter basic transmission loss not exceeded for p% time (E.16)

Lbs = M + Lfreq + Ldist + Lcoup - Yp;


return
end