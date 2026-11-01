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

/// شاشة إنشاء حساب صاحب المغسلة.
///
/// نموذج كامل مع تحقق من كل حقل (Form + TextFormField + Validation):
/// اسم المغسلة، اسم المالك، الهاتف، البريد، المدينة، كلمة المرور وتأكيدها،
/// والموافقة على الشروط — ثم يُحفظ الحساب محليًا ويدخل المستخدم للتطبيق.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _city;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    // نبدأ بنموذج نظيف دون رسالة خطأ متبقية من شاشة الدخول.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearError();
      }
    });
  }

  @override
  void dispose() {
    _shopController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
        'راجع الحقول المظللة بالأحمر لإكمال إنشاء الحساب',
        isError: true,
      );
      return;
    }

    final AuthResult result = await auth.register(
      shopName: _shopController.text,
      ownerName: _ownerController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      city: _city ?? '',
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
      acceptedTerms: _acceptedTerms,
    );
    if (!mounted) {
      return;
    }
    if (!result.success) {
      showAppSnackBar(context, result.message, isError: true);
      return;
    }

    showAppSnackBar(context, result.message, isSuccess: true);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomeScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _back() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
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
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _GlassBackButton(onTap: _back),
              ),
              const SizedBox(height: 12),
              const AuthBrandHeader(
                title: 'إنشاء حساب جديد',
                subtitle: 'أنشئ حساب مغسلتك مرة واحدة، ثم أدر كل الطلبات '
                    'والفواتير من مكان واحد.',
              ),
              AuthFormCard(
                icon: Icons.storefront_rounded,
                title: 'بيانات المغسلة',
                subtitle: 'جميع الحقول مطلوبة',
                child: _buildForm(auth),
              ),
              const SizedBox(height: 16),
              Text(
                'بياناتك تُحفظ على هذا الجهاز فقط — دون إنترنت أو سيرفر.',
                textAlign: TextAlign.center,
                style: AppTheme.text(
                  size: 10.5,
                  color: const Color(0xB3FFFFFF),
                  height: 1.7,
                ),
              ),
            ],
          ),
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
            controller: _shopController,
            label: 'اسم المغسلة',
            hint: 'مثال: مغسلة النور',
            prefixIcon: Icons.storefront_rounded,
            textInputAction: TextInputAction.next,
            validator: AppValidators.shopName,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _ownerController,
            label: 'اسم صاحب المغسلة',
            hint: 'الاسم الكامل',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.name],
            validator: AppValidators.ownerName,
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          AppTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'example@mail.com',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.email],
            validator: AppValidators.email,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            isExpanded: true,
            // ignore: deprecated_member_use
            value: _city,
            validator: AppValidators.city,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: AppTheme.fieldDecoration(
              label: 'المدينة',
              hint: 'اختر المدينة',
              prefixIcon: Icons.location_on_outlined,
            ),
            style: AppTheme.text(size: 13.5, weight: FontWeight.w600),
            borderRadius: BorderRadius.circular(AppRadius.field),
            items: AppConstants.cities
                .map(
                  (String city) => DropdownMenuItem<String>(
                    value: city,
                    child: Text(city, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (String? value) => setState(() => _city = value),
          ),
          const SizedBox(height: 12),
          PasswordTextField(
            controller: _passwordController,
            label: 'كلمة المرور',
            hint: '6 أحرف على الأقل',
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.newPassword],
            validator: AppValidators.password,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          _PasswordStrengthMeter(password: _passwordController.text),
          const SizedBox(height: 12),
          PasswordTextField(
            controller: _confirmController,
            label: 'تأكيد كلمة المرور',
            hint: 'أعد كتابة كلمة المرور',
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.newPassword],
            validator: (String? value) => AppValidators.confirmPassword(
              value,
              _passwordController.text,
            ),
          ),
          const SizedBox(height: 8),
          _TermsField(
            onChanged: (bool value) => setState(() => _acceptedTerms = value),
          ),
          const SizedBox(height: 16),
          AuthSubmitButton(
            label: 'إنشاء الحساب',
            loading: auth.isBusy,
            onPressed: _submit,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'لديك حساب بالفعل؟',
                style: AppTheme.text(
                  size: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: auth.isBusy ? null : _back,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// زر رجوع زجاجي فوق خلفية التدرّج (يستخدم Navigator.pop).
class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x26FFFFFF),
      shape: const CircleBorder(
        side: BorderSide(color: Color(0x33FFFFFF)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// مؤشر قوة كلمة المرور (ثلاثة أشرطة + وصف قصير).
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.password});

  final String password;

  static const List<String> _labels = <String>[
    'لم تُدخل كلمة المرور بعد',
    'كلمة مرور ضعيفة',
    'كلمة مرور متوسطة',
    'كلمة مرور قوية',
  ];

  static const List<Color> _colors = <Color>[
    AppColors.border,
    AppColors.cancelled,
    AppColors.warning,
    AppColors.ready,
  ];

  /// 0 = فارغة، 1 = ضعيفة، 2 = متوسطة، 3 = قوية.
  int get _level {
    if (password.isEmpty) {
      return 0;
    }
    int level = 1;
    final bool hasLetter = RegExp('[A-Za-z]').hasMatch(password);
    final bool hasDigit = RegExp('[0-9]').hasMatch(password);
    if (password.length >= 8 && (hasLetter || hasDigit)) {
      level = 2;
    }
    if (password.length >= 8 && hasLetter && hasDigit) {
      level = 3;
    }
    return level;
  }

  @override
  Widget build(BuildContext context) {
    final int level = _level;
    final Color color = _colors[level];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int index = 1; index <= 3; index++) ...<Widget>[
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: index <= level ? color : AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (index != 3) const SizedBox(width: 5),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          _labels[level],
          style: AppTheme.text(
            size: 10.5,
            color: level == 0 ? AppColors.textMuted : color,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// حقل الموافقة على الشروط داخل الـForm (مع رسالة خطأ عند عدم الموافقة).
class _TermsField extends StatelessWidget {
  const _TermsField({required this.onChanged});

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: false,
      validator: AppValidators.terms,
      builder: (FormFieldState<bool> field) {
        final bool value = field.value ?? false;
        void toggle() {
          field.didChange(!value);
          onChanged(!value);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: value,
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(
                      color: field.hasError
                          ? AppColors.cancelled
                          : AppColors.border,
                      width: 1.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (bool? _) => toggle(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: toggle,
                    child: Text.rich(
                      TextSpan(
                        style: AppTheme.text(
                          size: 11.5,
                          color: AppColors.textSecondary,
                          height: 1.7,
                        ),
                        children: <InlineSpan>[
                          const TextSpan(text: 'أوافق على '),
                          TextSpan(
                            text: 'شروط الاستخدام',
                            style: AppTheme.text(
                              size: 11.5,
                              weight: FontWeight.w700,
                              color: AppColors.primary,
                              height: 1.7,
                            ),
                          ),
                          const TextSpan(text: ' وحفظ بيانات مغسلتي على الجهاز.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 30),
                child: Text(
                  field.errorText ?? '',
                  style: AppTheme.text(
                    size: 11,
                    color: AppColors.cancelled,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
