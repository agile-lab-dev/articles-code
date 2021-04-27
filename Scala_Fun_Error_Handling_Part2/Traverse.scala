List[Option[Int]] → Option[List[Int]]
Tree[Either[String, Int]] → Either[String, Tree[Int]]
Vector[ValidatedNel[String, Int]] → ValidatedNel[String, Vector[Int]]

§

import cats.syntax.traverse._
import cats.syntax.option._
import cats.instances.list._
import cats.instances.option._

val list: List[Int] = List(1, 0, 3, 7, -1)
list.traverse {(x: Int) => if (x > 0) x.some else None } // None: Option[List[Int]]

// OR THIS

val list: List[Option[Int]] = List(1, 0, 3, 7, -1).map { x => if (x > 0) x.some else None }
list.sequence // None: Option[List[Int]]

§

import cats.Traverse
import cats.syntax.either._
import cats.instances.list._
import cats.instances.either._

val list: List[Int] = List(1, 0, 3, 7, -1)

Traverse[List].traverse(list) {
  (x: Int) => if (x > 0) x.asRight else "negative!!".asLeft
} // Left(negative!): Either[String, List[Int]]

§

import cats.Traverse
import cats.syntax.validated._
import cats.instances.list._
import cats.instances.string._

val list: List[Int] = List(1, 0, 3, 7, -1)
Traverse[List].traverse(list) {
  (x: Int) => if (x > 0) x.valid else s"$x: negative!!".invalid
} // Invalid(0: negative!)-1: negative!!): Invalid[String, List[Int]]