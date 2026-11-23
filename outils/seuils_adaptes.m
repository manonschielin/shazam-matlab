% SEUILS_ADAPTES Seuil dépendant de la durée de requête : 1,5 x le plus fort score négatif.
%   Rejoue la décision à partir de evaluation_bruit.mat (aucune nouvelle recherche)
%   et compare avec le seuil fixe de 30.
clear, close all

load('resultats/evaluation_bruit.mat')
pos = est_positive;
marge = 1.5;                                    % « nettement au-dessus » du plus fort négatif

seuils_duree = zeros(numel(durees), 1);
TBD_adapte = zeros(numel(durees), numel(RSB));
TFD_adapte = zeros(numel(durees), numel(RSB));
for d = 1:numel(durees)
    neg_d = score_max(~pos, d, :);              % scores des négatives, tous niveaux de bruit
    seuils_duree(d) = ceil(marge * max(neg_d(:)));
    for s = 1:numel(RSB)
        bon = id_max(pos, d, s) == vrai_id(pos);
        TBD_adapte(d, s) = mean(bon & score_max(pos, d, s) >= seuils_duree(d));
        TFD_adapte(d, s) = mean(score_max(~pos, d, s) >= seuils_duree(d));
    end
end

seuils_duree                                    % un seuil par durée (3, 5, 10 s)
TBD_seuil_30 = TBD                              % rappel : seuil fixe de 30
TBD_adapte
TFD_adapte

save('resultats/seuils_adaptes.mat', 'durees', 'seuils_duree', 'marge', 'TBD_adapte', 'TFD_adapte')

% Comparaison : traits pleins = seuil adapté, pointillés = seuil fixe de 30
abscisse = [25 20 15 10 5 0];
couleurs = lines(numel(durees));
figure, hold on
for d = 1:numel(durees)
    plot(abscisse, 100*TBD_adapte(d, :), '-o', 'Color', couleurs(d, :), 'LineWidth', 2)
    plot(abscisse, 100*TBD(d, :), '--', 'Color', couleurs(d, :), 'LineWidth', 1)
end
xticks(fliplr(abscisse))
xticklabels({'0', '5', '10', '15', '20', 'sans bruit'})
xlabel('RSB (dB)'), ylabel('TBD (%)'), ylim([0 105]), grid on
legend(sprintf('3 s, seuil %d', seuils_duree(1)), '3 s, seuil 30', ...
       sprintf('5 s, seuil %d', seuils_duree(2)), '5 s, seuil 30', ...
       sprintf('10 s, seuil %d', seuils_duree(3)), '10 s, seuil 30', 'Location', 'southeast')
title('Bruit blanc : seuil adapté à la durée (pleins) ou fixe à 30 (pointillés)')
exportgraphics(gcf, 'resultats/TBD_bruit_seuil_adapte.png')