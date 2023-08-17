    foldername = uigetdir('Select a folder');
    original_files=dir([foldername '/*.txt']);
    % Create a new excel database in folder in advance
    list = {'ID','Diagnosis','CAG repeats','Sequence','Raw Data'};
    dataName = input('Name of new database: ', 's'); % Prompt user for database name
    new_database = sprintf('%s.xlsx', dataName);
    fullFileName = fullfile(foldername, new_database); % Create the file full path in the designated folder
    xlswrite(fullFileName ,list); % Create file in folder

    % Create the first column
    a = 10:10:30;
    graphMatrix = zeros(length(a)+1, 2);
  for i=1:length(a)
    k = a(i);
        tic;
        %Create a database memory
        dataMemory = cell(k,length(list));
        %Extract the file names without extensions & save to memory
        fileNames = {original_files(1:k).name}';  % Extract file names
        pre_dataID = cellstr(fileNames);  % Convert to cell array of strings
        %pre_dataID = {original_files.name}';
        dataID = cellfun(@(x) x(1:end-4), pre_dataID, 'UniformOutput', false);
        dataMemory(:,1) = dataID;
        %Extract sequences from files & check validity of sequences
        dataContents = arrayfun(@(x) fileread(fullfile(foldername,x.name)),original_files(1:k),'UniformOutput',false);
        dataSeq = cellfun(@check_sequence, dataContents);
        NAposition = find(strcmp(dataSeq,'N/A'));
    
        %Save the raw sequences to the database memory
        dataMemory(:,5) = dataSeq;
        dataFolder = num2cell(repmat({foldername},length(original_files(1:k)),1));
    
        %Run the sequence to full_analysis
        [dataSeqcut, dataDiagnosis, dataRepeats] = cellfun(@full_analysis,dataSeq,dataID,dataFolder);
        dataMemory(:,2) = dataDiagnosis;
        dataMemory(:,3) = dataRepeats;
        dataMemory(:,4) = dataSeqcut;
        
        range= sprintf('A2:E%d', 2+length(original_files(k))-1);
        writecell(dataMemory, fullFileName,'WriteMode','append' );
      
        % Capture the elapsed time
        elapsedTime = toc;
        
        % Create the second column
        % b(i)= ones(size(a(i))) * elapsedTime;
        graphMatrix(:,1) = [0, a];
        graphMatrix(1,2) = 0;
        graphMatrix(i+1,2) = elapsedTime
     
    if i<length(a)
        [~, ~, data] = xlsread(fullFileName);
    
        % Clear the data by creating an empty cell array of the same size
        emptyData = cell(size(data));
    
        % Write the empty data to the Excel file, overwriting the existing data
        xlswrite(fullFileName,emptyData);    % Write the empty data to the Excel file
        fprintf('Finish screening %d patients. \n', k)
    else
        disp("------------------------------------------------------------------------------");
        fprintf('New database has been created! The database file is %s.xlsx \nAccess folder %s to view results.\n',dataName,foldername)
        break
    end
  end

b = graphMatrix(:,2);
a = graphMatrix(:,1);

% Create column names
timeList = {'Number of files','Time in second'};

% Convert matrix to a table with column names
dataTable = array2table(graphMatrix, 'VariableNames', timeList);

% Save table to an Excel file
filename = 'time_analysis.xlsx';
writetable(dataTable, filename); 

