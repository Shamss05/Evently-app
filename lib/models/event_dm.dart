import 'package:cloud_firestore/cloud_firestore.dart';

import 'category_dm.dart';

class EventDm {
  String id;
  String title;
  String description;
  int date;
  int time;
  CategoryDm category;
  List<String> favoriteUsers;
  String userId;

  EventDm({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.category,
    this.favoriteUsers = const [],
    this.userId = "",
  });

  factory EventDm.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final categoryId = (data["categoryId"] as num?)?.toInt();
    return EventDm(
      id: snapshot.id,
      title: (data["title"] as String?) ?? "",
      description: (data["description"] as String?) ?? "",
      date: (data["date"] as num?)?.toInt() ?? 0,
      time: (data["time"] as num?)?.toInt() ?? 0,
      userId: (data["userId"] as String?) ?? "",
      favoriteUsers: ((data["favoriteUsers"] ?? []) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      category: categoriesList.firstWhere(
        (e) => e.id == categoryId,
        orElse: () => categoriesList.first,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "date": date,
      "time": time,
      "categoryId": category.id,
      "favoriteUsers": List<String>.from(favoriteUsers),
      "userId": userId,
    };
  }
}
