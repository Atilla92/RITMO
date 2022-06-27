function [pulse_data, f_centroid_data, f_entropy_data, mode_data, keyclarity_data] = long_term_features(name, h, l)

	% Parameters
	% name: path to wav file
	% l : Window length
	% h : overlaping percentage
	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Measures

	% 1. Pulse clarity
	pulse = mirpulseclarity(name,'Frame',l,h);
	pulse_data = mirgetdata(pulse);

	% 2. Fluctuation centroid
	fluctuation = mirfluctuation(name,'Frame',l,h);
	f_centroid = mircentroid(fluctuation);
	f_centroid_data = mirgetdata(f_centroid);
	
	% 3. Fluctuation entropy
	f_entropy = mirentropy(fluctuation);
	f_entropy_data = mirgetdata(f_entropy);
	 
	% 4. mode clarity
	mode0 = mirmode(name,'Frame',l,h);
	mode_data = mirgetdata(mode0);

	% 5. Key clarity (might go down)
	[k, ks] = mirkey(name,'Frame',l,h);
	keyclarity_data = mirgetdata(ks);


end
