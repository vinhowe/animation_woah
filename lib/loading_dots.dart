import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

Offset offsetFromVector(Vector2 vector) {
  return Offset(vector.x, vector.y);
}

Vector2 vectorFromOffset(Offset offset) {
  return Vector2(offset.dx, offset.dy);
}

Vector2 rotateVector(double radians) {}

class LoadingDotsPainter extends CustomPainter {
  final List<PhysicsDot> dotPositions;
  final DotSystem dotSystem;
  final ChangeNotifier drawTick;
  final Color movingColor;
  final Color idleColor;
  final double radius;

  LoadingDotsPainter(this.dotPositions, this.dotSystem,
      {this.drawTick,
      this.idleColor = Colors.red,
      this.movingColor = Colors.redAccent,
      this.radius = 3.0})
      : super(repaint: drawTick);

  @override
  void paint(Canvas canvas, Size size) {
    if (dotPositions == null) {
      return;
    }
    final Paint paint = Paint()..color = movingColor;
    final Paint indicator = Paint()..color = Colors.green;
    final Paint attractedIndicator = Paint()..color = Colors.purple;

    paint.strokeWidth = 0.0;

    Vector2 center = vectorFromOffset(size.center(Offset.zero));

    // Draw a circle that circumscribes the arrow.
    paint.style = PaintingStyle.fill;


    // List<Color> colors = [Colors.red, Colors.black87, Colors.purple, Colors.brown, Colors.grey, Colors.greenAccent, Colors.yellow];

    int shapeCount = 0;

    dotSystem.shape.forEach((Vector2 point) {

      shapeCount++;
      canvas.drawCircle(offsetFromVector(center + point), radius, indicator);
      TextSpan span = new TextSpan(style: new TextStyle(color: Colors.blue[800]), text: shapeCount.toString());
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, offsetFromVector(center + point));
    });

    int count = 0;

    dotPositions.forEach((PhysicsDot dot) {
      // paint.color = colors[count];

      count++;
      int distance = dot.velocity.length.abs().floor();

      for (int i = 1; i < distance; i++) {
        Vector2 addedPosition = (dot.velocity * (i / distance));
        Vector2 finalPosition = center + (dot.position - addedPosition);
        //Keeps any motion from being clipped out
        // if (finalPosition.y > center.y + 0.1) continue;
        canvas.drawCircle(offsetFromVector(finalPosition), radius, paint);
      }

    int attractedDistance =
          (dot.attractedPoint - dot.position).length.abs().floor();

/*      for (int i = 1; i < attractedDistance; ++i) {
        Vector2 addedPosition =
            ((dot.position - dot.attractedPoint) * (i / attractedDistance));
        Vector2 finalPosition = center + (dot.position - addedPosition);
        //Keeps any motion from being clipped out

        canvas.drawCircle(offsetFromVector(finalPosition), radius, attractedIndicator);
      }

      canvas.drawCircle(offsetFromVector(center + dot.attractedPoint), radius, indicator);*/

      canvas.drawCircle(offsetFromVector(center + dot.position), radius, paint);

      /*TextSpan span = new TextSpan(style: new TextStyle(color: Colors.blue[800]), text: count.toString());
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, offsetFromVector(center + dot.position));*/
    });

    paint.color = movingColor;

/*    canvas.save();
    Path clipPath = Path();

    dotPositions.forEach((PhysicsDot dot) {
      clipPath.addOval(Rect.fromCircle(
          center: (center + dot.position.scale(1, 0)), radius: radius));
    });

    canvas.clipPath(clipPath);

*/ /*    dotPositions.forEach((PhysicsDot dot) => canvas.drawCircle(
        center + dot.position.scale(1, 0), radius, paint));*/ /*

*/ /*    dotPositions.forEach((PhysicsDot dot) {
      canvas.drawCircle(center + dot.position, radius, intersectPaint);
    });*/ /*

    canvas.restore();*/
  }

  @override
  bool shouldRepaint(LoadingDotsPainter oldDelegate) {
    return oldDelegate.dotPositions != dotPositions;
  }
}

class LoadingDots extends StatefulWidget {
  final TickerProvider tickerProvider;
  final int dotCount = 9;
  double padding = 10.0;
  double radius = 50;

