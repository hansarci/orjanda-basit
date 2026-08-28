/// Bir pusulayı (kesim sahasındaki bir ağaç aralığını) temsil eder.
class Pusula {
  String isim;
  int basNo;
  int sonNo;
  Set<int> kesilenNumaralar;

  Pusula({
    required this.isim,
    required this.basNo,
    required this.sonNo,
    Set<int>? kesilenNumaralar,
  }) : kesilenNumaralar = kesilenNumaralar ?? <int>{};

  int get toplamAgac => (sonNo - basNo + 1).clamp(0, 1 << 30);
  int get kesilenAdet => kesilenNumaralar.length;
  int get kalanAdet => toplamAgac - kesilenAdet;

  Map<String, dynamic> toMap() {
    return {
      'isim': isim,
      'basNo': basNo,
      'sonNo': sonNo,
      'kesilenNumaralar': kesilenNumaralar.toList(),
    };
  }

  factory Pusula.fromMap(Map<String, dynamic> harita) {
    final kesilenListe = (harita['kesilenNumaralar'] as List?) ?? [];
    return Pusula(
      isim: harita['isim'] ?? '',
      basNo: (harita['basNo'] ?? 1) is int
          ? harita['basNo']
          : int.tryParse('${harita['basNo']}') ?? 1,
      sonNo: (harita['sonNo'] ?? 10) is int
          ? harita['sonNo']
          : int.tryParse('${harita['sonNo']}') ?? 10,
      kesilenNumaralar: kesilenListe.map((e) => e as int).toSet(),
    );
  }
}
