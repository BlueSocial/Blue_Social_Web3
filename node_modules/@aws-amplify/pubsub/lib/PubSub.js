"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var tslib_1 = require("tslib");
var core_1 = require("@aws-amplify/core");
var internals_1 = require("./internals");
var PubSubClass = /** @class */ (function (_super) {
    tslib_1.__extends(PubSubClass, _super);
    function PubSubClass() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    PubSubClass.prototype.getModuleName = function () {
        return 'PubSub';
    };
    PubSubClass.prototype.subscribe = function (topics, options) {
        return _super.prototype.subscribe.call(this, topics, options);
    };
    return PubSubClass;
}(internals_1.InternalPubSubClass));
exports.PubSubClass = PubSubClass;
exports.PubSub = new PubSubClass();
core_1.Amplify.register(exports.PubSub);
//# sourceMappingURL=PubSub.js.map