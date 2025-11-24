import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memorion_caregiver/components/dependent_skeleton_item.dart';
import 'package:memorion_caregiver/components/shimmer_loading.dart';
import 'package:memorion_caregiver/components/tag.dart';
import 'package:memorion_caregiver/const/colors.dart';
import 'package:memorion_caregiver/const/other.dart';
import 'package:memorion_caregiver/const/value_name.dart';
import 'package:memorion_caregiver/screens/add_career_screen.dart';
import 'package:memorion_caregiver/screens/more_screen.dart';
import 'package:memorion_caregiver/services/api_client.dart';
import 'package:memorion_caregiver/services/dependent_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late ApiClient _apiClient;
  late DependentService _dependentService;
  bool _isLoading = false;
  String? _errorMessage = "";
  List<dynamic> _dependents = []; // or List<Map<String, dynamic>>

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _dependentService = DependentService(_apiClient);

    _fetchDependents();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchDependents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final resp = await _dependentService.getDependents();

    if (!mounted) return;

    if (resp["status"] == 200) {
      final data = resp["data"]["dependents"];
      setState(() {
        _dependents = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = resp["message"]?.toString() ?? "Unknown error";
        _isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      // Shimmer skeleton list
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 4, // skeleton item count
        itemBuilder: (context, index) {
          return const ShimmerLoading(
            isLoading: true,
            child: DependentSkeletonItem(),
          );
        },
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Error: $_errorMessage"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchDependents,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_dependents.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchDependents,
        child: ListView(
          children: const [
            SizedBox(height: 200),
            Center(child: Text("등록된 피보호자가 없어요.")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDependents,
      child: ListView.builder(
        itemCount: _dependents.length,
        itemBuilder: (context, index) {
          final item = _dependents[index] as Map<String, dynamic>;
          final name = item["name"] ?? "";
          final stat = item["last_state"] ?? -1;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: Other.gapS, horizontal: Other.margin),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: Other.gapSS, horizontal: Other.gapSS),
              decoration: BoxDecoration(
                color: AppColors.whiteMain,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(name, style: Theme.of(context).textTheme.titleMedium,),
                      subtitle: Text(statusText[stat] ?? "알 수 없는 상태"),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MoreScreen(item: item))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: statusTag[stat] ?? otherTag(),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        leadingWidth: 92,
        toolbarHeight: 40,
        titleSpacing: -16,
        leading: SvgPicture.asset("assets/images/memorion_logo.svg", fit: BoxFit.fitHeight,), 
        title: Text("따듯한전화", style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: AppColors.main
        )),
      ),
      body: Shimmer(
        linearGradient: shimmerGradient,
        child: _buildBody(),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddCareerScreen()));
        },
        backgroundColor: AppColors.main,
        disabledElevation: 0, // 주황색 등 테마색
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}