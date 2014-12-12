
function wbHTMLToNative(command, params, callback) {
    var message={"command":command,"params":params,"callback":callback};
    var isiOS=navigator.userAgent.match('iPad')
    || navigator.userAgent.match('iPhone')
    || navigator.userAgent.match('iPod');
    var isAndroid=navigator.userAgent.match('Android');
    var isDesktop=(!isiOS && !isAndroid);
    if (isiOS) {
        window.webkit.messageHandlers.webridge.postMessage({body:message});
    }
    else if (isAndroid) {
        // TODO: android
    }
    else if (isDesktop) {
        // TODO: desktop
    }
}
