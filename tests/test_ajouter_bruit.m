% Test de ajouter_bruit sur 10 s de Pyramids, et proportion de pics conservés
clear, close all

rng(3)
[x, Fe] = pretraitement('audio/Pyramids.mp3');
extrait = x(60*Fe + 1 : 70*Fe);

RSB_voulu = 10;
y = ajouter_bruit(extrait, RSB_voulu);
RSB_mesure = 10*log10(mean(extrait.^2) / mean((y - extrait).^2))   % attendu : 10
% soundsc(y, Fe)                                % décommenter pour écouter

% Pics de l'extrait propre et de l'extrait bruité
[S_x, f, t] = spectrogramme(extrait, Fe);
[k_x, m_x] = detection_pics(S_x);
[k_x, m_x] = selection_pics(S_x, k_x, m_x, f, t);

[S_y, f, t] = spectrogramme(y, Fe);
[k_y, m_y] = detection_pics(S_y);
[k_y, m_y] = selection_pics(S_y, k_y, m_y, f, t);

nb_pics_propre = numel(k_x)
nb_pics_bruite = numel(k_y)
nb_communs = size(intersect([k_x m_x], [k_y m_y], 'rows'), 1)   % pics exactement au même endroit
p = nb_communs / nb_pics_propre                 % proportion de pics conservés

figure
imagesc(t, f, S_y), axis xy, colorbar, hold on
plot(t(m_x), f(k_x), 'wo', 'MarkerSize', 6)     % pics du signal propre
plot(t(m_y), f(k_y), 'rx', 'MarkerSize', 6)     % pics du signal bruité
legend('Pics sans bruit', 'Pics avec bruit (10 dB)', 'Location', 'northwest')
xlabel('Temps (s)'), ylabel('Fréquence (Hz)')
title('Effet d''un bruit blanc à 10 dB sur la constellation')
exportgraphics(gcf, 'resultats/constellation_bruit_10dB.png')