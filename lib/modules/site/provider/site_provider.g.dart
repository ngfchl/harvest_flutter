// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unaddedSitesHash() => r'495c5a688947cf8e820e7beba26b23bc5806f3bf';

/// See also [unaddedSites].
@ProviderFor(unaddedSites)
final unaddedSitesProvider = FutureProvider<List<String>>.internal(
  unaddedSites,
  name: r'unaddedSitesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unaddedSitesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnaddedSitesRef = FutureProviderRef<List<String>>;
String _$websiteListHash() => r'1e022b3dca4ae1db1fb487102f11c2a562f7af52';

/// See also [WebsiteList].
@ProviderFor(WebsiteList)
final websiteListProvider =
    AutoDisposeAsyncNotifierProvider<WebsiteList, List<WebSite>>.internal(
      WebsiteList.new,
      name: r'websiteListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$websiteListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WebsiteList = AutoDisposeAsyncNotifier<List<WebSite>>;
String _$siteInfoListHash() => r'd34a155671b4f9169f6b5d0e4adc48d6d7e8e87e';

/// See also [SiteInfoList].
@ProviderFor(SiteInfoList)
final siteInfoListProvider =
    AsyncNotifierProvider<SiteInfoList, List<SiteInfo>>.internal(
      SiteInfoList.new,
      name: r'siteInfoListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$siteInfoListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SiteInfoList = AsyncNotifier<List<SiteInfo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
