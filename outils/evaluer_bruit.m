% EVALUER_BRUIT TBD et TFD avec bruit blanc, pour plusieurs RSB et durées de requête.
%   Pour chaque morceau et chaque durée, le MÊME extrait reçoit tous les niveaux de bruit.
clear, close all

rng(4)                                          % positions et bruits reproductibles
durees = [3 5 10];                              % durées des requêtes T_q (s)
RSB = [Inf 20 15 10 5 0];                       % Inf = sans bruit
s_thr = 30;

load('resultats/index_base.mat')
base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
neg = readtable('resultats/liste_negatives.csv', 'TextType', 'string', 'Delimiter', ',');
fichiers = [base.chemin; neg.chemin];
est_positive = [true(height(base), 1); false(height(neg), 1)];
vrai_id = [(1:height(base))'; zeros(height(neg), 1)];
N = numel(fichiers);

score_max = zeros(N, numel(durees), numel(RSB));
reponse = zeros(N, numel(durees), numel(RSB));
id_max = zeros(N, numel(durees), numel(RSB));   % morceau au meilleur score (avant le seuil)

tic
for r = 1:N
    [x, Fe] = pretraitement(fichiers(r));       % décodé une seule fois
    for d = 1:numel(durees)
        L = durees(d) * Fe;                     % longueur de l'extrait (échantillons)
        debut = floor(rand * (length(x) - L));
        extrait = x(debut + 1 : debut + L);
        for s = 1:numel(RSB)
            if isinf(RSB(s))
                y = extrait;                    % sans bruit
            else
                y = ajouter_bruit(extrait, RSB(s));
            end
            [cles_q, m1_q] = extraction(y, Fe);
            scores = rechercher(cles_q, m1_q, index);
            [score_max(r, d, s), id_max(r, d, s)] = max(scores);
            reponse(r, d, s) = decider(scores, index, s_thr);
        end
    end
    fprintf('%d / %d\n', r, N);                 % pour suivre l'avancement
end
temps_total = toc

% Taux : une ligne par durée, une colonne par RSB
pos = est_positive;
TBD = squeeze(mean(reponse(pos, :, :) == vrai_id(pos), 1))
TFD = squeeze(mean(reponse(~pos, :, :) ~= 0, 1))

save('resultats/evaluation_bruit.mat', 'score_max', 'id_max', 'reponse', 'est_positive', ...
     'vrai_id', 'durees', 'RSB', 's_thr', 'TBD', 'TFD')

% Figure demandée par le sujet : TBD en fonction du RSB, une courbe par durée
abscisse = [25 20 15 10 5 0];                   % "sans bruit" placé à 25 pour le tracer
figure, hold on
for d = 1:numel(durees)
    plot(abscisse, 100*TBD(d, :), '-o', 'LineWidth', 2)
end
xticks(fliplr(abscisse))
xticklabels({'0', '5', '10', '15', '20', 'sans bruit'})
xlabel('RSB (dB)'), ylabel('TBD (%)'), ylim([0 105]), grid on
legend('T_q = 3 s', 'T_q = 5 s', 'T_q = 10 s', 'Location', 'southeast')
title(sprintf('Bruit blanc : taux de bonne détection (seuil = %d)', s_thr))
exportgraphics(gcf, 'resultats/TBD_bruit_blanc.png')