function Qcaf = clear_air_fade_surface(A, Q0ca)
%Percentage time a given clear-air fade level is exceeded on a surface path
%   This function computes the percentage of the non-rain time a given fade 
%   in dB below the median signal level is exceeded on a surface path 
%   as defined in ITU-R P.2001-2 in Attachment B.4
%
%     Input parameters:
%     A        -   Clear air fade (A>0) or enhancement (A<0)
%     Q0ca     -   Notional zero-fade annual percantage time
%     Output parameters:
%     Qcaf     -   Percentage time a given clear-air fade level is exceeded
%                  on a surface path
%     
%
%
%     Example:
%     Qcaf = clear_air_fade_surface(A, Q0ca)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    14JUL16     Ivica Stevanovic, OFCOM         Initial version

%% B.4 Percentage time a given clear-air fade level is exceeded on a surface path

if A >= 0
   
    qt = 3.576 - 1.955*log10(Q0ca);     % Eq (B.4.1b)
    
    qa = 2 + (1 + 0.3*10^(-0.05*A)) * 10^(-0.016 * A )*( qt + 4.3*(10^(-0.05*A) + A/800)  );    % Eq (B.4.1a)
    
    Qcaf = 100*( 1 - exp(-10^(-0.05*qa*A) * log(2)) );   % Eq (B.4.1)
    
else
    
    qs = -4.05 - 2.35*log10(Q0ca);     % Eq (B.4.2b)
        
    qe = 8 + (1 + 0.3*10^(0.05*A)) * 10^(0.035 * A )*( qs + 12*(10^(0.05*A) - A/800)  );    % Eq (B.4.2a)
    
    Qcaf = 100*(exp(-10^(0.05*qe*A) * log(2)) );   % Eq (B.4.2)
end

return
end
