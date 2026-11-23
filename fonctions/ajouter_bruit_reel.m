function y = ajouter_bruit_reel(x, bruit, RSB_dB)
% AJOUTER_BRUIT_REEL Ajoute un passage d'un bruit enregistré pour obtenir un RSB donné.
%   y = ajouter_bruit_reel(x, bruit, RSB_dB) : bruit est un enregistrement déjà
%   prétraité (mono, 8 kHz), plus long que x ; on en prend un passage au hasard.
%   La puissance du signal est calculée sur x (l'extrait), comme l'exige le sujet.

L = length(x);
debut = floor(rand * (length(bruit) - L));
b = bruit(debut + 1 : debut + L);                     % passage de bruit au hasard

P_x = mean(x.^2);
P_b = mean(b.^2);
b = b * sqrt(P_x / (P_b * 10^(RSB_dB / 10)));        % bruit mis à la puissance voulue
y = x + b;
end