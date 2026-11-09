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

abstract interface class Searchable {
  bool matches(String query);
}

abstract interface class Exportable {
  Map<String, dynamic> toJson();
}

abstract class LibraryItem {
  String get title;
  String describe();
  void printCard() {
    print(describe());
  }
}

class Book extends LibraryItem
    implements Searchable, Exportable, Comparable<Book> {
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
  bool matches(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        author.toLowerCase().contains(q) ||
        genres.any((g) => g.toLowerCase().contains(q));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'Book',
      'title': title,
      'author': author,
      'year': year,
      'pages': pages,
      'genres': genres.toList(),
      'status': status.name,
      'rating': _rating,
    };
  }

  @override
  String describe() {
    return '«$title» — $author, $year, $pages стр., жанры: ${genres.join(", ")}, статус: ${status.label}';
  }

  @override
  String toString() => '«$shortTitle» ($author, $year)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          title == other.title &&
          author == other.author &&
          year == other.year;

  @override
  int get hashCode => Object.hash(title, author, year);

  @override
  int compareTo(Book other) => title.compareTo(other.title);

  Book copyWith({
    String? title,
    String? author,
    int? year,
    int? pages,
    Set<String>? genres,
    ReadingStatus? status,
    double? rating,
  }) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      rating: rating ?? this.rating,
    );
  }
}

mixin Rateable {
  double _ratingSum = 0;
  int _ratingCount = 0;

  double get averageRating =>
      _ratingCount == 0 ? 0.0 : _ratingSum / _ratingCount;

  void vote(double rating) {
    if (rating >= 0 && rating <= 5) {
      _ratingSum += rating;
      _ratingCount++;
    } else {
      print('Оценка должна быть от 0 до 5.');
    }
  }
}

mixin Loggable {
  void log(String message) {
    final now = DateTime.now();
    print(
      '[${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}] $message',
    );
  }
}

mixin Borrowable on Book {
  DateTime? _dueDate;

  bool get isBorrowed => _dueDate != null;

  void borrow(int days) {
    _dueDate = DateTime.now().add(Duration(days: days));
    print(
      'Книга «$title» выдана на $days дней. Вернуть до: ${_dueDate.toString().split(' ')[0]}',
    );
  }

  void giveBack() {
    _dueDate = null;
    print('Книга «$title» возвращена.');
  }
}

class PaperBook extends Book with Rateable, Loggable, Borrowable {
  final int shelf;

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
    final borrowedStr = isBorrowed ? ' [Выдана]' : '';
    return '«$title» (бумажная) — $author, полка $shelf, статус: ${status.label}$borrowedStr';
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['type'] = 'PaperBook';
    map['shelf'] = shelf;
    map['isBorrowed'] = isBorrowed;
    return map;
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

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['type'] = 'EBook';
    map['format'] = format;
    map['sizeMb'] = sizeMb;
    return map;
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

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['type'] = 'AudioBook';
    map['durationMinutes'] = duration.inMinutes;
    map['narrator'] = narrator;
    return map;
  }
}

class Library<T extends LibraryItem> {
  final List<T> _items = [];

  List<T> get items => List.unmodifiable(_items);
  int get count => _items.length;

  void add(T item) {
    if (!_items.contains(item)) {
      _items.add(item);
    } else {
      print('Предмет уже существует в библиотеке (дубликат).');
    }
  }

  bool remove(T item) => _items.remove(item);

  T? findByTitle(String title) {
    try {
      return _items.firstWhere((item) => item.title == title);
    } catch (_) {
      return null;
    }
  }

  Iterable<T> search(String query) {
    return _items.where(
      (item) => item is Searchable && (item as Searchable).matches(query),
    );
  }

  Iterable<T> where(bool Function(T test) predicate) {
    return _items.where(predicate);
  }

  Map<String, int> countByGenre() {
    final Map<String, int> result = {};
    for (final item in _items) {
      if (item is Book) {
        for (final genre in item.genres) {
          result[genre] = (result[genre] ?? 0) + 1;
        }
      }
    }
    return result;
  }
}

