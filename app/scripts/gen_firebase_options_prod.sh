#!/bin/bash
# Genere lib/firebase_options_prod.dart depuis GoogleService-Info.plist.
#
# main.dart importe ce fichier, produit d'ordinaire par `flutterfire config` —
# lequel exigerait d'authentifier Firebase dans la CI. Toutes les valeurs
# necessaires etant dans le plist, on le derive directement.
#
# Usage : gen_firebase_options_prod.sh <plist> <fichier_dart_de_sortie>
set -e

PL="$1"
OUT="$2"
lire() { /usr/libexec/PlistBuddy -c "Print :$1" "$PL"; }

cat > "$OUT" <<EOF
// Fichier genere au build depuis GoogleService-Info.plist. Ne pas editer.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Ce build ne cible que iOS.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Ce build ne cible que iOS.');
    }
  }

  static const ios = FirebaseOptions(
    apiKey: '$(lire API_KEY)',
    appId: '$(lire GOOGLE_APP_ID)',
    messagingSenderId: '$(lire GCM_SENDER_ID)',
    projectId: '$(lire PROJECT_ID)',
    storageBucket: '$(lire STORAGE_BUCKET)',
    iosBundleId: '$(lire BUNDLE_ID)',
  );
}
EOF

echo "genere : $OUT"
