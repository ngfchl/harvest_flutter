// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WebsiteList)
final websiteListProvider = WebsiteListProvider._();

final class WebsiteListProvider
    extends $AsyncNotifierProvider<WebsiteList, List<WebSite>> {
  WebsiteListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'websiteListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$websiteListHash();

  @$internal
  @override
  WebsiteList create() => WebsiteList();
}

String _$websiteListHash() => r'a0296e87522e94aef2b10e5e275448652f121e2b';

abstract class _$WebsiteList extends $AsyncNotifier<List<WebSite>> {
  FutureOr<List<WebSite>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<WebSite>>, List<WebSite>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<WebSite>>, List<WebSite>>,
              AsyncValue<List<WebSite>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SiteInfoList)
final siteInfoListProvider = SiteInfoListProvider._();

final class SiteInfoListProvider
    extends $AsyncNotifierProvider<SiteInfoList, List<SiteInfo>> {
  SiteInfoListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteInfoListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteInfoListHash();

  @$internal
  @override
  SiteInfoList create() => SiteInfoList();
}

String _$siteInfoListHash() => r'1a894457d693f420c04a5d31549cd1b6452cf5bc';

abstract class _$SiteInfoList extends $AsyncNotifier<List<SiteInfo>> {
  FutureOr<List<SiteInfo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SiteInfo>>, List<SiteInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SiteInfo>>, List<SiteInfo>>,
              AsyncValue<List<SiteInfo>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(unaddedSites)
final unaddedSitesProvider = UnaddedSitesProvider._();

final class UnaddedSitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  UnaddedSitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unaddedSitesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unaddedSitesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return unaddedSites(ref);
  }
}

String _$unaddedSitesHash() => r'495c5a688947cf8e820e7beba26b23bc5806f3bf';
