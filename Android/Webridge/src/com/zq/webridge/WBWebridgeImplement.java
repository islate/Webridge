package com.zq.webridge;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;

import com.zq.webridge.util.WBWebridge.AsynExecuteCommandListener;
import com.zq.webridge.util.WBWebridgeListener;

/**
 * 根据js发送的command注册的方法
 * 
 * @author user
 *
 */
public class WBWebridgeImplement implements WBWebridgeListener {

	// ======================测试数据======================
	public static JSONObject contacts = new JSONObject() {
		{
			putContact(this, 0);
			putContact(this, 1);
			putContact(this, 2);
			putContact(this, 3);
		}
	};

	private static void putContact(JSONObject object, int index) {
		JSONObject obj = new JSONObject();
		try {
			if (index == 0) {
				obj.put("name", "Jacky");
				obj.put("phone", "13800000000");
				obj.put("birthday", "06-21");
				object.put("Jacky", obj);
			} else if (index == 1) {
				obj.put("name", "Tracy");
				obj.put("phone", "18210001000");
				obj.put("birthday", "03-30");
				object.put("Tracy", obj);
			} else if (index == 2) {
				obj.put("name", "John");
				obj.put("phone", "18800010001");
				obj.put("birthday", "03-16");
				object.put("John", obj);
			} else if (index == 3) {
				obj.put("name", "");
				obj.put("phone", "");
				obj.put("birthday", "");
				object.put("unknow", obj);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	private Context mContext;

	public WBWebridgeImplement(Context c) {
		mContext = c;
	}

	// ======================js调用的native方法======================
	public void nativeGetPhoneContacts(AsynExecuteCommandListener listener) {
		if (listener != null) {
			listener.onCallBack(contacts.toString());
		}
	}

	public String nativeGetPhoneContacts() {
		return contacts.toString();
	}

	public String nativeGetPerson(JSONObject parmaObject) {
		if (JSONObject.NULL.equals(parmaObject)) {
			return "";
		}
		String parma = parmaObject.toString();
		try {
			JSONObject parmaObj = new JSONObject(parma);
			String name = parmaObj.optString("name");
			if (contacts.has(name)) {
				return contacts.getJSONObject(name).toString();
			} else {
				final JSONObject object = contacts.getJSONObject("unknow");
				object.put("name", name);
				return object.toString();
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return "";
	}

	public void nativeShowAlert(String parma) {
		Builder build = new AlertDialog.Builder(mContext);
		build.setMessage(parma);
		build.setNegativeButton("确定", new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		build.create().show();
	}

	// ======================native调用的js方法======================
	public void nativeToJSCallbackDialog(JSONObject resultObject) {
		if (JSONObject.NULL.equals(resultObject)) {
			return;
		}
		Builder build = new AlertDialog.Builder(mContext);
		build.setTitle("收到来自js的返回值");
		build.setMessage(resultObject.toString());
		build.setNegativeButton("确定", new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		build.create().show();
	}

}
