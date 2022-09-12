clc
clear all

addpath '~/Packages/elph-master/'
addpath '~/Packages/elph-master/private/mvgc_v2.0'
%addpath '~/Packages/statespace-master/mvgc_v2.0'
mvgc_startup

%%




clc


mo = 100;
hil = 0;

data_path = '~/Projects/insight/EEG/data/';
res_path = '~/Projects/insight/EEG/res/SS/';

% Find all the files
files = dir( strcat(data_path,'*.mat') );
for i = 1:length(files)
    %
    % Load the data
    name = files(i).name; % Find name of file
    load( strcat(data_path, name), 'data_clean') % Load .m file
    disp(name)
    %
    % Extracting channels and remove ground electrodes
    ch = data_clean.label; % EEG channel names
    n_chan = length(ch);   % number of channels
    ix = strcmp(ch,'A1') | strcmp(ch,'A2'); % find relevant indices
    %
    df = cat(2, data_clean.trial{:}); % Concatenate all the sub-matrices
    df = df(~ix,:);
    %
    if hil==1
        for i=1:size(df,1)
            df(i,:) = abs( hilbert( df(i,:) ) );
        end
    end
    %
    time = cat(2, data_clean.time{:}); % Concatenate all the sub-matrices
    df_nomusic = df(:, time<240); % data without music
    df_music   = df(:, time>=240); % data with music
    %
    Fs = data_clean.fsample;
    %
    % Entropy with no music
    [h_nomusic,F_nomusic] = StateSpaceEntropyRate(df_nomusic, Fs, 'yes', [1, 4; 4, 8; 8, 15; 15, 25; 25, 49; 1,100],mo);
    % Entropy with music
    [h_music,F_music]     = StateSpaceEntropyRate(df_music, Fs, 'yes', [1, 4; 4, 8; 8, 15; 15, 25; 25, 49; 1,100],mo);
    %
    % Format results
    res = [ [h_nomusic; F_nomusic], [h_music; F_music] ];
    % rows: h_tot, h_delta, h_theta, h_alpha, h_beta, h_gamma
    % Cols: nomusic, music
    %
    % Save data
    out_name = strcat(res_path,name(1:end-19),'.csv');
    writematrix(res,out_name)
    
end

