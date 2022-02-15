function Ldft = dl_se_ft_inner(epsr, sigma, d, hte, hre, adft, f)
%%dl_se_ft_inner The inner routine of the first-term spherical diffraction loss
%   This function computes the first-term part of Spherical-Earth diffraction
%   loss exceeded for p% time for antenna heights
%   as defined in Sec. A.3 of the ITU-R P.2001-2, equations (A3.2-A3.8)
%
%     Input parameters:
%     epsr    -   Relative permittivity
%     sigma   -   Conductivity (S/m)
%     d       -   Great-circle path distance (km)
%     hte     -   Effective height of interfering antenna (m)
%     hre     -   Effective height of interfered-with antenna (m)
%     adft    -   effective Earth radius (km)
%     f       -   frequency (GHz)
%
%     Output parameters:
%     Ldft   -   The first-term spherical-Earth diffraction loss not exceeded for p% time
%                implementing equations (30-37), Ldft(1) is for horizontal
%                and Ldft(2) for the vertical polarization
%
%     Example:
%     Ldft = dl_se_ft_inner(epsr, sigma, d, hte, hre, adft, f)
%
%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    23DEC15     Ivica Stevanovic, OFCOM         First implementation (P.452)
%     v1    06JUL16     Ivica Stevanovic, OFCOM         Modifications for P.1812
%     v2    13JUL16     Ivica Stevanovic, OFCOM         Modifications for P.2001

%% 

% Normalized factor for surface admittance for horizontal (1) and vertical
% (2) polarizations

K(1) = 0.036* (adft*f).^(-1/3) * ( (epsr-1).^2 + (18*sigma/f).^2 ).^(-1/4);   % Eq (A.3.2a)

K(2) = K(1) * (epsr.^2 + (18*sigma/f).^2).^(1/2);       % Eq (A.3.2b)

% Earth ground/polarization parameter

beta_dft = (1 + 1.6*K.^2 + 0.67* K.^4)./( 1 + 4.5* K.^2 + 1.53* K.^4);  % Eq (A.3.3)

% Normalized distance

X = 21.88* beta_dft .* (f./ adft.^2).^(1/3) * d;          % Eq (A.3.4)

% Normalized transmitter and receiver heights

Yt = 0.9575* beta_dft * (f.^2 / adft).^(1/3) * hte;       % Eq (A.3.5a)

Yr = 0.9575* beta_dft * (f.^2 / adft).^(1/3) * hre;       % Eq (A.3.5b)


Fx = [0,0];
GYt= [0,0];
GYr= [0,0];

% Calculate the distance term given by:

for ii = 1:2
    if X(ii) >= 1.6
        Fx(ii) = 11 + 10*log10(X(ii)) - 17.6*X(ii);
    else
        Fx(ii) = -20*log10(X(ii)) - 5.6488* (X(ii)).^1.425;     % Eq (A.3.6)
    end
end

Bt = beta_dft  .* Yt;             % Eq (A.3.7a)

Br = beta_dft .* Yr;              % Eq (A.3.7a)

for ii = 1:2
    if Bt(ii)>2
        GYt(ii) = 17.6*(Bt(ii) - 1.1).^0.5 - 5*log10(Bt(ii) -1.1)-8;
    else
        GYt(ii) = 20*log10(Bt(ii) + 0.1* Bt(ii).^3);
    end
    
    if Br(ii)>2
        GYr(ii) = 17.6*(Br(ii) - 1.1).^0.5 - 5*log10(Br(ii) -1.1)-8;
    else
        GYr(ii) = 20*log10(Br(ii) + 0.1* Br(ii).^3);
    end
    
    if GYr(ii) < 2 + 20*log10(K(ii))
        GYr(ii) = 2 + 20*log10(K(ii));
    end
    
    if GYt(ii) < 2 + 20*log10(K(ii))
        GYt(ii) = 2 + 20*log10(K(ii));
    end
    
end

Ldft = -Fx - GYt - GYr;         % Eq (A.3.8)

return
end