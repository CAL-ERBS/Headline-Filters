<!-- #include file ="sagecrm.js" -->

<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="getFormMetadata.js" -->
<%
var NumberOfRecordsReturned=100;
var itemsPerPage=Request.Form('itemsPerPage');
var clientsupportsPagination=true;
if (((itemsPerPage+"")=="undefined")||(itemsPerPage==null)||(itemsPerPage==""))
{
  itemsPerPage=100;
  clientsupportsPagination=false;
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
///////////////////////////////////////////////SORT DIRECTION
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
if (sortBy=="")
{
  sortBy="emte_name"
}
///////////////////////////////////////////////

var searchString=Request.Form('s');
if ((searchString+"")=="undefined")
  searchString=Request.QueryString('s');
if ((searchString+"")=="undefined")
  searchString="";  
searchString=new String(searchString);
searchString=escapeSQL(searchString);
if (containsRestrictedKeywords(searchString))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")contains Restricted Keywords "+searchString);
  //throw "containsRestrictedKeywords";
}

var entity=Request.Form('entity');
var entityFilter=" and 11=11";
if ((entity!=null)&&(entity!='null')&&(entity!="")&&(entity+""!="undefined"))
{
	entityFilter="and (emte_entity='"+entity+"' or emte_entity is null)";
}

var entityid=Request.Form('entityid');

//get the data
var sql= "select emte_id, emte_name, emte_comm_from, emte_comm_replyto, emte_comm_note, " +
                "emte_comm_email, emte_to, emte_cc, emte_bcc from emailtemplates WITH (NOLOCK) " +
                "where emte_deleted is null "+entityFilter;
if (searchString!="")
{
  sql+=" and emte_name like '%"+searchString+"%'";
}
sql+=" order by "+sortBy;
				
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
	  _tmpobj={
			"entityid": q("emte_id"),
			"name": q("emte_name"),
			"from": q("emte_comm_from"),
			"replyto": q("emte_comm_replyto"),
			"note": q("emte_comm_note"),
			"to": q("emte_to"),
			"cc": q("emte_cc"),
			"bcc": q("emte_bcc")
	  }
	  tableData.push(_tmpobj);
	  if (rowCount>=(NumberOfRecordsReturned*page))
		break;	  
	}  
	q.NextRecord();
}

//fix up data for clients that do not have pagination
if (!clientsupportsPagination)
  page=0;

var res={
  "screenMetadata": {
    "page":"getEmailTemplates"
  },
  "data": {
	"recordcount":recordcount,
	"entity":"emailtemplates",
	"sortBy":sortBy,
	"sortDesc":sortDesc,
	"page":page,
	"MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
    "searchstring":searchString,  
    "tableData": tableData,
    "tableColumns": [
      {
        "value": "emte_name",
        "text": CRM.GetTrans("Accelerator","EmailTemplates")
      },
	  {
		"value": "__Select__",
		"text": "",
		"sortable": false
	  }
    ]
  }
}


if ((entity!=null)&&(entity!='null')&&(entity!="")&&(entity+""!="undefined"))
{
  var tableNameView=getTableNameView(entity);
  var table=getTableInfo(entity);
  var q=CRM.Findrecord(tableNameView,"7500=7500 and "+table.idfield+"="+entityid);	
  var selres=_selectEntity(entity,entityid,q, false);	
  res.screenMetadata=selres.screenMetadata;
}
Response.Write(JSON.stringify(res));
Response.End();

res=JSON.stringify(res);
Response.Write(res);
%>