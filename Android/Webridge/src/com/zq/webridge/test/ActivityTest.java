package com.zq.webridge.test;

import android.app.Instrumentation;
import android.os.Handler;
import android.test.ActivityInstrumentationTestCase2;

import com.zq.webridge.MainActivity;
import com.zq.webridge.R;
import com.zq.webridge.util.WBWebView;
import com.zq.webridge.util.WBWebridge;

public class ActivityTest extends
		ActivityInstrumentationTestCase2<MainActivity> {

	private MainActivity mActivity;
	@SuppressWarnings("unused")
	private WBWebView mWebView;

	private Handler handler = new Handler();

	private Instrumentation mInstrument;

	public ActivityTest() {
		super("com.zq.webridgetest", MainActivity.class);
	}

	@Override
	protected void setUp() throws Exception {
		super.setUp();
		mInstrument = getInstrumentation();
		mActivity = getActivity();
		mWebView = (WBWebView) mActivity.findViewById(R.id.wv);
	}

	public void testNativeToJsIncludeReturn() {
		WBWebridge.testReturn = null;
		mInstrument.runOnMainSync(new Runnable() {

			@Override
			public void run() {
				mActivity.findViewById(R.id.nativeToJsIncludeReturn)
						.performClick();
			}
		});
		mInstrument.waitForIdleSync();
		handler.postDelayed(new Runnable() {

			@Override
			public void run() {
				assertNotNull(WBWebridge.testReturn);
			}
		}, 1000);
	}

	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}

}
