abstract class Environment {
  String get baseUrl;
  String get apiKey;
  EnvironmentType get type;
}

enum EnvironmentType { DEV, PROD }
