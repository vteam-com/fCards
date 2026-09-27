import 'package:cards/models/game/game_styles.dart';
import 'package:cards/models/game/memory_table_store.dart';
import 'package:cards/models/game/table_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => TableService.store = MemoryTableStore());

  group('GameTable', () {
    test('the same players in any order and case share one id', () {
      expect(
        GameTable.idFor(GameStyles.skyjo, <String>['sue', 'Bob ']),
        GameTable.idFor(GameStyles.skyjo, <String>['BOB', 'SUE', 'bob']),
      );
    });

    test('game type and exact players both change the id', () {
      final String base = GameTable.idFor(GameStyles.skyjo, <String>['A', 'B']);

      expect(
        GameTable.idFor(GameStyles.frenchCards9, <String>['A', 'B']),
        isNot(base),
      );
      expect(
        GameTable.idFor(GameStyles.skyjo, <String>['A', 'B', 'C']),
        isNot(base),
      );
    });
  });

  group('TableService', () {
    test(
      'resolve creates a table once and finds it again by players',
      () async {
        final GameTable first = await TableService.resolveTable(
          gameType: GameStyles.skyjo,
          players: <String>['SUE', 'BOB'],
          proposedName: 'blue  otter',
        );
        final GameTable again = await TableService.resolveTable(
          gameType: GameStyles.skyjo,
          players: <String>['bob', 'sue'],
          proposedName: 'OTHER NAME',
        );

        expect(first.name, 'BLUE OTTER');
        expect(first.players, <String>['BOB', 'SUE']);
        expect(again.id, first.id);
        expect(again.name, 'BLUE OTTER');
        expect(
          (await TableService.findTable(GameStyles.skyjo, <String>[
            'SUE',
            'BOB',
          ]))?.name,
          'BLUE OTTER',
        );
      },
    );

    test('a different group gets its own table and a free name', () async {
      await TableService.resolveTable(
        gameType: GameStyles.skyjo,
        players: <String>['A', 'B'],
        proposedName: 'BLUE OTTER',
      );
      final GameTable other = await TableService.resolveTable(
        gameType: GameStyles.skyjo,
        players: <String>['A', 'B', 'C'],
        proposedName: 'BLUE OTTER',
      );

      expect(other.name, isNot('BLUE OTTER'));
      expect(
        await TableService.findTable(GameStyles.frenchCards9, <String>[
          'A',
          'B',
        ]),
        isNull,
      );
    });

    test('rename rejects empty and taken names', () async {
      final GameTable a = await TableService.resolveTable(
        gameType: GameStyles.skyjo,
        players: <String>['A', 'B'],
        proposedName: 'FIRST',
      );
      await TableService.resolveTable(
        gameType: GameStyles.skyjo,
        players: <String>['C', 'D'],
        proposedName: 'SECOND',
      );

      expect(
        await TableService.renameTable(a.id, ' '),
        TableRenameResult.invalid,
      );
      expect(
        await TableService.renameTable(a.id, 'second'),
        TableRenameResult.taken,
      );
      expect(
        await TableService.renameTable(a.id, 'first'),
        TableRenameResult.renamed,
      );
      expect(
        await TableService.renameTable(a.id, 'Beach house'),
        TableRenameResult.renamed,
      );
      expect((await TableService.getTable(a.id))?.name, 'BEACH HOUSE');
    });

    test('lobbies reopen a table name and are found by name', () async {
      final GameTable table = await TableService.resolveTable(
        gameType: GameStyles.frenchCards9,
        players: <String>['A', 'B'],
        proposedName: 'LUCKY FOX',
      );
      final GameLobby reopened = await TableService.openLobby(
        gameType: GameStyles.frenchCards9,
        cards: CardMedium.physical,
        table: table,
      );
      final GameLobby fresh = await TableService.openLobby(
        gameType: GameStyles.skyjo,
        cards: CardMedium.virtual,
      );

      expect(reopened.name, 'LUCKY FOX');
      expect(reopened.tableId, table.id);
      expect(fresh.name, isNot('LUCKY FOX'));
      expect(
        (await TableService.findLobbies(
          'lucky fox',
          cards: CardMedium.physical,
        )).map((GameLobby lobby) => lobby.id),
        <String>[reopened.id],
      );
      expect(
        await TableService.findLobbies('LUCKY FOX', cards: CardMedium.virtual),
        isEmpty,
      );
      expect(
        (await TableService.recentLobbies(
          cards: CardMedium.virtual,
        )).map((GameLobby lobby) => lobby.id),
        <String>[fresh.id],
      );
    });

    test('lists a player\'s tables, most recent first', () async {
      final GameTable older = await TableService.resolveTable(
        gameType: GameStyles.skyjo,
        players: <String>['A', 'B'],
      );
      final GameTable newer = await TableService.resolveTable(
        gameType: GameStyles.frenchCards9,
        players: <String>['A', 'B'],
      );
      await TableService.markPlayed(
        older.id,
        DateTime.fromMillisecondsSinceEpoch(1),
        uids: <String>['uid'],
      );
      await TableService.markPlayed(
        newer.id,
        DateTime.fromMillisecondsSinceEpoch(2),
        uids: <String>['uid'],
      );

      expect(
        (await TableService.tablesForPlayer(
          'uid',
        )).map((GameTable table) => table.id),
        <String>[newer.id, older.id],
      );
      expect(
        (await TableService.tablesForPlayer(
          'uid',
          gameType: GameStyles.skyjo,
        )).map((GameTable table) => table.id),
        <String>[older.id],
      );
    });
  });
}
