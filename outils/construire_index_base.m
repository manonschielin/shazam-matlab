% CONSTRUIRE_INDEX_BASE Index inversé des 104 morceaux FMA de la base.
%   Mesure le temps de construction et la taille de l'index, puis le sauvegarde.
clear

T = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
fichiers = cellstr(T.chemin);                   % liste de noms au format attendu par construire_index

tic
index = construire_index(fichiers);
temps_construction = toc                        % en secondes

nb_morceaux = numel(index.noms)                 % attendu : 104
nb_entrees = numel(index.id)
nb_cles_differentes = numel(index.cles)
entrees_par_morceau_moyenne = nb_entrees / nb_morceaux
plus_long_bloc = max(index.nombre)

infos = whos('index');
taille_index_Mo = infos.bytes / 1e6             % taille en mémoire

save('resultats/index_base.mat', 'index')