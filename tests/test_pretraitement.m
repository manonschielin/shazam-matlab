% Test de pretraitement sur "Pyramids - Frank Ocean"
clear, close all

[x, Fe] = pretraitement('audio/Pyramids.mp3');

duree = length(x) / Fe          % attendu : 592,99 s (9 min 53)
amplitude_max = max(abs(x))     % attendu : un peu plus de 1 (Gibbs)
% soundsc(x, Fe)                % décommenter pour écouter (clear sound pour arrêter)