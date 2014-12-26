package com.zq.webridge;

import java.util.ArrayList;
import java.util.List;

import com.zq.webridge.util.WebUriListener;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;

/**
 * uri分发机制实现
 * 
 * @author user
 *
 */
public class WebUriImplement implements WebUriListener {
	private Context mContext;

	public WebUriImplement(Context context) {
		mContext = context;
	}

	@Override
	public String scheme() {
		return "slate";
	}

	@Override
	public void unknownURI(String uri) {
		Builder build = new AlertDialog.Builder(mContext);
		String message = "未能识别的uri " + uri;
		build.setMessage(message);
		build.setNegativeButton("确定", new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		build.create().show();
	}

	@Override
	public void unknownCommand(String command, String params,
			List<String> paramsList) {
		Builder build = new AlertDialog.Builder(mContext);
		String message = "未能识别的command " + command;
		build.setMessage(message);
		build.setNegativeButton("确定", new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		build.create().show();
	}

	public void articleCommand(String command, String params,
			ArrayList<String> paramsList) {
		showDialog(command, params, paramsList);
	}

	public void webCommand(String command, String params,
			ArrayList<String> paramsList) {
		showDialog(command, params, paramsList);
	}

	private void showDialog(String command, String params,
			ArrayList<String> paramsList) {
		Builder build = new AlertDialog.Builder(mContext);
		String message = "能识别的command:" + command + "\n";
		message += "params:" + params + "\n";
		message += "paramsList:{";
		for (String p : paramsList) {
			message += p + ",";
		}
		message = message.substring(0, message.length() - 1);
		message += "}";
		build.setMessage(message);
		build.setNegativeButton("确定", new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		build.create().show();
	}

}
