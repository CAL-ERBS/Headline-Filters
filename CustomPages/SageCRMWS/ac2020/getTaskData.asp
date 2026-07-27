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
//gettaskdata.asp
var tmpfrom = new Date(Request.Form("from"));
var from = new Date(tmpfrom.getFullYear(),tmpfrom.getMonth(),tmpfrom.getDate());

var tmpto = new Date(Request.Form("to"));
var to = new Date(tmpto.getFullYear(),tmpto.getMonth(),tmpto.getDate());

var formUserID = Request.Form("userid");
var userId = formUserID;
if (!Defined(userId) || userId==-1)
  userId = CRM.GetContextInfo("user","user_userid");

if (!isNumeric(userId)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid User ID found, userid is "+Request.Form("userid"));
  throw "No valid User ID found";
}

var type = "Task";
if (!Defined(Request.Form) || isNaN(from) || isNaN(to) )
{
  //test mode
  from = new Date();
  from.setDate(from.getDate() - 1);
  to = new Date();
  to.setDate(to.getDate() + 30);
}

var _userObject=getUserObject("and user_userid="+CRM.GetContextInfo("user","user_userid"));
var _userObjectCalendar=getUserObject("and user_userid="+userId);

var data=getTaskData(from,to,_userObjectCalendar,"Task","and comm_deleted is null");
//filter remove
//var data=getTaskData(from,to,_userObjectCalendar,"Task","and comm_status='Pending'");

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
	"caluser":_userObjectCalendar,
	"userid": userId,
	"whereclause":data.whereclause
  },
  "data": {
	"from":""+from.getVarDate()+"",
	"to":""+to.getVarDate()+"",	
	"tasks":data,
	"username": _userObjectCalendar.user_fullname
  }
}

res=JSON.stringify(res);
Response.Write(res);
%>