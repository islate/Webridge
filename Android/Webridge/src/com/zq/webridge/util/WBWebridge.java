package com.zq.webridge.util;

import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.SparseArray;
import android.webkit.WebView;

public class WBWebridge {
	public static final int CALL_JS = 0;
	public static final String COMMAND_ERROR = "WebridgeDelegate doesn't know method: ";
	public static final String DELEGATE_ERROR = "WebridgeDelegate exception on method: ";

	/**
	 * 异步执行本地方法回调接口
	 * 
	 * @author user
	 *
	 */
	public static interface AsynExecuteCommandListener {
		public void onCallBack(Object result);
	}

	private WebView mWebView;
	private WBWebridgeListener mWbWebridgeListener;

	private int mNativeSequence = 0;// native调用js之后，如果需要js回调本地方法，那么生成本地方法序号(因为js可能是异步的，可能会导致错乱)
	private SparseArray<String> mNativeCommands = new SparseArray<String>();// native调用js之后，如果需要js回调本地方法，那么把本地方法名加入进去

	public static String testReturn;
	public static String testJsToNative;

	private Handler mHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			if (msg.what == CALL_JS) {
				if (msg.obj instanceof String) {
					mWebView.loadUrl((String) msg.obj);
					testJsToNative = (String) msg.obj;
					System.out.println("jsToNativeCallBack:" + testJsToNative);
				}
			}
		}

	};

	public WBWebridge(WebView webView, WBWebridgeListener listener) {
		mWebView = webView;
		mWbWebridgeListener = listener;
	}

	// ==============================js调用native==============================
	/**
	 * js调用的native方法名
	 * 
	 * @param json
	 */
	public void postMessage(String json) {
		System.out.println("postMessage:" + json);
		// {"eval":{"command":"nativeGetPerson","params":{"name":"John"},"sequence":1}}

		JSONObject obj = null;
		try {
			obj = new JSONObject(json);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
		if (obj == null) {
			return;
		}

		JSONObject evalObj = obj.optJSONObject("eval");
		if (evalObj == null) {
			return;
		}

		jsToNative(evalObj);
	}

	/**
	 * js调用native放阿飞
	 * 
	 * @param evalObj
	 */
	private void jsToNative(final JSONObject evalObj) {
		// 需要执行的native方法名
		final String command = evalObj.optString("command");
		// 需要执行的native方法参数
		Object params = evalObj.opt("params");
		if (JSONObject.NULL.equals(params)) {
			params = null;
		}
		final Object parmaObj = params;
		// 调用的序号，用于找到对应的js回调函数(js会自动根据sequence去找对应的方法);如果sequence=-1，那么不需要再给js
		// callback了
		final int sequence = evalObj.optInt("sequence", -1);

		// NOTE 请求原生方法
		// 优先使用异步方法
		mHandler.post(new Runnable() {

			@Override
			public void run() {
				if (!asyncExecuteForCommand(command, parmaObj, sequence)) {
					// 异步方法请求失败，调用同步方法
					executeForCommand(command, parmaObj, sequence);
				}
			}
		});
	}

	/**
	 * 异步执行
	 * 
	 * @param command
	 *            本地方法名
	 * @param parmaObj
	 *            本地方法参数
	 * @param sequence
	 *            回调的js方法序号
	 * @return
	 */
	private boolean asyncExecuteForCommand(final String command,
			Object parmaObj, final int sequence) {
		if (TextUtils.isEmpty(command)) {
			return false;
		}

		AsynExecuteCommandListener listener = new AsynExecuteCommandListener() {

			@Override
			public void onCallBack(Object result) {
				System.out.println("异步执行");
				onFetchResult(result, command, sequence);
			}
		};
		try {
			if (parmaObj == null) {
				InvokeMethod.invokeMethod(mWbWebridgeListener, command,
						new Object[] { listener });
			} else {
				InvokeMethod.invokeMethod(mWbWebridgeListener, command,
						new Object[] { parmaObj, listener });
			}
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

		return true;
	}

	/**
	 * 同步执行
	 * 
	 * @param command
	 *            本地方法名
	 * @param parmaObj
	 *            本地方法参数
	 * @param sequence
	 *            回调的js方法序号
	 * @return
	 */
	private void executeForCommand(String command, Object parmaObj, int sequence) {
		// NOTE 请求原生方法
		if (TextUtils.isEmpty(command)) {
			callbackJs(sequence, "", COMMAND_ERROR + command);
			return;
		}
		Object result = null;
		try {
			if (parmaObj == null) {
				result = InvokeMethod.invokeMethod(mWbWebridgeListener,
						command, null);
			} else {
				result = InvokeMethod.invokeMethod(mWbWebridgeListener,
						command, new Object[] { parmaObj });
			}
		} catch (Exception e) {
			e.printStackTrace();
			callbackJs(sequence, "", COMMAND_ERROR + command);
			return;
		}

		// NOTE 请求js方法
		System.out.println("同步执行");
		onFetchResult(result, command, sequence);
	}

	/**
	 * 拿到本地方法返回值，请求js方法
	 * 
	 * @param result
	 * @param sequence
	 * @param command
	 */
	private void onFetchResult(Object result, String command, int sequence) {
		if (sequence == -1)
			return;
		if (!(result instanceof String)) {
			callbackJs(sequence, "", DELEGATE_ERROR + command);
		} else {
			try {
				new JSONObject(result.toString());
				callbackJs(sequence, result.toString(), "");
			} catch (Exception e) {
				e.printStackTrace();
				callbackJs(sequence, "", DELEGATE_ERROR + command);
			}
		}
	}

	/**
	 * 创建回调js
	 * 
	 * @param sequence
	 *            回调的js方法序号
	 * @param nativeReturnJson
	 *            回调的js方法参数
	 * @param errorMsg
	 *            错误信息
	 * @return
	 */
	private void callbackJs(int sequence, String nativeReturnJson,
			String errorMsg) {
		if (sequence == -1)
			return;
		String js = "javascript:webridge.jsToNativeCallback(" + sequence + ",";
		if (!TextUtils.isEmpty(errorMsg)) {
			js += "\"\"" + "," + "\"" + errorMsg + "\"";
		} else if (TextUtils.isEmpty(nativeReturnJson)) {
			js += "\"\"" + "," + "\"\"";
		} else {
			js += nativeReturnJson;
			js += "," + "\"\"";
		}
		js += ")";

		Message msg = new Message();
		msg.what = CALL_JS;
		msg.obj = js;
		mHandler.sendMessage(msg);
	}

	// ==============================native调用js==============================
	/**
	 * 本地调用js方法
	 * 
	 * @param jsCommand
	 *            js方法名
	 * @param jsParmas
	 *            js方法参数
	 * @param command
	 *            需要获取js返回值的本地方法
	 */
	public synchronized void nativeToJs(String jsCommand, Object jsParmas,
			String command) {
		if (TextUtils.isEmpty(jsCommand)) {
			return;
		}
		String js = "javascript:webridge.nativeToJS(";
		js += "\"" + jsCommand + "\"" + ",";
		if (jsParmas == null) {
			js += "\"\"";
		} else {
			js += jsParmas.toString();
		}
		js += ",";
		if (TextUtils.isEmpty(command)) {
			js += -1;
		} else {
			mNativeSequence++;
			mNativeCommands.put(mNativeSequence, command);
			js += mNativeSequence;
		}
		js += ")";
		System.out.println("nativeToJs:" + js);

		final String loadJs = js;
		mHandler.post(new Runnable() {

			@Override
			public void run() {
				mWebView.loadUrl(loadJs);
			}
		});
	}

	/**
	 * 调用js，js返回结果调用的native方法名
	 * 
	 * @param json
	 */
	public void returnMessage(final String json) {
		System.out.println("returnMessage:" + json);
		testReturn = json;

		JSONObject obj = null;
		try {
			obj = new JSONObject(json);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
		if (obj == null) {
			return;
		}

		JSONObject returnObj = obj.optJSONObject("return");
		if (returnObj == null) {
			return;
		}

		nativeToJSCallback(returnObj);
	}

	/**
	 * 本地调用js方法,并且收到js回调
	 * 
	 * @param result
	 */
	private void nativeToJSCallback(JSONObject returnObj) {
		int sequence = returnObj.optInt("sequence", -1);
		Object result = returnObj.opt("result");
		if (sequence <= 0) {
			return;
		}
		if (JSONObject.NULL.equals(result)) {
			result = null;
		}
		final Object resultObj = result;
		final String command = mNativeCommands.get(sequence, "");
		if (TextUtils.isEmpty(command)) {
			return;
		}
		mNativeCommands.delete(sequence);
		mHandler.post(new Runnable() {

			@Override
			public void run() {
				try {
					if (resultObj == null) {
						InvokeMethod.invokeMethod(mWbWebridgeListener, command,
								null);
					} else {
						InvokeMethod.invokeMethod(mWbWebridgeListener, command,
								new Object[] { resultObj });
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}
	
}
