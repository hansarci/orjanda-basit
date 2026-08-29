import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../modeller/is_kaydi.dart';
import '../modeller/pusula.dart';
import '../servisler/kimlik_servisi.dart';
import '../servisler/veritabani_servisi.dart';
import '../tema.dart';
import 'kesim_ekrani.dart';

/// Yazılan her harfi, Türkçe kurallarına uygun şekilde büyük harfe çevirir
/// (örn. 'i' -> 'İ', 'ı' -> 'I'; Dart'ın varsayılan toUpperCase()'i bunu
/// İngilizce kurallarına göre yanlış yapar).
class _TurkceBuyukHarfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue eskiDeger, TextEditingValue yeniDeger) {
    final buyukMetin = yeniDeger.text.split('').map((harf) {
      if (harf == 'i') return 'İ';
      if (harf == 'ı') return 'I';
      return harf.toUpperCase();
    }).join();

    return yeniDeger.copyWith(text: buyukMetin, selection: yeniDeger.selection);
  }
}

class _PusulaFormu {
  final TextEditingController isim = TextEditingController();
  final TextEditingController basNo = TextEditingController();
  final TextEditingController sonNo = TextEditingController();
}

class YeniIsEkrani extends StatefulWidget {
  const YeniIsEkrani({super.key});

  @override
  State<YeniIsEkrani> createState() => _YeniIsEkraniState();
}

class _YeniIsEkraniState extends State<YeniIsEkrani> {
  final _db = VeritabaniServisi();
  final _kimlikServisi = KimlikServisi();
  final _isAdiController = TextEditingController();

  int _seciliPusulaSayisi = 0;
  final List<_PusulaFormu> _formlar = [];
  bool _kaydediliyor = false;

  void _pusulaSayisiSec(int sayi) {
    setState(() {
      _seciliPusulaSayisi = sayi;
      _formlar.clear();
      for (int i = 0; i < sayi; i++) {
        _formlar.add(_PusulaFormu());
      }
    });
  }

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

  Future<void> _kesimeBasla() async {
    if (_isAdiController.text.trim().isEmpty) {
      _uyariGoster('Kesime başlamadan önce iş adını girmelisin.');
      return;
    }

    if (_formlar.isEmpty) {
      _uyariGoster('Kesime başlamadan önce en az 1 pusula formu doldurmalısın.');
      return;
    }

    final bosOlanlar = <int>[];
    for (var i = 0; i < _formlar.length; i++) {
      if (_formlar[i].isim.text.trim().isEmpty) bosOlanlar.add(i + 1);
    }
    if (bosOlanlar.isNotEmpty) {
      _uyariGoster('Pusula ${bosOlanlar.join(', ')} için Pusula Sahibi ismini girmelisin.');
      return;
    }

    setState(() => _kaydediliyor = true);

    final pusulalar = _formlar.map((f) {
      int basNo = int.tryParse(f.basNo.text.trim()) ?? 1;
      int sonNo = int.tryParse(f.sonNo.text.trim()) ?? (basNo + 9);
      if (sonNo < basNo) sonNo = basNo + 9;
      return Pusula(isim: f.isim.text.trim(), basNo: basNo, sonNo: sonNo);
    }).toList();

    final yeniIs = IsKaydi(
      kullaniciId: _kimlikServisi.suankiKullanici!.uid,
      isAdi: _isAdiController.text.trim().isEmpty ? 'İş Adı' : _isAdiController.text.trim(),
      durum: 'aktif',
      baslamaTarihi: DateTime.now(),
      pusulalar: pusulalar,
    );

    final isId = await _db.yeniIsOlustur(yeniIs);
    yeniIs.id = isId;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => KesimEkrani(isKaydi: yeniIs)),
    );
  }

  @override
  void dispose() {
    _isAdiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 16, color: OrjandaRenkleri.turuncu),
                        label: const Text('Geri', style: TextStyle(color: OrjandaRenkleri.turuncu)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: OrjandaRenkleri.turuncu),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Yeni iş oluştur',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: OrjandaRenkleri.yazi),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _etiket('İş Adı'),
                    TextField(
                      controller: _isAdiController,
                      inputFormatters: [_TurkceBuyukHarfFormatter()],
                      decoration: const InputDecoration(hintText: 'Örn: Yayla Kesimi ya da Bölme Numarası'),
                    ),
                    const SizedBox(height: 22),
                    _etiket('Pusula Sayısı Gir'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        mainAxisExtent: 46,
                      ),
                      itemBuilder: (context, i) {
                        final numara = i + 1;
                        final secili = numara <= _seciliPusulaSayisi;
                        return GestureDetector(
                          onTap: () => _pusulaSayisiSec(numara),
                          child: Container(
                            decoration: BoxDecoration(
                              color: secili ? OrjandaRenkleri.turuncu : OrjandaRenkleri.kart,
                              border: Border.all(color: secili ? OrjandaRenkleri.turuncu : OrjandaRenkleri.cizgi),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$numara',
                              style: TextStyle(
                                color: secili ? Colors.white : OrjandaRenkleri.yazi,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_formlar.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 230),
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                        decoration: BoxDecoration(
                          border: Border.all(color: OrjandaRenkleri.cizgi),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListView.separated(
                          itemCount: _formlar.length,
                          separatorBuilder: (_, __) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: OrjandaRenkleri.cizgi),
                          ),
                          itemBuilder: (context, i) => _pusulaFormAlani(i),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _kaydediliyor ? null : _kesimeBasla,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrjandaRenkleri.turuncu,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _kaydediliyor
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Kesime Başla',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etiket(String metin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(metin, style: const TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 14)),
    );
  }

  Widget _pusulaFormAlani(int index) {
    final form = _formlar[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PUSULA ${index + 1}',
            style: const TextStyle(color: OrjandaRenkleri.turuncu, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        TextField(
          controller: form.isim,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Pusula Sahibi'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: form.basNo,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'Baş Numara'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: form.sonNo,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'Son Numara'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
