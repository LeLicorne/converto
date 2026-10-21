// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Converto';

  @override
  String get pickTitle => 'Escolher um arquivo';

  @override
  String get pickSubtitle =>
      'Imagem, PDF, documento, áudio ou vídeo. Tudo fica no seu dispositivo.';

  @override
  String get pickMedia => 'Fotos e vídeos';

  @override
  String get pickMultipleHint =>
      'Você pode selecionar vários arquivos para combiná-los.';

  @override
  String get loading => 'Lendo o arquivo…';

  @override
  String get changeFile => 'Alterar';

  @override
  String get changeFileSemantics => 'Escolher outro arquivo';

  @override
  String filesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '1 arquivo',
    );
    return '$_temp0';
  }

  @override
  String detectedFormat(String format) {
    return 'Detectado: $format';
  }

  @override
  String get unknownFormat => 'Formato não reconhecido';

  @override
  String get convertTo => 'Converter para';

  @override
  String get noTargets => 'Nenhuma conversão disponível para este arquivo.';

  @override
  String get mixedFiles =>
      'Esses arquivos são de tipos diferentes e não podem ser convertidos juntos.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
    );
    return '$_temp0';
  }

  @override
  String get categoryImage => 'Imagens';

  @override
  String get categoryDocument => 'Documentos';

  @override
  String get categoryData => 'Dados';

  @override
  String get categoryArchive => 'Arquivos compactados';

  @override
  String get categoryAudio => 'Áudio';

  @override
  String get categoryVideo => 'Vídeo';

  @override
  String get extractArchive => 'Extrair arquivos';

  @override
  String get mergePdf => 'Mesclar / editar PDF';

  @override
  String get createZip => 'Arquivo ZIP';

  @override
  String get optionsTitle => 'Opções';

  @override
  String convertButton(String format) {
    return 'Converter para $format';
  }

  @override
  String get optQuality => 'Qualidade';

  @override
  String get optMaxSize => 'Tamanho máximo';

  @override
  String get optStripMetadata => 'Remover metadados (local, câmera…)';

  @override
  String get optPages => 'Páginas';

  @override
  String get optPagesHint => 'Todas as páginas, ou por exemplo 1-3, 5';

  @override
  String optPagesInvalid(int count) {
    return 'Seleção de páginas inválida (1 a $count).';
  }

  @override
  String get optLayout => 'Resultado';

  @override
  String get layoutSeparate => 'Uma imagem por página';

  @override
  String get layoutSingle => 'Uma única imagem contínua';

  @override
  String get optDpi => 'Resolução (DPI)';

  @override
  String get optPageSize => 'Tamanho da página';

  @override
  String get pageSizeFit => 'Ajustado à imagem';

  @override
  String get optGrouping => 'Resultado';

  @override
  String get groupingSingle => 'Um único PDF com todas as imagens';

  @override
  String get groupingPerImage => 'Um PDF por imagem';

  @override
  String get optOptimize => 'Otimizar o tamanho do arquivo';

  @override
  String get optFontSize => 'Tamanho do texto';

  @override
  String get optDelimiter => 'Separador';

  @override
  String get optOutputDelimiter => 'Separador';

  @override
  String get optFirstRowHeader =>
      'A primeira linha contém os nomes das colunas';

  @override
  String get optPretty => 'Formatação legível';

  @override
  String get optPageSeparators => 'Adicionar separadores de página';

  @override
  String get optRotation => 'Rotação';

  @override
  String get optBitrate => 'Taxa de bits';

  @override
  String get optSampleRate => 'Taxa de amostragem';

  @override
  String get optChannels => 'Canais';

  @override
  String get optKeepMetadata => 'Manter tags e capa';

  @override
  String get optResolution => 'Resolução';

  @override
  String get optFps => 'Quadros por segundo';

  @override
  String get optCodec => 'Codec';

  @override
  String get optKeepAudio => 'Manter a faixa de áudio';

  @override
  String get optGifWidth => 'Largura';

  @override
  String get optGifFps => 'Quadros por segundo';

  @override
  String get optGifDuration => 'Duração máxima';

  @override
  String get choiceOriginal => 'Original';

  @override
  String get choiceFull => 'Vídeo inteiro';

  @override
  String get choiceMono => 'Mono';

  @override
  String get choiceStereo => 'Estéreo';

  @override
  String get choiceAuto => 'Automático';

  @override
  String get choiceTab => 'Tabulação';

  @override
  String get choiceHigh => 'Alta';

  @override
  String get choiceMedium => 'Equilibrada';

  @override
  String get choiceLow => 'Arquivo leve';

  @override
  String get converting => 'Convertendo…';

  @override
  String convertingSemantics(int percent) {
    return 'Conversão em andamento, $percent por cento';
  }

  @override
  String get keepScreenOn => 'Mantenha o app aberto até o fim da conversão.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get resultTitle => 'Pronto!';

  @override
  String resultFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos criados',
      one: '1 arquivo criado',
    );
    return '$_temp0';
  }

  @override
  String resultSize(String before, String after) {
    return '$before → $after';
  }

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionSaveToFiles => 'Salvar em Arquivos';

  @override
  String get actionSaveToPhotos => 'Salvar em Fotos';

  @override
  String get actionShare => 'Compartilhar';

  @override
  String get actionOpen => 'Abrir';

  @override
  String get actionOpenWith => 'Abrir com…';

  @override
  String get shareAsZip => 'Tudo em um único ZIP';

  @override
  String get convertAnother => 'Outro formato';

  @override
  String get newFile => 'Novo arquivo';

  @override
  String get savedOk => 'Salvo.';

  @override
  String get savedPhotos => 'Salvo nas suas fotos.';

  @override
  String get saveFailed => 'Não foi possível salvar o arquivo.';

  @override
  String get openFailed => 'Nenhum app pode abrir este arquivo.';

  @override
  String get passwordTitle => 'Senha necessária';

  @override
  String passwordBody(String name) {
    return '“$name” está protegido. A senha é usada apenas neste dispositivo.';
  }

  @override
  String get passwordLabel => 'Senha';

  @override
  String get passwordWrong => 'Senha incorreta, tente novamente.';

  @override
  String get errCorrupt => 'Este arquivo parece danificado ou ilegível.';

  @override
  String get errUnsupported =>
      'Este arquivo não pode ser convertido com essas configurações.';

  @override
  String get errTooLarge =>
      'Este arquivo é grande demais para ser convertido neste dispositivo.';

  @override
  String get errNoSpace => 'Espaço de armazenamento insuficiente.';

  @override
  String get errEngine =>
      'Esta conversão não está disponível neste dispositivo.';

  @override
  String get errPick => 'Não foi possível abrir o arquivo.';

  @override
  String get dismiss => 'Fechar';

  @override
  String get settingsTooltip => 'Sobre e avisos legais';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutTagline =>
      'Grátis. Sem anúncios, sem conta, sem rastreamento. Seus arquivos nunca saem do seu dispositivo.';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutPrivacy => 'Privacidade';

  @override
  String get aboutPrivacyBody =>
      'Este app não coleta, armazena nem transmite dados pessoais. Seus arquivos são convertidos inteiramente no seu dispositivo e removidos do armazenamento temporário quando você termina ou escolhe outro arquivo.\n\nO app não tem conta, publicidade, análises, cookies nem rastreamento e não precisa de conexão com a internet. Os arquivos são lidos apenas dos locais que você escolhe, e os resultados só são salvos ou compartilhados quando você pede.\n\nComo o editor não trata nenhum dado, não é necessário um banner de consentimento.';

  @override
  String get aboutAccessibility => 'Acessibilidade';

  @override
  String aboutAccessibilityBody(String contact) {
    return 'O app foi projetado para ser usável por todos: suporte a leitores de tela (VoiceOver e TalkBack), texto que acompanha o tamanho de texto do sistema, temas claro e escuro com contraste suficiente, áreas de toque grandes e nenhum limite de tempo.\n\nO objetivo é o nível AA das WCAG 2.1, base do RGAA francês. Ainda não foi feita uma auditoria formal por terceiros, portanto a conformidade ainda não é certificada; esta declaração será atualizada após a auditoria.\n\nSe você encontrar um problema de acessibilidade, escreva para $contact. Responderemos em prazo razoável e buscaremos uma forma alternativa de dar acesso ao recurso.';
  }

  @override
  String get aboutLegal => 'Avisos legais e termos';

  @override
  String aboutLegalBody(String publisher, String contact) {
    return 'Editor: $publisher, pessoa física que atua a título não profissional.\nContato: $contact.\nHospedagem do site: OVH SAS, 2 rue Kellermann, 59100 Roubaix, França. Como permite o artigo 6, III-2 da LCEN francesa, o editor comunicou seus dados completos ao provedor de hospedagem.\n\nO app é oferecido gratuitamente e “como está”, sem compras, assinaturas nem publicidade. Os resultados dependem do arquivo de origem e podem diferir do original (layout, qualidade, metadados); guarde uma cópia dos originais.\n\nVocê é responsável por possuir os direitos dos arquivos que converte e por usar os resultados de forma lícita. O app não remove proteções: um PDF criptografado só é aberto com a senha que você fornece.';
  }

  @override
  String get aboutLicenses => 'Licenças de código aberto';

  @override
  String get aboutContact => 'Contatar o editor';

  @override
  String get aboutFfmpeg =>
      'A conversão de áudio e vídeo usa o FFmpeg (LGPL 3.0).';
}
