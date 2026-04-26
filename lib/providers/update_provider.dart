import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/providers/settings/client_settings_provider.dart';
import 'package:fladder/util/update_checker.dart';

part 'update_provider.freezed.dart';
part 'update_provider.g.dart';

final hasNewUpdateProvider = Provider<bool>((ref) {
  final latestRelease = ref.watch(updateProvider).latestRelease;
  final lastViewedVersion = ref.watch(clientSettingsProvider.select((value) => value.lastViewedUpdate));

  final latestVersion = latestRelease?.version;

  if (latestVersion == null || lastViewedVersion == null) {
    return false;
  }

  return latestVersion != lastViewedVersion;
});

// PERSONAL FORK: update checking permanently disabled. We never want this
// fork to surface "a new version is available" prompts because we're locked
// to a known-good build with our own .strm fix. Original implementation
// preserved in git history if you want to bring it back.
@Riverpod(keepAlive: true)
class Update extends _$Update {
  final updateChecker = UpdateChecker();

  @override
  UpdatesModel build() {
    return UpdatesModel();
  }

  void toggleUpdateChecker(bool checkForUpdates) {
    // no-op: update checks are permanently off in this fork.
  }

  Future<List<ReleaseInfo>> _fetchLatest() async {
    return const <ReleaseInfo>[];
  }
}

@Freezed(toJson: false, fromJson: false)
abstract class UpdatesModel with _$UpdatesModel {
  const UpdatesModel._();

  factory UpdatesModel({
    @Default([]) List<ReleaseInfo> lastRelease,
  }) = _UpdatesModel;

  ReleaseInfo? get latestRelease => lastRelease.firstWhereOrNull((value) => value.isNewerThanCurrent);
}
