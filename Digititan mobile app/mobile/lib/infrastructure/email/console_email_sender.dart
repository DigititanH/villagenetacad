import '../../domain/repositories/email_sender.dart';

/// Prototype email sender.
/// Does NOT talk to Gmail. Prints to console / debug log.
/// Later we swap this (DI) for a backend HTTP mail client.
class ConsoleEmailSender implements EmailSender {
  @override
  Future<void> send({
    required String to,
    required String subject,
    required String body,
  }) async {
    // ignore: avoid_print
    print('===== EMAIL (prototype) =====');
    // ignore: avoid_print
    print('To: $to');
    // ignore: avoid_print
    print('Subject: $subject');
    // ignore: avoid_print
    print(body);
    // ignore: avoid_print
    print('=============================');
  }
}
