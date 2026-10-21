# Réponses aux questionnaires de confidentialité

Ces réponses décrivent le comportement réel de l'application (aucune donnée collectée, aucun SDK tiers).
Vérifiez-les de nouveau si une dépendance est ajoutée ou si une permission change (commandes de contrôle dans `RELEASE_CHECKLIST.md`, section 5).

## Apple — App Store Connect › App Privacy

- **Collectez-vous des données de cette app ?** Non → « Data Not Collected ».
- **Suivi (tracking) ?** Non. Aucune demande ATT, pas de `NSUserTrackingUsageDescription`.
- **Domaines de suivi :** aucun (`PrivacyInfo.xcprivacy` : `NSPrivacyTracking = false`, listes vides).
- **Chiffrement à l'export :** `ITSAppUsesNonExemptEncryption = false` (aucun chiffrement propre à l'app ; la lib FFmpeg n'est pas utilisée pour chiffrer).
- **Classification d'âge :** 4+ (aucun contenu généré par les utilisateurs, aucun accès web).
- **URL de confidentialité :** page publique `https://<DOMAIN>/confidentialite.html` (dossier `web/`, voir checklist).
- **Permissions demandées :** Photothèque (lecture, pour choisir photos/vidéos) et ajout à la photothèque (écriture, uniquement si l'utilisateur choisit « Enregistrer dans Photos »). Textes localisés dans `ios/Runner/<langue>.lproj/InfoPlist.strings`.
- **Required Reason APIs déclarées** (`ios/Runner/PrivacyInfo.xcprivacy`) : FileTimestamp (C617.1, 3B52.1), UserDefaults (CA92.1), DiskSpace (E174.1, 85F4.1), SystemBootTime (35F9.1). À recouper avec le « Privacy Report » d'Xcode (Product › Archive › Generate Privacy Report) avant soumission.

## Google Play — Data safety

- **Collecte ou partage de données :** Non.
- **Données chiffrées en transit :** sans objet (aucune transmission).
- **Possibilité de demander la suppression des données :** sans objet (aucune donnée conservée côté éditeur).
- **Permissions Android :** aucune permission réseau (`INTERNET` et `ACCESS_NETWORK_STATE` sont retirées du manifeste fusionné), aucun accès aux médias (`READ_EXTERNAL_STORAGE` et `READ_MEDIA_*` retirées). Seule `WRITE_EXTERNAL_STORAGE`, limitée à Android 9 et moins, permet « Enregistrer dans Photos » sur ces anciennes versions. Accès aux fichiers via le sélecteur système (Storage Access Framework / Photo Picker).
- **Public cible :** tout public, non destinée aux enfants (pas d'inscription au programme « Familles »).
- **Annonces :** « Cette application ne contient pas de publicités ».
- **Achats intégrés :** aucun.
- **Accessibilité :** déclaration disponible dans l'app (À propos) et en ligne (`https://<DOMAIN>/accessibilite.html`).
- **Niveau d'API cible :** `targetSdk` suit celui de Flutter ; le mettre à jour en mettant à jour Flutter (exigence annuelle de Google Play).
- **Statut professionnel (« trader ») :** à déclarer dans la Console ; si « professionnel », l'adresse et le téléphone sont affichés publiquement sur la fiche.
