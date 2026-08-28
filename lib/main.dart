import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'tema.dart';
import 'ekranlar/giris_kayit_ekrani.dart';
import 'ekranlar/arsiv_ekrani.dart';
import 'servisler/kimlik_servisi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // İnternetsiz çalışabilmesi için Firestore'un cihazda önbellek
  // tutmasını açıkça ayarlıyoruz (mobilde varsayılan olarak açık olsa da
  // sınırsız önbellek boyutuyla bilinçli olarak belirtiyoruz).
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const OrjandaUygulamasi());
}

class OrjandaUygulamasi extends StatelessWidget {
  const OrjandaUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orjanda',
      debugShowCheckedModeBanner: false,
      theme: orjandaTemasi(),
      home: const GirisKapisi(),
    );
  }
}

/// Kullanıcının oturum durumuna göre Giriş/Kayıt ya da Arşiv ekranını gösterir.
class GirisKapisi extends StatelessWidget {
  const GirisKapisi({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: KimlikServisi().kullaniciDegisimi,
      builder: (context, anlik) {
        if (anlik.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (anlik.data != null) {
          return const ArsivEkrani();
        }
        return const GirisKayitEkrani();
      },
    );
  }
}
