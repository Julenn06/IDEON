class AppSettings {
  final ThemeMode themeMode;
  final String language;
  final bool vibrationsEnabled;
  final bool nsfwMode;
  final bool confirmBeforeDelete;
  final int primaryColorIndex;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = 'es',
    this.vibrationsEnabled = false,
    this.nsfwMode = false,
    this.confirmBeforeDelete = false,
    this.primaryColorIndex = 0,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? vibrationsEnabled,
    bool? nsfwMode,
    bool? confirmBeforeDelete,
    int? primaryColorIndex,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      vibrationsEnabled: vibrationsEnabled ?? this.vibrationsEnabled,
      nsfwMode: nsfwMode ?? this.nsfwMode,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      primaryColorIndex: primaryColorIndex ?? this.primaryColorIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'language': language,
      'vibrationsEnabled': vibrationsEnabled,
      'nsfwMode': nsfwMode,
      'confirmBeforeDelete': confirmBeforeDelete,
      'primaryColorIndex': primaryColorIndex,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      language: json['language'] ?? 'es',
      vibrationsEnabled: json['vibrationsEnabled'] ?? true,
      nsfwMode: json['nsfwMode'] ?? false,
      confirmBeforeDelete: json['confirmBeforeDelete'] ?? false,
      primaryColorIndex: json['primaryColorIndex'] ?? 0,
    );
  }
}

enum ThemeMode {
  light,
  dark,
  system,
}
