package com.zq.webridge.util;

import java.lang.reflect.Method;

import com.zq.webridge.util.WBWebridge.AsynExecuteCommandListener;

public class InvokeMethod {

	/**
	 * 执行cls方法
	 * 
	 * @param methodName
	 *            方法名
	 * @param args
	 *            参数
	 * @throws Exception
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public static Object invokeMethod(Object owner, String methodName,
			Object[] args) throws Exception {
		Class cls = owner.getClass();
		Class[] argclass;
		if (args == null || args.length == 0) {
			argclass = null;
		} else {
			argclass = new Class[args.length];
			for (int i = 0, j = argclass.length; i < j; i++) {
				argclass[i] = args[i].getClass();
				if (args[i] instanceof AsynExecuteCommandListener) {
					Class interfaces[] = argclass[i].getInterfaces();
					if (interfaces != null && interfaces.length > 0) {
						for (Class inter : interfaces) {
							if (inter.getName().contains("AsynExecuteCommandListener")) {
								argclass[i] = interfaces[0];
								break;
							}
						}
					}
				}
			}
		}
		Method method = cls.getMethod(methodName, argclass);
		return method.invoke(owner, args);
	}

	// 获取方法所需参数类型
	// public static Class[] getMethodParamTypes(Object classInstance,
	// String methodName) throws ClassNotFoundException {
	// Class[] paramTypes = null;
	// Method[] methods = classInstance.getClass().getMethods();// 全部方法
	// for (int i = 0; i < methods.length; i++) {
	// if (methodName.equals(methods[i].getName())) {// 和传入方法名匹配
	// Class[] params = methods[i].getParameterTypes();
	// paramTypes = new Class[params.length];
	// for (int j = 0; j < params.length; j++) {
	// paramTypes[j] = Class.forName(params[j].getName());
	// System.out.println(Class.forName(params[j].getName()));
	// }
	// break;
	// }
	// }
	// return paramTypes;
	// }
}
