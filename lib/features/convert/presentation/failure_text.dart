import 'package:converto/features/convert/domain/conversion_failure.dart';
import 'package:converto/l10n/generated/app_localizations.dart';

String failureText(AppLocalizations l10n, ConversionFailure failure) =>
    switch (failure) {
      PasswordRequired(:final wrongPassword) =>
        wrongPassword ? l10n.passwordWrong : l10n.passwordTitle,
      CorruptedFile() => l10n.errCorrupt,
      UnsupportedFile() => l10n.errUnsupported,
      FileTooLarge() => l10n.errTooLarge,
      NotEnoughSpace() => l10n.errNoSpace,
      EngineUnavailable() => l10n.errEngine,
      ConversionCancelled() => '',
    };
