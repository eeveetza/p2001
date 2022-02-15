function   [dct, dcr] = distance_to_sea(d, zone)
%distance_to_sea Distance to the sea in the direction of the other terminal
%     This function computes the distance from eacht terminal to the sea in
%     the direction of the other terminal
%
%     Input arguments:
%     d       -   vector of distances in the path profile
%     zone    -   vector of zones in the path profile
%                 4 - Inland, 3 - Coastal, 1 - See
%     
%     Output arguments:
%     dct      -  coast distance from transmitter
%     dcr      -  coast distance from receiver
%
%     Example:
%     [dct, dcr] = distance_to_sea(d, zone)

%     Rev   Date        Author                          Description
%     -------------------------------------------------------------------------------
%     v0    15JUL16     Ivica Stevanovic, OFCOM         Initial version

% Find the path profile points belonging to sea (zone = 1) starting from Tx

kk = find(zone == 1);

if isempty(kk) % complete path is inland or inland coast
    dct = d(end);
    dcr = d(end);
    
else
    nt = kk(1);
    nr = kk(end);
    
    if (nt == 1) % Tx is over sea
        dct = 0;
    else
        dct = (d(nt) + d(nt-1))/2 - d(1);
    
    end
    
    if (nr == length(zone)) % Rx is over sea
        dcr = 0;
    else
        dcr = d(end) - (d(nr) + d(nr + 1))/2;
        
    end

end
return
end