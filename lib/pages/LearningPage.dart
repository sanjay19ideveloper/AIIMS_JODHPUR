import 'dart:developer';
import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/pages/LearningDetailsPage.dart';
import 'package:aiims_heartcare/utils/loading.dart';
import 'package:aiims_heartcare/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class MyLearningPage extends StatefulWidget {
  const MyLearningPage({super.key});

  @override
  State<MyLearningPage> createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage> {
  bool _isLoading = true;
  var contentList = [];

  @override
  void initState() {
    super.initState();
    fetchLearningData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (BuildContext context) {
        fetchLearningData();
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is LearningState) {
            handleLearningResponse(state);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'My Learning',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF0D3B3F),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: ScreenWithLoader(
            isLoading: _isLoading,
            body: _isLoading
                ? _buildShimmerLoading()
                : contentList.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: contentList.length,
                        itemBuilder: (context, index) {
                          final content = contentList[index];
                          return ContentCard(
                            title: content.name ?? '',
                            description:
                                content.description ?? content.tagline ?? '',
                            imageUrl: content.imageUrl ?? '',
                            slug: content.slug ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LearningDetailsPage(
                                    slug: content.slug ?? '',
                                    category: content.name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : _buildEmptyState(), // Changed from showing text to custom empty state
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Learning Content',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Learning content will appear here once available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                fetchLearningData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B3F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchLearningData() {
    BlocProvider.of<HomeBloc>(context).add(MyLearningEvent());
  }

  void handleLearningResponse(LearningState state) {
    switch (state.apiState) {
      case ApiStatus.LOADING:
        Log.v("Loading...");
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

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            height: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 100,
                            height: 10,
                            color: Colors.white,
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 120,
                              height: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String slug;
  final VoidCallback onTap;

  const ContentCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.slug,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: isSmallScreen ? _buildVerticalLayout() : _buildHorizontalLayout(),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side image
        SizedBox(width: 120, height: 140, child: _buildImage()),
        // Right side content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3B3F),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _buildExploreButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top image
        SizedBox(width: double.infinity, height: 160, child: _buildImage()),
        // Content below
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3B3F),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: _buildExploreButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultImage();
            },
          )
        : _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return Container(
      color: const Color(0xFFE0F2F1),
      child: const Center(
        child: Icon(Icons.menu_book, size: 50, color: Color(0xFF0D3B3F)),
      ),
    );
  }

  Widget _buildExploreButton() {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Text(
        'Explore Now',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      label: const Icon(Icons.arrow_forward, size: 16),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D3B3F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}