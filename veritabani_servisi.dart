import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeller/is_kaydi.dart';
import '../modeller/pusula.dart';

/// Firestore okuma/yazma işlemlerini yönetir.
///
/// Yazma işlemleri bilinçli olarak "gönder ve unut" (fire-and-forget)
/// mantığıyla yapılır; UI, ağ cevabını beklemeden hemen devam eder.
/// Böylece internet olmadan da (offline persistence sayesinde) uygulama
/// donmadan çalışır.
class VeritabaniServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _isler => _db.collection('isler');

  /// Kullanıcının aktif (bitirilmemiş) işini dinler. Yoksa null döner.
  Stream<IsKaydi?> aktifIsDinle(String kullaniciId) {
    return _isler
        .where('kullaniciId', isEqualTo: kullaniciId)
        .where('durum', isEqualTo: 'aktif')
        .limit(1)
        .snapshots()
        .map((sonuc) => sonuc.docs.isEmpty ? null : IsKaydi.fromDoc(sonuc.docs.first));
  }

  /// Kullanıcının tamamlanmış işlerini (en yeni üstte) dinler.
  Stream<List<IsKaydi>> tamamlananIsleriDinle(String kullaniciId) {
    return _isler
        .where('kullaniciId', isEqualTo: kullaniciId)
        .where('durum', isEqualTo: 'tamamlandi')
        .orderBy('bitisTarihi', descending: true)
        .snapshots()
        .map((sonuc) => sonuc.docs.map((d) => IsKaydi.fromDoc(d)).toList());
  }

  /// Belirli bir işi tek seferlik okur.
  Future<IsKaydi?> isGetir(String isId) async {
    final doc = await _isler.doc(isId).get();
    if (!doc.exists) return null;
    return IsKaydi.fromDoc(doc);
  }

  /// Yeni bir aktif iş oluşturur, oluşan belgenin id'sini döner.
  Future<String> yeniIsOlustur(IsKaydi is_) async {
    final ref = await _isler.add(is_.toMap());
    return ref.id;
  }

  /// Pusula listesini günceller (kesim işaretleme, pusula ekleme/silme).
  void pusulalariGuncelle(String isId, List<Pusula> pusulalar) {
    _isler.doc(isId).update({
      'pusulalar': pusulalar.map((p) => p.toMap()).toList(),
    });
  }

  /// İşi tamamlanmış olarak işaretler.
  void isiBitir(String isId, DateTime bitisTarihi) {
    _isler.doc(isId).update({
      'durum': 'tamamlandi',
      'bitisTarihi': Timestamp.fromDate(bitisTarihi),
    });
  }
}
