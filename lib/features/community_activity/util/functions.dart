class Functions {
  static String getActivityStatusLabel({
    required int status,
    required DateTime endRegister,
    required DateTime endDate,
    required int numMember,
    required int maxMember,
  }) {
    final now = DateTime.now();

    if (status == 0) {
      if (now.isAfter(endRegister)) return 'Hết hạn đăng ký';
      if (numMember >= maxMember) return 'Đã đầy';
      return 'Mở đăng ký';
    }

    if (status == 1) {
      if (now.isAfter(endDate)) return 'Hoàn thành';
      return 'Đã đăng ký';
    }

    return 'Không xác định';
  }
}
