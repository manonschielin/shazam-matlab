% Premier test d'alignement : extrait de 10 s contre Pyramids entier
clear, close all

[x, Fe] = pretraitement('audio/Pyramids.mp3');

% Référence : le morceau entier
[S_ref, f, t] = spectrogramme(x, Fe);
[k_ref, m_ref] = detection_pics(S_ref);
[k_ref, m_ref] = selection_pics(S_ref, k_ref, m_ref, f, t);
[cles_ref, m1_ref] = empreintes(k_ref, m_ref);
nb_cles_ref = numel(cles_ref)

% Requête : l'extrait de 10 s à partir de 1 min
debut = 60;
extrait = x(debut*Fe + 1 : (debut+10)*Fe);
[S_q, f_q, t_q] = spectrogramme(extrait, Fe);
[k_q, m_q] = detection_pics(S_q);
[k_q, m_q] = selection_pics(S_q, k_q, m_q, f_q, t_q);
[cles_q, m1_q] = empreintes(k_q, m_q);
nb_cles_q = numel(cles_q)

% Correspondances : pour chaque clé de l'extrait, TOUTES les positions dans le morceau
paires = zeros(0, 2);                                 % [m_extrait, m_morceau]
for i = 1:numel(cles_q)
    j = find(cles_ref == cles_q(i));                  % toutes les occurrences de la clé
    paires = [paires; repmat(m1_q(i), numel(j), 1), m1_ref(j)];
end
nb_correspondances = size(paires, 1)

delta = paires(:, 2) - paires(:, 1);                  % décalage de chaque correspondance
[delta_0, score] = mode(delta)                        % décalage le plus fréquent et son nombre
decalage_en_s = delta_0 * 512 / Fe                    % attendu : environ 60 s

% Figure 1 : nuage des correspondances (comme dans l'article de Wang)
figure
plot(paires(:, 1), paires(:, 2), 'b.')
xlabel('Trame dans l''extrait'), ylabel('Trame dans le morceau')
title('Correspondances de clés')

% Figure 2 : histogramme des décalages
figure
subplot(2, 1, 1)
histogram(delta, 'BinMethod', 'integers')
xlabel('\delta (trames)'), ylabel('Nombre de clés')
title('Histogramme des décalages : tout le morceau')
subplot(2, 1, 2)
histogram(delta, 'BinMethod', 'integers')
xlim([delta_0 - 30, delta_0 + 30])
xlabel('\delta (trames)'), ylabel('Nombre de clés')
title('Zoom autour du pic')