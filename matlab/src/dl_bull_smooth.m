function [Ldbs, Ldbks, FlagLosps] = dl_bull_smooth(d, h, htep, hrep, ap, f)
%dl_bull_smooth Bullington part of the diffraction loss according to P.2001-2
%   This function computes the Bullington part of the diffraction loss
%   as defined in ITU-R P.2001-2 in Attachment A.5 (for a notional smooth profile)
%
%     Input parameters:
%     d       -   Vector of distances di of the i-th profile point (km)
%     h       -   Vector of heights hi of the i-th profile point (meters
%                 above mean sea level)  
%                 Both vectors d and h contain n+1 profile points
%     htep     -   Effective transmitter antenna height in meters above sea level (i=0)
%     hrep     -   Effective receiver antenna height in meters above sea level (i=n)
%     ap      -   Effective earth radius in kilometers
%     f       -   frequency expressed in GHz
%
%     Output parameters:
%     Ldbs   -   Bullington diffraction loss for a given smooth path
%     Ldbks  -   Knife-edge diffraction loss for Bullington point: smooth path
%     FlagLosps - 1 = LoS p% time for smooth path, 0 = otherwise

%     Example:
%     [Ldbs, Ldbks] = dl_bull_smooth(d, h, htep, hrep, ap, f)
%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    23DEC15     Ivica Stevanovic, OFCOM         First implementation for P.452-16
%     v1    06JUL16     Ivica Stevanovic, OFCOM         First implementation for P.1812-4
%     v2    13JUL16     Ivica Stevanovic, OFCOM         First implementation for P.2001-2
%     v3    29MAY17     Ivica Stevanovic, OFCOM         bug Jdbsk -> Ldbsk for NLOS path 
%                                                       as pointed out by Michael Rohner



% Wavelength
c = 2.998e8;
lam = 1e-9*c/f;

% Complete path length

dtot = d(end)-d(1);

% Find the intermediate profile point with the highest slope of the line
% from the transmitter to the point

di = d(2:end-1);
hi = h(2:end-1);

Stim = max( 500*(dtot - di)/ap - htep./di );           % Eq (A.5.1)

% Calculate the slope of the line from transmitter to receiver assuming a
% LoS path

Str = (hrep - htep)/dtot;                                         % Eq (A.5.2)

if Stim < Str % Case 1, Path is LoS
    FlagLosps = 1;
    % Find the intermediate profile point with the highest diffraction
    % parameter nu:
    
    numax = max (...
                  ( 500*di.*(dtot - di)/ap - ( htep*(dtot - di) + hrep*di)/dtot ) .* ...
                   sqrt(0.002*dtot./(lam*di.*(dtot-di))) ...   
                 );                                             % Eq (A.5.3)
              
    Ldbks = dl_knife_edge(numax);                               % Eq (A.5.4)
else
    FlagLosps = 0;
    % Path is NLOS
    
    % Find the intermediate profile point with the highest slope of the
    % line from the receiver to the point
    
    Srim = max(500*di/ap - hrep./(dtot-di));     % Eq (A.5.5)
    
    % Calculate the distance of the Bullington point from the transmitter:
    
    dbp = (hrep - htep + Srim*dtot)/(Stim + Srim);                % Eq (A.5.6)
    
    % Calculate the diffraction parameter, nub, for the Bullington point
    
    nub =  ( htep + Stim*dbp - ( htep*(dtot - dbp) + hrep*dbp)/dtot ) * ...
                   sqrt(0.002*dtot/(lam*dbp*(dtot-dbp)));       % Eq (A.5.7)
    
    % The knife-edge loss for the Bullington point is given by
              
    Ldbks = dl_knife_edge(nub);                                 % Eq (A.5.8)
    
end

% For Ldbs calculated using either (A.5.4) or (A.5.8), Bullington diffraction loss
% for the path is given by

Ldbs = Ldbks + (1 - exp(-Ldbks/6.0))*(10+0.02*dtot);            % Eq (A.5.9)
return
end
