% CHOISIR_MORCEAUX Tire au hasard les morceaux FMA de la base et des requêtes négatives.
%   13 morceaux par genre pour la base (104) et 7 autres par genre pour les
%   requêtes négatives (56), sans recouvrement. Tirage reproductible (rng).
clear

rng(1)                                          % même tirage à chaque exécution
nb_base = 13;                                   % morceaux par genre dans la base
nb_neg = 7;                                     % morceaux par genre pour les négatives

T = readtable('../fma/fma_small_genres.csv', 'TextType', 'string', 'Delimiter', ',');
exclus = [98565 98567 98569];                   % fichiers trop courts (vu avec verifier_morceaux)
T(ismember(T.id, exclus), :) = [];              % on les retire avant le tirage
genres = unique(T.genre);                       % les 8 genres

base = table();
negatives = table();
for g = 1:numel(genres)
    lignes = find(T.genre == genres(g));        % les 1000 morceaux de ce genre
    melange = lignes(randperm(numel(lignes)));  % dans un ordre aléatoire
    base = [base; T(melange(1:nb_base), :)];                            % les 13 premiers
    negatives = [negatives; T(melange(nb_base+1 : nb_base+nb_neg), :)]; % les 7 suivants
end

base.chemin = "../fma/" + base.chemin;          % chemins depuis le dossier projet
negatives.chemin = "../fma/" + negatives.chemin;

writetable(base, 'resultats/liste_base.csv');
writetable(negatives, 'resultats/liste_negatives.csv');

% Vérifications
nb_base_total = height(base)                    % attendu : 104
nb_negatives_total = height(negatives)          % attendu : 56
par_genre_base = groupcounts(base, 'genre')     % attendu : 13 par genre
nb_en_commun = numel(intersect(base.id, negatives.id))   % attendu : 0