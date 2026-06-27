import '../../domain/models/bird.dart';
import '../../domain/models/species.dart';
import '../../domain/repositories/species_repository.dart';

class MockSpeciesRepository implements SpeciesRepository {
  final List<Species> _species = [
    const Species(
      id: 'sp1',
      commonName: 'Rouge-gorge familier',
      scientificName: 'Erithacus rubecula',
      family: 'Muscicapidae',
      order: 'Passeriformes',
      description: 'Petit passereau très commun, reconnaissable à son plastron orangé.',
      imageUrls: [
        'https://images.unsplash.com/photo-1552728089-57bdde30ebd3?q=80&w=1000&auto=format&fit=crop',
      ],
      audioUrl: 'https://www.xeno-canto.org/sounds/uploaded/RFTXRYMVXN/XC682344-Robin.mp3',
      size: 'Petit (15-25cm)',
      weight: '16-22 g',
      plumage: 'Dessus brun-olive, face et gorge rouge-orangé, ventre blanc.',
      habitat: 'Forêt',
      food: 'Insectes, vers, baies.',
      reproduction: 'Nid dans un trou ou une crevasse, 5-6 œufs.',
      status: ConservationStatus.lc,
    ),
    const Species(
      id: 'sp2',
      commonName: 'Mésange bleue',
      scientificName: 'Cyanistes caeruleus',
      family: 'Paridae',
      order: 'Passeriformes',
      description: 'Petite mésange vive au plumage bleu et jaune.',
      imageUrls: [
        'https://images.unsplash.com/photo-1522448452220-449e7943f66a?q=80&w=1000&auto=format&fit=crop'
      ],
      audioUrl: 'https://www.xeno-canto.org/sounds/uploaded/RFTXRYMVXN/XC682345-BlueTit.mp3',
      size: 'Très petit (<15cm)',
      weight: '9-12 g',
      plumage: 'Calotte bleue, ailes bleues, poitrine jaune, masque noir.',
      habitat: 'Urbain',
      food: 'Insectes, larves, graines.',
      reproduction: 'Nicheur cavernicole, 7-12 œufs.',
      status: ConservationStatus.lc,
    ),
    const Species(
      id: 'sp3',
      commonName: 'Martin-pêcheur d\'Europe',
      scientificName: 'Alcedo atthis',
      family: 'Alcedinidae',
      order: 'Coraciiformes',
      description: 'Oiseau aux couleurs éclatantes, bleu turquoise et orangé.',
      imageUrls: [
        'https://images.unsplash.com/photo-1539243360452-4127539a6745?q=80&w=1000&auto=format&fit=crop'
      ],
      audioUrl: 'https://www.xeno-canto.org/sounds/uploaded/RFTXRYMVXN/XC682346-Kingfisher.mp3',
      size: 'Petit (15-25cm)',
      weight: '34-46 g',
      plumage: 'Bleu métallique sur le dessus, roux sur le dessous.',
      habitat: 'Zone humide',
      food: 'Poissons, insectes aquatiques.',
      reproduction: 'Nid dans un terrier de berge, 5-7 œufs.',
      status: ConservationStatus.lc,
    ),
  ];

  @override
  Future<List<Species>> getAllSpecies() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _species;
  }

  @override
  Future<List<Species>> searchSpecies(String query) async {
    return _species.where((s) => 
      s.commonName.toLowerCase().contains(query.toLowerCase()) || 
      s.scientificName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  Future<List<Species>> filterSpecies({
    String? habitat,
    String? size,
    List<String>? colors,
  }) async {
    return _species.where((s) {
      bool matches = true;
      if (habitat != null && habitat != 'Tous') {
        matches = matches && s.habitat == habitat;
      }
      if (size != null && size != 'Toutes') {
        matches = matches && s.size == size;
      }
      return matches;
    }).toList();
  }

  @override
  Future<Species?> getSpeciesById(String id) async {
    try {
      return _species.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
