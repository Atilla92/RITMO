% Define input and output directories
inputDirectory = '/Volumes/WHITE LOTUS/ONSET/drums_demucs/';
outputDirectory = '/Volumes/WHITE LOTUS/ONSET/output_week_37/';

% Get a list of .wav files in the input directory
wavFiles = dir(fullfile(inputDirectory, '*.wav'));

% Create a summary CSV file
summaryHeader = {'Filename', 'Onset Count'};
summaryData = cell(length(wavFiles), 2);

% Disable figure display
set(0, 'DefaultFigureVisible', 'off');


% Loop through each .wav file
for i = 1:length(wavFiles)
    
    % Get the filename without extension
    [~, filename, ~] = fileparts(wavFiles(i).name);
    
    % Construct the full paths for input and output
    inputPath = fullfile(inputDirectory, wavFiles(i).name);
    outputPath = fullfile(outputDirectory, [filename '_onsets.csv']);
    
    % Read the .wav file
    [y, fs] = audioread(inputPath);
    
    % Estimate the onset times
    [onsetTimes, intensity, ons]  = name_ons(inputPath, outsuffix = '_niels', outpath = outputDirectory, overwrite = true, audiosave = true, echange = true, dynbuffer = 32);
    
    %numOnsets = length(onsetTimes);
    %outputCSV = cell(length(onsetTimes),2);
    %outputCSV = {onsetTimes', intensity'};
    outputCSV = [onsetTimes'; intensity'];

    csvwrite(outputPath, outputCSV);
    
      
    % Update the summary data
    summaryData{i, 1} = wavFiles(i).name;
    summaryData{i, 2} = length(onsetTimes);

    % Plot original audio and onset times
    figure('Visible', 'off');
    subplot(2, 1, 1);
    plot((0:length(y)-1)/fs, y);
    title('Original Audio');

    hold on;
    % Add black dashed lines at onset times
    for j = 1:length(onsetTimes)
        line([onsetTimes(j) onsetTimes(j)], get(gca, 'YLim'), 'Color', 'black', 'LineStyle', '--');
    end
    hold off;

    xlabel('Time (s)');
    ylabel('Amplitude');
    xlim([0 length(y)/fs]);
    
    subplot(2, 1, 2);
    plot(onsetTimes, zeros(size(onsetTimes)), 'ro', 'MarkerSize', 10);
    title('Detected Onsets');
    
    % Customize plot labels and titles
    xlabel('Time (s)');
    ylabel('Amplitude');
    xlim([0 length(y)/fs]);
    ylim([-1 1]);
    
    sgtitle(filename);
    
    % Save the figure as an image
    figPNG = fullfile(outputDirectory, [filename '_plot.png']);
    saveas(gcf, figPNG);
    figPath = fullfile(outputDirectory, [filename '_plot.fig']);
    savefig(figPath);
    
    close;



end


% Restore default figure visibility
set(0, 'DefaultFigureVisible', 'on');

% Write the summary data to a CSV file
summaryPath = fullfile(outputDirectory, 'summary.csv');
summaryTable = cell2table(summaryData, 'VariableNames', summaryHeader);
writetable(summaryTable, summaryPath);

disp('Onset times and summary have been saved.');

disp('Onset counts have been saved.');


% framedur , most algorithms use 100, if you put lower FT will be more
% noisy but timing will be more accurate. 
% srtfr, 100 HZ 1/100s,  tried to test different settings, If you change
% framedur, then you get some complications. Default should be ok. 

% if there is some noise in low frequency range (room, random fluctuations,
% you cannot really hear it but see it in the low frequency end)
% in that case if ns=True is is better to detect small varitions. 
% 'decol', decrease per frequency
% 'debeg', 1 HZ should be fine
% lowfreq [0 10]
% 'dynbuffer' gradually increase to add 6dB!!!!!
% 'mono' assumes the noise level is the same for steering channels. 

% 'timesmooth' default 20Hz, put it lower, depends on how fast intervals
% are. If put lower it will filter out faster fluctuations --> Look at
% around max, 10Hz
% 'int' minimum intensity increase, increase it to stronger energy peaks
% 6dB. See whether it misses some important onsets. 
% 'soa' in ms, similar to time smoothing, after it has picked the peaks and
% increases, post processing, looks whether there is another peak 50ms
% after it will remove it. Could try to put it at 100ms. 
% 'dur' in ms, it didnt have much effect when he tried, increase to 50ms. 

%%% Meeting 2
% name_onsed
% need to add a shortcuts file, 
% Increase dynbuffer to 36 for silent movement periods, lower background noise
% changening "int" did not do much, certain things get excluded else.
% For guitar, behaves better than MIR toolbox. See whether you can lower
% it, or even remove the 32 db, look at the noise plot. 


%onsets = name_ons('P13_D1_G5_M1_R1_T1.wav', outsuffix = '_tryingout', outpath = '/Users/atillajv/Ritmo/F-Andalucia/Rode/test/', overwrite = true, audiosave = true, echange = true, int = 10);