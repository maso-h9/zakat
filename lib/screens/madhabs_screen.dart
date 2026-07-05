import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zakat_provider.dart';
import '../utils/theme.dart';

// ==============================
// نموذج بيانات مسألة المذاهب
// ==============================
class MadhabIssue {
  final String title;
  final String description;
  final String hanafi;
  final String maliki;
  final String shafii;
  final String hanbali;
  final String? preferred; // الراجح عند المحققين

  const MadhabIssue({
    required this.title,
    required this.description,
    required this.hanafi,
    required this.maliki,
    required this.shafii,
    required this.hanbali,
    this.preferred,
  });
}

const List<MadhabIssue> madhabIssues = [
  MadhabIssue(
    title: 'نصاب الذهب',
    description: 'الحد الأدنى الذي تجب فيه زكاة الذهب',
    hanafi: '20 مثقالاً = 85 غراماً تقريباً',
    maliki: '20 مثقالاً = 85 غراماً تقريباً',
    shafii: '20 مثقالاً = 85 غراماً تقريباً',
    hanbali: '20 مثقالاً = 85 غراماً تقريباً',
    preferred: 'اتفق العلماء الأربعة على هذا المقدار',
  ),
  MadhabIssue(
    title: 'زكاة حلي الذهب المستعمل',
    description: 'هل يُزكَّى الذهب المستخدم للزينة؟',
    hanafi: 'تجب الزكاة مطلقاً في كل ذهب وفضة بلغ النصاب',
    maliki: 'لا تجب في الحلي المباح المستعمل استعمالاً معتاداً',
    shafii: 'لا تجب في الحلي المباح المستعمل',
    hanbali: 'لا تجب في الحلي المباح على الراجح من المذهب',
    preferred:
        'الأحوط إخراج زكاته خروجاً من الخلاف، والمذهب الحنفي أكثر احتياطاً',
  ),
  MadhabIssue(
    title: 'ضم الذهب إلى الفضة',
    description: 'هل يُجمع الذهب والفضة لإكمال النصاب؟',
    hanafi: 'يُضم الذهب إلى الفضة بالقيمة لإكمال النصاب',
    maliki: 'يُضم الذهب إلى الفضة بالقيمة',
    shafii: 'لا يُضم الذهب إلى الفضة، لكل نصابه المستقل',
    hanbali: 'لا يُضم الذهب إلى الفضة في الأصح',
    preferred: 'قول الجمهور (عدم الضم) أحوط وأيسر على المزكّي',
  ),
  MadhabIssue(
    title: 'زكاة الدَّين',
    description: 'هل تجب الزكاة على الأموال التي في ذمة الغير؟',
    hanafi:
        'الدَّين القوي (المُقرّ به المرجو الأداء) تجب زكاته لكن لا تُؤدَّى حتى القبض',
    maliki: 'الدَّين المرجو تُزكَّى عند قبضه فقط عن سنة واحدة',
    shafii: 'تجب الزكاة في الدَّين ولو لم يُقبض، ويُخرجها من ماله الآخر',
    hanbali: 'الدَّين المرجو تجب زكاته لكل سنة مضت عند قبضه',
    preferred:
        'الأيسر: زكاته عند القبض لسنة واحدة (مذهب مالك)، والأحوط مذهب الشافعي',
  ),
  MadhabIssue(
    title: 'نصاب الزروع والثمار',
    description: 'الحد الأدنى الذي تجب فيه زكاة المحصول',
    hanafi: 'لا نصاب، تجب الزكاة في القليل والكثير',
    maliki: 'خمسة أوسق = 653 كيلوغراماً تقريباً',
    shafii: 'خمسة أوسق = 653 كيلوغراماً تقريباً',
    hanbali: 'خمسة أوسق = 653 كيلوغراماً تقريباً',
    preferred: 'جمهور العلماء على اشتراط النصاب وهو الأقوى دليلاً',
  ),
  MadhabIssue(
    title: 'نسبة زكاة الزروع المروية بآلة',
    description: 'نسبة الزكاة في المحصول المسقي بمضخة أو آلة',
    hanafi: 'نصف العشر (5%) في كل حال عند بعضهم، والعشر إن روي بلا مؤونة',
    maliki: 'نصف العشر (5%) إذا كانت المؤونة كثيرة',
    shafii: 'نصف العشر (5%) إذا روي بمؤونة',
    hanbali: 'نصف العشر (5%) إذا روي بمؤونة',
    preferred: 'اتفق الجمهور على نصف العشر عند الري بالآلة',
  ),
  MadhabIssue(
    title: 'زكاة العروض التجارية',
    description: 'هل تجب الزكاة في البضائع المعدّة للبيع؟',
    hanafi: 'تجب بنسبة 2.5% على قيمة البضاعة عند تمام الحول',
    maliki: 'تجب بنسبة 2.5% على قيمة البضاعة',
    shafii: 'تجب بنسبة 2.5% على قيمة البضاعة',
    hanbali: 'تجب بنسبة 2.5% على قيمة البضاعة',
    preferred: 'اتفاق كامل بين المذاهب الأربعة',
  ),
  MadhabIssue(
    title: 'تعجيل الزكاة قبل الحول',
    description: 'هل يجوز إخراج الزكاة قبل تمام سنة كاملة؟',
    hanafi: 'يجوز تعجيل الزكاة لسنة أو سنتين',
    maliki: 'لا يجوز إلا قبل الحول بيسير (أيام قليلة)',
    shafii: 'يجوز تعجيلها بعد ملك النصاب',
    hanbali: 'يجوز تعجيلها لسنتين',
    preferred: 'الجمهور يجيز التعجيل، وهو الأرفق بالمزكّين في العصر الحاضر',
  ),
];

