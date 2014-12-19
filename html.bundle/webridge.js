/*!
 * Webridge Javascript Library
 * yizelin - v0.0.1 (2014-12-19T09:20:00+0800)
 * https://github.com/linyize/Webridge
 */

/**
 * 原生代码调用js函数，并获得返回值
 * @method wbNativeToJS
 * @param {string} jsCommand 要调用的js函数名
 * @param {object} jsParams  传递给js函数的参数，json对象
 * @return {object} 返回json对象
 *
 *
 * js函数约定：
 * 1、只有一个参数，参数格式为json对象；
 * 2、返回一个json对象
 */
function wbNativeToJS(jsCommand, jsParams) {
    var jsParamsString = JSON.stringify(jsParams);
    var jsScript = jsCommand + '(' + jsParamsString + ')';
    var result = eval(jsScript);
    var isAndroid = navigator.userAgent.match('Android');
    if (isAndroid) {
        window.androidWebridge.returnMessage(JSON.stringify(result));
    }
    else {
        // iOS or other platform
        return result;
    }
}

/**
 * js函数调用原生代码，并获得返回值
 * @method wbJSToNative
 * @param {string} command      要调用的原生代码函数名
 * @param {object} params       传递给原生代码的参数，json对象
 * @param {string} jsCallback   js回调函数名，用于得到返回值
 *
 *
 * 原生代码函数格式约定：
 * 1、只有一个参数，参数格式为json对象
 * 2、返回一个json对象
 *
 * js回调函数格式约定: 
 * 1、只有一个参数，参数格式为 {'result':原生代码返回的json对象,'error':错误信息字符串}
 */
function wbJSToNative(command, params, jsCallback) {
    var message = {"command":command,"params":params,"callback":jsCallback};
    var isiOS = navigator.userAgent.match('iPad')
    || navigator.userAgent.match('iPhone')
    || navigator.userAgent.match('iPod');
    var isAndroid = navigator.userAgent.match('Android');
    var isDesktop = (!isiOS && !isAndroid);
    if (isiOS) {
        window.webkit.messageHandlers.webridge.postMessage({body:message});
    }
    else if (isAndroid) {
        window.androidWebridge.postMessage(JSON.stringify(message));
    }
    else if (isDesktop) {
        // TODO: desktop
    }
}
