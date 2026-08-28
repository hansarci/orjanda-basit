import 'package:firebase_auth/firebase_auth.dart';

/// Kullanıcı adı + şifre ile giriş/kayıt işlemlerini yönetir.
/// Firebase Auth e-posta istediği için kullanıcı adından arka planda
/// otomatik bir e-posta üretilir (kullanici@orjanda.app gibi).
class KimlikServisi {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get suankiKullanici => _auth.currentUser;
  Stream<User?> get kullaniciDegisimi => _auth.authStateChanges();

  /// Kullanıcı adını Firebase e-posta formatına uygun hale getirir.
  String _kullaniciAdindanEposta(String kullaniciAdi) {
    final harita = {
      'ç': 'c', 'Ç': 'c', 'ğ': 'g', 'Ğ': 'g', 'ı': 'i', 'I': 'i',
      'İ': 'i', 'ö': 'o', 'Ö': 'o', 'ş': 's', 'Ş': 's', 'ü': 'u', 'Ü': 'u',
    };
    var sonuc = kullaniciAdi.trim().toLowerCase();
    harita.forEach((tr, en) {
      sonuc = sonuc.replaceAll(tr.toLowerCase(), en);
    });
    sonuc = sonuc.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '$sonuc@orjanda.app';
  }

  Future<UserCredential> kayitOl({
    required String kullaniciAdi,
    required String sifre,
  }) async {
    final eposta = _kullaniciAdindanEposta(kullaniciAdi);
    final sonuc = await _auth.createUserWithEmailAndPassword(
      email: eposta,
      password: sifre,
    );
    await sonuc.user?.updateDisplayName(kullaniciAdi.trim());
    return sonuc;
  }

  Future<UserCredential> girisYap({
    required String kullaniciAdi,
    required String sifre,
  }) async {
    final eposta = _kullaniciAdindanEposta(kullaniciAdi);
    return _auth.signInWithEmailAndPassword(email: eposta, password: sifre);
  }

  Future<void> cikisYap() => _auth.signOut();

  /// Firebase hata kodlarını kullanıcıya gösterilecek Türkçe mesaja çevirir.
  String hataMesaji(FirebaseAuthException hata) {
    switch (hata.code) {
      case 'email-already-in-use':
        return 'Bu kullanıcı adı zaten alınmış.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalı.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Kullanıcı adı veya şifre hatalı.';
      case 'invalid-email':
        return 'Kullanıcı adı geçersiz karakter içeriyor.';
      default:
        return 'Bir hata oluştu: ${hata.message ?? hata.code}';
    }
  }
}
