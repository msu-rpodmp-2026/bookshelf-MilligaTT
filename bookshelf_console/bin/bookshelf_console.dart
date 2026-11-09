import 'dart:io';
import 'dart:convert';

enum ReadingStatus {
  planned('Запланирована', 0),
  reading('Читаю', 1),
  finished('Прочитана', 2),
  abandoned('Брошена', 3);

  final String label;
  final int order;
  const ReadingStatus(this.label, this.order);

  bool get isDone => this == ReadingStatus.finished;

  static ReadingStatus fromName(String name) =>
      values.firstWhere((s) => s.name == name, orElse: () => planned);
}

abstract class LibraryItem {
  String get title;
  String describe();
  void printCard() {
    print(describe());
  }
}

class Book extends LibraryItem {
  @override
  final String title;
  final String author;
  final int year;
  final int pages;
  final Set<String> genres;
  final ReadingStatus status;
  double? _rating;

  Book({
    required this.title,
    required this.author,
    this.year = 2024,
    this.pages = 100,
    Set<String>? genres,
    this.status = ReadingStatus.planned,
    double? rating,
  }) : genres = genres ?? <String>{},
       _rating = rating {
    if (rating != null && (rating < 0 || rating > 5)) {
      throw ArgumentError('Рейтинг должен быть от 0 до 5');
    }
  }

  String get shortTitle =>
      title.length > 20 ? '${title.substring(0, 17)}...' : title;
  double get readingHours => pages / 50.0;
  int get age => DateTime.now().year - year;
  bool get isRated => _rating != null;

  double? get rating => _rating;
  set rating(double? value) {
    if (value != null && (value < 0 || value > 5)) {
      throw ArgumentError('Рейтинг должен быть от 0 до 5');
    }
    _rating = value;
  }

  @override
  String describe() {
    return '«$title» — $author, $year, $pages стр., жанры: ${genres.join(", ")}, статус: ${status.label}';
  }
}

class PaperBook extends Book {
  final int shelf;
  bool isBorrowed = false;

  PaperBook({
    required super.title,
    required super.author,
    required this.shelf,
    super.year,
    super.pages,
    super.genres,
    super.status,
    super.rating,
  });

  @override
  String describe() {
    return '«$title» (бумажная) — $author, полка $shelf, статус: ${status.label}';
  }
}

class EBook extends Book {
  final String format;
  final double sizeMb;

  EBook({
    required super.title,
    required super.author,
    required this.format,
    required this.sizeMb,
    super.year,
    super.pages,
    super.genres,
    super.status,
    super.rating,
  });

  @override
  String describe() {
    return '«$title» (электронная) — $author, формат $format, $sizeMb МБ, статус: ${status.label}';
  }
}

class AudioBook extends Book {
  final Duration duration;
  final String narrator;

  AudioBook({
    required super.title,
    required super.author,
    required this.duration,
    required this.narrator,
    super.year,
    super.pages,
    super.genres,
    super.status,
    super.rating,
  });

  @override
  double get readingHours => duration.inMinutes / 60.0;

  @override
  String describe() {
    return '«$title» (аудио) — $author, читает $narrator, ${duration.inMinutes} мин., статус: ${status.label}';
  }
}

final List<Book> library = <Book>[
  PaperBook(
    title: 'Основы Dart',
    author: 'С. А. Чернышев',
    year: 2024,
    pages: 521,
    genres: {'учебник'},
    status: ReadingStatus.finished,
    shelf: 1,
  ),
  EBook(
    title: 'Flutter на практике',
    author: 'Ф. Заметти',
    year: 2020,
    pages: 328,
    genres: {'учебник'},
    status: ReadingStatus.planned,
    format: 'PDF',
    sizeMb: 15.5,
  ),
  PaperBook(
    title: 'Мастер и Маргарита',
    author: 'М. А. Булгаков',
    year: 1967,
    pages: 480,
    genres: {'роман'},
    status: ReadingStatus.finished,
    shelf: 2,
  ),
  Book(
    title: '1984',
    author: 'Дж. Оруэлл',
    year: 1949,
    pages: 320,
    genres: {'фантастика'},
    status: ReadingStatus.finished,
  ),
  Book(
    title: 'Преступление и наказание',
    author: 'Ф. М. Достоевский',
    year: 1866,
    pages: 671,
    genres: {'роман'},
    status: ReadingStatus.planned,
  ),
  Book(
    title: 'Дюна',
    author: 'Ф. Герберт',
    year: 1965,
    pages: 512,
    genres: {'фантастика'},
    status: ReadingStatus.reading,
  ),
  AudioBook(
    title: 'Краткая история времени',
    author: 'С. Хокинг',
    year: 1988,
    pages: 256,
    genres: {'научпоп'},
    status: ReadingStatus.finished,
    duration: Duration(hours: 6, minutes: 30),
    narrator: 'И. Иванов',
  ),
  Book(
    title: 'Убийство в «Восточном экспрессе»',
    author: 'А. Кристи',
    year: 1934,
    pages: 288,
    genres: {'детектив'},
    status: ReadingStatus.finished,
  ),
  Book(
    title: 'Гарри Поттер и философский камень',
    author: 'Дж. Роулинг',
    year: 1997,
    pages: 410,
    genres: {'фантастика'},
    status: ReadingStatus.finished,
  ),
  Book(
    title: 'Код да Винчи',
    author: 'Д. Браун',
    year: 2003,
    pages: 542,
    genres: {'детектив'},
    status: ReadingStatus.abandoned,
  ),
];

