import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/themes/theme_provider.dart';

String? extractYoutubeId(String url) {
  final uri = Uri.parse(url);
  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
  if (uri.host.contains('youtube.com')) {
    return uri.queryParameters['v']
        ?? (uri.pathSegments.length > 1 && uri.pathSegments[0] == 'embed'
            ? uri.pathSegments[1]
            : null);
  }
  return null;
}

class YoutubePlayerWidget extends StatelessWidget {
  final String src;
  final BloomTheme t;
  final String? title;
  const YoutubePlayerWidget({super.key, required this.src, required this.t, this.title});

  @override
  Widget build(BuildContext context) {
    final videoId = extractYoutubeId(src);
    final thumbUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;

    return Semantics(
      button: true,
      label: 'Buka video ${title ?? ''} di YouTube',
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(src),
            mode: LaunchMode.externalApplication),
        child: Container(
          decoration: BoxDecoration(
            color: t.bgSurface2,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                if (thumbUrl != null)
                  CachedNetworkImage(imageUrl: thumbUrl, width: double.infinity,
                      height: double.infinity, fit: BoxFit.cover,
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) => const SizedBox.shrink()),

                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.35)),
                ),

                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.play_circle_fill_rounded,
                          color: Color(0xFFFF0000), size: 16),
                      const SizedBox(width: 4),
                      Text('YouTube',
                          style: GoogleFonts.nunito(
                              color: Colors.white, fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),

                Center(
                  child: Container(
                    width: 64, height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5C518),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Color(0xFF1A1A1A), size: 38),
                  ),
                ),

                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title ?? 'Tonton Video',
                            style: GoogleFonts.nunito(
                                color: Colors.white, fontSize: 13,
                                fontWeight: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Ketuk untuk menonton di YouTube',
                            style: GoogleFonts.nunito(
                                color: Colors.white70, fontSize: 10)),
                      ],
                    ),
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