  LoadingDots({TickerProvider vsync}) : tickerProvider = vsync;

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with WidgetsBindingObserver {
  Duration lastElapsed;
  List<PhysicsDot> dotPositions;
  DotSystem dotSystem;
  Ticker ticker;

  double lowerBoundY;
  double upperBoundY;

  double lowerBoundX;
  double upperBoundX;

  LoadingDotsPainter loadingDotsPainter;
  bool isCircle = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    lowerBoundY = -300;
    upperBoundY = 300;

    lowerBoundX =
        -100 + (-(widget.padding * widget.dotCount) / 2) - widget.padding;
    upperBoundX =
        100 + ((widget.padding * widget.dotCount) / 2) + widget.padding;

    WidgetsBinding.instance.addObserver(this);

    setState(() {
      dotPositions = _createDotPositions(widget.padding, widget.dotCount);
    });

    ChangeNotifier drawTick = new ChangeNotifier();

    ticker = widget.tickerProvider.createTicker((Duration elapsed) {
      _updateDots(elapsed);
      drawTick.notifyListeners();
    });
    ticker.start();

    loadingDotsPainter =
        new LoadingDotsPainter(dotPositions, dotSystem, drawTick: drawTick);
  }

  List<PhysicsDot> _createDotPositions(double padding, int dotCount) {
    List<PhysicsDot> dots = [];

    Vector2 top = Vector2(0, -widget.radius);

    List<Vector2> shape = [];

    int shapeSize = widget.dotCount * 15;

    Random random = Random();

    for (int i = 0; i < shapeSize; i++) {
      shape.add(Matrix2.rotation((i.toDouble() / shapeSize) * 2 * pi)
          .transform(top.clone()));

/*      double posX =
          random.nextDouble() * (upperBoundX - lowerBoundX) + lowerBoundX;
      double posY =
          random.nextDouble() * (upperBoundY - lowerBoundY) + lowerBoundY;
      shape.add(Vector2(posX, posY));*/

    }

    dotSystem = DotSystem(
        cycleProgress: 0,
        shape: _checkMarkShape(),
        positions: _fillSpacedPositions(widget.dotCount),
        movementBehavior: DotSystemMovementBehavior.static);

    List<Vector2> pointPositions = dotSystem.pointPositions;

    for (Vector2 position in pointPositions) {
      dots.add(
          new PhysicsDot(position, Vector2.zero(), attractedPoint: position));
    }
    return dots;
  }

  List<double> _fillSpacedPositions(int count) {
    if (count < 1) {
      throw Exception("Can't create an empty spaced positions list");
    }
    List<double> values = [];
    for (int i = 0; i <= count-1; i++) {
      values.add(i / (count-1));
    }
    return values;
  }

  List<Vector2> _checkMarkShape() {
    double spacing = 15;

    List<Vector2> values = [
      Vector2(-spacing, 0),
      Vector2(0, spacing),
      Vector2(spacing, 0),
      Vector2(spacing * 2, -spacing),
      Vector2(spacing * 3, -spacing * 2),
    ];

    int shapeSize = widget.dotCount * 15;

    Vector2 top = Vector2(0, -widget.radius);


    List<Vector2> circle = [];
/*
    for (int i = 0; i < shapeSize; i++) {
      circle.add(Matrix2.rotation((i.toDouble() / shapeSize) * 2 * pi)
          .transform(top.clone()));

    }*/

    circle.addAll(values);

    return circle;
  }

