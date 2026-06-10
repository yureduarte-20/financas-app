class ApiPaths {
  static const base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000/api');
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const verifyCode = '/auth/verify-code';
  static const resendCode = '/auth/resend-code';
  static const me = '/auth/user';
  static const logout = '/auth/logout';
  static const transactions = '/transactions';
  static const categories = '/categories';
  static const uploadDoc = '/documents/upload';
  static const reports = '/reports';
}
