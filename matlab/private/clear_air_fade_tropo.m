function Qcaftropo = clear_air_fade_tropo(A)
%Percentage time a given clear-air fade level is exceeded on a troposcatter path
%   This function computes the percentage of the non-rain time a given fade 
%   in dB below the median signal level is exceeded on a troposcatter path 
%   as defined in ITU-R P.2001-2 in Attachment B.5
%
%     Input parameters:
%     A        -   Clear air fade (A>0) or enhancement (A<0)
%
%     Output parameters:
%     Qcaftropo-   Percentage time a given clear-air fade level is exceeded
%                  on a troposcatter path
%     
%
%
%     Example:
%     Qcaftropo = clear_air_fade_tropo(A)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    14JUL16     Ivica Stevanovic, OFCOM         Initial version

%% B.5 Percentage time a given clear-air fade level is exceeded on a troposcatter path

if A < 0
   
    Qcaftropo = 100;   % Eq (B.5.1a)
    
else

    Qcaftropo = 0;     % Eq (B.5.1b)

end

return
end
