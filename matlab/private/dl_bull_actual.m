function [Ldba, Ldbka, FlagLospa] = dl_bull_actual(d, h, hts, hrs, Cp, f)
%dl_bull_actual Bullington part of the diffraction loss according to P.2001-2
%   This function computes the Bullington part of the diffraction loss
%   as defined in ITU-R P.2001-2 in Attachment A.4 (for the smooth profile)
%
%     Input parameters:
%     d       -   Vector of distances di of the i-th profile point (km)
%     h       -   Vector of heights hi of the i-th profile point (meters
%                 above mean sea level)  
%                 Both vectors d and h contain n+1 profile points
%     hts     -   Effective transmitter antenna height in meters above sea level (i=0)
%     hrs     -   Effective receiver antenna height in meters above sea level (i=n)
%     Cp      -   Effective Earth curvature
%     f       -   Frequency (GHz)
%
%     Output parameters:
%     Ldba   -   Bullington diffraction loss for a given actual path
%     Ldbka  -   Knife-edge diffraction loss for Bullington point: actual path
%     FlagLospa - 1 = LoS p% time for actual path, 0 = otherwise
%
%     Example:
%     [Ldba, Ldbka, FlagLospa] = dl_bull_actual(d, h, hts, hrs, Cp, f)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    23DEC15     Ivica Stevanovic, OFCOM         First implementation for P.452-16
%     v1    06JUL16     Ivica Stevanovic, OFCOM         First implementation for P.1812-4
%     v2    13JUL16     Ivica Stevanovic, OFCOM         First implementation for P.2001-2



% Wavelength
c = 2.998e8;
lam = 1e-9*c/f;

% Complete path length

dtot = d(end)-d(1);

% Find the intermediate profile point with the highest slope of the line
% from the transmitter to the point

di = d(2:end-1);
hi = h(2:end-1);

Stim = max((hi + 500*Cp*di.*(dtot - di) - hts)./di );           % Eq (A.4.1)

% Calculate the slope of the line from transmitter to receiver assuming a
% LoS path

Str = (hrs - hts)/dtot;                                         % Eq (A.4.2)

if Stim < Str % Case 1, Path is LoS
    FlagLospa = 1;
    
    % Find the intermediate profile point with the highest diffraction
    % parameter nu:
    
    numax = max (...
                  ( hi + 500*Cp*di.*(dtot - di) - ( hts*(dtot - di) + hrs*di)/dtot ) .* ...
                   sqrt(0.002*dtot./(lam*di.*(dtot-di))) ...   
                 );                                             % Eq (A.4.3)
              
    Ldbka = dl_knife_edge(numax);                               % Eq (A.4.4)
else
    FlagLospa = 0;
    % Path is NLOS
    
    % Find the intermediate profile point with the highest slope of the
    % line from the receiver to the point
    
    Srim = max((hi + 500*Cp*di.*(dtot-di)-hrs)./(dtot-di));     % Eq (A.4.5)
    
    % Calculate the distance of the Bullington point from the transmitter:
    
    dbp = (hrs - hts + Srim*dtot)/(Stim + Srim);                % Eq (A.4.6)
    
    % Calculate the diffraction parameter, nub, for the Bullington point
    
    nub =  ( hts + Stim*dbp - ( hts*(dtot - dbp) + hrs*dbp)/dtot ) * ...
                   sqrt(0.002*dtot/(lam*dbp*(dtot-dbp)));       % Eq (A.4.7)
    
    % The knife-edge loss for the Bullington point is given by
              
    Ldbka = dl_knife_edge(nub);                                 % Eq (A.4.8)
    
end

% For Luc calculated using either (A.4.4) or (A.4.8), Bullington diffraction loss
% for the path is given by

Ldba = Ldbka + (1 - exp(-Ldbka/6.0))*(10+0.02*dtot);            % Eq (A.4.9)
return
end
