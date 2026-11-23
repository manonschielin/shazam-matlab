function index = construire_index(fichiers, dk, dm, dfc)
% CONSTRUIRE_INDEX Index inversé des empreintes d'une liste de morceaux.
%   index = construire_index({'A.mp3', 'B.mp3'}) renvoie une structure :
%   index.cles    : les clés différentes, triées
%   index.debut   : pour chaque clé, la ligne où commence son bloc
%   index.nombre  : pour chaque clé, le nombre de lignes de son bloc
%   index.id      : pour chaque ligne, le numéro du morceau
%   index.instant : pour chaque ligne, l'instant (trame) de l'ancre
%   index.noms    : les noms des fichiers
%   index = construire_index(fichiers, dk, dm, dfc) : réglages choisis.

if nargin < 2, dk = []; end                           % [] : valeur par défaut
if nargin < 3, dm = []; end
if nargin < 4, dfc = []; end

toutes_cles = [];
tous_id = [];
tous_instants = [];

for i = 1:numel(fichiers)
    [x, Fe] = pretraitement(fichiers{i});
    [cles, m1] = extraction(x, Fe, dk, dm, dfc);      % même chaîne que pour les extraits
    toutes_cles = [toutes_cles; cles];
    tous_id = [tous_id; i * ones(numel(cles), 1)];    % numéro du morceau, répété
    tous_instants = [tous_instants; m1];
end

[toutes_cles, ordre] = sort(toutes_cles);             % une même clé = lignes consécutives
index.id = tous_id(ordre);
index.instant = tous_instants(ordre);

[index.cles, index.debut] = unique(toutes_cles, 'first');   % début du bloc de chaque clé
index.nombre = diff([index.debut; numel(toutes_cles) + 1]); % taille de chaque bloc
index.noms = fichiers;
index.dk = dk;                                        % réglages utilisés (pour s'en souvenir)
index.dm = dm;
index.dfc = dfc;
end