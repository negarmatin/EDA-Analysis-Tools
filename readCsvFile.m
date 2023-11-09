
% Use this code to convert the csv files imported from Empatica into a
% single csv file called 'reformatted_data'
    
% Once imported to Ledalab, the new csv file will allow to see the EDA data, in addition to the event
% markers

% used the following as source: https://github.com/pefortin/Empatica-Ledalab/blob/master/empatica2ledalab.m


readCsvFile2(2);
% calling the function, with the type 2 file as input

 
function [] = readCsvFile2(o_type)
% Converts empatica connect output format to ledalab format (type 2 or 3 as defined by o_type).
% Uses EDA.csv and tags.csv and output a single csv with timestamp, eda and events (0/1) 

% Select directory containing the unzipped Empatica CSVs. (ACC, BVP, EDA, HR, etc.)
folder_name = uigetdir('', 'Select the directory containing the .csv files as generated by Empatica Connect');

% Read EDA and tags CSV files
EDA = csvread(fullfile(folder_name, 'EDA.csv'));
try
    tags = csvread(fullfile(folder_name, 'tags.csv'));
catch
    fprintf('ERROR: The new file was not generated!\n')
    fprintf('tags.csv seems to be empty.\n')
    fprintf('If there are no tagged events, you can directly import in Ledalab without readCsvFile.\n')
    return
end



% Adjust column positions
data_t(:,2) = EDA(4:end);
data_t(1,1) = EDA(1);
Ts = 1/EDA(2); %Time steps = 1/sampling frequency

% Place 0 as a default event for all timestamps
data_t(:,3) = zeros(length(data_t),1);

% Add timestamp to all rows
for(n=2:length(data_t))
    data_t(n,1)=data_t(1,1)+Ts*(n-1);
end

% Add an event at the closest timestamps (rounded upwards always)
% E.g.  timestamps 14, 15, 16, 17 and an event registered at 14.139
% would go to 15.
for k=1:length(tags)
    data_t(length(find(data_t(:,1)<tags(k))),3)=1;
end



switch o_type
    
    case 2
        data = data_t(:,2:3);
    case 3
        data = data_t;
end

% Write newly formated data to CSV file
csvwrite(fullfile(folder_name,'reformatted_data.csv'), data);
fprintf('Empatica csv: EDA.csv and tags.csv \nFrom %s\nGenerated Ledalab TYPE %i text file:%s\n', folder_name, o_type, fullfile(folder_name, 'reformatted_data.csv'))


end


