import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/database/sqlite/sqlite_helper.dart';
import 'core/network/network_info.dart';
import 'core/config/app_config.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_api_data_source_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/watch_auth_state.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

// Products
import 'features/products/data/datasources/local/product_local_data_source.dart';
import 'features/products/data/datasources/local/product_sqlite_data_source_impl.dart';
import 'features/products/data/datasources/local/product_web_local_data_source_impl.dart';
import 'features/products/data/datasources/remote/product_remote_data_source.dart';
import 'features/products/data/datasources/remote/product_remote_data_source_impl.dart';
import 'features/products/data/datasources/remote/product_firestore_data_source_impl.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/domain/usecases/add_product.dart';
import 'features/products/domain/usecases/delete_product.dart';
import 'features/products/domain/usecases/get_all_products.dart';
import 'features/products/domain/usecases/get_low_stock_products.dart';
import 'features/products/domain/usecases/get_product_by_id.dart';
import 'features/products/domain/usecases/update_product.dart';
import 'features/products/presentation/cubit/product_cubit.dart';

// Suppliers
import 'features/suppliers/data/datasources/supplier_local_data_source.dart';
import 'features/suppliers/data/datasources/supplier_local_data_source_impl.dart';
import 'features/suppliers/data/datasources/supplier_web_local_data_source_impl.dart';
import 'features/suppliers/data/datasources/supplier_remote_data_source.dart';
import 'features/suppliers/data/datasources/supplier_api_data_source_impl.dart';
import 'features/suppliers/data/datasources/supplier_firestore_data_source_impl.dart';
import 'features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'features/suppliers/domain/repositories/supplier_repository.dart';
import 'features/suppliers/domain/usecases/get_all_suppliers.dart';
import 'features/suppliers/domain/usecases/add_supplier.dart';
import 'features/suppliers/domain/usecases/update_supplier.dart';
import 'features/suppliers/domain/usecases/delete_supplier.dart';
import 'features/suppliers/presentation/cubit/supplier_cubit.dart';

// Audit
import 'features/audit/data/datasources/audit_local_data_source.dart';
import 'features/audit/data/datasources/audit_local_data_source_impl.dart';
import 'features/audit/data/datasources/audit_web_local_data_source_impl.dart';
import 'features/audit/data/datasources/remote/audit_remote_data_source.dart';
import 'features/audit/data/datasources/remote/audit_firestore_data_source_impl.dart';
import 'features/audit/data/repositories/audit_repository_impl.dart';
import 'features/audit/data/repositories/product_audit_decorator.dart';
import 'features/audit/domain/repositories/audit_repository.dart';
import 'features/audit/domain/usecases/get_all_audit_logs.dart';
import 'features/audit/domain/usecases/get_product_audit_logs.dart';
import 'features/audit/domain/usecases/watch_all_audit_logs.dart';
import 'features/audit/presentation/cubit/audit_cubit.dart';

// Dashboard
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';

// Warehouses
import 'features/warehouses/data/datasources/warehouse_remote_data_source.dart';
import 'features/warehouses/data/datasources/warehouse_remote_data_source_impl.dart';
import 'features/warehouses/data/repositories/warehouse_repository_impl.dart';
import 'features/warehouses/domain/repositories/warehouse_repository.dart';
import 'features/warehouses/domain/usecases/get_warehouses.dart';
import 'features/warehouses/domain/usecases/add_warehouse.dart';
import 'features/warehouses/domain/usecases/update_warehouse.dart';
import 'features/warehouses/domain/usecases/delete_warehouse.dart';
import 'features/warehouses/presentation/cubit/warehouse_cubit.dart';

