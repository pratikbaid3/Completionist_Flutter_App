import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchHtmlUrl(String url) async {
  final raw = url.trim();
  if (raw.isEmpty) return false;

  final resolvedUrl = _resolveLaunchUrl(raw);
  final uri = Uri.tryParse(resolvedUrl);
  if (uri == null) return false;

  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  return false;
}

String _resolveLaunchUrl(String url) {
  final youtubeId = _youtubeVideoId(url);
  if (youtubeId != null) {
    return 'https://www.youtube.com/watch?v=$youtubeId';
  }
  return url;
}

Widget? buildHtmlVideoWidget(dom.Element element) {
  final tag = element.localName?.toLowerCase();
  if (tag == 'iframe') {
    final src = element.attributes['src']?.trim();
    if (src == null || src.isEmpty) return null;
    return _buildVideoTile(
      src,
      element.attributes['title'] ?? 'Watch video guide',
      thumbnailUrl: _youtubeThumbnailUrl(src),
    );
  }

  if (tag == 'video') {
    final src = _videoUrlFromVideoElement(element);
    if (src == null || src.isEmpty) return null;
    return _buildVideoTile(
      src,
      element.attributes['title'] ?? 'Watch video guide',
      thumbnailUrl: _youtubeThumbnailUrl(src),
    );
  }

  return null;
}

String? _videoUrlFromVideoElement(dom.Element element) {
  final src = element.attributes['src']?.trim();
  if (src != null && src.isNotEmpty) {
    return src;
  }

  for (final child in element.children) {
    if (child.localName?.toLowerCase() == 'source') {
      final sourceUrl = child.attributes['src']?.trim();
      if (sourceUrl != null && sourceUrl.isNotEmpty) {
        return sourceUrl;
      }
    }
  }

  return null;
}

String? _youtubeVideoId(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;

  final host = uri.host.toLowerCase();
  if (host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
  }

  if (host.contains('youtube.com')) {
    if (uri.pathSegments.contains('watch')) {
      return uri.queryParameters['v'];
    }
    if (uri.pathSegments.contains('embed') && uri.pathSegments.length > 1) {
      return uri.pathSegments.last;
    }
  }

  return null;
}

String? _youtubeThumbnailUrl(String url) {
  final id = _youtubeVideoId(url);
  if (id == null) return null;
  return 'https://img.youtube.com/vi/$id/maxresdefault.jpg';
}

Widget _buildVideoTile(String url, String title, {String? thumbnailUrl}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await launchHtmlUrl(url);
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F222A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumbnailUrl != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 160,
                      color: const Color(0xFF262B37),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 160,
                      color: const Color(0xFF262B37),
                      child: const Icon(Icons.play_circle_fill_rounded,
                          color: Colors.white54, size: 40),
                    ),
                  ),
                ),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (thumbnailUrl != null)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                  if (thumbnailUrl != null)
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  if (thumbnailUrl == null)
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _resolveLaunchUrl(url),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
