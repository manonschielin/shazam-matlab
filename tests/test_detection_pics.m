% Test de detection_pics sur 10 s de Pyramids
clear, close all

[x, Fe] = pretraitement('audio/Pyramids.mp3');
debut = 60;                                     % début de l'extrait (s)
extrait = x(debut*Fe + 1 : (debut+10)*Fe);      % 10 s = 80 000 échantillons
[S_dB, f, t] = spectrogramme(extrait, Fe);

[k, m] = detection_pics(S_dB);
nb_pics = numel(k)                              % 795 avec les maxima locaux seuls
rho = nb_pics / 10                              % pics par seconde (cible : 25 à 35)

% Effet de la marge sur la densité de pics
for marge = [0 5 10 15 20]
    [k, m] = detection_pics(S_dB, [], [], marge);
    fprintf('marge = %2d dB : %4d pics, rho = %5.1f pics/s\n', marge, numel(k), numel(k)/10);
end

[k, m] = detection_pics(S_dB);                  % marge par défaut (10 dB) pour la figure

figure
imagesc(t, f, S_dB), axis xy, colorbar, hold on
plot(t(m), f(k), 'wo', 'MarkerSize', 4)         % la constellation en blanc
xlabel('Temps (s)'), ylabel('Fréquence (Hz)')
title('Constellation (maxima 11 x 7, marge 10 dB)')