% Plot the graph
plot(a,b);
text(a, b, num2str(b), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

% Add labels and title
xlabel('Number of files');
ylabel('Time in second');
title('Time analysis');

fig = gcf; % Get the current figure
%fig.Visible = 'off'; % Turn off visibility
fullfigName = fullfile(foldername,'time analysis');
saveas(gcf,fullfigName,'png') %gcf ='get current figure'


% This function check the validity of a sequence
function [dataCheck] = check_sequence(rawSeq)
% Check if a DNA sequence contains the start codon 'ATG' and ends with one of the stop codons 'TAA', 'TAG', or 'TGA'.
% Check if the file contains only a sequence of A, T, C, G nucleotides

dataCheck = {};

% Convert the lowercase letter sequence into uppercase letter one if there are any lowercase letters in the string
rawSeq = upper(rawSeq);

% Use a regular expression to search for any non-ACTG characters
character = '[^ACTG]';
character_match = regexp(rawSeq, character);
%disp(character_match)

% Use a regular expression to search for any non-star/stop codons
pattern = 'ATG((?:[ACGT]{3})*?)(?:TAG|TAA|TGA)';
pattern_match = regexp(rawSeq, pattern);
%disp(pattern_match)

if isempty(character_match) || isempty(pattern_match)
    dataCheck(end+1) = {'N/A'};
else
    dataCheck(end+1) = {rawSeq};
end

end

% This function process raw genetic sequence to obtain the coding sequence
function [arrayCodingSeq, diagnosis, CAGrepeats] = full_analysis(rawSeq,ID,folder)

%NAposition = find(strcmp(rawSeq,'N/A'));
arrayCodingSeq = {};

if ismember(rawSeq,'N/A')
    arrayCodingSeq(end+1) = {'N/A'};
else
    %Cut the DNA sequence to get the open reading frame (from start codon to stop codon)
    pattern = 'ATG((?:[ACGT]{3})*?)(?:TAG|TAA|TGA)'; % match the start codon with the sequence 
    arrayCodingSeq(end+1) = cellstr(regexp(rawSeq, pattern, 'match', 'once')); % a new sequence of subject sequence from start codon to stop codon
    %length(arrayCodingSeq)

%Run the diagnosis & draw graphs using the cut codingSeq
[result, repeats] = diagnosis_graph(rawSeq,ID,folder);

diagnosis = result;
CAGrepeats = repeats;

end
end


% This function draw graphs & give diagnosis for Hungtinton disease
function [result, repeats] = diagnosis_graph(str,ID,foldersave)

result = {};
repeats = {};

if ismember(str,'N/A')
    result(end+1) = {'File error!'};
    repeats(end+1) = {'N/A'};
else
    % Count the number of "CAG" codon repeats in the genome sequence
    codon = strread(char(str),'%3s'); % Cut the genome sequence to codon - a group of 3 nucleotides
    string = 'CAG'; % Set the target codon
    codoncmp = strcmp(codon, string); % Compare if codons in sequence is "CAG", 1 is similar codon, 0 is different
    count = 0; % Initialize a counter variable
    lengths = []; % Initialize an array to store the lengths of the consecutive sequences
    for i = 1:length(codoncmp) % Loop through the array
        if codoncmp(i) == 1 % If the current element is 1
            count = count + 1; % Increment the counter
        else % If the current element is 0
            lengths = [lengths count]; % Add the count to the lengths array
            count = 0; % Reset the counter
        end
    end
end
    repeats(end+1) = {max(lengths)};
    
    % Diagnosis of the Huntington disease using CAG count
    
    if le(max(lengths),35) % if count is <= 35, diagnosis is negative
        conclusion = 'Negative';
        result(end+1) = {conclusion}; % This result will be saved as 'Diagnosis' in the xlsx database
        disp("------------------------------------------------------------------------------");
        fprintf('Patient %s. The number of CAG repeat is %d. Diagnosis: %s.\nThis patient is not diagnosed with Hungtington disease.\n',ID,max(lengths),conclusion)
    elseif max(lengths) >= 40 % if count is >= 40, diagnosis is likely to be positive
        conclusion = 'Positive';
        result(end+1) = {conclusion};
        disp("------------------------------------------------------------------------------");
        fprintf('Patient %s. The number of CAG repeat is %d. Diagnosis: %s.\nThis patient may be diagnosed with Hungtington disease.\n',ID,max(lengths),conclusion)
    else % count from 36 to 40, diagnosis is N/A, in other words, maybe positive or negative
        conclusion = 'N/A';
        result(end+1) = {conclusion};
        disp("------------------------------------------------------------------------------");
        fprintf('Patient %s. The number of CAG repeat is %d. Diagnosis: %s.\nThis patient may or may not be diagnosed with Hungtington disease.\nMore tests are needed.\n',ID,max(lengths),conclusion)
    end
    
    
    % Draw the figure
    lengths = [lengths count];% Add the final count to the lengths array
    lengths = lengths(lengths ~= 0);% Remove any 0s at the beginning or end of the array
    % Display the lengths of the consecutive sequences
    %disp(lengths)
    
    Nuposarray = repelem(codoncmp, 3); % Convert the logical array of codons to the one of nucleotides
    Nuposition = double(Nuposarray'); % Convert the logical array of nucleotides to a double array of nucleotides
    
    % Draw the bar chart to show the number of "CAG" codon repeats
    tiledlayout(2,3); % Create a tiled layout to display all plots
    nexttile; % Mark axis of the 1st plot
    bar(max(lengths), 'BarWidth', 1, 'FaceColor', [0.5 0.5 0.5]); % Draw a bar chart with the numbe of "CAG" codons with the bar width of 1 and grey color
    set(gca, 'XTickLabel', []); % Set the x-axis without number
    xlabel('CAG codon'); % Name the x-axis
    ylabel('Number of repeats'); % Name the y-axis
    title('Number of CAG segment repeats'); % Name the title of the chart
    Y = max(lengths);
    text(1:length(Y),Y/2,num2str(Y'),'vert','bottom','horiz','center'); 
    
    % Draw a heat map to show the frequeny of codons in genome sequence
    nexttile([1 2]); % Mark axis of the 2nd plot
    codonstruct = codoncount(char(str),'figure',true); % Draw a heat map of codon frequency 
    title('Human HTT gene codon frequency'); % Name the title of the heatmap
    
    % Draw a heat map to show the positions of CAG codons in genome sequence
    nexttile([1 3]); % Mark axis of the 3rd plot
    seqMap = heatmap(Nuposition, 'Title', 'Subject gene sequence heatmap', 'XLabel', 'Position', 'YLabel', 'Nucleotide');
    seqMap.GridVisible = 'off';
    seqMap.ColorbarVisible = 'off';
    seqMap.CellLabelColor = "none";
    Ax = gca; % Get axis property
    Ax.YDisplayLabels = nan(size(Ax.YDisplayData));% Remove the display of Y label
    Ax.XDisplayLabels = nan(size(Ax.XDisplayData));% Remove the display of X label

    if ~isequal(foldersave,0)
        fig = gcf; % Get the current figure
        fig.Visible = 'off'; % Turn off visibility
        fullfigName = fullfile(char(foldersave),ID);
        saveas(gcf,fullfigName,'png'); %gcf ='get current figure'
        close(gcf);  %close the figure
    else
    end
end
