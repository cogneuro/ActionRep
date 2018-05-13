work_dir = '/Users/dojoonyi/cn/ActionRep/'; 
prot_dir = 'protocol';	% where raw behavioral data are saved. 

%%%%%%%%%%%%%%%%%%%%%%%%%%  UPLOADING DATA	
% Import data from text file.
filename = fullfile(work_dir, prot_dir, 'protocol_ActionRep.csv');
delimiter = ',';
startRow = 2;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
	'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, ...
	'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
TT = [dataArray{1:end-1}];
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%%%%%%%%%%%%%%%%%%%%%%%%%%  PARTICIPANTS INFO
SN = unique(TT(:,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%  EXPERIMENT SETUP
TT(:,end+1)=TT(:,8) + (TT(:,2)-1)*490;		% 12_concatenated stim time
TT(:,end+1)=TT(:,9) + TT(:,11) + (TT(:,2)-1)*490; % 13_concatenated RT
dstr={'self','other','how','why','missed'};

%%%%%%%%%%%%%%%%%%%%%%%%%%  BEHAVIOR
cntRESP = zeros(length(SN),17);
avgRESP = zeros(length(SN),4);
for mm=1:length(SN)
	xsn = SN(mm);
	
	SS = TT(TT(:,1)==xsn,:);
	% 1_SN, 2_run, 3_trial, 4_cond, 5_IM, 6_plan, 7_TTL, 8_stim, 9_scale, 10_resp, 11_rt
	fprintf('Subject %d --> %d x %d\n', xsn, size(SS,1), size(SS,2));

	for con=1:4
		for resp=1:4
			cntRESP(mm,(con-1)*4+resp) = length(SS(SS(:,4)==con & SS(:,10)==resp ,11));
		end
		avgRESP(mm, con) = mean(SS(SS(:,4)==con & SS(:,10)>0, 10))-1; 
	end
	cntRESP(mm,end) = length(SS(SS(:,10)==0, 11));

end

% output = fopen(['analyzedActRep_' datestr(now, 1) '_' datestr(now, 13) '.csv'], 'a');
filename = fullfile(work_dir, prot_dir, 'analyzedActRep_scale.csv');
fileID = fopen(filename, 'w');

fprintf(fileID, 'b01_ActionRep_behavior.m on %s\n\n', date);

yyy = sum(cntRESP(:,end))*100/sum(cntRESP(:));
fprintf(fileID, '* %1.4f %% of responses were missed.\n\n', yyy);

fprintf(fileID,'Count\n');
fprintf(fileID,'Condition,');
for	mm=1:4
	for nn=1:4
		fprintf(fileID,'%s,', dstr{mm});
	end
end
fprintf(fileID,'%s,sum\n', dstr{end});
fprintf(fileID,'Scale,');
for	mm=1:4
	fprintf(fileID,'easy0,1,2,diff3,');
end
fprintf(fileID,'%s,sum\n', dstr{end});

for nn=1:length(SN)
	fprintf(fileID,'s%02d,', SN(nn));
	for	mm=1:17
		fprintf(fileID,'%02d,', cntRESP(nn,mm));
	end
	fprintf(fileID,'%03d,', sum(cntRESP(nn,:)));
	fprintf(fileID,'\n');
end
fprintf(fileID,'\n\n\n');


fprintf(fileID,'Average\n');
fprintf(fileID,'SN,');
for mm=1:4
	fprintf(fileID,'%s,', dstr{mm});
end
fprintf(fileID,'\n');
for nn=1:length(SN)
	fprintf(fileID,'s%02d,', SN(nn));
	for	mm=1:4
		fprintf(fileID,'%01.4f,', avgRESP(nn,mm));
	end
	fprintf(fileID,'\n');
end
% average
mn = mean(avgRESP);
fprintf(fileID, 'MN,');
for nn=1:length(mn)
	fprintf(fileID, '%4.10f,', mn(nn));
end
fprintf(fileID, '\n');

% CI
ci = cintervalCM(avgRESP);
fprintf(fileID, 'CI,');
for nn=1:length(mn)
	fprintf(fileID, '%4.10f,', ci(nn));
end
fprintf(fileID, '\n\n\n\n');


fclose('all');
%---------------------------------- EOF.