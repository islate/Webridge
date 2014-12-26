package com.zq.webridge.test;

import java.util.ArrayList;
import java.util.List;

import android.test.AndroidTestCase;

import com.zq.webridge.util.WebUriListener;
import com.zq.webridge.util.WBUri;

public class MyTest extends AndroidTestCase {
	public class TestUriImplement implements WebUriListener {
		public int uriStatus;
		public int commandStatus;

		@Override
		public String scheme() {
			return "slate";
		}

		@Override
		public void unknownURI(String uri) {
			uriStatus = -1;
		}

		@Override
		public void unknownCommand(String command, String params,
				List<String> paramsList) {
			commandStatus = -1;
		}

		public void articleCommand(String command, String params,
				ArrayList<String> paramsList) {
		}

		public void webCommand(String command, String params,
				ArrayList<String> paramsList) {
		}

	}

	@Override
	protected void setUp() throws Exception {
		super.setUp();
	}

	public void testURI_web_1() {
		TestUriImplement implement = new TestUriImplement();
		new WBUri(mContext, implement)
				.openURI("slate://web/http://www.baidu.com/");
		assertEquals(0, implement.uriStatus);
		assertEquals(0, implement.commandStatus);
	}

	public void testURI_web_2() {
		TestUriImplement implement = new TestUriImplement();
		new WBUri(mContext, implement)
				.openURI("slate://web/http://www.baidu.com/index.php?data1=abc&data2=bbb#ttttt=1");
		assertEquals(0, implement.uriStatus);
		assertEquals(0, implement.commandStatus);
	}

	public void testURI_article_1() {
		TestUriImplement implement = new TestUriImplement();
		new WBUri(mContext, implement).openURI("slate://article/123/456/789/");
		assertEquals(0, implement.uriStatus);
		assertEquals(0, implement.commandStatus);
	}

	public void testURI_article_2() {
		TestUriImplement implement = new TestUriImplement();
		new WBUri(mContext, implement)
				.openURI("slate://article/123/456/789/1111()()");
		assertEquals(0, implement.uriStatus);
		assertEquals(0, implement.commandStatus);
	}

	public void testURI_unknown_scheme() {
		TestUriImplement implement = new TestUriImplement();
		new WBUri(mContext, implement).openURI("ddddd://article/123/456/789/");
		assertEquals(-1, implement.uriStatus);
	}

	public void testURI_unknown_command() {
		TestUriImplement implement = new TestUriImplement();
		new WBUri(mContext, implement).openURI("slate://ddddd/123/456/789/");
		assertEquals(0, implement.uriStatus);
		assertEquals(-1, implement.commandStatus);
	}
}