  _updateDots(Duration elapsed) {
    double delta =
        (elapsed - (lastElapsed ?? elapsed)).inMilliseconds / (1000 / 30);
    lastElapsed = elapsed;

    if (delta > 10) {
      delta = 0;
    }

    double decay = (1 - (0.2 * delta));
    double hitDecay = (1 - (0.2 * delta));
    // double gravity = 4.0 * delta;

    Random random = new Random();

    List<PhysicsDot> positions = dotPositions;

    dotSystem = dotSystem.advance(delta / 25);

    List<Vector2> pointPositions = dotSystem.pointPositions;

/*    if(pointPositions.length != positions.length) {
      print('');
    }*/

    for (int i = 0; i < pointPositions.length; i++) {
      positions[i] = positions[i].withAttractedPoint(pointPositions[i]);
    }

    for (int i = 0; i < widget.dotCount; i++) {
      PhysicsDot dot = positions[i];

      Vector2 updatedPosition = (dot.position + (dot.velocity * delta));

      Vector2 updatedVelocity = dot.velocity * decay;

      Vector2 clampedPosition = Vector2(
          min(max(updatedPosition.x, lowerBoundX), upperBoundX),
          min(max(updatedPosition.y, lowerBoundY), upperBoundY));

      double secondHitDecay = hitDecay;

      if (updatedPosition.x < lowerBoundX || updatedPosition.x > upperBoundX) {
        updatedVelocity =
            Vector2(-updatedVelocity.x * secondHitDecay, updatedVelocity.y);
      }

      if (updatedPosition.y < lowerBoundY ||
          updatedPosition.y > upperBoundY - 0.1) {
        updatedVelocity = Vector2(
            updatedVelocity.x,
            updatedVelocity.y.abs() > 2
                ? -updatedVelocity.y * secondHitDecay
                : 0);
      }

      // Allow jumping if dot is both in line position and near the center y

      if (updatedPosition.y.abs() < 2 && !isCircle) {
        dot = dot.withJump(Duration.zero);
      }

      // Rotate if circle
/*
      if (isCircle) {
        Vector2 rotatedPoint =
            Matrix2.rotation(0.2 * delta).transform(dot.attractedPoint.clone());

        dot = dot.withAttractedPoint(rotatedPoint);
      }*/

      // Add gravity to velocity

      if (dot.attractedPoint != null) {
        Vector2 distanceBetween = dot.attractedPoint - clampedPosition;

        double distance = max(distanceBetween.length, 100);

        double mass = 50000;

        double constant = 2;

        double pull = constant / distance / math.pow(distance, 2);

        updatedVelocity += distanceBetween * mass * pull * delta;

        dot = dot.withVelocity(updatedVelocity);
      }

      dot = dot.withPosition(clampedPosition);

      positions[i] = dot;
    }

    // Random move to random point

/*    if (random.nextDouble() < 0.01) {
      int randomIndex = random.nextInt(dotPositions.length - 1);

      double posX =
          random.nextDouble() * (upperBoundX - lowerBoundX) + lowerBoundX;
      double posY =
          random.nextDouble() * (upperBoundY - lowerBoundY) + lowerBoundY;

      positions[randomIndex] =
          positions[randomIndex].withAttractedPoint(Vector2(posX, posY));
    }*/

    int randomIndex = random.nextInt(dotPositions.length - 2);

    PhysicsDot dot = positions[randomIndex];
    PhysicsDot dot2 = positions[randomIndex + 1];

    // Random state change

/*    if (random.nextDouble() < 0.001) {
      setState(() {
        isCircle = !isCircle;
      });
      int dotCount = dotPositions.length;
      for (int i = 0; i < dotCount; i++) {
        double jumpX;
        double jumpY;
        Vector2 newAttractedPoint;
        if (isCircle) {
          jumpX = 0; //(random.nextDouble() * 40) - 20;
          jumpY = 0; //(random.nextDouble() * 40) - 20;

          Vector2 top = Vector2(0, -widget.radius);
          newAttractedPoint =
              Matrix2.rotation((i.toDouble() / dotCount) * 2 * pi)
                  .transform(top.clone());
        } else {
          jumpX = 0;
          jumpY = 0; //-(random.nextDouble()*50);

          newAttractedPoint = Vector2(
              i * widget.padding - ((dotCount - 1) * widget.padding / 2), 0);
        }
        dotPositions[i] = dotPositions[i]
            .withVelocity(Vector2(jumpX, jumpY))
            .withAttractedPoint(newAttractedPoint);
      }
    }*/

    // Random jump

    if (random.nextDouble() < 0.1 * delta &&
        (dot.jumpMoment == Duration.zero && dot2.jumpMoment == Duration.zero) &&
        !isCircle) {
      double requiredMovement = 0;
      double movementX = requiredMovement;
      double movementY =
          (random.nextBool() ? -1 : 1) * (random.nextInt(5) + 5).toDouble();
      bool firstDotSlides = random.nextBool();

      dot = dot
          .withVelocity(dot.velocity
            ..add(Vector2(movementX, firstDotSlides ? movementY : 0)))
          .withJump(elapsed);

      dot2 = dot2
          .withVelocity(dot2.velocity
            ..add(Vector2(-movementX, firstDotSlides ? 0 : movementY)))
          .withJump(elapsed);

      // Swap them
      dotPositions[randomIndex + 1] =
          dot.withAttractedPoint(dot2.attractedPoint);
      dotPositions[randomIndex] = dot2.withAttractedPoint(dot.attractedPoint);
    }

    dotPositions = positions;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        lastElapsed = null;
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.suspending:
        break;
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    ticker.stop(canceled: true);
    WidgetsBinding.instance.removeObserver(this);
    setState(() {
      lastElapsed = null;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 64, height: 64, child: CustomPaint(painter: loadingDotsPainter));
  }
}

class PhysicsDot {
  final Vector2 position;
  final Vector2 velocity;
  final Duration jumpMoment;
  final Vector2 attractedPoint;

