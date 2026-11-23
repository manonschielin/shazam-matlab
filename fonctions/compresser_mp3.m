function [y, Fe] = compresser_mp3(extrait, Fe_orig, debit_kbps)
% COMPRESSER_MP3 Code un extrait en MP3 puis le prétraite (mono, 8 kHz).
%   [y, Fe] = compresser_mp3(extrait, Fe_orig, debit_kbps)
%   extrait : signal à la fréquence d'origine Fe_orig (avant le passage à 8 kHz),
%   codé en MP3 par ffmpeg au débit voulu (kbit/s), décodé par ffmpeg (ce qui
%   retire le retard de l'encodeur), puis relu par pretraitement.
%   debit_kbps = Inf : même chemin mais sans compression (référence).

extrait = extrait / max(1, max(abs(extrait(:))));    % évite l'écrêtage à l'écriture du .wav

fichier_wav = [tempname '.wav'];                      % fichiers temporaires
audiowrite(fichier_wav, extrait, Fe_orig);

if isinf(debit_kbps)
    [y, Fe] = pretraitement(fichier_wav);             % référence sans compression
else
    fichier_mp3 = [tempname '.mp3'];
    fichier_decode = [tempname '.wav'];
    % Sous 32 kbit/s, la norme MP3 impose une fréquence d'échantillonnage plus basse
    if debit_kbps >= 32
        option_fe = '';
    elseif debit_kbps >= 16
        option_fe = '-ar 22050';                      % MPEG-2 : 22,05 kHz
    else
        option_fe = '-ar 11025';                      % MPEG-2.5 : 11,025 kHz
    end
    commande = sprintf('ffmpeg -y -loglevel error -i "%s" -codec:a libmp3lame -b:a %dk %s "%s"', ...
        fichier_wav, debit_kbps, option_fe, fichier_mp3);    commande_decodage = sprintf('ffmpeg -y -loglevel error -i "%s" "%s"', fichier_mp3, fichier_decode);
    if system(commande) ~= 0 || system(commande_decodage) ~= 0
        error('compresser_mp3 : ffmpeg a échoué');
    end
    [y, Fe] = pretraitement(fichier_decode);          % décodé par ffmpeg : retard de l'encodeur retiré
    delete(fichier_mp3, fichier_decode)
end
delete(fichier_wav)
end