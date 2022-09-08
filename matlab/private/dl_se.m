function Ldsph = dl_se(d, hte, hre, ap, f, omega)
%dl_se spherical-Earth diffraction loss exceeded for p% time according to ITU-R P.2001-2
%   This function computes the Spherical-Earth diffraction loss not exceeded
%   for p% time for antenna heights hte and hre (m)
%   as defined in Attachment A.2 of ITU-R P.2001-2
%
%     Input parameters:
%     d       -   Great-circle path distance (km)
%     hte     -   Effective height of interfering antenna (m)
%     hre     -   Effective height of interfered-with antenna (m)
%     ap      -   the effective Earth radius in kilometers
%     f       -   Frequency (GHz)
%     omega   -   the fraction of the path over sea
%
%     Output parameters:
%     Ldsph   -   The spherical-Earth diffraction loss not exceeded for p% time
%                 Ldsph(1) is for the horizontal polarization
%                 Ldsph(2) is for the vertical polarization
%
%     Example:
%     Ldsph = dl_se(d, hte, hre, ap, lam, omega)


%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    23DEC15     Ivica Stevanovic, OFCOM         Initial version (P.452)
%     v1    01FEB16     Ivica Stevanovic, OFCOM         Introduced dl_se_ft (P. 452)
%     v2    06JUL16     Ivica Stevanovic, OFCOM         Initial version (P.1812)
%     v2    13JUL16     Ivica Stevanovic, OFCOM         Initial version (P.2001)


% Wavelength
c0 = 2.998e8;
lam = 1e-9*c0/f;

% Calculate the marginal LoS distance for a smooth path

dlos = sqrt(2*ap) * (sqrt(0.001*hte) + sqrt(0.001*hre));    % Eq (A.2.1)

if d >= dlos
    % calculate diffraction loss Ldft using the method in Sec. A.3 for
    % adft = ap and set Ldsph to Ldft
    
    Ldsph = dl_se_ft(d, hte, hre, ap, f, omega);
    return
else
    % calculate the smallest clearance between the curved-Earth path and
    % the ray between the antennas, hse
    
    c = (hte - hre)/(hte + hre);        % Eq (A.2.2d)
    m = 250*d*d/(ap*(hte +hre));        % Eq (A.2.2e)
    
    b = 2*sqrt((m+1)/(3*m)) * cos( pi/3 + 1/3* acos( 3*c/2 * sqrt( 3*m/(m+1).^3 ) ) );   % Eq (A.2.2c)
    
    dse1 = d/2*(1+b);           % Eq (A.2.2a)
    dse2 = d - dse1;            % Eq (A.2.2b)
    
    hse = (hte - 500*dse1*dse1/ap)*dse2 + (hre - 500*dse2*dse2/ap)*dse1;
    hse = hse/d;                % Eq (A.2.2)
    
    % Calculate the required clearance for zero diffraction loss
    
    hreq = 17.456*sqrt(dse1 * dse2 * lam/d);     % Eq (A.2.3)
    
    if hse > hreq
        Ldsph = [0 0];
        return
    else
        
        % calculate the modified effective Earth radius aem, which gives
        % marginal LoS at distance d
        
        aem = 500*(d/( sqrt(hte) + sqrt(hre) )).^2;     % Eq (A.2.4)
        
        % Use the method in Sec. A3 for adft = aem to obtain Ldft
        
        Ldft = dl_se_ft(d, hte, hre, aem, f, omega);
        
        Ldft(Ldft < 0) = 0;

        Ldsph = (1-hse/hreq)*Ldft; % Eq (A.2.5)
    end
end

return
end