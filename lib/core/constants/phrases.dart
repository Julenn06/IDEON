class PhotoClashPhrases {
  static const Map<String, List<String>> phrases = {
    'es_normal': [
      'La foto que mejor represente un lunes por la mañana',
      'Algo rojo en tu galería',
      'La última foto que te hizo reír',
      'Tu mascota o animal favorito',
      'Comida que se ve deliciosa',
      'Un atardecer o amanecer',
      'Tu lugar favorito',
      'Algo que represente tu hobby',
      'Una foto con tus amigos',
      'El paisaje más bonito que tienes',
      'Tu selfie favorito',
      'Algo verde en tu galería',
      'Una foto que te da nostalgia',
      'Tu mejor foto de este año',
      'Algo que te haga sentir feliz',
    ],
    'es_crazy': [
      'Foto de tu amigo después de una fiesta',
      'Lo más raro que te encontraste este año',
      'Tu foto más cringe',
      'La foto que te da más vergüenza enseñar',
      'Algo completamente inexplicable',
      'Tu peor foto de perfil',
      'Momento más épico fail',
      'Foto más caótica de tu galería',
      'Algo que no deberías tener en tu teléfono',
      'Tu foto más random',
      'Meme que guardaste hace tiempo',
      'Screenshot más raro',
      'Foto que nadie entendería excepto tú',
      'Momento más vergonzoso capturado',
      'Foto más cursed de tu galería',
    ],
    'es_nsfw': [
      'Foto más atrevida (sin pasarse)',
      'Algo picante de tu galería',
      'Tu foto más sexy',
      'Momento de fiesta loca',
      'Screenshot comprometedor',
      'Foto que no mostrarías a tus padres',
      'Tu foto más salvaje',
      'Momento después de muchas copas',
    ],
    'en_normal': [
      'Best represents a Monday morning',
      'Something red in your gallery',
      'Last photo that made you laugh',
      'Your pet or favorite animal',
      'Food that looks delicious',
      'A sunset or sunrise',
      'Your favorite place',
      'Something that represents your hobby',
      'A photo with your friends',
      'The most beautiful landscape you have',
      'Your favorite selfie',
      'Something green in your gallery',
      'A photo that makes you nostalgic',
      'Your best photo this year',
      'Something that makes you feel happy',
    ],
    'en_crazy': [
      'Photo of your friend after a party',
      'Weirdest thing you found this year',
      'Your cringiest photo',
      'Most embarrassing photo',
      'Something completely inexplicable',
      'Your worst profile picture',
      'Most epic fail moment',
      'Most chaotic photo in your gallery',
      'Something you shouldn\'t have on your phone',
      'Your most random photo',
      'Meme you saved long ago',
      'Weirdest screenshot',
      'Photo only you would understand',
      'Most embarrassing moment captured',
      'Most cursed photo in your gallery',
    ],
    'en_nsfw': [
      'Most daring photo (keep it classy)',
      'Something spicy from your gallery',
      'Your sexiest photo',
      'Wild party moment',
      'Compromising screenshot',
      'Photo you wouldn\'t show your parents',
      'Your wildest photo',
      'Moment after too many drinks',
    ],
  };

  static String getRandomPhrase(String language, String mode, bool nsfwEnabled) {
    String key;
    
    if (nsfwEnabled && mode == 'nsfw') {
      key = '${language}_nsfw';
    } else if (mode == 'crazy') {
      key = '${language}_crazy';
    } else {
      key = '${language}_normal';
    }

    final phraseList = phrases[key] ?? phrases['es_normal']!;
    phraseList.shuffle();
    return phraseList.first;
  }
}
