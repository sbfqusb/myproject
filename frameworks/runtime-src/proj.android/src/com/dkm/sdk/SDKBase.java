package com.dkm.sdk;

import org.cocos2dx.lua.AppActivity;

import com.dkm.sdk.sdkImp.ConstCurChannel;

import android.app.Activity;
import android.content.Intent;
import android.view.KeyEvent;

public abstract class SDKBase {
	private static SDKBase single = null;
	public static AppActivity mActivity;

	public static SDKBase getInstance(AppActivity content) {
		if (single == null) {
			mActivity = content;
			try {
				String className = "com.dkm.sdk.sdkImp."
						+ ConstCurChannel.CURCHANNEL;
				single = (SDKBase) Class.forName(className).newInstance();
			} catch (InstantiationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		return single;

	}

	public SDKInterface.CompleteCallBack mCrateComplete;

	public void onCreate(SDKInterface.CompleteCallBack CreateComplete) {
		mCrateComplete = CreateComplete;
	}

	public SDKInterface.InitCallBack mInitCallbace;

	public void init(SDKInterface.InitCallBack initCallbace) {
		mInitCallbace = initCallbace;
	}

	public SDKInterface.LogoutCallBack mLogoutCallBack;

	public void setLogoutCallBack(SDKInterface.LogoutCallBack logoutCallBack) {
		mLogoutCallBack = logoutCallBack;
	}

	public SDKInterface.CompleteCallBack mOnStartComplete;

	public void onStart(SDKInterface.CompleteCallBack onStartComplete) {
		mOnStartComplete = onStartComplete;
	}

	public SDKInterface.CompleteCallBack mOnPauseComplete;

	public void onPause(SDKInterface.CompleteCallBack onStartComplete) {
		mOnPauseComplete = onStartComplete;
	}

	public SDKInterface.CompleteCallBack mOnResumeComplete;

	public void onResume(SDKInterface.CompleteCallBack onResumeComplete) {
		mOnResumeComplete = onResumeComplete;
	}

	public SDKInterface.CompleteCallBack mOnRestartComplete;

	public void onRestart(SDKInterface.CompleteCallBack onRestartComplete) {
		mOnRestartComplete = onRestartComplete;
	}

	public SDKInterface.CompleteCallBack mOnStopComplete;

	public void onStop(SDKInterface.CompleteCallBack onStopComplete) {
		mOnStopComplete = onStopComplete;
	}

	public SDKInterface.ExitCallBack mExitCallBack;


	public SDKInterface.CompleteCallBack mOnActivityResultCom;

	public void onActivityResult(int requestCode, int resultCode, Intent data,
			SDKInterface.CompleteCallBack onActivityResultComplete) {
		mOnActivityResultCom = onActivityResultComplete;
	}

	public SDKInterface.CompleteCallBack mOnNewIntentComplete;

	public void onNewIntent(Intent intent,
			SDKInterface.CompleteCallBack onNewIntentComplete) {
		mOnNewIntentComplete = onNewIntentComplete;
	}

	public SDKInterface.LoginCallBack mloginCallBack;

	public void doLogin(SDKInterface.LoginCallBack loginCallBack) {
		mloginCallBack = loginCallBack;
	}

	public SDKInterface.PayCallBack mPayCallBack;

	public void doPay(OrderParams order, SDKInterface.PayCallBack payCallBack) {
		mPayCallBack = payCallBack;
	}

	public SDKInterface.CompleteCallBack mOnsubmitUserInfoe;

	public void submitUserInfo(UserInfoType userInfoType, UserInfo userInfo,
			SDKInterface.CompleteCallBack onsubmitUserInfo) {
		mOnsubmitUserInfoe = onsubmitUserInfo;
	}

	public abstract void onDestroy(SDKInterface.CompleteCallBack onDestroyComplete);
	public abstract void doLogout();

	public abstract String getUserId();

	public abstract String getToken();

	public abstract int getChannelId();
	
	public abstract  boolean onKeyDown(int keyCode, KeyEvent event,
			SDKInterface.ExitCallBack ExitCallBack);
}
