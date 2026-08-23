abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de conexión a internet']);
}

class ExtractionFailure extends Failure {
  const ExtractionFailure([super.message = 'Error al extraer el audio de YouTube']);
}

class StreamExpiredFailure extends Failure {
  const StreamExpiredFailure([super.message = 'El enlace de reproducción ha expirado']);
}