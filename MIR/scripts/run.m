%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Extracting musical features using MIR toolbox
% Fernando Rosas, July 2020.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading audio files
%
user = getenv('USER');
%
if strcmp(user,'nanorosas')
	path_data = '~/Desktop/Imperial/Code/Projects/wavepaths/music_analysis/data/small/';
	path_res  = '~/Desktop/Imperial/Code/Projects/wavepaths/music_analysis/res/';
elseif strcmp(user,'root')
	path_data = '~/root/Desktop/wavepath/';
	path_res  = './res/';
elseif strcmp(user,'frosasde')
	path_data = '~/Projects/wave/data/';
	path_res  = '~/Projects/wave/res/';
	addpath(genpath('~/Packages/MIRtoolbox1.7.2'))
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading audio files
files = dir(path_data);
N = length(files);
%
% Compute features for each file
for k=80:N
	name = files(k).name;
    %name = 'out001.m4a'
    path = strcat( files(k).folder, '/', name);
	if strcmp(name,'.') || strcmp(name,'..') 
		continue % Discard trivial names
    end
    %
    %
    %
    disp(strcat("Going with file: ",name))
    %
    % Calculate signal
	signal = miraudio(path, 'Extract', 20, 280);
	%
	%mirplay(name)
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Calculating short term features
	%
	% Parameters
	l = 0.025; % Window length
	h = 0.5;   % overlaping percentage (1=no overlapping, 0.5=half window overlapping)
	%
	% Calculation of features
	[zerocross, centroid, RMS_power, ration_high_low, s_spread, s_rolloff, s_entropy, s_flatness, roughness, s_flux, s_flux_sub] = short_term_features(path, signal, l, h);
	%
	%
	%
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Calculating long term features
	%
	% Parameters
	l = 3; % Window length
	h = 0.33;   % overlaping percentage
	%
	% Calculation of features
	[pulse_data, f_centroid_data, f_entropy_data, mode_data, keyclarity_data] = long_term_features(path, h, l);
	%
	%
	%
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Store the results 
 	%
	% Fixing destination
	short_name = name(1:end-4);	
	save_path = strcat(path_res,'f25_',short_name);
	%
	save(save_path, 'zerocross', 'centroid', 'RMS_power', 'ration_high_low', 's_spread', 's_rolloff', 's_entropy', 's_flatness', 'roughness', 's_flux', 's_flux_sub', 'pulse_data', 'f_centroid_data', 'f_entropy_data', 'mode_data', 'keyclarity_data')
end
