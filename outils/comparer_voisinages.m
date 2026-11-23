% COMPARER_VOISINAGES Voisinage 11x7 (actuel) contre 17x11, sur toute la base.
%   Construit l'index 17x11, puis évalue les deux réglages sur les mêmes extraits
%   de 5 s, sans bruit et avec bruit blanc à 10 et 5 dB (seuil 21).
clear, close all

rng(11)
duree_q = 5;
s_thr = 21;
RSB = [Inf 10 5];
reglages = [5 3; 8 5];                          % [dk dm] : 11x7 et 17x11
noms = {'11x7', '17x11'};

base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
neg = readtable('resultats/liste_negatives.csv', 'TextType', 'string', 'Delimiter', ',');

% Les deux index
load('resultats/index_base.mat')
index_v = {index, []};
tic
index_v{2} = construire_index(cellstr(base.chemin), reglages(2, 1), reglages(2, 2));
temps_index_17x11 = toc
index = index_v{2};
save('resultats/index_base_17x11.mat', 'index')
nb_entrees = [numel(index_v{1}.id), numel(index_v{2}.id)]

% Évaluation
fichiers = [base.chemin; neg.chemin];
est_positive = [true(height(base), 1); false(height(neg), 1)];
vrai_id = [(1:height(base))'; zeros(height(neg), 1)];
N = numel(fichiers);
score_max = zeros(N, numel(RSB), 2);
id_max = zeros(N, numel(RSB), 2);

for r = 1:N
    [x, Fe] = pretraitement(fichiers(r));
    L = duree_q * Fe;
    debut = floor(rand * (length(x) - L));
    extrait = x(debut + 1 : debut + L);
    for s = 1:numel(RSB)
        if isinf(RSB(s)), y = extrait; else, y = ajouter_bruit(extrait, RSB(s)); end
        for v = 1:2                             % le MÊME extrait bruité pour les deux réglages
            [cles_q, m1_q] = extraction(y, Fe, reglages(v, 1), reglages(v, 2));
            scores = rechercher(cles_q, m1_q, index_v{v});
            [score_max(r, s, v), id_max(r, s, v)] = max(scores);
        end
    end
    if mod(r, 40) == 0, fprintf('%d / %d  (%.0f s)\n', r, N, toc); end
end

% Tableau : une ligne par (réglage, RSB)
pos = est_positive;
lignes = {};
for v = 1:2
    for s = 1:numel(RSB)
        bon = id_max(pos, s, v) == vrai_id(pos);
        lignes(end+1, :) = {noms{v}, RSB(s), ...
            100*mean(bon & score_max(pos, s, v) >= s_thr), ...
            100*mean(score_max(~pos, s, v) >= s_thr), ...
            median(score_max(pos, s, v)), max(score_max(~pos, s, v))};
    end
end
resultats = cell2table(lignes, 'VariableNames', ...
    {'voisinage', 'RSB_dB', 'TBD_pourcent', 'TFD_pourcent', 'score_median_pos', 'max_negatif'})

save('resultats/comparaison_voisinages.mat', 'score_max', 'id_max', 'est_positive', ...
     'vrai_id', 'reglages', 'RSB', 'duree_q', 's_thr')