// ============================================================
// MODELOS DE BACKEND PARA PHOTOCLASH
// ============================================================

class RoomResponse {
  final String id;
  final String code;
  final String status;
  final int roundsTotal;
  final int secondsPerRound;
  final bool nsfwAllowed;
  final DateTime createdAt;
  final List<RoomPlayerResponse> players;

  RoomResponse({
    required this.id,
    required this.code,
    required this.status,
    required this.roundsTotal,
    required this.secondsPerRound,
    required this.nsfwAllowed,
    required this.createdAt,
    required this.players,
  });

  factory RoomResponse.fromJson(Map<String, dynamic> json) {
    return RoomResponse(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? 'Waiting',
      roundsTotal: json['roundsTotal'] ?? 0,
      secondsPerRound: json['secondsPerRound'] ?? 0,
      nsfwAllowed: json['nsfwAllowed'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      players: (json['players'] as List?)
              ?.map((p) => RoomPlayerResponse.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'status': status,
      'roundsTotal': roundsTotal,
      'secondsPerRound': secondsPerRound,
      'nsfwAllowed': nsfwAllowed,
      'createdAt': createdAt.toIso8601String(),
      'players': players.map((p) => p.toJson()).toList(),
    };
  }
}

class RoomPlayerResponse {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final int score;
  final DateTime joinedAt;

  RoomPlayerResponse({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.score,
    required this.joinedAt,
  });

  factory RoomPlayerResponse.fromJson(Map<String, dynamic> json) {
    return RoomPlayerResponse(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      score: json['score'] ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'score': score,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class RoundResponse {
  final String id;
  final String roomId;
  final int roundNumber;
  final String promptPhrase;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  RoundResponse({
    required this.id,
    required this.roomId,
    required this.roundNumber,
    required this.promptPhrase,
    this.startedAt,
    this.finishedAt,
  });

  factory RoundResponse.fromJson(Map<String, dynamic> json) {
    return RoundResponse(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? '',
      roundNumber: json['roundNumber'] ?? 0,
      promptPhrase: json['promptPhrase'] ?? '',
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roundNumber': roundNumber,
      'promptPhrase': promptPhrase,
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }
}

class RoundPhotoResponse {
  final String id;
  final String roundId;
  final String playerId;
  final String playerUsername;
  final String photoUrl;
  final DateTime uploadedAt;

  RoundPhotoResponse({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.playerUsername,
    required this.photoUrl,
    required this.uploadedAt,
  });

  factory RoundPhotoResponse.fromJson(Map<String, dynamic> json) {
    return RoundPhotoResponse(
      id: json['id'] ?? '',
      roundId: json['roundId'] ?? '',
      playerId: json['playerId'] ?? '',
      playerUsername: json['playerUsername'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roundId': roundId,
      'playerId': playerId,
      'playerUsername': playerUsername,
      'photoUrl': photoUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

class VoteResponse {
  final String id;
  final String roundId;
  final String voterPlayerId;
  final String votedPlayerId;
  final DateTime createdAt;

  VoteResponse({
    required this.id,
    required this.roundId,
    required this.voterPlayerId,
    required this.votedPlayerId,
    required this.createdAt,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    return VoteResponse(
      id: json['id'] ?? '',
      roundId: json['roundId'] ?? '',
      voterPlayerId: json['voterPlayerId'] ?? '',
      votedPlayerId: json['votedPlayerId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roundId': roundId,
      'voterPlayerId': voterPlayerId,
      'votedPlayerId': votedPlayerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MatchResultResponse {
  final String id;
  final String roomId;
  final String winnerPlayerId;
  final String winnerUsername;
  final int totalRounds;
  final DateTime createdAt;

  MatchResultResponse({
    required this.id,
    required this.roomId,
    required this.winnerPlayerId,
    required this.winnerUsername,
    required this.totalRounds,
    required this.createdAt,
  });

  factory MatchResultResponse.fromJson(Map<String, dynamic> json) {
    return MatchResultResponse(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? '',
      winnerPlayerId: json['winnerPlayerId'] ?? '',
      winnerUsername: json['winnerUsername'] ?? '',
      totalRounds: json['totalRounds'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'winnerPlayerId': winnerPlayerId,
      'winnerUsername': winnerUsername,
      'totalRounds': totalRounds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class UserResponse {
  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserResponse({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}

class AppSettingsResponse {
  final String id;
  final String userId;
  final bool darkMode;
  final bool notifications;
  final String language;

  AppSettingsResponse({
    required this.id,
    required this.userId,
    required this.darkMode,
    required this.notifications,
    required this.language,
  });

  factory AppSettingsResponse.fromJson(Map<String, dynamic> json) {
    return AppSettingsResponse(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      darkMode: json['darkMode'] ?? false,
      notifications: json['notifications'] ?? true,
      language: json['language'] ?? 'es',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'darkMode': darkMode,
      'notifications': notifications,
      'language': language,
    };
  }
}

class PhotoSweepPhotoResponse {
  final String id;
  final String userId;
  final String uri;
  final DateTime? dateTaken;
  final bool? keepStatus;
  final DateTime? reviewedAt;

  PhotoSweepPhotoResponse({
    required this.id,
    required this.userId,
    required this.uri,
    this.dateTaken,
    this.keepStatus,
    this.reviewedAt,
  });

  factory PhotoSweepPhotoResponse.fromJson(Map<String, dynamic> json) {
    return PhotoSweepPhotoResponse(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      uri: json['uri'] ?? '',
      dateTaken: json['dateTaken'] != null ? DateTime.parse(json['dateTaken']) : null,
      keepStatus: json['keepStatus'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'uri': uri,
      'dateTaken': dateTaken?.toIso8601String(),
      'keepStatus': keepStatus,
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }
}

class PhotoSweepStatsResponse {
  final int totalPhotos;
  final int kept;
  final int deleted;
  final int pending;

  PhotoSweepStatsResponse({
    required this.totalPhotos,
    required this.kept,
    required this.deleted,
    required this.pending,
  });

  factory PhotoSweepStatsResponse.fromJson(Map<String, dynamic> json) {
    return PhotoSweepStatsResponse(
      totalPhotos: json['totalPhotos'] ?? 0,
      kept: json['kept'] ?? 0,
      deleted: json['deleted'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPhotos': totalPhotos,
      'kept': kept,
      'deleted': deleted,
      'pending': pending,
    };
  }
}
