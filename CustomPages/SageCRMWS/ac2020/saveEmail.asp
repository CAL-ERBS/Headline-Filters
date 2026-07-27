<!-- #include file ="sagecrm.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="entrytype44.js" -->
<!-- #include file ="getFormMetadata.js" -->
<%
    var saveStatus = "success";
    var entity=new String(Request.Form('entity'));
    var tableobj=getTableInfo(entity);
	if (!Defined(tableobj.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
	  throw "No valid Entity found";
	}
	
    var entityId = Request.Form('entityId');
	if (!isNumeric(entityid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
	  throw "No valid Entity ID found";
	}
	
    var saveStatus = "";

    var emailAddress = new String(Request.Form('emailAddress'));
	if (!validEmailAddress(emailAddress))
	{
	   LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid email address found, emailAddress is "+emailAddress);
	   throw "No valid emailAddress found";
	}
    var emailType =  escapeSQL(Request.Form('emailType'));
   
    var eLink = CRM.FindRecord("EmailLink", "ELink_EntityID="+tableobj.tableId+" AND ELink_RecordID=" + entityId + " AND ELink_Type='"+emailType+"'")
    //Response.Write("ELink_EntityID="+tableobj.tableId+" AND ELink_RecordID=" + entityId + " AND ELink_Type='"+emailType+"'")
    if (!eLink.eof) {
        var eRecord = CRM.FindRecord("Email", "emai_emailid=" + eLink.ELink_EmailId);
    //Response.Write("emai_emailid=" + eLink.RecordId);
        eRecord("emai_emailaddress") = emailAddress;
        try {
            eRecord.SaveChanges();
            saveStatus = "success";
        } catch(ex) {
            //Response.Addheader("Status Code", "500");      
            saveStatus = ex.message;
        }

    	
    }
var res = { "status" : saveStatus};
res = JSON.stringify(res);
Response.Write(res);
%>