import 'package:english_words/english_words.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair('Bienvenido a', ' nuestra app');
  late double num1, nnum1;
  late double num2, nnum2;
  late String operacion;
  late double middle, middle1;
  late String resultado, resultado1;

  void getNext() {
    Random random = Random();
    num1 = random.nextDouble() * 10;
    num2 = random.nextDouble() * 10;
    nnum1 = double.parse(num1.toStringAsFixed(2));
    nnum2 = double.parse(num2.toStringAsFixed(2));

    operacion = ['+', '-', '*', '/', '^'][random.nextInt(5)];

    switch (operacion) {
      case '+':
        middle = nnum1 + nnum2;
        middle1 = double.parse(middle.toStringAsFixed(2));
        resultado = '$nnum1 + $nnum2 ';
        resultado1 = '= $middle1';
       
        break;
      case '-':
        middle = nnum1 - nnum2;
        middle1 = double.parse(middle.toStringAsFixed(2));
        resultado = '$nnum1 - $nnum2 ';
        resultado1 = '= $middle1';
        
        break;
      case '*':
        middle = nnum1 * nnum2;
        middle1 = double.parse(middle.toStringAsFixed(2));
        resultado = '$nnum1 * $nnum2 ';
        resultado1 = '= $middle1';

        break;
      case '/':
        middle = nnum1 / nnum2;
        middle1 = double.parse(middle.toStringAsFixed(2));
        resultado = '$nnum1 / $nnum2 ';
        resultado1 = '= $middle1';
        
        break;
      case '^':
        var x1 = nnum1;
        var x2 = nnum2;
        middle = pow(x1, x2).toDouble();
        middle1 = double.parse(middle.toStringAsFixed(2));
        resultado = '$nnum1 ^ $nnum2 ';
        resultado1 = '= $middle1';

        break;
    }

    WordPair wordPair = WordPair(resultado, '= ????');
    current = wordPair;
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void cardclickrealizado() {
    current =  WordPair(resultado, '= $middle1');
    notifyListeners();
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Inicio'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favoritos'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page, // ← Here.
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Siguiente'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: pair.asPascalCase));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('Se ha copiado en el portapapeles del celular. ')));
            },
            child: Text('Copiar al portapapeles del celular'),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No tienes operaciones matematicas en favorito.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Tu tienes '
              '${appState.favorites.length} favorito:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<MyAppState>(context, listen: false);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return GestureDetector(
      onTap: () {
        appState.cardclickrealizado();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resultado realizado mostrado. ')),
        );
      },
      child: Card(
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            pair.asPascalCase,
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}",
          ),
        ),
      ),
    );
  }
}
