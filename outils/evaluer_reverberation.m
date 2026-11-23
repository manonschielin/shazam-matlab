% EVALUER_REVERBERATION TBD et TFD avec réverbération (T60 = 0,3 et 1 s, avec ou sans son direct).
%   Requêtes de 5 s, seuil adapté (21). Le MÊME extrait passe par les 5 conditions.
clear, close all

rng(8)
duree_q = 5;
load('resultats/seuils_adaptes.mat', 'durees', 'seuils_duree')
s_thr = seuils_duree(durees == duree_q)         % 21
T60s = [0   0.3   1     0.3   1];               % 0 = sans réverbération
DRRs = [NaN -Inf  -Inf  0     0];               % -Inf = sans son direct
conditions = {'sans réverbération', 'T60 0,3 s sans direct', 'T60 1 s sans direct', ...
              'T60 0,3 s, DRR 0 dB', 'T60 1 s, DRR 0 dB'};

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
    Lq = duree_q * Fe;
    L_max = round(max(T60s) * Fe);              % il faut 1 s de musique avant l'extrait
    debut = L_max + floor(rand * (length(x) - Lq - L_max));
    for c = 1:C
        if T60s(c) == 0
            y = x(debut + 1 : debut + Lq);
        else
            L = round(T60s(c) * Fe);
            long = x(debut - L + 1 : debut + Lq);   % T60 de musique en plus avant l'extrait
            if isinf(DRRs(c))
                y = reverberer(long, Fe, T60s(c));
            else
                y = reverberer(long, Fe, T60s(c), DRRs(c));
            end
            y = y(L + 1 : end);
        end
        [cles_q, m1_q] = extraction(y, Fe);
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

save('resultats/evaluation_reverberation.mat', 'score_max', 'id_max', 'est_positive', ...
     'vrai_id', 'conditions', 'T60s', 'DRRs', 'duree_q', 's_thr', 'TBD', 'TFD')

figure
bar(100*TBD)
xticklabels(conditions)
ylabel('TBD (%)'), ylim([0 105]), grid on
text(1:C, 100*TBD + 3, compose('%.1f %%', 100*TBD), 'HorizontalAlignment', 'center')
title(sprintf('Réverbération (T_q = %d s, seuil %d)', duree_q, s_thr))
exportgraphics(gcf, 'resultats/TBD_reverberation.png')