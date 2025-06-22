import 'package:aiims_heartcare/data/api/api_service.dart';
import 'package:aiims_heartcare/data/provider/home_provider.dart';
import 'package:aiims_heartcare/data/repositories/home_repository.dart';
import 'package:injector/injector.dart';

void setupDependencyInjections() async {
  Injector injector = Injector.appInstance;
  injector.registerSingleton<ApiService>(() => ApiService());

  _homeProviderDI(injector);
  _homeRepositoryDI(injector);
 
}

void _homeProviderDI(Injector injector) {
  injector.registerDependency<HomeProvider>(() {
    var api = injector.get<ApiService>();
    return HomeProvider(api: api);
  });
}

void _homeRepositoryDI(Injector injector) {
  injector.registerDependency<HomeRepository>(() {
    var homeProvider = injector.get<HomeProvider>();
    return HomeRepository(homeProvider: homeProvider);
  });
}



