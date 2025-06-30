clc;
clear;
close all;

% Load dataset
filename = "C:\Users\Software\Downloads\indian_preprate.nc";  % Adjust path as needed
lat = ncread(filename, 'lat');      % 105 x 1
lon = ncread(filename, 'lon');      % 83 x 1
precip = ncread(filename, 'TRMM_3B42_Daily_7_precipitation');  % 83 x 105

% Create meshgrid for plotting
[LonGrid, LatGrid] = meshgrid(lat, lon);  % 83 x 105

% ITU rain attenuation model parameters (for 28 GHz)
k = 0.03;
alpha = 0.7;

% Compute attenuation (dB/km) from precipitation data
attenuation = k * (precip .^ alpha);  % 83 x 105

% === Define scenarios ===
scenarios = {'urban', 'suburban', 'highway'};

% Normal (ITU-based) attenuation values in dB/km for each scenario
normal_conditions.urban.A = 2; normal_conditions.urban.TxPower = 35; normal_conditions.urban.Sensitivity = -90;
normal_conditions.suburban.A = 1.2; normal_conditions.suburban.TxPower = 33; normal_conditions.suburban.Sensitivity = -92;
normal_conditions.highway.A = 0.8; normal_conditions.highway.TxPower = 30; normal_conditions.highway.Sensitivity = -95;

% Tropical attenuation values (dataset mean) for each scenario
dataset_atten = mean(attenuation(:), 'omitnan');  % Tropical average attenuation

tropical_conditions.urban.A = dataset_atten + 1.0; tropical_conditions.urban.TxPower = 35; tropical_conditions.urban.Sensitivity = -90;
tropical_conditions.suburban.A = dataset_atten + 0.5; tropical_conditions.suburban.TxPower = 33; tropical_conditions.suburban.Sensitivity = -92;
tropical_conditions.highway.A = dataset_atten; tropical_conditions.highway.TxPower = 30; tropical_conditions.highway.Sensitivity = -95;

% Distances to simulate over
distances = 0.1:0.1:5;  % km

% Function to calculate received power, path loss, and link margin
calc_metrics = @(s, d) deal(...
    s.TxPower - s.A * d, ...                       % Received Power
    s.A * d, ...                                   % Path Loss
    s.TxPower - s.A * d - s.Sensitivity);          % Link Margin

% === Plot Link Margin - Normal ===
figure('Position', [100, 100, 1200, 600]);
hold on;
for i = 1:length(scenarios)
    scenario_name = scenarios{i};
    lm = zeros(1, length(distances));
    for j = 1:length(distances)
        [~, ~, LM] = calc_metrics(normal_conditions.(scenario_name), distances(j));
        lm(j) = LM;
    end
    plot(distances, lm, 'DisplayName', scenario_name, 'LineWidth', 2, 'LineStyle', '-');
end
xlabel('Distance (km)', 'FontSize', 14);
ylabel('Link Margin (dB)', 'FontSize', 14);
title('Link Margin - Normal Conditions (ITU)', 'FontSize', 16);
legend('show', 'Location', 'best');
grid on;
set(gca, 'FontSize', 12);

% === Plot Link Margin - Tropical ===
figure('Position', [100, 100, 1200, 600]);
hold on;
for i = 1:length(scenarios)
    scenario_name = scenarios{i};
    lm = zeros(1, length(distances));
    for j = 1:length(distances)
        [~, ~, LM] = calc_metrics(tropical_conditions.(scenario_name), distances(j));
        lm(j) = LM;
    end
    plot(distances, lm, 'DisplayName', scenario_name, 'LineWidth', 2, 'LineStyle', '--');
end
xlabel('Distance (km)', 'FontSize', 14);
ylabel('Link Margin (dB)', 'FontSize', 14);
title('Link Margin - Tropical Conditions (Dataset)', 'FontSize', 16);
legend('show', 'Location', 'best');
grid on;
set(gca, 'FontSize', 12);

% === Plot Path Loss - Normal ===
figure('Position', [100, 100, 1200, 600]);
hold on;
for i = 1:length(scenarios)
    scenario_name = scenarios{i};
    pl = zeros(1, length(distances));
    for j = 1:length(distances)
        [~, PL, ~] = calc_metrics(normal_conditions.(scenario_name), distances(j));
        pl(j) = PL;
    end
    plot(distances, pl, 'DisplayName', scenario_name, 'LineWidth', 2, 'LineStyle', '-');
end
xlabel('Distance (km)', 'FontSize', 14);
ylabel('Path Loss (dB)', 'FontSize', 14);
title('Path Loss - Normal Conditions (ITU)', 'FontSize', 16);
legend('show', 'Location', 'best');
grid on;
set(gca, 'FontSize', 12);

% === Plot Path Loss - Tropical ===
figure('Position', [100, 100, 1200, 600]);
hold on;
for i = 1:length(scenarios)
    scenario_name = scenarios{i};
    pl = zeros(1, length(distances));
    for j = 1:length(distances)
        [~, PL, ~] = calc_metrics(tropical_conditions.(scenario_name), distances(j));
        pl(j) = PL;
    end
    plot(distances, pl, 'DisplayName', scenario_name, 'LineWidth', 2, 'LineStyle', '--');
end
xlabel('Distance (km)', 'FontSize', 14);
ylabel('Path Loss (dB)', 'FontSize', 14);
title('Path Loss - Tropical Conditions (Dataset)', 'FontSize', 16);
legend('show', 'Location', 'best');
grid on;
set(gca, 'FontSize', 12);

% === Heatmap of Attenuation - Normal (ITU) ===
figure('Position', [100, 100, 1200, 600]);
imagesc(lat, lon, k * (precip .^ alpha));  % Using ITU-based precipitation data
set(gca, 'YDir', 'normal');
colorbar;
title('Heatmap of Rain Attenuation at 28 GHz - Normal (ITU)', 'FontSize', 16);
xlabel('Latitude', 'FontSize', 14);
ylabel('Longitude', 'FontSize', 14);
set(gca, 'FontSize', 12);

% === Heatmap of Attenuation - Tropical ===
figure('Position', [100, 100, 1200, 600]);
imagesc(lat, lon, attenuation);  % Using dataset-based attenuation
set(gca, 'YDir', 'normal');
colorbar;
title('Heatmap of Rain Attenuation at 28 GHz - Tropical (Dataset)', 'FontSize', 16);
xlabel('Latitude', 'FontSize', 14);
ylabel('Longitude', 'FontSize', 14);
set(gca, 'FontSize', 12);

