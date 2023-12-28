
clear all
close all
clc

[dosya,konum] = uigetfile('*.jpg;*.jpeg;*.png;*.tiff;*.gif;*.bmp','Lutfen Kripto Edilecek Goruntuyu Seciniz'); % Dosya secme penceresi acilir ve kullanici secim yapar
girdi = imread([konum,dosya]);	% Kullanicinin sectigi dosya okunur ve girdi matrisine atanir

girdi = uint8(girdi);

vkey = zeros(256, 1);

ecg = load('ecg.mat');
ecg_data = ecg.val;

[m,n] = size(ecg_data);

if m > n
  ecg_data = ecg_data';  
end

% fprintf("Vigenere Key:\n");

for i = 1:256
    vkey(i) = ecg_data(1, i);
end

vkey_stegano = uint8(zeros(256, 1));

s1 = size(girdi, 1);
s2 = size(girdi, 2);
sindex = 0;

for i = 1:length(vkey_stegano)
	for k = 1:8
		i1 = fix(sindex / s2) + 1;
		i2 = mod(sindex, s2) + 1;
		
		if bitget(girdi(i1, i2, 1), 1) == 0
			vkey_stegano(i) = bitset(vkey_stegano(i), k, 0);
		else
			vkey_stegano(i) = bitset(vkey_stegano(i), k, 1);
		end
		
		sindex = sindex + 1;
	end
end

disp('Steganography : ');
disp(vkey_stegano);

disp('Steganography data is equal: ');
disp(isequal(uint8(vkey), vkey_stegano));

girdi2 = double(girdi);

zlen = size(girdi, 1) * size(girdi, 2);

a_values = zeros(5, 1);
b_values = zeros(5, 1);

e_index = 256;

% a ve b degerlerini ECG verisinden al
for i = 1:5
	while true
		e_index = e_index + 1;
		if gcd(ecg_data(1, e_index), zlen) == 1
			a_values(i) = ecg_data(1, e_index);
			break;
		end
	end
end

for i = 1:5
	e_index = e_index + 1;
	b_values(i) = ecg_data(1, e_index);
end

% Vigenere Cipher

% Vigenere value cozme
for i=1:size(girdi2,1)
    for j=1:size(girdi2,2)
        for k=1:3
            girdi2(i,j,k) = mod(girdi2(i,j,k) - vkey(mod(j,256)+1), 256);
        end
    end
end

% Vigenere lokasyon cozme
for k=1:128
    for c = 1:size(girdi,1)
        ciktiB(c, :, :) = girdi2(mod(c + vkey(k), size(girdi, 1)) + 1, :, :);
    end
end

for k=129:256
    for c = 1:size(girdi,2)
        cikti2(:, c, :) = ciktiB(:, mod(c + vkey(k), size(girdi, 1)) + 1, :);
    end
end

cikti2 = double(cikti2);

r_a = round(a_values(3));
r_b = round(b_values(3));
g_a = round(a_values(4));
g_b = round(b_values(4));
b_a = round(a_values(5));
b_b = round(b_values(5));

[g,z1,d] = gcd(r_a,256); % Girilen a degerine gore z degeri elde edilir
[g,z2,d] = gcd(g_a,256);
[g,z3,d] = gcd(b_a,256);

% Affine value cozme
cikti(:,:,1) = uint8(mod(z1.*(cikti2(:,:,1)-r_b) ,256)); % Sifre cozme islemi yapilir
cikti(:,:,2) = uint8(mod(z2.*(cikti2(:,:,2)-g_b) ,256));
cikti(:,:,3) = uint8(mod(z3.*(cikti2(:,:,3)-b_b) ,256));

% z_values = zeros(1, 3);
% 
% for i = 1:3
% 	[g,z_values(i),d] = gcd(a_values(i+3),zlen);
% end

% Affine lokasyon cozme 
for c = 1:size(girdi,1)
	ciktiA(c, :, :) = cikti(mod(a_values(1).*c+b_values(1), size(girdi, 1)) + 1, :, :);
end

for c = 1:size(girdi,2)
	ciktiB(:, c, :) = ciktiA(:, mod(a_values(2).*c+b_values(2), size(girdi, 2)) + 1, :);
end

zcikti2 = reshape(ciktiB, [zlen 3]);

% Zigzag islemi
cikti3(:,:,1) = izigzag(zcikti2(:,1), size(girdi,1), size(girdi,2));
cikti3(:,:,2) = izigzag(zcikti2(:,2), size(girdi,1), size(girdi,2));
cikti3(:,:,3) = izigzag(zcikti2(:,3), size(girdi,1), size(girdi,2));

% cikti3 = reshape(zcikti2, [size(girdi,1), size(girdi,2) 3]);

cikti3 = uint8(cikti3);		% cikti matrisi 8 bitlik isaretsiz tam sayiya cevrilir
girdi = uint8(girdi);		% girdi matrisi 8 bitlik isaretsiz tam sayiya cevrilir
figure;						% Goruntuleme ekrani olusturulur
imshow(girdi);				% girdi matrisi/goruntusu ekranda gosterilir
title('Kriptolu Goruntu');	% Ekrana baslik yazilir
figure;						% Goruntuleme ekrani olusturulur
imshow(cikti3);				% cikti matrisi/goruntusu ekranda gosterilir
title('Cozulmus Goruntu');	% Ekrana baslik yazilir