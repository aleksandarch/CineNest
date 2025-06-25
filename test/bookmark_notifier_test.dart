import 'dart:io';

import 'package:cine_nest/boxes/boxes.dart';
import 'package:cine_nest/models/bookmark_model.dart';
import 'package:cine_nest/providers/bookmark_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BookmarkModelAdapter());
    }
    await Boxes.openBookmarkBox();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('BookmarkBox');
    await Hive.close(); // resets the type registry
    await tempDir.delete(recursive: true);
  });

  test('updateBookmarks stores bookmarks and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(bookmarkProvider.notifier);

    final bookmarks = [
      BookmarkModel(movieId: '1', createdOn: DateTime.now()),
      BookmarkModel(movieId: '2', createdOn: DateTime.now()),
    ];

    await notifier.updateBookmarks(bookmarks);

    final boxBookmarks = Boxes.getBookmarks().values.toList();
    expect(boxBookmarks.length, 2);
    expect(notifier.state.length, 2);
  });

  test('clear removes all bookmarks from box and state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(bookmarkProvider.notifier);

    await notifier.updateBookmarks([
      BookmarkModel(movieId: '1', createdOn: DateTime.now()),
    ]);

    expect(notifier.state.isNotEmpty, true);

    await notifier.clear();

    expect(Boxes.getBookmarks().isEmpty, true);
    expect(notifier.state.isEmpty, true);
  });
}
