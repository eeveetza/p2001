function [gamma_o, gamma_w] = specific_sea_level_attenuation(f, rho_sur, h_sur)
%specific_sea_level_attenuation Specific sea-level attenuations (Attachment F.6)
%   This function computes specific sea-level attenuations due to oxigen
%   and water-vapour as defined in ITU-R P.2001-2 Attachment F.6
%   The formulas are valid for frequencies not greater than 54 GHz.
%
%     Input parameters:
%     f       -   Frequency (GHz), not greater than 54 GHz
%     rho_sur -   Surface water-vapour density under non-rain conditions (g/m^3)
%     h_sur   -   Terrain height (masl)
%
%     Output parameters:
%     gamma_o -   Sea-level specific attenuation due to oxigen (dB/km)
%     gamma_w -   Sea-level specific attenuation due to water vapour (dB/km)

%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version

rho_sea = rho_sur* exp(h_sur/2000);      % Eq (F.6.2b)

eta = 0.955 + 0.006*rho_sea;             % Eq (F.6.2a)

gamma_o = ( 7.2/(f^2 + 0.34) + 0.62/( (54-f)^1.16  + 0.83 ) ) * f^2 *1e-3;    % Eq (F.6.1) 

gamma_w =  ( 0.046 + 0.0019*rho_sea + 3.98*eta/( (f-22.235)^2 + 9.42 *eta^2 ) * (1 + ( (f-22)/(f+22) )^2  ) ) * f^2 * rho_sea * 1e-4;    %Eq (F.6.2)
return
end
