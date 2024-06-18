"use strict";
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
var lodash_1 = require("lodash");
var types_1 = require("./types");
var DEEP_LINK_ACTION = 'deeplink';
var URL_ACTION = 'url';
exports.normalizeNativePermissionStatus = function (nativeStatus) {
    switch (nativeStatus) {
        case 'ShouldRequest':
            return types_1.PushNotificationPermissionStatus.SHOULD_REQUEST;
        case 'NotDetermined':
        case 'ShouldExplainThenRequest':
            return types_1.PushNotificationPermissionStatus.SHOULD_EXPLAIN_THEN_REQUEST;
        case 'Authorized':
        case 'Granted':
            return types_1.PushNotificationPermissionStatus.GRANTED;
        case 'Denied':
            return types_1.PushNotificationPermissionStatus.DENIED;
    }
};
exports.normalizeNativeMessage = function (nativeMessage) {
    var normalized;
    if (nativeMessage === null || nativeMessage === void 0 ? void 0 : nativeMessage.aps) {
        normalized = normalizeApnsMessage(nativeMessage);
    }
    if (nativeMessage === null || nativeMessage === void 0 ? void 0 : nativeMessage.rawData) {
        normalized = normalizeFcmMessage(nativeMessage);
    }
    if (!normalized) {
        return null;
    }
    var body = normalized.body, imageUrl = normalized.imageUrl, title = normalized.title, action = normalized.action, options = normalized.options, data = normalized.data;
    return tslib_1.__assign(tslib_1.__assign(tslib_1.__assign(tslib_1.__assign(tslib_1.__assign(tslib_1.__assign({}, (body && { body: body })), (imageUrl && { imageUrl: imageUrl })), (title && { title: title })), action), options), (!lodash_1.isEmpty(data) && { data: data }));
};
var normalizeApnsMessage = function (apnsMessage) {
    var _a, _b;
    var aps = apnsMessage.aps, _c = apnsMessage.data, data = _c === void 0 ? {} : _c;
    var _d = (_a = aps.alert) !== null && _a !== void 0 ? _a : {}, body = _d.body, title = _d.title;
    var action = (_b = getApnsAction(data.pinpoint)) !== null && _b !== void 0 ? _b : {};
    var imageUrl = data['media-url'];
    var options = getApnsOptions(apnsMessage);
    return { body: body, imageUrl: imageUrl, title: title, action: action, options: options, data: data };
};
var normalizeFcmMessage = function (fcmMessage) {
    var _a;
    var body = fcmMessage.body, imageUrl = fcmMessage.imageUrl, data = fcmMessage.rawData, title = fcmMessage.title;
    var action = (_a = getFcmAction(fcmMessage.action)) !== null && _a !== void 0 ? _a : {};
    var options = getFcmOptions(fcmMessage);
    return { body: body, imageUrl: imageUrl, title: title, action: action, options: options, data: data };
};
var getApnsAction = function (action) {
    if (action === void 0) { action = {}; }
    if (action[DEEP_LINK_ACTION]) {
        return { deeplinkUrl: action[DEEP_LINK_ACTION] };
    }
};
var getFcmAction = function (action) {
    if (action === void 0) { action = {}; }
    if (action[URL_ACTION]) {
        return { goToUrl: action[URL_ACTION] };
    }
    if (action[DEEP_LINK_ACTION]) {
        return { deeplinkUrl: action[DEEP_LINK_ACTION] };
    }
};
var getApnsOptions = function (_a) {
    var aps = _a.aps;
    var _b;
    var subtitle = ((_b = aps.alert) !== null && _b !== void 0 ? _b : {}).subtitle;
    var apnsOptions = tslib_1.__assign({}, (subtitle && { subtitle: subtitle }));
    return tslib_1.__assign({}, (!lodash_1.isEmpty(apnsOptions) && { apnsOptions: apnsOptions }));
};
var getFcmOptions = function (_a) {
    var channelId = _a.channelId, messageId = _a.messageId, senderId = _a.senderId, sendTime = _a.sendTime;
    var fcmOptions = tslib_1.__assign(tslib_1.__assign(tslib_1.__assign(tslib_1.__assign({}, (channelId && { channelId: channelId })), (messageId && { messageId: messageId })), (senderId && { senderId: senderId })), (sendTime && { sendTime: new Date(sendTime) }));
    return tslib_1.__assign({}, (!lodash_1.isEmpty(fcmOptions) && { fcmOptions: fcmOptions }));
};
//# sourceMappingURL=utils.js.map