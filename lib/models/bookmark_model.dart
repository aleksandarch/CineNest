import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 1)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  final String movieId;

  @HiveField(1)
  final DateTime createdOn;

  BookmarkModel({required this.movieId, required this.createdOn});

  factory BookmarkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookmarkModel(
      movieId: doc.id,
      createdOn: data['addedOn']?.toDate() ?? DateTime.now(),
    );
  }

  BookmarkModel.empty()
      : movieId = '',
        createdOn = DateTime.now();
}
