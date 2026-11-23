% EVALUER_MP3 TBD et TFD après compression MP3, pour plusieurs débits (requêtes de 5 s).
%   Chaque morceau est lu une seule fois ; le MÊME extrait passe par tous les débits.
clear, close all

rng(5)                                          % positions reproductibles
debits = [Inf 128 64 32 16 8];                  % Inf = sans compression
duree_q = 5;                                    % durée des requêtes (s)
load('resultats/seuils_adaptes.mat', 'durees', 'seuils_duree')
s_thr = seuils_duree(durees == duree_q)         % seuil adapté à 5 s (21)

load('resultats/index_base.mat')
base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
neg = readtable('resultats/liste_negatives.csv', 'TextType', 'string', 'Delimiter', ',');
fichiers = [base.chemin; neg.chemin];
est_positive = [true(height(base), 1); false(height(neg), 1)];
vrai_id = [(1:height(base))'; zeros(height(neg), 1)];
N = numel(fichiers);

score_max = zeros(N, numel(debits));
id_max = zeros(N, numel(debits));

tic
for r = 1:N
    [son, Fe_orig] = audioread(fichiers(r));    % lu une seule fois
    L = duree_q * Fe_orig;
    debut = floor(rand * (size(son, 1) - L));   % position au hasard (échantillons)
    extrait = son(debut + 1 : debut + L, :);
    for b = 1:numel(debits)
        [y, Fe] = compresser_mp3(extrait, Fe_orig, debits(b));
        [cles_q, m1_q] = extraction(y, Fe);
        scores = rechercher(cles_q, m1_q, index);
        [score_max(r, b), id_max(r, b)] = max(scores);
    end
    if mod(r, 20) == 0
        fprintf('%d / %d  (%.0f s écoulées)\n', r, N, toc);
    end
end
temps_total = toc

% Taux : une colonne par débit
pos = est_positive;
TBD = mean(id_max(pos, :) == vrai_id(pos) & score_max(pos, :) >= s_thr, 1)
TFD = mean(score_max(~pos, :) >= s_thr, 1)

save('resultats/evaluation_mp3.mat', 'score_max', 'id_max', 'est_positive', 'vrai_id', ...
     'duree_q', 'debits', 's_thr', 'TBD', 'TFD')

% Figure : TBD (axe de gauche) et score médian des positives (axe de droite)
mediane = median(score_max(pos, :), 1);
etiquettes = [{'sans'}, arrayfun(@num2str, debits(2:end), 'UniformOutput', false)];

figure
yyaxis left
plot(1:numel(debits), 100*TBD, '-o', 'LineWidth', 2)
ylabel('TBD (%)'), ylim([0 105])
yyaxis right
plot(1:numel(debits), mediane, '--s', 'LineWidth', 2)
yline(s_thr, ':', sprintf('seuil = %d', s_thr), 'LineWidth', 1.5)
ylabel('Score médian des positives'), ylim([0 max(mediane)*1.1])
xticks(1:numel(debits)), xticklabels(etiquettes)
xlabel('Débit MP3 (kbit/s)'), grid on
legend('TBD', 'Score médian', 'Location', 'southwest')
title(sprintf('Compression MP3 (T_q = %d s, seuil %d)', duree_q, s_thr))
exportgraphics(gcf, 'resultats/TBD_mp3.png')