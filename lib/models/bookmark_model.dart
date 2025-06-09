import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkModel {
  final String movieId;
  final DateTime createdOn;

  BookmarkModel({required this.movieId, required this.createdOn});

  factory BookmarkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookmarkModel(
      movieId: doc.id,
      createdOn: data['addedOn']?.toDate() ?? DateTime.now(),
    );
  }
}
