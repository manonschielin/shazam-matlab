function [id, nom] = decider(scores, index, s_thr)
% DECIDER Réponse du système : le meilleur morceau, ou « inconnu ».
%   [id, nom] = decider(scores, index) utilise le seuil s_thr = 30.
%   id = 0 et nom = 'inconnu' si le meilleur score est sous le seuil.

if nargin < 3, s_thr = 30; end

[score_max, id] = max(scores);                        % le meilleur morceau
if score_max < s_thr
    id = 0;                                           % pas assez de clés alignées
    nom = 'inconnu';
else
    nom = index.noms{id};
end
end