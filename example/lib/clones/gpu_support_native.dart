import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

bool? _isGpuSupportedCache;

/// Native platforms check whether Impeller and Flutter GPU context are available.
bool get isFlutterGpuSupported {
  if (_isGpuSupportedCache != null) return _isGpuSupportedCache!;
  if (kIsWeb || !ui.ImageFilter.isShaderFilterSupported) {
    return _isGpuSupportedCache = false;
  }
  try {
    gpu.gpuContext;
    return _isGpuSupportedCache = true;
  } catch (_) {
    return _isGpuSupportedCache = false;
  }
}