final Library<Book> library = Library<Book>()
  ..add(
    PaperBook(
      title: 'Основы Dart',
      author: 'С. А. Чернышев',
      year: 2024,
      pages: 521,
      genres: {'учебник'},
      status: ReadingStatus.finished,
      shelf: 1,
    ),
  )
  ..add(
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
  )
  ..add(
    PaperBook(
      title: 'Мастер и Маргарита',
      author: 'М. А. Булгаков',
      year: 1967,
      pages: 480,
      genres: {'роман'},
      status: ReadingStatus.finished,
      shelf: 2,
    ),
  )
  ..add(
    Book(
      title: '1984',
      author: 'Дж. Оруэлл',
      year: 1949,
      pages: 320,
      genres: {'фантастика'},
      status: ReadingStatus.finished,
    ),
  )
  ..add(
    Book(
      title: 'Преступление и наказание',
      author: 'Ф. М. Достоевский',
      year: 1866,
      pages: 671,
      genres: {'роман'},
      status: ReadingStatus.planned,
    ),
  )
  ..add(
    Book(
      title: 'Дюна',
      author: 'Ф. Герберт',
      year: 1965,
      pages: 512,
      genres: {'фантастика'},
      status: ReadingStatus.reading,
    ),
  )
  ..add(
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
  )
  ..add(
    Book(
      title: 'Убийство в «Восточном экспрессе»',
      author: 'А. Кристи',
      year: 1934,
      pages: 288,
      genres: {'детектив'},
      status: ReadingStatus.finished,
    ),
  )
  ..add(
    Book(
      title: 'Гарри Поттер и философский камень',
      author: 'Дж. Роулинг',
      year: 1997,
      pages: 410,
      genres: {'фантастика'},
      status: ReadingStatus.finished,
    ),
  )
  ..add(
    Book(
      title: 'Код да Винчи',
      author: 'Д. Браун',
      year: 2003,
      pages: 542,
      genres: {'детектив'},
      status: ReadingStatus.abandoned,
    ),
  );

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

void printStatistics(Library<Book> lib) {
  final books = lib.items;
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

  final Map<String, int> byGenre = lib.countByGenre();
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
  print('Книг по жанрам:          $byGenre');
  print('Доля прочитанного:       ${readPercent.toStringAsFixed(1)}%');
  print('=' * 50);
}

