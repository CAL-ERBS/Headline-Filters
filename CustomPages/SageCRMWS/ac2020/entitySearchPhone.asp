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
<!-- #include file ="globalsearchPhone.js" -->
<% 
Glog("-----------------------file: entitySearchPhone.asp");
var testurl=CRM.Url("sagecrmws/ac2020/entitySearchPhone.asp");
Glog(testurl);
if (!Defined(Request.Form))
{
	//this allows us to test parsing of the data..clever
	Response.Clear();
	Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="Entity">Entity:</label><br>');
	Response.Write('<input type="text" id="Entity" name="Entity" value="__phone__"><br>');
	Response.Write('<label for="searchObject">searchObject:</label><br>');
	Response.Write('<textarea id="searchObject" name="searchObject" rows="20" cols="75">');
	Response.Write('</textarea><br>');	
	Response.Write('<br><input type="submit" value="Submit">');
	Response.Write('<form>');
	
	Response.Write('<br><br><a href="'+testurl+'" >This url</a>');
	Response.End();
}
//////////////////////////////////////////
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

//////////////////////////////////////////
var page=Request.Form('page');
if (((page+"")=="undefined")||(page==null)||(page==""))
  page=1;
page=new Number(page);
if (!isNumeric(page)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid page found, page is "+Request.Form('page'));
  throw "No valid page found";
}
//////////////////////////////////////////
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
//////////////////////////////////////////
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

var entity=Request.Form('entity');

if (((entity+"")=="undefined")||(entity=="All")||(entity=="all"))
  entity="company";
entity=new String(entity);
Glog("entitySearch.asp entity:"+entity);

var searchString=new String(Request.Form('searchObject'));

Glog("entitySearch.asp orderBy:"+sortBy);

Glog("entitySearch.asp globalSearch:"+searchString);
if ((searchString==null)||(searchString==""))
  searchString="__NODATA__";
var gres=globalSearchPhone(searchString);
gres=JSON.parse(gres);
if (gres.data.recordcount==0){
    //fall back to search on last x(7) chars
	searchString=searchString.replace(/ /g, "");//need to do this
    searchString=searchString.substr(searchString.length - 7);
	gres=globalSearchPhone(searchString);
	gres=JSON.parse(gres);
	gres.screenMetadata.fallbacksearch=true;
}

var GLOBAL_TIMEEND2 = new Date().getTime();
var time = GLOBAL_TIMEEND2 - GLOBAL_TIMESTART;
gres.screenMetadata.time=time;
gres=JSON.stringify(gres);
Response.Write(gres);
Response.End();

var GLOBAL_TIMEEND = new Date().getTime();
var time = GLOBAL_TIMEEND - GLOBAL_TIMESTART;
res.screenMetadata.time=time;
res=JSON.stringify(res);
Response.Write(res);
Glog(res);
Glog("entitySearch.asp doEntitySearch end:");
%>