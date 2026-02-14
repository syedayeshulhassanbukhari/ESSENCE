class FragellaFragrance {
  const FragellaFragrance({
    required this.name,
    required this.brand,
    required this.year,
    required this.rating,
    required this.country,
    required this.popularity,
    required this.priceValue,
    required this.confidence,
    required this.imageUrl,
    required this.gender,
    required this.price,
    required this.longevity,
    required this.sillage,
    required this.oilType,
    required this.generalNotes,
    required this.mainAccords,
    required this.mainAccordsPercentage,
    required this.notes,
    required this.imageFallbacks,
    required this.purchaseUrl,
    required this.seasonRanking,
    required this.occasionRanking,
  });

  final String name;
  final String brand;
  final String year;
  final String rating;
  final String country;
  final String popularity;
  final String priceValue;
  final String confidence;
  final String imageUrl;
  final String gender;
  final String price;
  final String longevity;
  final String sillage;
  final String oilType;
  final List<String> generalNotes;
  final List<String> mainAccords;
  final Map<String, String> mainAccordsPercentage;
  final FragellaNotes notes;
  final List<String> imageFallbacks;
  final String purchaseUrl;
  final List<FragellaRanking> seasonRanking;
  final List<FragellaRanking> occasionRanking;

  factory FragellaFragrance.fromJson(Map<String, dynamic> json) {
    return FragellaFragrance(
      name: _string(json['Name']),
      brand: _string(json['Brand']),
      year: _string(json['Year']),
      rating: _string(json['rating']),
      country: _string(json['Country']),
      popularity: _string(json['Popularity']),
      priceValue: _string(json['Price Value']),
      confidence: _string(json['Confidence']),
      imageUrl: _string(json['Image URL']),
      gender: _string(json['Gender']),
      price: _string(json['Price']),
      longevity: _string(json['Longevity']),
      sillage: _string(json['Sillage']),
      oilType: _string(json['OilType']),
      generalNotes: _stringList(json['General Notes']),
      mainAccords: _stringList(json['Main Accords']),
      mainAccordsPercentage: _stringMap(json['Main Accords Percentage']),
      notes: FragellaNotes.fromJson(json['Notes']),
      imageFallbacks: _stringList(json['Image Fallbacks']),
      purchaseUrl: _string(json['Purchase URL']),
      seasonRanking: _rankingList(json['Season Ranking']),
      occasionRanking: _rankingList(json['Occasion Ranking']),
    );
  }

  static String _string(dynamic value) {
    return value is String ? value : '';
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  static Map<String, String> _stringMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(
            key.toString(),
            val is String ? val : val.toString(),
          ));
    }
    return const {};
  }

  static List<FragellaRanking> _rankingList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(FragellaRanking.fromJson)
          .toList();
    }
    return const [];
  }
}

class FragellaNotes {
  const FragellaNotes({
    required this.top,
    required this.middle,
    required this.base,
  });

  final List<FragellaNote> top;
  final List<FragellaNote> middle;
  final List<FragellaNote> base;

  factory FragellaNotes.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const FragellaNotes(top: [], middle: [], base: []);
    }

    return FragellaNotes(
      top: _noteList(json['Top']),
      middle: _noteList(json['Middle']),
      base: _noteList(json['Base']),
    );
  }

  static List<FragellaNote> _noteList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(FragellaNote.fromJson)
          .toList();
    }
    return const [];
  }
}

class FragellaNote {
  const FragellaNote({
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String imageUrl;

  factory FragellaNote.fromJson(Map<String, dynamic> json) {
    return FragellaNote(
      name: json['name'] is String ? json['name'] as String : '',
      imageUrl: json['imageUrl'] is String ? json['imageUrl'] as String : '',
    );
  }
}

class FragellaRanking {
  const FragellaRanking({
    required this.name,
    required this.score,
  });

  final String name;
  final double score;

  factory FragellaRanking.fromJson(Map<String, dynamic> json) {
    final rawScore = json['score'];
    final score = rawScore is num ? rawScore.toDouble() : 0.0;
    return FragellaRanking(
      name: json['name'] is String ? json['name'] as String : '',
      score: score,
    );
  }
}
