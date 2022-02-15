function [Lba, Aat, Aad, Aac, dct, dcr, dtm, dlm] = tl_anomalous_reflection(f, d, z, hts, hrs, htea, hrea, hm, thetat, thetar, dlt, dlr, phimn, omega, ae, p, q)
%anomalous_reflection Basic transmission loss associated with anomalous propagation
%   This function computes the basic transmission loss associated with
%   anomalous propagation as defined in ITU-R P.2001-2 (Attachment D)
%
%     Input parameters:
%     f       -   Frequency GHz
%     d       -   Vector of distances di of the i-th profile point (km)
%     z       -   Radio climatic zones 1 = Sea, 3 = Coastal inland, 4 = Inland
%                 Vectors d and z each contain n+1 profile points
%     hts     -   Transmitter antenna height in meters above sea level (i=0)
%     hrs     -   Receiver antenna height in meters above sea level (i=n)
%     htea    -   Effective height of Tx antenna above smooth surface(m amsl) 
%     hrea    -   Effective height of Rx antenna above smooth surface (m amsl) 
%     hm      -   Path roughness parameter (m)
%     thetat  -   Tx horizon elevation angle relative to the local horizontal (mrad)
%     thetar  -   Rx horizon elevation angle relative to the local horizontal (mrad)
%     dlt     -   Tx to horizon distance (km)
%     dlr     -   Rx to horizon distance (km)
%     phimn   -   Mid-point latitude (deg)
%     omega   -   the fraction of the path over sea
%     ae      -   Effective Earth radius (km)
%     p       -   Percentage of average year for which predicted basic loss
%                 is not exceeded (%)
%     q       -   Percentage of average year for which predicted basic loss
%                 is exceeded (%)
%
%     Output parameters:
%     Lba    -   Basic transmission loss associated with ducting (dB)
%     Aat    -   Time-dependent loss (dB) c.f. Attachment D.7
%     Aad    -   Angular distance dependent loss (dB) c.f. Attachment D.6
%     Aac    -   Total coupling loss to the anomalous propagation mechanism (dB) c.f. Attachment D.5
%     Dct    -   Coast distance from Tx (km)
%     Dcr    -   Coast distance from Rx (km)
%     Dtm    -   Longest continuous land (inland or coastal) section of the path (km)
%     Dlm    -   Longest continuous inland section of the path (km)
%
%     Example:
%     [Lba, Aat, Aad, Aac, Dct, Dcr, Dtm, Dlm] = tl_anomalous_reflection(f, d, h, z, hts, hrs, htea, hrea, thetat, thetar, dlt, dlr, omega, ae, p, q)
       
%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    15JUL16     Ivica Stevanovic, OFCOM         Initial version 
%     v1    28OCT19     Ivica Stevanovic, OFCOM         Changes in angular distance dependent loss according to ITU-R P.2001-3
%  


%% 

dt = d(end) - d (1);

% Attachment D: Anomalous/layer-reflection model

%% D.1 Characterize the radio-climatic zones dominating the path

% Longest continuous land (inland or coastal) section of the path 
zoner = 34; % (3 = coastal) + (4 = inland)
dtm = longest_cont_dist(d, z, zoner);

% Longest continuous inland section of the path
zoner = 4;
dlm = longest_cont_dist(d, z, zoner);

%% D.2 Point incidence of ducting

% Calculate a parameter depending on the longest inland section of the path
% (D.2.1)

tau = 1 - exp(-0.000412* dlm^2.41);

% Calculate parameter mu_1 characterizing the degree to which the path is
% over land (D.2.2)

mu1 = ( 10^(-dtm/(16-6.6*tau)) + 10^(-(2.48 + 1.77*tau) )  )^0.2;

if (mu1 > 1)
    mu1 = 1;
end

% Calculate parameter mu4 given by (D.2.3)

if abs(phimn) <= 70
   
    mu4 = 10^( ( -0.935 + 0.0176*abs(phimn))*log10(mu1) );
    
else
    
    mu4 = 10^(0.3*log10(mu1));
    
end

% The point incidence of anomalous propagation for the path centre (D.2.4)

if abs(phimn) <= 70

    b0 = mu1 * mu4 * 10^( -0.015*abs(phimn) + 1.67 );

else
    
    b0 = 4.17*mu1*mu4;
    
end

