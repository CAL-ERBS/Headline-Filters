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
var testtable=getTableInfo(entity);
if (!Defined(testtable.name)){
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
    var tableobj=getTableInfo(entity);
    var saveStatus = "";

    var areacode = Request.Form('areacode');
    var countrycode = Request.Form('countrycode');
    var phonenumber = Request.Form('phonenumber');
    var phoneType =  escapeSQL(Request.Form('phoneType'));

   
    var pLink = CRM.FindRecord("PhoneLink", "PLink_EntityID="+tableobj.tableId+" AND PLink_RecordID=" + entityId + " AND PLink_Type='"+phoneType+"'");
    Response.Write("PLink_EntityID="+tableobj.tableId+" AND PLink_RecordID=" + entityId + " AND PLink_Type='"+phoneType+"'");
    
    
    if (!pLink.eof) {
        var eRecord = CRM.FindRecord("Phone", "phon_phoneid=" + pLink.PLink_PhoneId);
        //Response.Write("emai_emailid=" + pLink.RecordId);
        eRecord("phon_areacode") = areacode;
        eRecord("phon_number") = phonenumber;
        eRecord("phon_countrycode") = countrycode;

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