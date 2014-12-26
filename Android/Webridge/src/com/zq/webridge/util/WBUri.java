package com.zq.webridge.util;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;

/**
 * uri分发机制
 * 
 * @author user
 *
 */
public class WBUri {
	private Context mContext;
	private WebUriListener mListener;

	public WBUri(Context context, WebUriListener listener) {
		mContext = context;
		mListener = listener;
		if (mContext == null) {
			throw new NullPointerException("WBUri mContext is NULL!");
		}
		if (mListener == null) {
			throw new NullPointerException("WBUri UriListener is NULL!");
		}
	}

	/**
	 * 是否可以打开uri
	 * 
	 * @param uriStr
	 * @return
	 */
	private boolean canOpenURI(String uriStr) {
		if (TextUtils.isEmpty(uriStr)) {
			return false;
		}

		Uri uri = Uri.parse(uriStr);
		String scheme = uri.getScheme();
		String path = uri.getPath();
		if (TextUtils.isEmpty(scheme) || TextUtils.isEmpty(path)) {
			return false;
		}

		if (TextUtils.equals(scheme, mListener.scheme())) {
			return true;
		}

		if (scheme.startsWith("http")
				&& path.startsWith("/" + mListener.scheme())) {
			// NOTE http://www.baidu.com/slate/article/1/2/3
			return true;
		}

		return false;
	}

	/**
	 * 打开uri
	 * 
	 * @param uriStr
	 */
	public void openURI(String uriStr) {
		if (!canOpenURI(uriStr)) {
			mListener.unknownURI(uriStr);
			return;
		}

		Uri uri = Uri.parse(uriStr);
		String scheme = uri.getScheme();
		String path = uri.getPath();
		String command = "";
		String params = "";

		if (TextUtils.equals(scheme, mListener.scheme())) {
			// NOTE slate://article/4/12/238/
			command = uri.getHost();
			if (TextUtils.isEmpty(command)) {
				mListener.unknownURI(uriStr);
				return;
			}
			params = path;
		} else {
			// NOTE http://www.xxx.com/slate/article/4/12/238/
			String[] pathArr = path.split("/");
			// NOTE {"",slate,article,4,12,238};
			if (pathArr.length < 2) {
				mListener.unknownURI(uriStr);
				return;
			}
			command = pathArr[2];
			int start = mListener.scheme().length() + command.length() + 2;
			if (start >= 0 && start <= path.length()) {
				params = path.substring(start);
			} else {
				mListener.unknownURI(uriStr);
				return;
			}
		}

		List<String> paramsList = new ArrayList<String>();
		if (!TextUtils.isEmpty(params)) {
			if (params.startsWith("/"))
				params = params.substring(1);
			String[] pArr = params.split("/");
			for (String p : pArr) {
				paramsList.add(p);
			}
		}

		handleURICommand(command, params, paramsList);
	}

	private void handleURICommand(String command, String params,
			List<String> paramsList) {
		String methodName = command + "Command";
		Object[] args = { command, params, paramsList };
		try {
			InvokeMethod.invokeMethod(mListener, methodName, args);
		} catch (Exception e) {
			e.printStackTrace();
			mListener.unknownCommand(command, params, paramsList);
		}
	}

}
