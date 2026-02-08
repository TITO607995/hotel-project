import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleResetPassword() async {
    if (_emailController.text.isEmpty) {
      _showCustomSnackBar("Masukkan email Anda terlebih dahulu!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi pengiriman email reset password
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    
    if (!mounted) return;
    _showCustomSnackBar("Link reset password telah dikirim ke email Anda.");
    
    // Kembali ke halaman login setelah sukses
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isError ? const Color(0xFFFFE5E5) : const Color(0xFFE5FFED),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isError ? Colors.redAccent.withOpacity(0.5) : Colors.green.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: isError ? Colors.redAccent : Colors.green,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError ? const Color(0xFF8B0000) : const Color(0xFF006400),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Besar
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded, size: 80, color: Color(0xFF8B0000)),
                  ),
                ),
                const SizedBox(height: 30),
                
                const Text(
                  "Lupa Password?",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Jangan khawatir! Masukkan email yang terdaftar dan kami akan mengirimkan instruksi reset.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 40),

                // Input Email
                const Text(
                  "Email Alamat",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D3436)),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Masukkan email anda",
                      prefixIcon: Icon(Icons.alternate_email_rounded, color: Colors.blueGrey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Reset
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _handleResetPassword,
                        child: const Text(
                          "Kirim Instruksi",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}