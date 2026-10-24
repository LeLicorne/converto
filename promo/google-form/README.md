# Formulaire « test en avant-première »

> Alternative : le site héberge maintenant son propre formulaire derrière un code (`web/test.html`, voir `web/README.md`). Il remplace ce Google Form si tu préfères garder les données sur ton propre projet Firestore.

Parcours prévu : ta story Instagram dit « go bio » → le lien en bio ouvre ce Google Form → selon son téléphone, la personne répond (iPhone ou Android) → les Android reçoivent les étapes pour tester.

## Remplir ton formulaire existant (le plus simple)
Ton formulaire existe déjà (celui dont tu as copié le code « Intégrer »). Son lien public est :

`https://docs.google.com/forms/d/e/1FAIpQLSevCDPyGRwzyO2Ovde8NNLobaOdLV1svQI0eEqX8m20Z33jQg/viewform`

C'est ce lien, **sans** `?embedded=true`, que tu mettras en bio Instagram. Le code `<iframe>` de la section « Intégrer du HTML » sert seulement à afficher un formulaire à l'intérieur d'une page web : tu n'en as pas besoin pour Instagram.

Pour y mettre toutes les questions :
1. Ouvre ton formulaire en **modification** (pas le lien public), puis le menu **⋮** en haut à droite, puis **Éditeur de scripts** (ou **Apps Script**).
2. Efface le code d'exemple et colle tout le contenu de `create-form.gs`.
3. Vérifie `GROUP_URL` et `TEST_URL` en haut du fichier (voir plus bas).
4. Choisis la fonction **`fillThisForm`** dans la barre du haut, clique sur **Exécuter**, puis autorise le script.
5. Reviens sur le formulaire et rafraîchis la page : les questions et les sections Android / iPhone sont là.

⚠️ `fillThisForm` **supprime d'abord toutes les questions déjà présentes** dans ce formulaire, puis les remplace par celles de Converto. Si tu y avais mis du contenu à garder, sauvegarde-le avant.

Pour créer à la place un **nouveau** formulaire, colle le script sur [script.google.com](https://script.google.com) et exécute `createConvertoForm` ; le journal d'exécution affiche les liens.

### Liens à vérifier dans le script
- `GROUP_URL` : la page de ton groupe Google (`https://groups.google.com/g/converto-tester` si le groupe s'appelle ainsi).
- `TEST_URL` : le lien de participation de la Play Console (onglet **Testeurs** de la piste de test fermé, rubrique « Comment les testeurs rejoignent votre test »). Garde celui que donne la Console.

### Si le lien public affiche une erreur « connexion requise » (401)
Les visiteurs doivent pouvoir répondre sans se connecter. Le script désactive la restriction à une organisation, la collecte d'e-mail et la limite d'une réponse. Si l'erreur persiste, vérifie dans le formulaire, onglet **Paramètres** → **Réponses** : « Restreindre à … » doit être **désactivé** (c'est le réglage par défaut des comptes Google Workspace), ainsi que « Collecter les adresses e-mail » et « Limiter à 1 réponse ». Teste ensuite le lien dans une fenêtre de navigation privée.

## Ce que le formulaire contient
**Page 1.** Présentation de Converto et une question : *Tu es sur quel téléphone ?* (Android / iPhone).

**Si iPhone :**
1. À quoi te servirait Converto ? (cases à cocher, plus « Autre »)
2. Pourquoi tu voudrais cette appli ? (texte libre)
3. Si Converto est disponible sur l'App Store, tu la télécharges ? (Oui, sûrement / Peut-être / Non)
4. E-mail facultatif pour être prévenu de la sortie sur l'App Store. Supprime cette question dans le formulaire si tu ne veux collecter aucune adresse.

Puis le formulaire s'envoie directement.

**Si Android :** les mêmes trois questions (avec « Google Play »), puis un bloc d'instructions :
1. rejoindre le groupe (lien) ;
2. attendre quelques minutes ;
3. ouvrir le lien de test avec le même compte Google, cliquer sur « Devenir testeur », installer l'appli.

Le message affiché après l'envoi répète ces étapes pour Android et indique aux utilisateurs d'iPhone que l'appli n'est pas encore sur l'App Store (Google Forms ne permet qu'un seul message final pour tout le monde).

## Avant de poster la story
- **Attends que Google ait approuvé la version de test** (Console : « Vue d'ensemble de la publication »). Avant, le lien de test ne marche pas et les gens ne pourront pas installer.
- Vérifie que le groupe est ouvert à tous (« Tout le monde peut rejoindre » ou « demander à rejoindre ») et que son adresse est bien dans la liste des testeurs de la piste.
- Teste le formulaire toi-même, une fois en choisissant Android et une fois en choisissant iPhone (bouton **œil** « Aperçu » du formulaire).
- Ouvre le lien public dans une fenêtre de navigation privée pour vérifier que n'importe qui peut répondre sans se connecter.

## Textes prêts à coller
**Dans la story / le reel (texte à l'écran) :**
> Converto : convertis tes fichiers sans rien envoyer en ligne.
> Gratuit. Sans pub. Sans compte.
> Teste-la en avant-première, go bio.

**Légende :**
> Une appli qui convertit tes photos, PDF, audio et vidéos directement sur ton téléphone. Rien ne quitte ton appareil. Je cherche des testeurs : le lien est en bio, ça prend 1 minute.

## Vie privée
Le formulaire est anonyme (aucune connexion, aucune adresse demandée automatiquement). Seule l'adresse e-mail facultative de la section iPhone est une donnée personnelle : précise-la à qui te le demande, utilise-la uniquement pour prévenir de la sortie, puis supprime-la du tableur. Les données restent hébergées par Google comme pour tout Google Form.
