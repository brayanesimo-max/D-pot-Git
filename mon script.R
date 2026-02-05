read.csv2("data_tidy/joueurs.csv") -> joueur
head(joueur)
dim(joueur)
library(tidyr)
joueur
library(tidyverse)

# 1. On supprime la première ligne (celle avec 'but', 'pasD'...)
joueur_propre <- joueur[-1, ] 

# 2. On convertit les colonnes en nombres pour pouvoir faire des stats
joueur_propre$Buts.marqués <- as.numeric(joueur_propre$Buts.marqués)
joueur_propre$Passes.décisives <- as.numeric(joueur_propre$Passes.décisives)
joueur_propre$Minutes.jouées <- as.numeric(joueur_propre$Minutes.jouées)

# 3. Maintenant, ton pivot va enfin marcher !
joueurs_wide <- joueur_propre %>%
  pivot_wider(names_from = X, values_from = Buts.marqués)

# On vérifie le résultat
View(joueurs_wide)

library(ggplot2)

# Graphique : Buts marqués par rapport aux Minutes jouées
ggplot(joueur_propre, aes(x = Minutes.jouées, y = Buts.marqués)) +
  geom_point(color = "darkblue", size = 3) +
  geom_text(aes(label = X), vjust = -1, size = 3) + # Affiche le nom des joueurs
  labs(title = "Efficacité des joueurs", x = "Temps de jeu", y = "Buts") +
  theme_minimal()
library(ggplot2)
library(ggrepel) # <--- C'est cette ligne qui débloque la fonction !

ggplot(joueur_propre, aes(x = Tirs.cadrés, y = Buts.marqués)) +
  geom_point(aes(color = Buts.marqués, size = Minutes.jouées)) +
  geom_text_repel(aes(label = X), size = 3, segment.color = "grey50") + 
  theme_minimal()
# Si tu n'as pas ggrepel, installe-le une fois avec : install.packages("ggrepel")
library(ggplot2)
library(ggrepel) 

ggplot(joueur_propre, aes(x = Tirs.cadrés, y = Buts.marqués)) +
  # 1. On ajoute une zone d'ombre pour la tendance (plus joli)
  geom_smooth(method = "lm", color = "grey70", fill = "grey90", alpha = 0.5) +
  
  # 2. On colorise les points selon l'efficacité (Buts)
  geom_point(aes(color = Buts.marqués, size = Minutes.jouées), alpha = 0.8) +
  
  # 3. On utilise une échelle de couleur dégradée (du bleu au rouge)
  scale_color_gradient(low = "blue", high = "red") +
  
  # 4. On ajoute les noms proprement (ils ne se chevauchent plus)
  geom_text_repel(aes(label = X), size = 3, segment.color = 'grey50') +
  
  # 5. On personnalise les titres et les axes
  labs(
    title = "Efficacité Offensive des Joueurs",
    subtitle = "Analyse du rapport Tirs Cadrés / Buts Marqués",
    x = "Nombre de tirs cadrés (Précision)",
    y = "Nombre de buts (Finition)",
    color = "Nombre de Buts",
    size = "Temps de jeu (min)",
    caption = "Source : Données footballistiques - ISARA"
  ) +
  
  # 6. Un thème très épuré et moderne
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "right"
  )

library(ggplot2)
library(tidyverse)

# On s'assure que les colonnes sont bien numériques avant le graph
joueur_propre$Buts.marqués <- as.numeric(joueur_propre$Buts.marqués)
joueur_propre$Tirs.cadrés <- as.numeric(joueur_propre$Tirs.cadrés)

joueur_propre %>% 
  drop_na(Buts.marqués, Tirs.cadrés) %>% # Nettoyage des données vides
  ggplot() + 
  aes(
    x = Tirs.cadrés, 
    y = Buts.marqués, 
    color = Buts.marqués, # Couleur selon le succès
    fill = Buts.marqués
  ) + 
  
  # Couches (Layers)
  geom_point(size = 1.5) +  
  geom_smooth(method = "lm", size = 0.8, alpha = 0.2) + 
  geom_density2d(size = 0.3, alpha = 0.5) + 
  
  # Échelles (Scales)
  # On adapte les limites à tes données de foot (0 à 30 buts environ)
  scale_color_viridis_c(option = "plasma") + 
  scale_fill_viridis_c(option = "plasma") + 
  scale_x_continuous(limits = c(0, 110)) + # Max tirs environ 109 pour Balotelli
  scale_y_continuous(limits = c(0, 30)) +  # Max buts environ 28 pour Cavani
  
  # Étiquettes et Titres (Options)
  xlab("Précision (Tirs cadrés)") + 
  ylab("Finition (Buts marqués)") + 
  ggtitle("Analyse de la Performance Offensive", subtitle = "Adaptation du modèle Penguins") + 
  
  # Thème et Coordonnées
  coord_cartesian() + 
  theme_bw() +
  theme(aspect.ratio = 1/1.5)
