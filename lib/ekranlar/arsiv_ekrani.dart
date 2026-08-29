import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../modeller/is_kaydi.dart';
import '../servisler/kimlik_servisi.dart';
import '../servisler/veritabani_servisi.dart';
import '../tema.dart';
import 'kesim_ekrani.dart';
import 'yeni_is_ekrani.dart';

class ArsivEkrani extends StatefulWidget {
  const ArsivEkrani({super.key});

  @override
  State<ArsivEkrani> createState() => _ArsivEkraniState();
}

class _ArsivEkraniState extends State<ArsivEkrani> {
  final _db = VeritabaniServisi();
  final _kimlikServisi = KimlikServisi();
  final _tarihFormat = DateFormat('dd/MM/yyyy');

  String get _kullaniciId => _kimlikServisi.suankiKullanici!.uid;

  void _uyariGoster(String mesaj) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OrjandaRenkleri.kart,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: OrjandaRenkleri.turuncu),
        ),
        content: Text(
          mesaj,
          textAlign: TextAlign.center,
          style: const TextStyle(color: OrjandaRenkleri.yazi, fontWeight: FontWeight.w600),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: OrjandaRenkleri.turuncu,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tamam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _aktifIseDon(IsKaydi? aktifIs) {
    if (aktifIs == null) {
      _uyariGoster('Aktif bir iş bulunmuyor.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => KesimEkrani(isKaydi: aktifIs)),
    );
  }

  void _yeniIsOlustur(IsKaydi? aktifIs) {
    if (aktifIs != null) {
      _uyariGoster('Devam eden bir iş var. Yeni iş oluşturmadan önce mevcut işi bitirmelisin.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const YeniIsEkrani()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<IsKaydi?>(
          stream: _db.aktifIsDinle(_kullaniciId),
          builder: (context, aktifSnap) {
            final aktifIs = aktifSnap.data;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 28, bottom: 16),
                  child: Column(
                    children: const [
                      Text(
                        'ORJANDA',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: OrjandaRenkleri.turuncu,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tamamlanan İşler',
                        style: TextStyle(fontSize: 15, color: OrjandaRenkleri.yaziSoluk),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: OrjandaRenkleri.cizgi),
                Expanded(
                  child: StreamBuilder<List<IsKaydi>>(
                    stream: _db.tamamlananIsleriDinle(_kullaniciId),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final isler = snap.data!;
                      if (isler.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Henüz kayıtlı iş yok.\nYeni bir iş oluşturmak için aşağıdaki butonu kullan.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: OrjandaRenkleri.yaziSoluk, height: 1.5),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: isler.length,
                        itemBuilder: (context, i) => _isKarti(isler[i]),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _aktifIseDon(aktifIs),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: OrjandaRenkleri.turuncu),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Aktif İşe Dön',
                              style: TextStyle(color: OrjandaRenkleri.yazi, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _yeniIsOlustur(aktifIs),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OrjandaRenkleri.turuncu,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Yeni İş Oluştur',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _isKarti(IsKaydi is_) {
    return GestureDetector(
      onTap: () => _detayGoster(is_),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: OrjandaRenkleri.cizgi, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('İş Adı:', style: TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 13)),
            const SizedBox(height: 6),
            _cerceveliAlan(is_.isAdi, ortala: true, kalin: true),
            const SizedBox(height: 12),
            const Text('Başlama ve bitiş tarihi:', style: TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: OrjandaRenkleri.turuncu),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_tarihFormat.format(is_.baslamaTarihi),
                      style: const TextStyle(color: OrjandaRenkleri.acikYesil, fontWeight: FontWeight.bold)),
                  Text(
                    is_.bitisTarihi != null ? _tarihFormat.format(is_.bitisTarihi!) : '-',
                    style: const TextStyle(color: OrjandaRenkleri.kirmizi, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: OrjandaRenkleri.turuncu),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${is_.gunSayisi}',
                        style: const TextStyle(color: OrjandaRenkleri.acikYesil, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    const Text('Gün', style: TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cerceveliAlan(String metin, {bool ortala = false, bool kalin = false, Color? renk}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: OrjandaRenkleri.turuncu),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        metin,
        textAlign: ortala ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          color: renk ?? OrjandaRenkleri.yazi,
          fontWeight: kalin ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
    );
  }

  void _detayGoster(IsKaydi is_) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OrjandaRenkleri.kart,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: OrjandaRenkleri.cizgi, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Text('İş Adı', style: TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 13)),
                const SizedBox(height: 6),
                _cerceveliAlan(is_.isAdi, ortala: true, kalin: true),
                const SizedBox(height: 14),
                const Text('Başlama ve Bitiş Tarihi', style: TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: OrjandaRenkleri.turuncu),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_tarihFormat.format(is_.baslamaTarihi),
                          style: const TextStyle(color: OrjandaRenkleri.acikYesil, fontWeight: FontWeight.bold)),
                      Text(
                        is_.bitisTarihi != null ? _tarihFormat.format(is_.bitisTarihi!) : '-',
                        style: const TextStyle(color: OrjandaRenkleri.kirmizi, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Pusula Sahipleri', style: TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  constraints: is_.pusulalar.length > 3
                      ? const BoxConstraints(maxHeight: 220)
                      : const BoxConstraints(),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: OrjandaRenkleri.cizgi),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: is_.pusulalar.length > 3
                      ? SingleChildScrollView(
                          child: Column(
                            children: is_.pusulalar
                                .map((p) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _cerceveliAlan(p.isim, ortala: true, kalin: true),
                                    ))
                                .toList(),
                          ),
                        )
                      : Column(
                          children: is_.pusulalar
                              .map((p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _cerceveliAlan(p.isim, ortala: true, kalin: true),
                                  ))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 14),
                const Text('Toplam Kesilen Ağaç', style: TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 13)),
                const SizedBox(height: 6),
                _cerceveliAlan('${is_.toplamKesilenAgac}', ortala: true, kalin: true, renk: OrjandaRenkleri.acikYesil),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrjandaRenkleri.turuncu,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kapat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
