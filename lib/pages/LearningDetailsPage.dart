
// ignore_for_file: unused_element

import 'dart:developer';
import 'package:aiims_heartcare/data/model/LearningContent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LearningDetailsPage extends StatefulWidget {
  final String? slug;
  final String? category;

  const LearningDetailsPage({super.key, this.slug, this.category});

  @override
  State<LearningDetailsPage> createState() => _LearningDetailsPageState();
}

class _LearningDetailsPageState extends State<LearningDetailsPage> {
  bool _isLoading = true;
  var contentList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {
        fetchLearningData(slug: widget.slug ?? '');
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is LearningContentState) {
            handleLearningResponse(state);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '${widget.category}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF0D3B3F),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D3B3F)))
              : contentList.isEmpty
                  ? _buildEmptyState()
                  : _buildContentList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No content found for slug: ${widget.slug}',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B3F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => fetchLearningData(slug: widget.slug ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contentList.length,
      itemBuilder: (context, index) {
        final item = contentList[index];
        return _buildContentCard(item);
      },
    );
  }

  Widget _buildContentCard(Datum item) {
    // Check if content is available
    final hasContent = item.content != null && item.content!.isNotEmpty;
    final hasVideo = item.videoUrl != null && item.videoUrl.toString().isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Image
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D3B3F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Color(0xFF0D3B3F),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3B3F),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status and date info (commented out)
                // Row(
                //   children: [
                //     _buildInfoChip(
                //       Icons.access_time,
                //       item.createdAt != null
                //           ? _formatDate(item.createdAt!)
                //           : 'Unknown date',
                //     ),
                //     const SizedBox(width: 12),
                //     _buildInfoChip(
                //       Icons.check_circle,
                //       item.status != null
                //           ? statusValues.reverse[item.status!] ?? 'Unknown'
                //           : 'Unknown',
                //     ),
                //   ],
                // ),

                // Only show divider if there's content after the title section
                if (hasContent || hasVideo) const SizedBox(height: 16),
                if (hasContent || hasVideo) const Divider(),
                if (hasContent || hasVideo) const SizedBox(height: 8),

                // Content - Only show if available
                if (hasContent) _buildFormattedContent(item.content!),

                // Video section if available
                if (hasVideo)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add space before video section only if there's content above
                      if (hasContent) const SizedBox(height: 16),
                      if (hasContent) const Divider(),
                      if (hasContent) const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_fill,
                            color: Color(0xFF0D3B3F),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Video Content',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Only show bottom padding if there's content or video
                if (hasContent || hasVideo) const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    // Split content by lines
    List<String> lines = content.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);
        
        // Check for numbered list items (lines starting with numbers)
        if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.substring(0, line.indexOf('.') + 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.substring(line.indexOf('.') + 1).trim(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }
        // Check for sub-points (lines starting with ->)
        else if (line.trim().startsWith('->')) {
          return Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    line.substring(2).trim(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }
        // Regular text
        else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void fetchLearningData({required String slug}) {
    Log.v("Fetching learning data with slug: $slug");
    debugPrint("Confirming slug in fetchLearningData: $slug");
    BlocProvider.of<HomeBloc>(context).add(LearningContentEvent(slug: slug));
  }

  void handleLearningResponse(LearningContentState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        Log.v("Loading...");
        setState(() {
          _isLoading = true;
        });
        break;
      case ApiStatus.SUCCESS:
        Log.v("Success learning data : ${state.response}");
        setState(() {
          _isLoading = false;
          contentList = state.response?.data ?? [];
          log('data is ${state.response?.data}');
        });
        break;
      case ApiStatus.ERROR:
        Log.v("Error: ${state.error}");
        setState(() {
          _isLoading = false;
        });
        break;
      case ApiStatus.INITIAL:
        break;
    }
  }
}