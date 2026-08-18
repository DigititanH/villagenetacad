/// Abstraction for sending email.
/// UI must NEVER import Gmail SMTP or hold App Passwords.
abstract class EmailSender {
  Future<void> send({
    required String to,
    required String subject,
    required String body,
  });
}
