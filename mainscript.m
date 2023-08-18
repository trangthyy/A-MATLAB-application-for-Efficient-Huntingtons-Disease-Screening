% This script analyze, store to database, and visualize genetic sequences for the screening of Huntington's disease
clear

% Ask the user for raw data or use the exist data
interface=menu('Start genetic screening for Huntington''s disease', 'Start', 'End');
while interface == 1
    close
      % Ask user to choose an option for sequence analysis
      data_source=menu('Please select one of the following functions.', ...
          'Screen Multiple Sequences & Create Database','Append New Profile','Visualize Individual Data');
      % Check if the user clicked Cancel
      if isequal(data_source,0)
         disp('User clicked Cancel. The program is terminated.')
         break
      % The user chooses to see data from the database
      elseif data_source == 3
         close
         [filename, filepath, correct_file, mainDatabase, T] = check_database();

         if correct_file ~= true
            break     
         end
         
         ID = false;
         for i=1:5 % Allow users to input wrong ID 5 times
             ID_in_data = input('Enter the patient''s ID in database: ', 's'); % Prompt user for patient's ID
             if ismember(ID_in_data, T.ID)
                ID = true;
                break
             else
                fprintf('Data of patient %s is unavailable. Please re-enter patient''s ID.\n',ID_in_data);
             end
         end
         if ID ~= true 
            fprintf('Too many incorrect ID attempts!\nPlease try again later. Program is terminated.\n')
            break
         end
         search = find(T.ID == string(ID_in_data)); % Find with ID
         get_ORF = table2cell(T(search, 'Cut Sequence')); % Extract the sequence stored from the row, turn it into a cell
         ORF = get_ORF{:}; % Get the content from the cell
         % Set condition to not save graphs in diagnosis_graph function
         wrongFolder = 0;
         % Input extracted info into function to diagnose & draw graphs
         diagnosis_graph(ORF,ID_in_data,wrongFolder);

      % The user choooses to create a new data and add to the database      
      elseif data_source == 2
          close
          [filename, filepath, correct_file, mainDatabase, T] = check_database();

          if correct_file ~= true
            break
          end
          newID = false;
          for d=1:3
            new_ID = input('Enter the new patient''s ID: ', 's'); % Prompt the user for patient's ID and sequence
            % Check if the new ID exists in the database
            if ~ismember(new_ID, T.ID)
               newID = true;
               break
            else
               disp('The new ID already exists in the database! Please add another ID!')
            end
          end
          if newID == false 
             fprintf('Too many existing ID attempts!\nPlease try again later. Program is terminated.\n')
             break
          end

          import = menu('Paste sequence or import txt file?', 'Paste sequence', 'Import text file');
          % Check if the user clicked Cancel
          if isequal(import,0)
             disp('User clicked Cancel. The program is terminated.')
             break
          elseif import == 1
              rawsequence = input('Enter the new patient''s coding sequence: ', 's');
          else
              % Create a list selection
              [filenamek, filepathk] = uigetfile('*.txt', 'Select a file');
              
              % Check if the user clicked Cancel
              if isequal(filenamek,0) || isequal(filepathk,0)
                  disp('User clicked Cancel. The program is terminated.')
                  break
              else
                  % Load the selected file
                  fullpath = fullfile(filepathk, filenamek);
                  % Add your code here to load or process the selected file
                  disp(['User selected file: ', fullpath])
                  file = string(fullpath);
                  S = convertStringsToChars(strjoin(readlines(file)));
                  rawsequence = S(~isspace(S)); % Obtain the raw sequence
              end
          end
          
          % Check the validity of the sequence
          [data,character_match, pattern_match] = check_sequence(rawsequence);
          if ~isempty(character_match)
             disp('The sequence is not valid. Please check again!') 
             break
          elseif isempty(pattern_match)
             disp('The sequence does not have a start/stop codon. Please check again!')
             break
          end

          % Set condition to not save figure in diagnosis_graph function
          wrongFolder = 0;
          % Run the function to draw graph, then obtain new coding sequence & diagnosis
          [arrayCodingSeq, new_diagnosis, new_repeats] = ORF_extraction(rawsequence,new_ID,wrongFolder);
          % Save data from new patient to excel file
          new_patient = [new_ID,new_diagnosis,new_repeats,arrayCodingSeq,rawsequence]; % Create an info array of new patient
          writecell(new_patient,mainDatabase,'WriteMode','Append'); % Append info of new patient to xls database file
          fprintf('New profile saved.\n') % Confirm profile is saved

          % Save the figure of the new profile
          fig = gcf; % Get the current figure
          fullfigName = fullfile(char(filepath),new_ID);
          saveas(gcf,fullfigName,'png'); %gcf ='get current figure'
          fprintf('New figure saved.\n') % Confirm figure is saved

      % The user chooses to read and analyze a folder of patients' sequences.    
      else
         % Ask user to select the desired folder to analyze
         close
         hasTextFile = false;
         disp('Please select a folder!')
         foldername = uigetdir('Select a folder');
         % Check if the user clicked Cancel
         if isequal(foldername,0)
            disp('User clicked Cancel. The program is terminated.')
            break
         else
            disp(['User selected folder: ', foldername])
            original_files=dir([foldername '/*.txt']);
            if ~exist(foldername, 'dir') % Check if folder exists
               mkdir(foldername); % Create a folder with such path
            end
            fileList = dir(foldername); % Get a list of all files in the folder
            for i = 1:length(fileList) % Check if any of the files have a .txt extension
               [~, ~, ext] = fileparts(fileList(i).name);
               if strcmp(ext, '.txt')
                  hasTextFile = true;
                  break
               end
            end
            if hasTextFile == true
                % Create a new excel database in folder in advance
                list = {'ID','Diagnosis','CAG repeats','Cut Sequence','Raw Data'};
                dataName = input('Name of new database: ', 's'); % Prompt user for database name
                new_database = sprintf('%s.xlsx', dataName);
                fullFileName = fullfile(foldername, new_database); % Create the file full path in the designated folder
                xlswrite(fullFileName,list); % Create file in folder

                % Create a database memory
                dataMemory = cell(length(original_files),length(list));
                % Extract the file names without extensions & save to memory
                pre_dataID = {original_files.name}';
                % Remove '.txt' from the file names & save to a cell array
                dataID = cellfun(@(x) x(1:end-4), pre_dataID, 'UniformOutput', false);
                % Add names to column 1 in database memory
                dataMemory(:,1) = dataID;

                % Extract sequences from files & check validity of sequences
                dataContents = arrayfun(@(x) fileread(fullfile(foldername,x.name)),original_files,'UniformOutput',false);
                dataSeq = cellfun(@check_sequence, dataContents);

                % Save the raw sequences to column 5 of the database memory
                dataMemory(:,5) = dataSeq;
                % Set condition to save figures in diagnosis_graph function
                dataFolder = num2cell(repmat({foldername},length(original_files),1));

                % Run sequences in function obtain cut seq, diagnosis, repeats
                [dataSeqcut, dataDiagnosis, dataRepeats] = cellfun(@ORF_extraction,dataSeq,dataID,dataFolder);
                
                % Add diagnosis,repeats,cut seqs to column 2,3,4 of database memory
                dataMemory(:,2) = dataDiagnosis;
                dataMemory(:,3) = dataRepeats;
                dataMemory(:,4) = dataSeqcut;
                
                % Save database memory to excel file in folder
                range= sprintf('A2:E%d', 2+length(original_files)-1);
                writecell(dataMemory, fullFileName,'WriteMode','append' );
                disp("------------------------------------------------------------------------------");
                fprintf('New database has been created! The database file is %s.xlsx \nAccess folder %s to view results.\n',dataName,foldername)
            else
               fprintf('The folder does not have any text file. Please try again! \n')
            end
         end
      end

      interface=menu('Start genetic analysis for Huntington''s disease screening', 'Start', 'End');
      if interface == 2
          close
          break
      end 
