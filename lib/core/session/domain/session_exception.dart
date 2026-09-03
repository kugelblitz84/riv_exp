class InvalidSessionException implements Exception {
  const InvalidSessionException();

  @override
  String toString() {
    return 'The session is invalid or has expired.';
  }
}

class InvalidAuthResponseException implements Exception {
  const InvalidAuthResponseException([
    this.message = 'The authentication response is invalid.',
  ]);

  final String message;

  @override
  String toString() => message;
}
