<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<%

var NumberOfRecordsReturned=100;
var itemsPerPage=Request.Form('itemsPerPage');
var clientsupportsPagination=true;
if (((itemsPerPage+"")=="undefined")||(itemsPerPage==null)||(itemsPerPage==""))
{
  clientsupportsPagination=false;
  itemsPerPage=100;
}
if (!isNumeric(itemsPerPage)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid itemsPerPage found, page is "+Request.Form('itemsPerPage'));
  throw "No valid itemsPerPage found";
}
NumberOfRecordsReturned=new Number(itemsPerPage);

//////page

var page=Request.Form('page');
if (((page+"")=="undefined")||(page==null)||(page==""))
  page=1;
page=new Number(page);
if (!isNumeric(page)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid page found, page is "+Request.Form('page'));
  throw "No valid page found";
}
///////////////////////////////////////////////SORT BY
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
if (sortBy=="")
{
  sortBy=[];
}
///////////////////////////////////////////////SORT DIRECTION
var sortDesc=Request.Form('sortDesc');

if (((sortDesc+"")=="undefined")||(sortDesc==null)||(sortDesc=="")||(sortDesc=="[]"))
  sortDesc="";
sortDesc=new String(sortDesc);

var _sqlsortby=sortBy;
if (sortDesc.indexOf('[')==0)
{
    sortDesc=sortDesc.substring(1,sortDesc.length-1);
	if (sortBy!="")
	{
	  if (sortDesc=="true")
		_sqlsortby+=" desc";
	  else
		_sqlsortby+=" asc";
	}
}
if (sortBy=="")
{
  _sqlsortby="book_title";  //note ...we in fact do not sort now
}

///////////////////////////////////////////////


//get the data
var sql = "select book_entityid, book_entityname, book_title from Bookmarks WITH (NOLOCK) where " +
		"book_userid=" + getUserId() + " and book_deleted is null";
	
//adding in CRM's own favourites
sql+=" union select usrc_RecordId as book_entityid, (select Bord_Name Bord_Name from Custom_Tables "+
	"where Bord_TableId=usrc_EntityId)as book_entityname, '' as book_title from UserRecords	"+
	"where usrc_Type='Favourites' and usrc_UserId="+ getUserId();

var q=CRM.CreateQueryObj(sql);
q.SelectSQL();
var recordcount=q.recordcount;

var tableData=[];
var rowCount=0;
var startFrom=(((NumberOfRecordsReturned*page)-NumberOfRecordsReturned)+1);
while(!q.eof)
{
  rowCount++;
  if (rowCount>=startFrom)
  {  
	  var _table= getTableInfo(q("book_entityname"));
	  _tmpobj={
			"count":rowCount,
			"entityid": q("book_entityid"),
			"book_entityname": capitalize(CRM.GetTrans("Entities",q("book_entityname"))),
			"book_title": getSSADisplayValue(q("book_entityname"), q("book_entityid"), _table.descriptor, false),
			"entity":q("book_entityname"),
			"tilecolor":getTileColour(q("book_entityname")),
			"tileicon":getTileIcon(q("book_entityname"))
	  }  
	  tableData.push(_tmpobj);
	  if (rowCount>=(NumberOfRecordsReturned*page))
		break;	  
  }   
  q.NextRecord();
}

var res={
  "screenMetadata": {
	"page":"getBookmarks"
  },
  "data": {
	"recordcount":recordcount,
	"entity":"Bookmarks",
	"sortBy":sortBy,
	"sortDesc":(sortDesc=="true"),
	"page":page,
	"sql":sql,
	"MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
    "searchstring":CRM.GetTrans("Accelerator","Bookmarks"),
	"disableTableSort":true,
    "tableData": tableData,
    "tableColumns": [
	  {
		"value": "__Select__",
		"text": "",
		"sortable": false
	  },
      {
        "value": "book_entityname",
        "text": CRM.GetTrans("colNames","book_entityname")
      },
      {
        "value": "book_title",
        "text": CRM.GetTrans("colNames","book_title")
      }
    ]
  }
}
res=JSON.stringify(res);
Response.Write(res);
%>