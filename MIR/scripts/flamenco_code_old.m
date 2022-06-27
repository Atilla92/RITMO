mirverbose(0)
close all

b=[]; 
filenames = {};

[b,filenames] = recurse(b,filenames);

save('Sevilla.mat','b','filenames');


function [b,filenames] = recurse(b,filenames)
d = dir;

    for i = 3:length(d)
        if d(i).isdir
            disp('/////////////////')
            d(i).name
            cd(d(i).name);
            [b,filenames] = recurse(b,filenames)
            cd ..
        else
            try
                if strcmp(d(i).name(end-3:end), '.WAV')
                        rms = mirrms(d(i).name, 'Frame')
                        entropy = mirentropy(d(i).name);
                        
                end

                                  
                    b=[b; rms, entropy];
                    filenames{end+1} = d(i).name;
                    
                
            catch
                continue
            end   
        end
        
    end
    for fuc=1:length(b)
    for sty=1:2
        s = mirgetdata(b(fuc));
        t = mirgetdata(b(sty));
        matr = [];
        new_row = [s;t];
        matri = [matr(1:end,:); new_row];
        disp(matri)
        save test1.mat matri;
    end
    end      
end






               