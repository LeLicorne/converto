/**
 * Google Form « Converto, test en avant-première ».
 * Deux façons de l'utiliser (détails dans README.md) :
 *   - fillThisForm()       : à coller dans l'éditeur de script d'un formulaire EXISTANT ; remplace son contenu.
 *   - createConvertoForm() : à coller sur script.google.com ; crée un nouveau formulaire.
 */

// ---- À VÉRIFIER AVANT D'EXÉCUTER ------------------------------------------------------------
// Lien du groupe Google des testeurs (page du groupe, visible par tout le monde).
const GROUP_URL = 'https://groups.google.com/g/converto-tester';
// Lien de participation au test fermé, copié depuis la Play Console (onglet « Testeurs »).
// Il ne fonctionne qu'une fois la version approuvée par Google.
const TEST_URL = 'https://play.google.com/apps/testing/com.baptistelore.converto';
// Créer aussi un tableur qui reçoit les réponses ?
const CREATE_SHEET = true;
// ----------------------------------------------------------------------------------------------

/** Crée un nouveau formulaire complet. */
function createConvertoForm() {
  const form = FormApp.create('Converto : rejoins le test en avant-première');
  buildForm(form);
  logLinks(form);
}

/**
 * Remplit le formulaire auquel ce script est rattaché (menu ⋮ du formulaire > Éditeur de scripts).
 * ATTENTION : supprime d'abord toutes les questions déjà présentes dans ce formulaire.
 */
function fillThisForm() {
  const form = FormApp.getActiveForm();
  form.getItems().forEach((item) => form.deleteItem(item));
  buildForm(form);
  logLinks(form);
}

function buildForm(form) {
  form.setTitle('Converto : rejoins le test en avant-première');
  try {
    // Pas de connexion obligatoire pour répondre (sinon les visiteurs voient une erreur 401).
    form.setRequireLogin(false);
  } catch (error) {
    Logger.log('setRequireLogin ignoré : ' + error);
  }
  form
    .setDescription(
      'Converto convertit tes images, PDF, documents, audio et vidéos directement sur ton téléphone. ' +
        'Gratuit, sans pub, sans compte, hors ligne : tes fichiers ne quittent jamais ton appareil.\n\n' +
        'Réponds à quelques questions (1 minute) pour rejoindre le test.'
    )
    .setCollectEmail(false)
    .setLimitOneResponsePerUser(false)
    .setAllowResponseEdits(false)
    .setShowLinkToRespondAgain(false)
    .setProgressBar(true)
    .setConfirmationMessage(
      'Merci pour ta réponse !\n\n' +
        'Android : rejoins le groupe ' + GROUP_URL + ', attends quelques minutes, puis ouvre ' + TEST_URL +
        ' (avec le même compte Google), clique sur « Devenir testeur » et installe Converto.\n\n' +
        'iPhone : Converto n\'est pas encore sur l\'App Store, ta réponse nous aide à décider de sa sortie.'
    );

  const device = form
    .addMultipleChoiceItem()
    .setTitle('Tu es sur quel téléphone ?')
    .setRequired(true);

  // ---- Section iPhone (iOS) ----
  const iosPage = form
    .addPageBreakItem()
    .setTitle('Sur iPhone')
    .setHelpText('Converto n\'est pas encore disponible sur l\'App Store. Dis-nous si ça t\'intéresse.');
  addCommonQuestions(form, 'l\'App Store');
  form
    .addTextItem()
    .setTitle('Si tu veux être prévenu(e) de la sortie sur l\'App Store, laisse ton e-mail (facultatif)')
    .setHelpText('Utilisé uniquement pour te prévenir de la sortie, puis supprimé. Laisse vide si tu préfères.')
    .setValidation(FormApp.createTextValidation().requireTextIsEmail().build());

  // ---- Section Android ----
  const androidPage = form
    .addPageBreakItem()
    .setTitle('Sur Android')
    .setHelpText('Converto est en test sur Google Play : tu peux l\'essayer avant tout le monde.');
  // Après la section iPhone, le formulaire s'envoie directement (sans passer par la section Android).
  androidPage.setGoToPage(FormApp.PageNavigationType.SUBMIT);
  addCommonQuestions(form, 'Google Play');
  form
    .addSectionHeaderItem()
    .setTitle('Pour essayer Converto maintenant')
    .setHelpText(
      '1. Rejoins le groupe des testeurs : ' + GROUP_URL + '\n' +
        '2. Attends quelques minutes que ton accès soit pris en compte.\n' +
        '3. Ouvre ce lien avec le même compte Google, clique sur « Devenir testeur », puis installe l\'appli : ' + TEST_URL + '\n\n' +
        'Pense à valider l\'envoi du formulaire en bas de page.'
    );

  device.setChoices([
    device.createChoice('Android', androidPage),
    device.createChoice('iPhone (iOS)', iosPage),
  ]);

  if (CREATE_SHEET && !hasDestination(form)) {
    const sheet = SpreadsheetApp.create('Converto : réponses au formulaire');
    form.setDestination(FormApp.DestinationType.SPREADSHEET, sheet.getId());
    Logger.log('Tableur des réponses : ' + sheet.getUrl());
  }
}

/** Vrai si le formulaire envoie déjà ses réponses vers un tableur. */
function hasDestination(form) {
  try {
    return Boolean(form.getDestinationId());
  } catch (error) {
    return false;
  }
}

function logLinks(form) {
  Logger.log('Modifier le formulaire : ' + form.getEditUrl());
  Logger.log('Lien à partager (bio Instagram) : ' + form.getPublishedUrl());
}

/** Questions communes aux deux plateformes. */
function addCommonQuestions(form, storeName) {
  form
    .addCheckboxItem()
    .setTitle('À quoi te servirait Converto ?')
    .setChoiceValues([
      'Convertir des photos (HEIC, JPG, PNG, WebP)',
      'Passer des PDF en images ou en texte, fusionner des PDF',
      'Convertir de l\'audio ou de la vidéo',
      'Documents, tableurs (CSV, Excel, Word)',
    ])
    .showOtherOption(true)
    .setRequired(true);

  form
    .addParagraphTextItem()
    .setTitle('Pourquoi tu voudrais cette appli ?')
    .setHelpText('Un exemple concret nous aide beaucoup : quel fichier, dans quelle situation ?')
    .setRequired(true);

  form
    .addMultipleChoiceItem()
    .setTitle('Si Converto est disponible sur ' + storeName + ', tu la télécharges ?')
    .setChoiceValues(['Oui, sûrement', 'Peut-être', 'Non'])
    .setRequired(true);
}
