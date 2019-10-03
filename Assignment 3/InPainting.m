clear;
close all

load ('badpicture.mat');



mask = imread('badpixels.tif');
O = load ('badpicture.mat');
F = load ('forcing.mat');

Pix = zeros(720, 1280);


% [j,i]=find(mask==0);
% [p]=find(mask==0);

alpha = 1;

G = imread('greece.tif');
pic = imread('greece.tif');

E = zeros(720, 1280);
I = zeros(720, 1280);
I_next = zeros(720, 1280);

I_f = zeros(720, 1280);
I_fnext = zeros(720, 1280);
E_f = zeros(720, 1280);

forcing = zeros(720, 1280);

for m = 1 : 720
     for n = 1 : 1280 
        forcing(m, n) = F.f(m, n); 
        I(m, n) = O.badpic(m, n);
        
        I_f(m, n) = O.badpic(m, n);
     end
end

%***************************************
iter = 2000;
%***************************************

iter_graph = zeros(1, iter);

% error_unforced = zeros(720, 1280, iter);
% error_forced = zeros(720, 1280, iter);
% 3D Array attempt, doesn't work as (720*1280*2000) = 13.7GB

error_unforced = zeros(720, 1280);
error_forced = zeros(720, 1280);


%Sum of errors for each iteration

error_f_graph = zeros(1, iter);
error_graph = zeros(1, iter);

for time = 1 : iter
    
    for m = 2 : 719
        
         for n = 2 : 1279 
             
             if(mask(m, n) == 1)
                 %*******Without Forcing
                 E(m, n) = I(m - 1, n) + I(m + 1, n) + I(m, n - 1) + I(m, n + 1) - 4 * (I(m, n));
                 I_next(m, n) = I(m, n) + alpha * ((E(m, n)) / 4); 
                 I(m, n) = I_next(m, n);
                 error_unforced(m, n) = pic(m, n) - I(m, n);
                
               
                 %*******With Forcing    
                 E_f(m, n) = I_f(m - 1, n) + I_f(m + 1, n) + I_f(m, n - 1) + I_f(m, n + 1)...
                              - 4 * (I_f(m, n)) - (forcing(m, n));
                 
                 I_fnext(m, n) = I_f(m, n) + alpha * ((E_f(m, n)) / 4); 
                 I_f(m, n) = I_fnext(m, n);
                 error_forced(m, n) = pic(m, n) - I_f(m, n);
                 
             end
         end
    end
    er1 = sum(error_unforced, 'all');
    er2 = sum(error_forced, 'all');
    
    error_graph(1, time) = er1;
    error_f_graph(1, time) = er2;
    
    
    iter_graph(1, iter) = time;
end


% STD = std(error_unforced);
% STDF = std(error_forced);

figure(1);
image(pic);
colormap(gray(256));
title('Good Picture');

figure(2);
image(badpic);
colormap(gray(256));
title('Bad Picture');

figure(3);
image(I);
colormap(gray(256));
title('Restored Picture');

figure(4);
image(I_f);
colormap(gray(256));
title('Restored Picture (with Forcing)');





% NOT WORKING, UNSURE WHY NOT

figure(5);
h = plot(iter_graph, error_graph, 'b-', iter_graph, error_f_graph, 'r--');
grid on;
set(h, 'linewidth', 3.0);
xlabel('No. of Iterations', 'fontsize', 20);
ylabel('STD of Errors', 'fontsize', 20);
title('Forcing vs non-Forcing');
