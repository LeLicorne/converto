// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Converto';

  @override
  String get pickTitle => 'Elegir un archivo';

  @override
  String get pickSubtitle =>
      'Imagen, PDF, documento, audio o vídeo. Todo se queda en tu dispositivo.';

  @override
  String get pickMedia => 'Fotos y vídeos';

  @override
  String get pickMultipleHint =>
      'Puedes seleccionar varios archivos para combinarlos.';

  @override
  String get loading => 'Leyendo el archivo…';

  @override
  String get changeFile => 'Cambiar';

  @override
  String get changeFileSemantics => 'Elegir otro archivo';

  @override
  String filesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '1 archivo',
    );
    return '$_temp0';
  }

  @override
  String detectedFormat(String format) {
    return 'Detectado: $format';
  }

  @override
  String get unknownFormat => 'Formato no reconocido';

  @override
  String get convertTo => 'Convertir a';

  @override
  String get noTargets => 'No hay conversiones disponibles para este archivo.';

  @override
  String get mixedFiles =>
      'Estos archivos son de tipos distintos y no se pueden convertir juntos.';

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
  String get categoryImage => 'Imágenes';

  @override
  String get categoryDocument => 'Documentos';

  @override
  String get categoryData => 'Datos';

  @override
  String get categoryArchive => 'Archivos comprimidos';

  @override
  String get categoryAudio => 'Audio';

  @override
  String get categoryVideo => 'Vídeo';

  @override
  String get extractArchive => 'Extraer archivos';

  @override
  String get mergePdf => 'Combinar / editar PDF';

  @override
  String get createZip => 'Archivo ZIP';

  @override
  String get optionsTitle => 'Opciones';

  @override
  String convertButton(String format) {
    return 'Convertir a $format';
  }

  @override
  String get optQuality => 'Calidad';

  @override
  String get optMaxSize => 'Tamaño máximo';

  @override
  String get optStripMetadata => 'Eliminar metadatos (ubicación, cámara…)';

  @override
  String get optPages => 'Páginas';

  @override
  String get optPagesHint => 'Todas las páginas, o por ejemplo 1-3, 5';

  @override
  String optPagesInvalid(int count) {
    return 'Selección de páginas no válida (1 a $count).';
  }

  @override
  String get optLayout => 'Resultado';

  @override
  String get layoutSeparate => 'Una imagen por página';

  @override
  String get layoutSingle => 'Una sola imagen continua';

  @override
  String get optDpi => 'Resolución (DPI)';

  @override
  String get optPageSize => 'Tamaño de página';

  @override
  String get pageSizeFit => 'Ajustado a la imagen';

  @override
  String get optGrouping => 'Resultado';

  @override
  String get groupingSingle => 'Un solo PDF con todas las imágenes';

  @override
  String get groupingPerImage => 'Un PDF por imagen';

  @override
  String get optOptimize => 'Optimizar el tamaño del archivo';

  @override
  String get optFontSize => 'Tamaño del texto';

  @override
  String get optDelimiter => 'Separador';

  @override
  String get optOutputDelimiter => 'Separador';

  @override
  String get optFirstRowHeader =>
      'La primera fila contiene los nombres de columna';

  @override
  String get optPretty => 'Formato legible';

  @override
  String get optPageSeparators => 'Añadir separadores de página';

  @override
  String get optRotation => 'Rotación';

  @override
  String get optBitrate => 'Tasa de bits';

  @override
  String get optSampleRate => 'Frecuencia de muestreo';

  @override
  String get optChannels => 'Canales';

  @override
  String get optKeepMetadata => 'Conservar etiquetas y carátula';

  @override
  String get optResolution => 'Resolución';

  @override
  String get optFps => 'Fotogramas por segundo';

  @override
  String get optCodec => 'Códec';

  @override
  String get optKeepAudio => 'Conservar la pista de audio';

  @override
  String get optGifWidth => 'Ancho';

  @override
  String get optGifFps => 'Fotogramas por segundo';

  @override
  String get optGifDuration => 'Duración máxima';

  @override
  String get choiceOriginal => 'Original';

  @override
  String get choiceFull => 'Todo el vídeo';

  @override
  String get choiceMono => 'Mono';

  @override
  String get choiceStereo => 'Estéreo';

  @override
  String get choiceAuto => 'Automático';

  @override
  String get choiceTab => 'Tabulación';

  @override
  String get choiceHigh => 'Alta';

  @override
  String get choiceMedium => 'Equilibrada';

  @override
  String get choiceLow => 'Archivo ligero';

  @override
  String get converting => 'Convirtiendo…';

  @override
  String convertingSemantics(int percent) {
    return 'Conversión en curso, $percent por ciento';
  }

  @override
  String get keepScreenOn =>
      'Mantén la aplicación abierta hasta que termine la conversión.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'Aceptar';

  @override
  String get resultTitle => '¡Listo!';

  @override
  String resultFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos creados',
      one: '1 archivo creado',
    );
    return '$_temp0';
  }

  @override
  String resultSize(String before, String after) {
    return '$before → $after';
  }

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionSaveToFiles => 'Guardar en Archivos';

  @override
  String get actionSaveToPhotos => 'Guardar en Fotos';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionOpen => 'Abrir';

  @override
  String get actionOpenWith => 'Abrir con…';

  @override
  String get shareAsZip => 'Todo en un solo ZIP';

  @override
  String get convertAnother => 'Otro formato';

  @override
  String get newFile => 'Nuevo archivo';

  @override
  String get savedOk => 'Guardado.';

  @override
  String get savedPhotos => 'Guardado en tus fotos.';

  @override
  String get saveFailed => 'No se pudo guardar el archivo.';

  @override
  String get openFailed => 'Ninguna aplicación puede abrir este archivo.';

  @override
  String get passwordTitle => 'Se requiere contraseña';

  @override
  String passwordBody(String name) {
    return '«$name» está protegido. La contraseña solo se usa en este dispositivo.';
  }

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordWrong => 'Contraseña incorrecta, inténtalo de nuevo.';

  @override
  String get errCorrupt => 'Este archivo parece dañado o no se puede leer.';

  @override
  String get errUnsupported =>
      'Este archivo no se puede convertir con estos ajustes.';

  @override
  String get errTooLarge =>
      'Este archivo es demasiado grande para convertirlo en este dispositivo.';

  @override
  String get errNoSpace => 'No hay suficiente espacio de almacenamiento.';

  @override
  String get errEngine =>
      'Esta conversión no está disponible en este dispositivo.';

  @override
  String get errPick => 'No se pudo abrir el archivo.';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get settingsTooltip => 'Acerca de y aviso legal';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutTagline =>
      'Gratis. Sin anuncios, sin cuenta, sin rastreo. Tus archivos nunca salen de tu dispositivo.';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutPrivacy => 'Privacidad';

  @override
  String get aboutPrivacyBody =>
      'Esta aplicación no recopila, almacena ni transmite datos personales. Tus archivos se convierten por completo en tu dispositivo y se eliminan del almacenamiento temporal cuando terminas o eliges otro archivo.\n\nLa aplicación no tiene cuenta, publicidad, analítica, cookies ni rastreo, y no necesita conexión a internet. Los archivos solo se leen desde las ubicaciones que eliges, y los resultados solo se guardan o comparten cuando lo pides.\n\nComo el editor no trata ningún dato, no hace falta un banner de consentimiento.';

  @override
  String get aboutAccessibility => 'Accesibilidad';

  @override
  String aboutAccessibilityBody(String contact) {
    return 'La aplicación está diseñada para que todos puedan usarla: compatibilidad con lectores de pantalla (VoiceOver y TalkBack), texto que sigue el tamaño de texto del sistema, temas claro y oscuro con contraste suficiente, zonas táctiles grandes y sin límites de tiempo.\n\nEl objetivo es el nivel AA de las WCAG 2.1, base del RGAA francés. Todavía no se ha realizado una auditoría formal por un tercero, por lo que la conformidad aún no está certificada; esta declaración se actualizará tras la auditoría.\n\nSi encuentras un problema de accesibilidad, escribe a $contact. Responderemos en un plazo razonable y buscaremos una forma alternativa de darte acceso a la función.';
  }

  @override
  String get aboutLegal => 'Aviso legal y condiciones';

  @override
  String aboutLegalBody(String publisher, String contact) {
    return 'Editor: $publisher, persona física que actúa a título no profesional.\nContacto: $contact.\nAlojamiento del sitio web: OVH SAS, 2 rue Kellermann, 59100 Roubaix, Francia. Como permite el artículo 6, III-2 de la LCEN francesa, el editor ha comunicado sus datos completos al proveedor de alojamiento.\n\nLa aplicación se ofrece gratis y «tal cual», sin compras, suscripciones ni publicidad. Los resultados dependen del archivo de origen y pueden diferir del original (diseño, calidad, metadatos); conserva una copia de tus originales.\n\nEres responsable de tener los derechos de los archivos que conviertes y de usar los resultados de forma lícita. La aplicación no elimina protecciones: un PDF cifrado solo se abre con la contraseña que proporcionas.';
  }

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String get aboutContact => 'Contactar con el editor';

  @override
  String get aboutFfmpeg =>
      'La conversión de audio y vídeo usa FFmpeg (LGPL 3.0).';
}
