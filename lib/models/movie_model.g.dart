// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieModelAdapter extends TypeAdapter<MovieModel> {
  @override
  final int typeId = 0;

  @override
  MovieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieModel(
      id: fields[0] as String,
      title: fields[1] as String,
      year: fields[2] as String,
      genres: (fields[3] as List).cast<String>(),
      ratings: (fields[4] as List).cast<int>(),
      posterUrl: fields[5] as String,
      contentRating: fields[6] as String?,
      duration: fields[7] as String?,
      releaseDate: fields[8] as String,
      originalTitle: fields[9] as String?,
      storyline: fields[10] as String,
      actors: (fields[11] as List).cast<String>(),
      imdbRating: fields[12] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MovieModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.genres)
      ..writeByte(4)
      ..write(obj.ratings)
      ..writeByte(5)
      ..write(obj.posterUrl)
      ..writeByte(6)
      ..write(obj.contentRating)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.releaseDate)
      ..writeByte(9)
      ..write(obj.originalTitle)
      ..writeByte(10)
      ..write(obj.storyline)
      ..writeByte(11)
      ..write(obj.actors)
      ..writeByte(12)
      ..write(obj.imdbRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
