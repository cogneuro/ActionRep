%% Participants Info
% SN = [1:4,6:12,14:17];
SN = 5;
%% Directory Info
root_dir = '/Users/dojoonyi/cn/CLT/ActionRep';

runTR = [245, 245, 245, 245];
nTRpRUN = cumsum(runTR);

for mm = 1:length(SN)
	xsn = SN(mm);
    xSS = sprintf('s%02d', xsn);
	
	TT(xsn).sn = xSS;
	TT(xsn).mv = load(fullfile(root_dir, xSS, sprintf('rp_exp1.txt')));
	TT(xsn).mv(:,4:6) = TT(xsn).mv(:,4:6)*180/pi;
	
	mP = max(max(abs(TT(xsn).mv(:,1:3))));
	[mR,mC] = find(abs(TT(xsn).mv(:,1:3))==mP);
	maxMM(xsn,1:2) = [mR, TT(xsn).mv(mR,mC)];
	clear mP mR mC;
	
	mP = max(max(abs(TT(xsn).mv(:,4:6))));
	[mR,mC] = find(abs(TT(xsn).mv(:,4:6))==mP);
	maxDeg(xsn,1:2) = [mR, TT(xsn).mv(mR,mC+3)];
	clear mP mR mC;
end

figure;
p1 = subplot(2,1,1);
hold on;
for mm = 1:length(SN)
	xsn = SN(mm);
    xSS = sprintf('s%02d', xsn);
	plot(TT(xsn).mv(:,1:3));
end
for mm = 1:length(SN)
	xsn = SN(mm);
    xSS = sprintf('s%02d', xsn);
	text(maxMM(xsn,1), maxMM(xsn,2), xSS, ...
					'Color', 'k', 'FontSize', 16, 'FontWeight','Bold');
end
s = ['x translation';'y translation';'z translation'];
set(get(p1,'Title'),'String','translation','FontSize',16,'FontWeight','Bold');
set(get(p1,'Xlabel'),'String','image');
set(get(p1,'Ylabel'),'String','mm');
yt = get(p1,'YTick');
for mm=1:length(nTRpRUN)
	plot([nTRpRUN(mm),nTRpRUN(mm)],[min(yt),max(yt)],'k:');
end
xlim([0,max(nTRpRUN)+10]);
legend(p1, s, 'Location', 'NorthWest');
hold off;

p2 = subplot(2,1,2);
hold on;
for mm = 1:length(SN)
	xsn = SN(mm);
    xSS = sprintf('s%02d', xsn);
	plot(TT(xsn).mv(:,4:6));
end
for mm = 1:length(SN)
	xsn = SN(mm);
    xSS = sprintf('s%02d', xsn);
	text(maxDeg(xsn,1), maxDeg(xsn,2), xSS, ...
					'Color', 'k', 'FontSize', 16, 'FontWeight','Bold');
end
s = ['pitch';'roll ';'yaw  '];
set(get(p2,'Title'),'String','rotation','FontSize',16,'FontWeight','Bold');
set(get(p2,'Xlabel'),'String','image');
set(get(p2,'Ylabel'),'String','degrees');
yt = get(p2,'YTick');
for mm=1:length(nTRpRUN)
	plot([nTRpRUN(mm),nTRpRUN(mm)],[min(yt),max(yt)],'k:');
end
xlim([0,max(nTRpRUN)+10]);
legend(p2, s, 'Location', 'NorthWest');
hold off;

%----------------------------- EOF.