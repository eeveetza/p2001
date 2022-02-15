function AiterQ = Aiter(q, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain)
%Aiter Inverse cumulative distribution function of a propagation model
%   This function computes the inverse cumulative distribution function of a
%   propagation model as defined in ITU-R P.2001-2 in Attachment I
%
%     Input parameters:
%     q        -   Percentage of average year for which predicted
%                  transmission loss is exceeded
%     Q0ca     -   Notional zero-fade annual percentage time
%     Q0ra     -   Percentage of an average year in which rain occurs
%     flagtropo-   0 = surface path, 1 = tropospheric path
%     a, b, c  -   Parameters defining cumulative distribution of rain rate
%     dr       -   Limited path length for precipitation calculations
%     kmod     -   Modified regression coefficients
%     alpha_mod-   Modified regression coefficients
%     Gm       -   Vector of attenuation multipliers
%     Pm       -   Vector of probabilities
%     flagrain -   1 = "rain" path, 0 = "non-rain" path
%
%     Output parameters:
%     AiterQ   -   Attenuation level of a propoagation mechanisms exceeded
%                  for q% time
%     
%
%
%     Example:
%     AiterQ = Aiter(q, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    15JUL16     Ivica Stevanovic, OFCOM         Initial version


%% Attachment I. Iterative procedure to invert cumulative distribution function

% Set initial values of the high and low searc hlimits for attenuation and
% the attenuation step size

Ainit = 10;

Ahigh = Ainit/2;                                                          % Eq (I.2.1)

Alow = -Ainit/2;                                                          % Eq (I.2.2)

Astep = Ainit;                                                            % Eq (I.2.3)

% Initialize the percentage times attenuations Ahigh and Alow are exceeded
% (I.2.4)

qhigh = Qiter(Ahigh, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);

qlow =  Qiter(Alow, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);

%% Stage 1

count = 0;

if (q < qhigh || q > qlow)
    
    while(count < 11)
        count = count + 1;
        
        if (q < qhigh)
            
            Alow = Ahigh;
            qlow = qhigh;
            Astep = 2 * Astep;
            Ahigh = Ahigh + Astep;
            qhigh = Qiter(Ahigh, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);
            continue % Loop back to the start of search range iteration and repeat from there
        end
        
        if (q > qlow)
            
            Ahigh = Alow;
            qhigh = qlow;
            Astep = 2 * Astep;
            Alow = Alow - Astep;
            qlow = Qiter(Alow, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);
            continue % Loop back to the start of search range iteration and repeat from there
        end
        
    end % Initial search range iteration
    
end  % only if q < qhigh and q > qlow


%% Stage 2: Binary search

% Evaluate Atry (I.2.5)

Atry = 0.5*(Alow + Ahigh);

% Start of binary search iteration
% Set the binary search accuracy

Aacc = 0.01;

Niter = ceil(3.32*log10(Astep/Aacc));

count = 0;

while (count <= Niter)
    count = count + 1;
    
    % Calculate the percentage time attenuation Atry is exceeded (I.2.6)
    
    qtry = Qiter(Atry, Q0ca, Q0ra, flagtropo, a, b, c, dr, kmod, alpha_mod, Gm, Pm, flagrain);
    
    if qtry < q 
        Ahigh = Atry;
    else
        Alow = Atry;
    end
    
    Atry = 0.5*(Alow + Ahigh);
    
end  % Loop back to the start of binary search iteration and repeat from there
    
AiterQ = Atry;

return
end