  PhysicsDot(this.position, this.velocity,
      {this.jumpMoment = Duration.zero, this.attractedPoint});

  PhysicsDot withPosition(Vector2 position) {
    return PhysicsDot(position, velocity,
        jumpMoment: jumpMoment, attractedPoint: attractedPoint);
  }

  PhysicsDot withVelocity(Vector2 velocity) {
    return PhysicsDot(position, velocity,
        jumpMoment: jumpMoment, attractedPoint: attractedPoint);
  }

  PhysicsDot withJump(Duration jumpMoment) {
    return PhysicsDot(position, velocity,
        jumpMoment: jumpMoment, attractedPoint: attractedPoint);
  }

  PhysicsDot withAttractedPoint(Vector2 attractedPoint) {
    return PhysicsDot(position, velocity,
        jumpMoment: jumpMoment, attractedPoint: attractedPoint);
  }
}

class DotSystem {
  final DotSystemMovementBehavior movementBehavior;
  final Vector2 _origin;
  final List<Vector2> shape;
  final List<double> positions;
  final double cycleProgress;

  DotSystem(
      {this.cycleProgress,
      Vector2 origin,
      this.shape = const [],
      this.positions = const [],
      this.movementBehavior = DotSystemMovementBehavior.cycle})
      : _origin = origin;

  Vector2 get origin => _origin ?? Vector2.zero();

  List<Vector2> get pointPositions {
    double totalDistance = 0.0;

    int shapeLength = movementBehavior == DotSystemMovementBehavior.cycle ? shape.length: shape.length-1;

    for (int i = 0; i < shapeLength; i++) {
      Vector2 point = shape[i];
      // Wrap around to the end
      Vector2 nextPoint = shape[(i + 1)%shape.length];

      double distance = point.distanceTo(nextPoint);
      totalDistance += distance;
    }

    List<Vector2> pointPositions = [];

    for (int i = 0; i < positions.length; i++) {
      double position = positions[i];
      double nextPosition = positions[(i + 1) % positions.length];

      double animationPosition = (position +
          (nextPosition > position
                  ? (nextPosition - position)
                  : ((nextPosition + 1) - position) % 1) *
              cycleProgress);

      double totalLinearPosition = animationPosition * totalDistance;

/*      if(i == 0) {
        print("Position $position");
        print("NextPos $nextPosition");
        print("AnimationPos $animationPosition");
        print("");
      }*/
      Vector2 finalPointPosition;
      double distanceCounted = 0;
      for (int d = 0; d < shape.length; d++) {
        Vector2 point = shape[d];
        Vector2 nextPoint = shape[(d + 1) % shape.length];

        double distance = point.distanceTo(nextPoint);
        distanceCounted += distance;

        double relativeDistance =
            (totalLinearPosition - (distanceCounted - distance)) / distance;

        if (distanceCounted >= totalLinearPosition) {
          Vector2 pointPosition =
              point + ((nextPoint - point) * relativeDistance);
          finalPointPosition = pointPosition;
          break;
        } /*else if (distanceCounted == totalDistance && totalLinearPosition > totalDistance) {

          Vector2 pointPosition = nextPoint;
          pointPositions.add(pointPosition);
          break;
        }*/
      }
      pointPositions.add(finalPointPosition);
      if(finalPointPosition == null) {
        print("woah");
      }
    }
    return pointPositions;
  }

  DotSystem advance(double delta) {
    if (movementBehavior == DotSystemMovementBehavior.static) {
      return this;
    }
    if (positions == null) {
      throw Exception("Can't advance an empty DotSystem.");
    }

    List<double> updatedPositions = positions;

    double newValue = (cycleProgress + delta);

    if (newValue >= 1) {
      updatedPositions.insert(updatedPositions.length, updatedPositions.first);
      updatedPositions.removeAt(0);
      newValue = 0;
    }

    return DotSystem(
        cycleProgress: newValue,
        origin: origin,
        shape: shape,
        positions: updatedPositions,
        movementBehavior: movementBehavior);
  }

  DotSystem withPositions(List<double> positions) {
    return DotSystem(
        cycleProgress: cycleProgress,
        origin: origin,
        shape: shape,
        positions: positions,
        movementBehavior: movementBehavior);
  }
}

enum DotSystemMovementBehavior { static, cycle }
