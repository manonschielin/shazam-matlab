% QUESTION4_DFC Effet du regroupement des fréquences dfc sur le nombre de clés,
%   les correspondances parasites et le TBD. Toute la base, extraits de 5 s,
%   sans bruit et avec bruit blanc à 10 et 5 dB.
clear, close all

rng(12)
duree_q = 5;
s_thr = 21;
RSB = [Inf 10 5];
dfcs = [1 2 4 8];
D = numel(dfcs);

base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
neg = readtable('resultats/liste_negatives.csv', 'TextType', 'string', 'Delimiter', ',');

% Les index (dfc = 2 existe déjà)
index_d = cell(1, D);
for d = 1:D
    fichier = sprintf('resultats/index_base_dfc%d.mat', dfcs(d));
    if dfcs(d) == 2
        load('resultats/index_base.mat')
    elseif isfile(fichier)
        load(fichier)
    else
        tic
        index = construire_index(cellstr(base.chemin), [], [], dfcs(d));
        fprintf('index dfc %d construit en %.0f s\n', dfcs(d), toc)
        save(fichier, 'index')
    end
    index_d{d} = index;
end

nb_entrees = cellfun(@(ix) numel(ix.id), index_d)
nb_cles_differentes = cellfun(@(ix) numel(ix.cles), index_d)
taille_moyenne_bloc = nb_entrees ./ nb_cles_differentes

% Évaluation
fichiers = [base.chemin; neg.chemin];
est_positive = [true(height(base), 1); false(height(neg), 1)];
vrai_id = [(1:height(base))'; zeros(height(neg), 1)];
N = numel(fichiers);
score_max = zeros(N, numel(RSB), D);
id_max = zeros(N, numel(RSB), D);
temps_recherche = zeros(1, D);

tic
for r = 1:N
    [x, Fe] = pretraitement(fichiers(r));
    L = duree_q * Fe;
    debut = floor(rand * (length(x) - L));
    extrait = x(debut + 1 : debut + L);
    for s = 1:numel(RSB)
        if isinf(RSB(s)), y = extrait; else, y = ajouter_bruit(extrait, RSB(s)); end
        for d = 1:D                             % le MÊME extrait bruité pour les 4 réglages
            [cles_q, m1_q] = extraction(y, Fe, [], [], dfcs(d));
            t0 = tic;
            scores = rechercher(cles_q, m1_q, index_d{d});
            temps_recherche(d) = temps_recherche(d) + toc(t0);
            [score_max(r, s, d), id_max(r, s, d)] = max(scores);
        end
    end
    if mod(r, 40) == 0, fprintf('%d / %d  (%.0f s)\n', r, N, toc); end
end
temps_par_requete_ms = 1000 * temps_recherche / (N * numel(RSB))

% Tableau : une ligne par (dfc, RSB), seuil fixe 21 et seuil adapté
pos = est_positive;
lignes = {};
for d = 1:D
    thr = ceil(1.5 * max(score_max(~pos, :, d), [], 'all'));   % même règle que seuils_adaptes
    for s = 1:numel(RSB)
        bon = id_max(pos, s, d) == vrai_id(pos);
        lignes(end+1, :) = {dfcs(d), RSB(s), ...
            100*mean(bon & score_max(pos, s, d) >= s_thr), ...
            100*mean(score_max(~pos, s, d) >= s_thr), ...
            thr, 100*mean(bon & score_max(pos, s, d) >= thr), ...
            median(score_max(pos, s, d)), median(score_max(~pos, s, d)), ...
            max(score_max(~pos, s, d))};
    end
end
resultats = cell2table(lignes, 'VariableNames', ...
    {'dfc', 'RSB_dB', 'TBD_21', 'TFD_21', 'seuil_adapte', 'TBD_adapte', ...
     'median_pos', 'median_neg', 'max_neg'})

save('resultats/question4_dfc.mat', 'score_max', 'id_max', 'est_positive', 'vrai_id', ...
     'dfcs', 'RSB', 'duree_q', 'nb_entrees', 'nb_cles_differentes', 'temps_par_requete_ms')