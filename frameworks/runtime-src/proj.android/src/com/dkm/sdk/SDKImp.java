package com.dkm.sdk;

import android.view.KeyEvent;

import com.dkm.sdk.OrderParams;
import com.dkm.sdk.SDKBase;
import com.dkm.sdk.SDKInterface;
import com.dkm.sdk.SDKInterface.CompleteCallBack;
import com.dkm.sdk.SDKInterface.ExitCallBack;
import com.dkm.sdk.SDKInterface.InitCallBack;
import com.dkm.sdk.SDKInterface.LogoutCallBack;
import com.dkm.sdk.SDKInterface.PayCallBack;

//import com.alipay.sdk.pay.AlipayMgr;

public class SDKImp extends SDKBase {
	@Override
	public void onCreate(SDKInterface.CompleteCallBack CreateComplete)
	{
		super.onCreate(CreateComplete);
		CreateComplete.onComplete();
	}
	
	public void init(SDKInterface.InitCallBack initCallbace)
	{
		super.init(initCallbace);
		mInitCallbace.initSucceed("");
	}
	
	public void setLogoutCallBack(SDKInterface.LogoutCallBack logoutCallBack)
	{
		super.setLogoutCallBack(logoutCallBack);
	}

	@Override
	public String getUserId() {
		// TODO Auto-generated method stub
		return "";
	}

	@Override
	public String getToken() {
		// TODO Auto-generated method stub
		return "";
	}

	@Override
	public int getChannelId() {
		// TODO Auto-generated method stub
		return 100;
	}
	
	@Override
	public void doPay(OrderParams order,SDKInterface.PayCallBack payCallBack)//官方支付
	{
		super.doPay(order, payCallBack);
		if(order.OrderNum.equals("-1"))//支付�?
		{
			//AlipayMgr.getInstance(mActivity).pay(order.Ext);
		}else if (order.OrderNum.equals("-2"))//易宝快捷支付
		{
			
		}else if (order.OrderNum.equals("-2"))//易宝手机�?
		{
			
		}else if (order.OrderNum.equals("-4"))//微信支付
		{
			
		}
	}

	@Override
	public void doLogout() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onDestroy(CompleteCallBack onDestroyComplete) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event,
			ExitCallBack ExitCallBack) {
		// TODO Auto-generated method stub
		return false;
	}
}
