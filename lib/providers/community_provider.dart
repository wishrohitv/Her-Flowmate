import 'package:flutter/foundation.dart';
import '../domain/entities/community_post.dart';
import '../domain/use_cases/get_community_feed.dart';

/// Presentation Layer: State provider for the Community feature.
/// It only depends on Use Cases, not on raw repositories or data sources.
class CommunityProvider extends ChangeNotifier {
  final GetCommunityFeed getFeedUseCase;

  CommunityProvider({required this.getFeedUseCase});

  List<CommunityPost> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<CommunityPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await getFeedUseCase.execute();
    } catch (e) {
      _error = 'Failed to load community feed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
