<!-- #include file ="sagecrm.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
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
  sortBy="sear_entityname"
}
///////////////////////////////////////////////

var startDateTime = " 00:00";
var endDateTime = " 23:59";
//yyyy-MM-dd
				
var entity=Request.QueryString('entity');
if (((entity+"")=="undefined")||(entity=="All")||(entity=="all"))
  entity="";
entity=new String(entity);
var table=getTableInfo(entity);
if ((entity!="")&&(!Defined(table.name))){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
  throw "No valid Entity found";
}

var startdateyyyy=Request.QueryString('yyyy');
if (!isNumeric(startdateyyyy)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Year found, startdateyyyy is "+Request.Form('yyyy'));
  throw "No valid Year found";
}
var startdateMM=Request.QueryString('MM');
if (!isNumeric(startdateMM)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Month found, startdateMM is "+Request.Form('MM'));
  throw "No valid MM found";
}
startdateMM=padDate(startdateMM);
var startdatedd=Request.QueryString('dd');
if (!isNumeric(startdatedd)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid day found, startdatedd is "+Request.Form('dd'));
  throw "No valid Entity ID found";
}
startdatedd=padDate(startdatedd);
var startDate=startdateyyyy+"-"+startdateMM+"-"+startdatedd+startDateTime;

var endDate=startdateyyyy+"-"+startdateMM+"-"+startdatedd+endDateTime;

//get the data
var sql = "select sear_entityid, sear_title, sear_entityname as 'sear_entitynameX' from SearchHistory WITH (NOLOCK) where " +
		"9345=9345 and sear_userid=" + getUserId() + " and sear_deleted is null and " +
		"sear_updateddate >= '" + startDate
		+ "' and sear_updateddate <= '" + endDate + "'";
if (entity != "")
{
	sql += " and sear_entityname='" + entity + "'";
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
		"entityid": q("sear_entityid"),
		"sear_entityname": q("sear_entitynameX"),
		"sear_title": q("sear_title")
	}
	tableData.push(_tmpobj);
	if (rowCount>=(NumberOfRecordsReturned*page))
		break;	  
	} 	
	q.NextRecord();
}

////////////////////////////////////
//get the searchEntities
var searchEntities_sql= "select Bord_Name,Bord_Caption from Custom_Tables where Bord_PrimaryTable='Y' "+
						"and bord_name not in ('address', 'quotes','orders','solutions','communication') order by Bord_Caption";
var q=CRM.CreateQueryObj(searchEntities_sql);
q.SelectSQL();
var searchEntities=[];
var configSearchEntities=new String(GetWebConfigValue("SearchEntities"));
var configSearchEntities_arr=configSearchEntities.split(",");
while(!q.eof)
{
  var _permission=hasPermissionView(q("Bord_Name"));
  if (_permission)
  {
	  _tmpobj={
			"name": q("Bord_Name"),
			"caption": CRM.GetTrans("TabNames",q("Bord_Caption"))
	  }
	  if (contains(configSearchEntities_arr,q("Bord_Name"))) //only add in entities that are in the config
	  {
		searchEntities.push(_tmpobj);
	  }
  }
  q.NextRecord();
}

////////////////////////////////////
var entityOptions=[{
				"text": CRM.GetTrans("GenCaptions","All"),
				"value": "all",
				"selected": true
			}];
for(var xx=0;xx<searchEntities.length;xx++)
{
	var perobj={
			"text": CRM.GetTrans("TabNames",searchEntities[xx].name),
			"value": searchEntities[xx].name,
			"selected": false
		}
	entityOptions.push(perobj);
}

var res={
  "screenMetadata": {
	"entityOptions": entityOptions,
	"entityOptionsDefault": CRM.GetTrans("GenCaptions","All")
  },
  "data": {
	"recordcount":recordcount,
	"entity":"getMySearchHistory",
	"sortBy":sortBy,
	"sortDesc":sortDesc,
	"page":page,  
    "tableData": tableData,
    "tableColumns": [
      {
        "value": "sear_entityname",
        "text": CRM.GetTrans("colNames","sear_entityname")
      },
      {
        "value": "sear_title",
        "text": CRM.GetTrans("colNames","sear_title")
      },
	  {
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