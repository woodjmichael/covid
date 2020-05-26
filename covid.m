%% covid.m

% v1 3/24 - italy seems to be off, didn't check others

clear all
clc

lastday = 23;

italia = pull_data(0, lastday);

lecco = pull_data(53, lastday);

bergamo = pull_data(49, lastday);

milano = pull_data(56, lastday);

torino = pull_data(76, lastday);

bari = pull_data(80, lastday);

reggio_emiglia = pull_data(30, lastday);

t=1:length(lecco);

plot(t,100*italia(:,3),'--',t,100*milano(:,3),t,100*lecco(:,3),t,100*bergamo(:,3),t,100*reggio_emiglia(:,3))
legend('italy','milano','lecco','bergamo','reggio emiglia')
ylabel('per unit increase in total cases')
xlabel('march')
ytickformat('percentage')
ylim([0 100])
xlim([lastday-14 lastday])

function result = pull_data(prov, lastday)

    row=1;
    prev_cases = 0;
    delta=0;

    m=2;
    for d = 24:29
        result(row,:) = loadAndLook(m,d,prov);
        cases(row) = result(row,2);
        delta(row) = result(row,2) - prev_cases;

        if prev_cases > 0
            pct(row) = delta(row)/prev_cases;
        else
            pct(row) = 0;
        end       

        prev_cases = result(row,2);
        row = row+1;
    end

    m=3;
    for d = 1:lastday
        result(row,:) = loadAndLook(m,d,prov);
        cases(row) = result(row,2);    
        delta(row) = result(row,2) - prev_cases;

        if prev_cases > 0
            pct(row) = delta(row)/prev_cases;
        else
            pct(row) = 0;
        end           

        prev_cases = result(row,2);
        row = row+1;
    end    

    result = [cases' delta' pct'];    
    
end



function result = loadAndLook(m, d, prov)


    %% Initialize variables.

    dateStr = sprintf('2020%02u%02u',m,d);    
    delimiter = ',';
    startRow = 2;
    
    if prov == 0
        filename = strcat('/Users/mjw/Google Drive/Code/covid/dpc-covid19-ita-regioni-',dateStr,'.csv');
    else
        filename = strcat('/Users/mjw/Google Drive/Code/covid/dpc-covid19-ita-province-',dateStr,'.csv');
    end    

    %% Format for each line of text:
    %   column1: categorical (%C)
    %	column2: categorical (%C)
    %   column3: double (%f)
    %	column4: categorical (%C)
    %   column5: double (%f)
    %	column6: text (%s)
    %   column7: text (%s)
    %	column8: double (%f)
    %   column9: double (%f)
    %	column10: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%C%C%f%C%f%s%s%f%f%f%[^\n\r]';

    %% Open the text file.
    fileID = fopen(filename,'r','n','UTF-8');
    % Skip the BOM (Byte Order Mark).
    fseek(fileID, 3, 'bof');

    %% Read columns of data according to the format.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

    %% Close the text file.
    fclose(fileID);

    %% Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.

    %% Create output variable
    T = table(dataArray{1:end-1}, 'VariableNames', {'data','stato','codice_regione','denominazione_regione','codice_provincia','denominazione_provincia','sigla_provincia','lat','long','totale_casi'});

    %% Clear temporary variables
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
    if prov == 0
        code = 0;
        cases = sum(T.totale_casi);
        result = [code cases];
    else
        code = T.codice_provincia(prov); 
        cases = T.totale_casi(prov);
        result = [code cases];
    end
    

end