String readLine() => (stdin.readLineSync(encoding: utf8) ?? '').trim();

int askInt(String prompt, {int min = 0, int? max}) {
  int? value;
  do {
    stdout.write('$prompt: ');
    value = int.tryParse(readLine());
    if (value == null || value < min || (max != null && value > max)) {
      print(
        'Некорректное значение. Ожидается целое число'
        '${max == null ? ' не меньше $min' : ' от $min до $max'}.',
      );
      value = null;
    }
  } while (value == null);
  return value;
}

void printAll(List<Book> books, {String emptyMessage = 'Ничего не найдено.'}) {
  if (books.isEmpty) {
    print(emptyMessage);
    return;
  }
  print('-' * 78);
  for (int i = 0; i < books.length; i++) {
    final Book b = books[i];
    final String mark = b.status.isDone ? '[x]' : '[ ]';
    final String num = (i + 1).toString().padLeft(2);
    print('$num. $mark ${b.describe()}');
  }
  print('-' * 78);
}

List<Book> searchByField(List<Book> books, String field, String query) {
  final String q = query.toLowerCase();
  return books.where((Book b) {
    switch (field) {
      case 'title':
        return b.title.toLowerCase().contains(q);
      case 'author':
        return b.author.toLowerCase().contains(q);
      case 'genre':
        return b.genres.any((g) => g.toLowerCase().contains(q));
      default:
        return false;
    }
  }).toList();
}

List<Book> filterByRead(List<Book> books, bool isRead) {
  return books.where((Book b) => b.status.isDone == isRead).toList();
}

