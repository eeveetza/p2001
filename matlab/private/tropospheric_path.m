function [d_tcv, d_rcv, phi_cve, phi_cvn, h_cv, phi_tcve, phi_tcvn, phi_rcve, phi_rcvn] = tropospheric_path(dt, hts, hrs, theta_e, theta_tpos, theta_rpos, ae, phi_re, phi_te, phi_rn, phi_tn, Re)
%trophospheric path segments according to ITU-R P.2001-2
% [d_tcv, d_rcv, phi_cve, phi_cvn, h_cv, phi_tcve, phi_tcvn, phi_rcve, phi_rcvn] = tropospheric_path(d, h, hts, theta_e, theta_tpos, theta_rpos, ae, phi_re, phi_te, phi_rn, phi_tn, Re)
% This function computes tropospheric path segments as described in Section
% 3.9 of Recommendation ITU-R P.2001-2
%
% Input parameters:
% dt        -   Path length (km)
% hts, hrs  -   Tx/Rx antenna heights above means sea level (m)
% theta_e   -   Angle subtended by d km at the center of a sphere of effective earth radius (rad)
% theta_tpos-   Interfering antenna horizon elevation angle limited to be positive (mrad)
% theta_rpos-   Interfered-with antenna horizon elevation angle limited to be positive (mrad)
%               hts = htg + h(1)
% ae        -   median effective Earth's radius 
% phi_re    -   Receiver longitude, positive to east (deg)
% phi_te    -   Transmitter longitude, positive to east (deg)
% phi_rn    -   Receiver latitude, positive to north (deg)
% phi_tn    -   Transmitter latitude, positive to north (deg)
% Re        -   Average Earth radius (km)
%
% Output parameters:
% d_tcv     -   Horizontal path length from transmitter to common volume (km)
% d_rcv     -   Horizontal path length from common volume to receiver (km)
% phi_cve   -   Longitude of the common volume 
% phi_cvn   -   Latitude of the common volume 
% h_cv      -   Height of the troposcatter common volume (masl)
% phi_tcve  -   Longitude of midpoint of the path segment from Tx to common volume
% phi_tcvn  -   Latitude of midpoint of the path segment from Tx to common volume
% phi_rcve  -   Longitude of midpoint of the path segment from common volume to Rx
% phi_rcvn  -   Latitude of midpoint of the path segment from common volumen to Rx
%


%
% Rev   Date        Author                          Description
% -------------------------------------------------------------------------------
% v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version 

% Horizontal path lenght from transmitter to common volumne (3.9.1a)

d_tcv = ( dt * tan(0.001*theta_rpos + 0.5* theta_e) - 0.001*(hts-hrs) ) / ...
        ( tan(0.001*theta_tpos + 0.5*theta_e) + tan(0.001*theta_rpos + 0.5* theta_e));

% Limit d_tcv such that 0 <= dtcv <= dt

if d_tcv < 0
    d_tcv = 0;
end
if d_tcv > dt
    d_tcv = dt;
end

% Horizontal path length from common volume to receiver (3.9.1b)

d_rcv = dt - d_tcv;

% Calculate the longitude and latitude of the common volumne from the
% transmitter and receiver longitudes and latitudes using the great circle
% path method of Attachment H by seting d_pnt = d_tcv

[phi_cve, phi_cvn, bt2r, dgc] = great_circle_path(phi_re, phi_te, phi_rn, phi_tn, Re, d_tcv);

% Calculate the height of the troposcatter common volume (3.9.2)

h_cv = hts + 1000 * d_tcv * tan(0.001*theta_tpos) + 1000 * d_tcv^2/(2*ae);

% Calculate the longitude and latitude of the midpoint of hte path segment
% from transmitter to common volume by setting dpnt = 0.5dtcv

d_pnt = 0.5 * d_tcv;

[phi_tcve, phi_tcvn, bt2r, dgc] = great_circle_path(phi_re, phi_te, phi_rn, phi_tn, Re, d_pnt);

% Calculate the longitude and latitude of the midpoint of the path segment
% from receiver to common volume by setting dpnt = dt - 0.5drcv

d_pnt = dt - 0.5 * d_rcv;

[phi_rcve, phi_rcvn, bt2r, dgc] = great_circle_path(phi_re, phi_te, phi_rn, phi_tn, Re, d_pnt);

return
end