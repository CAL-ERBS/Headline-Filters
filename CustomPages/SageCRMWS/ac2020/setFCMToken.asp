<!-- #include file ="sagecrm.js" -->
<%
    var id = Request.Form("user_userid");
if (!isNumeric(id)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid User ID found, id is "+Request.Form('user_userid'));
  throw "No valid User ID found";
}		
var userRecord = CRM.FindRecord("Users", "user_userid=" + id);
    if (!userRecord.eof) {
        userRecord("user_ct_fcmtoken") = Request.Form("user_ct_fcmtoken");
        userRecord.SaveChangesNoTls();
    }

    Response.Clear();
    Response.Write("ok");
    Response.End();
%>