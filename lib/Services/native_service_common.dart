import 'native_service_stub.dart'
    if (dart.library.ffi) 'native_service_ffi.dart'
    if (dart.library.html) 'native_service_web.dart'
    if (dart.library.js_interop) 'native_service_web.dart';

export 'native_service_stub.dart'
    if (dart.library.ffi) 'native_service_ffi.dart'
    if (dart.library.html) 'native_service_web.dart'
    if (dart.library.js_interop) 'native_service_web.dart';
