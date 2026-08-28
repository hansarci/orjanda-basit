import 'package:cloud_firestore/cloud_firestore.dart';
import 'pusula.dart';

/// Bir kesim işini (aktif ya da tamamlanmış) temsil eder.
class IsKaydi {
  String? id;
  String kullaniciId;
  String isAdi;
  String durum; // 'aktif' | 'tamamlandi'
  DateTime baslamaTarihi;
  DateTime? bitisTarihi;
  List<Pusula> pusulalar;

  IsKaydi({
    this.id,
    required this.kullaniciId,
    required this.isAdi,
    required this.durum,
    required this.baslamaTarihi,
    this.bitisTarihi,
    required this.pusulalar,
  });

  int get toplamKesilenAgac =>
      pusulalar.fold(0, (toplam, p) => toplam + p.kesilenAdet);

  int get gunSayisi {
    final bitis = bitisTarihi ?? DateTime.now();
    final b = DateTime(baslamaTarihi.year, baslamaTarihi.month, baslamaTarihi.day);
    final s = DateTime(bitis.year, bitis.month, bitis.day);
    return s.difference(b).inDays + 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'kullaniciId': kullaniciId,
      'isAdi': isAdi,
      'durum': durum,
      'baslamaTarihi': Timestamp.fromDate(baslamaTarihi),
      'bitisTarihi': bitisTarihi != null ? Timestamp.fromDate(bitisTarihi!) : null,
      'pusulalar': pusulalar.map((p) => p.toMap()).toList(),
      'olusturulmaTarihi': FieldValue.serverTimestamp(),
    };
  }

  factory IsKaydi.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final veri = doc.data()!;
    final pusulaListesi = (veri['pusulalar'] as List? ?? [])
        .map((p) => Pusula.fromMap(Map<String, dynamic>.from(p)))
        .toList();
    return IsKaydi(
      id: doc.id,
      kullaniciId: veri['kullaniciId'] ?? '',
      isAdi: veri['isAdi'] ?? 'İsimsiz İş',
      durum: veri['durum'] ?? 'aktif',
      baslamaTarihi: (veri['baslamaTarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bitisTarihi: (veri['bitisTarihi'] as Timestamp?)?.toDate(),
      pusulalar: pusulaListesi,
    );
  }
}
