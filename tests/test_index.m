% Test de construire_index sur 3 morceaux
clear, close all

fichiers = {'audio/Pyramids.mp3', 'audio/Creep.mp3', 'audio/Dracula.mp3'};
tic
index = construire_index(fichiers);
temps_construction = toc                        % en secondes

nb_entrees = numel(index.id)                    % nombre total de lignes
nb_cles_differentes = numel(index.cles)
entrees_par_morceau = accumarray(index.id, 1)'  % nombre de clés de chaque morceau
plus_long_bloc = max(index.nombre)              % la clé la plus fréquente

save('resultats/index_3_morceaux.mat', 'index')           % pour ne pas tout recalculer ensuite