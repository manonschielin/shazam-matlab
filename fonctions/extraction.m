function [cles, m1] = extraction(x, Fe, dk, dm, dfc)
% EXTRACTION Chaîne complète d'extraction des empreintes d'un signal.
%   [cles, m1] = extraction(x, Fe) : spectrogramme, pics, sélection, paires.
%   [cles, m1] = extraction(x, Fe, dk, dm) : voisinage des maxima locaux choisi
%   (par défaut celui de detection_pics : dk = 5, dm = 3).
%   [cles, m1] = extraction(x, Fe, dk, dm, dfc) : regroupement des fréquences
%   choisi (par défaut celui de empreintes : dfc = 2).
%   La MÊME fonction sert pour les morceaux de la base et pour les extraits.

if nargin < 3, dk = []; end                           % [] : valeur par défaut
if nargin < 4, dm = []; end
if nargin < 5, dfc = []; end

[S_dB, f, t] = spectrogramme(x, Fe);
[k, m] = detection_pics(S_dB, dk, dm);
[k, m] = selection_pics(S_dB, k, m, f, t);
[cles, m1] = empreintes(k, m, [], [], [], [], dfc);
end