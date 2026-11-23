% Test de compresser_mp3 sur 10 s de Pyramids : pics conservés selon le débit
clear, close all

debits = [Inf 128 64 32];                       % Inf = sans compression (référence)
k_ref = []; m_ref = [];
[son, Fe_orig] = audioread('audio/Pyramids.mp3');
extrait = son(60*Fe_orig + 1 : 70*Fe_orig, :);  % 10 s à partir de 1 min, fréquence d'origine
for i = 1:numel(debits)
    tic
    [y, Fe] = compresser_mp3(extrait, Fe_orig, debits(i));
    temps = toc;
    [S, f, t] = spectrogramme(y, Fe);    [k, m] = detection_pics(S);
    [k, m] = selection_pics(S, k, m, f, t);
    if i == 1
        k_ref = k; m_ref = m;                   % pics de la référence
    end
    nb_communs = size(intersect([k_ref m_ref], [k m], 'rows'), 1);
    fprintf('débit %4g kbit/s : %3d pics, %3d conservés, p = %.2f  (%.2f s)\n', ...
        debits(i), numel(k), nb_communs, nb_communs / numel(k_ref), temps);
end