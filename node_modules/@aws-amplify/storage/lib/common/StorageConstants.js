"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UPLOADS_STORAGE_KEY = exports.localTestingStorageEndpoint = exports.AMPLIFY_SYMBOL = void 0;
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
exports.AMPLIFY_SYMBOL = (typeof Symbol !== 'undefined' && typeof Symbol.for === 'function'
    ? Symbol.for('amplify_default')
    : '@@amplify_default');
exports.localTestingStorageEndpoint = 'http://localhost:20005';
exports.UPLOADS_STORAGE_KEY = '__uploadInProgress';
