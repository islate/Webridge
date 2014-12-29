package com.zq.webridge;

import org.json.JSONArray;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;

import com.zq.webridge.util.WBWebView;

public class MainActivity extends Activity implements View.OnClickListener {
	private WBWebView wv;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// setContentView(R.layout.activity_main);
		setContentView(R.layout.activity_test_uri);
//		setContentView(R.layout.activity_test_method);
		init();
	}

	@SuppressLint("SetJavaScriptEnabled")
	private void init() {
		// URI以及js调用本地方法测试
		boolean testUri = true;
		wv = (WBWebView) findViewById(R.id.test_uri_wv);
		String url = "file:///android_asset/webtonative.html";
		wv.loadUrl(url);
		// 本地调用js测试
//		boolean testUri = false;
//		wv = (WBWebView) findViewById(R.id.test_method_wv);
//		String url = "file:///android_asset/nativetoweb.html";
//		wv.loadUrl(url);

		
		// wv = (WBWebView) findViewById(R.id.wv);
		//
		// String url = "file:///android_asset/index.html";
		// wv.loadUrl(url);
		
		// findViewById(R.id.nativeToJsIncludeReturn).setOnClickListener(
		// new OnClickListener() {
		//
		// @Override
		// public void onClick(View v) {
		// try {
		// testNativeToJs();
		// } catch (Exception e) {
		// e.printStackTrace();
		// }
		// }
		// });
		if (!testUri) {
			findViewById(R.id.nativeToJsWithNoParam).setOnClickListener(this);
			findViewById(R.id.nativeToJsWithOneParam).setOnClickListener(this);
			findViewById(R.id.nativeToJsWithChineseParam).setOnClickListener(
					this);
			findViewById(R.id.nativeToJsWithNumberParam).setOnClickListener(
					this);
			findViewById(R.id.nativeToJsWithArrayParam)
					.setOnClickListener(this);
			findViewById(R.id.nativeToJsWithMultyParam)
					.setOnClickListener(this);
		}

	}

	private void testNativeToJs() throws Exception {
		// String method = "'jsGetPerson'";
		JSONObject parma = new JSONObject();
		parma.put("name", "zq");
		// String parma = "{\"name\":\"zq\"}";
		// String js = "javascript:wbNativeToJS(" + method + ","
		// + parma + ")";
		// wv.loadUrl(js);

		wv.getWebridge().nativeToJs("wbTest.jsGetPerson", parma,
				"nativeToJSCallbackDialog");
	}

	@Override
	public void onClick(View v) {
		int id = v.getId();
		switch (id) {
		case R.id.nativeToJsWithNoParam:
			testNativeToJsWithNoParam();
			break;
		case R.id.nativeToJsWithOneParam:
			testNativeToJsWithOneParam("jc");
			break;
		case R.id.nativeToJsWithChineseParam:
			testNativeToJsWithOneParam("中文");
			break;
		case R.id.nativeToJsWithNumberParam:
			testNativeToJsWithNumberParam();
			break;
		case R.id.nativeToJsWithArrayParam:
			testNativeToJsWithArrayParam();
			break;
		case R.id.nativeToJsWithMultyParam:
			testNativeToJsWithMultyParam();
			break;
		default:
			break;
		}
	}

	private void testNativeToJsWithOneParam(String name) {
		wv.getWebridge().nativeToJs("wbTest.jsGetPerson", name,
				"nativeToJSCallbackDialog");
	}

	private void testNativeToJsWithNumberParam() {
		wv.getWebridge().nativeToJs("wbTest.jsGetPersonByAge", 25,
				"nativeToJSCallbackDialog");
	}

	private void testNativeToJsWithArrayParam() {
		String[] param = { "jc", "ccx" };
		wv.getWebridge().nativeToJs("wbTest.jsGetPersonByArrayParam", param,
				"nativeToJSCallbackByJsonArrayDialog");
	}

	private void testNativeToJsWithNoParam() {
		wv.getWebridge().nativeToJs("wbTest.jsGetPerson", null,
				"nativeToJSCallbackDialog");
	}

	private void testNativeToJsWithMultyParam() {
		try {
			JSONArray paramArray = new JSONArray();
			JSONObject param1 = new JSONObject();
			param1.put("name", "jc");
			JSONObject param2 = new JSONObject();
			param2.put("name", "mxj");
			JSONObject param3 = new JSONObject();
			param3.put("name", "ccx");
			paramArray.put(param1);
			paramArray.put(param2);
			paramArray.put(param3);

			wv.getWebridge().nativeToJs("wbTest.jsGetPersonByDictionaryParam",
					paramArray, "nativeToJSCallbackByJsonArrayDialog");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
