function Gamma = multi_layer( delh )
%multi_layer Models the changes in specific attenuation within the melting layer
%   This function computes the changes in specific attenuation at different 
%   heights within the melting layer according to ITU-R Recommendation
%   P.2001-2 Attachment C.4
%
%     Input parameters:
%     delh     -   difference between a given height h and rain height hT (m)
%
%     Output parameters:
%     Gamma    -   attenuation multiplier
%
%     Example:
%     Gamma = multi_layer( delh )

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    14JUL16     Ivica Stevanovic, OFCOM         Initial version

%% C.4 Melting-layer model

if delh > 0
    
    Gamma = 0;
    
elseif (delh < -1200)
    
    Gamma = 1;
    
else
    
    Gamma = 4*(1-exp(delh/70))^2;
    
    Gamma = Gamma /(1 + (1-exp(-(delh/600)^2))^2 *(Gamma - 1 ));
    
end

return
end



