class CleaningTips {
  static const List<Map<String, String>> tipsES = [
    {
      'title': '💡 Tip: Fotos duplicadas',
      'message': '¿Ves la misma foto dos veces? Probablemente sea un duplicado. ¡Elimínala!',
    },
    {
      'title': '📸 Tip: Screenshots viejos',
      'message': 'Los screenshots de hace meses probablemente ya no los necesites.',
    },
    {
      'title': '🗓️ Tip: Fotos borrosas',
      'message': 'Si la foto está movida o borrosa, es mejor eliminarla.',
    },
    {
      'title': '✨ Consejo: Calidad antes que cantidad',
      'message': 'Es mejor tener 100 fotos buenas que 1000 mediocres.',
    },
    {
      'title': '🎯 Tip: Fotos de documentos',
      'message': 'Si ya procesaste ese documento, elimina la foto.',
    },
    {
      'title': '📱 Consejo: Memes guardados',
      'message': '¿Cuándo fue la última vez que miraste ese meme? Si hace más de 6 meses, elimínalo.',
    },
    {
      'title': '🌟 Tip: Fotos de eventos',
      'message': 'Quedarte con 5 fotos buenas de un evento es mejor que 50 regulares.',
    },
    {
      'title': '💾 Espacio liberado',
      'message': 'Cada foto que eliminas libera espacio para nuevas memorias.',
    },
    {
      'title': '🔄 Consejo: Fotos de prueba',
      'message': '¿Hiciste 10 fotos de lo mismo? Quédate solo con la mejor.',
    },
    {
      'title': '⚡ Tip rápido',
      'message': 'Si dudas más de 3 segundos, probablemente no la necesites.',
    },
  ];

  static const List<Map<String, String>> tipsEN = [
    {
      'title': '💡 Tip: Duplicate photos',
      'message': 'Seeing the same photo twice? It\'s probably a duplicate. Delete it!',
    },
    {
      'title': '📸 Tip: Old screenshots',
      'message': 'Screenshots from months ago probably aren\'t needed anymore.',
    },
    {
      'title': '🗓️ Tip: Blurry photos',
      'message': 'If the photo is blurry or shaky, it\'s better to delete it.',
    },
    {
      'title': '✨ Advice: Quality over quantity',
      'message': 'It\'s better to have 100 good photos than 1000 mediocre ones.',
    },
    {
      'title': '🎯 Tip: Document photos',
      'message': 'If you\'ve already processed that document, delete the photo.',
    },
    {
      'title': '📱 Advice: Saved memes',
      'message': 'When was the last time you looked at that meme? If it\'s been over 6 months, delete it.',
    },
    {
      'title': '🌟 Tip: Event photos',
      'message': 'Keeping 5 good photos from an event is better than 50 average ones.',
    },
    {
      'title': '💾 Freed space',
      'message': 'Every photo you delete frees up space for new memories.',
    },
    {
      'title': '🔄 Advice: Test photos',
      'message': 'Did you take 10 photos of the same thing? Keep only the best one.',
    },
    {
      'title': '⚡ Quick tip',
      'message': 'If you hesitate for more than 3 seconds, you probably don\'t need it.',
    },
  ];

  static Map<String, String> getRandomTip(String language) {
    final tips = language == 'es' ? tipsES : tipsEN;
    tips.shuffle();
    return tips.first;
  }

  static String getEncouragementMessage(int photosDeleted, String language) {
    if (language == 'es') {
      if (photosDeleted == 0) return '¡Comienza tu limpieza!';
      if (photosDeleted < 5) return '¡Buen comienzo! Sigue así.';
      if (photosDeleted < 10) return '¡Excelente! Ya llevas $photosDeleted fotos.';
      if (photosDeleted < 25) return '¡Increíble! $photosDeleted fotos eliminadas.';
      if (photosDeleted < 50) return '¡Eres un maestro de la limpieza!';
      return '¡WOW! $photosDeleted fotos. ¡Eres imparable!';
    } else {
      if (photosDeleted == 0) return 'Start your cleanup!';
      if (photosDeleted < 5) return 'Good start! Keep going.';
      if (photosDeleted < 10) return 'Excellent! $photosDeleted photos so far.';
      if (photosDeleted < 25) return 'Amazing! $photosDeleted photos deleted.';
      if (photosDeleted < 50) return 'You\'re a cleanup master!';
      return 'WOW! $photosDeleted photos. You\'re unstoppable!';
    }
  }
}
