% JMMORA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Otsu algorithm

img = imread("piezas.jpg");
figure(1); 
imshow(img);
size(img) % to be sure in is greyscale

%Calcular y representar histograma directamente con funcion nativa de Octave:
h = hist(img(:),0:255);

% Binarizar rapido sin algoritmo: (el inconveniente es que le tenemos que dar nosotros el valor de umbral T)
%T = 150;
%out = 255*(img >= T); % img sera 0 o 1 segun la evaluacion del >= para cada pixel
%figure()
%imshow(out)

% Algoritmo Otsu:
%% Define sa y m
sa = cumsum(h);
m = cumsum((0:255).*h);
%%Comprobacion de por ej el calculo de la media
mean(mean(img)) %esto tiene que ser igual a:
m(256)/sa(256)
%%Seguimos
[a b] = size(img)
img = single(img);
mu1 = (img(1,1) + img(1,b) + img(a,1) + img(a,b))/4
mu2 = m(256)/sa(256)
T = floor((mu1+mu2)/2)
Told = 0;
while Told ~= T
  Told = T;
  mu1 = m(T)/sa(T)
  mu2 = (m(256) - m(T))/(sa(256)-sa(T))
  T = floor((mu1+mu2)/2)
end

% check
mask = img< T;
figure(2); imshow(mask)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Equalization
% the equalization formula is:
% newlevels = cdf(g) - cdf_min
%             ----------------- * 255
%             cdf(255)-cdf_min

clear  all;

img =imread('helicoptero.bmp');
figure()
subplot(121)
imshow(img);

subplot(122)
hist(img(:),0:255);
h = hist(img(:),0:255);
sa = cumsum(h);
cdf = 255*sa/sa(256);
figure();
plot(cdf);
axis([0 255 0 255]);

[a b] = size(img);
for n=1:a
   for m=1:b
      gris = img(n, m);
      out(n, m) = cdf (gris+1);
   end
end

figure();
subplot(121);
imshow(uint8(out));

subplot (122)
hist(uint8(out(:)),0:255);
