import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/auth_result.dart';
import '../providers/auth_provider.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import '../utils/arabic_digits.dart';
import '../utils/validators.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/password_text_field.dart';
import 'home_screen.dart';
import 'register_screen.dart';

/// شاشة تسجيل دخول صاحب المغسلة.
///
/// تحتوي نموذجًا مع تحقق كامل من المدخلات، خيار «تذكرني»، استعادة كلمة
/// المرور، وبيانات الحساب التجريبي الجاهز لتسهيل التجربة.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialPhone});

  /// رقم هاتف مبدئي (يُستخدم بعد إنشاء حساب جديد مثلًا).
  final String? initialPhone;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // العمليات
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final AuthProvider auth = context.read<AuthProvider>();
    auth.clearError();

    if (!(_formKey.currentState?.validate() ?? false)) {
      showAppSnackBar(
        context,
        'تحقق من رقم الهاتف وكلمة المرور أولًا',
        isError: true,
      );
      return;
    }

    final AuthResult result = await auth.login(
      phone: _phoneController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );
    if (!mounted) {
      return;
    }
    if (!result.success) {
      showAppSnackBar(context, result.message, isError: true);
      return;
    }

    showAppSnackBar(context, result.message, isSuccess: true);
    // نستبدل كل الشاشات السابقة بلوحة التحكم بعد نجاح الدخول.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomeScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _openRegister() async {
    FocusScope.of(context).unfocus();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const RegisterScreen(),
      ),
    );
    if (!mounted) {
      return;
    }
    // لا نُبقي رسالة خطأ قديمة من شاشة أخرى في نموذج الدخول.
    context.read<AuthProvider>().clearError();
  }

  void _fillDemoCredentials() {
    setState(() {
      _phoneController.text = AppConstants.demoOwnerPhone;
      _passwordController.text = AppConstants.demoOwnerPassword;
    });
    showAppSnackBar(
      context,
      'تم تعبئة بيانات الحساب التجريبي — اضغط «تسجيل الدخول»',
    );
  }

  Future<void> _openResetPassword() async {
    FocusScope.of(context).unfocus();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext sheetContext) {
        return _ResetPasswordSheet(
          messenger: messenger,
          initialPhone: _phoneController.text,
        );
      },
    );
    if (!mounted) {
      return;
    }
    context.read<AuthProvider>().clearError();
  }

  // ---------------------------------------------------------------------------
  // الواجهة
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AuthBackground(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 42,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const AuthBrandHeader(
                      title: 'تسجيل الدخول',
                      subtitle: 'أدخل بيانات حسابك لإدارة طلبات المغسلة '
                          'ومتابعة حالاتها.',
                    ),
                    AuthFormCard(
                      icon: Icons.lock_open_rounded,
                      title: 'دخول صاحب المغسلة',
                      subtitle: 'رقم الهاتف وكلمة المرور',
                      child: _buildForm(auth),
                    ),
                    const SizedBox(height: 16),
                    if (auth.hasDemoAccount) ...<Widget>[
                      _DemoAccountCard(onFill: _fillDemoCredentials),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'الإصدار ${AppConstants.appVersion} • حساب واحد لصاحب المغسلة',
                      textAlign: TextAlign.center,
                      style: AppTheme.text(
                        size: 10.5,
                        color: const Color(0xB3FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (auth.errorMessage != null) ...<Widget>[
            AuthErrorBanner(message: auth.errorMessage!),
            const SizedBox(height: 12),
          ],
          AppTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: 'مثال: 771234567',
            prefixIcon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.telephoneNumber],
            inputFormatters: const <TextInputFormatter>[
              ArabicDigitsInputFormatter(maxLength: AppConstants.phoneDigits),
            ],
            validator: AppValidators.phone,
          ),
          const SizedBox(height: 14),
          PasswordTextField(
            controller: _passwordController,
            label: 'كلمة المرور',
            hint: 'أدخل كلمة المرور',
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.password],
            validator: AppValidators.password,
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: AppColors.border, width: 1.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onChanged: (bool? value) =>
                      setState(() => _rememberMe = value ?? false),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: InkWell(
                  onTap: () =>
                      setState(() => _rememberMe = !_rememberMe),
                  child: Text(
                    'تذكرني',
                    style: AppTheme.text(
                      size: 11.5,
                      weight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: auth.isBusy ? null : _openResetPassword,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: AppTheme.text(
                    size: 11.5,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                child: const Text('نسيت كلمة المرور؟'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AuthSubmitButton(
            label: 'تسجيل الدخول',
            loading: auth.isBusy,
            onPressed: _submit,
            icon: Icons.login_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              const Expanded(
                child: Divider(height: 1, color: AppColors.border),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'ليس لديك حساب؟',
                  style: AppTheme.text(
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(height: 1, color: AppColors.border),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: auth.isBusy ? null : _openRegister,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
              label: const Text('إنشاء حساب جديد للمغسلة'),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة الحساب التجريبي مع زر تعبئة سريعة لبيانات الدخول.
class _DemoAccountCard extends StatelessWidget {
  const _DemoAccountCard({required this.onFill});

  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                'حساب تجريبي جاهز للتجربة',
                style: AppTheme.text(
                  size: 12,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'الهاتف: ${AppConstants.demoOwnerPhone}  •  '
            'كلمة المرور: ${AppConstants.demoOwnerPassword}',
            style: AppTheme.text(
              size: 11,
              color: const Color(0xE6FFFFFF),
              height: 1.7,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onFill,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: AppTheme.text(
                  size: 11.5,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              icon: const Icon(Icons.bolt_rounded, size: 17),
              label: const Text('تعبئة بيانات الدخول التجريبية'),
            ),
          ),
        ],
      ),
    );
  }
}

/// نافذة سفلى لاستعادة كلمة المرور داخل الجهاز (بدون سيرفر).
class _ResetPasswordSheet extends StatefulWidget {
  const _ResetPasswordSheet({
    required this.messenger,
    required this.initialPhone,
  });

  final ScaffoldMessengerState messenger;
  final String initialPhone;

  @override
  State<_ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<_ResetPasswordSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _shopController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final AuthProvider auth = context.read<AuthProvider>();
    final AuthResult result = await auth.resetPassword(
      phone: _phoneController.text,
      shopName: _shopController.text,
      newPassword: _passwordController.text,
      confirmPassword: _confirmController.text,
    );
    if (!mounted) {
      return;
    }
    if (!result.success) {
      setState(() => _error = result.message);
      return;
    }
    Navigator.of(context).pop();
    showAppSnackBarOn(widget.messenger, result.message, isSuccess: true);
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'استعادة كلمة المرور',
                            style: AppTheme.text(
                              size: 16,
                              weight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'أكّد رقم الهاتف واسم المغسلة ثم اختر كلمة مرور جديدة',
                            style: AppTheme.text(
                              size: 11,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_error != null) ...<Widget>[
                  AuthErrorBanner(message: _error!),
                  const SizedBox(height: 12),
                ],
                AppTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف المسجل',
                  hint: 'مثال: 771234567',
                  prefixIcon: Icons.phone_iphone_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: const <TextInputFormatter>[
                    ArabicDigitsInputFormatter(
                      maxLength: AppConstants.phoneDigits,
                    ),
                  ],
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _shopController,
                  label: 'اسم المغسلة',
                  hint: 'اسم المغسلة كما سُجّل عند إنشاء الحساب',
                  prefixIcon: Icons.storefront_rounded,
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.shopName,
                ),
                const SizedBox(height: 12),
                PasswordTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور الجديدة',
                  hint: '6 أحرف على الأقل',
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.password,
                ),
                const SizedBox(height: 12),
                PasswordTextField(
                  controller: _confirmController,
                  label: 'تأكيد كلمة المرور الجديدة',
                  hint: 'أعد كتابة كلمة المرور',
                  textInputAction: TextInputAction.done,
                  validator: (String? value) => AppValidators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: 16),
                AuthSubmitButton(
                  label: 'تحديث كلمة المرور',
                  loading: auth.isBusy,
                  onPressed: _submit,
                  icon: Icons.check_rounded,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
