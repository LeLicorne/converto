import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:pdfrx/pdfrx.dart';

bool _initialized = false;

Future<void> ensurePdfEngine() async {
  if (_initialized) return;
  await pdfrxFlutterInitialize();
  _initialized = true;
}

Future<PdfDocument> openPdf(String path, {String? password}) async {
  await ensurePdfEngine();
  var attempts = 0;
  try {
    return await PdfDocument.openFile(
      path,
      passwordProvider: () {
        attempts++;
        if (password == null) throw const PasswordRequired();
        if (attempts > 1) throw const PasswordRequired(wrongPassword: true);
        return password;
      },
    );
  } on PasswordRequired {
    rethrow;
  } on PdfPasswordException {
    throw PasswordRequired(wrongPassword: password != null);
  } on PdfException {
    throw const CorruptedFile();
  }
}
