% Test de rechercher : un extrait de 10 s de chaque morceau
clear, close all

load('resultats/index_3_morceaux.mat')                    % l'index construit par test_index
debuts = [60, 30, 45];                          % début de l'extrait dans chaque morceau (s)

for s = 1:numel(index.noms)
    [x, Fe] = pretraitement(index.noms{s});
    extrait = x(debuts(s)*Fe + 1 : (debuts(s)+10)*Fe);
    [cles_q, m1_q] = extraction(extrait, Fe);

    tic
    [scores, decalages] = rechercher(cles_q, m1_q, index);
    temps = toc;

    [~, meilleur] = max(scores);
    fprintf('\nExtrait de %s (à %d s) : réponse = %s, recherche en %.3f s\n', ...
        index.noms{s}, debuts(s), index.noms{meilleur}, temps);
    for j = 1:numel(index.noms)
        fprintf('   %-20s score = %4d   décalage = %6.2f s\n', ...
            index.noms{j}, scores(j), decalages(j) * 512 / Fe);
    end
end