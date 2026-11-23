% VERIFIER_MORCEAUX Vérifie que chaque morceau choisi se lit et dure assez longtemps.
%   Affiche les fichiers illisibles ou plus courts que duree_min.
clear

duree_min = 25;                                 % s : il faut pouvoir y prendre des requêtes de 10 s
listes = {'resultats/liste_base.csv', 'resultats/liste_negatives.csv'};

for l = 1:numel(listes)
    T = readtable(listes{l}, 'TextType', 'string', 'Delimiter', ',');   % séparateur imposé
    durees = zeros(height(T), 1);
    for i = 1:height(T)
        try
            info = audioinfo(T.chemin(i));      % lit seulement l'en-tête du fichier
            durees(i) = info.Duration;
        catch
            durees(i) = 0;                      % fichier illisible
        end
    end
    fprintf('\n%s : %d morceaux, durée min = %.1f s, max = %.1f s\n', ...
        listes{l}, height(T), min(durees), max(durees));
    problemes = find(durees < duree_min);
    for i = problemes'
        fprintf('   problème : id %d (%s), durée = %.1f s\n', T.id(i), T.genre(i), durees(i));
    end
end