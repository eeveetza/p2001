function QiterA = Qiter(Afade, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain)
%Qiter Cumulative distribution function of a propagation model
%   This function computes the cumulative distribution function of a
%   propagation model as defined in ITU-R P.2001-2 in Sections 4.1 and 4.3
%
%     Input parameters:
%     Afade    -   Clear air fade (A>0) or enhancement (A<0)
%     Q0ca     -   Notional zero-fade annual percantage time
%     Q0ra     -   Percentage of an average year in which rain occurs
%     flagtropo-   0 = surface path, 1 = tropospheric path
%     a, b, c  -   Parameters defining cumulative distribution of rain rate
%     dr       -   Limited path length for precipitation calculations
%     kmod     -   Modified regression coefficients
%     alpha_mod-   Modified regression coefficients
%     Gm       -   Vector of attenuation multipliers
%     Pm       -   Vector of probabilities
%     flagrain -   1 = "rain" path, 0 = "non-rain" path
%
%     Output parameters:
%     QiterA   -   Cumulative distribution function of fade A
%     
%
%
%     Example:
%     QiterA = Qiter(Afade, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    14JUL16     Ivica Stevanovic, OFCOM         Initial version

%% 

% Compute Qrain(Afade) as defined in Attachment C.3 
QrainA = precipitation_fade(Afade, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);

% Compute Qcaf(Afade) as defined in Attachments B.4/5

if (flagtropo == 0)
    QcafA = clear_air_fade_surface(Afade, Q0ca);
else
    QcafA = clear_air_fade_tropo(Afade);
end

% Function QiterA is defined for combined clear-air/precipitation fading
% (4.1.3), (4.3.5)

QiterA = QrainA*(Q0ra/100) + QcafA*(1-Q0ra/100);

return
end
