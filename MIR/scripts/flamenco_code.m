mirverbose(0)
close all

b=[]; 
ml1 = {};
ml2 = {};
fp1 = {};
fp2 = {};
filenames = {};

[b,filenames, ml1, ml2, fp1, fp2] = recurse(b,filenames, ml1, ml2, fp1, fp2);

save('features.mat','b','filenames', 'ml1', 'ml2', 'fp1','fp2');
%writecell(features.mat, 'features.csv')

function [b,filenames, ml1, ml2, fp1, fp2] = recurse(b,filenames, ml1, ml2, fp1, fp2)
d = dir;

    for i = 3:length(d)
        if d(i).isdir
            disp('/////////////////')
            d(i).name
            cd(d(i).name);
            [b,filenames, ml1, ml2, fp1, fp2] = recurse(b,filenames, ml1, ml2, fp1, fp2);
            cd ..
        else
            try
                if strcmp(d(i).name(end-3:end), '.wav')

                        rms = mirrms(d(i).name, 'Frame');
                        m1 = mirgetdata(rms);
                        f1 = get(rms,'FramePos');
                        f1{1}{1};
                        
                        entropy = mirentropy(d(i).name, 'Frame');
                        m2 = mirgetdata(entropy);
                        f2 = get(entropy,'FramePos');
                        f2{1}{1};
                        
                        filenames{end+1} = d(i).name;
                        ml1{end+1} = m1;
                        ml2{end+1} = m2;
                        fp1{end+1} = f1;
                        fp2{end+1} = f2;
                        
                        b=[b; ml1; ml2];
    
                        title(d(i).name)
    
                        %save([num2str(d(i).name) '.mat'],'ml1')
                    
                        snapnow
                        close all
                end            
                
            catch
                continue
            end   
        end
        
    end
    
end






               