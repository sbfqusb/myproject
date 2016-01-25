package org.cocos2dx.lua;

import java.util.HashMap;
import java.util.Map;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.dkm.sdk.*;
import com.dkm.sdk.SDKInterface.ExitCallBack;

public class SdkMgr {

	private static final String TAG = SdkMgr.class.getName();

	public AppActivity context;
	public Boolean isLogin;
	public int m_keyCode;
	public KeyEvent m_event;

	private SdkMgr() {
		isLogin = false;
	}

	private static final SdkMgr oneSdk = new SdkMgr();

	public static SdkMgr getInstance() {
		return oneSdk;
	}

	protected void onCreate(AppActivity activity, Bundle savedInstanceState) {
		context = activity;
		// SDKBase.registerClass =
		initSdk();
		SDKBase.getInstance(activity).onCreate(
				new SDKInterface.CompleteCallBack() {

					@Override
					public void onComplete() {
						// TODO Auto-generated method stub

					}
				});

	}

	private void initSdk() {
		SDKBase.getInstance(context).init(new SDKInterface.InitCallBack() {
			@Override
			public void initSucceed(String extraJson) {
				Log.d(TAG, "initSucceed");
				context.initSdKResult("1");

			}

			@Override
			public void initFailed(String reason) {
				Log.d(TAG, "initFailed");
				context.initSdKResult("0");
			}
		});

		SDKBase.getInstance(context).setLogoutCallBack(
				new SDKInterface.LogoutCallBack() {

					@Override
					public void succeed() {
						isLogin = false;
						context.runOnGLThread(new Runnable() {
							@Override
							public void run() {
								Cocos2dxLuaJavaBridge
										.callLuaGlobalFunctionWithString(
												"goToLogin", "");
							}
						});
					}

					@Override
					public void failed() {
						isLogin = false;
					}
				});
	}

	protected void onStart() {
		SDKBase.getInstance(context).onStart(
				new SDKInterface.CompleteCallBack() {

					@Override
					public void onComplete() {

					}
				});
	}

	protected void onPause() {
		SDKBase.getInstance(context).onPause(
				new SDKInterface.CompleteCallBack() {
					@Override
					public void onComplete() {

					}
				});
	}

	protected void onResume() {
		SDKBase.getInstance(context).onResume(
				new SDKInterface.CompleteCallBack() {
					@Override
					public void onComplete() {

					}
				});
	}

	protected void onRestart() {
		SDKBase.getInstance(context).onRestart(
				new SDKInterface.CompleteCallBack() {

					@Override
					public void onComplete() {

					}
				});
	}

	protected void onStop() {
		Log.v(TAG, "onStop");
		SDKBase.getInstance(context).onStop(
				new SDKInterface.CompleteCallBack() {
					@Override
					public void onComplete() {

					}
				});
	}

	protected void onDestroy() {
		Log.v(TAG, "onDestroy");
		SDKBase.getInstance(context).onDestroy(
				new SDKInterface.CompleteCallBack() {
					@Override
					public void onComplete() {
						/** VM exiting after onDestroy */
						System.exit(0);
					}
				});
	}

