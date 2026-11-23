% TEST_RECHERCHER Compare l'ancienne et la nouvelle version de rechercher :
%   mêmes scores attendus, et temps de calcul de chacune.
clear
load('resultats/index_base.mat')
base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');

rng(14)
ecart_max = 0;
t_ancien = 0;
t_nouveau = 0;
for r = 1:20
    [x, Fe] = pretraitement(base.chemin(5 * r));
    L = 5 * Fe;
    debut = floor(rand * (length(x) - L));
    y = ajouter_bruit(x(debut + 1 : debut + L), 10);
    [c, m1] = extraction(y, Fe);
    tic, s1 = rechercher_ancien(c, m1, index); t_ancien = t_ancien + toc;
    tic, s2 = rechercher(c, m1, index);        t_nouveau = t_nouveau + toc;
    ecart_max = max(ecart_max, max(abs(s1 - s2)));
end
ecart_max                                     % attendu : 0
temps_ancien_ms = 1000 * t_ancien / 20
temps_nouveau_ms = 1000 * t_nouveau / 20