/// Represents a validation error for a specific field in a request or model.
///
/// Contains the name of the field that failed validation and an associated error message.
/// This class is typically used by validators to accumulate and report detailed
/// validation issues.
///
/// Fields:
/// - [field]: The name of the field that failed validation.
/// - [message]: A human-readable message describing the validation failure.
///
/// Example:
/// ```dart
/// final error = ValidatorError('email', 'Email is not valid');
/// print('${error.field}: ${error.message}');
/// // Output: email: Email is not valid
/// ```
class ValidatorError {
  /// The name of the field that failed validation.
  final String field;

  /// A human-readable message describing why validation failed.
  final String message;

  /// Constructs a [ValidatorError] with the given [field] and [message].
  ValidatorError(this.field, this.message);
}
