function [x, Fe] = pretraitement(fichier, Fe_cible)
% PRETRAITEMENT Charge un fichier audio, le passe en mono et le ré-échantillonne.
%   [x, Fe] = pretraitement(fichier) ré-échantillonne à 8 kHz.
%   [x, Fe] = pretraitement(fichier, Fe_cible) utilise une autre fréquence.

if nargin < 2
    Fe_cible = 8000;
end

[son, Fe_orig] = audioread(fichier);   % son : une colonne par voie

x = mean(son, 2);                      % mono : moyenne des voies gauche et droite

x = resample(x, Fe_cible, Fe_orig);    % filtre anti-repliement puis changement de Fe
Fe = Fe_cible;
end
