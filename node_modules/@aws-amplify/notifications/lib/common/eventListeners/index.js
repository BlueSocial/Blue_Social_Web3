"use strict";
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
var eventListeners = {};
exports.notifyEventListeners = function (type) {
    var args = [];
    for (var _i = 1; _i < arguments.length; _i++) {
        args[_i - 1] = arguments[_i];
    }
    var _a;
    (_a = eventListeners[type]) === null || _a === void 0 ? void 0 : _a.forEach(function (listener) {
        listener.handleEvent.apply(listener, tslib_1.__spread(args));
    });
};
exports.notifyEventListenersAndAwaitHandlers = function (type) {
    var args = [];
    for (var _i = 1; _i < arguments.length; _i++) {
        args[_i - 1] = arguments[_i];
    }
    var _a;
    return Promise.all(Array.from((_a = eventListeners[type]) !== null && _a !== void 0 ? _a : []).map(function (listener) { return tslib_1.__awaiter(void 0, void 0, void 0, function () {
        var err_1;
        return tslib_1.__generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    _a.trys.push([0, 2, , 3]);
                    return [4 /*yield*/, listener.handleEvent.apply(listener, tslib_1.__spread(args))];
                case 1:
                    _a.sent();
                    return [3 /*break*/, 3];
                case 2:
                    err_1 = _a.sent();
                    throw err_1;
                case 3: return [2 /*return*/];
            }
        });
    }); }));
};
exports.addEventListener = function (type, handler) {
    // If there is no listener set for the event type, just create it
    if (!eventListeners[type]) {
        eventListeners[type] = new Set();
    }
    var listener = {
        handleEvent: handler,
        remove: function () {
            eventListeners[type].delete(listener);
        },
    };
    eventListeners[type].add(listener);
    return listener;
};
//# sourceMappingURL=index.js.map