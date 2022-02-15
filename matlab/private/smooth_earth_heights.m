function [theta_t, theta_r, theta_tpos, theta_rpos, dlt, dlr, lt, lr, hstip, hsrip, hstipa, hsripa, htea, hrea, mses, hm, hst, hsr, htep, hrep, FlagLos50] = smooth_earth_heights(d, h, hts, hrs, ae, lam)
%smooth_earth_heights smooth-Earth effective antenna heights according to ITU-R P.2001-2
% [theta_t, theta_r, theta_tpos, theta_rpos, dlt, dlr, lt, lr, hstip, hsrip, hstipa, hsripa, htea, hrea, hm, hst, hsr, htep, hrep] = smooth_earth_heights(d, h, hts, hrs, ae, lam)
% This function derives smooth-Earth effective antenna heights according to
% Sections 3.7 and 3.8 of Recommendation ITU-R P.2001-2
%
% Input parameters:
% d         -   vector of terrain profile distances from Tx [0,dtot] (km)
% h         -   vector of terrain profile heights amsl (m)
% hts, hrs  -   Tx and Rx antenna heights above means sea level (m)
%               hts = htg + h(1), hrs = hrg + h(end)
% ae        -   median effective Earth's radius
% lam       -   wavelength (m)
%
% Output parameters:
%
% theta_t      -   Interfering antenna horizon elevation angle (mrad)
% theta_r      -   Interfered-with antenna horizon elevation angle (mrad)
% theta_tpos   -   Interfering antenna horizon elevation angle limited to be positive (mrad)
% theta_rpos   -   Interfered-with antenna horizon elevation angle limited to be positive (mrad)
% dlt          -   Tx antenna horizon distance (km)
% dlr          -   Rx antenna horizon distance (km)
% lt           -   Index i in the path profile for which dlt=d(lt)
% lr           -   Index i in tha path profile for which dlr = d(lr)
% hstip, hrip  -   Initial smooth-surface height at Tx/Rx
% hstipa, hripa-   Smooth surface height at Tx/Rx not exceeding ground level
% htea, htea   -   Effective Tx and Rx antenna heigts above the smooth-Earth surface amsl for anomalous propagation (m)
% mses         -   Smooth surface slope (m/km)
% hm           -   The terrain roughness parameter (m)
% hst, hsr     -   Heights of the smooth surface at the Tx and Rx ends of the paths
% htep, hrep   -   Effective Tx and Rx antenna heights for the
%                  spherical-earth and the smooth-pofile version of the
%                  Bullingtong diffraction model (m)
% FlagLos50    -   1 = Line-of-sight 50% time, 0 = otherwise
%
% Example
%  [theta_t, theta_r, theta_tpos, theta_rpos, dlt, dlr, lt, lr, hstip, hsrip, hstipa, hsripa, htea, hrea, mses, hm, hst, hsr, htep, hrep] = smooth_earth_heights(d, h, hts, hrs, ae, lam)

%
% Rev   Date        Author                          Description
% -------------------------------------------------------------------------------
% v0    15JAN16     Ivica Stevanovic, OFCOM         First implementation in matlab (P.452)
% v1    15JUN16     Ivica Stevanovic, OFCOM         Modifications related to LoS path (P.452)
% v3    15JUN16     Ivica Stevanovic, OFCOM         Initial version for P.1812
% v4    13JUL16     Ivica Stevanovic, OFCOM         Initial version for P.2001

n = length(d);

dtot = d(end);

%Tx and Rx antenna heights above mean sea level amsl (m)


%% 3.7 Path classification and terminal horizon parameters

% Highest elevation angle to an intermediate profile point, relative to the
% horizontal at the transmitter (3.7.1)

ii = 2:n-1;

theta_tim =   max( (h(ii)-hts)./d(ii) - 500*d(ii)/ae );

% Elevation angle of the receiver as viewed by the transmitter, assuming a
% LoS path (3.7.2)

theta_tr = (hrs - hts)/dtot - 500*dtot/ae; %


if theta_tim < theta_tr % path is LoS
    FlagLos50 = 1;
    nu = (h(ii) + 500*d(ii).*(dtot-d(ii))./ae - (hts*(dtot- d(ii)) + hrs *d(ii))/dtot).* ...
        sqrt(0.002*dtot./(lam*d(ii).*(dtot-d(ii))));             % Eq (3.7.3)
    
    numax = max(nu);
    
    kindex = find(nu == numax);
    lt = kindex(end)+1;     %in order to map back to path d indices, as theta takes path indices 2 to n-1,
    dlt = d(lt);                                % Eq (3.7.4a)
    dlr = dtot - dlt;                           % Eq (3.7.4b)
    lr = lt;                                    % Eq (3.7.4d)
    
    theta_t =  theta_tr;                        % Eq (3.7.5a)
    theta_r = -theta_tr - 1000*dtot/ae;         % Eq (3.7.5b)
    
