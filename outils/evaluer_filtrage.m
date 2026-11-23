% EVALUER_FILTRAGE TBD et TFD avec filtrage « téléphone » 300-3400 Hz, avec ou sans bruit.
%   Requêtes de 5 s, seuil adapté (21). Le MÊME extrait passe par les 4 conditions.
clear, close all

rng(6)                                          % positions et bruits reproductibles
duree_q = 5;
load('resultats/seuils_adaptes.mat', 'durees', 'seuils_duree')
s_thr = seuils_duree(durees == duree_q)         % 21
RSB_dB = 10;
conditions = {'sans dégradation', 'filtre 300-3400 Hz', 'bruit 10 dB', 'filtre + bruit 10 dB'};

load('resultats/index_base.mat')
base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
neg = readtable('resultats/liste_negatives.csv', 'TextType', 'string', 'Delimiter', ',');
fichiers = [base.chemin; neg.chemin];
est_positive = [true(height(base), 1); false(height(neg), 1)];
vrai_id = [(1:height(base))'; zeros(height(neg), 1)];
N = numel(fichiers);
C = numel(conditions);

score_max = zeros(N, C);
id_max = zeros(N, C);

tic
for r = 1:N
    [x, Fe] = pretraitement(fichiers(r));
    L = duree_q * Fe;
    debut = floor(rand * (length(x) - L));
    extrait = x(debut + 1 : debut + L);

    filtre = filtrer_telephone(extrait, Fe);    % ce que joue le haut-parleur
    versions = {extrait, ...
                filtre, ...
                ajouter_bruit(extrait, RSB_dB), ...
                ajouter_bruit(filtre, RSB_dB)}; % le bruit s'ajoute au niveau du micro

    for c = 1:C
        [cles_q, m1_q] = extraction(versions{c}, Fe);
        scores = rechercher(cles_q, m1_q, index);
        [score_max(r, c), id_max(r, c)] = max(scores);
    end
    if mod(r, 40) == 0, fprintf('%d / %d  (%.0f s)\n', r, N, toc); end
end

pos = est_positive;
TBD = mean(id_max(pos, :) == vrai_id(pos) & score_max(pos, :) >= s_thr, 1);
TFD = mean(score_max(~pos, :) >= s_thr, 1);
mediane = median(score_max(pos, :), 1);
resultats = table(conditions', 100*TBD', 100*TFD', mediane', ...
    'VariableNames', {'condition', 'TBD_pourcent', 'TFD_pourcent', 'score_median'})

save('resultats/evaluation_filtrage.mat', 'score_max', 'id_max', 'est_positive', 'vrai_id', ...
     'conditions', 'duree_q', 's_thr', 'RSB_dB', 'TBD', 'TFD')

figure
bar(100*TBD)
xticklabels(conditions)
ylabel('TBD (%)'), ylim([0 105]), grid on
text(1:C, 100*TBD + 3, compose('%.1f %%', 100*TBD), 'HorizontalAlignment', 'center')
title(sprintf('Filtrage téléphone et bruit (T_q = %d s, seuil %d)', duree_q, s_thr))
exportgraphics(gcf, 'resultats/TBD_filtrage.png')