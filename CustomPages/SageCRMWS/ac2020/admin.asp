<!-- #include file ="../sagecrm.js" -->

<%

//no longer used
so breaking with this code


//reset some caching
Application("webconfig_SearchEntities")=null;
Application("webconfig_NewEntities")=null;
Application("webconfig_NewEntityDefault")=null;

CurrentUser=CRM.GetContextInfo("selecteduser", "User_UserId");

container = CRM.GetBlock('container');

container.DisplayButton(Button_Default) = false;

var _url_upload=CRM.Url("sagecrmws/ac2020/uploadtest.asp");
var _url_entitySearch=CRM.Url("sagecrmws/ac2020/entitySearch.asp");
var _url_fileemail=CRM.Url("sagecrmws/ac2020/fileemail.asp");
var _url_fileemailSearch=CRM.Url("sagecrmws/ac2020/fileemailSearch.asp");
//var _url_filesentemail=CRM.Url("sagecrmws/ac2020/fileemail.asp");
//var _url_filesentemail=CRM.Url("sagecrmws/ac2020/filesentemail.asp");
var _url_apptwebhookendpoint=CRM.Url("sagecrmws/ac2020/apptwebhookendpoint.asp");
var _url_selectentity=CRM.Url("sagecrmws/ac2020/selectentity.asp");
var _url_gettabcontent=CRM.Url("sagecrmws/ac2020/getTabContent.asp");

CRM.AddContent("<div>");
CRM.AddContent("<br><a href='"+_url_upload+"' target='BLANK' >1. Upload file test</a>");
CRM.AddContent("<br><a href='"+_url_entitySearch+"' target='BLANK' >1. EntitySearch</a>");
CRM.AddContent("<br><a href='"+_url_fileemail+"' target='BLANK' >1. File Email</a>");
CRM.AddContent("<br><a href='"+_url_fileemailSearch+"' target='BLANK' >1. File Email Search</a>");
//CRM.AddContent("<br><a href='"+_url_filesentemail+"' target='BLANK' >1. File Sent Email</a>");
CRM.AddContent("<br><a href='"+_url_apptwebhookendpoint+"' target='BLANK' >1. Appointment Web Hook</a>");
CRM.AddContent("<br><a href='"+_url_selectentity+"' target='BLANK' >1. Select Entity</a>");
CRM.AddContent("<br><a href='"+_url_gettabcontent+"' target='BLANK' >1. Get Tab Content</a>");

CRM.AddContent("<br><br>");
CRM.AddContent("</div>");

var _url="";

var crm_url=new String(CRM.Url("sagecrmws/remove.asp"));
var crm_url_arr=crm_url.split("sagecrmws");

_url=crm_url_arr[0]+"sagecrmws/webapp/#/";

CRM.AddContent("<iframe frameborder=1 width=\"450px\" height=\"700px\" src=\""+_url+"\" ></iframe>");

Response.Write(CRM.GetPage('acceleratortab'));

%>