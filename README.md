# fl_bustter

A lightweight Dart command bus and validation framework inspired by CQRS (Command Query Responsibility Segregation) patterns. Designed for clean, testable, and scalable architecture in Dart or Flutter applications.

## ✨ Features

- 📨 `Busster`: A simple request/handler dispatcher.
- ✅ `IValidator`: Built-in validation system with rules like `notEmpty`, `emailAddress`, `mustMatch`, `isIn`, and `nested`.
- 📦 Easy integration with custom request types and handlers.
- 🧪 Fully testable.

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  fl_bustter: ^1.0.1
```

Then run:

```bash
dart pub get
```

## 📦 Getting Started

### 1. Create a Response

```dart
class LoginResponse {
  final String token;
  LoginResponse(this.token);
}
```

### 2. Create a Request

```dart
class LoginRequest extends IRequest<LoginResponse> {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});
}
```

### 3. Create a Validator

```dart
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
```

### 4. Create a Request

```dart
class LoginRequest extends IRequest<String> {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});
}
```

### 5. Create a Handler

```dart
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
```

### 5. Register in Busster

```dart
void main()  {
  final busster = Busster();

  // Register the handler
  busster.registerHandler<LoginRequest, LoginResponse>(LoginHandler());
}
```

### 6. Use Busster

```dart
void call() async {
   
  try {
    final request = LoginRequest(email: 'test@example.com', password: 'password123');
    final result = await busster.send<LoginResponse>(request);
    print(result.token); // Login successful: token_string_example
  } on ValidationException catch (e) {
    print('Validation failed:');
    print(e.toString());
  } catch (e) {
    print('Error: $e');
  }
}
```

## 📁 Example

See [`example/main.dart`](example/main.dart) for a working login use case.

## 🧪 Tests

Run tests using:

```bash
dart test
```

## 📄 License

This project is licensed under the [MIT License](LICENSE).
