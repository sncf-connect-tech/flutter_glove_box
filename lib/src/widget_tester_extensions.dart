import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'configuration.dart';
import 'device.dart';

/// Convenience extensions on WidgetTester
extension WidgetTesterImageLoadingExtensions on WidgetTester {
  /// Waits for images to decode. Use this to ensure that images are properly displayed
  /// in Goldens. The implementation of this can be configured as part of GoldenToolkitConfiguration
  ///
  /// If you have assets that are not loading with this implementation, please file an issue and we will explore solutions.
  Future<void> waitForAssets() => GoldenToolkit.configuration.primeAssets(this);
}

/// Convenience extensions for more easily configuring WidgetTester for pre-set configurations
extension WidgetFlutterBindingExtensions on TestWidgetsFlutterBinding {
  /// Configure the Test device for the duration of the supplied operation and revert
  ///
  /// [device] the desired configuration to apply
  ///
  /// [body] the closure you wish to be executed with the device configuration applied
  ///
  Future<void> runWithDeviceOverrides(
    Device device, {
    required Future<void> Function() body,
    required TestFlutterView view,
  }) async {
    await applyDeviceOverrides(device, view: view);
    try {
      await body();
    } finally {
      await resetDeviceOverrides(view: view);
    }
  }

  /// Configure the Test device to match the configuration of the supplied device
  ///
  /// Note: these settings will persist across multiple tests in the same file. It is recommended
  /// that you reset upon completion.
  ///
  /// [device] the desired configuration to apply
  ///
  Future<void> applyDeviceOverrides(Device device, {required TestFlutterView view}) async {
    await setSurfaceSize(Size(device.size.width, device.size.height));
    view.physicalSize = device.size * device.devicePixelRatio;
    view.devicePixelRatio = device.devicePixelRatio;
    view.platformDispatcher.textScaleFactorTestValue = device.textScale;
    view.platformDispatcher.platformBrightnessTestValue =
        device.brightness;
    view.safeAreaTestValue = device.safeArea;
  }

  /// Resets any configuration that may be been specified by applyDeviceOverrides
  ///
  /// Only needs to be called if you are concerned about the result of applyDeviceOverrides bleeding over across tests.
  Future<void> resetDeviceOverrides({required TestFlutterView view}) async {
    // there is an untested assumption that clearing these specific values is cheaper than
    // calling binding.window.clearAllTestValues().
    view.resetDevicePixelRatio();
    view.platformDispatcher.clearPlatformBrightnessTestValue();
    view.resetPadding();
    view.platformDispatcher.clearTextScaleFactorTestValue();
    view.resetPhysicalSize();
    await setSurfaceSize(null);
  }
}

/// Convenience extensions for configuring elements of the TestWindow
extension TestFlutterViewExtensions on TestFlutterView {
  /// convenience wrapper for configuring the paddingTestValue
  ///
  /// paddingTestValue requires you creating your own class that implements WindowPadding
  ///
  /// [safeArea] specifies the safe area insets for all 4 edges that you wish to simulate
  ///
  set safeAreaTestValue(EdgeInsets safeArea) {
    padding = FakeViewPadding(
      bottom: safeArea.bottom,
      left: safeArea.left,
      right: safeArea.right,
      top: safeArea.top,
    );
  }
}


