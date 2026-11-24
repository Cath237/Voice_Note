import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Clé du navigateur principal : elle permet d'afficher un toast depuis
/// n'importe où, même juste après la fermeture d'un écran.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

enum ToastType { auto, info, success, warning, error }

class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  /// Affiche un message. Sans [type], la couleur est déduite du texte.
  static void show(
      String message, {
        ToastType type = ToastType.auto,
        String? actionLabel,
        VoidCallback? onAction,
        Duration? duration,
      }) {
    final overlay = appNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    dismiss();
    final resolved = type == ToastType.auto ? _detect(message) : type;

    final entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        type: resolved,
        actionLabel: actionLabel,
        onAction: () {
          dismiss();
          onAction?.call();
        },
        onTap: dismiss,
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    final wait = duration ??
        (actionLabel != null || resolved == ToastType.error
            ? const Duration(seconds: 6)
            : const Duration(seconds: 3));
    _timer = Timer(wait, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static ToastType _detect(String message) {
    final t = message.toLowerCase();
    const errors = ['échec', 'erreur', 'impossible', 'introuvable', 'refus', 'manquante'];
    const warnings = ['aucun', 'rien à', 'pas encore', 'arrêtez d', 'réessayez'];
    const successes = [
      'enregistr', 'ajout', 'copié', 'restaur', 'supprim', 'généré', 'créé', 'déplacée'
    ];
    if (errors.any(t.contains)) return ToastType.error;
    if (warnings.any(t.contains)) return ToastType.warning;
    if (successes.any(t.contains)) return ToastType.success;
    return ToastType.info;
  }
}

class _ToastView extends StatelessWidget {
  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback onAction;
  final VoidCallback onTap;

  const _ToastView({
    required this.message,
    required this.type,
    required this.actionLabel,
    required this.onAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final (color, icon) = switch (type) {
      ToastType.success => (AppColors.done, Icons.check_circle_outline),
      ToastType.warning => (const Color(0xFFD97706), Icons.info_outline),
      ToastType.error => (AppColors.recordRed, Icons.error_outline),
      _ => (AppColors.deepBlue, Icons.info_outline),
    };

    return Positioned(
      left: 16,
      right: 16,
      // Au-dessus de la barre du bas et du clavier.
      bottom: media.viewInsets.bottom + media.padding.bottom + 96,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
        ),
        child: Material(
          color: color,
          elevation: 6,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                if (actionLabel != null)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: onAction,
                    child: Text(actionLabel!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}