/// Marker interface representing a request that expects a response of type [TResponse].
///
/// This interface is typically used in conjunction with the [IHandler] interface
/// to define requests in a CQRS (Command Query Responsibility Segregation) pattern.
///
/// Type Parameter:
/// - [TResponse]: The type of response that this request expects.
///
/// Example:
/// ```dart
/// class GetUserByIdRequest implements IRequest<User> {
///   final String userId;
///
///   GetUserByIdRequest(this.userId);
/// }
/// ```
abstract class IRequest<TResponse> {}
