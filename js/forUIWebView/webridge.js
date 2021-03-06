/*!
 * Webridge Javascript Library
 * yizelin - v0.0.4 (2015-5-14T16:50:00+0800)
 * https://github.com/linyize/Webridge
 */

var isWKWebView = false;

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
            if (isWKWebView) {
                window.webkit.messageHandlers.webridge.postMessage(message);
            }
            else {
                postMessage_UIWebView(message);
            }
        }
        else if (isAndroid) {
            window.androidWebridge.returnMessage(JSON.stringify(message));
        }
    };
    
    var postMessage_UIWebView = function(message) {
        var url = "webridge://" + encodeURIComponent(JSON.stringify(message));
        fireIFrame(url);
    };
    
    var fireIFrame = function(url) {
        var iframe = document.createElement("IFRAME");
        iframe.setAttribute("src", url);
        iframe.setAttribute("style","position:absolute; top:0; left:0; width:0; height:0; border:none; margin:0");
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
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
                throw jsCommandAsync + ' is a ' + typeof(jsCommandAsyncFunction) + ', not a function!';
            }
        } catch (e) {
            // 调用异步方式失败时，再采用同步方式
            var jsCommandFunction = eval(jsCommand);
            if (typeof(jsCommandFunction) == 'function') {
                var result = jsCommandFunction(jsParams);
                nativeToJSCallback(nativeSequence, result);
            }
            else if (typeof(jsCommandFunction) == 'string') {
                var result = jsCommandFunction;
                nativeToJSCallback(nativeSequence, result);
            }
            else if (typeof(jsCommandFunction) == 'int') {
                var result = jsCommandFunction;
                nativeToJSCallback(nativeSequence, result);
            }
            else
            {
                throw e;
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
            if (isWKWebView) {
                window.webkit.messageHandlers.webridge.postMessage(message);
            }
            else {
                postMessage_UIWebView(message);
            }
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

// 当dom加载完毕时，通知WebridgeDelegate
document.addEventListener("DOMContentLoaded",function(){
                          webridge.jsToNative("domReady", null, null);},
                          false);
