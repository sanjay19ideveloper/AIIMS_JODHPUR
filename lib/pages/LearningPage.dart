import 'package:aiims_heartcare/blocs/bloc_manager.dart';
import 'package:aiims_heartcare/blocs/home_bloc.dart';
import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/pages/LearningCard.dart';
import 'package:aiims_heartcare/pages/LearningDetailsPage.dart';
import 'package:aiims_heartcare/utils/loading.dart';
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
  List<dynamic> contentList = [];

  @override
  void initState() {
    super.initState();
    fetchLearningData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager(
      initState: (_) => fetchLearningData(),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is LearningState) {
            handleLearningResponse(state);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'My Learning',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF0D3B3F),
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
                          return LearningCard(
                            title: content.name ?? '',
                            description:
                                content.description ?? content.tagline ?? '',
                            imageUrl: content.imageUrl ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LearningDetailsPage(
                                    slug: content.slug ?? '',
                                    category: content.name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : _buildEmptyState(),
          ),
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
        break;
      case ApiStatus.SUCCESS:
        setState(() {
          _isLoading = false;
          contentList = state.response?.data ?? [];
        });
        break;
      case ApiStatus.ERROR:
        setState(() => _isLoading = false);
        break;
      default:
        break;
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No learning content available',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
