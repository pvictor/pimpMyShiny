# Pimp My Shiny !

Bienvenue sur le repo Pimp My Shiny !

Ici vous retrouverez les slides de notre présentation au [meetup R Addicts du 12/07/2016](http://www.meetup.com/fr-FR/rparis/events/232196288/) ainsi que le code des applications que nous avons présenté.

## basic
L'application shiny *basic* est disponible ici :  https://dreamrs-vic.shinyapps.io/basicShiny/

Le code se trouve dans le répertoire "basic" de ce repo (Nous n'avons pas inclus les données, vous pouvez nous contacter pour les obtenir).


## pimp
L'application shiny *pimpée* est disponible ici : TODO



<br><br>

## Autres trucs

### Bouton switch
Pour utiliser bouton on/off vu dans la version pimpée, vous pouvez regarder :

```{r}
shiny::runGitHub(repo = "pimpMyShiny", username = "pvictor", subdir = "bootstrap_switch")
```

### API Meetup
Le script que nous avons utilisé pour récupérer la liste des R Addicts est disponible ici : `R_scripts/get_raddicts.R`


### Cartes
Pour la carte du monde, nous avons utilisé l'exemple de Kristoffer Magnusson, disponible [ici](http://rpsychologist.com/working-with-shapefiles-projections-and-world-maps-in-ggplot) 

Pour la carte de France, nous avons utilisé les contours des départements OpenStreetMap disponibles sur [data.gouv](https://www.data.gouv.fr/fr/datasets/contours-des-departements-francais-issus-d-openstreetmap/) 

<br>
<br>
Pimpez-bien !

Fanny et Victor


Pour nous joindre :

* sur twitter : [@meyer_fanny](https://twitter.com/meyer_fanny) et [@victpir](https://twitter.com/Victpir)
* par mail : fannymeyer2@gmail.com et perrier.victor@gmail.com


