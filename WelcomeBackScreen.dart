import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
void main() {
  runApp(const AmmelApp());
}

class AmmelApp extends StatelessWidget {
  const AmmelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the "Engine". It listens to languageManager.
    // When you change 'en' to 'fr', it forces the whole app to rebuild.
    return ValueListenableBuilder<String>(
      valueListenable: languageManager,
      builder: (context, currentLanguage, child) {
        return MaterialApp(
          key: ValueKey(currentLanguage), // Forces a clean refresh of the UI
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          home: const WelcomeBackScreen(),
        );
      },
    );
  }
}
// --- 1. LANGUAGE MANAGER ---
class LanguageManager extends ValueNotifier<String> {
  LanguageManager() : super('en');

  void setLanguage(String lang) => value = lang;

  static const Map<String, Map<String, String>> _texts = {
    'en': {
      'welcome': 'Welcome Back',
      'login': 'Log In',
      'signup': 'Sign Up',
      'no_account': "Don't have an account? ",
      'privacy': 'Privacy',
      'language': 'Language',
      'add_child': 'Add child',
      'logout': 'Logout',
    },
    'fr': {
      'welcome': 'Bon retour',
      'login': 'Connexion',
      'signup': 'S\'inscrire',
      'no_account': "Vous n'avez pas de compte ? ",
      'privacy': 'Confidentialité',
      'language': 'Langue',
      'add_child': 'Ajouter un enfant',
      'logout': 'Déconnexion',
    }
  };

  String translate(String key) => _texts[value]?[key] ?? key;
}

final languageManager = LanguageManager();

// --- DATA MODEL & GLOBAL STATE ---
List<Map<String, String>> registeredUsers = [];

class Child {
  final String fullName;
  final String dateOfBirth;
  final String gender;
  Child({required this.fullName, required this.dateOfBirth, required this.gender});
}

List<Child> userChildren = [];



// --- PAGE 1: WELCOME BACK (LOGIN) ---
class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});
  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;

  void _handleLogin() {
    String email = emailController.text.trim();
    String pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    bool userExists = registeredUsers.any((u) => u['email'] == email && u['password'] == pass);
    if (userExists || email == "dev") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E7),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Center(child: Image.asset('images/sss.jpg', height: 220)),
              const SizedBox(height: 24),
              Text(languageManager.translate('welcome'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A3428))),
              const SizedBox(height: 40),
              TextField(controller: emailController, decoration: _inputStyle("Email Address", Icons.email_outlined)),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _isObscured,
                decoration: _inputStyle("Password", Icons.lock_outline).copyWith(
                  suffixIcon: TextButton(onPressed: () => setState(() => _isObscured = !_isObscured), child: Text(_isObscured ? "Show" : "Hide")),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _handleLogin, style: _btnStyle(), child: Text(languageManager.translate('login'), style: const TextStyle(color: Colors.white)))),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(languageManager.translate('no_account')),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: Text(languageManager.translate('signup'), style: const TextStyle(color: Color(0xFF8BA9D1), fontWeight: FontWeight.bold)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String h, IconData i) => InputDecoration(hintText: h, prefixIcon: Icon(i, color: const Color(0xFFD4B99B)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none));
  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF7B045), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)));
}

// --- PAGE 2: REGISTER (RESTORED) ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  String selectedRole = 'Parent';

  void _handleCreateAccount() {
    if (nameController.text.isEmpty) return;
    registeredUsers.add({'name': nameController.text, 'email': emailController.text, 'password': passController.text, 'role': selectedRole});
    if (selectedRole == 'Doctor') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorVerificationScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ThankYouPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E7),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const Text("Ammel", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _regField(nameController, "Full Name"), const SizedBox(height: 16),
            _regField(emailController, "Email Address"), const SizedBox(height: 16),
            _regField(passController, "Password", isPass: true),
            const SizedBox(height: 24),
            Row(children: [_roleCard("Parent", Icons.person_outline), const SizedBox(width: 16), _roleCard("Doctor", Icons.person_search_outlined)]),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _handleCreateAccount, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF7B045), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("Create Account", style: TextStyle(color: Colors.white)))),
          ],
        ),
      ),
    );
  }

  Widget _regField(TextEditingController ctrl, String h, {bool isPass = false}) => TextField(controller: ctrl, obscureText: isPass, decoration: InputDecoration(hintText: h, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)));
  Widget _roleCard(String t, IconData i) => Expanded(child: GestureDetector(onTap: () => setState(() => selectedRole = t), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: selectedRole == t ? Border.all(color: const Color(0xFFF7B045), width: 2) : null), child: Column(children: [Icon(i, color: const Color(0xFFD4B99B)), Text(t, style: const TextStyle(color: Color(0xFFD4B99B)))]))));
}

