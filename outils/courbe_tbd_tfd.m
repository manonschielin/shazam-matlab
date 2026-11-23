% COURBE_TBD_TFD Effet du seuil : TBD en fonction du TFD, pour chaque durée de requête.
%   Utilise les scores enregistrés par evaluer_bruit.m (aucune nouvelle recherche).
clear, close all

load('resultats/evaluation_bruit.mat')
pos = est_positive;
seuils = 1:150;
s_rsb = find(RSB == 10);                        % on étudie le cas RSB = 10 dB

figure, hold on
for d = 1:numel(durees)
    sc = score_max(:, d, s_rsb);
    bon = id_max(:, d, s_rsb) == vrai_id;       % le meilleur morceau est le bon
    TBD_s = zeros(size(seuils));
    TFD_s = zeros(size(seuils));
    for i = 1:numel(seuils)
        TBD_s(i) = mean(bon(pos) & sc(pos) >= seuils(i));
        TFD_s(i) = mean(sc(~pos) >= seuils(i));
    end
    plot(100*TFD_s, 100*TBD_s, '-o', 'LineWidth', 2, 'MarkerSize', 3)

    % Seuil le plus bas sans aucune fausse détection
    seuil_min = max(sc(~pos)) + 1;
    fprintf('T_q = %2d s : plus fort score négatif = %3d, seuil sans fausse détection = %3d, TBD = %.1f %%\n', ...
        durees(d), max(sc(~pos)), seuil_min, 100*mean(bon(pos) & sc(pos) >= seuil_min));
end
xlabel('TFD (%)'), ylabel('TBD (%)'), grid on
xlim([0 30]), ylim([0 105])
legend('T_q = 3 s', 'T_q = 5 s', 'T_q = 10 s', 'Location', 'southeast')
title('Bruit blanc à 10 dB : TBD en fonction du TFD (seuil variable)')
exportgraphics(gcf, 'resultats/courbe_TBD_TFD_10dB.png')