PROJET TRAITEMENT DU SIGNAL - RECONNAISSANCE MUSICALE PAR EMPREINTES
(méthode de Wang, 2003 : constellation de pics, paires de pics, index inversé)
Groupe : QUÉRO Thomas, SCHIELIN Manon

=== Lancer la démonstration ===
1. Ouvrir MATLAB dans le dossier projet et taper : init_projet
2. Taper : main
3. Jouer un morceau près du micro (téléphone ou enceinte), appuyer sur Entrée :
   le système écoute 10 s et affiche le morceau reconnu, sa position,
   le spectrogramme avec les pics, les scores et l'histogramme des décalages.
   L'index de démo contient 104 morceaux FMA + 4 morceaux connus
   (Frank Ocean - Pyramids, Radiohead - Creep, Tame Impala - Dracula,
   Kanye West - Roses).
Attention : sous Windows, désactiver les « Améliorations audio » du micro
(Paramètres > Système > Son > Microphone), sinon la suppression d'écho
efface la musique.

=== Prérequis ===
- MATLAB avec Signal Processing Toolbox et Image Processing Toolbox
- ffmpeg (seulement pour les tests de compression MP3) : winget install Gyan.FFmpeg
- Base FMA (fma_small) pour les évaluations, à placer à côté du dossier projet :
    traitement du signal/projet/              (ce dossier)
    traitement du signal/fma/fma_small/       (https://os.unil.cloud.switch.ch/fma/fma_small.zip)
    traitement du signal/fma/fma_small_genres.csv
  La démonstration (main) n'a pas besoin de la base FMA : elle utilise
  resultats/index_demo.mat.

=== Organisation ===
init_projet.m   ajoute les dossiers au chemin de MATLAB et se place dans projet
main.m          démonstration en direct
fonctions/      une fonction par étape de la chaîne :
  pretraitement      lecture, mono, ré-échantillonnage à 8 kHz
  spectrogramme      TFD à court terme (Hann, N = 1024, pas 512), en dB
  detection_pics     maxima locaux (voisinage 11 x 7) + seuil local
  selection_pics     5 pics par bande de fréquence et par seconde
  empreintes         clés par paires de pics (F = 10, dfc = 2)
  extraction         enchaîne les 4 étapes précédentes
  construire_index   index inversé (clés triées)
  rechercher         histogramme des décalages, score de chaque morceau
  decider            meilleur morceau ou « inconnu » (seuil)
  ajouter_bruit, ajouter_bruit_reel, compresser_mp3, filtrer_telephone,
  reverberer         dégradations simulées
tests/          un script de test par fonction, plus les tests du micro
outils/         scripts d'évaluation (un par expérience du rapport) :
  choisir_morceaux, construire_index_base, construire_index_demo,
  evaluer, evaluer_bruit, courbe_tbd_tfd, seuils_adaptes, evaluer_mp3,
  evaluer_filtrage, evaluer_reverberation, evaluer_bruit_reel,
  question3_voisinage, comparer_voisinages, question4_dfc,
  passage_echelle, jouer_et_enregistrer, campagne_telephone,
  rechercher_ancien (ancienne version, pour comparaison)
audio/          morceaux connus, bruit de brouhaha, enregistrements au micro
resultats/      listes de morceaux, index, résultats (.mat) et figures (.png)

=== Paramètres retenus ===
Fe = 8 kHz ; fenêtre de Hann de 1024 échantillons (128 ms), pas de 512 (64 ms) ;
voisinage des maxima 11 x 7 ; marge 10 dB ; 5 pics par bande et par seconde ;
F = 10 cibles, dm de 1 à 24 trames, |dk| <= 60 canaux, dfc = 2 ;
seuil de décision 18 / 21 / 26 pour des extraits de 3 / 5 / 10 s.