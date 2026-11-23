% CONSTRUIRE_INDEX_DEMO Index de la démonstration : les 104 morceaux de la base
%   + 4 morceaux connus (audio/). Ajoute des titres lisibles (index.titres),
%   puis vérifie que chaque morceau connu est retrouvé sur un extrait de 10 s.
clear

base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
connus = {'audio/Pyramids.mp3'; 'audio/Creep.mp3'; 'audio/Dracula.mp3'; 'audio/Roses.mp3'};
titres_connus = ["Frank Ocean - Pyramids"; "Radiohead - Creep"; ...
                 "Tame Impala - Dracula"; "Kanye West - Roses"];

fichiers = [cellstr(base.chemin); connus];
tic
index = construire_index(fichiers);
temps_construction = toc
index.titres = cellstr(["FMA " + base.id + " (" + base.genre + ")"; titres_connus]);
nb_morceaux = numel(index.noms)
nb_entrees = numel(index.id)
save('resultats/index_demo.mat', 'index')

% Vérification : un extrait de 10 s de chaque morceau connu, pris à 60 s
for j = 1:numel(connus)
    [x, Fe] = pretraitement(connus{j});
    extrait = x(60*Fe + 1 : 70*Fe);
    [cles, m1] = extraction(extrait, Fe);
    scores = rechercher(cles, m1, index);
    [id, ~] = decider(scores, index, 26);
    tri = sort(scores, 'descend');
    if id == 0, reponse = "inconnu"; else, reponse = string(index.titres{id}); end
    fprintf('%-25s -> %-25s (score %d, 2e : %d)\n', titres_connus(j), reponse, tri(1), tri(2))
end