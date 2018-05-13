% Setups
root_dir = '/Users/dojoonyi/cn/ActionRep/';
ons_dir	 = 'ons';

% Experimental design
SN = [1:12,14:17];

for mm = 1:length(SN)
	xSS = sprintf('s%02d', SN(mm));
	mv = load(fullfile(root_dir, xSS, 'rp_exp1.txt'));
	
	% add scrubbing regressors
	for xrun = 1:4
		mv(245*(xrun-1)+1, end+1) = 1;	% 1st TR
		mv(245*(xrun-1)+2, end+1) = 1;	% 2nd TR
		
		if exist(fullfile(root_dir, xSS, sprintf('dvars_rexp%d.txt', xrun)),'file')==2
			clear xreg;
			xreg = load(fullfile(root_dir, xSS, sprintf('dvars_rexp%d.txt', xrun)));
			mv(245*(xrun-1)+1:245*xrun, end+1:end+size(xreg,2)) = xreg;
		end
	end	
	
	% add run-specific regressors to 3DMC
	mv(001:245, end+1) = 1;
	mv(246:490, end+1) = 1;
	mv(491:735, end+1) = 1;

	mv_name = fullfile(root_dir, xSS, ons_dir, sprintf('par3dmc+scrubbed_%s.txt', xSS));
	dlmwrite(mv_name,mv,'delimiter','\t','precision','%.7e');
	
	fprintf('%s: %d x %d\n', xSS, size(mv,1), size(mv, 2));
	clear mv_name mv;
end

% a06_ActionRep_regScrub
% s01: 980 x 27
% s02: 980 x 53
% s03: 980 x 38
% s04: 980 x 41
% s05: 980 x 132
% s06: 980 x 27
% s07: 980 x 49
% s08: 980 x 62
% s09: 980 x 28
% s10: 980 x 29
% s11: 980 x 37
% s12: 980 x 28
% s14: 980 x 73
% s15: 980 x 44
% s16: 980 x 29
% s17: 980 x 42