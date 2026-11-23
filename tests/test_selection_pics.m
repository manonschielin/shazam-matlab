% Test de selection_pics sur 10 s de Pyramids
clear, close all

[x, Fe] = pretraitement('audio/Pyramids.mp3');
debut = 60;                                     % début de l'extrait (s)
extrait = x(debut*Fe + 1 : (debut+10)*Fe);      % 10 s = 80 000 échantillons
[S_dB, f, t] = spectrogramme(extrait, Fe);
[k, m] = detection_pics(S_dB);                  % 629 pics avec la marge de 10 dB

% Sélection : 5 pics par bande et par seconde
[k2, m2] = selection_pics(S_dB, k, m, f, t);
nb_pics_final = numel(k2)
rho_final = nb_pics_final / 10                  % attendu : 30 au plus

figure
imagesc(t, f, S_dB), axis xy, colorbar, hold on
plot(t(m2), f(k2), 'wo', 'MarkerSize', 5)
yline([200 330 543 894 1474 2428 4000], 'w--')  % limites des bandes
xlabel('Temps (s)'), ylabel('Fréquence (Hz)')
title('Constellation finale (5 pics par bande et par seconde)')