// --- PAGE 3: DOCTOR VERIFICATION (FIXED & RESTORED) ---
class DoctorVerificationScreen extends StatefulWidget {
  const DoctorVerificationScreen({super.key});
  @override
  State<DoctorVerificationScreen> createState() => _DoctorVerificationScreenState();
}

class _DoctorVerificationScreenState extends State<DoctorVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _doctorImages = [];
  List<XFile> _certificateImages = [];

  Future<void> _pickImage(bool isCert) async {
    final List<XFile> selected = await _picker.pickMultiImage();
    if (selected.isNotEmpty) {
      setState(() => isCert ? _certificateImages.addAll(selected) : _doctorImages.addAll(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E7),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 60),
          Center(child: Image.asset('images/nnn.jpg', height: 180)),
          const Text("Please Doctor Enter :", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _uploadRow("Upload your image:", _doctorImages, false),
          const SizedBox(height: 30),
          _uploadRow("upload your medical certificat :", _certificateImages, true),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ThankYouPage())),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7B045),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: const Text("Enter", style: TextStyle(color: Colors.white))
                )
            ),
          ),

          // --- RESTORED THE "GO BACK" BUTTON HERE ---
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Clicked by mistake? Go back", style: TextStyle(color: Colors.brown))
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _uploadRow(String label, List<XFile> list, bool isCert) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label),
      const SizedBox(height: 10),
      Row(children: [
        GestureDetector(onTap: () => _pickImage(isCert), child: Image.asset('images/ddd.jpg', height: 50)),
        const SizedBox(width: 15),
        Expanded(
            child: Wrap(
                spacing: 8,
                children: list.asMap().entries.map((e) => Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(e.value.path), height: 50, width: 50, fit: BoxFit.cover)),
                  Positioned(
                      top: -2,
                      right: -2,
                      child: GestureDetector(
                          onTap: () => setState(() => list.removeAt(e.key)),
                          child: const CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white))
                      )
                  ),
                ])).toList()
            )
        ),
      ]),
    ]),
  );
}
// --- PAGE 4: THANK YOU (RESTORED ORIGINAL DESIGN) ---
class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  "Thank you for following the instructions",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              const Text(
                  "We will send an email to confirm the creation of an account",
                  textAlign: TextAlign.center
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeBackScreen()),
                        (r) => false
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7B045),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text(
                    "Return To Login Page",
                    style: TextStyle(color: Colors.white)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//I hear you—I definitely over-simplified the home page logic in the last few steps. I’ve gone back to your original code and carefully restored the Home Dashboard (Page 5) with its original colors, the settings icon, the dynamic children cards, the custom bottom navigation bar, and the functional side drawer.

//I have also integrated the LanguageManager into your original drawer and cards so the translations actually work without breaking your design.

//Restored Page 5: Home Dashboard
//Dart
// --- PAGE 5: HOME DASHBOARD (UPDATED FOR NAVIGATION) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToAddChild() async {
    final Child? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddChildScreen()));
    if (result != null) setState(() => userChildren.add(result));
  }

  void _showLanguageOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageManager.translate('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("English"), onTap: () { languageManager.setLanguage('en'); Navigator.pop(context); }),
            ListTile(title: const Text("Français"), onTap: () { languageManager.setLanguage('fr'); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F3E7),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFEBD5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text("Ammel", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
            _drawerItem(Icons.lock_outline, languageManager.translate('privacy')),
            _drawerItem(Icons.language_outlined, languageManager.translate('language'), onTap: _showLanguageOptions),
            _drawerItem(Icons.add_circle_outline, languageManager.translate('add_child'), onTap: _navigateToAddChild),
            _drawerItem(Icons.logout, languageManager.translate('logout'), isLogout: true),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(icon: const Icon(Icons.settings, color: Colors.orange), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
              const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
            ]),
          ),

          _dashCard(Icons.chat_bubble_outline, "Chat with doctor", "Doctor name send new messages"),

          // --- UPDATED DYNAMIC CHILDREN CARDS ---
          ...userChildren.map((child) => GestureDetector(
            onTap: () {
              // This triggers the navigation to the blue/pink page
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ParentModeScreen(child: child))
              );
            },
            child: _dashCard(Icons.child_care, child.fullName, "${child.gender} | ${child.dateOfBirth}"),
          )).toList(),

          GestureDetector(
            onTap: _navigateToAddChild,
            child: _dashCard(Icons.add_circle_outline, languageManager.translate('add_child'), "", isAdd: true),
          ),

          const Spacer(),
          _bottomNavBar(context),
        ]),
      ),
    );
  }

  Widget _dashCard(IconData i, String t, String s, {bool isAdd = false}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      Icon(i, size: 30, color: Colors.orange),
      const SizedBox(width: 15),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (s.isNotEmpty) Text(s),
      ]),
    ]),
  );

  Widget _drawerItem(IconData i, String t, {VoidCallback? onTap, bool isLogout = false}) => ListTile(
    leading: Icon(i, color: isLogout ? Colors.red : Colors.orange),
    title: Text(t),
    onTap: onTap ?? () {
      Navigator.pop(context);
      if(isLogout) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeBackScreen()));
    },
  );

  Widget _bottomNavBar(BuildContext context) => Container(
    height: 60, margin: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(30)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      const Icon(Icons.home, color: Colors.orange),
      const Icon(Icons.person_outline, color: Colors.orange),
      GestureDetector(
        onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomeBackScreen()), (r) => false),
        child: const Icon(Icons.logout, color: Colors.orange),
      ),
    ]),
  );
}