List<Book> sortBy(List<Book> books, String field, {bool descending = false}) {
  final List<Book> copy = <Book>[...books];
  copy.sort((Book a, Book b) {
    int cmp;
    switch (field) {
      case 'title':
        cmp = a.title.compareTo(b.title);
        break;
      case 'author':
        cmp = a.author.compareTo(b.author);
        break;
      case 'year':
        cmp = a.year.compareTo(b.year);
        break;
      case 'pages':
        cmp = a.pages.compareTo(b.pages);
        break;
      default:
        cmp = 0;
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
  final int readCount = books.where((Book b) => b.status.isDone).length;
  final int totalPages = books.fold<int>(0, (int s, Book b) => s + b.pages);
  final double avgPages = totalPages / total;
  final Book oldest = books.reduce(
    (Book a, Book b) => a.year <= b.year ? a : b,
  );
  final Book newest = books.reduce(
    (Book a, Book b) => a.year >= b.year ? a : b,
  );
  final Book thickest = books.reduce(
    (Book a, Book b) => a.pages >= b.pages ? a : b,
  );

  final Set<String> genres = books.expand((Book b) => b.genres).toSet();
  final Map<String, int> byGenre = {};
  for (final String g in genres) {
    byGenre[g] = books.where((Book b) => b.genres.contains(g)).length;
  }

  final double readPercent = readCount / total * 100;

  print('=' * 50);
  print('СТАТИСТИКА КАТАЛОГА');
  print('=' * 50);
  print('Всего книг:              $total');
  print('Прочитано:               $readCount');
  print('Суммарно страниц:        $totalPages');
  print('Среднее страниц:         ${avgPages.toStringAsFixed(1)}');
  print('Самая старая:            «${oldest.title}» (${oldest.year})');
  print('Самая новая:             «${newest.title}» (${newest.year})');
  print(
    'Самая объёмная:          «${thickest.title}» (${thickest.pages} стр.)',
  );
  print('Уникальные жанры:        $genres');
  print('Книг по жанрам:          $byGenre');
  print('Доля прочитанного:       ${readPercent.toStringAsFixed(1)}%');
  print('=' * 50);
}

void addBook() {
  stdout.write('Название: ');
  final String title = readLine();
  if (title.isEmpty) {
    print('Название не может быть пустым. Добавление отменено.');
    return;
  }

  stdout.write('Автор: ');
  final String author = readLine();
  final int year = askInt('Год издания', min: 0, max: 2100);
  final int pages = askInt('Количество страниц', min: 1);

  stdout.write('Жанры (через запятую): ');
  final String genresRaw = readLine();
  final Set<String> genres = genresRaw
      .split(',')
      .map((g) => g.trim())
      .where((g) => g.isNotEmpty)
      .toSet();

  stdout.write('Статус (planned / reading / finished / abandoned): ');
  final String statusName = readLine();
  final ReadingStatus status = ReadingStatus.fromName(statusName);

  library.add(
    Book(
      title: title,
      author: author,
      year: year,
      pages: pages,
      genres: genres,
      status: status,
    ),
  );
  print('Книга «$title» успешно добавлена.');
}

void removeBook() {
  if (library.isEmpty) {
    print('Каталог пуст. Удалять нечего.');
    return;
  }
  printAll(library);
  final int index =
      askInt('Введите номер книги для удаления', min: 1, max: library.length) -
      1;
  final Book b = library[index];

  stdout.write('Удалить книгу «${b.title}»? (да/нет): ');
  final String confirm = readLine().toLowerCase();
  if (confirm == 'да' || confirm == '+') {
    library.removeAt(index);
    print('Книга удалена.');
  } else {
    print('Удаление отменено.');
  }
}

typedef BookPredicate = bool Function(Book book);

List<Book> filter(List<Book> books, BookPredicate test) {
  return books.where(test).toList();
}

Function makeCounter() {
  int count = 0;
  return () {
    count++;
    return count;
  };
}

void demoHigherOrder() {
  print('\n--- 1. Толстые книги (страниц > 400) ---');
  final List<Book> thickBooks = filter(library, (Book b) => b.pages > 400);
  printAll(thickBooks, emptyMessage: 'Таких книг нет.');

  print('\n--- 2. Книги нового века (год >= 2000) ---');
  final List<Book> newCentury = filter(library, (Book b) => b.year >= 2000);
  printAll(newCentury, emptyMessage: 'Таких книг нет.');

  print('\n--- 3. Непрочитанные книги выбранного жанра ---');
  stdout.write('Введите жанр: ');
  final String genre = readLine().toLowerCase();
  final List<Book> unreadGenre = filter(
    library,
    (Book b) =>
        b.genres.map((g) => g.toLowerCase()).contains(genre) &&
        !b.status.isDone,
  );
  printAll(unreadGenre, emptyMessage: 'Таких книг нет.');
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
  print('10 - Демонстрация функций высшего порядка');
  print('0 - Выход');
  stdout.write('> ');
}

void main() {
  stdout.encoding = utf8;
  stderr.encoding = utf8;

  bool running = true;
  final Function counter = makeCounter();
  int executedCommands = 0;

  while (running) {
    printMenu();
    final String choice = readLine();

    switch (choice) {
      case '1':
        printAll(library);
        break;
      case '2':
        stdout.write('Автор: ');
        printAll(
          searchByField(library, 'author', readLine()),
          emptyMessage: 'По автору ничего не найдено.',
        );
        break;
      case '3':
        stdout.write('Название: ');
        printAll(
          searchByField(library, 'title', readLine()),
          emptyMessage: 'По названию ничего не найдено.',
        );
        break;
      case '4':
        stdout.write('Жанр: ');
        printAll(
          searchByField(library, 'genre', readLine()),
          emptyMessage: 'Жанр не найден.',
        );
        break;
      case '5':
        stdout.write('Показать прочитанные? (да/нет): ');
        final bool isRead = readLine().toLowerCase() == 'да';
        printAll(filterByRead(library, isRead));
        break;
      case '6':
        stdout.write('Поле (title/author/year/pages): ');
        final String field = readLine();
        const Set<String> valid = <String>{'title', 'author', 'year', 'pages'};
        if (!valid.contains(field)) {
          print('Неизвестное поле: «$field».');
          break;
        }
        stdout.write('По убыванию? (да/нет): ');
        final bool desc = readLine().toLowerCase() == 'да';
        printAll(sortBy(library, field, descending: desc));
        break;
      case '7':
        printStatistics(library);
        break;
      case '8':
        addBook();
        break;
      case '9':
        removeBook();
        break;
      case '10':
        demoHigherOrder();
        break;
      case '0':
        running = false;
        continue;
      default:
        print('Неизвестная команда. Повторите ввод.');
        continue;
    }
    executedCommands = counter() as int;
  }
  print('Работа завершена. Выполнено команд за сессию: $executedCommands');
}
