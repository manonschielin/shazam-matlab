% EVALUER Requêtes positives (dans la base) et négatives (absentes) sans dégradation.
%   Calcule le TBD et le TFD pour un seuil donné et trace les histogrammes des scores.
clear, close all

rng(2)                                          % positions des extraits reproductibles
duree_q = 10;                                   % durée des requêtes (s)
s_thr = 30;                                     % seuil de décision

load('resultats/index_base.mat')                % l'index des 104 morceaux
base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
neg = readtable('resultats/liste_negatives.csv', 'TextType', 'string', 'Delimiter', ',');

fichiers = [base.chemin; neg.chemin];
est_positive = [true(height(base), 1); false(height(neg), 1)];
vrai_id = [(1:height(base))'; zeros(height(neg), 1)];   % ligne i de la liste = morceau i de l'index
N = numel(fichiers);

score_max = zeros(N, 1);                        % meilleur score de la requête
score_parasite = zeros(N, 1);                   % meilleur score parmi les mauvais morceaux
reponse = zeros(N, 1);                          % id répondu (0 = inconnu)
temps = zeros(N, 1);                            % temps de recherche

for r = 1:N
    [x, Fe] = pretraitement(fichiers(r));
    debut = floor(rand * (length(x) - duree_q*Fe));     % position au hasard (en échantillons)
    extrait = x(debut + 1 : debut + duree_q*Fe);
    [cles_q, m1_q] = extraction(extrait, Fe);

    tic
    scores = rechercher(cles_q, m1_q, index);
    temps(r) = toc;

    score_max(r) = max(scores);
    reponse(r) = decider(scores, index, s_thr);
    if est_positive(r)
        scores(vrai_id(r)) = -Inf;              % on retire le bon morceau
    end
    score_parasite(r) = max(scores);
end

% Résultats
pos = est_positive;
nb_bonnes = sum(pos & reponse == vrai_id)
nb_confusions = sum(pos & reponse ~= vrai_id & reponse ~= 0)
nb_non_detections = sum(pos & reponse == 0)
nb_fausses_detections = sum(~pos & reponse ~= 0)
TBD = nb_bonnes / sum(pos)
TFD = nb_fausses_detections / sum(~pos)
score_min_positives = min(score_max(pos))
score_max_negatives = max(score_max(~pos))
score_max_parasites = max(score_parasite)
temps_moyen_requete = mean(temps)

save('resultats/evaluation_10s.mat', 'score_max', 'score_parasite', 'reponse', ...
     'est_positive', 'vrai_id', 'temps', 's_thr', 'duree_q')

% Histogrammes des scores (question 5), abscisse logarithmique
bords = logspace(0, 3.5, 36);                   % de 1 à environ 3000
figure
histogram(max(score_max(pos), 1), bords), hold on
histogram(max(score_max(~pos), 1), bords)
xline(s_thr, 'w--', 'seuil')
set(gca, 'XScale', 'log')
xlabel('Meilleur score de la requête'), ylabel('Nombre de requêtes')
legend('Requêtes positives', 'Requêtes négatives')
title('Scores des requêtes (10 s, sans dégradation')
exportgraphics(gcf, 'resultats/histogramme_scores_10s.png')