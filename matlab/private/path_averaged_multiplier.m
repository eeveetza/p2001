function G = path_averaged_multiplier( hlo, hhi, hT )
%path_averaged_multiplier Models path-averaged multiplier
%   This function computes the path-averaged multiplier
%   according to ITU-R Recommendation P.2001-2 Attachment C.5
%
%     Input parameters:
%     hlo, hhi  -   heights of the loewr and higher antennas (m)
%     hT        -   rain height
%
%     Output parameters:
%     G         -   weighted average of the multiplier Gamma (multi_layer.m)
%
%     Example:
%     G = path_averaged_multiplier( hlo, hhi, hT )

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    14JUL16     Ivica Stevanovic, OFCOM         Initial version

%% C.5 Path-averaged multiplier

% Calculate the slices in which the two antennas lie (C.5.1)

slo = 1 + floor((hT-hlo)/100);

shi = 1 + floor((hT-hhi)/100);

if slo < 1 % path wholly above the melting layer
    G=0;
    return
end

if (shi > 12) % path is wholy at or below the lower edge of the melting layer
    G=1;
    return
end

if (slo == shi) % both antennas in the same melting-layer slice (C.5.2)
    
    G = multi_layer(0.5*( hlo + hhi ) - hT);
    
    return
end

% Initialize G for use as an accumulator (C.5.3)

G = 0;

% Calculate the required range of slice indices (C.5.4)

sfirst = max(shi, 1);

slast =  min(slo, 12);

for s = sfirst : slast
   
    if (shi < s && s < slo)
        % In this case the slice is fully traversed by a section of the
        % path (C.5.5)
        
        delh = 100 * (0.5 - s);
        
        Q = 100/(hhi - hlo);
        
    elseif (s == slo)
        % In this case the slice contains the lower antenna at hlo (C.5.6)
        
        delh = 0.5 * (  hlo - hT - 100 * (s-1) );
        Q = (hT - 100*(s - 1) - hlo)/(hhi - hlo);
    
    elseif  (s==shi)
        % In this case the slice contains the higher antenna at hhi (C.5.7)
        
        delh = 0.5*( hhi - hT - 100*s );
        
        Q = (hhi - (hT - 100*s))/(hhi - hlo);
        
    end
    
    % For delh calculated under one of the preceeding three conditions,
    % calculate the corresponding multiplier (C.5.8)
    
    Gamma_slice = multi_layer(delh);
    
    % Accumulate the multiplier (C.5.9)
    
    G = G + Q * Gamma_slice;
end

if slo > 12 % lower antenna is below the melting layer
   
    %The fraction of the path below the layer (C.5.10)
    Q = (hT - 1200 - hlo)/(hhi - hlo);    
    
    % Since the multiplier is 1 below the layer, G should be increased
    % according to (C.5.11)
    
    G = G + Q;
    
end
    
return
end