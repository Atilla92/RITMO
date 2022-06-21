function m = metrograph(input,bpm,t1,t2,subd)
% m = metrograph(input,bpm,t1,t2,subd)
% input is a file name.
% bpm is the tempo in BPM.
% t1 is the starting time in seconds.
% t2 is the ending time in seconds.
% subd is the subdivision of the quarter note to be displayed (for
% instance, 1, 3, 4).
% 2022, Olivier Lartillot, UIO

if nargin < 3
    t1 = 0;
end
if nargin >= 4
    input = miraudio(input,'Extract',t1,t2);
end
if nargin < 5
    subd = 1;
end
o = mironsets(input,'Detect',0);
d = mirgetdata(o);

t = get(o,'Time');
t = t{1}{1};

if isnumeric(bpm)
    f = bpm/60/4;
    tb = (0:100)/f + t1;
    ib = zeros(1,length(tb));
    m = [];
    for i = 1:length(ib)-1
        f = find(t >= tb(i),1);
        if isempty(f)
            break
        end
        ib(i) = f;
        if i > 1
            m(i-1,1:ib(i)-ib(i-1)) = d(ib(i-1)+1:ib(i));
        end
    end

    figure,imagesc(m);
    lob = size(m,2);
    set(gca,'XTick',lob*(0:.25:1)+.5)
    set(gca,'XTickLabel',1:4)
    set(gca,'YTick',[])
    grid on
    set(gca,'GridColor','k')
    set(gca,'LineWidth',2)
    hold on
    yl = ylim;
    for i = 0:.25/subd:1
        plot(lob*[i,i]+.5,yl,'w')
    end
else
    bpm = load(bpm);
    figure, hold on
    subdiv = 8;
    if 1 % alignment bar by bar
        for i = 0:floor(length(bpm)/subdiv) - 1
            t1 = find(t>bpm(subdiv*i+1+1),1);
            t2 = find(t>bpm(subdiv*(i+1)+1+1),1);
            N = t2-t1;
            X = 0:1/N:1;
            Y = i + (0:1)';
            Z = repmat(d(t1:t2)',[2,1]);
            surfplot(X,Y,Z)
        end
    else % alignment beat by beat
        bar = 1;
        beat = 1;
        for i = 0:length(bpm) - 3
            t1 = find(t>bpm(i+1+1),1);
            t2 = find(t>bpm((i+1)+1+1),1);
            N = t2-t1;
            X = (beat - 1 + (0:1/N:1)) / subdiv;
            Y = bar - 1 + (0:1)';
            Z = repmat(d(t1:t2)',[2,1]);
            surfplot(X,Y,Z)
            beat = beat + 1;
            if beat == subdiv + 1
                bar = bar + 1;
                beat = 1;
            end
        end
    end
end