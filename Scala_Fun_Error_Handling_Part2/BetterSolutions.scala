def applyF1ToBoth(lat: Int, long: Int): Either[E, (Double, Double)]

§

import cats.syntax.either._

def applyF1ToBoth(lat: Int, long: Int): Either[E, (Double, Double)] =
  (f1(lat).toValidatedNec, f1(long).toValidatedNec) // Tuple2[ValidatedNec[E, Double], ValidatedNec[E, Double]]

§

import cats.syntax.either._
import cats.syntax.apply._

def applyF1ToBoth(lat: Int, long: Int): Either[E, (Double, Double)] =
  (f1(lat).toValidatedNec, f1(long).toValidatedNec).mapN {
    case (rLat, rLong) => rLat -> rLong
  } // ValidatedNec[E, (Double, Double)]

§

import cats.syntax.either._
import cats.syntax.apply._

def applyF1ToBoth(lat: Int, long: Int): Either[E, (Double, Double)] =
  (f1(lat).toValidatedNec, f1(long).toValidatedNec).mapN {
    case (rLat, rLong) => rLat -> rLong
  }.leftMap { chain =>
    chain.reduceLeft(_ + "\n" + _)
  } // Validated[E, (Double, Double)]

§

import cats.syntax.either._
import cats.syntax.apply._

def applyF1ToBoth(lat: Int, long: Int): Either[E, (Double, Double)] =
  (f1(lat).toValidatedNec, f1(long).toValidatedNec).mapN {
    case (rLat, rLong) => rLat -> rLong
  }.leftMap{ chain =>
    chain.reduceLeft(_ + "\n" + _)
  }.toEither

§

def f(lat: Int, long: Int, alt: Int): Either[E, TagPoint] =
  for {
    r <- applyF1ToBoth(lat, long).right
    (rLat, rLong) = r
    tagName <- f2(rLat, rLong).right
    result  <- f3(rLat, rLong, alt, tagName).right
  } yield result

§

val a = 1.validNel[Throwable]
val b = (new RuntimeException).invalid[Int]
val c = (new RuntimeException).invalid[Int]
(a, b, c).mapN((ra, rb, rc) => ra + rb + rc)
// Error: could not find implicit value for parameter
// semigroupal: Semigroupal[cats.data.Validated[Throwable,A]]