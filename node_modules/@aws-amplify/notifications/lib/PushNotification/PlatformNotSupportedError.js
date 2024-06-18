"use strict";
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
var PlatformNotSupportedError = /** @class */ (function (_super) {
    tslib_1.__extends(PlatformNotSupportedError, _super);
    function PlatformNotSupportedError() {
        var _this = _super.call(this, 'Function not supported on current platform') || this;
        _this.name = 'PlatformNotSupportedError';
        return _this;
    }
    return PlatformNotSupportedError;
}(Error));
exports.default = PlatformNotSupportedError;
//# sourceMappingURL=PlatformNotSupportedError.js.map