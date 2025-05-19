import '../exceptions/validation_exception.dart';
import 'validator.dart';
import 'validator_error.dart';

typedef FieldExtractor<T, P> = P Function(T);

/// A fluent API builder to define and apply validation rules on a specific field.
///
/// This class is used internally by validators that extend `IValidator<T>`.
/// It helps build a chain of rules for a field, collect validation errors, and
/// customize error messages.
///
/// Type Parameters:
/// - `T`: The type of the object being validated.
/// - `P`: The type of the property being validated.
///
/// Example usage:
/// ```dart
/// class UserValidator extends IValidator<User> {
///   @override
///   void buildRules() {
///     ruleFor((x) => x.email, 'email')
///       .notNull().withMessage('Email is required')
///       .notEmpty().withMessage('Email cannot be empty')
///       .emailAddress().withMessage('Invalid email format');
///
///     ruleFor((x) => x.password, 'password')
///       .minLength(8).withMessage('Password must be at least 8 characters')
///       .matches(r'^(?=.*[A-Z])(?=.*\d).+$').withMessage('Password must contain uppercase and digit');
///
///     ruleFor((x) => x.confirmPassword, 'confirmPassword')
///       .mustMatch(x.password).withMessage('Passwords do not match');
///
///     ruleFor((x) => x.address, 'address')
///       .nested(AddressValidator());
///   }
/// }
/// ```
///
class RuleBuilder<T, P> {
  /// The name of the field being validated (used in error messages).
  final String field;

  /// The value of the field being validated.
  final P value;

  /// The shared list of validation errors for the current validator.
  final List<ValidatorError> errors;

  /// Keeps track of the last validation error for applying custom messages.
  ValidatorError? _lastError;

  /// Creates a new [RuleBuilder] for a specific field and its value.
  RuleBuilder(this.field, this.value, this.errors);

  /// Ensures the value is not empty (for strings).
  RuleBuilder<T, P> notEmpty() {
    if (value == null || (value is String && value.toString().trim().isEmpty)) {
      _lastError = ValidatorError(field, '$field must not be empty');
      errors.add(_lastError!);
    } else {
      _lastError = null;
    }
    return this;
  }

  /// Ensures the value is not null.
  RuleBuilder<T, P> notNull() {
    if (value == null) {
      _lastError = ValidatorError(field, '$field must not be null');
      errors.add(_lastError!);
    } else {
      _lastError = null;
    }
    return this;
  }

  /// Applies a nested validator to a sub-object.
  ///
  /// Errors from the nested validator will be prefixed with the parent field name
  /// (e.g., `address.city`) and added to the main error list.
  RuleBuilder<T, P> nested(IValidator<P> validator) {
    try {
      validator.validate(value);
    } on ValidationException catch (e) {
      errors.addAll(
        e.errors.map((e) => ValidatorError('$field.${e.field}', e.message)),
      );
    }
    return this;
  }

  /// Ensures the value matches the [otherValue].
  ///
  /// Useful for confirmation fields (e.g., password confirmation).
  RuleBuilder<T, P> mustMatch(P otherValue) {
    if (value != otherValue) {
      errors.add(
        _lastError = ValidatorError(
          field,
          '$field does not match the required value',
        ),
      );
      errors.add(_lastError!);
    } else {
      _lastError = null;
    }
    return this;
  }

  /// Ensures the value is in the provided list of [allowedValues].
  RuleBuilder<T, P> isIn(List<P> allowedValues) {
    if (!allowedValues.contains(value)) {
      _lastError = ValidatorError(field, '$field is not an allowed value');
      errors.add(_lastError!);
    } else {
      _lastError = null;
    }
    return this;
  }

  /// Validates that a string is a properly formatted email address.
  RuleBuilder<T, P> emailAddress() {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (value is String && !regex.hasMatch(value.toString())) {
      _lastError = ValidatorError(field, '$field is not a valid email');
      errors.add(_lastError!);
    } else {
      _lastError = null;
    }
    return this;
  }

  /// Ensures the string has a minimum length.
  RuleBuilder<T, P> minLength(int length) {
    if (value is String && value.toString().length < length) {
      _lastError = ValidatorError(
        field,
        '$field must be at least $length characters',
      );
      errors.add(_lastError!);
    } else {
      _lastError = null;
    }
    return this;
  }

  /// Validates the string against a regular expression pattern.
  RuleBuilder<T, P> matches(String pattern) {
    final regex = RegExp(pattern);
    if (value is String && !regex.hasMatch(value.toString())) {
      _lastError = ValidatorError(field, '$field does not match pattern');
      errors.add(_lastError!);
    } else {
      _lastError = null;
    }
    return this;
  }

  /// Overrides the error message for the previous rule if it failed.
  ///
  /// Must be called immediately after a rule.
  RuleBuilder<T, P> withMessage(String message) {
    if (_lastError != null) {
      final index = errors.lastIndexOf(_lastError!);
      if (index != -1) {
        errors[index] = ValidatorError(_lastError!.field, message);
        _lastError = errors[index]; // update reference
      }
    }
    return this;
  }
}