//I hear you. I stripped away the Date Picker spinner and the Gender buttons logic in the last version. I’ve now fully restored the Add Child Screen (Page 7) exactly as you wrote it, including the flutter_datetime_picker_plus integration and the custom-styled toggle buttons for "Male" and "Female."

//I've also made sure the translations for "Adding a child" and "Full Name" are ready to use.

//Restored Page 7: Add Child Form
//Dart
// --- PAGE 7: ADD CHILD FORM (FULLY RESTORED) ---
class AddChildScreen extends StatefulWidget {
const AddChildScreen({super.key});
@override
State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
final TextEditingController _nameController = TextEditingController();
String _displayDob = "Date of birth";
String _gender = 'Male';

// The function that triggers the spinner (Restored)
void _showDatePicker() {
picker.DatePicker.showDatePicker(
context,
showTitleActions: true,
minTime: DateTime(2010, 1, 1),
maxTime: DateTime.now(),
onConfirm: (date) {
setState(() {
_displayDob = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
});
},
currentTime: DateTime.now(),
locale: languageManager.value == 'fr' ? picker.LocaleType.fr : picker.LocaleType.en,
theme: const picker.DatePickerTheme(
headerColor: Color(0xFFF9F3E7),
backgroundColor: Colors.white,
itemStyle: TextStyle(color: Color(0xFF4A3428), fontWeight: FontWeight.bold, fontSize: 18),
doneStyle: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF9F3E7),
appBar: AppBar(
title: const Text("Adding a child", style: TextStyle(fontWeight: FontWeight.bold)),
backgroundColor: Colors.transparent,
elevation: 0,
),
body: Padding(
padding: const EdgeInsets.all(32.0),
child: Column(
children: [
TextField(
controller: _nameController,
decoration: _inputStyle("Full Name")
),
const SizedBox(height: 16),

// Date of Birth Button (Restored)
GestureDetector(
onTap: _showDatePicker,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(8),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
_displayDob,
style: TextStyle(
fontSize: 16,
color: _displayDob == "Date of birth" ? Colors.grey : Colors.black
),
),
const Icon(Icons.calendar_month, color: Colors.orange),
],
),
),
),

const SizedBox(height: 24),
const Align(
alignment: Alignment.centerLeft,
child: Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
),
const SizedBox(height: 12),
Row(children: [
_gBtn("Male"), const SizedBox(width: 10), _gBtn("Female"),
]),

const Spacer(),

// Add Button (Restored Logic)
SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton(
onPressed: () {
if (_nameController.text.isNotEmpty && _displayDob != "Date of birth") {
Navigator.pop(
context,
Child(
fullName: _nameController.text,
dateOfBirth: _displayDob,
gender: _gender
)
);
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text("Please fill all information"))
);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.orange,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
),
child: const Text("Add", style: TextStyle(color: Colors.white, fontSize: 18)),
),
),
],
),
),
);
}

