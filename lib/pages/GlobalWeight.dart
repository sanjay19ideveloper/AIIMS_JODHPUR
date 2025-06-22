// global_data.dart
class GlobalData {
  // Singleton instance
  static final GlobalData _instance = GlobalData._internal();
  
  factory GlobalData() {
    return _instance;
  }
  
  GlobalData._internal();

  // Global variables
  double? weightCount;
  List<dynamic>? weightList; // Adjust the type based on your Weight model

  // Methods to update or clear data (optional)
  void setWeightCount(double? count) {
    weightCount = count;
  }

  void setWeightList(List<dynamic>? list) {
    weightList = list;
  }

  void clear() {
    weightCount = null;
    weightList = null;
  }
}