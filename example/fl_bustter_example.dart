import 'package:fl_bustter/fl_bustter.dart';

/// Login Request
class LoginRequest extends IRequest<LoginResponse> {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});
}

/// Login Response
class LoginResponse {
  final String token;
  LoginResponse(this.token);
}

/// Login Validator
class LoginValidator extends IValidator<LoginRequest> {
  @override
  void buildRules() {
    ruleFor((x) => x.email, 'email')
        .notEmpty()
        .emailAddress()
        .withMessage('Please enter a valid email');

    ruleFor((x) => x.password, 'password')
        .notEmpty()
        .minLength(6)
        .withMessage('Password must be at least 6 characters');
  }
}

/// Login Handler
class LoginHandler extends IHandler<LoginRequest, LoginResponse> {
  LoginHandler() : super(LoginValidator());

  @override
  Future<LoginResponse> handle(LoginRequest request) async {
    await Future.delayed(Duration(seconds: 5));

    // Simulate login logic
    if (request.email == 'test@example.com' &&
        request.password == 'password123') {
      return LoginResponse("token_string_example");
    } else {
      throw Exception('Invalid email or password');
    }
  }
}

void main() async {
  final busster = Busster();

  // Register the handler
  busster.registerHandler<LoginRequest, LoginResponse>(LoginHandler());

  try {
    final request =
        LoginRequest(email: 'test@example.com', password: 'password123');

    final result = await busster.send<LoginResponse>(request);
    print(result.token); // Login successful: token_string_example
  } on ValidationException catch (e) {
    print('Validation failed:');
    print(e.toString());
  } catch (e) {
    print('Error: $e');
  }
}
