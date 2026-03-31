import '../entities/community_post.dart';
import '../repositories/i_community_repository.dart';

/// Single-purpose Use Case for fetching the community feed.
/// Highly testable and encapsulates exactly one piece of logic.
class GetCommunityFeed {
  final ICommunityRepository repository;

  GetCommunityFeed(this.repository);

  Future<List<CommunityPost>> execute() async {
    // We could add business logic here (e.g. sorting, filtering blocked users)
    final posts = await repository.getFeedPosts();
    return posts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
