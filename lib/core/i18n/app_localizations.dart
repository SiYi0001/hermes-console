import 'package:flutter/material.dart';

/// App localization delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh', 'ja', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// App localizations
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation
      'nav_home': 'Home',
      'nav_connect': 'Connect',
      'nav_console': 'Console',
      'nav_status': 'Status',
      'nav_settings': 'Settings',

      // Connection
      'connect_title': 'Connect',
      'connect_scan_qr': 'Scan QR',
      'connect_manual': 'Manual',
      'connect_generate': 'Generate QR',
      'connect_disconnect': 'Disconnect',
      'connect_status_connected': 'Connected',
      'connect_status_connecting': 'Connecting...',
      'connect_status_disconnected': 'Disconnected',

      // Console
      'console_title': 'Console',
      'console_hint': 'Type command...',
      'console_clear': 'Clear',
      'console_copy': 'Copy',
      'console_export': 'Export',

      // Status
      'status_title': 'Status',
      'status_latency': 'Latency',
      'status_bandwidth': 'Bandwidth',
      'status_connection': 'Connection',

      // Settings
      'settings_title': 'Settings',
      'settings_security': 'Security',
      'settings_network': 'Network',
      'settings_appearance': 'Appearance',
      'settings_about': 'About',

      // Memory
      'memory_title': 'Memory',
      'memory_add': 'Add Memory',
      'memory_search': 'Search memories...',
      'memory_category': 'Category',
      'memory_importance': 'Importance',

      // Skills
      'skills_title': 'Skills',
      'skills_add': 'Add Skill',
      'skills_usage': 'Usage',
      'skills_last_used': 'Last Used',

      // Automation
      'automation_title': 'Automation',
      'automation_add': 'Add Task',
      'automation_enable': 'Enable',
      'automation_disable': 'Disable',
      'automation_run_now': 'Run Now',

      // Logs
      'logs_title': 'Logs',
      'logs_filter': 'Filter',
      'logs_clear': 'Clear',
      'logs_export': 'Export',

      // Notifications
      'notifications_title': 'Notifications',
      'notifications_mark_all_read': 'Mark All Read',
      'notifications_clear': 'Clear All',

      // Profile
      'profile_title': 'Profile',
      'profile_edit': 'Edit Profile',
      'profile_identities': 'Identities',
      'profile_security': 'Security',

      // Performance
      'performance_title': 'Performance',
      'performance_cpu': 'CPU',
      'performance_memory': 'Memory',
      'performance_network': 'Network',

      // Common
      'common_save': 'Save',
      'common_cancel': 'Cancel',
      'common_delete': 'Delete',
      'common_edit': 'Edit',
      'common_close': 'Close',
      'common_retry': 'Retry',
      'common_loading': 'Loading...',
      'common_error': 'Error',
      'common_success': 'Success',
      'common_warning': 'Warning',

      // Errors
      'error_connection_failed': 'Connection failed',
      'error_timeout': 'Request timed out',
      'error_network': 'Network error',
      'error_unknown': 'Unknown error',

      // Actions
      'action_connect': 'Connect',
      'action_disconnect': 'Disconnect',
      'action_refresh': 'Refresh',
      'action_export': 'Export',
      'action_import': 'Import',
    },
    'zh': {
      // Navigation
      'nav_home': '首页',
      'nav_connect': '连接',
      'nav_console': '控制台',
      'nav_status': '状态',
      'nav_settings': '设置',

      // Connection
      'connect_title': '连接',
      'connect_scan_qr': '扫码',
      'connect_manual': '手动',
      'connect_generate': '生成二维码',
      'connect_disconnect': '断开连接',
      'connect_status_connected': '已连接',
      'connect_status_connecting': '连接中...',
      'connect_status_disconnected': '未连接',

      // Console
      'console_title': '控制台',
      'console_hint': '输入命令...',
      'console_clear': '清空',
      'console_copy': '复制',
      'console_export': '导出',

      // Status
      'status_title': '状态',
      'status_latency': '延迟',
      'status_bandwidth': '带宽',
      'status_connection': '连接',

      // Settings
      'settings_title': '设置',
      'settings_security': '安全',
      'settings_network': '网络',
      'settings_appearance': '外观',
      'settings_about': '关于',

      // Memory
      'memory_title': '记忆',
      'memory_add': '添加记忆',
      'memory_search': '搜索记忆...',
      'memory_category': '分类',
      'memory_importance': '重要性',

      // Skills
      'skills_title': '技能',
      'skills_add': '添加技能',
      'skills_usage': '使用次数',
      'skills_last_used': '上次使用',

      // Automation
      'automation_title': '自动化',
      'automation_add': '添加任务',
      'automation_enable': '启用',
      'automation_disable': '禁用',
      'automation_run_now': '立即运行',

      // Logs
      'logs_title': '日志',
      'logs_filter': '筛选',
      'logs_clear': '清空',
      'logs_export': '导出',

      // Notifications
      'notifications_title': '通知',
      'notifications_mark_all_read': '全部已读',
      'notifications_clear': '清空全部',

      // Profile
      'profile_title': '个人资料',
      'profile_edit': '编辑资料',
      'profile_identities': '身份',
      'profile_security': '安全',

      // Performance
      'performance_title': '性能',
      'performance_cpu': '处理器',
      'performance_memory': '内存',
      'performance_network': '网络',

      // Common
      'common_save': '保存',
      'common_cancel': '取消',
      'common_delete': '删除',
      'common_edit': '编辑',
      'common_close': '关闭',
      'common_retry': '重试',
      'common_loading': '加载中...',
      'common_error': '错误',
      'common_success': '成功',
      'common_warning': '警告',

      // Errors
      'error_connection_failed': '连接失败',
      'error_timeout': '请求超时',
      'error_network': '网络错误',
      'error_unknown': '未知错误',

      // Actions
      'action_connect': '连接',
      'action_disconnect': '断开',
      'action_refresh': '刷新',
      'action_export': '导出',
      'action_import': '导入',
    },
    'ja': {
      'nav_home': 'ホーム',
      'nav_connect': '接続',
      'nav_console': 'コンソール',
      'nav_status': 'ステータス',
      'nav_settings': '設定',
      'connect_title': '接続',
      'console_title': 'コンソール',
      'status_title': 'ステータス',
      'settings_title': '設定',
    },
    'ko': {
      'nav_home': '홈',
      'nav_connect': '연결',
      'nav_console': '콘솔',
      'nav_status': '상태',
      'nav_settings': '설정',
      'connect_title': '연결',
      'console_title': '콘솔',
      'status_title': '상태',
      'settings_title': '설정',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Shorthand getter
  String operator [](String key) => translate(key);
}

/// Extension for easy access to localizations
extension LocalizationsExtension on BuildContext {
  AppLocalizations get i18n => AppLocalizations.of(this)!;
}

/// Locale provider
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
}
