% MATLAB/Octave script that is used to verify the implementation of
% Recommendation ITU-R P.P2001-4 (as defined in the file tl_p2001.m and the
% functions called therefrom) using a set of test terrain profiles provided by the user.
%
% The script reads all the test profiles from the folder defined by
% the variable <test_profiles>, calculates path profile parameters and
% compares the computed basic transmission loss with the reference ones.

% Author: Ivica Stevanovic (IS), Federal Office of Communications, Switzerland
% Revision History:
% Date            Revision
% 16FEB22         Created - transliterated validation examples using .csv instead of .xlsx
%                 Created new validate_p2001.m that handles .csv files
%                 These are meant to replace the previous version working
%                 with Excel files. The advantage: it works in both MATLAB
%                 and Octave, Windows and MacOS and it is easier to diff
% 13JUL21         Renaming subfolder "src" into "private" which is automatically in the MATLAB search path
%                                                       (as suggested by K. Konstantinou, Ofcom UK)
% 05JUN2020       Introduced Octave specific code (with M. Rohner, LS telcom)
% 16JUN2016       Initial version (IS)




clear all;
close all;
fclose all;

tol = 1e-6;
success = 0;
total = 0;

pdr = true;

%% compute the path profile parameters
s = pwd;

% path to the folder containing test profiles
test_profiles = [s '/validation_examples/'];
test_results  = [s '/validation_results/'];



%% begin code
% Collect all the filenames .csv in the folder pathname that contain the profile data
filenames = dir(fullfile(test_profiles, '*.csv')); % filenames(i).name is the filename


% start excel application
if(isOctave)
    pkg load windows
end

