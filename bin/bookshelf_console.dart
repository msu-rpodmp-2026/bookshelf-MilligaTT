import 'dart:io';
import 'dart:convert';

// В моменте пока проверял работу кода, решил что долго всё последовательно прогонять,
// поэтому решил сделать в начале выбор задания к которому можно перейти.
// P.S Задание 2 и 3 находятся в одном пункте
void task1() {
  const String projectName = 'bookshelf_console';
  print('');
  print('Проект: $projectName');
  print('Версия Dart: ${Platform.version}');
  print('Операционная система: ${Platform.operatingSystem}');
  print('');
}

void task2() {
  stdout.write('Название: ');
  String title = stdin.readLineSync(encoding: utf8) ?? '';
  if (title.trim().isEmpty) {
    title = 'без названия';
  }

  stdout.write('Автор: ');
  final String author = stdin.readLineSync(encoding: utf8) ?? 'неизвестен';

  stdout.write('Год издания: ');
  final int year = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  stdout.write('Количество страниц: ');
  int pages = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
  if (pages <= 0) {
    pages = 1;
  }

  stdout.write('Оценка (0–5): ');
  final String ratingRaw =
      (stdin.readLineSync(encoding: utf8) ?? '').replaceAll(',', '.');
  double rating = double.tryParse(ratingRaw) ?? 0.0;
  if (rating < 0) {
    rating = 0.0;
  } else if (rating > 5) {
    rating = 5.0;
  }

  stdout.write('Прочитана (да/нет): ');
  final String readRaw = stdin.readLineSync(encoding: utf8) ?? 'нет';
  final String readNorm = readRaw.trim().toLowerCase();
  final bool isRead = readNorm == 'да';

  final String category;
  if (pages <= 150) {
    category = 'брошюра';
  } else if (pages <= 399) {
    category = 'книга';
  } else {
    category = 'том';
  }

  final double hours = pages / 50;
  final String hoursText = hours.toStringAsFixed(1);

  final int currentYear = DateTime.now().year;
  int age = currentYear - year;
  if (age < 0) {
    age = 0;
  }

  String initials = '';
  final List<String> parts = author.trim().split(RegExp(r'\s+'));
  for (final String part in parts) {
    if (part.isNotEmpty) {
      initials += '${part[0].toUpperCase()}. ';
    }
  }
  initials = initials.trim();

  print('');
  print('=' * 44);
  print(' «$title»');
  print(' Автор: $author ($initials)');
  print(' Год: $year (возраст: $age лет)');
  print(' Страниц: $pages ($category)');
  print(' Время чтения: $hoursText ч');
  print(' Оценка: ${rating.toStringAsFixed(1)} / 5');
  print(' Прочитана: ${isRead ? 'да' : 'нет'}');
  print('=' * 44);
  print('');
}

void task4() {
  final List<String> shelf = <String>[
    'Мастер и Маргарита',
    'Преступление и наказание',
    'Война и мир',
    '1984',
    'Гарри Поттер',
  ];
  print('=' * 44);
  print('Полка: $shelf');
  print('Длина: ${shelf.length}');
  print('Первая: ${shelf.first}');
  print('Последняя: ${shelf.last}');
  print('=' * 44);
  print('');
  shelf.insert(0, 'Три товарища');
  shelf.add('Тень горы');
  print('После добавления в начало и конец: $shelf');

  shelf.remove('1984');
  print('После удаления «1984»: $shelf');
  print('');

  stdout.write('Жанры (через запятую): ');
  final String genresRaw = stdin.readLineSync(encoding: utf8) ?? '';
  final Set<String> genres = genresRaw
      .split(',')
      .map((String g) => g.trim())
      .toSet();

  print('Жанры: $genres');
  print('Уникальных жанров: ${genres.length}');
  print('');

  print('Количество страниц: ');
  final Map<String, int> pagesByBook = <String, int>{
    'Мастер и Маргарита': 480,
    'Преступление и наказание': 671,
    'Война и мир': 1225,
    '1984': 320,
    'Гарри Поттер': 410,
  };

  pagesByBook.forEach((String title, int pages) {
    print('  $title — $pages стр.');
  });

  String maxTitle = '';
  int maxPages = 0;
  int total = 0;
  pagesByBook.forEach((String title, int pages) {
    total += pages;
    if (pages > maxPages) {
      maxPages = pages;
      maxTitle = title;
    }
  });
  final double average = total / pagesByBook.length;

  print('Самая толстая: «$maxTitle» ($maxPages стр.)');
  print('Суммарно страниц: $total');
  print('Среднее: ${average.toStringAsFixed(1)}');
  print('');

  print('Список all ');
  final List<String> all = <String>[
    'Начало списка',
    ...shelf,
    if (shelf.length > 3) 'Полка большая',
    for (int i = 1; i <= 3; i++) 'Том $i',
    'Конец списка',
  ];

  print('=' * 160);
  print('all: $all');
  print('=' * 160);
}

