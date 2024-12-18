import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `main.dart` with the code generated by Freezed
part 'game_state.freezed.dart';
// optional: Since our Game class is serializable, we must add this line.
// But if Game was not serializable, we could skip it.
part 'game_state.g.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required String name,
    required Map<int, int?> tileMap,
    required int score,
    required bool gameIsOver,
  }) = _Game;

  factory GameState.fromJson(Map<String, Object?> json) =>
      _$GameStateFromJson(json);
}