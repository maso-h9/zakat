// ================================================================
// ramadan_screen.dart — وضع رمضان متوافق مع Dark Mode العام
// ================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});
  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _moonCtrl;

  final List<Map<String, String>> _sadaqahAhadith = [
    {
      'text':
          'كانَ النَّبيُّ صلَّى اللهُ عليه وسلَّمَ أجوَدَ النَّاسِ، وكانَ أجوَدُ ما يكونُ في رمضانَ',
      'narrator': 'ابن عباس رضي الله عنهما',
      'source': 'متفق عليه',
    },
    {
      'text':
          'مَن فطَّرَ صائمًا كانَ له مثلُ أجرِه، غيرَ أنَّه لا يَنقُصُ من أجرِ الصَّائمِ شيئًا',
      'narrator': 'زيد بن خالد الجهني رضي الله عنه',
      'source': 'صحيح الترمذي',
    },
    {
      'text': 'أفضَلُ الصَّدقةِ صدقةٌ في رمضانَ',
      'narrator': 'أنس بن مالك رضي الله عنه',
      'source': 'صحيح الترمذي',
    },
  ];

  int _hadithIdx = 0;

  @override
  void initState() {
    super.initState();
    _moonCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _moonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;

    return Directionality(
      textDirection: p.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        // وضع رمضان دائماً يستخدم الثيم الليلي الخاص به بصرف النظر عن Dark Mode العام
        data: _ramadanTheme(),
        child: Scaffold(
          backgroundColor: p.isRamadanMode
              ? const Color(0xFF0D1B3E)
              : ZakatTheme.scaffoldBgAdaptive(isDark),
          appBar: AppBar(
            title: Text(
              p.isRamadanMode
                  ? (p.isArabic ? '🌙 وضع رمضان' : '🌙 Ramadan Mode')
                  : (p.isArabic ? 'وضع رمضان' : 'Ramadan Mode'),
              style: TextStyle(
                fontFamily: 'Scheherazade',
                color: p.isRamadanMode ? const Color(0xFFFFD700) : Colors.white,
              ),
            ),
            backgroundColor: p.isRamadanMode
                ? const Color(0xFF0A1428)
                : (isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Switch(
                  value: p.isRamadanMode,
                  activeColor: const Color(0xFFFFD700),
                  onChanged: p.toggleRamadanMode,
                ),
              ),
            ],
          ),
          body:
              p.isRamadanMode ? _buildRamadanBody(p) : _buildOffBody(p, isDark),
        ),
      ),
    );
  }

  ThemeData _ramadanTheme() => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B3E),
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFF4FC3F7),
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Scheherazade'),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1A2A5E),
          border: OutlineInputBorder(borderSide: BorderSide.none),
          labelStyle:
              TextStyle(color: Colors.white70, fontFamily: 'Scheherazade'),
        ),
      );

  // ==============================
  // وضع رمضان مفعّل
  // ==============================
  Widget _buildRamadanBody(ZakatProvider p) {
    return SingleChildScrollView(
      child: Column(children: [
        _buildRamadanHeader(p),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _buildFitrCard(p),
            const SizedBox(height: 16),
            _buildDaysCounter(p),
            const SizedBox(height: 16),
            _buildSadaqahHadith(),
            const SizedBox(height: 16),
            _buildDailyReminders(p),
            const SizedBox(height: 16),
            _buildFadailCard(p),
            const SizedBox(height: 32),
          ]),
        ),
      ]),
    );
  }

  Widget _buildRamadanHeader(ZakatProvider p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1428), Color(0xFF1A2A5E)],
        ),
      ),
      child: Column(children: [
        AnimatedBuilder(
          animation: _moonCtrl,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _moonCtrl.value * 6 - 3),
            child: const Text('🌙', style: TextStyle(fontSize: 56)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          p.isArabic ? 'رمضان كريم' : 'Ramadan Kareem',
          style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Scheherazade'),
        ),
        const SizedBox(height: 6),
        const Text(
          '﴿شَهْرُ رَمَضَانَ الَّذِي أُنزِلَ فِيهِ الْقُرْآنُ﴾',
          style: TextStyle(
              color: Color(0xFFB0BEC5),
              fontSize: 16,
              fontFamily: 'Scheherazade',
              height: 1.8),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _buildFitrCard(ZakatProvider p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A2A5E), Color(0xFF243B74)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('⭐', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(p.isArabic ? 'زكاة الفطر' : 'Zakat Al-Fitr',
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Scheherazade')),
        ]),
        const SizedBox(height: 12),
        Text(
          p.isArabic
              ? 'فرضها رسول الله ﷺ طهرةً للصائم من اللغو والرفث، وطُعمةً للمساكين.'
              : 'Prescribed by the Prophet ﷺ as purification for the fasting person and food for the poor.',
          style: const TextStyle(
              color: Color(0xFFB0BEC5),
              fontSize: 14,
              height: 1.7,
              fontFamily: 'Scheherazade'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
          ),
          child: Column(children: [
            _fitrRow(
                p.isArabic ? 'المقدار' : 'Amount',
                p.isArabic
                    ? 'صاع = 2.5 كيلوغرام من قوت البلد'
                    : 'One Sa\' ≈ 2.5kg of staple food'),
            const SizedBox(height: 8),
            _fitrRow(
                p.isArabic ? 'وقتها' : 'Timing',
                p.isArabic
                    ? 'من غروب آخر يوم رمضان حتى صلاة العيد'
                    : 'From last day of Ramadan until Eid prayer'),
            const SizedBox(height: 8),
            _fitrRow(p.isArabic ? 'قيمتها التقريبية' : 'Approx. value',
                '${p.fitrAmount.toStringAsFixed(0)} ${p.currencySymbol} ${p.isArabic ? "للفرد" : "per person"}'),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => p.markFitrPaid(true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    p.fitrPaid ? Colors.green : const Color(0xFFFFD700),
                foregroundColor: p.fitrPaid ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(
                  p.fitrPaid ? Icons.check_circle : Icons.volunteer_activism),
              label: Text(
                p.fitrPaid
                    ? (p.isArabic ? 'تم إخراجها ✓' : 'Paid ✓')
                    : (p.isArabic ? 'سجّل إخراج الفطر' : 'Record Payment'),
                style:
                    const TextStyle(fontFamily: 'Scheherazade', fontSize: 15),
              ),
            ),
          ),
          if (p.fitrPaid) ...[
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: () => p.markFitrPaid(false)),
          ],
        ]),
      ]),
    );
  }

  Widget _fitrRow(String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: ',
          style: const TextStyle(
              color: Color(0xFFFFD700),
              fontFamily: 'Scheherazade',
              fontSize: 14,
              fontWeight: FontWeight.bold)),
      Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Scheherazade',
                  fontSize: 14,
                  height: 1.5))),
    ]);
  }

  Widget _buildDaysCounter(ZakatProvider p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A5E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(p.isArabic ? 'اليوم من رمضان' : 'Day of Ramadan',
            style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Scheherazade',
                fontSize: 14)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: Color(0xFFFFD700)),
            onPressed: () =>
                setState(() => _hadithIdx = (_hadithIdx - 1).clamp(1, 30)),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD700), width: 2)),
            child: Center(
                child: Text('${_hadithIdx + 1}',
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Scheherazade'))),
          ),
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: Color(0xFFFFD700)),
            onPressed: () =>
                setState(() => _hadithIdx = (_hadithIdx + 1).clamp(0, 29)),
          ),
        ]),
        Text(
          p.isArabic
              ? 'متبقٍ ${30 - _hadithIdx - 1} يوم على نهاية الشهر'
              : '${30 - _hadithIdx - 1} days left in the month',
          style: const TextStyle(
              color: Colors.white54, fontFamily: 'Scheherazade', fontSize: 13),
        ),
      ]),
    );
  }

  Widget _buildSadaqahHadith() {
    final h = _sadaqahAhadith[_hadithIdx % _sadaqahAhadith.length];
    return GestureDetector(
      onTap: () => setState(
          () => _hadithIdx = (_hadithIdx + 1) % _sadaqahAhadith.length),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2A5E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('✨ حديث الصدقة',
                  style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontFamily: 'Scheherazade',
                      fontSize: 13)),
            ),
            const Spacer(),
            const Text('اضغط للتالي',
                style: TextStyle(
                    color: Colors.white38,
                    fontFamily: 'Scheherazade',
                    fontSize: 12)),
          ]),
          const SizedBox(height: 14),
          Text('❝ ${h['text']} ❞',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 2.0,
                  fontFamily: 'Scheherazade')),
          const SizedBox(height: 10),
          Text('رواه ${h['narrator']} — ${h['source']}',
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 12,
                  fontFamily: 'Scheherazade')),
        ]),
      ),
    );
  }

  Widget _buildDailyReminders(ZakatProvider p) {
    final reminders = p.isArabic
        ? [
            {'icon': '🌅', 'title': 'السحور', 'desc': 'تسحّر ولو بجرعة ماء'},
            {'icon': '🤲', 'title': 'الدعاء', 'desc': 'لا ترد دعوة الصائم'},
            {
              'icon': '📖',
              'title': 'القرآن',
              'desc': 'ختم القرآن في رمضان سنة'
            },
            {
              'icon': '💰',
              'title': 'الصدقة',
              'desc': 'أفضل الصدقة صدقة في رمضان'
            },
          ]
        : [
            {
              'icon': '🌅',
              'title': 'Suhoor',
              'desc': 'Eat even a sip of water'
            },
            {
              'icon': '🤲',
              'title': 'Dua',
              'desc': 'A fasting person\'s dua is not rejected'
            },
            {
              'icon': '📖',
              'title': 'Quran',
              'desc': 'Completing Quran is Sunnah'
            },
            {
              'icon': '💰',
              'title': 'Charity',
              'desc': 'Best charity is in Ramadan'
            },
          ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.isArabic ? 'تذكيرات يومية' : 'Daily Reminders',
          style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Scheherazade')),
      const SizedBox(height: 10),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: reminders.length,
        itemBuilder: (_, i) {
          final r = reminders[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF1A2A5E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.15))),
            child: Row(children: [
              Text(r['icon']!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(r['title']!,
                          style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Scheherazade')),
                      Text(r['desc']!,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontFamily: 'Scheherazade'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ]),
              ),
            ]),
          );
        },
      ),
    ]);
  }

  Widget _buildFadailCard(ZakatProvider p) {
    final items = p.isArabic
        ? [
            'الصدقة في رمضان مضاعفة الأجر بإذن الله',
            'من فطّر صائماً كان له مثل أجره',
            'الجود في رمضان كان طبع النبي ﷺ',
            'إطعام الطعام من أسباب دخول الجنة',
          ]
        : [
            'Charity in Ramadan multiplies rewards',
            'Feeding a fasting person earns equal reward',
            'Generosity in Ramadan was the Prophet\'s ﷺ nature',
            'Feeding others leads to Paradise',
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1A2A5E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            p.isArabic
                ? 'فضائل الصدقة في رمضان'
                : 'Virtues of Charity in Ramadan',
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Scheherazade')),
        const SizedBox(height: 12),
        ...items.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('⭐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(f,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.6,
                            fontFamily: 'Scheherazade'))),
              ]),
            )),
      ]),
    );
  }

  // ==============================
  // وضع رمضان معطّل
  // ==============================
  Widget _buildOffBody(ZakatProvider p, bool isDark) {
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;
    final subColor = isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: ZakatTheme.cardShadowAdaptive(isDark)),
          child: Column(children: [
            const Text('🌙', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(p.isArabic ? 'وضع رمضان' : 'Ramadan Mode',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Scheherazade',
                    color: textColor)),
            const SizedBox(height: 8),
            Text(
              p.isArabic
                  ? 'فعّل الوضع عند دخول شهر رمضان المبارك للحصول على تجربة مخصصة تشمل زكاة الفطر وأحاديث الصدقة والتذكيرات اليومية.'
                  : 'Enable this mode during Ramadan for a custom experience with Zakat Al-Fitr, charity hadiths and daily reminders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: subColor,
                  fontSize: 15,
                  height: 1.8,
                  fontFamily: 'Scheherazade'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => p.toggleRamadanMode(true),
              icon: const Text('🌙'),
              label: Text(
                  p.isArabic ? 'تفعيل وضع رمضان' : 'Enable Ramadan Mode',
                  style: const TextStyle(
                      fontFamily: 'Scheherazade', fontSize: 16)),
            ),
          ]),
        ),
      ]),
    );
  }
}
