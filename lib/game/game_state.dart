/// The possible states the game can be in.
enum GameState {
  /// Title screen — waiting for first tap.
  menu,

  /// Active gameplay — wizard is flying, pipes are scrolling.
  playing,

  /// Wizard has crashed — showing score summary.
  gameOver,
}
