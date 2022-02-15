function [Ld, Ldsph, Ldba, Ldbs, Ldbka, Ldbks, FlagLospa, FlagLosps] = dl_p( d, h, hts, hrs, hte, hre, f, omega, ap, Cp )
%dl_p Diffraction loss model not exceeded for p% of time according to P.2001-2
%   [Ld, Ldsph, Ldba, Ldbs, Ldbka, Ldbks] = dl_p( d, h, hts, hrs, hte, hre, f, omega, ap, Cp )
%
%   This function computes the diffraction loss not exceeded for p% of time
%   as defined in ITU-R P.2001-2 (Attachment A)
%
%     Input parameters:
%     d       -   vector of distances di of the i-th profile point (km)
%     h       -   vector hi of heights of the i-th profile point (meters
%                 above mean sea level). 
%                 Both vectors h and d contain n+1 profile points
%     hts     -   transmitter antenna height in meters above sea level (i=0)
%     hrs     -   receiver antenna height in meters above sea level (i=n)
%     hte     -   Effective height of interfering antenna (m amsl) 
%     hre     -   Effective height of interfered-with antenna (m amsl) 
%     f       -   frequency expressed in GHz
%     omega   -   the fraction of the path over sea
%     ap      -   Effective Earth radius (km)
%     Cp      -   Effective Earth curvature
%
%     Output parameters:
%     Ldp    -   diffraction loss for the general path not exceeded for p % of the time 
%                according to Attachment A of ITU-R P.2001-2. 
%                Ldp(1) is for the horizontal polarization 
%                Ldp(2) is for the vertical polarization
%     Ldshp  -   Spherical-Earth diffraction loss diffraction (A.2) for the actual path d and modified antenna heights
%     Lba    -   Bullington diffraction loss for the actual path profile as calculated in A.4    
%     Lbs    -   Bullingtong diffraction loss for a smooth path profile as calculated in A.5
%     Ldbka  -   Knife-edge diffraction loss for Bullington point: actual path
%     Ldbks  -   Knife-edge diffraction loss for Bullington point: smooth path
%     FlagLospa - 1 = LoS p% time for actual path, 0 = otherwise
%     FlagLosps - 1 = LoS p% time for smooth path, 0 = otherwise
%
%     Example:
%     [Ld, Ldsph, Ldba, Ldbs, Ldbka, Ldbks, FlagLospa, FlagLosps] = dl_p( d, h, hts, hrs, hte, hre, f, omega, ap, Cp )
       
%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    01JAN16     Ivica Stevanovic, OFCOM         Initial version (P.452)
%     v1    06JUL16     Ivica Stevanovic, OFCOM         Modifications according to P.1812
%     v2    13JUL16     Ivica Stevanovic, OFCOM         Modifications according to P.2001 


%% 
dtot = d(end);

Ldsph = dl_se(dtot, hte, hre, ap, f, omega);

[Ldba, Ldbka, FlagLospa] = dl_bull_actual(d, h, hts, hrs, Cp, f);

[Ldbs, Ldbks, FlagLosps] = dl_bull_smooth(d, h, hte, hre, ap, f);

Ld = Ldba + max(Ldsph-Ldbs,0);                  % Eq (A.1.1)

return
end