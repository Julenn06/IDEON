class GameRoom {
  final String id;
  final String code;
  final String hostId;
  final int maxPlayers;
  final int rounds;
  final int timePerRound;
  final String phraseMode;
  final String language;
  final GameStatus status;
  final int currentRound;
  final Map<String, Player> players;
  final Map<int, RoundData> roundsData;

  GameRoom({
    required this.id,
    required this.code,
    required this.hostId,
    this.maxPlayers = 6,
    this.rounds = 10,
    this.timePerRound = 60,
    this.phraseMode = 'normal',
    this.language = 'es',
    this.status = GameStatus.waiting,
    this.currentRound = 0,
    this.players = const {},
    this.roundsData = const {},
  });

  factory GameRoom.fromJson(Map<String, dynamic> json) {
    return GameRoom(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      hostId: json['hostId'] ?? '',
      maxPlayers: json['maxPlayers'] ?? 6,
      rounds: json['rounds'] ?? 10,
      timePerRound: json['timePerRound'] ?? 60,
      phraseMode: json['phraseMode'] ?? 'normal',
      language: json['language'] ?? 'es',
      status: GameStatus.values[json['status'] ?? 0],
      currentRound: json['currentRound'] ?? 0,
      players: (json['players'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Player.fromJson(value)),
          ) ??
          {},
      roundsData: (json['roundsData'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(int.parse(key), RoundData.fromJson(value)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'hostId': hostId,
      'maxPlayers': maxPlayers,
      'rounds': rounds,
      'timePerRound': timePerRound,
      'phraseMode': phraseMode,
      'language': language,
      'status': status.index,
      'currentRound': currentRound,
      'players': players.map((key, value) => MapEntry(key, value.toJson())),
      'roundsData': roundsData.map((key, value) => MapEntry(key.toString(), value.toJson())),
    };
  }

  GameRoom copyWith({
    String? id,
    String? code,
    String? hostId,
    int? maxPlayers,
    int? rounds,
    int? timePerRound,
    String? phraseMode,
    String? language,
    GameStatus? status,
    int? currentRound,
    Map<String, Player>? players,
    Map<int, RoundData>? roundsData,
  }) {
    return GameRoom(
      id: id ?? this.id,
      code: code ?? this.code,
      hostId: hostId ?? this.hostId,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      rounds: rounds ?? this.rounds,
      timePerRound: timePerRound ?? this.timePerRound,
      phraseMode: phraseMode ?? this.phraseMode,
      language: language ?? this.language,
      status: status ?? this.status,
      currentRound: currentRound ?? this.currentRound,
      players: players ?? this.players,
      roundsData: roundsData ?? this.roundsData,
    );
  }
}

class Player {
  final String id;
  final String name;
  final int score;
  final bool ready;

  Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.ready = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      score: json['score'] ?? 0,
      ready: json['ready'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'ready': ready,
    };
  }

  Player copyWith({
    String? id,
    String? name,
    int? score,
    bool? ready,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      ready: ready ?? this.ready,
    );
  }
}

class RoundData {
  final String phrase;
  final Map<String, PhotoSubmission> submissions;
  final Map<String, String> votes; // voterId -> submissionPlayerId

  RoundData({
    required this.phrase,
    this.submissions = const {},
    this.votes = const {},
  });

  factory RoundData.fromJson(Map<String, dynamic> json) {
    return RoundData(
      phrase: json['phrase'] ?? '',
      submissions: (json['submissions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, PhotoSubmission.fromJson(value)),
          ) ??
          {},
      votes: Map<String, String>.from(json['votes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phrase': phrase,
      'submissions': submissions.map((key, value) => MapEntry(key, value.toJson())),
      'votes': votes,
    };
  }
}

class PhotoSubmission {
  final String playerId;
  final String photoUrl;
  final DateTime timestamp;

  PhotoSubmission({
    required this.playerId,
    required this.photoUrl,
    required this.timestamp,
  });

  factory PhotoSubmission.fromJson(Map<String, dynamic> json) {
    return PhotoSubmission(
      playerId: json['playerId'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'photoUrl': photoUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum GameStatus {
  waiting,
  playing,
  voting,
  results,
  finished,
}
