"use strict";
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
var NotEnabledError = /** @class */ (function (_super) {
    tslib_1.__extends(NotEnabledError, _super);
    function NotEnabledError() {
        var _this = _super.call(this, 'Function is unavailable as Push has not been enabled. Please call `Push.enable` before calling this function.') || this;
        _this.name = 'NotEnabledError';
        return _this;
    }
    return NotEnabledError;
}(Error));
exports.default = NotEnabledError;
//# sourceMappingURL=NotEnabledError.js.map