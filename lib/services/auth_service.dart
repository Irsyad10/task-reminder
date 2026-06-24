import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<User?> signInWithGoogle() async {
    try {
      // Ambil Web Client ID dari file .env (opsional, tapi direkomendasikan untuk Android/Web)
      final String? webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Di Web, client ID dibaca dari <meta> tag di index.html
        // serverClientId hanya untuk Android
        serverClientId: kIsWeb ? null : webClientId,
      );

      // Disconnect dulu agar account picker selalu muncul
      // dan tidak otomatis memilih akun yang sebelumnya digunakan
      await googleSignIn.disconnect().catchError((_) => null);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // Pengguna membatalkan login
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Token ID Google tidak ditemukan. Pastikan Web Client ID dikonfigurasi dengan benar.');
      }

      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response.user;
    } catch (e) {
      debugPrint('Error Google Sign-In: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // disconnect() menghapus sesi Google sepenuhnya
      // agar account picker selalu muncul saat login berikutnya
      await googleSignIn.disconnect();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
    }
    await _supabase.auth.signOut();
  }
}
