// ================================================================
// core/utils/data_state.dart — حالات البيانات الموحّدة (بند 4)
// استخدم هذا بدل bool isLoading في كل الشاشات
// ================================================================
// ignore_for_file: unreachable_switch_case

import '../errors/app_exception.dart';

/// حالة البيانات — كل شاشة تعرض إحدى هذه الحالات
sealed class DataState<T> {
  const DataState();
}

/// جاري التحميل
class Loading<T> extends DataState<T> {
  const Loading();
}

/// نجح الجلب — بيانات جاهزة
class Success<T> extends DataState<T> {
  final T data;
  const Success(this.data);
}

/// فارغ — لا توجد بيانات
class Empty<T> extends DataState<T> {
  final String? messageAr;
  final String? messageEn;
  const Empty({this.messageAr, this.messageEn});
  String message(bool isArabic) => isArabic
      ? (messageAr ?? 'لا توجد بيانات')
      : (messageEn ?? 'No data found');
}

/// حالة خطأ
class Failure<T> extends DataState<T> {
  final AppException exception;
  const Failure(this.exception);
  String message(bool isArabic) =>
      isArabic ? exception.userMessage : exception.message;
}

/// بدون إنترنت — يعرض بيانات محلية
class Offline<T> extends DataState<T> {
  final T? cachedData;
  final DateTime? lastUpdated;
  const Offline({this.cachedData, this.lastUpdated});
}

/// انتهت مهلة الطلب
class TimedOut<T> extends DataState<T> {
  final T? cachedData;
  const TimedOut({this.cachedData});
}

// ── Extension helpers ───────────────────────────────────────────
extension DataStateX<T> on DataState<T> {
  bool get isLoading => this is Loading<T>;
  bool get isSuccess => this is Success<T>;
  bool get isEmpty => this is Empty<T>;
  bool get isFailure => this is Failure<T>;
  bool get isOffline => this is Offline<T>;
  bool get isTimedOut => this is TimedOut<T>;

  T? get data => switch (this) {
        Success<T> s => s.data,
        Offline<T> o => o.cachedData,
        TimedOut<T> t => t.cachedData,
        _ => null,
      };

  /// نفّذ كود بناءً على الحالة
  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String msg) failure,
    R Function(T? data)? offline,
    R Function()? empty,
  }) {
    return switch (this) {
      Loading() => loading(),
      Success<T> s => success(s.data),
      Failure<T> f => failure(f.exception.userMessage),
      Offline<T> o => offline != null ? offline(o.cachedData) : loading(),
      Empty() => empty != null ? empty() : loading(),
      TimedOut<T> t => offline != null ? offline(t.cachedData) : loading(),
      _ => loading(),
    };
  }
}

// ── Widget مساعد لعرض الحالات ──────────────────────────────────
// استخدمه في أي شاشة تحتاج تعرض Loading/Error/Empty/Success
//
// مثال الاستخدام:
//
// DataStateWidget(
//   state: p.goldPriceState,
//   loadingWidget: const ShimmerCard(),
//   emptyMessage: 'لا يوجد سعر',
//   builder: (price) => GoldPriceCard(price: price),
// )
