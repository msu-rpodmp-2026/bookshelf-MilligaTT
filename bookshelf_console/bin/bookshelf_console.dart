import 'dart:io';
import 'dart:convert';

typedef Book = Map<String, Object?>;

final List<Book> library = <Book>[
  {
    'title': 'Основы Dart',
    'author': 'С. А. Чернышев',
    'year': 2024,
    'pages': 521,
    'genre': 'учебник',
    'read': true,
  },
  {
    'title': 'Flutter на практике',
    'author': 'Ф. Заметти',
    'year': 2020,
    'pages': 328,
    'genre': 'учебник',
    'read': false,
  },
  {
    'title': 'Мастер и Маргарита',
    'author': 'М. А. Булгаков',
    'year': 1967,
    'pages': 480,
    'genre': 'роман',
    'read': true,
  },
  {
    'title': '1984',
    'author': 'Дж. Оруэлл',
    'year': 1949,
    'pages': 320,
    'genre': 'фантастика',
    'read': true,
  },
  {
    'title': 'Преступление и наказание',
    'author': 'Ф. М. Достоевский',
    'year': 1866,
    'pages': 671,
    'genre': 'роман',
    'read': false,
  },
  {
    'title': 'Дюна',
    'author': 'Ф. Герберт',
    'year': 1965,
    'pages': 512,
    'genre': 'фантастика',
    'read': false,
  },
  {
    'title': 'Краткая история времени',
    'author': 'С. Хокинг',
    'year': 1988,
    'pages': 256,
    'genre': 'научпоп',
    'read': true,
  },
  {
    'title': 'Убийство в «Восточном экспрессе»',
    'author': 'А. Кристи',
    'year': 1934,
    'pages': 288,
    'genre': 'детектив',
    'read': true,
  },
  {
    'title': 'Гарри Поттер и философский камень',
    'author': 'Дж. Роулинг',
    'year': 1997,
    'pages': 410,
    'genre': 'фантастика',
    'read': true,
  },
  {
    'title': 'Код да Винчи',
    'author': 'Д. Браун',
    'year': 2003,
    'pages': 542,
    'genre': 'детектив',
    'read': false,
  },
];

void printAll(List<Book> books, {String emptyMessage = 'Ничего не найдено.'}) {
  if (books.isEmpty) {
    print(emptyMessage);
    return;
  }
  print('-' * 78);
  for (int i = 0; i < books.length; i++) {
    final Book b = books[i];
    final String mark = b['read'] == true ? '[x]' : '[ ]';
    final String num = (i + 1).toString().padLeft(2);
    print(
      '$num. $mark «${b['title']}» — ${b['author']}, ${b['year']}, ${b['pages']} стр., ${b['genre']}',
    );
  }
  print('-' * 78);
}

List<Book> searchByField(List<Book> books, String field, String query) {
  final String q = query.trim().toLowerCase();
  return books
      .where((Book b) => (b[field]?.toString() ?? '').toLowerCase().contains(q))
      .toList();
}

List<Book> filterByRead(List<Book> books, bool isRead) {
  return books.where((Book b) => (b['read'] == true) == isRead).toList();
}

List<Book> sortBy(List<Book> books, String field, {bool descending = false}) {
  final List<Book> copy = <Book>[...books];
  copy.sort((Book a, Book b) {
    final Object? av = a[field];
    final Object? bv = b[field];
    int cmp;
    if (av is num && bv is num) {
      cmp = av.compareTo(bv);
    } else {
      cmp = (av?.toString() ?? '').compareTo(bv?.toString() ?? '');
    }
    return descending ? -cmp : cmp;
  });
  return copy;
}

