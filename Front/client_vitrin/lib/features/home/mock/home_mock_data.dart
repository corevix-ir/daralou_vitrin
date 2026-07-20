/// Static mock JSON payload simulating backend API response for debug and offline kiosk mode.
class HomeMockData {
  HomeMockData._();

  static final Map<String, dynamic> rawDashboardJson = {
    'locationTag': 'ساختمان مرکزی | لابی',
    'temperature': '28°C',
    'time': '10:24',
    'news': {
      'id': 'news_101',
      'categoryTag': 'اخبار رسمی',
      'title': 'پیشرفت پروژه فاز ۳ استخراج مس در منطقه جنوب غربی',
      'imageUrl': 'https://images.unsplash.com/photo-1578328819058-b69f3a3b0f6b?auto=format&fit=crop&w=1200&q=80',
      'publishedAt': 'امروز - ۰۸:۳۰',
      'totalSlides': 4,
      'activeIndex': 0,
    },
    'service': {
      'id': 'srv_201',
      'sectionTitle': 'مرکز خدمات پرسنلی',
      'title': 'رزرو مجموعه‌های ورزشی',
      'subtitle': 'سانس‌های استخر، سالن بدنسازی و زمین‌های ورزشی را رزرو کنید.',
      'buttonText': 'شروع رزرو',
    },
    'lme': {
      'title': 'قیمت مس LME',
      'priceFormatted': '\$9,450',
      'unit': 'تن',
      'trendPercent': '+2.1%',
      'isPositiveTrend': true,
      'timeFrame': '24h',
    },
    'stock': {
      'symbol': 'TSE: FAMELI',
      'changePercent': '+1.4%',
      'isPositive': true,
      'lastUpdatedTime': '۱۰:۲۰',
    },
    'floorGuide': {
      'title': 'راهنمای طبقات و دایرکتوری',
      'description': 'بخش‌ها، پرسنل و خروجی‌های اضطراری را در تمامی بخش‌های شرکت بیابید.',
    },
    'restaurant': {
      'title': 'منوی رستوران',
      'subtitle': 'مشاهده غذاهای امروز',
    },
    'transit': {
      'nextDepartureMinutes': '۵',
      'schedules': [
        {
          'time': '۱۰:۳۰',
          'routeName': 'سرویس الف',
          'gateName': 'دروازه جنوبی',
        },
        {
          'time': '۱۰:۴۵',
          'routeName': 'سرویس ب',
          'gateName': 'دروازه شمالی',
        },
      ],
    },
    'survey': {
      'title': 'امروز از خدمات ما راضی بودید؟',
      'subtitle': 'نظرات شما به ما در بهبود خدمات مجموعه کمک می‌کند.',
    },
    'emergencyMarqueeText':
        'وضعیت سیستم: فعال | پروتکل اضطراری فعال: با امنیت سایت داخلی ۹۱۱ تماس بگیرید | وضعیت سیستم: فعال | پروتکل اضطراری فعال: با امنیت سایت داخلی ۹۱۱ تماس بگیرید',
  };
}
