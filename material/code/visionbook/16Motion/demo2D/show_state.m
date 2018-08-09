function show_state(S,conf)
%%SHOW_STATE Display samples with color according to the weight
%%CMP Vision Algorithms cmpvia@cmp.felk.cvut.cz

col_max = max(S.pi);

% During the first run create handles for the plots and store it to the
% 'UserData' property of the figure

if isempty(find(findobj == 100))
    h = zeros(1,conf.N);
    figure(100);
    col = 1-S.pi(1)/col_max;
    h(1) = imshow(S.img);
    axis on;
    hold on;
    h(2) = plot(S.s(2,1),S.s(1,1),'o','Color',[col col col]);
    for i = 2:conf.N
        col = 1-S.pi(i)/col_max;
        h(i+1) = plot(S.s(2,i),S.s(1,i),'o','Color',[col col col]);
    end
    title(sprintf('step: %d',1));
    set(100,'UserData',[2 h]);
else
    % Update the data in the plots
    h = get(100,'UserData');
    set(h(2),'CData',S.img);
    for i = 1:conf.N
        col = 1-S.pi(i)/col_max;
        set(h(i+2),'XData',S.s(2,i));
        set(h(i+2),'YData',S.s(1,i));
        set(h(i+2),'Color',[col col col]);
    end
    h(1) = h(1) + 1;
    title(sprintf('step: %d',h(1)));
    set(100,'UserData',h);
end
% Force drawing
drawnow;