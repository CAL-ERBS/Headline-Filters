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
//getcalendardata.asp

var tmpfrom = new Date(Request.Form("from"));
//var from = new Date(tmpfrom.getFullYear(),tmpfrom.getMonth(),tmpfrom.getDate(), tmpfrom.getHours(),tmpfrom.getMinutes());
var from = tmpfrom;

var tmpto = new Date(Request.Form("to"));
//var to = new Date(tmpto.getFullYear(),tmpto.getMonth(),tmpto.getDate());
var to = tmpto;

var formUserID = Request.Form("userid");
var userId = formUserID;
if (!Defined(userId) || userId==-1)
  userId = CRM.GetContextInfo("user","user_userid");

if (!isNumeric(userId)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid User ID found, userid is "+Request.Form("userid"));
  throw "No valid User ID found";
}

var type = "Appointment";
if (!Defined(Request.Form))
{
  //test mode
  from = new Date();
  to = new Date();
  to.setDate(to.getDate() + 30);
}

var data=getCalendarData(from,to,userId,'Appointment');

var _userObject=getUserObject("and user_userid="+CRM.GetContextInfo("user","user_userid"));
var uOCsql=" and user_userid="+userId;
if (!Defined(userId)||(userId==""))
	uOCsql=" and user_userid is null";
var _userObjectCalendar=getUserObject(uOCsql);
var _users=[];
if (!isPortalRequest){
	if (_userObject.user_per_todo==3)
	{
	  _users=getUsersForCalendar("");
	}else 
	if (_userObject.user_per_todo==1)
	{
	  _users=getUsersForCalendar("and user_userid="+CRM.GetContextInfo("user","user_userid"));
	}else{
	  _users=getUsersForCalendar("1=2");
	}
}
  
var res={
  "screenMetadata": {
    "lang": getUserLang(),
	"users":_users,
	"appuser":_userObject,
	"caluser":_userObjectCalendar
  },
  "data": {
	"from":""+from.getVarDate()+"",
	"to":""+to.getVarDate()+"",	
	"events":data
  }
}

res=JSON.stringify(res);
Response.Write(res);
%>