for iname = 1 : length(filenames)
    
    filename1 = filenames(iname).name;
    
    if (strfind(filename1, 'results'))
        continue
    end
    
    
    fprintf(1,'***********************************************\n');
    fprintf(1,'Processing file %s ...\n', filename1);
    fprintf(1,'***********************************************\n');
    % otherwise, read the profile and the results
    
    failed = false;
    
    
    % this file contains path profile
    clear d h z
    % read the path profile
    X = readcsv([test_profiles  filename1]);
    
    d = str2double( X(9:end,1) );
    h = str2double( X(9:end,2) );
    z = str2double( X(9:end,3) );
    
    
    
    % read the input arguments and reference values
    filename2 = [filename1(1:end-12) '_results.csv'];
    Y = readcsv([test_profiles  filename2]);
    
    
    [nrows, ncols] = size(Y);
    
    
    GHz = zeros(nrows,1);
    Tpc = zeros(nrows,1);
    Phire = zeros(nrows,1);
    Phirn = zeros(nrows,1);
    Phite = zeros(nrows,1);
    Phitn = zeros(nrows,1);
    Hrg = zeros(nrows,1);
    Htg = zeros(nrows,1);
    Grx = zeros(nrows,1);
    Gtx = zeros(nrows,1);
    FlagVP = zeros(nrows,1);
    Profile = cell(nrows,1);
    Lb_ref = zeros(nrows,1);
    Lbs_ref = zeros(nrows,1);
    delta = zeros(nrows,1);
    delta1 = zeros(nrows,1);
    
    for i = 1:nrows
        GHz(i)    = str2double(Y(i,2));
        Tpc(i)    = str2double(Y(i,11));
        Phire(i)    = str2double(Y(i,7));
        Phirn(i)    = str2double(Y(i,8));
        Phite(i)    = str2double(Y(i,9));
        Phitn(i)    = str2double(Y(i,10));
        Hrg(i)    = str2double(Y(i,5));
        Htg(i)    = str2double(Y(i,6));
        Grx(i)    = str2double(Y(i,3));
        Gtx(i)    = str2double(Y(i,4));
        FlagVP(i)    = str2double(Y(i,1));
        Profile{i} = Y{i,12};
        
        Lb_ref(i)    = str2double(Y(i,79));
        Lbs_ref(i) = str2double(Y(i, 88 ));

    end
    
    A = cell(nrows+1,ncols);
    
    A(1,:) = {'FlagVp', 'GHz', 'Grx', 'Grt', 'Hrg', 'Htg', 'Phire', 'Phirn',  'Phite', ...
        'Phitn', 'Tpc',	'Profile',	'FlagLos50', 'FlagLospa', 'FlagLosps', 'FlagSea', ...
        'FlagShort', 'A1', 'A2', 'A2r',	'A2t',	'Aac',	'Aad',	'dAat',	'Ags',	'Agsur', ...
        'Aorcv', 'Aos',	'Aosur', 'Aotcv', 'Awrcv',	'Awrrcv', 'Awrs', 'Awrsur',	'Awrtcv', ...
        'Aws', 'Awsur',	'Awtcv', 'Bt2rDeg',	'Cp', 'D',	'Dcr',	'Dct',	'Dgc',	'Dlm', ...
        'Dlr',	'Dlt',	'Drcv',	'Dtcv',	'Dtm',	'Foes1', 'Foes2', 'Fsea', 'Fwvr', 'Fwvrrx',	'Fwvrxt', ...
        'GAM1',	'GAM2',	'Gamo',	'Gamw',	'Gamwr', 'H1', 'Hcv', 'Hhi', 'Hlo',	'Hm', 'Hmid', ...
        'Hn', 	'Hrea',	'Hrep',	'Hrs',	'Hsrip',	'Hsripa',	'Hstip',	'Hstipa',	'Htea', ...
        'Htep',	'Hts',	'Lb',	'Lba',	'Lbes1',	'Lbes2',	'Lbfs',	'Lbm1',	'Lbm2',	'Lbm3',	...
        'Lbm4',	'Lbs',	'Ld',	'Ldba',	'Ldbka',    'Ldbks',	'Ldbs',	'dLdsph',	'Lp1r',	'Lp1t', ...
        'Lp2r',	'Lp2t',	'Mses',	'N',	'Nd1km50',	'Nd1kmp',	'Nd65m1',	'Nlr',	'Nlt',	'Nsrima',...
        'Nsrims',	'Nstima',	'Nstims',	'Phi1qe',	'Phi1qn',	'Phi3qe',	'Phi3qn',	'Phicve', ...
        'Phicvn',	'Phime',	'Phimn',	'Phircve',	'Phircvn',	'Phitcve',	'Phitcvn',	'Qoca', ...
        'Reff50',	'Reffp',	'Sp',	'Thetae',	'Thetar',	'Thetarpos',	'Thetas',	'Thetat', ...
        'Thetatpos',	'Tpcp',	'Tpcq',	'Tpcscale',	'Wave',	'Wvsur',	'WvSurrx',	'WvSurtx',	'Ztropo'};
    
    filename_out = [filename1(1:end-12) '_OFCOM_results.csv'];
    filename = [test_results  filename_out];
    fid = fopen(filename, 'w');
    if (fid == -1)
        error(['Cannot open file ' filename '.']);
    end
    
    
    for i = 1 : nrows
        
        if i == 1
            disp(['Processing ' num2str(i) '/' num2str(nrows) ', GHz = ' num2str(GHz(i)) ' GHz,  Tpc = ' num2str(Tpc(i)) '% - ' num2str(Tpc(end)) '% ...']);
        end
        if i > 1
            if(GHz(i)>GHz(i-1))
                disp(['Processing ' num2str(i) '/' num2str(nrows) ', GHz = ' num2str(GHz(i)) ' GHz,  Tpc = ' num2str(Tpc(i)) '% - ' num2str(Tpc(end)) '% ...']);
            end
        end
        
        p2001 = tl_p2001(d, h, z, GHz(i), Tpc(i), Phire(i), Phirn(i), Phite(i), Phitn(i), ...
            Hrg(i), Htg(i), Grx(i), Gtx(i), FlagVP(i), pdr);
        
        
        row = [...
            FlagVP(i), ...
            GHz(i), ...
            Grx(i), ...
            Gtx(i), ...
            Hrg(i), ...
            Htg(i), ...
            Phire(i), ...
            Phirn(i), ...
            Phite(i), ...
            Phitn(i), ...
            Tpc(i), ...
            Profile{i}, ...
            struct2cell(p2001).'
            ];
        A(i+1,:) = row;
        
        delta(i) = abs(p2001.Lb - Lb_ref(i));
        delta1(i) = p2001.Lb - Lb_ref(i);
    end
    
    if (iname == 1)
        figure(1)
        plot(Lb_ref, Lb_ref+delta1,'b.')
        hold on
        [ff1,xx1] = ksdensity(delta1);
        figure(3)
        histogram(delta1);
        grid on
        xlabel('L_{pdr p.2001} - L_{p.2001} (dB)')
        title('Profile: b2iseac')

        figure(5)
        plot(d,h)
        xlabel('d (km)')
        ylabel('h (m)');
        title('Profile: b2iseac')
        grid on
        
    else
        figure(2)
        plot(Lb_ref, Lb_ref + delta1, 'r.')
        hold on
        [ff2,xx2] = ksdensity(delta1);
        figure(4)
        histogram(delta1)
        grid on
        xlabel('L_{pdr p.2001} - L_{p.2001} (dB)')
        title('Profile: prof4')

        figure(6)
        plot(d,h)
        xlabel('d (km)')
        ylabel('h (m)');
        title('Profile: prof4')
        grid on
    end
    figure(1)
    set(gca,'XLim', [80,250]);
    set(gca,'YLim', [80,250]);
    xlabel('L_{p.2001} (dB)');
    ylabel('L_{pdr p.2001} (dB)' );
    title('Profile: b2iseac')
    plot(Lb_ref,Lb_ref,'k-')
    plot(Lb_ref,Lb_ref-10, 'Color', [0.5, 0.5 0.5])
    plot(Lb_ref,Lb_ref+10, 'Color', [0.5, 0.5 0.5])
    
    grid on
    hold on

    figure(2)
    set(gca,'XLim', [90,300]);
    set(gca,'YLim', [90,300]);
    xlabel('L_{p.2001} (dB)');
    ylabel('L_{pdr p.2001} (dB)' );
    title('Profile: prof4')
    plot(Lb_ref,Lb_ref,'k-')
    plot(Lb_ref,Lb_ref-10, 'Color', [0.5, 0.5 0.5])
    plot(Lb_ref,Lb_ref+10, 'Color', [0.5, 0.5 0.5])
    
    grid on
    hold on


    for i = 1 : nrows+1
        
        if i == 1
            % the whole row is cell of strings
            fprintf(fid,'%s\n', strjoin(A(i,:), ','));
        else
            % the cell in cols 12 106-109 are strings, the rest are numbers
            
            X = A(i,:);
            Xstr = cellfun(@(x) num2str(x,16), X, 'UniformOutput', false);
            fprintf(fid,'%s\n', strjoin(Xstr, ','));
            
        end

    end
    
    kk = find(abs(delta) > tol);
    if ~isempty(kk)
        for kki = 1:length(kk)
            fprintf(1,'Maximum deviation found in step %d larger than tolerance %g:  %g   %g\n', kk(kki), tol, delta(kk(kki)), Lb_ref(kk(kki)));
            failed = true;
        end
    end
    
    if (~failed)
        success = success + 1;
    end

    total = total + 1;
    %
    
    fclose(fid);
    
    disp(['Results are written in the file: ' filename_out]);
end


fprintf(1,'Validation results: %d out of %d tests passed successfully.\n', success, total);
if (success == total)
    fprintf(1,'The deviation from the reference results is smaller than %g dB.\n', tol);
end