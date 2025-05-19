import 'request.dart';
import 'validator.dart';

/// Abstract base class for handling a request with optional validation.
///
/// This generic handler is part of a CQRS (Command Query Responsibility Segregation) pattern
/// and is used to encapsulate the logic for processing a request (`TRequest`)
/// and returning a response (`TResponse`). It optionally accepts a validator
/// to enforce business rules before handling the request.
///
/// Type Parameters:
/// - `TRequest`: The type of request being handled, which must implement `IRequest<TResponse>`.
/// - `TResponse`: The type of response expected from handling the request.
///
/// Example usage:
/// ```dart
/// class CreateUserRequest implements IRequest<User> {
///   final String email;
///   final String password;
///
///   CreateUserRequest(this.email, this.password);
/// }
///
/// class CreateUserHandler extends IHandler<CreateUserRequest, User> {
///   CreateUserHandler() : super(CreateUserValidator());
///
///   @override
///   Future<User> handle(CreateUserRequest request) async {
///     // Business logic to create a user
///     return User(email: request.email);
///   }
/// }
/// ```
abstract class IHandler<TRequest extends IRequest<TResponse>, TResponse> {
  /// Optional validator to check the request before handling it.
  final IValidator<TRequest>? _validator;

  /// Creates an [IHandler] with an optional validator.
  IHandler([this._validator]);

  /// Validates the [request] (if a validator is present) and then handles it.
  ///
  /// This method should be called by consumers to trigger validation and handling.
  Future<TResponse> handleRequest(TRequest request) async {
    _validator?.validate(request);
    return handle(request);
  }

  /// Handles the business logic for the given [request].
  ///
  /// Must be implemented by subclasses to define how the request is processed.
  Future<TResponse> handle(TRequest request);
}
