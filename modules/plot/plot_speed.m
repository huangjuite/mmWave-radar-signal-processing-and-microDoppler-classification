% plot range-angle heatmap
function [axh] = plot_speed(speed,rng_grid,agl_grid)

% polar coordinates
for i = 1:size(agl_grid,2)
    yvalue(i,:) = (sin(agl_grid(i)*pi/180 )).*rng_grid;
end
for i=1:size(agl_grid,2)
    xvalue(i,:) = (cos(agl_grid(i)*pi/180)).*rng_grid;
end

%% plot 2D(range-angle)

% Xsnr = pow2db(Xpow/noisefloor);

figure('visible','off')
% figure()
set(gcf,'Position',[10,10,530,420])
[axh] = surf(agl_grid,rng_grid,speed);
view(0,90)
% axis([-90 90 0 25]);
axis([-60 60 2 25]);
grid off
shading interp
xlabel('Angle of arrive(degrees)')
ylabel('Range(meters)')
colorbar
caxis([-1,1])
title('speed heatmap')

end