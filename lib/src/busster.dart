import 'core/handler.dart';
import 'core/request.dart';

/// A simple mediator-style bus for sending requests to their corresponding handlers.
///
/// The `Busster` class is responsible for coordinating the dispatch of request objects
/// (that implement [IRequest]) to their respective handlers (that implement [IHandler]).
///
/// This allows for decoupling the sending of requests from the handling logic,
/// and supports validation automatically if the handler provides a validator.
///
/// Example usage:
/// ```dart
/// // Define a request
/// class LoginRequest implements IRequest<String> {
///   final String email;
///   final String password;
///
///   LoginRequest(this.email, this.password);
/// }
///
/// // Define a handler for the request
/// class LoginHandler extends IHandler<LoginRequest, String> {
///   LoginHandler() : super(LoginValidator());
///
///   @override
///   Future<String> handle(LoginRequest request) async {
///     return 'Logged in as ${request.email}';
///   }
/// }
///
/// // Register and use the Busster
/// final bus = Busster();
/// bus.registerHandler(LoginHandler());
///
/// final response = await bus.send(LoginRequest('user@example.com', 'password123'));
/// print(response); // "Logged in as user@example.com"
/// ```
class Busster {
  /// Internal map that holds handlers by request type.
  final Map<Type, dynamic> _handlers = {};

  /// Registers a handler for a specific type of [IRequest].
  ///
  /// The handler must implement [IHandler] for the given request type.
  /// If a handler is already registered for the same request type, it will be replaced.
  void registerHandler<TRequest extends IRequest<TResponse>, TResponse>(
    IHandler<TRequest, TResponse> handler,
  ) {
    _handlers[TRequest] = handler;
  }

  /// Sends a request and returns a response by dispatching it to the appropriate handler.
  ///
  /// Automatically runs validation (if any) through [IHandler.handleRequest].
  ///
  /// Throws an [Exception] if no handler is registered for the request type.
  Future<TResponse> send<TResponse>(IRequest<TResponse> request) async {
    final handler = _handlers[request.runtimeType];
    if (handler == null) {
      throw Exception('No handler registered for ${request.runtimeType}');
    }

    // Call handleRequest to ensure validation happens automatically
    return await (handler as dynamic).handleRequest(request);
  }
}
