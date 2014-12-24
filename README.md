Webridge iOS
========

1、介绍

    Webridge开源项目为混合式App(Native + Web)开发提供两个核心机制: WBURI + WBWebBridge
    
    WBURI 
        一种统一资源描述符，包含格式约定和分发机制。通过注册URIHandler实现功能扩展。
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
			参数2类型：block     void (^)(id result, NSError *error)
			返回值：   void

	回调js函数格式约定：
		参数个数：两个
		参数1类型：{object}  result  原生方法的返回值,json对象
		参数2类型：{string}  error   错误信息字符串象
		返回值：  void

2、支持环境

	iOS8.0以上

3、适合场景

	混合式App(Native + Web)开发

4、Usage

4.1 iOS使用WBURI

	a. 注册URIHandler
	_handler = [URIHandler new];
	[WBURI registerURIHandler:_handler];

	b. 实现URIHandler， 以article command为例
	- (void)articleCommand:(NSString *)command params:(NSString *)params paramsArray:(NSArray *)paramsArray
	{
		NSLog(@"识别articleCommand\n  params %@\n paramsArray %@", params, paramsArray);
	}

	c. 实现WKNavigationDelegate 的webView:decidePolicyForNavigationAction:decisionHandler:
	- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
	{
		NSURL *url = navigationAction.request.URL;
		if ([WBURI canOpenURI:url]) {
			if (decisionHandler) {
				[WBURI openURI:url];
				decisionHandler(WKNavigationActionPolicyCancel);
				return;
			}
		}
		
		if (decisionHandler) {
			decisionHandler(WKNavigationActionPolicyAllow);
		}
	}

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

4.2 js调用原生代码，并异步得到返回值

	webridge.jsToNative('commandName', {'param':'value'}, function (result, error) {
		if (error.length > 0) {
			// 有错误，显示错误信息
		}
		else {
			// 没有错误，得到结果 result
		}
	})

4.3 iOS调用js函数，并异步得到返回值

	[self.webView evalJSCommand:@"commandName" jsParams:@{@"param": @"value"} 
			completionHandler:^(id result, NSError *error) {
				if (error) {
					// 有错误，显示错误信息
				}
				else {
					// 没有错误，得到结果 result
				}
			}];

5、如何引入工程

	1 将WBURI WBWebView WBWebridge WBUtils 四个类添加到工程
	2 使用WBWebView作为网页容器，指定webridgeDelegate
	3 注册URIHandler
	4 使用[WBURI openURI:]打开网页内触发的各种WBURI
	5 网页中引入webridge.js，使得网页可调用webridgeDelegate的方法

