% Test de spectrogramme sur 10 s de Pyramids
clear, close all

[x, Fe] = pretraitement('audio/Pyramids.mp3');
debut = 60;                                     % début de l'extrait (s)
extrait = x(debut*Fe + 1 : (debut+10)*Fe);      % 10 s = 80 000 échantillons

% Référence : affichage direct par la fonction MATLAB
N = 1024;                                       % taille de la fenêtre
H = N/2;                                        % avance entre deux trames
figure
spectrogram(extrait, hann(N), N-H, N, Fe, 'yaxis')
title('Référence MATLAB : 10 s à partir de 1 min (Hann, N = 1024)')

% Notre fonction
[S_dB, f, t] = spectrogramme(extrait, Fe);
taille = size(S_dB)                             % attendu : 513 x 155

figure
imagesc(t, f, S_dB)
axis xy                                         % fréquences basses en bas
colorbar
xlabel('Temps (s)'), ylabel('Fréquence (Hz)')
title('S_{dB} de Pyramids avec notre fonction')