end

% This function check if the correct database is selected
function [filename, filepath, correct_file, mainDatabase, T] = check_database()
% Prompts the user to select an Excel file and checks if it contains all necessary elements
% The user is allowed to select the file up to 3 times, and if the file is still incorrect, the function will terminate with an error message.

    disp('Please select the desired database file!')
    correct_file = false;

    for i = 1:3
        [filename, filepath] = uigetfile('*.xlsx', 'Select a file');

        % Check if the user clicked Cancel
        if isequal(filename, 0) || isequal(filepath, 0)
           disp('User clicked Cancel. Program is terminated.\n');
           correct_file = 'N/A';
           T = 'N/A';
           break
        else 
            [~, raw] = xlsread(fullfile(filepath, filename));
            element = {'ID','Diagnosis','CAG repeats','Cut Sequence','Raw Data'};
            if all(ismember(element, raw(1,:)))
               correct_file = true;
               mainDatabase = fullfile(filepath, filename);
               T = readtable(mainDatabase, "VariableNamingRule","preserve");
               break;
            else
                disp('This is the incorrect database. Please try again!')
            end
        end
        % If the correct file is not selected after 3 attempts, terminate
        if i == 3
            fprintf('Too many incorrect database attempts!\nPlease try again later. Program is terminated.\n')
            break
        end
    end
end


% This function check the validity of a sequence
function [dataCheck,character_match,pattern_match] = check_sequence(rawSeq)
% Check if a DNA sequence contains the start codon 'ATG' and ends with one of the stop codons 'TAA', 'TAG', or 'TGA'.
% Check if the file contains only a sequence of A, T, C, G nucleotides
% Save the raw sequences in the file to cell array

% Create empty array to store raw sequences 
dataCheck = {};

% Convert the lowercase letter sequence into uppercase letter one if there are any lowercase letters in the string
rawSeq = upper(rawSeq);

% Use a regular expression to search for any non-ACTG characters
character = '[^ACTG]';
character_match = regexp(rawSeq, character);

