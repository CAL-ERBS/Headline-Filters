<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="mycrm.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="getCommunications.asp" -->
<%

var userid=getUserId();
var canSeeMyCRMStats = true;
function getUserStats(userid){

	
	if (isPortalRequest)	{
		var qUser=CRM.Findrecord("users,vAcceleratorPortalCRMUsers","user_userid="+getUserId());
		var _userofficeint=getScreenSection("users",qUser,"UsersOfficeIntPortal",CRM.GetTrans("TabNames","UserDetails"));	
	}
	else {
		var qUser=CRM.Findrecord("users","user_userid="+getUserId());	
		var _userofficeint=getScreenSection("users",qUser,"usersofficeint",CRM.GetTrans("TabNames","UserDetails"));
		
	}
	
	canSeeMyCRMStats = qUser("user_per_todo") == 1 || qUser("user_per_todo") == 3; //all users or user only

	var res=_userofficeint;		
	
	return res;
}	
var configSearchEntities=new String(GetWebConfigValue("SearchEntities"));
	if (isPortalRequest) {
		configSearchEntities = Defined(CurrentPortalCRMUser("acpu_searchentities")) ?  CurrentPortalCRMUser("acpu_searchentities") :  "";
	}
configSearchEntities=configSearchEntities.toLowerCase();

var userstats=getUserStats();

var sysUsesCases=configSearchEntities.indexOf("cases")>-1;
var sysUsesOppos=configSearchEntities.indexOf("opportunity")>-1;

var salesstats=getSalesStats();
var _mycrmcustomtabs=[];
if (canSeeMyCRMStats) {
	_mycrmcustomtabs = getCustomMyCRMTabs();
}

var salesdata=null;
var salesdataLabels=null;

	if (canSeeMyCRMStats) {
		var _oppo_permission=hasPermissionView("opportunity");

		if (_oppo_permission && sysUsesOppos)
		{
			salesdata=getSalesData(getUserId());
			salesdataLabels=getSalesDataLabel();
		}

	}
var casesdata=null;
var casesdataLabels=null;

		if (canSeeMyCRMStats) {
var _case_permission=hasPermissionView("cases");

if (_case_permission && sysUsesCases)
{
	casesdata=getCasesData();
	casesdataLabels=getCasesDataLabel();
	
}
	}

//activitydata
var activitydatasql="select count(*) as activitycount,MONTH(Comm_Datetime) as activitymonth , year(Comm_Datetime) as activityyear "+
			"from "+
			"vCommunication where 7843=7843 and "+
			" Comm_Datetime>(getdate()-365) "+
			" and Comm_Datetime<getdate() "+
			" and cmli_comm_userid="+userid+
			" group by MONTH(Comm_Datetime),year(Comm_Datetime) "+
			" order by activityyear, activitymonth"; 
	
activityres=[];	
var __now=new Date();
for(var x=0; x<12; x++) {
    activityres.push(0);
}
var activitydataObj=getActivityData(activitydatasql,activityres,1);
activitydataObj.datalabel=[];
var monthNameList = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
__now=new Date();
__now.setMonth(__now.getMonth()+1);
for(var x=0; x<12; x++) {
    activitydataObj.datalabel.push(CRM.GetTrans("MonthNameShort",monthNameList[__now.getMonth()]));
	__now.setMonth(__now.getMonth()+1);
}

var _date = new Date();
var firstDay = new Date(_date.getFullYear(), _date.getMonth(), 1);
var lastDay = new Date(_date.getFullYear(), _date.getMonth() + 1, 0);



var res={
  "screenMetadata": {
    "salestats":salesstats,
	"activitydata":activitydataObj.data,
	"activitydatalabels":activitydataObj.datalabel,
	"userdata": userstats
  },
  "data": 
	{ 
	"custompages":_mycrmcustomtabs,
	"salestats":getPipelineStatsJSON(salesdata,salesdataLabels),
	"casestats":getPipelineStatsJSON(casesdata,casesdataLabels)
	}
  }

res=JSON.stringify(res);
Response.Write(res);
%>