// Notifications
import 'core/notifications/presentation/cubit/notification_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final backend = AppConfig.activeBackend;

  //! Core
  sl.registerFactory(() => NotificationCubit());

  //! Features - Dashboard
  sl.registerFactory(
    () => DashboardCubit(
      productRepository: sl(),
      supplierRepository: sl(),
    ),
  );

  //! Features - Warehouses
  // Presentation
  sl.registerFactory(
    () => WarehouseCubit(
      getWarehousesUseCase: sl(),
      addWarehouseUseCase: sl(),
      updateWarehouseUseCase: sl(),
      deleteWarehouseUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWarehouses(sl()));
  sl.registerLazySingleton(() => AddWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWarehouseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWarehouseUseCase(sl()));

  // Repository
  sl.registerLazySingleton<WarehouseRepository>(
    () => WarehouseRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WarehouseRemoteDataSource>(
    () => WarehouseRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Auth
  // Presentation
  sl.registerFactory(
    () => AuthCubit(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      watchAuthStateUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => WatchAuthState(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  if (backend == BackendType.firebase) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
    );
  } else {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthApiDataSourceImpl(client: sl()),
    );
  }

  //! Features - Products
  // Presentation
  sl.registerFactory(
    () => ProductCubit(
      getAllProducts: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      getLowStockProducts: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AddProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));
  sl.registerLazySingleton(() => GetAllProducts(sl()));
  sl.registerLazySingleton(() => GetLowStockProducts(sl()));
  sl.registerLazySingleton(() => GetProductById(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductAuditDecorator(
      ProductRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        networkInfo: sl(),
      ),
      sl(),
      sl(),
    ),
  );

  // Data sources
  if (kIsWeb) {
    sl.registerLazySingleton<ProductLocalDataSource>(() => ProductWebLocalDataSourceImpl());
  } else {
    sl.registerLazySingleton<ProductLocalDataSource>(
      () => ProductSqliteDataSourceImpl(dbHelper: sl()),
    );
  }
  
  if (backend == BackendType.firebase) {
    sl.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductFirestoreDataSourceImpl(firestore: sl()),
    );
  } else {
    sl.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(client: sl()),
    );
  }

  //! Features - Suppliers
  // Presentation
  sl.registerFactory(
    () => SupplierCubit(
      getAllSuppliers: sl(),
      addSupplierUseCase: sl(),
      updateSupplierUseCase: sl(),
      deleteSupplierUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllSuppliers(sl()));
  sl.registerLazySingleton(() => AddSupplier(sl()));
  sl.registerLazySingleton(() => UpdateSupplier(sl()));
  sl.registerLazySingleton(() => DeleteSupplier(sl()));

  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  if (kIsWeb) {
    sl.registerLazySingleton<SupplierLocalDataSource>(() => SupplierWebLocalDataSourceImpl());
  } else {
    sl.registerLazySingleton<SupplierLocalDataSource>(
      () => SupplierLocalDataSourceImpl(sl()),
    );
  }
  
  if (backend == BackendType.firebase) {
    sl.registerLazySingleton<SupplierRemoteDataSource>(
      () => SupplierFirestoreDataSourceImpl(firestore: sl()),
    );
  } else {
    sl.registerLazySingleton<SupplierRemoteDataSource>(
      () => SupplierApiDataSourceImpl(client: sl()),
    );
  }

  //! Features - Audit
  // Presentation
  sl.registerFactory(
    () => AuditCubit(
      getAllAuditLogs: sl(),
      getProductAuditLogs: sl(),
      watchAllAuditLogs: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllAuditLogs(sl()));
  sl.registerLazySingleton(() => GetProductAuditLogs(sl()));
  sl.registerLazySingleton(() => WatchAllAuditLogs(sl()));

  sl.registerLazySingleton<AuditRepository>(
    () => AuditRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  if (kIsWeb) {
    sl.registerLazySingleton<AuditLocalDataSource>(() => AuditWebLocalDataSourceImpl());
  } else {
    sl.registerLazySingleton<AuditLocalDataSource>(
      () => AuditLocalDataSourceImpl(sl()),
    );
  }
  sl.registerLazySingleton<AuditRemoteDataSource>(
    () => AuditFirestoreDataSourceImpl(firestore: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(kIsWeb ? null : sl()));
  if (!kIsWeb) {
    sl.registerLazySingleton(() => SqliteHelper());
  }

  //! External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => http.Client());
  if (!kIsWeb) {
    sl.registerLazySingleton(() => InternetConnectionChecker());
  }
}
