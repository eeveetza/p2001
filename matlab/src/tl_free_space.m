function Lbfs = tl_free_space(f,d)
%tl_free_space Free-space basic transmission loss 
%   This function computes free-space basic transmission loss in dB
%   as defined in ITU-R P.2001-2 Section 3.11
%
%     Input parameters:
%     f       -   Frequency (GHz)
%     d       -   Distance (km)
%
%     Output parameters:
%     Lbfs    -   Free-space basic transmission loss (dB)

%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version

Lbfs = 92.44 + 20*log10(f) + 20*log10(d);

return
end
