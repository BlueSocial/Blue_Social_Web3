"use strict";
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
Object.defineProperty(exports, "__esModule", { value: true });
exports.s3TransferHandler = void 0;
var aws_client_utils_1 = require("@aws-amplify/core/internals/aws-client-utils");
var composers_1 = require("@aws-amplify/core/internals/aws-client-utils/composers");
var contentSha256middleware_1 = require("../contentSha256middleware");
/**
 * S3 transfer handler for node based on Node-fetch. On top of basic transfer handler, it also supports
 * x-amz-content-sha256 header. However, it does not support request&response process tracking like browser.
 *
 * @internal
 */
exports.s3TransferHandler = (0, composers_1.composeTransferHandler)(aws_client_utils_1.authenticatedHandler, [contentSha256middleware_1.contentSha256Middleware]);
