function [Aosur, Awsur, Awrsur, gamma_o, gamma_w, gamma_wr, rho_sur] = gaseous_abs_surface(phi_me, phi_mn, h_mid, hts, hrs, dt, f)
%specific_sea_level_attenuation Specific sea-level attenuations (Attachment F.6)
%   This function computes specific sea-level attenuations due to oxigen
%   and water-vapour as defined in ITU-R P.2001-2 Attachment F.6
%   The formulas are valid for frequencies not greater than 54 GHz.
%
%   Input parameters:
%   phi_me    -   Longitude of the mid-point of the path (deg)
%   phi_mn    -   Latitude of the mid-point of the path (deg)
%   h_mid     -   Ground height at the mid-point of the profile (masl)
%   hts, hrs  -   Tx and Rx antenna heights above means sea level (m)
%                 hts = htg + h(1), hrs = hrg + h(end)
%   f         -   Frequency (GHz), not greater than 54 GHz
%     
%   Output parameters:
%   Aosur     -   Attenuation due to oxygen (dB)
%   Awsur     -   Attenuation due to water-vapour under non-rain conditions (dB)
%   Awrsur    -   Attenuation due to water-vapour under rain conditions (dB)
%   gamma_o  -   Specific attenuation due to oxygen (dB/km)
%   gamma_w  -   Specific attenuation due to water-vapour non-rain conditions (dB/km)
%   gamma_wr -   Specific attenuation due to water-vapour rain conditions (dB/km)
%   rho_sur  -   Surface water-vapour content (g/m^3)

%
%   Example:
%   [Aosur, Awsur, Awrsur, gamma_o, gamma_w, gamma_wr, rho_sur] = gaseous_abs_surface(phi_me, phi_mn, h_mid, hts, hrs, dt, f)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version
%     v1    13JUN17     Ivica Stevanovic, OFCOM         replaced load function calls to increase computational speed
%     v2    20APR23     Ivica Stevanovic, OFCOM         introduced get_interp2 to increase computational speed

% Obtain surface water-vapour density under non-rain conditions at the
% midpoint of the path from the data file surfwv_50_fixed.txt

% Find rho_sur from file surfwv_50_fixed.txt for the path mid-pint at phi_me (lon),
% phi_mn (lat) - as a bilinear interpolation

rho_sur = get_interp2('surfwv',phi_me,phi_mn);

h_sur = h_mid;

% Use equation (F.6.2) to calculate the sea-level specific attenuation due
% to water vapour under non-rain conditions gamma_w

[gamma_o, gamma_w] = specific_sea_level_attenuation(f, rho_sur, h_sur);

% Use equation (F.5.1) to calculate the surface water-vapour density under
% rain conditions rho_surr

rho_surr = water_vapour_density_rain(rho_sur, h_sur);

% Use equation (F.6.2) to calculate the sea-level specifica ttenuation due
% to water vapour undr rain conditions gamma_wr

[~, gamma_wr] = specific_sea_level_attenuation(f, rho_surr, h_sur);

% Calculate the height for water-vapour density (F.2.1)

h_rho = 0.5*(hts + hrs);

% Attenuation due to oxygen (F.2.2a)

Aosur = gamma_o * dt * exp(-h_rho/5000);

% Attenuation due to water-vapour under non-rain conditions (F.2.2b)

Awsur = gamma_w * dt * exp(-h_rho/2000);

% Attenuation due to water-vapour under non-rain conditions (F.2.2b)

Awrsur = gamma_wr * dt * exp(-h_rho/2000);

return
end
