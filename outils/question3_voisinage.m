% QUESTION3_VOISINAGE Effet du voisinage des maxima locaux sur la densité rho
%   et sur la proportion p de pics conservés après un bruit blanc à 10 dB.
%   21 morceaux de la base (tous les genres), extraits de 10 s.
clear, close all

rng(10)
voisinages = [2 1; 3 2; 5 3; 8 5; 12 8; 20 12];        % [dk dm] : ±dk canaux, ±dm trames
V = size(voisinages, 1);
base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
choix = 1:5:height(base);                               % 21 morceaux, répartis sur les genres
duree = 10;

nb_pics = zeros(V, 1);
nb_communs = zeros(V, 1);                               % même canal et même trame
nb_proches = zeros(V, 1);                               % à ±1 canal et ±1 trame

for i = choix
    [x, Fe] = pretraitement(base.chemin(i));
    L = duree * Fe;
    debut = floor(rand * (length(x) - L));
    extrait = x(debut + 1 : debut + L);
    S_x = spectrogramme(extrait, Fe);
    S_y = spectrogramme(ajouter_bruit(extrait, 10), Fe);

    for v = 1:V
        [k_x, m_x] = detection_pics(S_x, voisinages(v, 1), voisinages(v, 2));
        [k_y, m_y] = detection_pics(S_y, voisinages(v, 1), voisinages(v, 2));
        nb_pics(v) = nb_pics(v) + numel(k_x);
        nb_communs(v) = nb_communs(v) + size(intersect([k_x m_x], [k_y m_y], 'rows'), 1);
        for j = 1:numel(k_x)                            % pics retrouvés à ±1 près
            if any(abs(k_y - k_x(j)) <= 1 & abs(m_y - m_x(j)) <= 1)
                nb_proches(v) = nb_proches(v) + 1;
            end
        end
    end
end

rho = nb_pics / (numel(choix) * duree);                 % pics par seconde
p = nb_communs ./ nb_pics;
p_tolerant = nb_proches ./ nb_pics;
taille_Hz = round((2*voisinages(:, 1) + 1) * Fe / 1024);    % largeur du voisinage en Hz
taille_ms = round((2*voisinages(:, 2) + 1) * 64);           % durée du voisinage en ms

resultats = table(voisinages(:, 1), voisinages(:, 2), taille_Hz, taille_ms, rho, p, p.^2, ...
    p_tolerant, rho .* p.^2, 'VariableNames', ...
    {'dk', 'dm', 'largeur_Hz', 'duree_ms', 'rho', 'p', 'p2', 'p_tolerant', 'rho_p2'})

save('resultats/question3.mat', 'voisinages', 'rho', 'p', 'p_tolerant')

figure, hold on
plot(rho, p, '-o', 'LineWidth', 2)
plot(rho, p.^2, '-s', 'LineWidth', 2)
plot(rho, p_tolerant, '--^', 'LineWidth', 1.5)
text(rho, p + 0.03, compose('%dx%d', 2*voisinages(:, 1) + 1, 2*voisinages(:, 2) + 1), ...
    'HorizontalAlignment', 'center')
set(gca, 'XScale', 'log')
xlabel('Densité \rho (pics/s)'), ylabel('Proportion'), ylim([0 1]), grid on
legend('p (pic exactement conservé)', 'p^2 (paire conservée)', 'p tolérant (±1 canal, ±1 trame)', ...
    'Location', 'southwest')
title('Question 3 : robustesse des pics au bruit blanc à 10 dB selon le voisinage')
exportgraphics(gcf, 'resultats/question3_p_rho.png')