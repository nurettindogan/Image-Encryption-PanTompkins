
clear all
close all
clc

[dosya,konum] = uigetfile('*.jpg;*.jpeg;*.png;*.tiff;*.gif;*.bmp','Lutfen Kripto Edilecek Goruntuyu Seciniz'); %Dosya secme penceresi acilir ve kullanici secim yapar
girdi = imread([konum,dosya]); % Kullanicinin sectigi dosya okunur ve girdi matrisine atanir

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

zlen = size(girdi, 1) * size(girdi, 2);

% Zigzag islemi
% zcikti = reshape(girdi, [zlen 3]);
zcikti(:,1) = zigzag(girdi(:,:,1));
zcikti(:,2) = zigzag(girdi(:,:,2));
zcikti(:,3) = zigzag(girdi(:,:,3));

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

ciktiA = reshape(zcikti, [size(girdi, 1), size(girdi, 2) 3]);

% Affine lokasyon sifreleme 
for c = 1:size(girdi,1)
	ciktiB(mod(a_values(1).*c+b_values(1), size(girdi, 1)) + 1, :, :) = ciktiA(c, :, :);
end

for c = 1:size(girdi,2)
	cikti2(:, mod(a_values(2).*c+b_values(2), size(girdi, 2)) + 1, :) = ciktiB(:, c, :);
end

r_a = round(a_values(3));
r_b = round(b_values(3));
g_a = round(a_values(4));
g_b = round(b_values(4));
b_a = round(a_values(5));
b_b = round(b_values(5));

cikti2 = double(cikti2); % Girdi matrisi double tipine cevrilir (tasma olmamasi icin)

% Affine value sifreleme
cikti3(:,:,1) = mod(r_a.*cikti2 (:,:,1)+r_b ,256);	% Affine sifreleme yapilir
cikti3(:,:,2) = mod(g_a.*cikti2 (:,:,2)+g_b ,256);
cikti3(:,:,3) = mod(b_a.*cikti2 (:,:,3)+b_b ,256);

% Vigenere lokasyon sifreleme
for k=1:128
    for c = 1:size(girdi,1)
        ciktiB(mod(c + vkey(k), size(girdi, 1)) + 1, :, :) = cikti3(c, :, :);
    end
end

for k=129:256
    for c = 1:size(girdi,2)
        cikti2(:, mod(c + vkey(k), size(girdi, 1)) + 1, :) = ciktiB(:, c, :);
    end
end

cikti3 = cikti2;

% Vigenere Cipher

for i=1:size(cikti3,1)
    for j=1:size(cikti3,2)
        for k=1:3
            cikti3(i,j,k) = mod(cikti3(i,j,k) + vkey(mod(j,256)+1), 256);
        end
    end
end

cikti = uint8(cikti3); 					% cikti matrisi girdi2 matrisinin 8 bitlik isaretsiz tam sayiya donusturulmus haline editlenir

vkey_stegano = uint8(vkey);
girdi = uint8(girdi);

% Steganography

disp('Steganography: ');
disp(vkey_stegano);

s1 = size(cikti, 1);
s2 = size(cikti, 2);
sindex = 0;

for i = 1:length(vkey)
	for k = 1:8
		i1 = fix(sindex / s2) + 1;
		i2 = mod(sindex, s2) + 1;
		
		if bitget(vkey_stegano(i), k) == 0
			cikti(i1,i2,1) = bitset(cikti(i1,i2,1), 1, 0);
		else
			cikti(i1,i2,1) = bitset(cikti(i1,i2,1), 1, 1);
		end
		
		sindex = sindex + 1;
	end
end

figure;									% Goruntuleme ekrani olusturulur
imshow(girdi);							% girdi matrisi/goruntusu ekranda gosterilir
title('Secilen Goruntu');				% Ekrana baslik yazilir
figure;									% Goruntuleme ekrani olusturulur
imshow(cikti);							% Cikti matrisi/goruntusu ekranda gosterilir
title('Kriptolanmis Goruntu');			% Ekrana baslik yazilir
imwrite(cikti,['kriptolanmis_',dosya]); % Cikti goruntusu; ilk basta secilen goruntu isminin basina "kriptolanmis" ibaresi eklenerek kaydedilir