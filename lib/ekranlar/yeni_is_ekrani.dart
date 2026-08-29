import 'package:flutter/material.dart';

import '../modeller/is_kaydi.dart';
import '../modeller/pusula.dart';
import '../servisler/veritabani_servisi.dart';
import '../tema.dart';
import 'arsiv_ekrani.dart';

class KesimEkrani extends StatefulWidget {
  final IsKaydi isKaydi;
  const KesimEkrani({super.key, required this.isKaydi});

  @override
  State<KesimEkrani> createState() => _KesimEkraniState();
}

class _KesimEkraniState extends State<KesimEkrani> {
  final _db = VeritabaniServisi();
  final _aramaController = TextEditingController();

  late final String _isId = widget.isKaydi.id!;
  late String _isAdi = widget.isKaydi.isAdi;
  late List<Pusula> _pusulalar = widget.isKaydi.pusulalar;
  int _seciliIndex = 0;
  final _pusulaSeciciKey = GlobalKey();

  void _kaydet() {
    _db.pusulalariGuncelle(_isId, _pusulalar);
  }

  Pusula? get _seciliPusula => _pusulalar.isEmpty ? null : _pusulalar[_seciliIndex];

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pusula = _seciliPusula;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: OrjandaRenkleri.turuncu),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_isAdi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: OrjandaRenkleri.yazi)),
            ),
            GestureDetector(
              key: _pusulaSeciciKey,
              onTap: _pusulaSeciciAc,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: OrjandaRenkleri.cizgi),
                  borderRadius: BorderRadius.circular(12),
                  color: OrjandaRenkleri.kart,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pusula?.isim ?? 'Pusula Sahibi', style: const TextStyle(color: OrjandaRenkleri.yazi)),
                    const Icon(Icons.expand_more, color: OrjandaRenkleri.yaziSoluk, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                    decoration: BoxDecoration(
                      border: Border.all(color: OrjandaRenkleri.turuncu),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11, color: OrjandaRenkleri.yaziSoluk, fontWeight: FontWeight.w600),
                        children: [
                          const TextSpan(text: 'KALAN AĞAÇ: '),
                          TextSpan(
                            text: '${pusula?.kalanAdet ?? 0}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: OrjandaRenkleri.acikYesil),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 84,
                        height: 36,
                        child: TextField(
                          controller: _aramaController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Ağaç Ara',
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _agacAra,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: OrjandaRenkleri.yesil,
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.search, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: OrjandaRenkleri.turuncu),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: pusula == null
                    ? const Center(
                        child: Text('Henüz pusula yok.', style: TextStyle(color: OrjandaRenkleri.yaziSoluk)))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: pusula.toplamAgac,
                        itemBuilder: (context, i) {
                          final numara = pusula.basNo + i;
                          final kesildi = pusula.kesilenNumaralar.contains(numara);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (kesildi) {
                                  pusula.kesilenNumaralar.remove(numara);
                                } else {
                                  pusula.kesilenNumaralar.add(numara);
                                }
                              });
                              _kaydet();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: kesildi ? const Color(0xFF2E7D32) : const Color(0xFFC9C4B6),
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$numara',
                                style: TextStyle(
                                  color: kesildi ? Colors.white : const Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: 220,
                child: OutlinedButton(
                  onPressed: _menuAc,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: OrjandaRenkleri.turuncu),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.menu, color: OrjandaRenkleri.yazi),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pusulaSeciciAc() async {
    final kutu = _pusulaSeciciKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (kutu == null || overlay == null) return;

    final kutuUstSol = kutu.localToGlobal(Offset.zero, ancestor: overlay);
    final pozisyon = RelativeRect.fromLTRB(
      kutuUstSol.dx,
      kutuUstSol.dy + kutu.size.height + 4,
      overlay.size.width - (kutuUstSol.dx + kutu.size.width),
      0,
    );

    final secilenIndex = await showMenu<int>(
      context: context,
      position: pozisyon,
      color: OrjandaRenkleri.kart,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: OrjandaRenkleri.turuncu),
      ),
      constraints: BoxConstraints(minWidth: kutu.size.width, maxWidth: kutu.size.width),
      items: _pusulalar.asMap().entries.map((e) {
        return PopupMenuItem<int>(
          value: e.key,
          child: Text(e.value.isim, style: const TextStyle(color: OrjandaRenkleri.yazi)),
        );
      }).toList(),
    );

    if (secilenIndex != null) {
      setState(() => _seciliIndex = secilenIndex);
    }
  }

  void _agacAra() {
    final numara = int.tryParse(_aramaController.text.trim());
    Pusula? eslesen;
    if (numara != null) {
      for (final p in _pusulalar) {
        if (numara >= p.basNo && numara <= p.sonNo) {
          eslesen = p;
          break;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OrjandaRenkleri.kart,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: OrjandaRenkleri.turuncu)),
        content: eslesen != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bilgiKutusu('Ağaç No', '$numara', OrjandaRenkleri.yazi),
                  const SizedBox(height: 12),
                  _bilgiKutusu('Pusula Sahibi', eslesen.isim, OrjandaRenkleri.acikYesil),
                ],
              )
            : const Text('Bu ağaç sisteme kayıtlı değil.',
                textAlign: TextAlign.center, style: TextStyle(color: OrjandaRenkleri.yazi, fontWeight: FontWeight.w600)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _aramaController.clear();
              },
              style: ElevatedButton.styleFrom(backgroundColor: OrjandaRenkleri.turuncu),
              child: const Text('Tamam', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  /// "Tamam" butonu — açılışta turuncu rengin soldan sağa doluşuyla belirir.
  Widget _dolanTamamButonu(BuildContext dialogContext) {
    return Container(
      width: double.infinity,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OrjandaRenkleri.turuncu),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(dialogContext),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOut,
                  builder: (context, deger, child) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: deger,
                    child: Container(color: OrjandaRenkleri.turuncu),
                  ),
                ),
              ),
              const Text('Tamam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bilgiKutusu(String etiket, String deger, Color renk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: OrjandaRenkleri.turuncu), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(etiket, style: const TextStyle(color: OrjandaRenkleri.yaziSoluk, fontSize: 11, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(deger, style: TextStyle(color: renk, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _menuAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: OrjandaRenkleri.kart,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: OrjandaRenkleri.cizgi, borderRadius: BorderRadius.circular(2)),
              ),
              _sheetButon('Pusula Ekle', OrjandaRenkleri.turuncu, OrjandaRenkleri.yazi, () {
                Navigator.pop(context);
                _pusulaEkleAc();
              }),
              const SizedBox(height: 12),
              _sheetButon('Pusula Sil', OrjandaRenkleri.turuncu, Colors.white, () {
                Navigator.pop(context);
                _pusulaSilAc();
              }),
              const SizedBox(height: 12),
              _sheetButon('İşi Bitir', Colors.white, Colors.white, () {
                Navigator.pop(context);
                _isiBitir();
              }, dolu: true),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetButon(String metin, Color kenar, Color yazi, VoidCallback onTap, {bool dolu = false}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: kenar),
          backgroundColor: dolu ? const Color(0xFF2E7D32) : null,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(metin, style: TextStyle(color: yazi, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  void _pusulaEkleAc() {
    final isimController = TextEditingController();
    final basController = TextEditingController();
    final sonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: OrjandaRenkleri.kart,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: OrjandaRenkleri.turuncu)),
          title: const Text('Yeni Pusula', textAlign: TextAlign.center, style: TextStyle(color: OrjandaRenkleri.yazi)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: isimController,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Pusula Sahibi'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: basController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: 'Baş Numara'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: sonController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: 'Son Numara'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: OrjandaRenkleri.cizgi)),
                    child: const Text('Vazgeç', style: TextStyle(color: OrjandaRenkleri.yaziSoluk)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isimController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Pusula Sahibi ismini girmelisin.')));
                        return;
                      }
                      int bas = int.tryParse(basController.text.trim()) ?? 1;
                      int son = int.tryParse(sonController.text.trim()) ?? (bas + 9);
                      if (son < bas) son = bas + 9;
                      final yeniPusula = Pusula(isim: isimController.text.trim(), basNo: bas, sonNo: son);
                      setState(() {
                        _pusulalar.add(yeniPusula);
                        _seciliIndex = _pusulalar.length - 1;
                      });
                      _kaydet();
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _basariGoster(yeniPusula.isim, '${yeniPusula.basNo} - ${yeniPusula.sonNo}');
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: OrjandaRenkleri.turuncu),
                    child: const Text('Ekle', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _basariGoster(String isim, String aralik) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: OrjandaRenkleri.kart,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: OrjandaRenkleri.turuncu)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Oluşturulan Pusula Bilgileri',
                  style: TextStyle(color: OrjandaRenkleri.yazi, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _bilgiKutusu('Pusula Sahibi', isim, OrjandaRenkleri.acikYesil),
              const SizedBox(height: 12),
              _bilgiKutusu('Ağaç Aralığı', aralik, OrjandaRenkleri.yazi),
              const SizedBox(height: 20),
              _dolanTamamButonu(context),
            ],
          ),
        ),
      ),
    );
  }

  void _pusulaSilAc() {
    if (_pusulalar.isEmpty) return;
    final secilenler = <int>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: OrjandaRenkleri.kart,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: OrjandaRenkleri.turuncu)),
          title: const Text('Hangi pusulaları silmek istiyorsun?',
              textAlign: TextAlign.center, style: TextStyle(color: OrjandaRenkleri.yazi, fontSize: 15)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _pusulalar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final secili = secilenler.contains(i);
                return GestureDetector(
                  onTap: () => setDialogState(() {
                    if (secili) {
                      secilenler.remove(i);
                    } else {
                      secilenler.add(i);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: secili ? const Color(0x33C0392B) : null,
                      border: Border.all(color: secili ? const Color(0xFFC0392B) : OrjandaRenkleri.cizgi),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_pusulalar[i].isim} (${_pusulalar[i].basNo}-${_pusulalar[i].sonNo})',
                      style: TextStyle(color: secili ? Colors.white : OrjandaRenkleri.yazi, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: OrjandaRenkleri.cizgi)),
                    child: const Text('Vazgeç', style: TextStyle(color: OrjandaRenkleri.yaziSoluk)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (secilenler.isEmpty) {
                        Navigator.pop(context);
                        return;
                      }
                      final silinenIsimler = secilenler.map((i) => _pusulalar[i].isim).toList();
                      setState(() {
                        final kalanlar = <Pusula>[];
                        for (var i = 0; i < _pusulalar.length; i++) {
                          if (!secilenler.contains(i)) kalanlar.add(_pusulalar[i]);
                        }
                        _pusulalar = kalanlar;
                        if (_seciliIndex >= _pusulalar.length) {
                          _seciliIndex = _pusulalar.isEmpty ? 0 : _pusulalar.length - 1;
                        }
                      });
                      _kaydet();
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _silindiGoster(silinenIsimler);
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC0392B)),
                    child: const Text('Sil', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _silindiGoster(List<String> isimler) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: OrjandaRenkleri.kart,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: OrjandaRenkleri.turuncu)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seçilen Pusulalar Silindi',
                  style: TextStyle(color: OrjandaRenkleri.yazi, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...isimler.map((isim) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _bilgiKutusu('Pusula Sahibi', isim, OrjandaRenkleri.acikYesil),
                  )),
              const SizedBox(height: 4),
              _dolanTamamButonu(context),
            ],
          ),
        ),
      ),
    );
  }

  void _isiBitir() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OrjandaRenkleri.kart,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: OrjandaRenkleri.turuncu)),
        content: const Text(
          'İşi bitirmek istiyor musunuz? Bir daha bu iş düzenine geri dönemez ve düzenleyemezsiniz.',
          textAlign: TextAlign.center,
          style: TextStyle(color: OrjandaRenkleri.yazi, fontWeight: FontWeight.w600),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: OrjandaRenkleri.cizgi)),
                  child: const Text('Vazgeç', style: TextStyle(color: OrjandaRenkleri.yaziSoluk)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _isiBitirOnaylandi();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: OrjandaRenkleri.turuncu),
                  child: const Text('Evet, Bitir', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _isiBitirOnaylandi() {
    _db.isiBitir(_isId, DateTime.now());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ArsivEkrani()),
      (route) => false,
    );
  }
}
