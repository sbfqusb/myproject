/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.ArrayList;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.dkm.sdk.SDKBase;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.provider.Settings;
import android.text.format.Formatter;
import android.util.Log;
import android.view.KeyEvent;
import android.view.WindowManager;
import android.widget.Toast;


public class AppActivity extends Cocos2dxActivity{

    static String hostIPAdress = "0.0.0.0";
    static int initPlatmLuaFun = 0;
    static int loginSdkCallbackLuaFun = 0;
    static int doPaySdkCallbackLuaFun = 0;
    static String sdkInitResult = "-1";
    static AppActivity context;
    
    private static final String TAG = AppActivity.class.getName();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        context = this;
        SdkMgr.getInstance().onCreate(this, savedInstanceState);
//        if(nativeIsLandScape()) {
//            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
//        } else {
//            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
//        }
//        
//        //2.Set the format of window
//        
//        // Check the wifi is opened when the native is debug.
//        if(nativeIsDebug())
//        {
//            getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
//            if(!isNetworkConnected())
//            {
//                AlertDialog.Builder builder=new AlertDialog.Builder(this);
//                builder.setTitle("Warning");
//                builder.setMessage("Please open WIFI for debuging...");
//                builder.setPositiveButton("OK",new DialogInterface.OnClickListener() {
//                    
//                    @Override
//                    public void onClick(DialogInterface dialog, int which) {
//                        startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
//                        finish();
//                        System.exit(0);
//                    }
//                });
//
//                builder.setNegativeButton("Cancel", null);
//                builder.setCancelable(true);
//                builder.show();
//            }
//            hostIPAdress = getHostIpAddress();
//        }
    }
    private boolean isNetworkConnected() {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
            if (cm != null) {  
                NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
            ArrayList networkTypes = new ArrayList();
            networkTypes.add(ConnectivityManager.TYPE_WIFI);
            try {
                networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
            } catch (NoSuchFieldException nsfe) {
            }
            catch (IllegalAccessException iae) {
                throw new RuntimeException(iae);
            }
            if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
                    return true;  
                }  
            }  
            return false;  
        } 
     
    public String getHostIpAddress() {
        WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        int ip = wifiInfo.getIpAddress();
        return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
    }
    
    public static String getLocalIpAddress() {
        return hostIPAdress;
    }
    
    private static native boolean nativeIsLandScape();
    private static native boolean nativeIsDebug();
    
    public static void initPlatform(int luaFun){
    	initPlatmLuaFun = luaFun;
    	if (sdkInitResult.equals("-1") == false){
    		ExecLuaCallBack(initPlatmLuaFun,sdkInitResult);
    	}
    }
    
    public void initSdKResult(String value){
    	sdkInitResult = value;
    	if (initPlatmLuaFun > 0){		
    		ExecLuaCallBack(initPlatmLuaFun,sdkInitResult);
    	}

    }
    
    public static int getChannelId(){
    	int id = SDKBase.getInstance(context).getChannelId();
    	Log.v(TAG, "getChannelId :" + id);
    	return id;
    }   
        
    public static int getAppVersionCode(){
    		PackageManager mgr = context.getPackageManager();
    		PackageInfo info = null;
			try {
				info = mgr.getPackageInfo(context.getPackageName(),0);
			} catch (NameNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    		int versionCode = info.versionCode;
    		return versionCode;
    }
    
    public static void ExecLuaCallBack(final int fun,final String result){
    	context.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(fun, result);
				Cocos2dxLuaJavaBridge.releaseLuaFunction(fun);
			}
		});
		
    }
    @Override
   	protected void onStart() {
   		super.onStart();
   		SdkMgr.getInstance().onStart();
   	}

   	@Override
   	protected void onPause() {
   		super.onPause();
   		SdkMgr.getInstance().onPause();
   	}

   	@Override
   	protected void onResume() {
   		super.onResume();
   		SdkMgr.getInstance().onResume();
   	}

   	@Override
   	protected void onRestart() {
   		super.onRestart();
   		SdkMgr.getInstance().onRestart();
   	}

   	@Override
   	protected void onStop() {
   		super.onStop();
   		SdkMgr.getInstance().onStop();
   	}

   	@Override
   	protected void onDestroy() {
   		super.onDestroy();
   		SdkMgr.getInstance().onDestroy();
   	}

   	@Override
   	public boolean onKeyDown(final int keyCode, final KeyEvent event) {
   		if (SdkMgr.getInstance().onKeyDown(keyCode, event) == false)
   		{
   			return super.onKeyDown(keyCode, event);
   		}
   		return true;
   	}

   	@Override
   	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
   		super.onActivityResult(requestCode, resultCode, data);
   	}

   	@Override
   	protected void onNewIntent(Intent intent) {
   		super.onNewIntent(intent);
   	}
   	
	public static void LoginSdk(int luaFun){
		loginSdkCallbackLuaFun = luaFun;
		SdkMgr.getInstance().LoginSdk();		
	}
	public void LoginCallback(String value){//1:success 2:cancel 3:fail
		if (loginSdkCallbackLuaFun > 0){
			ExecLuaCallBack(loginSdkCallbackLuaFun,value);
		}
	}
	
	public static void doPay(int luaFun,
			String orderNumber, 
			float price,
			float ServerId,
			float ExchangeRate,
			String ProductId,
			String ProductName,
			String ProductDesc,
			String Ext,
			String Balance,
			String Vip,
			String Lv,
			String PartyName,
			String RoleName,
			String RoleId,
			String ServerName,
			String Company,
			String CurrencyName){
		doPaySdkCallbackLuaFun = luaFun;
		SdkMgr.getInstance().doPay(orderNumber, 
										 (int)price,
										 (int)ServerId,
										 (int)ExchangeRate,
										 ProductId,
										 ProductName,
										 ProductDesc,
										 Ext,
										 Balance,
										 Vip,
										 Lv,
										 PartyName,
										 RoleName,
										 RoleId,
										 ServerName,
										 Company,
										 CurrencyName);
	}
	public void doPayCallBack(String value){//1:success 2:cancel 3:fail
		if (doPaySdkCallbackLuaFun > 0){
			ExecLuaCallBack(doPaySdkCallbackLuaFun,value);
		}
	}	
	
}
