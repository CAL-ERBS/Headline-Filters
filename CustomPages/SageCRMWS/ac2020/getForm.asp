<!-- #include file ="sagecrm.js" -->

<!-- #include file ="helpers.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="entrytype44.js" -->
<!-- #include file ="getFormMetadata.js" -->
<%
var entity=new String(Request.Form('entity')).toLowerCase();
var table=getTableInfo(entity);
if (!Defined(table.name)){
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

    //check edit permissions just to be sure

    var edit = hasPermissionEdit(entity);
    if (edit) {
       var res={
          "screenMetadata": {
            "lang": getUserLang(),
	        "page":"getFormMetadata",
	        "screens":[],
            "entity" : entity,
            "entityid" : new String(entityid),
            "screenName" : new String(screenName)
          },
          "data": {}
        }
        res=JSON.stringify(res);
        Response.Write(res);
        Response.End();
    }

//Response.Write(entity + ">>"+ entityid);
var record = getEntityRecord(entity, entityid);
    
var screenName = Request.Form("screenName");
var crmscreen = getScreenWithData(entity, screenName, record, entity);
crmscreen.subheader = ""
var allscreens=[crmscreen];

var data = {};

var e = new Enumerator(record);
while(!e.atEnd()) {
    var field = new String(e.item()).toLowerCase();
    var fieldVal = Defined(record(field)) ? new String(record(field)) : "";        
    data[field] = fieldVal;
    e.moveNext();
}

var res={
  "screenMetadata": {
    "lang": getUserLang(),
	"page":"getFormMetadata",
	"screens":allscreens,
    "entity" : entity,
    "entityid" : new String(entityid),
    "screenName" : new String(screenName)
  },
  "data": data
}
res=JSON.stringify(res);
Response.Write(res);
%>