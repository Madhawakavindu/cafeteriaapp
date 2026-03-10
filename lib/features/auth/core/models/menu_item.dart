class MenuItem {
  final String id;
  final String mainFood;
  final List<String> vegetables;
  final String mealType;
  final String date;

  MenuItem({
    required this.id,
    required this.mainFood,
    required this.vegetables,
    required this.mealType,
    required this.date,
  });

  MenuItem copyWith({
    String? id,
    String? mainFood,
    List<String>? vegetables,
    String? mealType,
    String? date,
  }) {
    return MenuItem(
      id: id ?? this.id,
      mainFood: mainFood ?? this.mainFood,
      vegetables: vegetables ?? this.vegetables,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
    );
  }
}
