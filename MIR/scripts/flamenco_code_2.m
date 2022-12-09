mirverbose(0)
close all

b=[]; 
rms = {};
rmsavg = {};
entropy = {};
entropyavg = {};
metre = {};
sm = {};
novelty = {};
fp1 = {};
fp2 = {};
fp3 = {};
fp4 = {};
fp5 = {};
filenames = {};

[b,filenames, rms, rmsavg, entropy, entropyavg, metre, sm, novelty,...
   fp1, fp2, fp3, fp4, fp5]...
    = recurse(b,filenames, rms, rmsavg, entropy, entropyavg, metre, ...
    sm, novelty, fp1, fp2, fp3, fp4, fp5);

save('features.mat','b','filenames', 'rms', 'rmsavg', 'entropy', ...
    'entropyavg','metre', 'sm','novelty', 'fp1','fp2', 'fp3', 'fp4', 'fp5');
%writecell(features.mat, 'features.csv')

function [b,filenames, rms, rmsavg, entropy, entropyavg, metre, sm, novelty,...
    fp1, fp2, fp3, fp4, fp5]...
    = recurse(b,filenames, rms, rmsavg, entropy, entropyavg, metre, ...
    sm, novelty, fp1, fp2, fp3, fp4, fp5)
d = dir;

    for i = 3:length(d)
        if d(i).isdir
            disp('/////////////////')
            d(i).name
            cd(d(i).name);
            [b,filenames, rms, rmsavg, entropy, entropyavg, metre, sm, novelty,...
    fp1, fp2, fp3, fp4, fp5]...
    = recurse(b,filenames, rms, rmsavg, entropy, entropyavg, metre, ...
    sm, novelty, fp1, fp2, fp3, fp4, fp5);
            cd ..
        else
            try
                if strcmp(d(i).name(end-3:end), '.wav') || ...
                        strcmp(d(i).name(end-3:end), '.WAV')

                        rmsavgc = mirrms(d(i).name);
                        mgt1 = mirgetdata(rmsavgc);
                        rmsc = mirrms(d(i).name, 'Frame');
                        m1 = mirgetdata(rmsc);
                        f1 = get(rmsc,'FramePos');
                        f1{1}{1};
                        
                        entropyavgc = mirentropy(d(i).name);
                        mgt2 = mirgetdata(entropyavgc);
                        entropyc = mirentropy(d(i).name, 'Frame');
                        m2 = mirgetdata(entropyc);
                        f2 = get(entropyc,'FramePos');
                        f2{1}{1};

                        o1 = mironsets(d(i).name,'SpectroFrame',.05,.2,...
                            'PreSilence',0,'Detect',0,'Frame',5,.05);
                        ac1 = mirautocor(o1,'Min',60/1000,'Max',...
                            60/24 * 2,'NormalWindow',0,'HighPass');  % ,'Resonance');
                        o2 = mironsets(d(i).name,'SmoothGate','Lartillot',...
                            'MinRes',10,'Detect',0,'Frame',5,.05);
                        ac2 = mirautocor(o2,'Min',60/1000,'Max',...
                            60/24 * 2,'NormalWindow',0);
                        ac = ac1 + ac2;
                        metrec = mirmetre(ac);
                        m3 = mirgetdata(metrec);
                        f3 = get(metrec,'FramePos');
                        f3{1}{1};

                        s = mirmfcc(d(i).name,'Frame',7,.2,'Rank',2:13);
                        smc = mirsimatrix(s);
                        m4 = mirgetdata(smc);
                        f4 = get(smc, 'FramePos');
                        f4{1}{1};

                        b = mirnovelty(smc,'Width',20,'Normal',0,...
                            'FilterBorder',0,'Back');
                        f = mirnovelty(smc,'Width',20,'Normal',0,...
                            'FilterBorder',0,'Forth');
                        noveltyc = b + f;
                        m5 = mirgetdata(noveltyc);
                        f5 = get(noveltyc, 'FramePos');
                        f5{1}{1};
                        
                        
                        filenames{end+1} = d(i).name;
                        rms{end+1} = m1;
                        rmsavg{end+1} = mgt1;
                        entropy{end+1} = m2;
                        entropyavg{end+1} = mgt2;
                        metre{end+1} = m3;
                        sm{end+1} = m4;
                        novelty{end+1} = m5;
                        fp1{end+1} = f1;
                        fp2{end+1} = f2;
                        fp3{end+1} = f3;
                        fp4{end+1} = f4;
                        fp5{end+1} = f5;
                        
                        b=[b; rmsc; entropyc; metrec; smc; noveltyc];
    
                        %title(d(i).name);
    
                        %save([num2str(d(i).name) '.mat'],'ml1')
                    
                        snapnow;
                        close all
                end            
                
            catch
                continue
            end   
        end
        
    end
    
end






               