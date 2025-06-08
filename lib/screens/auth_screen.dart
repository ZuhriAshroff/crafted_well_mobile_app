// lib/screens/auth_screen.dart
import 'package:crafted_well_mobile_app/main.dart';
import 'package:crafted_well_mobile_app/screens/homepage.dart';
import 'package:crafted_well_mobile_app/screens/product_list_screen.dart';
import 'package:crafted_well_mobile_app/theme/theme.dart';
import 'package:crafted_well_mobile_app/utils/navigation_state.dart';
import 'package:crafted_well_mobile_app/widgets/popup_widget.dart';
import 'package:crafted_well_mobile_app/utils/user_manager.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final int initialTabIndex;

  const AuthScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          onPressed: () {
            final materialApp =
                context.findAncestorWidgetOfExactType<MaterialApp>();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(
                  currentThemeMode: materialApp?.themeMode ?? ThemeMode.system,
                  onThemeModeChanged: (ThemeMode mode) {
                    final craftedWellState =
                        context.findAncestorStateOfType<State<CraftedWell>>();
                    if (craftedWellState != null &&
                        craftedWellState is State<CraftedWell>) {
                      (craftedWellState as dynamic).toggleTheme(mode);
                    }
                  },
                ),
              ),
              (route) => false,
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!isLandscape) ...[
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/Crafted Well Logo (2).png',
                  height: 80,
                ),
                const SizedBox(height: 20),
              ],

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                unselectedLabelColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white60
                        : Colors.black54,
                tabs: const [
                  Tab(text: 'LOGIN'),
                  Tab(text: 'REGISTER'),
                ],
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    LoginTab(tabController: _tabController),
                    RegisterTab(tabController: _tabController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Login Tab Content
class LoginTab extends StatefulWidget {
  final TabController tabController;
  const LoginTab({Key? key, required this.tabController}) : super(key: key);

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await UserManager.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (success) {
          StatusPopup.show(
            context,
            message: 'Welcome back to Crafted Well!',
            isSuccess: true,
            onClose: () {
              // Check if user came from survey
              if (NavigationState.hasCompletedSurvey) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListScreen(),
                  ),
                  (route) => false,
                );
              } else {
                // Regular homepage navigation
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      currentThemeMode:
                          Theme.of(context).brightness == Brightness.dark
                              ? ThemeMode.dark
                              : ThemeMode.light,
                      onThemeModeChanged: (ThemeMode mode) {
                        final craftedWellState = context
                            .findAncestorStateOfType<State<CraftedWell>>();
                        if (craftedWellState != null &&
                            craftedWellState is State<CraftedWell>) {
                          (craftedWellState as dynamic).toggleTheme(mode);
                        }
                      },
                    ),
                  ),
                  (route) => false,
                );
              }
            },
          );
        } else {
          StatusPopup.show(
            context,
            message:
                'Login failed. Please check your credentials.\n\nDemo credentials:\nEmail: ${UserManager.defaultEmail}\nPassword: ${UserManager.defaultPassword}',
            isSuccess: false,
          );
        }
      } catch (e) {
        StatusPopup.show(
          context,
          message: 'An error occurred. Please try demo credentials.',
          isSuccess: false,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Demo info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For demo purposes, use:\nEmail: ${UserManager.defaultEmail}\nPassword: ${UserManager.defaultPassword}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Quick fill button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _emailController.text = UserManager.defaultEmail;
                      _passwordController.text = UserManager.defaultPassword;
                    },
                    child: Text(
                      'Fill Demo Credentials',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('LOGGING IN...'),
                          ],
                        )
                      : const Text('LOGIN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Register Tab Content
class RegisterTab extends StatefulWidget {
  final TabController tabController;
  const RegisterTab({Key? key, required this.tabController}) : super(key: key);

  @override
  State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await UserManager.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (result['success']) {
          StatusPopup.show(
            context,
            message:
                result['message'] ?? 'Registration successful! Please login.',
            isSuccess: true,
            onClose: () {
              // Switch to login tab
              widget.tabController.animateTo(0);
            },
          );
        } else {
          StatusPopup.show(
            context,
            message: result['message'] ?? 'Registration failed',
            isSuccess: false,
          );
        }
      } catch (e) {
        StatusPopup.show(
          context,
          message: 'An error occurred. Please try again.',
          isSuccess: false,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Info message
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber.shade700, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For demo purposes, please use the login tab with provided credentials.',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    if (value!.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('REGISTERING...'),
                          ],
                        )
                      : const Text('REGISTER'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
