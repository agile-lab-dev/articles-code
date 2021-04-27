class StringSemigroup extends Semigroup[String] {
  def combine(x: String, y: String): String = x + y
}

class ListSemigroup[A] extends Semigroup[List[A]] {
  def combine(x: List[A], y: List[A]): List[A] = x ::: y
}

class MapSemigroup[A, B: Semigroup] extends Semigroup[Map[A. B]] {
  def combine(x: Map[A, B], y: Map[A, B]): Map[A. N] = {
    ...
  }
}