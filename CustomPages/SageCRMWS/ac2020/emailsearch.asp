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
<!-- #include file ="entrytype44.js" -->
<%
//used to check emails for qr scanner
Glog("-----------------------file: emailsearch.asp");
var testurl=CRM.Url("sagecrmws/ac2020/emailsearch.asp");

var NumberOfRecordsReturned=_baseConfig.listlength;
var itemsPerPage=Request.Form('itemsPerPage');
if (((itemsPerPage+"")=="undefined")||(itemsPerPage==null)||(itemsPerPage==""))
  itemsPerPage=_baseConfig.listlength;
if (!isNumeric(itemsPerPage)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid itemsPerPage found, page is "+Request.Form('itemsPerPage'));
  throw "No valid itemsPerPage found";
}  
NumberOfRecordsReturned=new Number(itemsPerPage);
if (isNaN(NumberOfRecordsReturned))
  NumberOfRecordsReturned=5;

///////////////////////page//////////////////////
var page=Request.Form('page');
if (((page+"")=="undefined")||(page==null)||(page==""))
  page=1;
page=new Number(page);
if (!isNumeric(page)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid page found, page is "+Request.Form('page'));
  throw "No valid page found";
}
///////////////////////sort by//////////////////////
var sortBy=Request.Form('sortBy');
if (((sortBy+"")=="undefined")||(sortBy==null)||(sortBy=="")||(sortBy=="[]"))
  sortBy="";
sortBy=new String(sortBy);

if (sortBy.indexOf('["')==0)
{
  sortBy=sortBy.substring(2,sortBy.length-2);
}
if ((sortBy!="")&&(!ValidDBColumn(sortBy)))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid sortBy found, sortBy is "+Request.Form('sortBy'));
  throw "No valid sortBy found";
}
/////////////////////////////////////////////////////
var sortDesc=Request.Form('sortDesc');

if (((sortDesc+"")=="undefined")||(sortDesc==null)||(sortDesc=="")||(sortDesc=="[]"))
  sortDesc="";
sortDesc=new String(sortDesc);

if (sortDesc.indexOf('[')==0)
{
	sortDesc=sortDesc.substring(1,sortDesc.length-1);
	if (sortBy!="")
	{
	  if (sortDesc=="true")
		sortBy+=" desc";
	  else
		sortBy+=" asc";
	}
}
/////////////////////////////////////////////////////


var _email=new String(Request.QueryString("email"));
if (!validEmailAddress(_email))
{
   LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid email address found, emailAddress is "+_email);
   throw "No valid emailAddress found";
}
//test line
//_email="info.AaxxellInteravtive@demosagecrm.com";

res=globalSearch(_email);
res=JSON.stringify(res);
Response.ContentType = "application/json";
Response.Write(res);
%>