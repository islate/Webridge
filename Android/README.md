Webridge Android

1、介绍

Webridge开源项目为混合式App(Native + Web)开发提供两个核心机制: WBURI + WBWebBridge

WBURI 
一种统一资源描述符，包含格式约定和分发机制。通过实现WebUriListener进行功能扩展。
网页中用WBURI形式的超链接可访问各种原生功能(资源)。

WBWebBridge
原生代码与网页JS之间互相调用的一种机制，约定了互相调用的格式。通过设置WebBridgeDelegate实现功能扩展。

1.1 WBURI基本格式

原始格式
[scheme]://[command]/[param1]/[param2]/[param3]

兼容HTTP格式
http://[host]/[scheme]/[command]/[param1]/[param2]/[param3]

分为scheme、command、params三部分，这三部分都可以由外部自定义。

scheme 方案
command 命令
params 参数

WBURI要符合URL的编码规则。

1.2 WBWebBridge调用机制

1.2.1 原生代码调用网页内的js函数，并获得返回值。

可调用的js函数格式约定:
同步返回
参数个数：一个
参数类型：{object}
返回值：  {object} 或 void

异步返回
方法名: 带有_async后缀
参数个数: 两个
参数1类型: {object}
参数2类型: {function}    function (result)  result 返回值 {object}类型
返回值:   void

1.2.2 网页内的js函数调用原生代码，传递方法名、参数、回调函数。通过回调函数获得返回值。

可调用的原生方法约定：
同步返回
参数个数：一个
参数类型：{object}
返回值：  {object} 或 void

异步返回
参数个数：两个
参数1类型：{object}
参数2类型：AsynExecuteCommandListener
返回值：   void

回调js函数格式约定：
参数个数：两个
参数1类型：{object}  result  原生方法的返回值,json对象
参数2类型：{string}  error   错误信息字符串象
返回值：  void

2、支持环境

android2.3.3以上

3、适合场景

混合式App(Native + Web)开发

4、Usage

4.1 Android使用WBURI

a. 实现WebUriListener
WebUriListener listener = new WebUriImplement();
WebUri uri = new WBUri(mContext, new WebUriImplement(mContext));


b. 实现WebUriListener， 以article command为例
public class WebUriImplement implements WebUriListener {
    private Context mContext;

    public WebUriImplement(Context context) {
        mContext = context;
    }

    @Override
    public String scheme() {
        return "slate";
    }

    public void articleCommand(String command, String params,
        ArrayList<String> paramsList) {
        // TODO 收到打开文章uri
    }

}

c. webview设置setWebViewClient
setWebViewClient(new WebViewClient() {

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        mWbUri.openURI(url);
    return true;
    }

});


网页中可以用超链接方式，引入WBURI
<a href="slate://article/1/2/3/4">view article</a>

或者用js打开WBURI
window.location.href = "slate://article/1/2/3/4";

或者用一个看不见的iframe加载WBURI
var uri = "slate://article/1/2/3/4";
var iframe = document.createElement("IFRAME");
iframe.setAttribute("src", uri);
iframe.setAttribute("style","position:absolute; top:0; left:0; width:0; height:0; border:none; margin:0");
document.documentElement.appendChild(iframe);
iframe.parentNode.removeChild(iframe);
iframe = null;

4.2 Android使用WBWebridge

WBWebridge和WBWebView要结合起来一起使用。

a. 实现WBWebridgeListener
@implementation WebridgeDelegate
public void nativeGetPhoneContacts(Object parmas, AsynExecuteCommandListener listener) {
    //TODO 得到结果后通过listener回调
}

b. 创建webView
layout中 <com.zq.webridge.util.WBWebView/>

4.2.1 js调用原生代码，并异步得到返回值

webridge.jsToNative('nativeCommand', {'param':'value'}, function (result, error) {
if (error.length > 0) {
// 有错误，显示错误信息
}
else {
// 没有错误，得到结果 result
}
});

4.2.2 Android调用js函数，并异步得到返回值
webview.getWebridge().nativeToJs("jsObject.jsCommand", parma,
"nativeCommandForCallback");

网页中相关js函数的实现，异步方式：
jsObject.jsCommand_async = function(params, callback) {
// todo: 得到结果result后，调用  callback(result);
};

同步方式:
jsObject.jsCommand = function(params) {
// todo: 得到结果result
return result;
};

5、如何引入工程

1 直接添加com.zq.webridge.util包下面的所有类
2 使用WBWebView作为网页容器
3 实现WebUriListener和WBWebridgeListener接口
4 使用wbUri.openURI(uri);打开网页内触发的各种WBURI
5 网页中引入webridge.js，使得网页可调用WBWebridgeListener的方法
