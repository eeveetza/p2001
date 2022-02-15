function [Ao, Aw, Awr, gamma_o, gamma_w, gamma_wr] = gaseous_abs_tropo_t2cv(rho_sur, h_sur, theta_el, dcv, f)
%gaseous_abs_tropo_t2cv Gaseous absorbtion for tropospheric terminal-common-volume path
%   This function computes gaseous absorbtion for termina/common-volume
%   troposcatter path as defined in ITU-R P.2001-2 Attachment F.4
%
%   Input parameters:
%   rho_sur   -   Surface water-vapour density under non rain conditions (g/m^3)
%   h_sur     -   terrain height (masl)
%   theta_el  -   elevation angle of path (mrad)
%   dcv       -   Horizontal distance to the comon volume (km)
%   f         -   Frequency (GHz), not greater than 54 GHz
%     
%   Output parameters:
%   Ao       -   Attenuation due to oxygen (dB)
%   Aw       -   Attenuation due to water-vapour under non-rain conditions (dB)
%   Awr      -   Attenuation due to water-vapour under rain conditions (dB)
%   gamma_o  -   Specific attenuation due to oxygen (dB/km)
%   gamma_w  -   Specific attenuation due to water-vapour non-rain conditions (dB/km)
%   gamma_wr -   Specific attenuation due to water-vapour rain conditions (dB/km)
%
%   Example:
%   [Ao, Aw, Awr, gamma_o, gamma_w, gamma_wr] = gaseous_abs_tropo_t2cv(rho_sur, h_sur, theta_el, dcv, f)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    18JUL16     Ivica Stevanovic, OFCOM         Initial version
%     v1    13JUN17     Ivica Stevanovic, OFCOM         Octave compatibility (do -> d0)

% Use equation (F.6.2) to calculate the sea-level specific attenuation due
% to water vapour under non-rain conditions gamma_w

[gamma_o, gamma_w] = specific_sea_level_attenuation(f, rho_sur, h_sur);


% Use equation (F.5.1) to calculate the surface water-vapour density under
% rain conditions rho_surr

rho_surr = water_vapour_density_rain(rho_sur, h_sur);

% Use equation (F.6.2) to calculate the sea-level specifica ttenuation due
% to water vapour undr rain conditions gamma_wr

[~, gamma_wr] = specific_sea_level_attenuation(f, rho_surr, h_sur);

% Calculate the quantities do and dw for oxygen and water vapour (F.4.1)

d0 = 0.65*sin(0.001*theta_el) + 0.35 * sqrt((sin(0.001*theta_el))^2 + 0.00304);
d0 = 5/d0;

dw = 0.65*sin(0.001*theta_el) + 0.35 * sqrt((sin(0.001*theta_el))^2 + 0.00122);
dw = 2/dw;

% Effective distances for oxygen and water vapour (F.4.2)

deo = d0 * (1-exp(-dcv/d0)) * exp(-h_sur/5000);


dew = dw * (1-exp(-dcv/dw)) * exp(-h_sur/2000);

% Attenuations due to oxygen, and for water vapour for both non-rain and
% rain conditions (F.4.3)

Ao = gamma_o * deo;

Aw = gamma_w * dew;

Awr = gamma_wr * dew;


return
end
