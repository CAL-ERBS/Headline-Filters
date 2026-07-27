<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->

<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="globalsearch.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="SearchHistory.js" -->
<!-- #include file ="getFormMetadata.js" -->
<%
Glog("pers_dedupe.asp");

var NumberOfRecordsReturned=5;
var _pers_dedupe_searchval=new String(Request.QueryString("v"));
if ((!_pers_dedupe_searchval)||(_pers_dedupe_searchval==""))
{
  Response.Write("");
  Response.End();
} 
//note..._pers_dedupe_searchval is escaped in doEntitySearch (in getEntityWhereClause)
var tmpsearchObject={fieldname:"pers_personid"};	

res=doEntitySearch("person",tmpsearchObject,_pers_dedupe_searchval,"",NumberOfRecordsReturned);
res.screenMetadata.title=CRM.GetTrans("ELead","PossPersonMatch");
res=JSON.stringify(res);
Response.Write(res);


%>