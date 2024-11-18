path = '*\MIIA STED summary\image examples\WT\high DA - red';
imagefiles = dir(fullfile(path, '*.tif'));
folders = dir(path);
images_green = {};
images_red = {};
green_channel_intensity = {};
red_channel_intensity = {};
pixel = 0.022;

for ii = 1:length(imagefiles)
    
    currentfile = imagefiles(ii).name;
    filenames{ii} = erase(currentfile, '.tif');
    currentimg_gr = imread(currentfile,1);
    currentimg_red = imread(currentfile,2);
    images_green{ii} = currentimg_gr; 
    images_red{ii} = currentimg_red;
    green_channel_intensity{end+1} = [mean((currentimg_gr),'all')];
    red_channel_intensity{end+1} = [mean((currentimg_red),'all')];

end

       
green_parameters = {};
red_parameters = {};
iccs_parameters = {}; 

for ii = 1:length(images_green)

    green = images_green{ii};
    red = images_red{ii};
    imgseries = cat(3, green, red);

    ICS2DCorr_gr = corrfunc(imgseries(:,:,1));
    ICS2DCorr_red = corrfunc(imgseries(:,:,2));

    ICS2DCorrCrop_gr = autocrop(ICS2DCorr_gr,12);
    figure(3);
    f = surf(ICS2DCorrCrop_gr(:,:,1));
    axis tight
    colormap(jet)
    xlabel('\eta', 'FontSize', 12)
    ylabel('\xi', 'FontSize', 12)
    zlabel('r(\xi, \eta)', 'FontSize', 12)
    title('ICS2DCrop-green')
    figname = strcat('ICS2DCrop_gr',filenames{ii},'.png');
    saveas(f,figname,'png');

    ICS2DCorrCrop_red = autocrop(ICS2DCorr_red,12);
    figure(4);
    g = surf(ICS2DCorrCrop_red(:,:,1));
    axis tight
    colormap(jet)
    xlabel('\eta', 'FontSize', 12)
    ylabel('\xi', 'FontSize', 12)
    zlabel('r(\xi, \eta)', 'FontSize', 12)
    title('ICS2DCrop-red')
    figname = strcat('ICS2DCrop_red',filenames{ii},'.png');
    saveas(g,figname,'png');

    ICS_green_series{ii} = ICS2DCorrCrop_gr;
    ICS_red_series{ii} = ICS2DCorrCrop_red;

    ICCS = corrfunc_cross(imgseries(:,:,1),imgseries(:,:,2));
    ICCS_crop = autocrop(ICCS,12);
            %ICCS_crop = ICCS;
    ICCS_series{ii} = ICCS_crop; 

    h = surf(ICCS_crop(:,:,1));
    axis tight
    colormap(jet)
    xlabel('\eta', 'FontSize', 12)
    ylabel('\xi', 'FontSize', 12)
    zlabel('r(\xi, \eta)', 'FontSize', 12)
    set(h, 'LineStyle', 'none')
    title('ICCS2DCrop')
    figname = strcat('ICCS_crop',filenames{ii},'.png');
    saveas(h,figname,'png');

    a = gaussfit(ICS2DCorrCrop_gr, '2d', pixel, 'y');
    green_parameters{ii} = a;
    fig = plotgaussfit_bl(a(1,1:6), ICS2DCorrCrop_gr(:,:,1), pixel, 'y');
    figname = strcat('ICS2DCrop_gr_fit',filenames{ii}, '.fig');
    saveas(fig, figname, 'fig');

    b = gaussfit(ICS2DCorrCrop_red, '2d', pixel, 'y');
    red_parameters{ii} = b;
    fig = plotgaussfit_bl(b(1,1:6), ICS2DCorrCrop_red(:,:,1), pixel, 'y');
    figname = strcat('ICS2DCrop_red_fit',filenames{ii}, '.fig');
    saveas(fig, figname, 'fig');

    c = gaussfit(ICCS_crop, '2d', pixel, 'y');
    iccs_parameters{ii} = c;
    %plotgaussfit_bl(c(1,1:6), ICCS_crop(:,:,1), pixel, 'y');
    figname = strcat('ICCS2DCrop_fit',filenames{ii});
    %savefig(figname);

    disp(ii)

end

green_channel_fits = {};

for i = 1:length(green_parameters)
    params = cell2mat(green_parameters(i));
    particlesPerBeamArea_gr = 1/params(1);
    beamArea_gr = pi*params(2)*params(3);
    density_gr = particlesPerBeamArea_gr/beamArea_gr;
    green_channel_fits{i} = [particlesPerBeamArea_gr beamArea_gr density_gr];
    green_channel_particles{i} = [particlesPerBeamArea_gr];
    green_channel_BA{i} = [beamArea_gr];
end

red_channel_fits = {};

for i = 1:length(red_parameters)
    params = cell2mat(red_parameters(i));
    particlesPerBeamArea_red = 1/params(1);
    beamArea_red = pi*params(2)*params(3);
    density_red = particlesPerBeamArea_red/beamArea_red;
    red_channel_fits{i} = [particlesPerBeamArea_red beamArea_red density_red];
    red_channel_particles{i} = [particlesPerBeamArea_red];
    red_channel_BA{i} = [beamArea_red];
end

iccs_fits = {};

for i = 1:length(iccs_parameters)
    iccs_params = cell2mat(iccs_parameters(i));
    green_params = cell2mat(green_channel_fits(i));
    red_params = cell2mat(red_channel_fits(i));
    if green_params(2) > red_params(2)
        particlesPerBeamArea_iccs = (iccs_params(1)/((1/green_params(1))*(1/red_params(1))))*(green_params(2)/red_params(2));
    else
        particlesPerBeamArea_iccs = (iccs_params(1)/((1/green_params(1))*(1/red_params(1))))*(red_params(2)/green_params(2));
    end
    particlesPerBeamArea_iccs = 1/iccs_params(1);
    beamArea_iccs = pi*iccs_params(2)*iccs_params(3);
    density_iccs = particlesPerBeamArea_iccs/beamArea_iccs;
    r_iccs =(iccs_params(1)/((1/green_params(1))*(1/red_params(1))));
    iccs_fits{i} = [particlesPerBeamArea_iccs beamArea_iccs density_iccs r_iccs];

    iccs_channel_particles{i} = [particlesPerBeamArea_iccs];
    iccs_channel_BA{i} = [beamArea_iccs];


end

for i = 1:length(imagefiles)
    results = [green_channel_particles(i); red_channel_particles(i); iccs_channel_particles(i); green_channel_BA(i); red_channel_BA(i); iccs_channel_BA(i); green_channel_intensity(i); red_channel_intensity(i)];
    mat = cell2mat(results);
    file = strcat(filenames{i}, '.xlsx');
    writematrix(mat, file);
end
    %filename_gr = strcat(filename, '_green.tiff');
    %filename_red = strcat(filename, '_red.tiff');
    %imwrite(cell2mat(images_green), filename_gr);
    %imwrite(cell2mat(images_red), filename_red);


