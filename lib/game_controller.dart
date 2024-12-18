import 'dart:math';

import 'package:flutter/material.dart' show Color, Colors;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:twenty_forty_eight/game_state.dart';

part 'game_controller.g.dart';

enum Direction {
  up,
  down,
  left,
  right;
}

@riverpod
class Game extends _$Game {
  int _score = 0;

  GameState _newGameState() {
    GameState newGame = GameState(
      name: 'BJC  News',
      tileMap: ref.watch(testTileMapProvider),
      // tileMap: ref.watch(defaultTileMapProvider),
      score: 0,
      gameIsOver: false,
      gameWon: false,
    );
    final Map<int, int?> tileMap = {...newGame.tileMap};
    final random = Random();
    for (int i = 0; i < 2; i++) {
      final availableTiles = _emptyTiles(newGame.tileMap);
      final index = availableTiles[random.nextInt(availableTiles.length)];
      final value = random.nextDouble() < 0.95 ? 2 : 4;
      tileMap[index] = value;
    }
    return newGame.copyWith(tileMap: tileMap);
  }

  @override
  GameState build() {
    return _newGameState();
  }

  void handleSwipe(Direction direction) {
    final oldBoard = {...state.tileMap};
    for (int i = 0; i < 4; i++) {
      switch (direction) {
        case Direction.up:
          _combineColumnUp(i);
        case Direction.down:
          _combineColumnDown(i);
        case Direction.left:
          _combineRowLeft(i);
        case Direction.right:
          _combineRowRight(i);
      }
    }
    int newScore = state.score + _score;
    state = state.copyWith(score: newScore);
    _score = 0;

    final boardChanged = _boardChanged(oldBoard);
    addNewTile(boardChanged: boardChanged);

    if (state.tileMap.containsValue(2048) &&
        !state.gameWon &&
        !state.gameIsOver) {
      // TODO handle win!
      state = state.copyWith(gameWon: true, gameIsOver: true);
    }
  }

  void _combineColumnUp(int col) {
    print("Combining Column $col up");
    List<int> numbers = _getNumbersInColumn(col);
    List<int?> newNumbers = _combineNumbers(numbers);
    _setNumbersInColumn(col, newNumbers);
  }

  void _combineColumnDown(int col) {
    print("Combining Column $col down");
    List<int> numbers = _getNumbersInColumn(col).reversed.toList();
    List<int?> newNumbers = _combineNumbers(numbers).reversed.toList();
    _setNumbersInColumn(col, newNumbers);
  }

  void _combineRowLeft(int row) {
    print("Combining Row $row up");
    List<int> numbers = _getNumbersInRow(row);
    List<int?> newNumbers = _combineNumbers(numbers);
    _setNumbersInRow(row, newNumbers);
  }

  void _combineRowRight(int row) {
    print("Combining Row $row down");
    List<int> numbers = _getNumbersInRow(row).reversed.toList();
    List<int?> newNumbers = _combineNumbers(numbers).reversed.toList();
    _setNumbersInRow(row, newNumbers);
  }

  List<int> _getNumbersInColumn(int col) {
    List<int> numbers = [];
    for (int i = 0; i < 4; i++) {
      int index = col + (i * 4);
      int? value = state.tileMap[index];
      if (value != null) {
        numbers.add(value);
      }
    }
    return numbers;
  }

  List<int> _getNumbersInRow(int row) {
    List<int> numbers = [];
    for (int i = 0; i < 4; i++) {
      int index = (row * 4) + i;
      int? value = state.tileMap[index];
      if (value != null) {
        numbers.add(value);
      }
    }
    return numbers;
  }

  void _setNumbersInColumn(int column, List<int?> numbers) {
    final newTileMap = {...state.tileMap};
    for (int i = 0; i < 4; i++) {
      // Could loop over numbers specifically
      int index = column + (i * 4);
      newTileMap[index] = numbers.elementAtOrNull(i);
    }
    state = state.copyWith(tileMap: newTileMap);
  }

  void _setNumbersInRow(int row, List<int?> numbers) {
    final newTileMap = {...state.tileMap};
    for (int i = 0; i < 4; i++) {
      // Could loop over numbers specifically
      int index = (row * 4) + i;
      newTileMap[index] = numbers.elementAtOrNull(i);
    }
    state = state.copyWith(tileMap: newTileMap);
  }

  List<int?> _combineNumbers(List<int> numbers) {
    final newNumbers = <int?>[];
    // int score = state.score;
    while (numbers.isNotEmpty) {
      if (numbers.length == 1) {
        newNumbers.add(numbers[0]);
        numbers.removeAt(0);
      } else if (numbers[0] == numbers[1]) {
        int sum = numbers[0] + numbers[1];
        newNumbers.add(sum);
        _score += sum; // TODO add score for combined digits!
        // state.score += sum;
        numbers.removeAt(0);
        numbers.removeAt(0);
      } else {
        newNumbers.add(numbers[0]);
        numbers.removeAt(0);
      }
    }
    while (newNumbers.length < 4) {
      newNumbers.add(null);
    }
    return newNumbers;
  }

  bool _boardChanged(Map<int, int?> oldBoard) {
    for (int i = 0; i < 16; i++) {
      if (oldBoard[i] != state.tileMap[i]) {
        return true;
      }
    }
    // return true; // TODO this should be false!
    return false;
  }

  void addNewTile({required bool boardChanged}) {
    Map<int, int?> tileMap = {...state.tileMap};
    bool gameOver = false;
    bool gameWon = state.gameWon;
    final emptyKeys = _emptyTiles(state.tileMap);
    if (emptyKeys.isNotEmpty && boardChanged) {
      final random = Random();
      final index = emptyKeys[random.nextInt(emptyKeys.length)];
      final value = random.nextDouble() < 0.95 ? 2 : 4;
      // TODO make this random value based on score. 2s, 4s, 8s +

      tileMap[index] = value;
    } else if (emptyKeys.isEmpty && !boardChanged) {
      // Game is over! There are no more empty tiles
      // TODO fix this based on possible moves
      gameOver = true;
      gameWon = false;
      print("✅ GameOver!");
    }

    state = state.copyWith(
      tileMap: tileMap,
      gameIsOver: gameOver,
      gameWon: gameWon,
    );
  }

  List<int> _emptyTiles(Map<int, int?> tileMap) {
    return tileMap.keys.where((i) => tileMap[i] == null).toList();
  }

  void startNewGame() {
    ref.invalidateSelf();
    // We now get two tiles at the beginning of the game state...
    // addNewTile(boardChanged: true);
    // addNewTile(boardChanged: true);
  }

  void keepGoing() {
    state = state.copyWith(gameIsOver: false);
  }
}

@riverpod
Map<int, int?> defaultTileMap(Ref ref) {
  final tileMap = {
    0: null,
    1: null,
    2: null,
    3: null,
    4: null,
    5: null,
    6: null,
    7: null,
    8: null,
    9: null,
    10: null,
    11: null,
    12: null,
    13: null,
    14: null,
    15: null,
  };

  return tileMap;
}

@riverpod
Map<int, int?> testTileMap(Ref ref) {
  final tileMap = {
    0: 2,
    1: 4,
    2: 8,
    3: 16,
    4: 32,
    5: 64,
    6: 128,
    7: 256,
    8: 512,
    9: 1024,
    10: null,
    11: 4096,
    12: null,
    13: null,
    14: 1024,
    15: null,
  };

  return tileMap;
}

@riverpod
Color tileColor(Ref ref, int? value) {
  // if (value == null) return The
  return Colors.green;
}