% Use a regular expression to search for any non-star/stop codons
pattern = 'ATG((?:[ACGT]{3})*?)(?:TAG|TAA|TGA)';
pattern_match = regexp(rawSeq, pattern);

% Choose actions if file is error or contain DNA sequence
if isempty(character_match) || isempty(pattern_match)
    dataCheck(end+1) = {'N/A'}; % Add 'N/A' to the created array if file is not DNA sequence
else
    dataCheck(end+1) = {rawSeq}; % Add raw seq to the created array if file content is DNA sequence
end

end

% This function process raw genetic sequence to obtain the coding sequence
function [arrayCodingSeq, diagnosis, CAGrepeats] = ORF_extraction(rawSeq,ID,folder)

% Create empty array to store coding sequences
arrayCodingSeq = {};

% Choose actions if file is error or contain DNA sequence 
if ismember(rawSeq,'N/A') == 1
    arrayCodingSeq(end+1) = {'N/A'}; % Add 'N/A' to the empty array if file is error
else
    %Cut the DNA sequence to get the open reading frame (from start codon to stop codon)
    pattern = 'ATG((?:[ACGT]{3})*?)(?:TAG|TAA|TGA)'; % match the start codon with the sequence 
    arrayCodingSeq(end+1) = cellstr(regexp(rawSeq, pattern, 'match', 'once')); % a new sequence of subject sequence from start codon to stop codon
end

% Run the diagnosis & draw graphs using the cut codingSeq
[result, repeats] = diagnosis_graph(arrayCodingSeq,ID,folder);

% Obtain diagnosis & number of repeats
diagnosis = result;
CAGrepeats = repeats;

end


% This function draw graphs & give diagnosis for Hungtinton disease
function [result, repeats] = diagnosis_graph(orfSeq,ID,foldersave)

% Create empty array to store diagnosis & number of CAG repeats
result = {};
repeats = {};

% Choose actions if file is error or contain DNA sequence
if ismember(orfSeq,'N/A') == 1
    result(end+1) = {'File error!'};
    repeats(end+1) = {'N/A'};
    disp("------------------------------------------------------------------------------");
    fprintf('File error!\n');
else
    % Count the number of "CAG" codon repeats in the genome sequence
    codon = strread(char(orfSeq),'%3s'); % Cut the genome sequence to codon - a group of 3 nucleotides
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
    repeats(end+1) = {max(lengths)}; % Save repeats to the created array
    
    % Diagnosis of the Huntington disease using CAG count
    if le(max(lengths),35) % if count is <= 35, diagnosis is negative
        conclusion = 'Negative';
        result(end+1) = {conclusion}; % This result will be saved as 'Diagnosis' in the xlsx database
        disp("------------------------------------------------------------------------------");
        fprintf('Patient %s. The number of CAG repeat is %d. Diagnosis: %s.\nThis patient is not diagnosed with Hungtington''s disease.\n',ID,max(lengths),conclusion)
    elseif max(lengths) >= 40 % if count is >= 40, diagnosis is likely to be positive
        conclusion = 'Positive';
        result(end+1) = {conclusion};
        disp("------------------------------------------------------------------------------");
        fprintf('Patient %s. The number of CAG repeat is %d. Diagnosis: %s.\nThis patient may be diagnosed with Hungtington''s disease.\n',ID,max(lengths),conclusion)
    else % count from 36 to 40, diagnosis is N/A, in other words, maybe positive or negative
        conclusion = 'N/A';
        result(end+1) = {conclusion};
        disp("------------------------------------------------------------------------------");
        fprintf('Patient %s. The number of CAG repeat is %d. Diagnosis: %s.\nThis patient may or may not be diagnosed with Hungtington''s disease.\nMore clinical tests are needed.\n',ID,max(lengths),conclusion)
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
    codonstruct = codoncount(char(orfSeq),'figure',true); % Draw a heat map of codon frequency 
    title('Human HTT gene codon frequency'); % Name the title of the heatmap
    
    % Draw a heat map to show the positions of CAG codons in genome sequence
    nexttile([1 3]); % Mark axis of the 3rd plot
    seqMap = heatmap(Nuposition, 'Title', 'Subject gene sequence heatmap', 'XLabel', 'Position', 'YLabel', 'Nucleotide');
    seqMap.GridVisible = 'off';
    seqMap.ColorbarVisible = 'off';
    seqMap.CellLabelColor = "none";
    Ax = gca; % Get axis property
    Ax.YDisplayLabels = nan(size(Ax.YDisplayData)); % Remove the display of Y label
    Ax.XDisplayLabels = nan(size(Ax.XDisplayData)); % Remove the display of X label

    % Save & not diplay figures only when reading from folder
    if ~isequal(foldersave,0)
        fig = gcf; % Get the current figure
        fig.Visible = 'off'; % Turn off visibility
        fullfigName = fullfile(char(foldersave),ID);
        saveas(gcf,fullfigName,'png'); %gcf ='get current figure'
        close(fig);  %close the figure
    else
    end
end
end
