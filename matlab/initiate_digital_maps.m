% This Recommendation uses integral digital products. They form an integral
% part of the recommendation and may not be reproduced, by any means whatsoever,
% without written permission of ITU.
%
% The user should download the necessary digital maps that are used by this
% implementation directly from ITU-R web site and place the files in the
% folder ./private/maps. After that, the user should execute the script
% contained in this file "initiate_digital_maps.m". The script produces the
% necessary functions that contain the digital maps and are used for
% interpolations.
% The following maps should be extracted in the folder ./private/maps:
% From https://www.itu.int/dms_pubrec/itu-r/rec/p/R-REC-P.2001-4-202109-S!!ZIP-E.zip
%  DN_Median.txt              Esarain_Mt_v5.txt	FoEs10.txt		h0.txt
%  DN_SubSlope.txt            Esarain_Pr6_v5.txt	FoEs50.txt		surfwv_50_fixed.txt
%  DN_SupSlope.txt            FoEs0.1.txt		    TropoClim.txt
%  Esarain_Beta_v5.txt        FoEs01.txt		    dndz_01.txt
% From [ITU-R P.452-18](https://www.itu.int/dms_pubrec/itu-r/rec/p/R-REC-P.452-18-202310-I!!ZIP-E.zip):
%  N050.TXT, DN50.TXT


files = {'N050.TXT', 'DN50.TXT', 'DN_Median.txt', 'Esarain_Mt_v5.txt', 'FoEs10.txt', 'h0.txt' ...
         'DN_SubSlope.txt', 'Esarain_Pr6_v5.txt', 'FoEs50.txt',	'surfwv_50_fixed.txt' ...
         'DN_SupSlope.txt',	'FoEs0.1.txt', 'TropoClim.txt', 'Esarain_Beta_v5.txt', ...
     	 'FoEs01.txt', 'dndz_01.txt'};

for i  = 1 : length(files)

    xx = files{i};
    filename = ['private/maps/' xx];
    if strcmp(xx, 'FoEs0.1.txt')
        xx = 'FoEs0p1.txt';
    end
    functionname = ['DigitalMaps_' xx(1:end-4)];

    filename_m = ['private/' functionname '.m'];

    if ~isfile(filename_m)

        fprintf(1, "Processing file: %s --> %s...\n", filename, filename_m);

        % verify that the file does not exist

        % read the file

        fid = fopen(filename, "r");

        if(fid==-1)
            errorstr = sprintf('Download and extract the required map %s from ITU-R P.2001-4 to ./private/maps', xx);
            error(errorstr);

        end

        datastr = [];

        while (1)

            line = fgetl(fid);

            if (line == -1)
                break;
            end

            datastr = [datastr line '\n'];

        end

        fclose(fid);

        % write the data in the function.m

        fid = fopen(filename_m, 'w');


        datastr_before = ['function y = ' functionname '()\n' ...
            '%%%% ' functionname ' returns values from the table ' files{i} ,'\n' ...
            '\n' ...
            '\n' ...
            'y = [' ];

        datastr_after = [ '];\n' ...
            'return\n' ...
            'end\n'];

        fprintf(fid, datastr_before);
        fprintf(fid, datastr);
        fprintf(fid, datastr_after);
    end
end