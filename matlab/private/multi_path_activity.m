function Q0ca = multi_path_activity(f, dt, hts, hrs, dlt, dlr, hlt, hlr, hlo, thetat, thetar, epsp, Nd65m1, phimn, FlagLos50)
%multi_path_activity Multipath fading calculation 
%   This function computes the the notional zero-fade annual percentage time
%   for the whole path as defined in ITU-R P.2001-2 in Attachment B.2
%
%     Input parameters:
%     f        -   Frequency (GHz)
%     hts      -   Transmitter antenna height in meters above sea level (i=0)
%     hrs      -   Receiver antenna height in meters above sea level (i=n)
%     dlt      -   Tx antenna horizon distance (km)
%     dlr      -   Rx antenna horizon distance (km)
%     hlt      -   Profile height at transmitter horizon (m)
%     hlr      -   Profile height at receiver horizon (m)
%     hlo      -   Lower antenna height (m)
%     thetat   -   Horizon elevation angles relative to the local horizontal as viewed from Tx
%     thetar   -   Horizon elevation angles relative to the local horizontal as viewed from Rx
%     phimn    -   mid-point latitude
%     dca      -   path distance (km)
%     epsp     -   Positive value of path inclination (mrad) 
%     Nd65m1   -   Refractivity gradient in the lowest 65 m of the atmosphere exceeded for 1% of an average year
%     phimn    -   Path midpoint latitude
%     FlagLos50-   1 = Line-of-sight 50% time, 0 = otherwise
%
%     Output parameters:
%     Q0ca   -   Notional zero-fade annual percantage time for the whole path
%     
%
%
%     Example:
%     Q0ca = multi_path_activity(f, dt, hts, hrs, dlt, dlr, hlt, hlr, hlo, thetat, thetar, epsp, Nd65m1, phimn)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version

%% B.2 Characterize multi-path activity

% Factor representing the statistics of radio-refractivity lapse time

K = 10^(-(4.6 + 0.0027*Nd65m1));

if (FlagLos50 == 1)
    % Calculate the notional zero fade annual percentage using (B.2.2)
    
    dca = dt;
    epsca = epsp;
    hca = hlo;
    
    Q0ca = zero_fade_annual_time(dca, epsca, hca, f, K, phimn);

    
else
    
    % Calculate the notoinal zero-fade annual percentage time at the
    % transmitter end Q0cat using (B.2.3)
    
    dca = dlt;
    epsca = abs(thetat);
    hca = min(hts,hlt);
    
    Q0cat = zero_fade_annual_time(dca, epsca, hca, f, K, phimn);
    
    % Calculate th enotional zero-fade annual percentage time at the
    % receiver end Q0car using (B.2.4)
 
    dca = dlr;
    epsca = abs(thetar);
    hca = min(hrs,hlr);
    
    Q0car = zero_fade_annual_time(dca, epsca, hca, f, K, phimn);
    
    Q0ca = max(Q0cat, Q0car);   % Eq (B.2.5)
    
end

return
end
