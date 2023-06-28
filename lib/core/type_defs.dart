import 'package:fpdart/fpdart.dart';
import 'package:randomy/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
