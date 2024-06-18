"use strict";
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
Object.defineProperty(exports, "__esModule", { value: true });
exports.defaultConfig = exports.isDnsCompatibleBucketName = exports.SERVICE_NAME = void 0;
var core_1 = require("@aws-amplify/core");
var aws_client_utils_1 = require("@aws-amplify/core/internals/aws-client-utils");
var utils_1 = require("./utils");
var DOMAIN_PATTERN = /^[a-z0-9][a-z0-9\.\-]{1,61}[a-z0-9]$/;
var IP_ADDRESS_PATTERN = /(\d+\.){3}\d+/;
var DOTS_PATTERN = /\.\./;
/**
 * The service name used to sign requests if the API requires authentication.
 */
exports.SERVICE_NAME = 's3';
/**
 * The endpoint resolver function that returns the endpoint URL for a given region, and input parameters.
 */
var endpointResolver = function (options, apiInput) {
    var region = options.region, useAccelerateEndpoint = options.useAccelerateEndpoint, customEndpoint = options.customEndpoint, forcePathStyle = options.forcePathStyle;
    var endpoint;
    // 1. get base endpoint
    if (customEndpoint) {
        endpoint = new URL(customEndpoint);
    }
    else if (useAccelerateEndpoint) {
        if (forcePathStyle) {
            throw new Error('Path style URLs are not supported with S3 Transfer Acceleration.');
        }
        endpoint = new URL("https://s3-accelerate.".concat((0, aws_client_utils_1.getDnsSuffix)(region)));
    }
    else {
        endpoint = new URL("https://s3.".concat(region, ".").concat((0, aws_client_utils_1.getDnsSuffix)(region)));
    }
    // 2. inject bucket name
    if (apiInput === null || apiInput === void 0 ? void 0 : apiInput.Bucket) {
        if (!(0, exports.isDnsCompatibleBucketName)(apiInput.Bucket)) {
            throw new Error("Invalid bucket name: \"".concat(apiInput.Bucket, "\"."));
        }
        if (forcePathStyle || apiInput.Bucket.includes('.')) {
            endpoint.pathname = "/".concat(apiInput.Bucket);
        }
        else {
            endpoint.host = "".concat(apiInput.Bucket, ".").concat(endpoint.host);
        }
    }
    return { url: endpoint };
};
/**
 * Determines whether a given string is DNS compliant per the rules outlined by
 * S3. Length, capitaization, and leading dot restrictions are enforced by the
 * DOMAIN_PATTERN regular expression.
 * @internal
 *
 * @see https://github.com/aws/aws-sdk-js-v3/blob/f2da6182298d4d6b02e84fb723492c07c27469a8/packages/middleware-bucket-endpoint/src/bucketHostnameUtils.ts#L39-L48
 * @see https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
 */
var isDnsCompatibleBucketName = function (bucketName) {
    return DOMAIN_PATTERN.test(bucketName) &&
        !IP_ADDRESS_PATTERN.test(bucketName) &&
        !DOTS_PATTERN.test(bucketName);
};
exports.isDnsCompatibleBucketName = isDnsCompatibleBucketName;
/**
 * @internal
 */
exports.defaultConfig = {
    service: exports.SERVICE_NAME,
    endpointResolver: endpointResolver,
    retryDecider: (0, aws_client_utils_1.getRetryDecider)(utils_1.parseXmlError),
    computeDelay: aws_client_utils_1.jitteredBackoff,
    userAgentValue: (0, core_1.getAmplifyUserAgent)(),
    useAccelerateEndpoint: false,
    uriEscapePath: false, // Required by S3. See https://github.com/aws/aws-sdk-js-v3/blob/9ba012dfa3a3429aa2db0f90b3b0b3a7a31f9bc3/packages/signature-v4/src/SignatureV4.ts#L76-L83
};
