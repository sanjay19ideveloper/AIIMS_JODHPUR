
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/model/LearningContent.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';

class LearningDetailsPage extends StatefulWidget {
  final String? slug;
  final String? category;

  const LearningDetailsPage({super.key, this.slug, this.category});

  @override
  State<LearningDetailsPage> createState() => _LearningDetailsPageState();
}

class _LearningDetailsPageState extends State<LearningDetailsPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Datum> contentList = [];
  List<bool> _expandedList = [];

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (_) => fetchLearningData(slug: widget.slug ?? ''),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (_, state) {
          if (state is LearningContentState) {
            handleLearningResponse(state);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              widget.category ?? 'Learning',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF0D3B3F),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0D3B3F),
                  ),
                )
              : contentList.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                    
                      padding: const EdgeInsets.all(14),
                      itemCount: contentList.length,
                      itemBuilder: (_, index) =>
                          _buildExpandableCard(contentList[index], index),
                    ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  Widget _buildExpandableCard(Datum item, int index) {
    final bool isExpanded =
        index < _expandedList.length ? _expandedList[index] : false;

    final bool hasImage = item.imageUrl?.isNotEmpty == true;
    final bool hasContent = item.content?.isNotEmpty == true;
    final bool hasVideo = item.videoUrl?.isNotEmpty == true;

    return GestureDetector(
      onTap: () => _toggle(index),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        color: Color(0xFF0D3B3F),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title ?? 'Untitled',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF0D3B3F),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isExpanded && (hasContent || hasVideo)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              const Divider(),
                              if (hasContent)
                                _buildFormattedContent(item.content!),
                              if (hasVideo) _videoSection(),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text('No learning content available'),
    );
  }

  // ---------------- CONTENT ----------------

  Widget _buildFormattedContent(String content) {
    final lines = content.split('\n');

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          if (line.trim().isEmpty) return const SizedBox(height: 8);

          if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.substring(0, line.indexOf('.') + 1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    line.substring(line.indexOf('.') + 1).trim(),
                  ),
                ),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(line),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- LOGIC ----------------

  void _toggle(int index) {
    if (index >= _expandedList.length) return;
    setState(() => _expandedList[index] = !_expandedList[index]);
  }

  void fetchLearningData({required String slug}) {
    BlocProvider.of<HomeBloc>(context)
        .add(LearningContentEvent(slug: slug));
  }

  void handleLearningResponse(LearningContentState state) {
    if (state.apiState == ApiStatus.SUCCESS) {
      setState(() {
        _isLoading = false;
        contentList = state.response?.data ?? [];
        _expandedList = List<bool>.filled(contentList.length, false);
      });
    } else if (state.apiState == ApiStatus.LOADING) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoading = false);
    }
  }
}
