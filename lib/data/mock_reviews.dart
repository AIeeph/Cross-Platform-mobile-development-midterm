import '../models/review.dart';

final Map<String, List<Review>> mockReviews = {
  '1': [
    Review(author: 'Nika', comment: 'Легендарный фильм, Джокер шикарный.', rating: 5, createdAt: DateTime(2026, 4, 2)),
    Review(author: 'Alex', comment: 'Best superhero movie ever made.', rating: 5, createdAt: DateTime(2026, 4, 1)),
    Review(author: 'Mira', comment: 'Атмосфера Готэма просто идеальна.', rating: 5, createdAt: DateTime(2026, 3, 29)),
    Review(author: 'Daniel', comment: 'Heath Ledger performance is unforgettable.', rating: 5, createdAt: DateTime(2026, 3, 25)),
    Review(author: 'Aidos', comment: 'Сюжет держит в напряжении до конца.', rating: 4, createdAt: DateTime(2026, 3, 21)),
  ],
  '2': [
    Review(author: 'Arman', comment: 'Сюжет сложный, но очень затягивает.', rating: 5, createdAt: DateTime(2026, 4, 1)),
    Review(author: 'Sofia', comment: 'Mind-bending and visually stunning.', rating: 5, createdAt: DateTime(2026, 3, 30)),
    Review(author: 'Timur', comment: 'Нужно пересматривать, чтобы все понять.', rating: 5, createdAt: DateTime(2026, 3, 27)),
    Review(author: 'Chris', comment: 'Amazing concept and excellent score.', rating: 4, createdAt: DateTime(2026, 3, 22)),
    Review(author: 'Alya', comment: 'Очень стильный и умный фильм.', rating: 5, createdAt: DateTime(2026, 3, 19)),
  ],
  '3': [
    Review(author: 'Dana', comment: 'Эмоционально и визуально мощно.', rating: 5, createdAt: DateTime(2026, 3, 28)),
    Review(author: 'Noah', comment: 'A beautiful story about love and time.', rating: 5, createdAt: DateTime(2026, 3, 27)),
    Review(author: 'Rauan', comment: 'Музыка Ханса Циммера невероятная.', rating: 5, createdAt: DateTime(2026, 3, 24)),
    Review(author: 'Emma', comment: 'Science and emotion balanced perfectly.', rating: 4, createdAt: DateTime(2026, 3, 20)),
    Review(author: 'Zhanar', comment: 'Очень трогательный финал.', rating: 5, createdAt: DateTime(2026, 3, 16)),
  ],
  '4': [
    Review(author: 'Maks', comment: 'Эпик и масштаб на максимуме.', rating: 5, createdAt: DateTime(2026, 4, 5)),
    Review(author: 'Oliver', comment: 'The world-building is next level.', rating: 5, createdAt: DateTime(2026, 4, 3)),
    Review(author: 'Amina', comment: 'Сцены пустыни выглядят потрясающе.', rating: 5, createdAt: DateTime(2026, 4, 1)),
    Review(author: 'Liam', comment: 'Great sequel with strong pacing.', rating: 4, createdAt: DateTime(2026, 3, 28)),
    Review(author: 'Bek', comment: 'Один из лучших фильмов года.', rating: 5, createdAt: DateTime(2026, 3, 24)),
  ],
  '5': [
    Review(author: 'Aruzhan', comment: 'Атмосфера 80-х и мистерия топ.', rating: 4, createdAt: DateTime(2026, 3, 30)),
    Review(author: 'Mason', comment: 'Great cast chemistry and suspense.', rating: 5, createdAt: DateTime(2026, 3, 29)),
    Review(author: 'Yana', comment: 'Каждый сезон держит интригу.', rating: 5, createdAt: DateTime(2026, 3, 25)),
    Review(author: 'Leo', comment: 'Nostalgic and thrilling at the same time.', rating: 4, createdAt: DateTime(2026, 3, 22)),
    Review(author: 'Samat', comment: 'Сильный сериал, особенно первые сезоны.', rating: 4, createdAt: DateTime(2026, 3, 17)),
  ],
  '6': [
    Review(author: 'Temir', comment: 'Один из лучших сериалов вообще.', rating: 5, createdAt: DateTime(2026, 4, 6)),
    Review(author: 'Ethan', comment: 'Perfect character development.', rating: 5, createdAt: DateTime(2026, 4, 4)),
    Review(author: 'Kamila', comment: 'Игра актеров просто на высоте.', rating: 5, createdAt: DateTime(2026, 4, 1)),
    Review(author: 'Logan', comment: 'Dark, intense, and brilliantly written.', rating: 5, createdAt: DateTime(2026, 3, 28)),
    Review(author: 'Madi', comment: 'Сюжет затягивает с первой серии.', rating: 5, createdAt: DateTime(2026, 3, 23)),
  ],
  '7': [
    Review(author: 'Aliya', comment: 'Классика фэнтези, интриги супер.', rating: 5, createdAt: DateTime(2026, 3, 27)),
    Review(author: 'Grace', comment: 'Massive world and unforgettable characters.', rating: 5, createdAt: DateTime(2026, 3, 24)),
    Review(author: 'Nurlan', comment: 'Политика и драма очень сильные.', rating: 4, createdAt: DateTime(2026, 3, 20)),
    Review(author: 'Henry', comment: 'Early seasons are absolute peak TV.', rating: 5, createdAt: DateTime(2026, 3, 16)),
    Review(author: 'Dina', comment: 'Эпичный сериал, пересматриваю снова.', rating: 5, createdAt: DateTime(2026, 3, 13)),
  ],
  '8': [
    Review(author: 'Ruslan', comment: 'Очень сильная драма и актеры.', rating: 5, createdAt: DateTime(2026, 4, 4)),
    Review(author: 'Isla', comment: 'Powerful adaptation with great tension.', rating: 5, createdAt: DateTime(2026, 4, 1)),
    Review(author: 'Saltanat', comment: 'Атмосфера постапокалипсиса огонь.', rating: 4, createdAt: DateTime(2026, 3, 29)),
    Review(author: 'Jack', comment: 'Emotionally heavy in the best way.', rating: 5, createdAt: DateTime(2026, 3, 25)),
    Review(author: 'Adil', comment: 'Сильный старт и отличные персонажи.', rating: 4, createdAt: DateTime(2026, 3, 21)),
  ],
  '9': [
    Review(author: 'Zarina', comment: 'Легко смотрится, стиль отличный.', rating: 4, createdAt: DateTime(2026, 4, 3)),
    Review(author: 'Ella', comment: 'Fun, quirky and very bingeable.', rating: 4, createdAt: DateTime(2026, 3, 31)),
    Review(author: 'Aibek', comment: 'Харизматичная главная героиня.', rating: 4, createdAt: DateTime(2026, 3, 28)),
    Review(author: 'Lucas', comment: 'Dark comedy with cool visuals.', rating: 4, createdAt: DateTime(2026, 3, 24)),
    Review(author: 'Malika', comment: 'Интересный микс мистики и юмора.', rating: 4, createdAt: DateTime(2026, 3, 20)),
  ],
  '10': [
    Review(author: 'Sanzhar', comment: 'Финал эпохи Marvel, очень мощно.', rating: 5, createdAt: DateTime(2026, 4, 7)),
    Review(author: 'Mia', comment: 'Epic conclusion and emotional payoff.', rating: 5, createdAt: DateTime(2026, 4, 5)),
    Review(author: 'Erkebulan', comment: 'Битва в финале невероятная.', rating: 5, createdAt: DateTime(2026, 4, 2)),
    Review(author: 'Jacob', comment: 'Fan service done right.', rating: 4, createdAt: DateTime(2026, 3, 29)),
    Review(author: 'Aigerim', comment: 'Сильная кульминация всей саги.', rating: 5, createdAt: DateTime(2026, 3, 25)),
  ],
};
