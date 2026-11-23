% EVALUER_BRUIT_REEL Brouhaha (bruit de foule) comparé au bruit blanc, aux mêmes RSB.
%   Requêtes de 5 s, seuil adapté (21). Le MÊME extrait passe par les 7 conditions.
clear, close all

rng(9)
duree_q = 5;
load('resultats/seuils_adaptes.mat', 'durees', 'seuils_duree')
s_thr = seuils_duree(durees == duree_q)         % 21
RSB = [10 5 0];

[bruit, Fe_b] = pretraitement('audio/brouhaha.mp3');   % 2 min de bruit de foule, 8 kHz

% Spectre moyen des deux bruits (même puissance), pour comprendre les résultats
[S_brouhaha, f] = spectrogramme(bruit(1:30*Fe_b), Fe_b);
blanc = randn(30*Fe_b, 1) * sqrt(mean(bruit.^2));
S_blanc = spectrogramme(blanc, Fe_b);
figure
plot(f, mean(S_brouhaha, 2), f, mean(S_blanc, 2), 'LineWidth', 2)
xlabel('Fréquence (Hz)'), ylabel('Niveau moyen (dB)'), grid on
legend('Brouhaha', 'Bruit blanc (même puissance)')
title('Spectre moyen des deux bruits')
exportgraphics(gcf, 'resultats/spectre_bruits.png')

% Évaluation
conditions = {'sans bruit'};
for s = 1:numel(RSB)
    conditions = [conditions, {sprintf('blanc %d dB', RSB(s)), sprintf('brouhaha %d dB', RSB(s))}];
end

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

    versions = {extrait};
    for s = 1:numel(RSB)
        versions = [versions, {ajouter_bruit(extrait, RSB(s)), ajouter_bruit_reel(extrait, bruit, RSB(s))}];
    end

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

save('resultats/evaluation_bruit_reel.mat', 'score_max', 'id_max', 'est_positive', ...
     'vrai_id', 'conditions', 'RSB', 'duree_q', 's_thr', 'TBD', 'TFD')

% TBD en fonction du RSB : bruit blanc et brouhaha
figure, hold on
plot(RSB, 100*TBD(2:2:end), '-o', 'LineWidth', 2)
plot(RSB, 100*TBD(3:2:end), '-s', 'LineWidth', 2)
yline(100*TBD(1), '--', 'sans bruit')
set(gca, 'XDir', 'reverse')                     % du plus faible bruit au plus fort
xlabel('RSB (dB)'), ylabel('TBD (%)'), ylim([0 105]), grid on
legend('Bruit blanc', 'Brouhaha', 'Location', 'southwest')
title(sprintf('Bruit blanc et brouhaha (T_q = %d s, seuil %d)', duree_q, s_thr))
exportgraphics(gcf, 'resultats/TBD_brouhaha.png')