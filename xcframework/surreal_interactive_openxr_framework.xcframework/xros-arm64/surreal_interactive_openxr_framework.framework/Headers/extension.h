// Copyright Surreal Interactive Inc. All rights reserved.
#ifndef XCFRAMEWORK_EXTENSION_H_
#define XCFRAMEWORK_EXTENSION_H_
#include "openxr.h"

#ifdef __cplusplus
extern "C" {
#endif
XrResult xrRenderDone(XrSession session, XrTime poll_timestamp, XrTime render_finish_timestamp);
#ifdef __cplusplus
}
#endif

#endif  // XCFRAMEWORK_EXTENSION_H_

