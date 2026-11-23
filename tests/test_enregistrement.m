% TEST_ENREGISTREMENT Joue un extrait de la base, l'enregistre au micro et le cherche.
clear, close all

distance_cm = 10;                                     % à changer selon la position du haut-parleur
duree = 10;
s_thr = 26;                                           % seuil adapté pour 10 s

load('resultats/index_base.mat')
base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
i = randi(height(base));                              % un morceau au hasard
[fichier, debut_s] = jouer_et_enregistrer(i, distance_cm, duree);

[x, Fe] = pretraitement(fichier);
[cles, m1] = extraction(x, Fe);
[scores, decalages] = rechercher(cles, m1, index);
[id, nom] = decider(scores, index, s_thr);

[tri, ordre] = sort(scores, 'descend');
fprintf('\nJoué   : morceau %d (%s), à partir de %.1f s\n', i, base.genre(i), debut_s)
fprintf('Trouvé : morceau %d  ->  %s\n', id, string(nom))
fprintf('3 meilleurs scores : %d (n°%d), %d (n°%d), %d (n°%d)\n', ...
        tri(1), ordre(1), tri(2), ordre(2), tri(3), ordre(3))
if id == i
    debut_trouve = decalages(id) * 512 / Fe;          % 1 trame = 512 échantillons = 64 ms
    fprintf('Décalage trouvé : %.2f s  ->  retard de la chaîne audio ≈ %.2f s\n', ...
            debut_trouve, debut_s - 0.5 - debut_trouve)
end