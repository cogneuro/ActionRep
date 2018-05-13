%% Participants Info
SN = [1:12,14:17];

% Information & Parameters
data_dir = '/Users/dojoonyi/cn/CLT/ActionRep';

for it=1:length(SN)
	xsn = SN(it);
	xSS = sprintf('s%02d', xsn);
	
%  	delete(fullfile(data_dir, xSS, 'ons', 'dmat*'));

%  	rmdir(fullfile(data_dir, xSS, 'rois_native'), 's');
	rmdir(fullfile(data_dir, xSS, 'rois_native_neurosynth180502'), 's');
end