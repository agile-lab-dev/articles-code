def f(lat: Int, long: Int, alt: Int): Either[E, TagPoint] =
  for {
    rLat <- f1(lat).right
    rLong <- f1(long).right
    tagName <- f2(rLat, rLong).right
    result <- f3(rLat, rLong, alt, tagName).right
  } yield result

§

def f(lat: Int, long: Int, alt: Int): Either[E, TagPoint] =
  (f1(lat), f1(long)) match {
    case (Left(msg1), Left(msg2)) => Left(msg1 + "\n" + msg2)
    case (Left(msg1), _) => Left(msg1)
    case (_, Left(msg2)) => Left(msg2)
    case (Right(rLat), Right(rLong)) =>
      for {
        tagName <- f2(rLat, rLong).right
        result <- f3(rLat, rLong, alt, tagName).right
      } yield result
  }