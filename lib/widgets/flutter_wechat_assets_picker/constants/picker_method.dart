// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import 'extensions.dart';

Future<AssetEntity?> _pickFromCamera(BuildContext c) {
  return CameraPicker.pickFromCamera(
    c,
    pickerConfig: const CameraPickerConfig(enableRecording: true),
  );
}

/// Define a regular pick method.
class PickMethod {
  const PickMethod({
    required this.icon,
    required this.name,
    required this.description,
    required this.method,
    this.onLongPress,
  });

  factory PickMethod.common(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '📹',
      name: 'Common',
      description: 'Common Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
          ),
        );
      },
    );
  }

  factory PickMethod.image(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '🖼️',
      name: 'Image',
      description: 'Image Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            requestType: RequestType.image,
          ),
        );
      },
    );
  }

  factory PickMethod.video(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '🎞',
      name: 'Video',
      description: 'Video Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            requestType: RequestType.video,
          ),
        );
      },
    );
  }

  factory PickMethod.audio(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '🎶',
      name: 'Audio',
      description: 'Audio Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            requestType: RequestType.audio,
          ),
        );
      },
    );
  }

  factory PickMethod.camera({
    required BuildContext context,
    required int maxAssetsCount,
    required Function(BuildContext, AssetEntity) handleResult,
  }) {
    return PickMethod(
      icon: '📷',
      name: 'Camera',
      description: 'Camera Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        const AssetPickerTextDelegate textDelegate = AssetPickerTextDelegate();
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            specialItemPosition: SpecialItemPosition.prepend,
            specialItemBuilder: (
              BuildContext context,
              AssetPathEntity? path,
              int length,
            ) {
              if (path?.isAll != true) {
                return null;
              }
              return Semantics(
                label: textDelegate.sActionUseCameraHint,
                button: true,
                onTapHint: textDelegate.sActionUseCameraHint,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Feedback.forTap(context);
                    final AssetEntity? result = await _pickFromCamera(context);
                    if (result != null) {
                      handleResult(context, result);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(28.0),
                    color: Theme.of(context).dividerColor,
                    child: const FittedBox(
                      fit: BoxFit.fill,
                      child: Icon(Icons.camera_enhance),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  factory PickMethod.cameraAndStay(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '📸',
      name: 'CameraAndStay',
      description: 'CameraAndStay Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        const AssetPickerTextDelegate textDelegate = AssetPickerTextDelegate();
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            specialItemPosition: SpecialItemPosition.prepend,
            specialItemBuilder: (
              BuildContext context,
              AssetPathEntity? path,
              int length,
            ) {
              if (path?.isAll != true) {
                return null;
              }
              return Semantics(
                label: textDelegate.sActionUseCameraHint,
                button: true,
                onTapHint: textDelegate.sActionUseCameraHint,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final AssetEntity? result = await _pickFromCamera(context);
                    if (result == null) {
                      return;
                    }
                    final picker = context.findAncestorWidgetOfExactType<
                        AssetPicker<AssetEntity, AssetPathEntity>>()!;
                    final builder =
                        picker.builder as DefaultAssetPickerBuilderDelegate;
                    final p = builder.provider;
                    await p.switchPath(
                      PathWrapper<AssetPathEntity>(
                        path:
                            await p.currentPath!.path.obtainForNewProperties(),
                      ),
                    );
                    p.selectAsset(result);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(28.0),
                    color: Theme.of(context).dividerColor,
                    child: const FittedBox(
                      fit: BoxFit.fill,
                      child: Icon(Icons.camera_enhance),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  factory PickMethod.threeItemsGrid(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '🔲',
      name: 'ThreeItemsGrid',
      description: 'ThreeItemsGrid Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            gridCount: 3,
            pageSize: 120,
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            requestType: RequestType.all,
          ),
        );
      },
    );
  }

  factory PickMethod.customFilterOptions(
    BuildContext context,
    int maxAssetsCount,
  ) {
    return PickMethod(
      icon: '⏳',
      name: 'CustomFilterOptions',
      description: 'CustomFilterOptions Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            requestType: RequestType.video,
            filterOptions: FilterOptionGroup(
              videoOption: const FilterOption(
                durationConstraint: DurationConstraint(
                  max: Duration(minutes: 1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  factory PickMethod.prependItem(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '➕',
      name: 'PrependItem',
      description: 'PrependItem Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            specialItemPosition: SpecialItemPosition.prepend,
            specialItemBuilder: (
              BuildContext context,
              AssetPathEntity? path,
              int length,
            ) {
              return const Center(
                child: Text('Custom Widget', textAlign: TextAlign.center),
              );
            },
          ),
        );
      },
    );
  }

  factory PickMethod.noPreview(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '👁️‍🗨️',
      name: 'NoPreview',
      description: 'NoPreview Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            specialPickerType: SpecialPickerType.noPreview,
          ),
        );
      },
    );
  }

  factory PickMethod.keepScrollOffset({
    required BuildContext context,
    required DefaultAssetPickerBuilderDelegate Function() delegate,
    required Function(PermissionState state) onPermission,
    GestureLongPressCallback? onLongPress,
  }) {
    return PickMethod(
      icon: '💾',
      name: 'KeepScrollOffset',
      description: 'KeepScrollOffset Description',
      method: (BuildContext context, List<AssetEntity> assets) async {
        final PermissionState ps = await PhotoManager.requestPermissionExtend();
        if (ps != PermissionState.authorized && ps != PermissionState.limited) {
          throw StateError('Permission state error with $ps.');
        }
        onPermission(ps);
        return AssetPicker.pickAssetsWithDelegate(
          context,
          delegate: delegate(),
        );
      },
      onLongPress: onLongPress,
    );
  }

  factory PickMethod.changeLanguages(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '🔤',
      name: 'ChangeLanguages',
      description: 'ChangeLanguages Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            textDelegate: const EnglishAssetPickerTextDelegate(),
          ),
        );
      },
    );
  }

  factory PickMethod.preventGIFPicked(
    BuildContext context,
    int maxAssetsCount,
  ) {
    return PickMethod(
      icon: '🈲',
      name: 'PreventGIFPicked',
      description: 'PreventGIFPicked Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            selectPredicate: (BuildContext c, AssetEntity a, bool isSelected) {
              debugPrint('Asset title: ${a.title}');
              return a.title?.endsWith('.gif') != true;
            },
          ),
        );
      },
    );
  }

  factory PickMethod.customizableTheme(
    BuildContext context,
    int maxAssetsCount,
  ) {
    return PickMethod(
      icon: '🎨',
      name: 'CustomizableTheme',
      description: 'CustomizableTheme Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            pickerTheme: AssetPicker.themeData(
              Colors.lightBlueAccent,
              light: true,
            ),
          ),
        );
      },
    );
  }

  factory PickMethod.pathNameBuilder(BuildContext context, int maxAssetsCount) {
    return PickMethod(
      icon: '🈸',
      name: 'PathNameBuilder',
      description: 'PathNameBuilder Description',
      method: (BuildContext context, List<AssetEntity> assets) {
        return AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            maxAssets: maxAssetsCount,
            selectedAssets: assets,
            pathNameBuilder: (AssetPathEntity path) => '${path.name}🍭',
          ),
        );
      },
    );
  }

  final String icon;
  final String name;
  final String description;

  /// The core function that defines how to use the picker.
  final Future<List<AssetEntity>?> Function(
    BuildContext context,
    List<AssetEntity> selectedAssets,
  ) method;

  final GestureLongPressCallback? onLongPress;
}