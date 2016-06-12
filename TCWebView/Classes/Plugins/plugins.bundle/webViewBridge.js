/**
 * bridgeProxy是webview插件的代理对象
 * 通过该类调用对应的插件
 */
(function(window){
	// 防止重复定义RuahoWebViewJSBridge
	if (window.RuahoWebViewJSBridge) {
		return;
	}
	
	var _callback_count = 1000, // 回调函数ID
		_callback_map = {}; // 回调函数map
	
	// 调用插件
	var __call = function(plugin, func, arguments, callback) {
		if (!plugin || typeof plugin !== "string") {
			logger.debug("插件名必须提供");
			return;
		}
		
        if (!func || typeof func !== "string") {
			logger.debug("调用的插件方法名必须提供");
            return;
        }
		
        if (!arguments) {
        	arguments = [];
        }
 
        if (typeof arguments !== "array") {
            arguments = [arguments];
        }

		var callbackID;
        if (typeof callback === "function") {
			callbackID = (_callback_count++).toString();
          	_callback_map[callbackID] = callback;
        }

		var result;
		if (callbackID) {
			result = this.pluginProxy.execute(plugin, func, arguments, callbackID);
		} else {
			result = this.pluginProxy.execute(plugin, func, arguments);
		}
		
		if (result) {
			return result;
		} 
	};
	
	// 插件回调
	var __callback = function() {
		var args = Array.prototype.slice.call(arguments);
		var callbackID = args[0];
		var callback = _callback_map[callbackID];
		if (callback) {
			if (args.length >= 2) {
				callback(args[1]);
			} else {
				callback();
			}
			delete _callback_map[callbackID];
		}
	};
	
    var __WebViewJSBridge = {
        pluginProxy: __PLUGIN_PROXY__, // 原生代码写入的对象
		invoke: __call,
		call: __call,
		callback: __callback,
      	on: function(){}
    };
 
    // 日志
    window.logger = {
        debug : function(msg) {
            __WebViewJSBridge.call("TCLogger", "debug", msg);
        }
    };

    window.$R = window.RuahoWebViewJSBridge = __WebViewJSBridge;
})(window);


