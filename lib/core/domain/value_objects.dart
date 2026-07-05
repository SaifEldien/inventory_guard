import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class ValueObject<T> {
  const ValueObject();
  Either<Failure, T> get value;

  bool isValid() => value.isRight();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ValueObject<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Value($value)';
}