// ==============================
// الشاشة الرئيسية
// ==============================
class MadhabsComparisonScreen extends StatefulWidget {
  const MadhabsComparisonScreen({super.key});

  @override
  State<MadhabsComparisonScreen> createState() =>
      _MadhabsComparisonScreenState();
}

class _MadhabsComparisonScreenState extends State<MadhabsComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ZakatProvider>();
    final isDark = p.isDarkMode;
    final bg = ZakatTheme.scaffoldBgAdaptive(isDark);
    final appBarColor = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: const Text('مقارنة المذاهب الأربعة'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: ZakatTheme.gold,
            indicatorWeight: 3,
            labelColor: ZakatTheme.gold,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 14,
                fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'المسائل المقارنة'),
              Tab(text: 'جدول سريع'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildIssuesList(isDark),
            _buildQuickTable(isDark),
          ],
        ),
      ),
    );
  }

  // ==============================
  // تبويب 1: قائمة المسائل
  // ==============================
  Widget _buildIssuesList(bool isDark) {
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بانر تعريفي
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient:
                isDark ? ZakatTheme.darkModeGradient : ZakatTheme.mainGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Text('📚', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'يُعرض رأي كل مذهب من المذاهب الأربعة في المسائل الرئيسية للزكاة مع ذكر الراجح عند المحققين',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Scheherazade',
                      fontSize: 13,
                      height: 1.6),
                ),
              ),
            ],
          ),
        ),

        ...List.generate(madhabIssues.length, (i) {
          final issue = madhabIssues[i];
          final isExpanded = _expandedIndex == i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
              border: Border.all(
                color: isExpanded
                    ? ZakatTheme.gold.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                // Header
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      setState(() => _expandedIndex = isExpanded ? -1 : i),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ZakatTheme.gold.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: ZakatTheme.gold,
                                    fontFamily: 'Scheherazade',
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(issue.title,
                                  style: TextStyle(
                                      fontFamily: 'Scheherazade',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                              const SizedBox(height: 2),
                              Text(issue.description,
                                  style: TextStyle(
                                      fontFamily: 'Scheherazade',
                                      fontSize: 12,
                                      color: isDark
                                          ? ZakatTheme.darkTextSecondary
                                          : ZakatTheme.lightText)),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: ZakatTheme.gold,
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanded content
                if (isExpanded) ...[
                  Divider(
                      height: 1,
                      color: isDark
                          ? ZakatTheme.darkBorder
                          : const Color(0xFFEEE8D5)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _madhabRow('🟢 الحنفية', issue.hanafi,
                            const Color(0xFF1565C0), isDark),
                        const SizedBox(height: 10),
                        _madhabRow('🟡 المالكية', issue.maliki,
                            const Color(0xFF6A1B9A), isDark),
                        const SizedBox(height: 10),
                        _madhabRow('🔵 الشافعية', issue.shafii,
                            const Color(0xFF00695C), isDark),
                        const SizedBox(height: 10),
                        _madhabRow('🔴 الحنابلة', issue.hanbali,
                            const Color(0xFFC62828), isDark),
                        if (issue.preferred != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ZakatTheme.gold.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: ZakatTheme.gold.withOpacity(0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline,
                                    color: ZakatTheme.gold, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'الراجح: ${issue.preferred}',
                                    style: TextStyle(
                                        fontFamily: 'Scheherazade',
                                        fontSize: 13,
                                        height: 1.7,
                                        color: isDark
                                            ? ZakatTheme.gold
                                            : ZakatTheme.medText),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _madhabRow(String name, String opinion, Color color, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(name,
              style: TextStyle(
                  color: color,
                  fontFamily: 'Scheherazade',
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            opinion,
            style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 14,
              height: 1.6,
              color: isDark ? ZakatTheme.darkTextSecondary : ZakatTheme.medText,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================
  // تبويب 2: جدول سريع
  // ==============================
  Widget _buildQuickTable(bool isDark) {
    final cardColor = ZakatTheme.cardBgAdaptive(isDark);
    final headerColor = isDark ? const Color(0xFF0A2A1A) : ZakatTheme.deepGreen;
    final textColor = isDark ? ZakatTheme.darkTextPrimary : ZakatTheme.darkText;

    final rows = [
      ['نصاب الذهب', '85 غ', '85 غ', '85 غ', '85 غ'],
      ['نصاب الفضة', '595 غ', '595 غ', '595 غ', '595 غ'],
      ['حلي الذهب', 'تُزكَّى', 'لا تُزكَّى', 'لا تُزكَّى', 'لا تُزكَّى'],
      ['ضم الذهب والفضة', 'يُضم', 'يُضم', 'لا يُضم', 'لا يُضم'],
      ['نسبة النقود', '2.5%', '2.5%', '2.5%', '2.5%'],
      ['زكاة الزروع', 'بلا نصاب', '653 كغ', '653 كغ', '653 كغ'],
      ['تعجيل الزكاة', 'يجوز', 'يُكره', 'يجوز', 'يجوز'],
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ZakatTheme.cardShadowAdaptive(isDark),
        ),
        child: Column(
          children: [
            // Header row
            Container(
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Table(
                children: [
                  TableRow(
                    children: [
                      _headerCell('المسألة'),
                      _headerCell('حنفي'),
                      _headerCell('مالكي'),
                      _headerCell('شافعي'),
                      _headerCell('حنبلي'),
                    ],
                  ),
                ],
              ),
            ),
            // Data rows
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(
                    color: isDark
                        ? ZakatTheme.darkBorder
                        : const Color(0xFFEEE8D5),
                    width: 0.5),
              ),
              children: List.generate(rows.length, (i) {
                final row = rows[i];
                final isEven = i % 2 == 0;
                return TableRow(
                  decoration: BoxDecoration(
                    color: isEven
                        ? (isDark
                            ? Colors.white.withOpacity(0.02)
                            : ZakatTheme.cream.withOpacity(0.3))
                        : Colors.transparent,
                  ),
                  children: row
                      .map((cell) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            child: Text(
                              cell,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Scheherazade',
                                  fontSize: 12,
                                  color: textColor),
                            ),
                          ))
                      .toList(),
                );
              }),
            ),
            // Footer note
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                '* يُنصح بمراجعة عالم متخصص للمسائل التفصيلية في حالتك الخاصة',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 12,
                    color: isDark
                        ? ZakatTheme.darkTextSecondary
                        : ZakatTheme.lightText,
                    height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Scheherazade',
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
