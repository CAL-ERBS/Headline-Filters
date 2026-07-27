<!-- #include file ="sagecrm.js" -->
<!-- #include file ="json2.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="globalsearch.js" -->
<%
//getFeedToday.asp

function readFile(fname){
	var fso = Server.CreateObject("Scripting.FilesystemObject");
	var txt = fso.OpenTextFile(Server.MapPath(fname));
	return txt.ReadAll();
}

var fields=[];
//set up our fields
fields.push({
	name: "entity",
	order: 1,
	type: 10,
	componentType: getComponentType(10),
	lookup: "",
	newline: true,
	viewfields: ""
});
fields.push({
	name: "recordfield",
	order: 2,
	type: 10,
	componentType: getComponentType(10),
	lookup: "",
	newline: true,
	viewfields: ""
});
fields.push({
	name: "companyname",
	order: 3,
	type: 10,
	componentType: getComponentType(10),
	lookup: "",
	newline: true,
	viewfields: ""
});
fields.push({
	name: "personfullname",
	order: 4,
	type: 10,
	componentType: getComponentType(10),
	lookup: "",
	newline: true,
	viewfields: ""
});
fields.push({
	name: "primaryentity",
	order: 5,
	type: 10,
	componentType: getComponentType(10),
	lookup: "",
	newline: true,
	viewfields: ""
});
fields.push({
	name: "UpdatedDate",
	order: 6,
	type: 10,
	componentType: getComponentType(10),
	lookup: "",
	newline: true,
	viewfields: ""
});
fields.push({
	name: "username",
	order: 7,
	type: 10,
	componentType: getComponentType(10),
	lookup: "",
	newline: true,
	viewfields: ""
});
fields.push({
	name: "FlagStatus",
	order: 8,
	type: 10,
	componentType: getComponentType(10),
	lookup: "",
	newline: true,
	viewfields: ""
});

var NumberOfRecordsReturned=10;
var itemsPerPage=Request.Form('itemsPerPage');
var clientsupportsPagination=true;
if (((itemsPerPage+"")=="undefined")||(itemsPerPage==null)||(itemsPerPage==""))
{
  itemsPerPage=10;
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
  sortBy="UpdatedDate"
}
///////////////////////////////////////////////

//get the data
var userid=getUserId();
	
var sql="SELECT * FROM ( "+readFile("xtodaysql.js")+") as A "+
		" order by UpdatedDate";
var q=null;
try{
	q=CRM.CreateQueryObj(sql);
	q.SelectSQL();
}catch(eSQL){
  Response.Write("SQL Error:"+sql);Response.End();
}
var recordcount=q.recordcount;
var tableData=[];
var rowCount=0;

var rowCount=0;
var startFrom=(((NumberOfRecordsReturned*page)-NumberOfRecordsReturned)+1);
while(!q.eof)
{
	rowCount++;
	if (rowCount>=startFrom)
	{
	  _tmpobj={
			"count":rowCount,
			"entityid": q("entityid"),
			"entity":q("entity"),
			"tilecolor":getTileColour(q("entity")),
			"tileicon":getTileIcon(q("entity"))
	  }
	  for(var c=0;c<fields.length;c++)
	  {
		_tmpobj[fields[c].name.toLowerCase()]=getSearchListFieldsData(q("entity"), fields[c], q(fields[c].name), true);
	  }
	  tableData.push(_tmpobj);
	  if (rowCount>=(NumberOfRecordsReturned*page))
		break;	  
	}
	q.NextRecord();
}

var tableColumns=[];
//add in select field
tableColumns.push({
	"value": "__Select__",
	"text": "",
	"sortable": false
  });
for(var c=0;c<fields.length;c++)
{
  tableColumns.push({
        "value": fields[c].name.toLowerCase(),
        "text": CRM.GetTrans("colNames",fields[c].name),
		"componentType":fields[c].componentType
      });
}

//fix up data for clients that do not have pagination
if (!clientsupportsPagination)
  page=0;
  
var res={
  "screenMetadata": {
	"page":"companyaddresses"
  },
  "data": {
	"recordcount":recordcount,
	"entity":"activityfeedtoday",
	"sortBy":sortBy,
	"sortDesc":sortDesc,
	"page":page,
	"MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
    "searchstring":"activityfeedtodaySQL",
    "tableData": tableData,
    "tableColumns": tableColumns
  }
}
res=JSON.stringify(res);
Response.Write(res);
%>