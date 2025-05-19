import '../core/validator_error.dart';

/// An exception that is thrown when validation fails for one or more fields.
///
/// The [ValidationException] contains a list of [ValidatorError] objects
/// that describe which fields failed and why.
///
/// It is typically thrown from an [IValidator] implementation when
/// `validate()` is called and one or more validation rules fail.
///
/// Example:
/// ```dart
/// try {
///   userValidator.validate(user);
/// } catch (e) {
///   if (e is ValidationException) {
///     for (var error in e.errors) {
///       print('${error.field}: ${error.message}');
///     }
///   }
/// }
/// ```
///
/// Output might look like:
/// ```
/// email: Email is required
/// password: Password must be at least 8 characters
/// ```
class ValidationException implements Exception {
  /// A list of validation errors that caused this exception.
  final List<ValidatorError> errors;

  /// Creates a [ValidationException] with a list of [ValidatorError]s.
  ValidationException(this.errors);

  /// Returns a human-readable string listing all validation errors.
  @override
  String toString() {
    return errors.map((e) => '${e.field}: ${e.message}').join('\n');
  }
}
