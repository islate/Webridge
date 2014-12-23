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

1.2 WBWebBridge调用机制

1.2.1 原生代码调用网页内的js函数，并获得返回值。

    可调用的js函数格式约定
      参数个数：一个 或 无
      参数类型：json对象
      返回值：  json对象 或 无

1.2.2 网页内的js函数调用原生代码，传递方法名、参数、回调函数名。通过回调函数获得返回值。

	可调用的原生方法约定：
      参数个数：一个 或 无
      参数类型：json对象
      返回值：  json对象 或 无

    回调js函数格式约定：
      参数个数：一个
      参数类型：json对象 {'result': 原生方法返回的json对象, 'error': 错误信息字符串 }
      返回值：  无

2、支持环境

    iOS8.0以上

3、适合场景

    混合式App(Native + Web)开发

4、api

4.1 js api

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
	function wbNativeToJS(jsCommand, jsParams)

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
	function wbJSToNative(command, params, jsCallback)

4.2 iOS api

	// under construction

5、例子

	// under construction

6、如何引入工程

	1 将WBURI WBWebView WBWebridge三个类添加到工程
	2 使用WBWebView作为网页容器，指定webridgeDelegate
	3 注册URIHandler
	4 使用[WBURI openURI:]打开网页内触发的各种WBURI
	5 网页中引入webridge.js，使得网页可调用webridgeDelegate的方法

