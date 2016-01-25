/**
 * 
 */
package com.dkm.sdk;

/**
 * @author DKM20150316
 *
 */
public class SDKInterface {
	public interface CompleteCallBack {
		void onComplete();
	}
	public interface InitCallBack {
		public void initSucceed(String extraJson);
		public void initFailed(String reason);
	}
	public interface LogoutCallBack {
		public void succeed();
		public void failed();
	}

	public interface ExitCallBack {
		public void onGameHasExitView();// 游戏自己的退出界面
		public void onChannelHasExitView();// 渠道有自己的退出界面，游戏只需进行游戏的退出操作和资源释放等
	}

	public interface LoginCallBack {
		public void succeed(String userId, String token,String password, String msg);
		public void failed(String msg);
		public void cancelled();
	}

	public interface PayCallBack {
		public void succeed(String orderId, String msg);
		public void failed(String orderId, String msg);
		public void cancelled(String orderId, String msg);
	}
};
