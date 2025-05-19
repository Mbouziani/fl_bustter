import 'package:fl_bustter/fl_bustter.dart';
import 'package:test/test.dart';

class PasswordRequest extends IRequest<String> {
  final String password;
  final String confirmPassword;

  PasswordRequest(this.password, this.confirmPassword);
}

class PasswordValidator extends IValidator<PasswordRequest> {
  @override
  void buildRules() {
    ruleFor((x) => x.password, 'password')
        .minLength(6)
        .withMessage('Password must be at least 6 characters');

    ruleFor((x) => x.confirmPassword, 'confirmPassword')
        .mustMatch(instance.password)
        .withMessage('Passwords do not match');
  }
}

class PasswordHandler extends IHandler<PasswordRequest, String> {
  PasswordHandler() : super(PasswordValidator());

  @override
  Future<String> handle(PasswordRequest request) async {
    return 'Passwords accepted';
  }
}

// Nested object
class ProfileRequest extends IRequest<String> {
  final String name;
  final Address address;

  ProfileRequest(this.name, this.address);
}

class Address {
  final String city;
  Address(this.city);
}

class AddressValidator extends IValidator<Address> {
  @override
  void buildRules() {
    ruleFor((x) => x.city, 'city')
        .notEmpty()
        .withMessage('City must not be empty');
  }
}

class ProfileValidator extends IValidator<ProfileRequest> {
  @override
  void buildRules() {
    ruleFor((x) => x.name, 'name').notEmpty();
    ruleFor((x) => x.address, 'address').nested(AddressValidator());
  }
}

class ProfileHandler extends IHandler<ProfileRequest, String> {
  ProfileHandler() : super(ProfileValidator());

  @override
  Future<String> handle(ProfileRequest request) async {
    return 'Profile accepted';
  }
}

void main() {
  group('PasswordHandler Tests', () {
    late Busster busster;

    setUp(() {
      busster = Busster();
      busster.registerHandler(PasswordHandler());
    });

    test('Valid passwords pass', () async {
      final result =
          await busster.send(PasswordRequest('secret123', 'secret123'));
      expect(result, equals('Passwords accepted'));
    });

    test('Too short password fails with custom message', () {
      expect(
        () => busster.send(PasswordRequest('123', '123')),
        throwsA(predicate((e) =>
            e is ValidationException &&
            e.errors.any((err) =>
                err.message == 'Password must be at least 6 characters'))),
      );
    });

    test('Mismatched passwords fail with custom message', () {
      expect(
        () => busster.send(PasswordRequest('secret123', 'different')),
        throwsA(predicate((e) =>
            e is ValidationException &&
            e.errors.any((err) => err.message == 'Passwords do not match'))),
      );
    });
  });

  group('ProfileHandler Nested Validation', () {
    late Busster busster;

    setUp(() {
      busster = Busster();
      busster.registerHandler(ProfileHandler());
    });

    test('Valid profile passes', () async {
      final result =
          await busster.send(ProfileRequest('Alice', Address('Riyadh')));
      expect(result, equals('Profile accepted'));
    });

    test('Empty name fails', () {
      expect(
        () => busster.send(ProfileRequest('', Address('Riyadh'))),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Empty address city fails with nested error', () {
      expect(
        () => busster.send(ProfileRequest('Alice', Address(''))),
        throwsA(predicate((e) =>
            e is ValidationException &&
            e.errors.any((err) =>
                err.field == 'address.city' &&
                err.message == 'City must not be empty'))),
      );
    });
  });
}
