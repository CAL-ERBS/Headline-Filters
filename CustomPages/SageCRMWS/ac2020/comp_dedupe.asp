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
Glog("comp_dedupe.asp");

var NumberOfRecordsReturned=5;
var _comp_dedupe_searchval=new String(Request.QueryString("v"));
if ((!_comp_dedupe_searchval)||(_comp_dedupe_searchval==""))
{
  Response.Write("");
  Response.End();
} 
//note..._comp_dedupe_searchval is escaped in doEntitySearch (in getEntityWhereClause)
var tmpsearchObject={fieldname:"comp_companyid"};	

res=doEntitySearch("company",tmpsearchObject,_comp_dedupe_searchval,"comp_name",NumberOfRecordsReturned);
res.screenMetadata.title=CRM.GetTrans("ELead","PossibleCompanyMatch");
res=JSON.stringify(res);
Response.Write(res);
/*
old way
var resphtml="";
for (var i=0;i<res.data.tableData.length;i++)
{
  var obj=res.data.tableData[i];
  resphtml+=obj.comp_name+"<br>";
}
if (resphtml!="")
	resphtml=CRM.GetTrans("ELead","PossibleCompanyMatch")+"<br>"+resphtml;
Response.Write(resphtml);
*/
%>