% INIT_PROJET À lancer une fois après avoir ouvert MATLAB.
%   Rend les fonctions et les tests accessibles depuis n'importe quel dossier,
%   puis se place dans le dossier projet (les chemins 'audio/...' et
%   'resultats/...' des tests partent d'ici).

racine = fileparts(mfilename('fullpath'));            % le dossier projet
addpath(fullfile(racine, 'fonctions'), fullfile(racine, 'tests'), fullfile(racine, 'outils'));
cd(racine)
