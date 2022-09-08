function [Aos, Aws, Awrs, Aotcv, Awtcv, Awrtcv, Aorcv, Awrcv, Awrrcv, Wvsurtx, Wvsurrx] = gaseous_abs_tropo(phi_te, phi_tn, phi_re, phi_rn, h1, hn, thetatpos, thetarpos,  dtcv, drcv,  f)
%gaseous_abs_tropo Gaseous absorbtion for a troposcatter path
%   This function computes gaseous absorbtion for a complete troposcater
%   path, from Tx to Rx via the common scattering volume
%   and water-vapour as defined in ITU-R P.2001-2 Attachment F.3
%   The formulas are valid for frequencies not greater than 54 GHz.
%
%   Input parameters:
%   phi_te    -   Tx Longitude (deg)
%   phi_tn    -   Tx Latitude  (deg)
%   phi_re    -   Rx Longitude (deg)
%   phi_rn    -   Rx Latitude  (deg)
%   h1        -   Ground height at the transmitter point of the profile (masl)
%   hn        -   Ground height at the receiver point of the profile (masl)
%   thetatpos -   Horizon elevation angle relative to the local horizontal
%                 as viewed from Tx (limited to be positive) (mrad)
%   thetarpos -   Horizon elevation angle relative to the local horizontal
%                 as viewed from Rx (limited to be positive) (mrad)
%   dtcv      -   Tx terminal to troposcatter common volume distance
%   drcv      -   Rx terminal to troposcatter common volume distance
%   f         -   Frequency (GHz), not greater than 54 GHz
%     
%   Output parameters:
%   Aos       -   Attenuation due to oxygen for the complete troposcatter path (dB)
%   Aws       -   Attenuation due to water-vapour under non-rain conditions for the complete path(dB)
%   Awrs      -   Attenuation due to water-vapour under rain conditions for the complete path(dB)
%   Aotcv     -   Attenuation due to oxygen for the Tx-cv path (dB)
%   Awtcv     -   Attenuation due to water-vapour under non-rain conditions for the Tx-cv path(dB)
%   Awrtcv    -   Attenuation due to water-vapour under rain conditions for the Tx-cv path(dB)%
%   Aorcv     -   Attenuation due to oxygen for the Rx-cv path (dB)
%   Awrcv     -   Attenuation due to water-vapour under non-rain conditions for the Rx-cv path(dB)
%   Awrrcv    -   Attenuation due to water-vapour under rain conditions for the Rx-cv path(dB)%
%   Wvsurtx   -   Surface water-vapour density under non-rain conditions at the Tx (g/m^3)
%   Wvsurrx   -   Surface water-vapour density under non-rain conditions at the Rx (g/m^3)

%   Example:
%   [Aos, Aws, Awrs, Aotcv, Awtcv, Awrtcv, Aorcv, Awrcv, Awrrcv, Wvsurtx, Wvsurrx] = gaseous_abs_tropo(phi_te, phi_tn, phir_re, phi_rn, h1, hn, thetatpos, thetarpos,  dtcv, drcv,  f)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    18JUL16     Ivica Stevanovic, OFCOM         Initial version
%     v1    13JUN17     Ivica Stevanovic, OFCOM         replaced load function calls to increase computational speed
%     v2    20APR23     Ivica Stevanovic, OFCOM         introduced get_interp2 to increase computational speed

% Obtain surface water-vapour density under non-rain conditions at the
% location of Tx from the data file surfwv_50_fixed.txt

% Find rho_sur from file surfwv_50_fixed.txt as a bilinear interpolation

rho_sur = get_interp2('surfwv',phi_te,phi_tn);

Wvsurtx = rho_sur;


% Use the method in Attachment F.4 to get the gaseous attenuations due to
% oxygen and for water vapour under both non-rain and rain conditions for
% the Tx-cv path (F.3.1)
h_sur = h1;
theta_el = thetatpos;
dcv = dtcv;

[Aotcv, Awtcv, Awrtcv] = gaseous_abs_tropo_t2cv(rho_sur, h_sur, theta_el, dcv, f);

% Obtain surface water-vapour density under non-rain conditions at the
% location of Rx from the data file surfwv_50_fixed.txt

% Find rho_sur from file surfwv_50_fixed.txt as a bilinear interpolation

rho_sur = get_interp2('surfwv',phi_re,phi_rn);

Wvsurrx = rho_sur;


% Use the method in Attachment F.4 to get the gaseous attenuations due to
% oxygen and for water vapour under both non-rain and rain conditions for
% the Rx-cv path (F.3.2)
h_sur = hn;
theta_el = thetarpos;
dcv = drcv;

[Aorcv, Awrcv, Awrrcv] = gaseous_abs_tropo_t2cv(rho_sur, h_sur, theta_el, dcv, f);

% Gaseous attenuations for the complete troposcatter path (F.3.3)

Aos = Aotcv + Aorcv;

Aws = Awtcv + Awrcv;

Awrs = Awrtcv + Awrrcv;
return
end
