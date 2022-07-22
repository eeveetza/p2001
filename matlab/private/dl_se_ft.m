function Ldft = dl_se_ft(d, hte, hre, adft, f, omega)
%dl_se_ft First-term part of spherical-Earth diffraction according to ITU-R P.2001-2
%   This function computes the first-term part of Spherical-Earth diffraction
%   as defined in Sec. A.3 of the ITU-R P.2001-2
%
%     Input parameters:
%     d       -   Great-circle path distance (km)
%     hte     -   Effective height of interfering antenna (m)
%     hre     -   Effective height of interfered-with antenna (m)
%     adft    -   effective Earth radius (km)
%     f       -   Frequency (GHz)
%     omega   -   fraction of the path over sea
%
%     Output parameters:
%     Ldft   -   The first-term spherical-Earth diffraction loss not exceeded for p% time
%                Ldft(1) is for the horizontal polarization
%                Ldft(2) is for the vertical polarization
%
%     Example:
%     Ldft = dl_se_ft(d, hte, hre, adft, f, omega)
%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    23DEC15     Ivica Stevanovic, OFCOM         First implementation (P.452)
%     v1    06JUL16     Ivica Stevanovic, OFCOM         First implementation (P.1812)
%     v2    13JUL16     Ivica Stevanovic, OFCOM         First implementation (P.2001)
%     v3    04AUG18     Ivica Stevanovic, OFCOM         epsr and sigma were
%                                                       swapped in dl_se_ft_inner function call


%% 

% First-term part of the spherical-Earth diffraction loss over land

epsr = 22;
sigma = 0.003;

Ldft_land = dl_se_ft_inner(epsr, sigma, d, hte, hre, adft, f);

% First-term part of the spherical-Earth diffraction loss over sea

epsr = 80;
sigma = 5;

Ldft_sea = dl_se_ft_inner(epsr, sigma, d, hte, hre, adft, f);


% First-term spherical diffraction loss 

Ldft = omega * Ldft_sea + (1-omega)*Ldft_land;      % Eq (A.3.1)

return
end