	public boolean SDKOnkeyDown(final int keyCode, final KeyEvent event) {
		int channelid = SDKBase.getInstance(context).getChannelId();
		return SDKBase.getInstance(context).onKeyDown(keyCode, event,
				new ExitCallBack() {
					@Override
					public void onGameHasExitView() {
						// 游戏自己弹出退出界面，并进行退出操作，以下为示例
						AlertDialog alertDialog = new AlertDialog.Builder(
								oneSdk.context).create();
						alertDialog.setMessage("是否退出游戏？");
						alertDialog.setButton(DialogInterface.BUTTON_POSITIVE,
								"退出游戏", new DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										Log.d(TAG, "finish which: " + which);
										context.finish();
									}

								});
						alertDialog.setButton(DialogInterface.BUTTON_NEGATIVE,
								"取消退出", new DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										Log.d(TAG, "dismiss which: " + which);
										dialog.dismiss();
									}

								});
						alertDialog.show();
					}

					@Override
					public void onChannelHasExitView() {
						// 渠道有自己的退出界面，游戏只需进行游戏的退出操作和资源释放等
						Log.v(TAG, "exit game");
						context.finish();
					}
				});
	}

	public boolean onKeyDown(final int keyCode, final KeyEvent event) {
		m_keyCode = keyCode;
		m_event = event;
		// if (keyCode == KeyEvent.KEYCODE_BACK)
		// {
		// context.runOnGLThread(new Runnable() {
		// @Override
		// public void run() {
		// Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("goBack", "");
		// }
		// });
		// return true;
		// }
		return SDKOnkeyDown(keyCode, event);

	}

	public static void ExitSdk() {
		oneSdk.context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				oneSdk.SDKOnkeyDown(oneSdk.m_keyCode, oneSdk.m_event);
			}
		});
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		SDKBase.getInstance(context).onActivityResult(requestCode, resultCode,
				data, new SDKInterface.CompleteCallBack() {

					@Override
					public void onComplete() {

					}
				});
	}

	protected void onNewIntent(Intent intent) {
		SDKBase.getInstance(context).onNewIntent(intent,
				new SDKInterface.CompleteCallBack() {

					@Override
					public void onComplete() {

					}
				});
	}

	public void LoginSdk() {
		isLogin = false;
		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				SDKBase.getInstance(context).doLogin(
						new SDKInterface.LoginCallBack() {

							@Override
							public void succeed(String userId, String token,
									String password, String msg) {
								Log.v(TAG, "LoginSdk success");
								isLogin = true;

								Map<String, String> map = new HashMap<String, String>();
								map.put("result", String.valueOf(1));
								map.put("userId", userId);
								map.put("token", token);
								map.put("password", password);
								map.put("msg", msg);
								JSONObject jObject = new JSONObject(map);
								context.LoginCallback(jObject.toString());// success
								context.runOnGLThread(new Runnable() {// 鍒囨崲璐﹀彿
									@Override
									public void run() {
										Cocos2dxLuaJavaBridge
												.callLuaGlobalFunctionWithString(
														"goToLogin", "");
									}
								});
							}

							@Override
							public void failed(String msg) {
								Map<String, String> map = new HashMap<String, String>();
								map.put("result", String.valueOf(0));
								JSONObject jObject = new JSONObject(map);
								context.LoginCallback(jObject.toString());// fail
								Log.v(TAG, "LoginSdk fail");
							}

							@Override
							public void cancelled() {
								Map<String, String> map = new HashMap<String, String>();
								map.put("result", String.valueOf(2));
								JSONObject jObject = new JSONObject(map);
								context.LoginCallback(jObject.toString());// cancel
								Log.v(TAG, "LoginSdk cancelled");
							}
						});
			}
		});
	}

	public void doPay(String orderNumber, int price, int ServerId,
			int ExchangeRate, String ProductId, String ProductName,
			String ProductDesc, String Ext, String Balance, String Vip,
			String Lv, String PartyName, String RoleName, String RoleId,
			String ServerName, String Company, String CurrencyName) {
		Log.v(TAG, "GAME ORDER ID :" + orderNumber);
		Log.v(TAG, "PRICE :" + price);
		Log.v(TAG, "ServerId :" + ServerId);
		Log.v(TAG, "ExchangeRate :" + ExchangeRate);
		Log.v(TAG, "ProductName :" + ProductName);
		Log.v(TAG, "ProductDesc :" + ProductDesc);
		Log.v(TAG, "Ext :" + Ext);

		final OrderParams orderParams = new OrderParams();
		setParamValues(orderNumber, price, ServerId, ExchangeRate, ProductId,
				ProductName, ProductDesc, Ext, Balance, Vip, Lv, PartyName,
				RoleName, RoleId, ServerName, Company, CurrencyName,
				orderParams);

		context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				SDKBase.getInstance(context).doPay(orderParams,
						new SDKInterface.PayCallBack() {

							@Override
							public void succeed(String orderId, String msg) {
								// mAlertDialog.setTitle("pay succeed");
								Map<String, String> map = new HashMap<String, String>();
								map.put("result", String.valueOf(1));// success
								map.put("orderId", orderId);
								map.put("msg", msg);
								JSONObject jObject = new JSONObject(map);
								context.doPayCallBack(jObject.toString());//
							}

							@Override
							public void failed(String orderId, String msg) {
								// mAlertDialog.setTitle("pay failed");
								Map<String, String> map = new HashMap<String, String>();
								map.put("result", String.valueOf(0));// fail
								map.put("orderId", orderId);
								map.put("msg", msg);
								JSONObject jObject = new JSONObject(map);
								context.doPayCallBack(jObject.toString());//
							}

							@Override
							public void cancelled(String orderId, String msg) {
								// mAlertDialog.setTitle("pay cancelled");
								Map<String, String> map = new HashMap<String, String>();
								map.put("result", String.valueOf(2));// cancelled
								map.put("orderId", orderId);
								map.put("msg", msg);
								JSONObject jObject = new JSONObject(map);
								context.doPayCallBack(jObject.toString());//
							}
						});
			}
		});
	}

	private void setParamValues(String orderNumber, int price, int ServerId,
			int ExchangeRate, String ProductId, String ProductName,
			String ProductDesc, String Ext, String Balance, String Vip,
			String Lv, String PartyName, String RoleName, String RoleId,
			String ServerName, String Company, String CurrencyName,
			OrderParams orderParams) {
		/** 濞撳憡鍨欐导鐘插弳閻ㄥ嫬顧囬柈銊吂閸楁洖褰块敍灞剧槨缁楁棁顓归崡鏇☆嚞娣囨繃瀵旂拋銏犲礋閸欏嘲鏁稉锟界幢String */
		/**
		 * appication's order serial number,please be unique for each request to
		 * doPay() method;String
		 */
		orderParams.setOrderNum(orderNumber);
		/**
		 * 闁叉垿顤傞敍灞间簰閸掑棔璐熼崡鏇氱秴閿涙稑缂撶拋顔荤炊閸忥拷00閸掑棛娈戦弫瀛樻殶閸婂稄绱濋崶鐘辫礋閺堝绨哄〒鐘讳壕(娓氬顪嗛惂鎯у
		 * 婢舵岸鍙块妴渚�徔閻欙拷娴犮儱鍘撴稉鍝勫礋娴ｅ稄绱濋懟銉ょ炊閸忋儵鍣炬０婵呯瑝閺勶拷00閸掑棛娈戦弫瀛樻殶閸婂稄绱�
		 * 閸掓瑨绻栨禍娑欑闁挸瀵橀弮鐘崇《閺�垯绮敍娌琻t
		 */
		/**
		 * price,unit is RMB Fen. some channel's paying unit is RMB Yuan,but
		 * OneSDK's is RMB Fen,so you'd better set price to An integer multiple
		 * of 100;int
		 */
		orderParams.setPrice(price);
		/**
		 * 濞撳憡鍨欓張宥呭閸ｂ暐d閿涘本鐦℃稉锟介嚋閺堝秴濮熼崳鈺閸︹垼nesdk閸氬骸褰寸�鐟扮安娑擄拷閲滈弨顖欑帛闁氨鐓￠崷鏉挎絻閿涘矂绮
		 * 拋銈勮礋0閿涙铂nt
		 */
		/**
		 * game server id,in sdk developer center, you can config a payment
		 * notify url for each server id(1 notify url,1 server id);int
		 */
		orderParams.setServerId(ServerId);
		/** 濞撳憡鍨欑敮浣风瑢娴滅儤鐨敮浣稿幀閹广垺鐦悳锟芥笟瀣渾100娑擄拷閸忓啩姹夊鎴濈閸忔垶宕�00濞撳憡鍨欑敮渚婄幢int */
		/**
		 * exchange rate between game currency and RMB Yuan,for example:100
		 * means 1 RMB Yuan could rate 100 game currency;int
		 */
		orderParams.setExchangeRate(ExchangeRate);
		/** 閸熷棗鎼d閿涙奔tring */
		/**
		 * product Id;String
		 */
		orderParams.setProductId(ProductId);
		/** 閸熷棗鎼ч崥宥囆為敍姹紅ring */
		/**
		 * 閻㈠彉绨琽ppo閵嗕胶娉悳鈺嬬礄閻╁﹦甯哄Ο顏勭潌閸滃瞼娉悳鈺冪彨鐏炲骏绱氬〒鐘讳壕閸熷棗鎼ч崥宥囆為弰鍓с仛閻ㄥ嫮澹掑▓
		 * 濠冿拷閿涘苯娲滃
		 * 銈咁杻閸旂姵绗柆鎾冲灲閺傤叏绱濇俊鍌涚亯濞撶娀浜鹃崣铚傝礋8閿涘潵ppo閿涘锟�0閿涘牏娉悳鈺偯仦蹇ョ礆閵嗭拷1閿涳拷
		 * 閻╁﹦甯虹粩鏍х潌閿涘鍨悧瑙勭暕婢跺嫮鎮婇崯鍡楁惂閸氬秶袨
		 */
		/** product name;String */
		/**
		 * because of the channel "oppo" and "ewan" is different from the
		 * others,so if channelId is 8(oppo) or 50(ewanh:"ewan" horizontal
		 * version) or 51(ewanv:"ewan" vertical version),you need code specially
		 * like follows when set productName
		 */
		int channelId = SDKBase.getInstance(context).getChannelId();
		if (channelId == 8 || channelId == 50 || channelId == 51) {
			orderParams.setProductCount(price / 10);
			orderParams.setProductName("钻石");
		} else {
			orderParams.setProductName(ProductName);
		}
		/** 閸熷棗鎼ч幓蹇氬牚閿涙奔tring */
		/** product description;String */
		orderParams.setProductDesc(ProductDesc);
		/**
		 * 闂勫嫬濮炵�妤侇唽閿涙稒鏂侀崷銊╂閸旂姴鐡у▓鍏歌厬閻ㄥ嫬锟介敍瀛玭eSDK閺堝秴濮熼崳銊ь伂娴兼矮绗夋担婊�崲娴ｆ洑鎱ㄩ弨褰掞拷鏉╁
		 * 洦婀囬崝鈥虫珤闁氨鐓￠柅蹇庣炊缂佹瑦鐖堕幋蹇旀箛閸斺�娅掗敍姹紅ring
		 */
		/**
		 * extra data,sdk server will pass 'extra data' via sdk server notify
		 * with modify nothing;String
		 */
		orderParams.setExt(Ext);
		/** 閻劍鍩涘〒鍛婂灆鐢椒缍戞０婵撶礉婵″倹鐏夊▽鈩冩箒鐠愶附鍩涙担娆擃杺閿涘矁顕繅锟�String */
		/**
		 * user game currency balance,if your game doesn't have this params set
		 * 0(zero) please;String
		 */
		orderParams.setBalance(Balance);
		/** vip缁涘楠囬敍灞筋渾閺嬫粍鐥呴張澶涚礉鐠囧嘲锝�閿涙奔tring */
		/**
		 * user vip level,if your game doesn't have this params set 0(zero)
		 * please;String
		 */
		orderParams.setVip(Vip);
		/** 鐟欐帟澹婄粵澶岄獓閿涘苯顪嗛弸婊勭梾閺堝绱濈拠宄帮綖0閿涙奔tring */
		/**
		 * user role level,if your game doesn't have this params set 0(zero)
		 * please;String
		 */
		orderParams.setLv(Lv);
		/** 瀹搞儰绱伴妴浣稿簻濞叉儳鎮曠粔甯礉婵″倹鐏夊▽鈩冩箒閿涘矁顕繅锟介敍姹紅ring */
		/**
		 * party(a faction of users) name,if your game doesn't have this params
		 * set 0(zero) please;String
		 */
		orderParams.setPartyName(PartyName);
		/** 鐟欐帟澹婇崥宥囆為敍姹紅ring */
		/**
		 * role name;String
		 */
		orderParams.setRoleName(RoleName);
		/** 鐟欐帟澹奿d閿涙奔tring */
		/**
		 * role id;String
		 */
		orderParams.setRoleId(RoleId);
		/** 閹碉拷婀張宥呭閸ｃ劌鎮曠粔甯幢String */
		/**
		 * server name which the role in;String
		 */
		orderParams.setServerName(ServerName);
		/** 閸忣剙寰冮崥宥囆為敍姹紅ring */
		/**
		 * company name;String
		 */
		orderParams.setCompany(Company);
		/** 鐠愌冪閸氬秶袨閿涙奔tring */
		/**
		 * game currency name;String
		 */
		orderParams.setCurrencyName(CurrencyName);

		orderParams.setAppName("斗罗大陆神界传说");
		// orderParams.setAppName(oneSdk.context.getPackageName());

	}

	public static void logoutSdk() {
		oneSdk.context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				SDKBase.getInstance(oneSdk.context).doLogout();
			}
		});
	}

	public static String getUserId() {
		String userID = SDKBase.getInstance(oneSdk.context).getUserId();
		return userID;
	}

	public static String getToken() {
		return SDKBase.getInstance(oneSdk.context).getToken();
	}

	public static int isLogin() {
		return oneSdk.isLogin ? 1 : 0;
	}

	public static void submitRoleInfo(final int infoType, final String roleId,
			final String roleName, final String level, final int zoneId,
			final String zoneName) {
		if(!oneSdk.isLogin || roleName.equals(""))
		{
			return;
		}
		oneSdk.context.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// info type
				UserInfoType userInfoType = UserInfoType.ROLE_LEVEL_CHANGE;
				if (0 == infoType) {
					userInfoType = UserInfoType.CREATE_ROLE;
				} else if (1 == infoType) {
					userInfoType = UserInfoType.LOGIN;
				}

				String playerRoleId = roleId;
				if (roleId.equals("")) {
					playerRoleId = "123";
				}

				String playerLevel = level;
				if (level.equals("")) {
					playerLevel = "1";
				}
				// role info
				UserInfo userInfo = new UserInfo();
				userInfo.setRoleId(playerRoleId);
				userInfo.setRoleName(roleName);
				userInfo.setLv(playerLevel);
				userInfo.setZoneId(zoneId);
				userInfo.setZoneName(zoneName);
				userInfo.setBalance("0");
				userInfo.setPartyName("test");
				userInfo.setVip("0");
				Log.v(TAG, "submitRoleInfo");
				Log.v(TAG, "infoType:" + infoType);
				Log.v(TAG, "playerRoleId:" + playerRoleId);
				Log.v(TAG, "roleName:" + roleName);
				Log.v(TAG, "playerLevel:" + playerLevel);
				Log.v(TAG, "zoneId:" + zoneId);
				Log.v(TAG, "zoneName:" + zoneName);
				SDKBase.getInstance(oneSdk.context).submitUserInfo(
						userInfoType, userInfo,
						new SDKInterface.CompleteCallBack() {

							@Override
							public void onComplete() {
								// TODO Auto-generated method stub
								Log.v(TAG, "submitRoleInfo SUCCESS============");
							}
						});
			}
		});
	}
	
	public static String getDataJson(){
		String DataJson = "local dataJson={";
		DataJson += "uid = " + "\""+ getUserId()+ "\""+";";
		DataJson += "accessToken = " + "\""+getToken()+"\""+";";
		DataJson += "} return dataJson";
		return DataJson;
	}
}