else
    FlagLos50 = 0;
    % Transmitter hoizon distance and profile index of the horizon point (3.7.6)
    
    theta_ti =    (h(ii)-hts)./d(ii) - 500*d(ii)/ae ;
    kindex = find(theta_ti == theta_tim);
    lt = kindex(end)+1;     %in order to map back to path d indices, as theta takes path indices 2 to n-1,
    dlt = d(lt);                                % Eq (3.7.6a)
    
    % Transmitter horizon elevation angle reltive to its local horizontal (3.7.7)
    theta_t = theta_tim;
    
    % Find the heighest elevation angle to an intermediate profile point,
    % relative to the horizontal at the receiver (3.7.8)
    
    theta_ri =   ( (h(ii)-hrs)./(dtot-d(ii)) - 500*(dtot-d(ii))/ae );
    
    theta_rim = max(theta_ri);
    kindex = find(theta_ri == theta_rim);
    lr = kindex(end)+1;     %in order to map back to path d indices, as theta takes path indices 2 to n-1,
    dlr = dtot-d(lr);                           % Eq (3.7.9)
    
    % receiver horizon elevatio nangle relative to its local horizontal
    theta_r = theta_rim;                        % Eq (3.7.10)
end

% Calculate the horizon elevation angles limited such that they are
% positive

theta_tpos = max(theta_t, 0);                   % Eq (3.7.11a)
theta_rpos = max(theta_r, 0);                   % Eq (3.7.11b)

%% 3.8 Effective heights and path roughness parameter

% v1 = 0;
% for ii = 2:n
%     v1 = v1 + (d(ii)-d(ii-1))*(h(ii)+h(ii-1));  % Eq (85)
% end
% v2 = 0;
% for ii = 2:n
%     v2 = v2 + (d(ii)-d(ii-1))*( h(ii)*( 2*d(ii) + d(ii-1) ) + h(ii-1) * ( d(ii) + 2*d(ii-1) ) );  % Eq (86)
% end

% the above equations optimized for speed, as suggested by Roger LeClair (leclairtelecom)

v1 = sum(diff(d) .* (h(2:n) + h(1:n-1)));  % Eq (3.8.1)
v2 = sum(diff(d) .* (h(2:n) .* (2 * d(2:n) + d(1:n-1)) + h(1:n-1) .* (d(2:n) + 2 * d(1:n-1))));  % Eq (3.8.2)

%

hstip = (2*v1*dtot - v2)/dtot.^2;       % Eq (3.8.3a)
hsrip = (v2- v1*dtot)/dtot.^2;          % Eq (3.8.3b)

% Smooth-sruface heights limited not to exceed ground leve at either Tx or
% Rx

hstipa = min(hstip,h(1));               % Eq (3.8.4a)
hsripa = min(hsrip,h(end));             % Eq (3.8.4b)

% The slope of the least-squares regression fit (3.8.5)

mses =(hsripa-hstipa)/dtot;

% effective heights of Tx and Rx antennas above the smooth surface (3.8.6)

htea = hts-hstipa;
hrea = hrs-hsripa;

% Path roughness parameter (3.8.7)

ii = lt:1:lr;

hm = max(h(ii) - (hstipa + mses*d(ii)));

% Smooth-surface heights for the diffraction model

HH = h - (hts*(dtot-d) + hrs*d)/dtot;  %  Eq (3.8.8d)

hobs = max(HH(2:n-1));                 % Eq (3.8.8a)

alpha_obt = max( HH(2:n-1)./d(2:n-1) ); % Eq (3.8.8b)

alpha_obr = max( HH(2:n-1)./( dtot - d(2:n-1) ) ); % Eq (3.8.8c)

% Calculate provisional values for the Tx and Rx smooth surface heights

gt = alpha_obt/(alpha_obt + alpha_obr);         % Eq (3.8.9e)
gr = alpha_obr/(alpha_obt + alpha_obr);         % Eq (3.8.9f)

if hobs <= 0
    hst = hstip;                                % Eq (3.8.9a)
    hsr = hsrip;                                % Eq (3.8.9b)
else
    hst = hstip - hobs*gt;                      % Eq (3.8.9c)
    hsr = hsrip - hobs*gr;                      % Eq (3.8.9d)
end

% calculate the final values as required by the diffraction model

if hst >= h(1)
    hst = h(1);                                % Eq (3.8.10a)
end

if hsr > h(end)
    hsr = h(end);                              % Eq (3.8.10b)
end

% The terminal effective heigts for the ducting/layer-reflection model

htep = hts - hst;                            % Eq (3.8.11a)
hrep = hrs - hsr;                            % Eq (3.8.11b)

return
end