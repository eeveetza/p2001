function QrainA = precipitation_fade(Afade, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain)
%precipitation_fade Percentage time for which attenuation is exceeded
%   This function computes the percentage time during whicht it is raining
%   for which a given attenuation Afade is exceeded as defined in ITU-R 
%   P.2001-2 in Attachment C.3
%
%     Input parameters:
%     Afade    -   Attenuation (dB)
%     a, b, c  -   Parameters defining cumulative distribution of rain rate
%     dr       -   Limited path length for precipitation calculations
%     kmod     -   Modified regression coefficients
%     alpha_mod-   Modified regression coefficients
%     Gm       -   Vector of attenuation multipliers
%     Pm       -   Vector of probabilities
%     flagrain -   1 = "rain" path, 0 = "non-rain" path
%     
%     Output parameters
%     QrainA   -  percentage time during which it is raining for which a
%                 given attenuation Afade is exceeded
%     Example:
%     QrainA = precipitation_fade(Afade, a, b, c, dr, Q0ra, Fwvr, kmod, alpha_mod, Gm, Pm, flagrain)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    14JUL16     Ivica Stevanovic, OFCOM         Initial version

%% C.3 Percentage time a given precipitation fade level is exceeded

if Afade < 0
    
    QrainA = 100;                                                        % Eq (C.3.1a)
    
else
    
    if (flagrain == 0)  % non-rain
       
       QrainA = 0;                                                       % Eq (C.3.1b)
   
    else    % rain
        
        drlim = max(dr, 0.001);                                          % Eq (C.3.1e)
        
        Rm = (Afade ./ (Gm .* drlim .* kmod)).^(1/alpha_mod);            % Eq (C.3.1d)
        
        QrainA = 100*sum( Pm .* exp(-a*Rm.*(b*Rm+1)./(c*Rm+1)) );        % Eq (C.3.1c)
        
    end
end
return
end