void addBook() {
  stdout.write('Название: ');
  final String title = readLine();
  if (title.isEmpty) {
    print('Название не может быть пустым. Отменено.');
    return;
  }

  stdout.write('Автор: ');
  final String author = readLine();
  final int year = askInt('Год издания', min: 0, max: 2100);
  final int pages = askInt('Количество страниц', min: 1);

  stdout.write('Жанры (через запятую): ');
  final Set<String> genres = readLine()
      .split(',')
      .map((g) => g.trim())
      .where((g) => g.isNotEmpty)
      .toSet();

  stdout.write('Статус (planned / reading / finished / abandoned): ');
  final ReadingStatus status = ReadingStatus.fromName(readLine());

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
  if (library.count == 0) {
    print('Каталог пуст.');
    return;
  }
  final items = library.items.toList();
  printAll(items);
  final int index =
      askInt('Номер книги для удаления', min: 1, max: library.count) - 1;
  final Book b = items[index];

  stdout.write('Удалить книгу «${b.title}»? (да/нет): ');
  final String confirm = readLine().toLowerCase();
  if (confirm == 'да' || confirm == '+') {
    library.remove(b);
    print('Книга удалена.');
  } else {
    print('Отменено.');
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
  final books = library.items.toList();
  print('\n 1. Толстые книги (страниц > 400) ');
  printAll(filter(books, (Book b) => b.pages > 400), emptyMessage: 'Нет.');

  print('\n 2. Книги нового века (год >= 2000) ');
  printAll(filter(books, (Book b) => b.year >= 2000), emptyMessage: 'Нет.');

  print('\n 3. Непрочитанные книги выбранного жанра ---');
  stdout.write('Введите жанр: ');
  final String genre = readLine().toLowerCase();
  printAll(
    filter(
      books,
      (Book b) =>
          b.genres.map((g) => g.toLowerCase()).contains(genre) &&
          !b.status.isDone,
    ),
    emptyMessage: 'Нет.',
  );
}

void demoInterfacesAndMixins() {
  print('\n 1. Интерфейс Searchable ');
  printAll(library.search('Дарт').toList(), emptyMessage: 'Совпадений нет.');

  print('\n 2. Интерфейс Exportable ');
  final EBook ebook = library.items.whereType<EBook>().first;
  print(ebook.toJson());

  print('\n 3. Миксины на бумажной книге ');
  final PaperBook paper = library.items.whereType<PaperBook>().first;
  paper.borrow(14);
  paper.log('Статус на руках: ${paper.isBorrowed}');
  paper.giveBack();
  paper.log('Статус на руках: ${paper.isBorrowed}');

  print('\n 4. Миксин Rateable ');
  paper.vote(4.5);
  paper.vote(5.0);
  paper.vote(3.5);
  print('Средняя оценка: ${paper.averageRating.toStringAsFixed(1)}');
}

void demoSpecialMethods() {
  print('\n 1. Демонстрация ==, hashCode и Set ');
  final b1 = Book(title: 'Дюна', author: 'Ф. Герберт', year: 1965);
  final b2 = Book(title: 'Дюна', author: 'Ф. Герберт', year: 1965);
  print('b1 == b2: ${b1 == b2}');
  final set = <Book>{b1, b2};
  print('Размер Set (должен быть 1): ${set.length}');

  print('\n 2. Демонстрация Comparable и sort() ');
  final books = library.items.toList();
  books.sort();
  print('Отсортировано по названию:');
  for (final b in books) {
    print(' - ${b.title}');
  }

  print('\n 3. Демонстрация copyWith ');
  final original = Book(title: 'Оригинал', author: 'Автор', year: 2000);
  final copy = original.copyWith(title: 'Копия', year: 2024);
  print('Оригинал: $original');
  print('Копия:    $copy');

  print('\n 4. Демонстрация findByTitle ');
  final found = library.findByTitle('1984');
  print('Найдено: ${found?.describe() ?? "не найдено"}');
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
  print('11 - Демонстрация интерфейсов и миксинов');
  print('12 - Демонстрация спец. методов (==, sort, copyWith)');
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
        printAll(library.items.toList());
        break;
      case '2':
        stdout.write('Автор: ');
        final qAuthor = readLine().toLowerCase();
        printAll(
          library
              .where((b) => b.author.toLowerCase().contains(qAuthor))
              .toList(),
          emptyMessage: 'Не найдено.',
        );
        break;
      case '3':
        stdout.write('Название: ');
        final qTitle = readLine().toLowerCase();
        printAll(
          library.where((b) => b.title.toLowerCase().contains(qTitle)).toList(),
          emptyMessage: 'Не найдено.',
        );
        break;
      case '4':
        stdout.write('Жанр: ');
        final qGenre = readLine().toLowerCase();
        printAll(
          library
              .where(
                (b) => b.genres.any((g) => g.toLowerCase().contains(qGenre)),
              )
              .toList(),
          emptyMessage: 'Не найдено.',
        );
        break;
      case '5':
        stdout.write('Показать прочитанные? (да/нет): ');
        final bool isRead = readLine().toLowerCase() == 'да';
        printAll(library.where((b) => b.status.isDone == isRead).toList());
        break;
      case '6':
        stdout.write('Поле (title/author/year/pages): ');
        final String field = readLine();
        const Set<String> valid = <String>{'title', 'author', 'year', 'pages'};
        if (!valid.contains(field)) {
          print('Неверное поле.');
          break;
        }
        stdout.write('По убыванию? (да/нет): ');
        final bool desc = readLine().toLowerCase() == 'да';
        final listToSort = library.items.toList();
        listToSort.sort((Book a, Book b) {
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
          return desc ? -cmp : cmp;
        });
        printAll(listToSort);
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
      case '11':
        demoInterfacesAndMixins();
        break;
      case '12':
        demoSpecialMethods();
        break;
      case '0':
        running = false;
        continue;
      default:
        print('Неизвестная команда.');
        continue;
    }
    executedCommands = counter() as int;
  }
  print('Работа завершена. Выполнено команд за сессию: $executedCommands');
}
