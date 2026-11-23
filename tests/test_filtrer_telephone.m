% Test de filtrer_telephone : vérification de la propriété de la question 2,
% puis proportion de pics conservés.
clear, close all

[x, Fe] = pretraitement('audio/Pyramids.mp3');
extrait = x(60*Fe + 1 : 70*Fe);
[y, b, a] = filtrer_telephone(extrait, Fe);

[S_x, f, t] = spectrogramme(extrait, Fe);
S_y = spectrogramme(y, Fe);
D = S_y - S_x;                                  % décalage dû au filtrage, pour chaque (k, m)

% Question 2 : S_y,dB - S_x,dB en fonction de k, pour plusieurs trames
trames = [20 60 100 140];
H = freqz(b, a, f, Fe);                         % réponse du filtre aux fréquences des canaux
figure, hold on
for m = trames
    plot(f, D(:, m), 'LineWidth', 1)
end
plot(f, 20*log10(abs(H)), 'w--', 'LineWidth', 2)
xlabel('Fréquence (Hz)'), ylabel('S_{y,dB} - S_{x,dB} (dB)'), grid on
ylim([-80 10])
legend([compose('trame %d', trames), {'g(k) = 20 log_{10}|H(k)|'}], 'Location', 'south')
title('Filtrage 300-3400 Hz : décalage vertical selon le canal, pour 4 trames')
exportgraphics(gcf, 'resultats/question2_decalage_filtrage.png')

% Proportion de pics conservés
[k_x, m_x] = detection_pics(S_x);
[k_x, m_x] = selection_pics(S_x, k_x, m_x, f, t);
[k_y, m_y] = detection_pics(S_y);
[k_y, m_y] = selection_pics(S_y, k_y, m_y, f, t);
nb_communs = size(intersect([k_x m_x], [k_y m_y], 'rows'), 1);
p = nb_communs / numel(k_x)