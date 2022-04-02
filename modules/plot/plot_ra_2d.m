% plot 3D point clouds
function [axh] = plot_ra_2d(detout)
% detout format: % [range bin, velocity bin, angle bin, power, range(m), ...
% velocity (m/s), angle(degree)]

figure('visible','off')
% x-direction: Doppler, y-direction: angle, z-direction: range
[axh] = scatter(detout(:, 7), detout(:, 5), 'filled');
xlabel('Azimuth angle (degrees)')
ylabel('Range (m)')
axis([-60 60 2 25]);
title('3D point clouds')
grid on

end