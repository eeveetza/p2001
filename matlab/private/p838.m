function [ k, alpha ] = p838( f, theta, pol )
%p838 Recommendation ITU-R P.838-3
%   This function computes the rain regression coefficients k and alpha for
%   a given frequency, path inclination and polarization according to ITU-R
%   Recommendation P.838-3
%
%     Input parameters:
%     f        -   Frequency (GHz)
%     theta    -   Path inclination (radians)
%     pol      -   Polarization 0 = horizontal, 1 = vertical
%
%     Output parameters:
%     k, alpha -   Rain regression coefficients
%
%     Example:
%     [ k, alpha ] = p838( f, theta, pol )

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    14JUL16     Ivica Stevanovic, OFCOM         Initial version

if pol == 0 % horizontal polarization
    
    tau = 0;
    
else % vertical polarization
    
    tau = pi/2;

end

% Coefficients for kH
Table1 = [  -5.33980 -0.10008 1.13098
            -0.35351 1.26970 0.45400
            -0.23789 0.86036 0.15354
            -0.94158 0.64552 0.16817];

aj_kh = Table1(:,1);
bj_kh = Table1(:,2);
cj_kh = Table1(:,3);
m_kh = -0.18961;
c_kh = 0.71147;

% Coefficients for kV

Table2 = [  -3.80595 0.56934 0.81061
            -3.44965 -0.22911 0.51059
            -0.39902 0.73042 0.11899
            0.50167 1.07319 0.27195];
        
aj_kv = Table2(:,1);
bj_kv = Table2(:,2);
cj_kv = Table2(:,3);
m_kv = -0.16398;
c_kv = 0.63297;

% Coefficients for aH

Table3 = [  -0.14318 1.82442 -0.55187
            0.29591 0.77564 0.19822
            0.32177 0.63773 0.13164
            -5.37610 -0.96230 1.47828
            16.1721 -3.29980 3.43990];
        
aj_ah = Table3(:,1);
bj_ah = Table3(:,2);
cj_ah = Table3(:,3);
m_ah  = 0.67849;
c_ah  = -1.95537;

% Coefficients for aV

Table4 = [  -0.07771 2.33840 -0.76284
            0.56727 0.95545 0.54039
            -0.20238 1.14520 0.26809
            -48.2991 0.791669 0.116226
            48.5833 0.791459 0.116479];

aj_av = Table4(:,1);
bj_av = Table4(:,2);
cj_av = Table4(:,3);
m_av = -0.053739;
c_av = 0.83433;

logkh = sum(aj_kh.* exp(-((log10(f)-bj_kh)./cj_kh).^2)) + m_kh*log10(f) + c_kh;
kh = 10.^(logkh);

logkv = sum(aj_kv.* exp(-((log10(f)-bj_kv)./cj_kv).^2)) + m_kv*log10(f) + c_kv;
kv = 10.^(logkv);

ah = sum(aj_ah.* exp(-((log10(f)-bj_ah)./cj_ah).^2)) + m_ah*log10(f) + c_ah;

av = sum(aj_av.* exp(-((log10(f)-bj_av)./cj_av).^2)) + m_av*log10(f) + c_av;

k = (kh + kv + (kh - kv)*(cos(theta))^2 * cos(2*tau))/2;

alpha = (kh*ah + kv*av + (kh*ah - kv*av)*(cos(theta))^2 * cos(2*tau))/(2*k);


return
end



