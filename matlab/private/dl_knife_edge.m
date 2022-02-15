function J = dl_knife_edge(nu)
%dl_knife_edge Knife edge diffraction loss
%   This function computes knife-edge diffraction loss in dB
%   as defined in ITU-R P.2001-2 Section 3.12
%
%     Input parameters:
%     nu      -   dimensionless parameter
%
%     Output parameters:
%     J       -   Knife-edge diffraction loss (dB)
%     
%     Example J = dl_knife_edge(nu)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    13JUL16     Ivica Stevanovic, OFCOM         Initial version

J = 0;

if nu > -0.78
    J = 6.9 + 20*log10( sqrt((nu-0.1)^2+1) + nu - 0.1 );
end

return
end
