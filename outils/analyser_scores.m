% ANALYSER_SCORES Positives faibles, scores par genre et seuil automatique.
%   Utilise les résultats de evaluer.m (resultats/evaluation_10s.mat).
clear, close all

load('resultats/evaluation_10s.mat')
base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
pos = est_positive;

% 1. Les 10 requêtes positives au score le plus faible
scores_pos = score_max(pos);
genres_pos = base.genre(vrai_id(pos));
ids_pos = base.id(vrai_id(pos));
[~, ordre] = sort(scores_pos);
fprintf('\nLes 10 positives les plus faibles :\n')
for i = ordre(1:10)'
    fprintf('   id %6d  %-14s score = %4d\n', ids_pos(i), genres_pos(i), scores_pos(i));
end

% 2. Score médian des positives par genre
par_genre = groupsummary(table(genres_pos, scores_pos), 'genres_pos', {'median', 'min'})

% 3. Seuil automatique à partir des scores parasites (modèle gaussien sur le log)
log_parasites = log(score_parasite(score_parasite > 0));
mu = mean(log_parasites);
sigma = std(log_parasites);
TFD_vise = 0.001;                               % 0,1 % de fausses détections
z = sqrt(2) * erfinv(1 - 2*TFD_vise);           % P(gaussienne > z) = TFD_vise
s_thr_auto = exp(mu + z*sigma)

figure
histogram(log_parasites, 'Normalization', 'pdf'), hold on
u = linspace(min(log_parasites) - 1, mu + 4*sigma, 200);
plot(u, exp(-(u - mu).^2 / (2*sigma^2)) / (sigma*sqrt(2*pi)), 'LineWidth', 2)
xline(log(s_thr_auto), 'r--', sprintf('seuil auto = %.1f', s_thr_auto), ...
    'LineWidth', 2, 'FontSize', 12, 'LabelOrientation', 'horizontal', ...
    'LabelHorizontalAlignment', 'left')
xlabel('log(score parasite)'), ylabel('Densité')
legend('Mesures', 'Modèle gaussien', 'Location', 'northwest')
title('Scores des meilleurs mauvais morceaux (160 requêtes)')
exportgraphics(gcf, 'resultats/seuil_automatique.png')