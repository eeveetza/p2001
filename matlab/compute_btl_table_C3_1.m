% This script computes the basic transmissino loss according to ITU-R
% P.2001-4 (using tl_p2001.m) for those path profiles in the table C3_1
% which have complete set of input parameters.
% 1) The script reads the data from table C3_1 including the measured basic
% transmission losses using read_data_table_C3_1()
% 2) The script also reads the terrain profile data from
% the folder ./C3_1_profiles/*.csv provided by Stephen Salamon using
% read_C3_1_profile()
% 3) As the terrain profile data does not contain the information about the
% zone code, DigitalMaps_TropoClim.m is used to deterine whether the point
% in the terrain profile belongs to land (4) (for codes 1-6) or sea (1)
% (for code 0). This script does not distinguish coastal zone.
% 4) Basic transmission loss computatins are performed only for the terrain
% profile data for which the complete information (including antenna
% heights above ground at Tx/Rx site) is available. Other profiles are
% ignored.

clear all
close all
clc

% presenting results with rounding off to 1 digit
rd = 1;

% discard the results with deviation larger than discard
discard = 25;


% 1) The script reads the data from table C3_1 including the measured basic
% transmission losses using read_data_table_C3_1()

filename = 'C3_1_profiles/C3_1_v1clearTransHorizon200703revised201708.xls';

stano = read_data_table_C3_1(filename);


for pp = 1:2 % once with and once without PDR
    
    count = 1;
    
    for i = 1:length(stano)
        %for i = 22:23
        
        if (pp == 1)
            pdr = false;
            fprintf(1,'First round, applying P.2001-4\n');
            
        else
            pdr = true;
            fprintf(1,'Second round, applying P.2001-4 PDR\n');
        end
        
        % if certain necessary data are not available for a given link, skip
        %% Tx data
        if (isnan(stano{i}.tx.lat))
            warning(['Tx Latitude missing. Skipping station number: ' num2str(stano{i}.number)])
            continue;
        end
        
        if (isnan(stano{i}.tx.lon))
            warning(['Tx Longitude missing. Skipping station number: ' num2str(stano{i}.number)])
            continue;
        end
        
        if (isnan(stano{i}.tx.ahag))
            warning(['Tx antenna height above ground missing. Skipping station number: ' num2str(stano{i}.number)])
            continue;
            %          warning(['Tx antenna height above ground missing. Set to 1 m: ' num2str(stano{i}.number)])
            %          stano{i}.tx.ahag = 1;
        end
        
        if (isnan(stano{i}.tx.g))
            warning(['Tx antenna gain missing. Skipping station number: ' num2str(stano{i}.number)])
            continue;
            %          warning(['Tx antenna gain missing. Set to zero: ' num2str(stano{i}.number)])
            %          stano{i}.tx.g = 0;
        end
        
        %% Rx data
        if (isnan(stano{i}.rx.lat))
            warning(['Rx Latitude missing. Skipping station number: ' num2str(stano{i}.number)])
            continue;
        end
        
        if (isnan(stano{i}.rx.lon))
            warning(['Rx Longitude missing. Skipping station number: ' num2str(stano{i}.number)])
            continue;
        end
        
        if (isnan(stano{i}.rx.ahag))
            warning(['Rx antenna height above ground missing. Skipping station number: ' num2str(stano{i}.number)])
            continue;
            %          warning(['Rx antenna height above ground missing. Set to 1 m: ' num2str(stano{i}.number)])
            %          stano{i}.rx.ahag = 1;
        end
        
        if (isnan(stano{i}.rx.g))
            warning(['Rx antenna gain missing. Skipping station number: ' num2str(stano{i}.number)])
            continue;
            %         warning(['Rx antenna gain missing. Set to zero: ' num2str(stano{i}.number)])
            %         stano{i}.rx.g = 0;
        end
        
        
        % 2) The script also reads the terrain profile data from
        % the folder ./C3_1_profiles/*.csv provided by Stephen Solomon using
        % read_C3_1_profile()
        
        filename = ['./C3_1_profiles/3_1_' num2str(stano{i}.number,'%04.f') '.csv'];
        
        try
            struct = read_C3_1_profile(filename);
        catch
            warning(['File not found. Skipping station number: ' num2str(stano{i}.number)])
            continue
        end
        % 3) As the terrain profile data does not contain the information about the
        % zone code, DigitalMaps_TropoClim.m is used to deterine whether the point
        % in the terrain profile belongs to land (4) (for codes 1-6) or see (1)
        % (for code 0). This script does not distinguish coastal zone.
        
        z = zeros(size(struct.h));
        
        %% E.2 Climatic classification
        
        latcnt = 89.75:-0.5:-89.75;           %Table 2.4.1
        loncnt = -179.75: 0.5: 179.75;        %Table 2.4.1
        
        % Obtain TropoClim for tx.the, tx.phi from the data file "TropoClim.txt"
        
        %TropoClim = load('DigitalMaps/TropoClim.txt');
        TropoClim = DigitalMaps_TropoClim();
        
        for kk = 1:length(struct.d)
            
            % The value at the closest grid point to phicvn, phicve should be taken
            phicvn = struct.the(kk);
            phicve = struct.phi(kk);
            
            knorth = find (abs(phicvn - latcnt) == min(abs(phicvn-latcnt)));
            keast = find (abs(phicve - loncnt) == min(abs(phicve-loncnt)));
            
            climzone = TropoClim(knorth(1), keast(1));
            
            if climzone == 0
                z(kk) = 1; % see
            else
                z(kk) = 4; % land
            end
            
            
        end
        
        clear TropoClim
        
        % collect measured data for the given link i
        
        t_all = stano{i}.t;
        pl_all = stano{i}.btl;
        
        k = find(~isnan(pl_all));
        
        t = t_all(k);
        pl = pl_all(k);
        
        fprintf(1,'\n');
        fprintf(1,'Station No.: %d\n', stano{i}.number);
        
        if (isempty(t))
            warning(['No information on time percentage data. Skipping station number: ' num2str(stano{i}.number)])
            continue;
        end
        
        for it = 1:length(t)
            
            Tpc = t(it);
            Phire = struct.rx.phi;
            Phirn = struct.rx.the;
            Phite = struct.tx.phi;
            Phitn = struct.tx.the;
            Hrg = struct.rx.ahag;
            Htg = struct.tx.ahag;
            Grx = struct.rx.g;
            Gtx = struct.tx.g;
            %         Hrg = stano{i}.rx.ahag;
            %         Htg = stano{i}.tx.ahag;
            %         Grx = stano{i}.rx.g;
            %         Gtx = stano{i}.tx.g;
            FlagVP = 0;  % vertical polarization
            p2001 = tl_p2001(struct.d, struct.h, z, struct.f, Tpc, Phire, Phirn, Phite, Phitn, Hrg, Htg, Grx, Gtx, FlagVP, pdr);
            
            L = -5*log10(10^(-0.2*p2001.Lbs) + 10^(-0.2*p2001.Lba));
            
            fprintf(1,'Time percentage: %g %%\n', t(it));
            fprintf(1,'Measured basic tl: %g dB\n', pl(it));
            fprintf(1,'Simulated basic tl: %g dB\n', L);
            fprintf(1,'Error: %g dB\n', p2001.Lb - pl(it));
            fprintf(1,'\n');
            

            result{pp}{count}.statno = stano{i}.number;
            result{pp}{count}.t = t(it);
            result{pp}{count}.plm = round(pl(it),rd);
            result{pp}{count}.pls = round(L,rd);
            result{pp}{count}.pls_total = round(p2001.Lb,rd);
            result{pp}{count}.delta = round(p2001.Lb - pl(it),rd);
            count = count + 1;
        end
        
    end
    
end
filename_out = 'Results_Table_C3_1_P2001.xls';

fprintf(1,'%10s  %10s  %20s  %20s  %20s  %20s  %20s\n','Stat. no.', 't (%)', 'Measured PL (dB)', 'P.2001 (dB)', 'PDR (dB)', 'PE P.2001 (dB)', 'PE PDR (dB)');

A = {'Stat. no.', 't (%)', 'Measured PL (dB)', 'P.2001 (dB)', 'PDR (dB)', 'PE P.2001 (dB)', 'PE PDR (dB)'};


for kk = 1:length(result{1})
    fprintf(1,'%10d  %10g  %20g  %20g  %20g  %20g  %20g\n', result{1}{kk}.statno, result{1}{kk}.t, result{1}{kk}.plm, result{1}{kk}.pls_total, result{2}{kk}.pls_total, result{1}{kk}.delta, result{2}{kk}.delta);
    
    row = {result{1}{kk}.statno, result{1}{kk}.t, result{1}{kk}.plm, result{1}{kk}.pls_total, result{2}{kk}.pls_total, result{1}{kk}.delta, result{2}{kk}.delta};
     if (abs(result{1}{kk}.delta) < discard && abs(result{2}{kk}.delta) < discard)
         A = [A; row];
     end
    
end

tout = [99 90 50 30 10 3 1 0.3 0.1];


if exist(filename_out,'file')
    
    % if the file already exist, delete it
    [status, result1] = system(['del ' filename_out]);
    fprintf(1,'Rewriting the existing file: %s\n', filename_out);
    
end

fprintf(1,'Writing the results in file: %s\n', filename_out);
for tt = 1:length(tout)
    clear B
    % 
    kk = find([A{2:end,2}] == tout(tt))+1;
    page = ['p = ' num2str(tout(tt)) '%'];
    B = A(1,:);
    B = [B; A(kk, :)];
    
    delta1 = [B{2:end,4}]-[B{2:end,3}];
    delta2 = [B{2:end,5}]-[B{2:end,3}];
    row = {'ME', ' ', ' ' , ' ', ' ', round(mean((delta1)),rd), round(mean((delta2)),rd)};
    B = [B; row];
    row = {'RMSE', ' ', ' ' , ' ', ' ', round(sqrt(mean((delta1).^2)),rd), round(sqrt(mean((delta2).^2)),rd)};
    B = [B; row];
    xlswrite(filename_out, B, page);
end