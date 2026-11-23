% Test de reverberer sur 10 s de Pyramids : pics conservés et spectrogrammes
clear, close all

rng(7)
[x, Fe] = pretraitement('audio/Pyramids.mp3');
debut = 60*Fe;  Lq = 10*Fe;
extrait = x(debut + 1 : debut + Lq);

[S_x, f, t] = spectrogramme(extrait, Fe);
[k_x, m_x] = detection_pics(S_x);
[k_x, m_x] = selection_pics(S_x, k_x, m_x, f, t);

T60s = [0.3 1 0.3 1];
DRRs = [-Inf -Inf 0 0];                         % -Inf : pas de son direct (pire cas)
S_r = cell(1, numel(T60s));
for i = 1:numel(T60s)
    L = round(T60s(i) * Fe);
    long = x(debut - L + 1 : debut + Lq);       % T60 de musique en plus avant l'extrait
    if isinf(DRRs(i))
        y = reverberer(long, Fe, T60s(i));
    else
        y = reverberer(long, Fe, T60s(i), DRRs(i));
    end
    y = y(L + 1 : end);                         % on retire ce début : même extrait qu'avant
    S_r{i} = spectrogramme(y, Fe);
    [k_y, m_y] = detection_pics(S_r{i});
    [k_y, m_y] = selection_pics(S_r{i}, k_y, m_y, f, t);
    p = size(intersect([k_x m_x], [k_y m_y], 'rows'), 1) / numel(k_x);
    fprintf('T60 = %.1f s, DRR = %4g dB : %d pics, p = %.2f\n', T60s(i), DRRs(i), numel(k_y), p);
end

% Spectrogrammes : sans réverbération et avec T60 = 1 s (2 premières secondes)
figure
subplot(2, 1, 1)
imagesc(t, f, S_x), axis xy, colorbar, xlim([0 2])
title('Sans réverbération'), ylabel('Fréquence (Hz)')
subplot(2, 1, 2)
imagesc(t, f, S_r{2}), axis xy, colorbar, xlim([0 2])
title('Réverbération T_{60} = 1 s'), xlabel('Temps (s)'), ylabel('Fréquence (Hz)')
exportgraphics(gcf, 'resultats/reverberation_spectrogrammes.png')