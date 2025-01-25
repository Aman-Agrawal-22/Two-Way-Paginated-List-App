class Item {
  final int id;
  final String title;

  Item({required this.id, required this.title});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  Item copyWith({int? id, String? title}) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  @override
  String toString() {
    return 'Item{id: $id, title: $title}';
  }
}
