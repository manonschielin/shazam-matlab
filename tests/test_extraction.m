% Test de extraction : mêmes résultats qu'avec les fonctions appelées une par une
clear, close all

[x, Fe] = pretraitement('audio/Pyramids.mp3');
extrait = x(60*Fe + 1 : 70*Fe);                 % 10 s à partir de 1 min

[cles_q, m1_q] = extraction(extrait, Fe);
nb_cles_q = numel(cles_q)                       % attendu : 2027

[cles_ref, m1_ref] = extraction(x, Fe);
nb_cles_ref = numel(cles_ref)                   % attendu : 106264