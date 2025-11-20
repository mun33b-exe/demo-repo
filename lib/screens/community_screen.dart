import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_repo/models/post.dart';
import 'package:intl/intl.dart';
import 'package:demo_repo/l10n/app_localizations.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _postController = TextEditingController();
  bool _isPosting = false;

  Future<void> _createPost() async {
    final l10n = AppLocalizations.of(context)!;
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception(l10n.userNotLoggedIn);

      await Supabase.instance.client.from('posts').insert({
        'content': content,
        'user_email': user.email,
        'likes': [],
      });

      _postController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await Supabase.instance.client.from('posts').delete().eq('id', postId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.postDeletedSuccess)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDeletingPost(e.toString()))),
        );
      }
    }
  }

  Future<void> _editPost(Post post) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: post.content);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editPost),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.enterNewContent),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await Supabase.instance.client
                    .from('posts')
                    .update({'content': controller.text.trim()})
                    .eq('id', post.id);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.postUpdatedSuccess)),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.errorUpdatingPost(e.toString())),
                  ),
                );
              }
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(String postId) async {
    final l10n = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.rpc(
        'toggle_like',
        params: {'post_id': postId},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorUpdatingLike(e.toString()))),
        );
      }
      rethrow; // Allow PostCard to handle the error by reverting state
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    print('DEBUG: Building CommunityScreen with Tabs');
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.communityTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.feed),
              Tab(text: l10n.myPosts),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _PostList(
                    isMyPosts: false,
                    onToggleLike: _toggleLike,
                    onEdit: _editPost,
                    onDelete: _deletePost,
                  ),
                  _PostList(
                    isMyPosts: true,
                    onToggleLike: _toggleLike,
                    onEdit: _editPost,
                    onDelete: _deletePost,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: InputDecoration(
                        hintText: l10n.askSomething,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton.filled(
                    onPressed: _isPosting ? null : _createPost,
                    icon: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  final bool isMyPosts;
  final Future<void> Function(String) onToggleLike;
  final Function(Post) onEdit;
  final Function(String) onDelete;

  const _PostList({
    required this.isMyPosts,
    required this.onToggleLike,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserEmail = Supabase.instance.client.auth.currentUser?.email;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: isMyPosts
          ? Supabase.instance.client
                .from('posts')
                .stream(primaryKey: ['id'])
                .eq('user_email', currentUserEmail ?? '')
                .order('created_at', ascending: false)
          : Supabase.instance.client
                .from('posts')
                .stream(primaryKey: ['id'])
                .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadingPosts,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isMyPosts ? Icons.article_outlined : Icons.forum_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  isMyPosts ? l10n.haventPosted : l10n.noPostsYet,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  isMyPosts ? l10n.shareThoughts : l10n.startConversation,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final posts = data.map((e) => Post.fromJson(e)).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                key: ValueKey(post.id), // Important for state preservation
                post: post,
                currentUserEmail: currentUserEmail,
                onToggleLike: onToggleLike,
                onEdit: onEdit,
                onDelete: onDelete,
              );
            },
          ),
        );
      },
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final String? currentUserEmail;
  final Future<void> Function(String) onToggleLike;
  final Function(Post) onEdit;
  final Function(String) onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserEmail,
    required this.onToggleLike,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    _updateStateFromPost();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update from widget if the remote state might have changed
    // independent of our local optimistic update, or to sync up eventually.
    // For now, we trust the stream to eventually be consistent, but we
    // don't want to overwrite our optimistic state immediately if the stream
    // lags behind.
    // However, since the stream is the source of truth, we should probably
    // sync with it if it differs, UNLESS we are currently toggling?
    // A simple approach: always sync with widget, but when toggling,
    // we might see a flicker if the stream is slow.
    // Better approach for "instant" feel:
    // Initialize state. When user taps, update local state.
    // If stream updates, we update local state.
    // If stream update matches our optimistic state, great.
    // If stream update is "old" (e.g. before our toggle), we might flicker.
    // But usually Supabase Realtime is fast.
    // Let's just sync for now.
    _updateStateFromPost();
  }

  void _updateStateFromPost() {
    isLiked = widget.post.likes.contains(widget.currentUserEmail);
    likeCount = widget.post.likes.length;
  }

  Future<void> _handleLike() async {
    final previousIsLiked = isLiked;
    final previousLikeCount = likeCount;

    setState(() {
      if (isLiked) {
        isLiked = false;
        likeCount--;
      } else {
        isLiked = true;
        likeCount++;
      }
    });

    try {
      await widget.onToggleLike(widget.post.id);
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          isLiked = previousIsLiked;
          likeCount = previousLikeCount;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final date = widget.post.createdAt.toLocal();
    final isAuthor = widget.post.userEmail == widget.currentUserEmail;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    (widget.post.userEmail ?? '?')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userEmail ?? l10n.unknown,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('MMM d, h:mm a').format(date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isAuthor)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        widget.onEdit(widget.post);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.deletePost),
                            content: Text(l10n.confirmDeletePost),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onDelete(widget.post.id);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.post.content),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: _handleLike,
                ),
                Text('$likeCount ${l10n.likes}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
