function [k, m] = selection_pics(S_dB, k, m, f, t, pics_par_bande_s, bandes)
% SELECTION_PICS Garde les pics les plus forts dans chaque bande et chaque seconde.
%   [k, m] = selection_pics(S_dB, k, m, f, t) garde 5 pics par bande et par seconde,
%   avec les 6 bandes géométriques du sujet entre 200 et 4000 Hz.
%   k, m : pics trouvés par detection_pics ; f, t : sorties de spectrogramme.

if nargin < 6 || isempty(pics_par_bande_s), pics_par_bande_s = 5; end
if nargin < 7, bandes = [200 330 543 894 1474 2428 4000]; end

f = f(:);  t = t(:);                                  % tout en colonnes
force = S_dB(sub2ind(size(S_dB), k, m));              % valeur en dB de chaque pic
seconde = floor(t(m));                                % numéro de la seconde de chaque pic
garder = false(size(k));

for b = 1:numel(bandes) - 1
    dans_bande = f(k) >= bandes(b) & f(k) < bandes(b+1);
    for s = unique(seconde(dans_bande))'
        idx = find(dans_bande & seconde == s);        % pics de cette bande et de cette seconde
        [~, ordre] = sort(force(idx), 'descend');     % du plus fort au plus faible
        garder(idx(ordre(1:min(pics_par_bande_s, numel(idx))))) = true;
    end
end

k = k(garder);
m = m(garder);
end