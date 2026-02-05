import os
import requests
from moviepy import ImageClip, concatenate_videoclips, AudioFileClip

# ==========================================
# CONFIGURATION DE L'ENVIRONNEMENT
# ==========================================
# Localisation du script pour garantir la creation des dossiers au bon endroit
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# Definition des repertoires de travail
dossier_images = os.path.join(script_dir, "images_picsum")
dossier_audio = os.path.join(script_dir, "Audio_proj")
dossier_diapo = os.path.join(script_dir, "Diapo_proj")

# Creation des dossiers si inexistants
for dossier in [dossier_images, dossier_audio, dossier_diapo]:
    if not os.path.exists(dossier):
        os.makedirs(dossier)

# ==========================================
# PHASE 1 : ACQUISITION DES RESSOURCES
# ==========================================
try:
    nb_images_input = input("Combien voulez-vous d'images ? ")
    nb_images = int(nb_images_input)
    
    for i in range(1, nb_images + 1):
        url = f"https://picsum.photos/800/600?random={i}"
        try:
            response = requests.get(url, stream=True)
            if response.status_code == 200:
                path_image = os.path.join(dossier_images, f"image_{i}.jpg")
                with open(path_image, 'wb') as fichier:
                    fichier.write(response.content)
                print(f"Statut : Image {i} enregistree.")
        except Exception as e:
            print(f"Erreur lors du telechargement de l'image {i} : {e}")
except ValueError:
    print("Erreur : Veuillez entrer un nombre entier valide.")
    exit()

# ==========================================
# PHASE 2 : TRAITEMENT ET MONTAGE VIDEO
# ==========================================
try:
    nb_secondes_input = input("Combien voulez-vous que l'image dure (en secondes) ? ")
    duree_image = int(nb_secondes_input)
    
    clips = []
    for i in range(1, nb_images + 1):
        chemin_image = os.path.join(dossier_images, f"image_{i}.jpg")
        if os.path.exists(chemin_image):
            # Utilisation de with_duration pour la compatibilite MoviePy 2.x
            clip = ImageClip(chemin_image).with_duration(duree_image)
            clips.append(clip)

    if clips:
        # Assemblage des sequences
        diaporama = concatenate_videoclips(clips, method="compose")
        
        # Gestion de la piste audio
        # Remarque : Le fichier doit se nommer "MG - TD.mp3" dans le dossier "Audio_proj"
        chemin_musique = os.path.join(dossier_audio, "MG - TD.mp3")
        
        if os.path.exists(chemin_musique):
            print("Statut : Integration de la piste audio en cours...")
            musique = AudioFileClip(chemin_musique)
            
            # Synchronisation de l'audio sur la duree totale du diaporama
            musique = musique.with_duration(diaporama.duration)
            diaporama = diaporama.with_audio(musique)
        else:
            print(f"Alerte : Fichier audio introuvable dans {dossier_audio}. Video muette.")

        # Exportation finale du projet
        path_sortie = os.path.join(dossier_diapo, "diaporama.mp4")
        diaporama.write_videofile(
            path_sortie, 
            fps=24, 
            codec="libx264", 
            audio_codec="aac"
        )
        print(f"\nSucces : Le projet a ete genere dans {path_sortie}")
    else:
        print("Erreur : Aucun clip n'a pu etre genere.")

except Exception as e:
    print(f"Erreur lors du montage : {e}")