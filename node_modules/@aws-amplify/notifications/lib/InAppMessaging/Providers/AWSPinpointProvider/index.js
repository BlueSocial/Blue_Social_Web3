"use strict";
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
var pinpoint_1 = require("@aws-amplify/core/internals/aws-clients/pinpoint");
var common_1 = require("../../../common");
var SessionTracker_1 = tslib_1.__importDefault(require("../../SessionTracker"));
var types_1 = require("../../types");
var types_2 = require("./types");
var utils_1 = require("./utils");
var MESSAGE_DAILY_COUNT_KEY = 'pinpointProvider_inAppMessages_dailyCount';
var MESSAGE_TOTAL_COUNT_KEY = 'pinpointProvider_inAppMessages_totalCount';
var AWSPinpointProvider = /** @class */ (function (_super) {
    tslib_1.__extends(AWSPinpointProvider, _super);
    function AWSPinpointProvider() {
        var _this = _super.call(this, utils_1.logger) || this;
        _this.configured = false;
        _this.configure = function (config) {
            if (config === void 0) { config = {}; }
            _this.config = tslib_1.__assign(tslib_1.__assign({}, _super.prototype.configure.call(_this, config)), { endpointInfo: { channelType: 'IN_APP' } });
            // some configuration steps should not be re-run even if provider is re-configured for some reason
            if (!_this.configured) {
                _this.sessionTracker = new SessionTracker_1.default(_this.sessionStateChangeHandler);
                _this.sessionTracker.start();
                // wire up default Pinpoint message event handling
                common_1.addEventListener(types_1.InAppMessageInteractionEvent.MESSAGE_DISPLAYED, function (message) {
                    _this.recordMessageEvent(message, types_2.AWSPinpointMessageEvent.MESSAGE_DISPLAYED);
                });
                common_1.addEventListener(types_1.InAppMessageInteractionEvent.MESSAGE_DISMISSED, function (message) {
                    _this.recordMessageEvent(message, types_2.AWSPinpointMessageEvent.MESSAGE_DISMISSED);
                });
                common_1.addEventListener(types_1.InAppMessageInteractionEvent.MESSAGE_ACTION_TAKEN, function (message) {
                    _this.recordMessageEvent(message, types_2.AWSPinpointMessageEvent.MESSAGE_ACTION_TAKEN);
                });
            }
            _this.configured = true;
            utils_1.dispatchInAppMessagingEvent('pinpointProvider_configured', null);
            return _this.config;
        };
        _this.getInAppMessages = function () { return tslib_1.__awaiter(_this, void 0, void 0, function () {
            var _a, appId, credentials, endpointId, region, input, response, messages, err_1;
            return tslib_1.__generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        if (!!this.initialized) return [3 /*break*/, 2];
                        return [4 /*yield*/, this.init()];
                    case 1:
                        _b.sent();
                        _b.label = 2;
                    case 2:
                        // There is no way to granuarly reconcile the filter memoization as the keys are composited from a message id and
                        // event properties thus opting to just clear them out when getting messages rather than leave potentially
                        // obsolete entries that will no longer serve any purpose.
                        utils_1.clearMemo();
                        _b.label = 3;
                    case 3:
                        _b.trys.push([3, 6, , 7]);
                        return [4 /*yield*/, this.updateEndpoint()];
                    case 4:
                        _b.sent();
                        _a = this.config, appId = _a.appId, credentials = _a.credentials, endpointId = _a.endpointId, region = _a.region;
                        input = {
                            ApplicationId: appId,
                            EndpointId: endpointId,
                        };
                        this.logger.debug('getting in-app messages');
                        return [4 /*yield*/, pinpoint_1.getInAppMessages({ credentials: credentials, region: region }, input)];
                    case 5:
                        response = _b.sent();
                        messages = response.InAppMessagesResponse.InAppMessageCampaigns;
                        utils_1.dispatchInAppMessagingEvent('getInAppMessages', messages);
                        return [2 /*return*/, messages];
                    case 6:
                        err_1 = _b.sent();
                        this.logger.error('Error getting in-app messages', err_1);
                        throw err_1;
                    case 7: return [2 /*return*/];
                }
            });
        }); };
        _this.processInAppMessages = function (messages, event) { return tslib_1.__awaiter(_this, void 0, void 0, function () {
            var highestPrioritySeen;
            var _this = this;
            return tslib_1.__generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!!this.initialized) return [3 /*break*/, 2];
                        return [4 /*yield*/, this.init()];
                    case 1:
                        _a.sent();
                        _a.label = 2;
                    case 2: return [2 /*return*/, this.normalizeMessages(messages.reduce(function (acc, message) {
                            var messageQualifies = utils_1.matchesEventType(message, event) &&
                                utils_1.matchesAttributes(message, event) &&
                                utils_1.matchesMetrics(message, event) &&
                                utils_1.isBeforeEndDate(message) &&
                                _this.isBelowCap(message);
                            // filter all qualifying messages returning only those that are of (relative) highest priority
                            if (messageQualifies) {
                                // have not yet encountered message with priority
                                if (!highestPrioritySeen) {
                                    // this message has priority, so reset the accumulator with this message only
                                    if (message.Priority) {
                                        highestPrioritySeen = message.Priority;
                                        return [message];
                                    }
                                    else {
                                        // this message also has no priority, so just add this message to accumulator
                                        acc.push(message);
                                    }
                                    // have previously encountered message with priority, so only messages with priority matter now
                                }
                                else if (message.Priority) {
                                    // this message has higher priority (lower number), so reset the accumulator with this message only
                                    if (message.Priority < highestPrioritySeen) {
                                        highestPrioritySeen = message.Priority;
                                        return [message];
                                        // this message has the same priority, so just add this message to accumulator
                                    }
                                    else if (message.Priority === highestPrioritySeen) {
                                        acc.push(message);
                                    }
                                }
                            }
                            return acc;
                        }, []))];
                }
            });
        }); };
        _this.sessionStateChangeHandler = function (state) {
            if (state === 'started') {
                // reset all session counts
                _this.sessionMessageCountMap = {};
            }
        };
        _this.isBelowCap = function (_a) {
            var CampaignId = _a.CampaignId, SessionCap = _a.SessionCap, DailyCap = _a.DailyCap, TotalCap = _a.TotalCap;
            var _b = _this.getMessageCounts(CampaignId), sessionCount = _b.sessionCount, dailyCount = _b.dailyCount, totalCount = _b.totalCount;
            return ((!SessionCap || sessionCount < SessionCap) &&
                (!DailyCap || dailyCount < DailyCap) &&
                (!TotalCap || totalCount < TotalCap));
        };
        // Use the current session count in memory or initialize as empty count
        _this.getSessionCount = function (messageId) {
            return _this.sessionMessageCountMap[messageId] || 0;
        };
        _this.getDailyCount = function () {
            var storage = _this.config.storage;
            var today = utils_1.getStartOfDay();
            var item = storage.getItem(MESSAGE_DAILY_COUNT_KEY);
            // Parse stored count or initialize as empty count
            var counter = item
                ? JSON.parse(item)
                : { count: 0, lastCountTimestamp: today };
            // If the stored counter timestamp is today, use it as the count, otherwise reset to 0
            return counter.lastCountTimestamp === today ? counter.count : 0;
        };
        _this.getTotalCountMap = function () {
            var storage = _this.config.storage;
            var item = storage.getItem(MESSAGE_TOTAL_COUNT_KEY);
            // Parse stored count map or initialize as empty
            return item ? JSON.parse(item) : {};
        };
        _this.getTotalCount = function (messageId) {
            var countMap = _this.getTotalCountMap();
            // Return stored count or initialize as empty count
            return countMap[messageId] || 0;
        };
        _this.getMessageCounts = function (messageId) {
            try {
                return {
                    sessionCount: _this.getSessionCount(messageId),
                    dailyCount: _this.getDailyCount(),
                    totalCount: _this.getTotalCount(messageId),
                };
            }
            catch (err) {
                _this.logger.error('Failed to get message counts from storage', err);
            }
        };
        _this.setSessionCount = function (messageId, count) {
            _this.sessionMessageCountMap[messageId] = count;
        };
        _this.setDailyCount = function (count) {
            var storage = _this.config.storage;
            var dailyCount = {
                count: count,
                lastCountTimestamp: utils_1.getStartOfDay(),
            };
            try {
                storage.setItem(MESSAGE_DAILY_COUNT_KEY, JSON.stringify(dailyCount));
            }
            catch (err) {
                _this.logger.error('Failed to save daily message count to storage', err);
            }
        };
        _this.setTotalCountMap = function (countMap) {
            var storage = _this.config.storage;
            try {
                storage.setItem(MESSAGE_TOTAL_COUNT_KEY, JSON.stringify(countMap));
            }
            catch (err) {
                _this.logger.error('Failed to save total count to storage', err);
            }
        };
        _this.setTotalCount = function (messageId, count) {
            var _a;
            var updatedMap = tslib_1.__assign(tslib_1.__assign({}, _this.getTotalCountMap()), (_a = {}, _a[messageId] = count, _a));
            _this.setTotalCountMap(updatedMap);
        };
        _this.incrementCounts = function (messageId) { return tslib_1.__awaiter(_this, void 0, void 0, function () {
            var _a, sessionCount, dailyCount, totalCount;
            return tslib_1.__generator(this, function (_b) {
                _a = this.getMessageCounts(messageId), sessionCount = _a.sessionCount, dailyCount = _a.dailyCount, totalCount = _a.totalCount;
                this.setSessionCount(messageId, sessionCount + 1);
                this.setDailyCount(dailyCount + 1);
                this.setTotalCount(messageId, totalCount + 1);
                return [2 /*return*/];
            });
        }); };
        _this.normalizeMessages = function (messages) {
            return messages.map(function (message) {
                var CampaignId = message.CampaignId, InAppMessage = message.InAppMessage;
                return {
                    id: CampaignId,
                    content: utils_1.extractContent(message),
                    layout: utils_1.interpretLayout(InAppMessage.Layout),
                    metadata: utils_1.extractMetadata(message),
                };
            });
        };
        _this.recordMessageEvent = function (message, event) { return tslib_1.__awaiter(_this, void 0, void 0, function () {
            return tslib_1.__generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!!this.initialized) return [3 /*break*/, 2];
                        return [4 /*yield*/, this.init()];
                    case 1:
                        _a.sent();
                        _a.label = 2;
                    case 2:
                        utils_1.recordAnalyticsEvent(event, message);
                        if (!(event === types_2.AWSPinpointMessageEvent.MESSAGE_DISPLAYED)) return [3 /*break*/, 4];
                        return [4 /*yield*/, this.incrementCounts(message.id)];
                    case 3:
                        _a.sent();
                        _a.label = 4;
                    case 4: return [2 /*return*/];
                }
            });
        }); };
        _this.sessionMessageCountMap = {};
        return _this;
    }
    /**
     * get the sub-category of the plugin
     */
    AWSPinpointProvider.prototype.getSubCategory = function () {
        return AWSPinpointProvider.subCategory;
    };
    AWSPinpointProvider.subCategory = 'InAppMessaging';
    return AWSPinpointProvider;
}(common_1.AWSPinpointProviderCommon));
exports.default = AWSPinpointProvider;
//# sourceMappingURL=index.js.map