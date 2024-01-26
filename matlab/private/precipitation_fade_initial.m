function [a, b, c, dr, Q0ra, Fwvr, kmod, alpha_mod, G, P, flagrain] = precipitation_fade_initial(f, q, phi_n, phi_e, h_rainlo, h_rainhi, d_rain, pol_hv)
%precipitation_fade_initial Preliminary calculation of precipitation fading
%   This function computes the preliminary parameters necessary for precipitation
%   fading as defined in ITU-R P.2001-2 in Attachment C.2
%
%     Input parameters:
%     f        -   Frequency (GHz)
%     q        -   Percentage of average year for which predicted basic
%                  loss is exceeded (100-p)
%     phi_n    -   Latitude for obtaining rain climatic parameters (deg)
%     phi_e    -   Longitude for obtaining rain climatic parameters (deg
%     h_rainlo -   Lower height of the end of the path for a precipitation calculation (m)
%     h_rainlo -   Higher height of the end of the path for a precipitation calculation (m)
%     d_rain   -   Length of the path for rain calculation (km)
%     pol_hv   -   0 = horizontal, 1 = vertical polarization
%
%
%     Output parameters:
%     a, b, c  -   Parameters defining cumulative distribution of rain rate
%     dr       -   Limited path length for precipitation calculations
%     Q0ra     -   Percentage of an average year in which rain occurs
%     Fwvr     -   Factor used to estimate the effect of additional water vapour under rainy conditions
%     kmod     -   Modified regression coefficients
%     alpha_mod-   Modified regression coefficients
%     G        -   Vector of attenuation multipliers
%     P        -   Vector of probabilities
%     flagrain -   1 = "rain" path, 0 = "non-rain" path
%
%     Example:
%     [a, b, c, dr, Q0ra, Fwvr, kmod, alpha_mod, G, P, flagrain] = precipitation_fade_initial(f, q, phi_n, phi_e, h_rainlo, h_rainhi, d_rain, pol_hv)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    15JUL16     Ivica Stevanovic, OFCOM         Initial version
%     v1    13JUN17     Ivica Stevanovic, OFCOM         replaced load calls to increase computational speed
%     v2    07MAR18     Ivica Stevanovic, OFCOM         declared empty arrays G and P for no-rain path
%     v3    20APR23     Ivica Stevanovic, OFCOM         introduced get_interp2 to increase computational speed

%% C.2 Precipitation fading: Preliminary calculations

% Obtain Pr6 for phi_n, phi_e from the data file "Esarain_Pr6_v5.txt"
% as a bilinear interpolation

Pr6 = get_interp2('Esarain_Pr6',phi_e,phi_n);

% Obtain Mt for phi_n, phi_e from the data file "Esarain_Mt_v5.txt"
% as a bilinear interpolation

Mt = get_interp2('Esarain_Mt',phi_e,phi_n);

% Obtain beta_rain for phi_n, phi_e from the data file "Esarain_Beta_v5.txt"
% as a bilinear interpolation

beta_rain = get_interp2('Esarain_Beta',phi_e,phi_n);

% Obtain h0 for phi_n, phi_e from the data file "h0.txt"
% as a bilinear interpolation

h0 = get_interp2('h0',phi_e,phi_n);

% Calculate mean rain height hr (C.2.1)

hR = 360 + 1000*h0;

% calculate the highest rain height hRtop (C.2.2)

hRtop = hR + 2400;

if (Pr6 == 0 || h_rainlo >= hRtop)
    flagrain = 0; % no rain path
    Q0ra = 0;
    Fwvr = 0;
    a = [];
    b = [];
    c = [];
    dr = [];
    kmod = [];
    alpha_mod = [];
    Gm = [];
    Pm = [];
    G = Gm;
    P = Pm;
    
else % the path is classified as rain
    
    flagrain = 1;
    
    % Values from table C.2.1
    
    TableC21 = [-2400 0.000555
                -2300 0.000802
                -2200 0.001139
                -2100 0.001594
                -2000 0.002196
                -1900 0.002978
                -1800 0.003976
                -1700 0.005227
                -1600 0.006764
                -1500 0.008617
                -1400 0.010808
                -1300 0.013346
                -1200 0.016225
                -1100 0.019419
                -1000 0.022881
                -900 0.026542
                -800 0.030312
                -700 0.034081
                -600 0.037724
                -500 0.041110
                -400 0.044104
                -300 0.046583
                -200 0.048439
                -100 0.049589
                0 0.049978
                100 0.049589
                200 0.048439
                300 0.046583
                400 0.044104
                500 0.041110
                600 0.037724
                700 0.034081
                800 0.030312
                900 0.026542
                1000 0.022881
                1100 0.019419
                1200 0.016225
                1300 0.013346
                1400 0.010808
                1500 0.008617
                1600 0.006764
                1700 0.005227
                1800 0.003976
                1900 0.002978
                2000 0.002196
                2100 0.001594
                2200 0.001139
                2300 0.000802
                2400 0.000555];

    H =  TableC21(:,1);
    Pi = TableC21(:,2);
    
    % Calculate two intermediate parameters (C.2.3)
    
    Mc = beta_rain * Mt;
    Ms = (1 - beta_rain) *Mt;
    
    % Calculate the percentage of an average year in which rain occurs (C.2.4)
    
    Q0ra = Pr6 * (1 - exp(-0.0079*Ms/Pr6));
    
    % Calculate the parameters defining the cumulative distribution of rain
    % rate (C.2.5)
    
    a1 = 1.09;
    b1 = (Mc + Ms)/(21797*Q0ra);
    c1 = 26.02*b1;
    
    a = a1;
    b = b1;
    c = c1;
    
    % Calculate the percentage time approximating to the transition between
    % the straight and curved sections of the rain-rate cumulative
    % distribution when plotted ... (C.2.6)
    
    Qtran = Q0ra * exp(a1*(2*b1 - c1)/c1^2);
    
    
    % Path inclination angle (C.2.7)
    
    eps_rain = 0.001 * (h_rainhi-h_rainlo)/d_rain; % radians
    
    % Use the method given in Recommendation ITU-R P.838 to calculate rain
    % regression coefficients k and alpha for the frequency, polarization
    % and path inclination
    
    if f < 1 % compute theregression coefficient for 1 GHz
        
        [k1GHz, alpha1GHz] = p838( 1, eps_rain, pol_hv );
        k = f*k1GHz;        % Eq (C.2.8a)
        alpha = alpha1GHz;  % Eq (C.2.8b)
    else
    
        [ k, alpha ] = p838( f, eps_rain, pol_hv );
    
    end
    
    % Limit the path length for precipitation (C.2.9)
    
    dr = min(d_rain, 300);
    drmin = max(dr, 1);
    
    % Calculate modified regression coefficients (C.2.10)
    
    kmod = 1.763^alpha * k * (0.6546*exp(-0.009516*drmin) + 0.3499*exp(-0.001182*drmin));
    alpha_mod = (0.753 + 0.197/drmin) * alpha + 0.1572 * exp(-0.02268*drmin) - 0.1594 * exp(-0.0003617*drmin);
  
    % Initialize and allocate the arrays for attenuation multiplier and
    % probability of a particular case (with a maximum dimension 49 as in
    % table C.2.1
    
    Gm = zeros(length(TableC21),1);
    Pm = zeros(length(TableC21),1);
    
    % Initialize Gm(1)=1, set m=1
    
    Gm(1) = 1;
    
    m = 1;
    
    for n = 1:49
    % For each line of Table C.2.1 for n from 1 to 49 do the following
    
        % a) Calculate rain height given by  (C.2.11)
        hT = hR + H(n);    
        
        % b) If h_rainlo >= hT repeat from a) for the next avalue of n,
        % otherwise continue from c
        
        if h_rainlo >= hT
        
            continue  % repeat from a) for the next value of n
        
        end
        
        if h_rainhi > hT-1200
            % c.i) use the method in Attachment C.5 to set Gm to the
            % path-averaged multiplier for this path geometry relative to
            % the melting layer
            
            Gm(m) = path_averaged_multiplier(h_rainlo, h_rainhi, hT);
            
            % c.ii) set Pm = Pi(n) from Table C.2.1
            Pm(m) = Pi(n);
            
            % c.iii) if n < 49 add 1 to array index m
            
            if (n < 49)
                m = m + 1;
            end
            
            % c.iv) repeat fom a) for the next value of n
            
            continue;
            
        else
            
            % d) Accumulate Pi(n) from table C.2.1 into Pm, set Gm = 1 and
            % repeat from a) for the next value of n
            
            Pm(m) = Pm(m) + Pi(n);
            Gm(m) = 1;
        end
   
    end % for loop
    
    % Set the number of values in arrays Gm and Pm according to (C.2.12)
    
    Mlen = m;
    
    G = Gm(1:Mlen);
    P = Pm(1:Mlen);
    
    
    % Calculate a factor used to estimate the effect of additional water
    % vapour under rainy conditions (C.2.13), (C.2.14)
    
    Rwvr = 6*( log10(Q0ra/q) / log10(Q0ra/Qtran) ) - 3;
    
    Fwvr = 0.5*(1+tanh(Rwvr))*sum(G.*P);
    
end


return
end
