"use strict";
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
var PlatformNotSupportedError_1 = tslib_1.__importDefault(require("./PlatformNotSupportedError"));
var PushNotification = /** @class */ (function () {
    function PushNotification() {
        var _this = this;
        /**
         * Configure PushNotification
         * @param {Object} config - PushNotification configuration object
         */
        this.configure = function (_) {
            if (_ === void 0) { _ = {}; }
            throw new PlatformNotSupportedError_1.default();
        };
        /**
         * Get a plugin from added plugins
         * @param {string} providerName - the name of the plugin to get
         */
        this.getPluggable = function (_) {
            throw new PlatformNotSupportedError_1.default();
        };
        /**
         * Add plugin into PushNotification
         * @param {PushNotificationProvider} pluggable - an instance of the plugin
         */
        this.addPluggable = function (_) {
            throw new PlatformNotSupportedError_1.default();
        };
        /**
         * Remove a plugin from added plugins
         * @param {string} providerName - the name of the plugin to remove
         */
        this.removePluggable = function () {
            throw new PlatformNotSupportedError_1.default();
        };
        this.enable = function () {
            throw new PlatformNotSupportedError_1.default();
        };
        this.identifyUser = function () {
            throw new PlatformNotSupportedError_1.default();
        };
        this.getLaunchNotification = function () { return tslib_1.__awaiter(_this, void 0, void 0, function () {
            return tslib_1.__generator(this, function (_a) {
                throw new PlatformNotSupportedError_1.default();
            });
        }); };
        this.getBadgeCount = function () { return tslib_1.__awaiter(_this, void 0, void 0, function () {
            return tslib_1.__generator(this, function (_a) {
                throw new PlatformNotSupportedError_1.default();
            });
        }); };
        this.setBadgeCount = function (_) {
            throw new PlatformNotSupportedError_1.default();
        };
        this.getPermissionStatus = function () { return tslib_1.__awaiter(_this, void 0, void 0, function () {
            return tslib_1.__generator(this, function (_a) {
                throw new PlatformNotSupportedError_1.default();
            });
        }); };
        this.requestPermissions = function (_) { return tslib_1.__awaiter(_this, void 0, void 0, function () {
            return tslib_1.__generator(this, function (_a) {
                throw new PlatformNotSupportedError_1.default();
            });
        }); };
        this.onNotificationReceivedInBackground = function (_) {
            throw new PlatformNotSupportedError_1.default();
        };
        this.onNotificationReceivedInForeground = function (_) {
            throw new PlatformNotSupportedError_1.default();
        };
        this.onTokenReceived = function (_) {
            throw new PlatformNotSupportedError_1.default();
        };
        this.onNotificationOpened = function (_) {
            throw new PlatformNotSupportedError_1.default();
        };
    }
    /**
     * Get the name of this module
     * @returns {string} name of this module
     */
    PushNotification.prototype.getModuleName = function () {
        throw new PlatformNotSupportedError_1.default();
    };
    return PushNotification;
}());
exports.default = PushNotification;
//# sourceMappingURL=PushNotification.js.map