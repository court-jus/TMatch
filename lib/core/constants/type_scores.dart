abstract final class TypeScores {
  static const Map<int, int> played = {
    1: 5,
    2: 10,
    3: 50,
    4: 200,
    -1: 500,
    -2: 10,
    -3: 100,
    -4: 250,
  };

  static const Map<int, int> combItem = {
    1: 10,
    2: 20,
    3: 50,
    4: 100,
    5: 150,
    6: 1000,
    -2: 100,
    -5: 500,
    -6: 2500,
  };

  static const Map<int, int> combResult = {
    2: 30,
    3: 70,
    4: 150,
    5: 500,
    6: 2500,
    7: 10000,
    -5: 750,
    -6: 1500,
    -7: 5000,
  };

  static const Map<int, int> destroyed = {
    1: -5,
    2: -30,
    3: -75,
    4: -200,
    5: -1000,
    6: -5000,
    7: -20000,
    -1: 2000,
    -2: 10,
    -5: 500,
    -6: 1000,
    -7: 25000,
  };
}
