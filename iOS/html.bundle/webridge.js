/*!
 * Webridge Javascript Library
 * yizelin - v0.0.2 (2014-12-24T17:30:00+0800)
 * https://github.com/linyize/Webridge
 */

function Webridge () {
    
    // 私有变量
    var isiOS = navigator.userAgent.match('iPad')
                || navigator.userAgent.match('iPhone')
                || navigator.userAgent.match('iPod');
    var isAndroid = navigator.userAgent.match('Android');
    var sequence = 0;
    var callbackArray = new Array();
    
    // 私有方法
    
    /**
     * 回调函数(原生代码调用js函数)
     * @method nativeToJSCallback
     * @param {int}    nativeSequence   调用的序号，用于找到对应的原生调用
     * @param {object} result           js函数返回的json对象
     *
     */
    var nativeToJSCallback = function(nativeSequence, result) {
        
        var message = {"return":{"sequence":nativeSequence, "result":result} };
        
        if (isiOS) {
            window.webkit.messageHandlers.webridge.postMessage(message);
        }
        else if (isAndroid) {
            window.androidWebridge.returnMessage(JSON.stringify(message));
        }
    };
    

    // 公有方法
    
    /**
     * 原生代码调用js函数，并获得返回值
     * @method nativeToJS
     * @param {string} jsCommand       要调用的js函数名
     * @param {object} jsParams        传递给js函数的参数，json对象
     * @param {int}    nativeSequence  调用的序号，用于找到对应的原生回调block
     *
     *
     * js函数约定：请查阅 https://github.com/linyize/Webridge/blob/master/README.md
     */
    this.nativeToJS = function(jsCommand, jsParams, nativeSequence) {
        try {
            // 先调用异步方式
            var jsCommandAsync = jsCommand + '_async';
            var jsCommandAsyncFunction = eval(jsCommandAsync);
            if (typeof(jsCommandAsyncFunction) == 'function') {
                jsCommandAsyncFunction(jsParams, function(result) {
                                            nativeToJSCallback(nativeSequence, result);
                                       });
            }
            else
            {
                throw 'wrong type';
            }
        } catch (e) {
            // 调用异步方式失败时，再采用同步方式
            var jsCommandFunction = eval(jsCommand);
            if (typeof(jsCommandFunction) == 'function') {
                var result = jsCommandFunction(jsParams);
                nativeToJSCallback(nativeSequence, result);
            }
            else
            {
                throw 'wrong type';
            }
        }
    };
    
    /**
     * js函数调用原生代码，并获得返回值
     * @method jsToNative
     * @param {string} command      要调用的原生代码函数名
     * @param {object} params       传递给原生代码的参数，json对象
     * @param {function} jsCallback   js回调函数 function(result, error)，用于得到返回值
     *
     *
     * 原生函数约定： 请查阅 https://github.com/linyize/Webridge/blob/master/README.md
     *
     * js回调函数约定:    function(result, error)
     * 1、 {object} result  原生代码返回的json对象
     *     {string} error   错误信息字符串
     * 2、无返回值
     */
    this.jsToNative = function(command, params, jsCallback/* function(result, error) */) {
        var message = {"eval":{"command":command, "params":params} };
        
        if (typeof(jsCallback) == 'function') {
            sequence += 1;
            callbackArray[sequence] = jsCallback;
            message["eval"]["sequence"] = sequence;
        }

        if (isiOS) {
            window.webkit.messageHandlers.webridge.postMessage(message);
        }
        else if (isAndroid) {
            window.androidWebridge.postMessage(JSON.stringify(message));
        }
    };
    
    /**
     * 回调函数(js函数调用原生代码)
     * @method jsToNativeCallback
     * @param {int}    jsSequence   调用的序号，用于找到对应的js回调函数
     * @param {object} result       原生代码返回的json对象
     * @param {string} error        错误信息字符串
     *
     *
     * js回调函数约定:     function(result, error)
     * 1、 {object} result  原生代码返回的json对象
     *     {string} error   错误信息字符串
     * 2、无返回值
     */
    this.jsToNativeCallback = function(jsSequence, result, error) {
        var jsCallback = callbackArray[jsSequence];
        jsCallback(result, error);
        delete callbackArray[jsSequence];
    };
    
}

// 全局对象 webridge
var webridge = new Webridge();
