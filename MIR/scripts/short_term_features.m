function [zerocross_data, centroid_data, RMS_data, ration_high_low_data, s_spread_data,	s_rolloff_data, s_entropy_data, s_flatness_data, roughness_data, s_flux_data, s_flux_sub_data] = short_term_features(path, signal, l, h)

	% Parameters
	% name: path to wav file
	% l : Window length
	% h : overlaping percentage
	

	% Calculate spectrum
	spectrum = mirspectrum(signal, 'Frame', l, h);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Measures

	% 1. Zero-crossing rate
	zerocross = mirzerocross(signal, 'Frame', 0.025, 1);

	% 2. Spectral centroid
	s_centroid = mircentroid(spectrum);

	% 3. High/low energy ratio
	%rms_energy = mirrms(signal, 'Frame', l, h);
	low_energy = mirlowenergy(signal,'Threshold',1500,'Frame',l,h);

	% 4. Spectral spread
	s_spread = mirspread(spectrum);

	% 5. Spectral roll-off
	s_rolloff = mirrolloff(spectrum);

	% 6. Spectral entropy
	s_entropy = mirentropy(spectrum);

	% 7. Spectral flatness
	s_flatness = mirflatness(spectrum);

	% 8. Roughness
	roughness = mirroughness(signal,'Frame',l,h);

	% 9. RMS energy
	RMS = mirrms(signal,'Frame',l,h);

	% 10. Spectral flux
	%s_flux = mirflux(spectrum,'Frame',l,h);

	% 11. Spectral Sub-band flux
	%s_flux_sub = mirflux(path, 'Subband', 'Frame', l, h);
	
	% 1
	zerocross_data = mirgetdata(zerocross);
	% 2
	centroid_data = mirgetdata(s_centroid);
	% 3
	RMS_data = mirgetdata(RMS);
	low_RMS_data = mirgetdata(low_energy);
	high_RMS_data = RMS_data - low_RMS_data;
	ration_high_low_data = high_RMS_data ./low_RMS_data; 
	% 4
	s_spread_data = mirgetdata(s_spread);
	% 5
	s_rolloff_data = mirgetdata(s_rolloff);
	% 6
	s_entropy_data = mirgetdata(s_entropy);
	% 7
	s_flatness_data = mirgetdata(s_flatness);
	% 8
	roughness_data = mirgetdata(roughness);
	% 9 RMS energy
	% 10		
	%s_flux_data = mirgetdata(s_flux);
    s_flux_data = 0;
	% 11
	%s_flux_sub_data = mirgetdata(s_flux_sub);
    s_flux_sub_data = 0;
end
