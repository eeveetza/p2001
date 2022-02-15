function rho_surr = water_vapour_density_rain(rho_sur, h_sur)
%water_vapour_density_rain Atmospheric water-vapour density in rain (Attachment F.5)
%   This function computes atmosphoric water-vapour density in rain 
%   as defined in ITU-R P.2001-2 Attachment F.5
%
%     Input parameters:
%     rho_sur -   Surface water-vapour density under non-rain conditions (g/m^3)
%     h_sur   -   Terrain height (masl)
%
%     Output parameters:
%     rho_surr-   Atmospheric water-vapour density in rain

%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version

if (h_sur <= 2600)
    rho_surr = rho_sur + 0.4 + 0.0003*h_sur;
else
    rho_surr = rho_sur + 5*exp(-h_sur/1800);
end

return
end
