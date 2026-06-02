#pragma once

#include <flutter/engine_method_result.h>
#include <flutter/flutter_engine.h>

// Registers all Roola MethodChannel handlers with the Flutter engine.
void SetupRoolaChannels(flutter::FlutterEngine* engine);
