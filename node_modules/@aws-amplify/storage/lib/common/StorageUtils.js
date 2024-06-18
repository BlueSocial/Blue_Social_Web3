"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isBlob = exports.isFile = exports.dispatchStorageEvent = exports.byteLength = void 0;
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
var core_1 = require("@aws-amplify/core");
var StorageConstants_1 = require("./StorageConstants");
var byteLength = function (x) {
    if (typeof x === 'string') {
        return x.length;
    }
    else if (isArrayBuffer(x)) {
        return x.byteLength;
    }
    else if ((0, exports.isBlob)(x)) {
        return x.size;
    }
    else {
        throw new Error('Cannot determine byte length of ' + x);
    }
};
exports.byteLength = byteLength;
var dispatchStorageEvent = function (track, event, attrs, metrics, message) {
    if (track) {
        var data = { attrs: attrs };
        if (metrics) {
            data['metrics'] = metrics;
        }
        core_1.Hub.dispatch('storage', {
            event: event,
            data: data,
            message: message,
        }, 'Storage', StorageConstants_1.AMPLIFY_SYMBOL);
    }
};
exports.dispatchStorageEvent = dispatchStorageEvent;
var isFile = function (x) {
    return typeof x !== 'undefined' && x instanceof File;
};
exports.isFile = isFile;
var isBlob = function (x) {
    return typeof x !== 'undefined' && x instanceof Blob;
};
exports.isBlob = isBlob;
var isArrayBuffer = function (x) {
    return typeof x !== 'undefined' && x instanceof ArrayBuffer;
};
