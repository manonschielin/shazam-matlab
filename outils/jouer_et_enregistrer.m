function [fichier, debut_s] = jouer_et_enregistrer(i, distance_cm, duree)
% JOUER_ET_ENREGISTRER Joue un extrait du morceau i de la base sur la sortie
%   audio par défaut et l'enregistre en même temps avec le micro (44,1 kHz).
%   [fichier, debut_s] = jouer_et_enregistrer(i, distance_cm, duree)
%   fichier : chemin du .wav enregistré ; debut_s : début de l'extrait dans le morceau.
%   L'enregistrement commence 0,5 s avant la lecture et finit 0,5 s après.

if nargin < 3, duree = 10; end

base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
[son, Fe_orig] = audioread(base.chemin(i));
son = mean(son, 2);                                   % mono

debut_s = floor(10 * rand * (length(son)/Fe_orig - duree)) / 10;   % au dixième de seconde
extrait = son(round(debut_s*Fe_orig) + 1 : round((debut_s + duree)*Fe_orig));
extrait = 0.9 * extrait / max(abs(extrait));          % même niveau de lecture pour tous

lecteur = audioplayer(extrait, Fe_orig);
rec = audiorecorder(44100, 16, 1);
record(rec);                                          % l'enregistrement démarre...
pause(0.5);
playblocking(lecteur);                                % ... la lecture, jusqu'au bout
pause(0.5);
stop(rec);
y = getaudiodata(rec);

fichier = sprintf('audio/enregistrements/m%03d_d%03dcm_t%03d.wav', i, distance_cm, round(10*debut_s));
audiowrite(fichier, y, 44100);
fprintf('Enregistré : %s  (crête %.2f)\n', fichier, max(abs(y)))
end