%% D.3 Site-shielding losses with respect to the anomalous propagatoin mechanism

% Corrections to Tx and Rx horizon elevation angles (D.3.1)

gtr = 0.1* dlt;
grr = 0.1* dlr;

% Modified transmitter and receiver horizon elevation angles (D.3.2)

thetast = thetat - gtr;  %mrad
thetasr = thetar - grr;  %mrad

% Tx and Rx site-shielding losses with respect to the duct (D.3.3)-(D.3.4)

if thetast > 0
    Ast = 20*log10(1 + 0.361 * thetast  * sqrt(f * dlt)) + 0.264*thetast*f^(1/3); 
else
    Ast = 0;
end

if thetasr > 0
    
    Asr = 20*log10(1 + 0.361 * thetasr  * sqrt(f * dlr)) + 0.264*thetasr*f^(1/3); 
    
else
    
    Asr = 0;

end


%% D.4 Over-sea surface duct coupling corrections

% Obtain the distance from each terminal to the sea in the direction of the
% other terminal (D.4.1)

[dct, dcr] = distance_to_sea(d, z);

% The over-sea surface duct coupling corrections for Tx and Rx
% (D.4.2)-(D.4.3)

Act = 0;
Acr = 0;

if (omega >= 0.75)
    
    if (dct <= dlt && dct <= 5)
    
        Act = -3 * exp(-0.25*dct^2 ) * ( 1 + tanh(0.07*(50-hts) ));
        
    end
    
    if (dcr <= dlr && dcr <= 5)
        
        Acr = -3 * exp(-0.25*dcr^2 ) * ( 1 + tanh(0.07*(50-hrs) ));
        
    end

end


%% D.5 Total coupling loss to the anomalous propagation mechanism

% Empirical correction to account for the increasing attenuation with
% wavelength in ducted propagation (D.5.2)

Alf = 0;

if f < 0.5
    
    Alf = (45.375 - 137.0*f + 92.5 *f^2) * omega;

end

% Total coupling losses between the antennas and the anomalous propagation
% mechanism (D.5.1)

Aac = 102.45 + 20*log10(f*(dlt + dlr)) + Alf + Ast + Asr + Act + Acr;

%% D.6 Angular-distance dependent loss

% Specific angular attenuation (D.6.1)

gammad = 5e-5 * ae * f^(1/3);

% Adjusted Tx and Rx horizon elevation angles (D.6.2)

theta_at = min(thetat, gtr);  % mrad

theta_ar = min(thetar, grr);  % mrad

% Adjucted total path angular distance (D.6.3)

theta_a = 1000*dt/ae + theta_at + theta_ar; % mrad

% Angular-distance dependent loss (D.6.4a,b)
Aad = 0;  

if (theta_a > 0)
    Aad = gammad * theta_a;
end
    

%% D.7 Distance and time-dependent loss

% Distance adjusted for terrain roughness factor (D.7.1)

dar = min(dt - dlt - dlr, 40);   

% Terrain roughness factor (D.7.2)

if hm > 10
    
    mu3 = exp(-4.6e-5 *(hm - 10)*(43 + 6*dar));
    
else
    
    mu3 = 1;
    
end

% A term required for the path geometr ycorrection  (D.7.3)

alpha = -0.6 - 3.5e-9 * dt^3.1 * tau;

if alpha < -3.4

    alpha = -3.4;
    
end

% Path geometry factor (D.7.4)

mu2 = 500* dt^2/ ( ae * (sqrt(htea) + sqrt(hrea) )^2  );
mu2 = mu2^alpha;

if mu2 > 1
    mu2 = 1;
end

% Time percentage associated with anomalous propagation adjusted for
% general location and specific properties of the path (D.7.5)

bduct = b0 * mu2 * mu3;

% An exponent required fo rthe time-dependent loss (D.7.6)

Gamma = 1.076 * exp ( -1e-6 * dt^1.13 *( 9.51 - 4.8 * log10(bduct) + 0.198 * (log10(bduct))^2) ) / ...
        ((2.0058 - log10(bduct))^1.012);
    
 % Time dependent loss (D.7.7)
 
 Aat = -12 + (1.2 + 0.0037 * dt) * log10(p / bduct) + 12 * ( p / bduct )^Gamma + 50/q;
 
%% D.8 Basic transmission loss associated with ducting (D.8.1)

Lba = Aac + Aad + Aat;
return
end