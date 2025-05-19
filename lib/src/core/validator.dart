import '../exceptions/validation_exception.dart';
import 'rule_builder.dart';
import 'validator_error.dart';

/// An abstract base class for creating strongly-typed validators for specific models.
///
/// `IValidator<T>` provides a structure for building validation rules using a fluent API.
/// It manages validation state, executes the defined rules, and throws a [ValidationException]
/// if any rule is violated.
///
/// Type parameter:
/// - [T]: The type of the object to be validated.
///
/// Example:
/// ```dart
/// class User {
///   final String email;
///   final String password;
///   User(this.email, this.password);
/// }
///
/// class UserValidator extends IValidator<User> {
///   @override
///   void buildRules() {
///     ruleFor((u) => u.email, 'email')
///         .notEmpty().withMessage('Email is required')
///         .emailAddress().withMessage('Email is invalid');
///
///     ruleFor((u) => u.password, 'password')
///         .notEmpty()
///         .minLength(8).withMessage('Password must be at least 8 characters');
///   }
/// }
///
/// final validator = UserValidator();
/// try {
///   validator.validate(User('', '123'));
/// } catch (e) {
///   if (e is ValidationException) {
///     for (var error in e.errors) {
///       print('${error.field}: ${error.message}');
///     }
///   }
/// }
/// // Output:
/// // email: Email is required
/// // password: Password must be at least 8 characters
/// ```
abstract class IValidator<T> {
  /// Internal list of accumulated validation errors.
  final List<ValidatorError> _errors = [];

  /// The current instance being validated.
  late T instance;

  /// Executes validation on the given [instance].
  ///
  /// Clears previous errors, builds rules by calling [buildRules],
  /// and throws a [ValidationException] if validation fails.
  void validate(T instance) {
    this.instance = instance;
    _errors.clear();
    buildRules();
    if (_errors.isNotEmpty) {
      throw ValidationException(_errors);
    }
  }

  /// Override this method to define validation rules using [ruleFor].
  void buildRules();

  /// Creates a [RuleBuilder] for a specific property in the instance.
  ///
  /// - [property]: A function that extracts a field from the instance.
  /// - [field]: The name of the field (used for error reporting).
  ///
  /// Returns a [RuleBuilder] that allows chaining validation methods.
  RuleBuilder<T, P> ruleFor<P>(P Function(T) property, String field) {
    final value = property(instance);
    return RuleBuilder<T, P>(field, value, _errors);
  }
}
