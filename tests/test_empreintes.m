% Test de empreintes sur 10 s de Pyramids
clear, close all

[x, Fe] = pretraitement('audio/Pyramids.mp3');
debut = 60;                                     % début de l'extrait (s)
extrait = x(debut*Fe + 1 : (debut+10)*Fe);      % 10 s = 80 000 échantillons
[S_dB, f, t] = spectrogramme(extrait, Fe);
[k, m] = detection_pics(S_dB);
[k, m] = selection_pics(S_dB, k, m, f, t);      % 259 pics

[cles, m1, triplets] = empreintes(k, m);
nb_cles = numel(cles)                           % au plus 259 x 10 = 2590
cles_par_pic = nb_cles / numel(k)               % au plus F = 10
nb_cles_differentes = numel(unique(cles))
premiers_triplets = triplets(1:5, :)            % [Qf(k1)  Qf(k2)  dm]

% Les paires d'une ancre prise vers 5 s
t = t(:);  f = f(:);
[m_tri, ordre] = sort(m);  k_tri = k(ordre);
i = find(t(m_tri) >= 5, 1);                     % première ancre après 5 s
dm = m_tri - m_tri(i);  dk = abs(k_tri - k_tri(i));
cibles = find(dm >= 1 & dm <= 24 & dk <= 60);
cibles = cibles(1:min(10, numel(cibles)));

figure
imagesc(t, f, S_dB), axis xy, colorbar, hold on
plot(t(m), f(k), 'wo', 'MarkerSize', 5)
for j = cibles'
    plot(t([m_tri(i) m_tri(j)]), f([k_tri(i) k_tri(j)]), 'r-', 'LineWidth', 1.5)
end
plot(t(m_tri(i)), f(k_tri(i)), 'rs', 'MarkerSize', 10, 'LineWidth', 2)   % l'ancre
xlabel('Temps (s)'), ylabel('Fréquence (Hz)')
title('Les paires d''une ancre (carré rouge) vers 5 s')