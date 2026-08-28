import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../servisler/kimlik_servisi.dart';
import '../tema.dart';

class GirisKayitEkrani extends StatefulWidget {
  const GirisKayitEkrani({super.key});

  @override
  State<GirisKayitEkrani> createState() => _GirisKayitEkraniState();
}

class _GirisKayitEkraniState extends State<GirisKayitEkrani> {
  final _kimlikServisi = KimlikServisi();
  bool _girisModu = true;
  bool _yukleniyor = false;

  final _girisKullaniciAdi = TextEditingController();
  final _girisSifre = TextEditingController();
  final _kayitKullaniciAdi = TextEditingController();
  final _kayitSifre = TextEditingController();

  @override
  void dispose() {
    _girisKullaniciAdi.dispose();
    _girisSifre.dispose();
    _kayitKullaniciAdi.dispose();
    _kayitSifre.dispose();
    super.dispose();
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: OrjandaRenkleri.kirmizi),
    );
  }

  Future<void> _girisYap() async {
    if (_girisKullaniciAdi.text.trim().isEmpty || _girisSifre.text.isEmpty) {
      _hataGoster('Kullanıcı adı ve şifre gerekli.');
      return;
    }
    setState(() => _yukleniyor = true);
    try {
      await _kimlikServisi.girisYap(
        kullaniciAdi: _girisKullaniciAdi.text,
        sifre: _girisSifre.text,
      );
    } on FirebaseAuthException catch (e) {
      _hataGoster(_kimlikServisi.hataMesaji(e));
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _kayitOl() async {
    if (_kayitKullaniciAdi.text.trim().isEmpty || _kayitSifre.text.isEmpty) {
      _hataGoster('Kullanıcı adı ve şifre gerekli.');
      return;
    }
    if (_kayitSifre.text.length < 6) {
      _hataGoster('Şifre en az 6 karakter olmalı.');
      return;
    }
    setState(() => _yukleniyor = true);
    try {
      await _kimlikServisi.kayitOl(
        kullaniciAdi: _kayitKullaniciAdi.text,
        sifre: _kayitSifre.text,
      );
    } on FirebaseAuthException catch (e) {
      _hataGoster(_kimlikServisi.hataMesaji(e));
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'ORJANDA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: OrjandaRenkleri.yazi,
                        ),
                      ),
                      const SizedBox(height: 36),
                      if (_girisModu) _girisFormu() else _kayitFormu(),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Created: Turhan Sarıcı',
                style: TextStyle(fontSize: 12, color: OrjandaRenkleri.yaziSoluk),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _girisFormu() {
    return Column(
      children: [
        TextField(
          controller: _girisKullaniciAdi,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Kullanıcı Adı'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _girisSifre,
          obscureText: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'Şifrenizi Giriniz'),
        ),
        const SizedBox(height: 16),
        _gonderButonu('Giriş Yap', _yukleniyor ? null : _girisYap),
        const SizedBox(height: 18),
        _linkButonu('Hesabın yok mu? Kayıt Ol', () {
          setState(() => _girisModu = false);
        }),
      ],
    );
  }

  Widget _kayitFormu() {
    return Column(
      children: [
        TextField(
          controller: _kayitKullaniciAdi,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Kullanıcı Adı Oluştur'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _kayitSifre,
          obscureText: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: 'Şifre Oluştur (En az 6 karakter)'),
        ),
        const SizedBox(height: 16),
        _gonderButonu('Kayıt Ol', _yukleniyor ? null : _kayitOl),
        const SizedBox(height: 18),
        _linkButonu('Zaten hesabın var mı? Giriş Yap', () {
          setState(() => _girisModu = true);
        }),
      ],
    );
  }

  Widget _gonderButonu(String metin, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: OrjandaRenkleri.turuncu),
          backgroundColor: OrjandaRenkleri.kart,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _yukleniyor
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                metin,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OrjandaRenkleri.yazi,
                ),
              ),
      ),
    );
  }

  Widget _linkButonu(String metin, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: OrjandaRenkleri.turuncu),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
      child: Text(
        metin,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: OrjandaRenkleri.turuncu,
        ),
      ),
    );
  }
}
