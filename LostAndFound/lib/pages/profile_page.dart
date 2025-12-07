import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found Amrita',
      theme: ThemeData(
        fontFamily: 'Lexend',
        primaryColor: const Color(0xFF8C2F39),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C2F39)),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProfileScreen(),
    const LoginScreen(),
    const EditProfileScreen(),
    const PasswordResetScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit'),
          BottomNavigationBarItem(icon: Icon(Icons.lock_reset), label: 'Reset'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8C2F39),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAMxisfuLYqWlfzdXkLn2g9unw9mSIugRMhtVx2mu19aqfMBsehgsqtawXOhviaM0rt7IlY7IUqG42ntfLRs5vbUKTkSa9BJ-Wk_rlWjyHunrULSqIZ36u0kaCWw6bgl7KcnHVrMr004XjHMIekcaMt1SdW6sXMBiawB0T1dc55dCKXtCP9mpzoyvJlSGzb5x9UArZayvExyoIqeIxU0FpNm9Ial88_QviYQb56rzNnLTk7PA3NWJlgVvLhh_DkPuz8aHhFxHd4Ol_6',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Priya Sharma',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Student - CSE 2025',
                    style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF8C2F39,
                        ).withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(color: Color(0xFF8C2F39)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTab('My Posts', true)),
                  Expanded(child: _buildTab('Activity', false)),
                ],
              ),
            ),
            // Posts List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final items = [
                  {
                    'type': 'Lost',
                    'color': Colors.red,
                    'title': 'Blue Water Bottle',
                    'date': 'Oct 26',
                  },
                  {
                    'type': 'Found',
                    'color': Colors.green,
                    'title': 'ID Card',
                    'date': 'Oct 24',
                  },
                  {
                    'type': 'Found',
                    'color': Colors.green,
                    'title': 'Airpods Pro',
                    'date': 'Oct 22',
                  },
                ];
                final item = items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['type'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item['color'] as Color,
                                  ),
                                ),
                              ),
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Posted on: ${item['date']}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                [
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBU7jZC5x85yyM-CL8HgMpukXCcnoso0-FP9rz7M48jXdHFxWpLYnjEnnObx_GP0eqdp1i6WNxyBKpdn8Kod1mOl5ZlTcoTEQ8B71_6QxslVCXIh0iHSlDyI2ptgCcsibZOEoSuHPst7h6t1GUEOPSUPZWs_mKZEO0SHVtMgSqHQPr0XYq0C-7SpU_8xklEuY3kf3qDhg7DeZA80Ngh9BqcG7mihShBsW3JLdrKwONbSNoeSj8iggwLEl0eQaPsI9skyd7ZRgaI6IkW',
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC9EOCjTa_zNYXj61lCnlGi0FGM4iBF173MiGs-tJyD8xOf3HavT4keaHWtzDuLecnGjxl--wxt2M6D9rqkUktjzQFHQEJamjq8kDYHrybff6FJKyX7H4aqhG8wZfBfSOZc_9s3Ww2RQDPbSlaFw0bCoTKtiTDX_-tM3uyFeYgr3squ_ILTTJXJfyctngWeQuP3jKdk3Nzm6kRlPAGQVDaTwwDalXWgd8wt8cRpo-QDZE5cQ8L66kP4aiSR4ffrVN0imfkvv_wK-ABo',
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBbHRt9vmt9SpZ4Q-k21oUkA4HhXY7bJo_JAnKVqsq6QVlRmvaKtEvho2YB73GrsBrE-vyKp8yOnH1KT-v1h7kGNfsLblgtFzsoiuiuGJdRe-dXtBqLFZlDBkQS4A0f6tnpqw8YTwuiwviS9P7vV4qmj2V15HJUT7eHY1xiybU3cWx-hJZ3wdGf030YthvrXnvDN54CRYlD5KkIKByia4KuA35PgDvWC1EoH4LUohr8q7zf454pcxZ1y8NAtdQANvwyiwhClg5istjv',
                                ][index],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Column(
      children: [
        Container(
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF8C2F39) : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Column(
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDiQUacZ7nZa_jeyqNctfBo8LMORygeGPqIUEN4UMRhxjHnqxppOaVqZPjPorS7thY-dFjqrlK8sCI4FY783F5l_tB5tIDXLZkglnA_UbXJ0Y_pbCjErT7JxNAfSAGuV_AbLb7q73yNyabBSamPHQjDYVqO4cAx-gvaTcaUyUF5vog85cC14G29n54ekkqmPJVygl4baOgjDY5uKmRbyxJtUHRZw-dl25P56mHFB5q6I2E7uz8SuVIw8U-tiBN8n7A9kFnzw3YLBo-8',
                    height: 64,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Find what\'s lost on campus.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
                  ),
                ],
              ),
              const Spacer(),
              // Form
              Column(
                children: [
                  _buildTextField(
                    'Amrita Email',
                    'yourname@am.students.amrita.edu',
                    Icons.email,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFF8C2F39)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C2F39),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF999999)),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(
                            color: Color(0xFF8C2F39),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF999999)),
            prefixIcon: Icon(icon, color: const Color(0xFF8C2F39)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF8C2F39)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    bool _obscureText = true;
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF8C2F39)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCAD_q0PPeX_FZSo5MTED2wI1CaBJUM_u6oleQ3JxFAJBVV84MuSOgQLKIAcgLWJ__dI0R-Y4HnJFmuewPVSJwcPQQqbkqdvTkS4qI_N5VE4leUeVmCLgwyXURfUq1BPDtYzOJlLQp8py79lcyLvHbMyn3xF9eEVtFoSr-O3WwTayMWPEgXgKY4wWRkWo10pv5iQLegqp47NlY7lipihIyLVDvwdtVbAwbwmp2N65hRAEXA9AVWlHx9H5W14CMPtDUgaDoiyNW3fjtm',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8C2F39),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Form Fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildFormField('Full Name', 'Alexender Jordan'),
                    const SizedBox(height: 24),
                    _buildFormField('Contact Number', '+1 234 567 890'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C2F39),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Password Reset'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot Password?',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your registered email address to receive a password reset link.',
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail),
                  hintText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C2F39),
                ),
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Back to Login',
                style: TextStyle(color: Color(0xFF8C2F39)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection('Notifications', [
              _buildSettingRow(Icons.notifications, 'New Post Alerts', true),
              _buildSettingRow(Icons.task_alt, 'Item Status Updates', false),
            ]),
            _buildSection('Privacy', [
              _buildNavRow(Icons.visibility, 'Contact Info Visibility'),
            ]),
            _buildSection('Account', [
              _buildNavRow(Icons.lock_reset, 'Change Password'),
              _buildNavRow(Icons.logout, 'Logout'),
              _buildDangerRow(Icons.delete, 'Delete Account'),
            ]),
            _buildSection('General', [
              _buildNavRow(Icons.info, 'About Us'),
              _buildNavRow(Icons.help, 'Help & FAQ'),
              _buildNavRow(Icons.feedback, 'Send Feedback'),
            ]),
            const SizedBox(height: 32),
            const Text(
              'App Version 1.0.0',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Card(child: Column(children: children)),
        ],
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String title, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF8C2F39)),
              const SizedBox(width: 16),
              Expanded(child: Text(title)),
            ],
          ),
          Switch(value: isEnabled, onChanged: (value) {}),
        ],
      ),
    );
  }

  Widget _buildNavRow(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF8C2F39)),
              const SizedBox(width: 16),
              Expanded(child: Text(title)),
            ],
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }

  Widget _buildDangerRow(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
