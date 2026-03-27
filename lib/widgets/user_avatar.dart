import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';

/// A circular avatar that shows the user's profile photo when available,
/// falling back to initials. Photo URLs are cached in-memory per session
/// to avoid redundant Firestore reads.
class UserAvatar extends StatefulWidget {
  final String userId;
  final String displayName;
  final double size;
  final Color? bgColor;
  final Color? textColor;

  /// Pass the photo URL if it is already known (e.g. from a UserModel).
  /// This skips the Firestore fetch and also warms the cache for future use.
  final String? knownPhotoUrl;

  const UserAvatar({
    super.key,
    required this.userId,
    required this.displayName,
    this.size = 40,
    this.bgColor,
    this.textColor,
    this.knownPhotoUrl,
  });

  /// Clear the cache (e.g. after a user updates their photo).
  static void evict(String userId) => _cache.remove(userId);

  static final Map<String, String?> _cache = {};

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    if (widget.knownPhotoUrl != null) {
      _photoUrl = widget.knownPhotoUrl;
      UserAvatar._cache[widget.userId] = widget.knownPhotoUrl;
    } else if (UserAvatar._cache.containsKey(widget.userId)) {
      _photoUrl = UserAvatar._cache[widget.userId];
    } else {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    final url = await FirestoreService().getUserPhotoUrl(widget.userId);
    UserAvatar._cache[widget.userId] = url;
    if (mounted) setState(() => _photoUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.displayName
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          key: ValueKey(_photoUrl),
          imageUrl: _photoUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initials(initials),
          errorWidget: (_, __, ___) => _initials(initials),
        ),
      );
    }
    return _initials(initials);
  }

  Widget _initials(String txt) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.bgColor ?? const Color(0xFFF0F0F0),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            txt,
            style: GoogleFonts.sora(
              fontSize: widget.size * 0.33,
              fontWeight: FontWeight.w700,
              color: widget.textColor ?? const Color(0xFF1A1A1A),
            ),
          ),
        ),
      );
}
