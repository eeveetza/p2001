function Q0ca = zero_fade_annual_time(dca, epsca, hca, f, K, phimn)
%zero_fade_annual_time Calculate the notional zero-fade annual percentage time 
%   This function computes the the notional zero-fade annual percentage time
%   as defined in ITU-R P.2001-2 in Attachment B.3
%
%     Input parameters:
%     dca      -   path distance (km)
%     epsca    -   Positive value of path inclination (mrad) 
%     hca      -   Antenna height in meters above sea level 
%     f        -   Frequency (GHz)
%     K        -   Factor representing the statistics of radio-refractivity
%                  lapse rate for the midpoint of the path
%     phimn    -   mid-point latitude
%     Output parameters:
%     Q0ca   -   Notional zero-fade annual percantage time
%
%
%     Example:
%     Q0ca = zero_fade_annual_time(dca, epsca, hca, f, K, phimn)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version


% Notional zero-fade worst-month percentage time (B.3.1)

qw = K* dca^3.1 * (1 + epsca)^(-1.29) * f^0.8 * 10^(-0.00089*hca);     

% Calculate the logarithmic climatic conversion factor (B.3.2)

if abs(phimn)<= 45

    Cg = 10.5 - 5.6*log10( 1.1 + (abs( cosd(2*phimn) ))^0.7) - 2.7*log10(dca) + 1.7*log10(1+epsca);  

else
        
    Cg = 10.5 - 5.6*log10( 1.1 - (abs( cosd(2*phimn) ))^0.7) - 2.7*log10(dca) + 1.7*log10(1+epsca);
    
end

if Cg > 10.8
    Cg = 10.8;
end

% Notional zero-fade annual percentage time (B.3.3)

Q0ca = qw * 10^(-0.1*Cg);

return
end
