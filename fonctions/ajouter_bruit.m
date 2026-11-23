function y = ajouter_bruit(x, RSB_dB)
% AJOUTER_BRUIT Ajoute un bruit blanc gaussien pour obtenir un RSB donné.
%   y = ajouter_bruit(x, RSB_dB) : la puissance du signal est calculée sur x
%   lui-même (l'extrait qui sert de requête), comme l'exige le sujet.

P_x = mean(x.^2);                                     % puissance de l'extrait
P_b = P_x / 10^(RSB_dB / 10);                         % puissance de bruit voulue
b = sqrt(P_b) * randn(size(x));                       % bruit blanc gaussien
y = x + b;
end