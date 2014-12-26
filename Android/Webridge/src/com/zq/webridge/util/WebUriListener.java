package com.zq.webridge.util;

import java.util.List;

/**
 * uri分发机制抽象接口
 * 
 * @author user
 * 
 * @原始格式 [scheme]://[command]/[param1]/[param2]/[param3]
 * @兼容HTTP格式 http://[host]/[scheme]/[command]/[param1]/[param2]/[param3]
 *
 */
public interface WebUriListener {
	/**
	 * 方案，默认slate
	 * 
	 * @return
	 */
	public String scheme();

	/**
	 * 未知的uri
	 * 
	 * @param uri
	 */
	public void unknownURI(String uri);

	/**
	 * 未知的命令
	 * 
	 * @param command
	 * @param params
	 *            command之后的所有字符（主要是有http链接作为参数的情况要用到，不能使用paramsArray,因为
	 *            http链接里面也有斜杠）
	 * @param paramsList
	 *            参数列表
	 */
	public void unknownCommand(String command, String params,
			List<String> paramsList);
}