void printStatistics(List<Book> books) {
  if (books.isEmpty) {
    print('Каталог пуст.');
    return;
  }
  final int total = books.length;
  final int readCount = books.where((Book b) => b['read'] == true).length;
  final int totalPages = books.fold<int>(
    0,
    (int sum, Book b) => sum + (b['pages'] as int),
  );
  final double avgPages = totalPages / total;
  final Book oldest = books.reduce(
    (Book a, Book b) => (a['year'] as int) <= (b['year'] as int) ? a : b,
  );
  final Book newest = books.reduce(
    (Book a, Book b) => (a['year'] as int) >= (b['year'] as int) ? a : b,
  );
  final Book thickest = books.reduce(
    (Book a, Book b) => (a['pages'] as int) >= (b['pages'] as int) ? a : b,
  );
  final Set<String> genres = books
      .map((Book b) => b['genre'] as String)
      .toSet();
  final Map<String, int> byGenre = books.fold<Map<String, int>>(
    <String, int>{},
    (Map<String, int> acc, Book b) {
      final String g = b['genre'] as String;
      acc[g] = (acc[g] ?? 0) + 1;
      return acc;
    },
  );
  final double readPercent = readCount / total * 100;
  final bool hasOld = books.any((Book b) => (b['year'] as int) < 1950);
  final bool allTitled = books.every(
    (Book b) => (b['title'] as String).isNotEmpty,
  );

  print('=' * 50);
  print('СТАТИСТИКА КАТАЛОГА');
  print('=' * 50);
  print('Всего книг:              $total');
  print('Прочитано:               $readCount');
  print('Суммарно страниц:        $totalPages');
  print('Среднее страниц:         ${avgPages.toStringAsFixed(1)}');
  print('Самая старая:            «${oldest['title']}» (${oldest['year']})');
  print('Самая новая:             «${newest['title']}» (${newest['year']})');
  print(
    'Самая объёмная:          «${thickest['title']}» (${thickest['pages']} стр.)',
  );
  print('Уникальные жанры:        $genres');
  print('Книг по жанрам:          $byGenre');
  print('Доля прочитанного:       ${readPercent.toStringAsFixed(1)}%');
  print('Есть книга старше 1950:  ${hasOld ? 'да' : 'нет'}');
  print('У всех книг есть название: ${allTitled ? 'да' : 'нет'}');
  print('=' * 50);
}

void printMenu() {
  print('');
  print('=== BookShelf ===');
  print('1 - Показать весь каталог');
  print('2 - Поиск по автору');
  print('3 - Поиск по названию');
  print('4 - Фильтр по жанру');
  print('5 - Фильтр по признаку «прочитана»');
  print('6 - Сортировка');
  print('7 - Статистика каталога');
  print('8 - Добавить книгу');
  print('9 - Удалить книгу по номеру');
  print('0 - Выход');
  stdout.write('> ');
}

String readLine() => (stdin.readLineSync(encoding: utf8) ?? '').trim();

void main() {
  stdout.encoding = utf8;
  stderr.encoding = utf8;
  bool running = true;
  while (running) {
    printMenu();
    final String command = readLine();
    switch (command) {
      case '1':
        printAll(library);
        break;
      case '2':
        stdout.write('Автор: ');
        final String q = readLine();
        printAll(
          searchByField(library, 'author', q),
          emptyMessage: 'По автору ничего не найдено.',
        );
        break;
      case '3':
        stdout.write('Название: ');
        final String q = readLine();
        printAll(
          searchByField(library, 'title', q),
          emptyMessage: 'По названию ничего не найдено.',
        );
        break;
      case '4':
        stdout.write('Жанр: ');
        final String q = readLine();
        printAll(
          searchByField(library, 'genre', q),
          emptyMessage: 'Жанр не найден.',
        );
        break;
      case '5':
        stdout.write('Показать прочитанные? (да/нет): ');
        final String ans = readLine().toLowerCase();
        final bool isRead = ans == 'да' || ans == '+';
        printAll(filterByRead(library, isRead));
        break;
      case '6':
        stdout.write('Поле (title/author/year/pages): ');
        final String field = readLine();
        const Set<String> valid = <String>{'title', 'author', 'year', 'pages'};
        if (!valid.contains(field)) {
          print(
            'Неизвестное поле: «$field». Допустимо: title, author, year, pages.',
          );
          break;
        }
        stdout.write('По убыванию? (да/нет): ');
        final String descRaw = readLine().toLowerCase();
        final bool desc = descRaw == 'да' || descRaw == '+';
        printAll(sortBy(library, field, descending: desc));
        break;
      case '7':
        printStatistics(library);
        break;
      case '8':
        print(
          'Добавление книги будет реализовано на следующем этапе (задание 5).',
        );
        break;
      case '9':
        print(
          'Удаление книги будет реализовано на следующем этапе (задание 5).',
        );
        break;
      case '0':
        running = false;
        break;
      default:
        print('Неизвестная команда. Повторите ввод.');
    }
  }
  print('Работа завершена.');
}
