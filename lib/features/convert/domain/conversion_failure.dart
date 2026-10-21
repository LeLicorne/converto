sealed class ConversionFailure implements Exception {
  const ConversionFailure();
}

final class PasswordRequired extends ConversionFailure {
  const PasswordRequired({this.wrongPassword = false});

  final bool wrongPassword;
}

final class CorruptedFile extends ConversionFailure {
  const CorruptedFile();
}

final class UnsupportedFile extends ConversionFailure {
  const UnsupportedFile();
}

final class FileTooLarge extends ConversionFailure {
  const FileTooLarge();
}

final class NotEnoughSpace extends ConversionFailure {
  const NotEnoughSpace();
}

final class ConversionCancelled extends ConversionFailure {
  const ConversionCancelled();
}

final class EngineUnavailable extends ConversionFailure {
  const EngineUnavailable();
}
