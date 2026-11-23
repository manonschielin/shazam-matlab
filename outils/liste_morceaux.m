% LISTE_MORCEAUX Liste complète des morceaux utilisés dans le projet, avec leur rôle :
%   base (104), negative (56), passage_echelle (896 autres morceaux FMA), demo (4).
%   Écrit resultats/liste_morceaux.csv (à joindre au rendu).
clear

base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
neg = readtable('resultats/liste_negatives.csv', 'TextType', 'string', 'Delimiter', ',');
genres = readtable('../fma/fma_small_genres.csv', 'TextType', 'string', 'Delimiter', ',');
load('resultats/cles_1000.mat', 'chemins')

% Les 896 morceaux du passage à l'échelle : ceux de cles_1000 qui ne sont pas dans la base
autres = chemins(~ismember(chemins, base.chemin));
L = strlength(autres);
id_autres = str2double(extractBetween(autres, L - 9, L - 4));   % ex. .../086140.mp3 -> 86140
[~, ligne] = ismember(id_autres, genres.id);
genre_autres = genres.genre(ligne);

id = [base.id; neg.id; id_autres; NaN(4, 1)];
genre = [base.genre; neg.genre; genre_autres; strings(4, 1)];
role = [repmat("base", height(base), 1); repmat("negative", height(neg), 1); ...
        repmat("passage_echelle", numel(autres), 1); repmat("demo", 4, 1)];
fichier = [base.chemin; neg.chemin; autres; ...
           "Frank Ocean - Pyramids"; "Radiohead - Creep"; ...
           "Tame Impala - Dracula"; "Kanye West - Roses"];

T = table(id, genre, role, fichier);
writetable(T, 'resultats/liste_morceaux.csv')

% Vérifications
nb_total = height(T)                            % attendu : 1060
par_role = groupcounts(T, 'role')               % attendu : 104 / 56 / 896 / 4
genre_manquant = sum(T.genre == "" & T.role ~= "demo")   % attendu : 0