void task5() {
  print('');
  print('1. Арифметические операторы: /, ~/, % ===');
  demoArithmetic();

  print('\n2. "Ленивое" вычисление && и || ');
  demoShortCircuit();

  print('\n3. Операторы ?., ??, ??= ');
  demoNullAware();

  print('\n4. Различие final и const ');
  demoFinalVsConst();

  print('\n5. Каскадный оператор (StringBuffer) ');
  demoCascade();
}

void demoArithmetic() {
  final double division = 7 / 2;
  final int intDivision = 7 ~/ 2;
  final int remainder = 7 % 2;

  print('7 /  2 = $division  (тип: ${division.runtimeType})');
  print('7 ~/ 2 = $intDivision (тип: ${intDivision.runtimeType})');
  print('7 %  2 = $remainder  (тип: ${remainder.runtimeType})');
}

bool check(String name, bool value) {
  print('  -> check("$name") вызвана, вернёт $value');
  return value;
}

void demoShortCircuit() {
  print('Случай A: false && check(...)');
  final bool a = check('левый', false) && check('правый', true);
  print('  результат: $a (правый операнд не вызывался)\n');

  print('Случай B: true || check(...)');
  final bool b = check('левый', true) || check('правый', false);
  print('  результат: $b (правый операнд не вызывался)\n');

  print('Случай C: true && check(...)');
  final bool c = check('левый', true) && check('правый', true);
  print('  результат: $c (оба операнда вызваны)');
}

// Обёртка чтобы компилятор не вычислил результат статически
// и не пометил вторую строку ??= как dead_code.
String? maybeNull() => null;

// Вспомогательная функция, результат которой компилятор не может предсказать
String? getRandomCity() {
  return DateTime.now().millisecond.isEven ? 'Смоленск' : null;
}

void demoNullAware() {
  final String? maybeName = null;
  final int? length = maybeName?.length;
  print('null?.length = $length');

  final String realName = 'Дарт'; 
  print("'Дарт'.length = ${realName.length}");

  final String fallback = maybeName ?? 'значение по умолчанию';
  print("название ?? 'по умолчанию' = $fallback");

  String? city = null;
  city ??= 'Минск';
  print("город после ??= 'Минск': $city");

  city = getRandomCity();
  city ??= 'Могилёв';
  print("город после повторного ??= 'Могилёв': $city (осталось прежним)");
}

void demoFinalVsConst() {
  final DateTime now = DateTime.now();
  print('final now = $now (значение известно только во время работы)');

  const List<int> constList = <int>[1, 2, 3];

  final List<int> finalList = <int>[1, 2, 3];
  finalList.add(4);
  finalList[0] = 99;
  print('final list после изменений: $finalList');

  print('const list (не менялся): $constList');
  print('constList == <int>[1, 2, 3] ${constList == <int>[1, 2, 3]}');
}

void demoCascade() {
  final StringBuffer plain = StringBuffer();
  plain.write('Книга: ');
  plain.write('«Мастер и Маргарита»');
  plain.writeln();
  plain.write('Автор: Михаил Булгаков');
  print('Без каскада:\n$plain');

  final StringBuffer cascade = StringBuffer()
    ..write('Книга: ')
    ..write('«Мастер и Маргарита»')
    ..writeln()
    ..write('Автор: Булгаков')
    ..writeln()
    ..write('Год: 1967');
  print('С каскадом:\n$cascade');

  final List<String> shelf = <String>['Мастер и Маргарита', '1984', 'Война и мир'];
  print('Список: $shelf');
}

void main() {
  stdout.encoding = utf8;
  stderr.encoding = utf8;
  bool running = true;
  while (running) {
    print('');
    print('1 - Задание 1');
    print('2 - Задание 2');
    print('4 - Задание 4');
    print('5 - Задание 5');
    print('0 - Выход');
    stdout.write('Выберите пункт: ');

    final String choice = (stdin.readLineSync() ?? '').trim();

    switch (choice) {
      case '1':
        task1();
        break;
      case '2':
        task2();
        break;
      case '4':
        task4();
        break;
      case '5':
        task5();
        break;
      case '0':
        running = false;
        break;
      default:
        print('Неизвестный пункт: «$choice». Попробуйте снова.');
    }
  }
}