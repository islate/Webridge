package com.zq.webridge;

import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;

import com.zq.webridge.util.WBWebView;

public class MainActivity extends Activity {
	private WBWebView wv;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		init();
	}

	@SuppressLint("SetJavaScriptEnabled")
	private void init() {
		wv = (WBWebView) findViewById(R.id.wv);

		String url = "file:///android_asset/index.html";
		wv.loadUrl(url);

		findViewById(R.id.nativeToJsIncludeReturn).setOnClickListener(
				new OnClickListener() {

					@Override
					public void onClick(View v) {
						try {
							testNativeToJs();
						} catch (Exception e) {
							e.printStackTrace();
						}
					}
				});
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
}
