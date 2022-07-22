function Lbfs = tl_free_space(f,d)
%tl_free_space Free-space basic transmission loss 
%   This function computes free-space basic transmission loss in dB
%   as defined in ITU-R P.2001-4 Section 3.11
%
%     Input parameters:
%     f       -   Frequency (GHz)
%     d       -   3D Distance (km)
%
%     Output parameters:
%     Lbfs    -   Free-space basic transmission loss (dB)

%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version
%     v1    11FEB22     Ivica Stevanovic, OFCOM         Aligned to P.2001-4

Lbfs = 92.4 + 20*log10(f) + 20*log10(d);

return
end
