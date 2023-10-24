import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Animaciones",
      home: ChartPage(),
    );
  }
}

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  ChartPageState createState() => ChartPageState();
}

//Se utiliza para proporcionar un mecanismo para la animación y la actualización continua de widgets.
//Esta clase es parte del paquete flutter/scheduler.dart y se utiliza para crear
//widgets que pueden ser actualizados de manera eficiente en el tiempo.
class ChartPageState extends State<ChartPage> with TickerProviderStateMixin {
  final random = Random();
  late AnimationController animation;
  List<BarTween> tweens = [];
  List<Color> barColors = []; // Lista de colores

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    for (int i = 0; i < 4; i++) {
      tweens.add(BarTween(Bar(0.0), Bar(random.nextDouble() * 100.0)));
      barColors.add(
          generateRandomColor()); // Se utiliza para almacenar colores generados aleatoriamente.
    }

    animation.forward();
  }

  // Se utiliza para realizar tareas de limpieza antes de que el widget se elimine por completo
  // Esto evita posibles fugas de memoria y asegura que la animación se detenga correctamente.
  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  //Se asegurarse de que los cambios en los datos se reflejen en la interfaz de usuario.
  void changeData() {
    setState(() {
      for (int i = 0; i < 4; i++) {
        tweens[i] = BarTween(
          tweens[i].evaluate(animation),
          Bar(random.nextDouble() * 100.0),
        );
        barColors[i] =
            generateRandomColor(); // Asignar nuevos colores aleatorios
      }
      //Esto inicia o reanuda una animación, haciendo que avance desde el inicio (desde 0.0).
      animation.forward(from: 0.0);
    });
  }

  // Generar un color aleatorio
  // Valores de componente rojo, verde y azul que se eligen de manera aleatoria en el rango de 0 a 255.
  Color generateRandomColor() {
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animaciones en barras"),
      ),
      body: Center(
        child: CustomPaint(
          size: const Size(200.0, 20.0),
          painter: BarChartPainter(
              tweens.map((tween) => tween.animate(animation)).toList(),
              barColors),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: changeData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class Bar {
  final double height;

  Bar(this.height);
}

class BarTween extends Tween<Bar> {
  BarTween(Bar begin, Bar end) : super(begin: begin, end: end);

  @override
  Bar lerp(double t) {
    return Bar(
      lerpDouble(begin!.height, end!.height, t) ?? 0.0,
    );
  }
}

class BarChartPainter extends CustomPainter {
  static const barWidth = 40.0;
  static const barSpacing = 20.0;

  final List<Animation<Bar>> animations;
  final List<Color> barColors; // Lista de colores

  BarChartPainter(this.animations, this.barColors)
      : super(repaint: animations.first);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < animations.length; i++) {
      final barHeight = animations[i].value.height;
      final paint = Paint()
        ..color = barColors[i] // Utilizar el color asignado
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          (i * (barWidth + barSpacing)) +
              (size.width - (barWidth + barSpacing) * animations.length) / 2.0,
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return animations.first != oldDelegate.animations.first;
  }
}
