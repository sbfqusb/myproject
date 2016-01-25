package com.dkm.sdk;


public class UserInfo {
	public String mroleId;
	public String mroleName;
	public String mlevel;
	public int mzoneId;
	public String mzoneName;
	public String mblance;
	public String mpartyName;
	public String mvip;
	public void setRoleId(String playerRoleId)
	{
		mroleId = playerRoleId;
	}
	public void setRoleName(String roleName)
	{
		mroleName = roleName;
	}
	public void setLv(String playerLevel)
	{
		mlevel = playerLevel;
	}
	public void setZoneId(int zoneId)
	{
		mzoneId = zoneId;
	}
	public void setZoneName(String zoneName)
	{
		mzoneName = zoneName;
	}
	public void setBalance(String Balance)
	{
		mblance = Balance;
	}
	public void setPartyName(String PartyName)
	{
		mpartyName = PartyName;
	}
	public void setVip(String vip)
	{
		mvip = vip;
	}
}
