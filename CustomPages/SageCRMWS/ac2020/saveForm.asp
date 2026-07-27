<!-- #include file ="sagecrm.js" -->

<!-- #include file ="helpers.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="entrytype44.js" -->
<!-- #include file ="getFormMetadata.js" -->
<%

var saveStatus = "success";

var entity=new String(Request.Form('entity')).toLowerCase();
var testtable=getTableInfo(entity);
if (!Defined(testtable.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
  throw "No valid Entity found";
}

var entityid = Request.Form('entityId');
if (!isNumeric(entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
  throw "No valid Entity ID found";
}

    var btn = CRM.Button("My button","MyImage.gif", CRM.Url("MyPage.asp"), entity, "EDIT");
    if (!Defined(btn) || btn == "") {
        var res = { "saveStatus" : "not allowed", "updatedRecord" : {}};
        res = JSON.stringify(res);
        Response.Write(res);
    }


var record = getEntityRecord(entity, entityid);
var screenName = Request.Form("screenName");

    var block = CRM.GetBlock(screenName);
    var e = new Enumerator(block);
    var data = {};
    while(!e.atEnd()) {
        var field = new String(e.item()).toLowerCase(); 
        var fieldVal = Request.Form(field);
        record(field) = fieldVal;
        data[field] = new String(fieldVal);
        e.moveNext();
    }

var saveError = null

    try {
        record.SaveChangesNoTls();
    } catch(ex) {
        data = [];
        //Response.Addheader("Status Code", "500");      
        saveStatus = ex.message;
    }

var res = { "saveStatus" : saveStatus, "updatedRecord" : data};
res = JSON.stringify(res);
Response.Write(res);
%>