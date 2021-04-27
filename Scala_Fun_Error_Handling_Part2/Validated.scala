sealed abstract class Validated[+E, +A]

final case class Valid[+A](a: A)   extends Validated[Nothing, A]

final case class Invalid[+E](e: E) extends Validated[E, Nothing]

§

// Types
type ValidatedNel[+E, +A] = Validated[NonEmptyList[E], A]
type ValidatedNec[+E, +A] = Validated[NonEmptyChain[E], A]

// Functions to/from `Either`
import cats.data.Validated

Validated[E, A].toEither // Either[E, A]

import cats.either.syntax._

Either[E, A].toValidated // Validated[E, A]
Either[E, A].toValidatedNec // ValidatedNec[E, A] -> Validated[NonEmptyChain[E], A]
Either[E, A].toValidatedNel // ValidatedNel[E, A] -> Validated[NonEmptyList[E], A]

§

import cats.syntax.validated._

3.valid            // Validated[Nothing, Int]
3.valid[String]    // Validated[String, Int]
3.validNel[String] // ValidatedNel[String, Int]
3.validNec[String] // ValidatedNec[String, Int]