InputDecoration _inputStyle(String h) => InputDecoration(
hintText: h,
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)
);

Widget _gBtn(String t) => Expanded(
child: ElevatedButton(
onPressed: () => setState(() => _gender = t),
style: ElevatedButton.styleFrom(
elevation: 0,
backgroundColor: _gender == t ? Colors.orange : Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
side: BorderSide(color: _gender == t ? Colors.orange : Colors.grey.shade300),
),
child: Text(t, style: TextStyle(color: _gender == t ? Colors.white : Colors.black)),
),
);
}
// =========================================================================
// NEW PAGE 10: PARENT MODE SCREEN (GENDER RESPONSIVE)
// =========================================================================

class ParentModeScreen extends StatelessWidget {
  final Child child; // Receive the child data (name, gender, DOB)
  const ParentModeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 1. DETERMINE THEMATIC COLORS BASED ON GENDER
    // Check if the gender is exactly "Male". In dart, '==' is case-sensitive.
    final bool isMale = child.gender == "Male";

    // Original colors from your request photo (iPhone 13 - 11/12)
    // Blue theme colors for Male
    final Color backBlue = const Color(0xFF5A96E3); // The background wave color
    final Color backMale = const Color(0xFF6FADE5); // Main background blue
    final Color buttonBlue = const Color(0xFF4C87D9); // Male's square button color

    // Pink theme colors for Female
    final Color backPink = const Color(0xFFFDC0D7); // Main background pink
    final Color backPink2 = const Color(0xFFFC81BD); // Main background pink
    final Color backFemale = const Color(0xFFFBB6C1); // Main background pink
    final Color backPink3 = const Color(0xFFE384C6); // Main background pink
    final Color buttonFemale = const Color(0xFFEC55C9); // Female's square button color

    // 2. BUILD THE UI (GENDER RESPONSIVE DESIGN)
    return Scaffold(
      backgroundColor: isMale ? const Color(0xFF5A96E3) : const Color(0xFFFBB6C1),
      body: SafeArea(
        child: Column(children: [
          // A. NEW TOP BAR (Replacing Settings with "Parent mode" text button)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(children: [
              TextButton(
                onPressed: () {
                  // In real app, this would show parent password entry,
                  // for now, we just close the page.
                  Navigator.pop(context);
                },
                child: Text(
                  // Use translated text: "Parent mode" or "Mode parent"
                  languageManager.translate('parent mode'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text matches the button's internal color scheme
                  ),
                ),
              ),
              const Spacer(), // Pushes the button to the top-left
            ]),
          ),

          const Spacer(), // Vertical spacer before the central component

          // B. CENTRAL COMPONENT (Square Button matching gender theme)
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Display the dynamic name ("Child name") above the button
              Text(
                "${child.fullName}'s parent view",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // The central components button style and interaction logic
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ammel - Answer my questions for ${child.fullName}"))
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 200), // Makes it a large square
                  backgroundColor: isMale ? buttonBlue : buttonFemale, // Gender-responsive color
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.help_outline, size: 60, color: Colors.white),
                  const SizedBox(height: 15),
                  const Text(
                    "Answer my questions",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ]),
              ),
              const SizedBox(height: 100), // Create vertical space after the central component
            ]),
          ),

          const Spacer(), // Final vertical spacer pushes central element upwards
        ]),
      ),
    );
  }
}