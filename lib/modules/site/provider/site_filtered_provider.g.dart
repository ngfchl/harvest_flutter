// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_filtered_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(availableTags)
final availableTagsProvider = AvailableTagsProvider._();

final class AvailableTagsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  AvailableTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableTagsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return availableTags(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$availableTagsHash() => r'b917e0a5589858dd96667d3e5e6c9eb658754c0b';

@ProviderFor(filteredSiteList)
final filteredSiteListProvider = FilteredSiteListProvider._();

final class FilteredSiteListProvider
    extends $FunctionalProvider<List<SiteInfo>, List<SiteInfo>, List<SiteInfo>>
    with $Provider<List<SiteInfo>> {
  FilteredSiteListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredSiteListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredSiteListHash();

  @$internal
  @override
  $ProviderElement<List<SiteInfo>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SiteInfo> create(Ref ref) {
    return filteredSiteList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SiteInfo> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SiteInfo>>(value),
    );
  }
}

String _$filteredSiteListHash() => r'ec7ce6ad745d00cee35d3200ab6d1927cde04db5';
