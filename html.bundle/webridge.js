
function wbNativeToHTML(jsCommand, jsParams) {
    var jsParamsString = JSON.stringify(jsParams);
    var jsScript = jsCommand + '(' + jsParamsString + ')';
    var result = eval(jsScript);
    var isAndroid = navigator.userAgent.match('Android');
    if (isAndroid) {
        window.androidWebridge.postMessage(JSON.stringify(result));
    }
    else {
        // iOS or other platform
        return result;
    }
}

function wbHTMLToNative(command, params, callback) {
    var message = {"command":command,"params":params,"callback":callback};
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
