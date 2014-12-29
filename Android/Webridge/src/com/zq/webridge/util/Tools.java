package com.zq.webridge.util;

public class Tools {

	/**
	 * 转换jsParmas
	 * 
	 * @param jsParmas
	 * @return
	 */
	public static Object convertJsParmas(Object jsParmas) {
		if (jsParmas == null) {
			return "\"\"";
		}
		if (jsParmas instanceof String) {
			return "'" + jsParmas.toString() + "'";
		}
		if (jsParmas.getClass().isArray()) {
			return arrayToString((Object[]) jsParmas);
		}
		return jsParmas;
	}

	/**
	 * 数组转为string
	 * 
	 * @param array
	 * @return
	 */
	private static String arrayToString(Object[] array) {
		if (array == null) {
			return "[]";
		}
		if (array.length == 0) {
			return "[]";
		}
		StringBuilder sb = new StringBuilder(array.length * 7);
		sb.append('[');
		sb.append(arrayItemToString(array[0]));
		for (int i = 1; i < array.length; i++) {
			sb.append(", ");
			sb.append(arrayItemToString(array[i]));
		}
		sb.append(']');
		return sb.toString();
	}

	private static Object arrayItemToString(Object item) {
		if (item instanceof String) {
			return "'" + item + "'";
		}
		return item;
	}
}
