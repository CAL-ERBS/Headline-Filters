<!-- #include file ="sagecrm.js" -->
<!-- #include file ="configreader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="_base_objects.js" -->
<%
var Max=_baseConfig.listlength;
var searchString=Request.Form('s');
if ((searchString+"")=="undefined")
  searchString="";
searchString=new String(searchString);

if (containsRestrictedKeywords(searchString))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")contains Restricted Keywords "+searchString);
  //throw "containsRestrictedKeywords";
}

var entityString=Request.Form('entity');
if ((entityString+"")=="undefined")
  entityString="";
entityString=new String(entityString);
if (Defined(entityString) &&(entityString!=""))
{
	var table=getTableInfo(entityString);
	if (!Defined(table.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
	  throw "No valid Entity found";
	}
}
var idString=Request.Form('entityid');
if ((idString+"")=="undefined")
  idString="";
idString=new String(idString);
if (Defined(idString) &&(idString!=""))
{
	if (!isNumeric(idString)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, idString is "+Request.Form('entityid'));
	  throw "No valid Entity ID found";
	}
}

var itemsPerPage=Request.Form('itemsPerPage');
if (((itemsPerPage+"")=="undefined")||(itemsPerPage==null)||(itemsPerPage==""))
  itemsPerPage=_baseConfig.listlength;
if (!isNumeric(itemsPerPage)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid itemsPerPage found, page is "+Request.Form('itemsPerPage'));
  throw "No valid itemsPerPage found";
}  
NumberOfRecordsReturned=new Number(itemsPerPage);

var page=Request.Form('page');
if (((page+"")=="undefined")||(page==null)||(page==""))
  page=1;
page=new Number(page);
if (!isNumeric(page)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid page found, page is "+Request.Form('page'));
  throw "No valid page found";
}

var sortBy=Request.Form('sortBy');
if (((sortBy+"")=="undefined")||(sortBy==null)||(sortBy=="")||(sortBy=="[]"))
  sortBy="";
sortBy=new String(sortBy);

var _newClientAPI=false;
if (sortBy.indexOf('[{"key"')==0)
{
	//version 6..vue3 code sends data like [{"key":"note","order":"asc"}]
	var __jsonSortBy=JSON.parse(sortBy);
	sortBy="libr_"+__jsonSortBy[0]["key"];
	_newClientAPI=true;
}else  
if (sortBy.indexOf('["')==0)
{
  sortBy=sortBy.substring(2,sortBy.length-2);
}
/*
MR removed this as they are not real column names
if ((sortBy!="")&&(!ValidDBColumn(sortBy)))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid sortBy found, sortBy is "+Request.Form('sortBy'));
  throw "No valid sortBy found:"+sortBy;
}*/

var sortDesc=Request.Form('sortDesc');

if (((sortDesc+"")=="undefined")||(sortDesc==null)||(sortDesc=="")||(sortDesc=="[]"))
  sortDesc="";
sortDesc=new String(sortDesc);
if (_newClientAPI)
{
	//version 6..vue3 code sends data like [{"key":"note","order":"asc"}]
	var sortDesc=Request.Form('sortBy');
	var __jsonSortOrder=JSON.parse(sortDesc);
	sortDesc=__jsonSortOrder[0]["order"];		

	if (sortBy!="")
	{
		sortBy+=" "+sortDesc;
	}
}else
if (sortDesc.indexOf('[')==0)
{
    sortDesc=sortDesc.substring(1,sortDesc.length-1);
	if (sortBy!="")
	{
	
      if (sortBy=="filename")
	    sortBy="libr_filename";
	  else 
		sortBy="libr_note";
		
	  if (sortDesc=="true")
		sortBy+=" desc";
	  else
		sortBy+=" asc";
	}
}
if (sortBy=="")
{
  sortBy=" Libr_updateddate DESC";
}

var EntityCol="";
if (entityString!="")
{
  EntityCol=getLibrEntityColumn(entityString,true);
}

//get the data
var sql="select libr_libraryid,Libr_Type, Libr_Category, Libr_FilePath, Libr_FileName, " +
	" SUBSTRING(Libr_Note,1, 200) as Libr_Note, Libr_Status, libr_updateddate from library where libr_active='Y' and libr_deleted is null and " +
	" libr_global='Y' and (libr_language is null or libr_language = '"+getCRMUserLang()+"') " +
	"and libr_status='Final' and 588=588 and libr_entity is null and Libr_Mergetemplate='N' and " +
	"Libr_Type !='dTargetListExport' and libr_filename not like '%.scsv%'";
	
	//test..DO NOT CHECK THIS IN ************************************
	//sql="select libr_libraryid,Libr_Type, Libr_Category, Libr_FilePath, Libr_FileName, " +
	//" SUBSTRING(Libr_Note,1, 200) as Libr_Note, Libr_Status from library ";
	
if (searchString!="")
{
  sql+=" and libr_filename like '%"+searchString+"%'";
}

sql+=" order by "+sortBy;

if (EntityCol!="")
{
	sql= "select libr_libraryid,Libr_Type, Libr_Category, Libr_FilePath, Libr_FileName, " +
		" SUBSTRING(Libr_Note,1, 200) as Libr_Note, Libr_Status,Libr_updateddate  " +
		"from library WITH (NOLOCK) where 577=577 and "+EntityCol+"="+idString+" and  " +
		"libr_deleted is null";
	if (searchString!="")
	{
	  sql+=" and libr_filename like '%"+searchString+"%'";
	}	
	sql+=" ORDER BY "+sortBy;
}		
			
var libq=CRM.CreateQueryObj(sql);
libq.SelectSQL();
var recordcount=libq.recordcount;
var tableData=[];

var rowCount=0;
var startFrom=(((NumberOfRecordsReturned*page)-NumberOfRecordsReturned)+1);
while(!libq.eof)
{
  rowCount++;
  if (rowCount>=startFrom)
  {  
    //var _displayDate=(new Date(libq.FieldValue("Libr_updateddate")));
	var _displayDate=getUserDateSmart(libq.FieldValue("Libr_updateddate"), true);
	_tmpobj={
		"entityid": libq.FieldValue("libr_libraryid"),
		"type": CRM.GetTrans("Libr_Type",libq.FieldValue("Libr_Type")),
		"category": CRM.GetTrans("Libr_Category",libq.FieldValue("Libr_Category")),
		"filepath": libq.FieldValue("Libr_FilePath"),
		"filename": libq.FieldValue("Libr_FileName"),
		"note": libq.FieldValue("Libr_Note"),
		"status": CRM.GetTrans("Libr_Status",libq.FieldValue("Libr_Status")),
		"updateddate": _displayDate,
		"selected":false,
		"link": getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+
				CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp")+isportalcode()+"id="+libq.FieldValue("Libr_LibraryId")+
		"&entity="+entityString+"&entityid="+idString
	}
	tableData.push(_tmpobj);
	if (rowCount>=(NumberOfRecordsReturned*page))
		break;	  
  }    
  libq.NextRecord();
}

var res={
  "screenMetadata": {},
  "data": {
	"recordcount":recordcount,
	"entity":"library",
	"sortBy":sortBy,
	"sortDesc":sortDesc,
	"page":page,
	"sql":sql,
	"MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
    "searchstring":searchString,  
    "tableData": tableData,
    "tableColumns": [
      {
        "value": "filename",
        "text": CRM.GetTrans("colnames","libr_filename")
      },{
        "value": "note",
        "text": CRM.GetTrans("colnames","Libr_Note")
      },{
        "value": "updateddate",
        "text": CRM.GetTrans("colnames","Libr_updateddate")
      }, {
		"value": "__Select__",
		"text": "",
		"sortable": false
	  }
    ]
  }
}
res=JSON.stringify(res);
Response.Write(res);
%>