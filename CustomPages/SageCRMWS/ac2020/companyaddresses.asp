<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="globalsearch.js" -->
<%

function getContextCompandId(){
  var _payload=Request.Form('screens');
  var _payloadObj=JSON.parse(_payload);
  var _foundpers_companyid="-1";
  for(var rr=0;rr<_payloadObj.length;rr++)
  {
		var _formElements=_payloadObj[rr].formElements;
		for(var aa=0;aa<_formElements.length;aa++)
		{
			var _formObj=_formElements[aa];
			if (_formObj.name=="pers_companyid")
			{
				if ((_formObj.value)&&(_formObj.value.value)&&(_formObj.value.value.entityid))
				{
					_foundpers_companyid=_formObj.value.value.entityid;
					break;
				}
			}
		}
		if (_foundpers_companyid!="-1")
		  break;
  }
  return _foundpers_companyid;
}

var entity="address";
var fields=getSearchListFields(entity);
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
var _contextcompanyid="-1";
_contextcompanyid=getContextCompandId();

if (!isNumeric(_contextcompanyid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, _contextcompanyid is "+_contextcompanyid);
  throw "No valid Entity ID found";
}
///////////////////////////////////////////////page
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
  sortBy="addr_updateddate"
}
///////////////////////////////////////////////

//get the data
var userid=getUserId();

var sqlFilter=CRM.FindRecord("address,vAddressCompany","1250=1250 and AdLi_CompanyID="+_contextcompanyid);
	
var sql="SELECT * FROM ( select * , ROW_NUMBER() over(ORDER BY  Addr_Address1, Addr_Address1) AS rowranking "+
		" from vAddressCompany  "+
		"WITH (NOLOCK)  WHERE 1251=1251 and AdLi_CompanyID="+_contextcompanyid+") as A "+
		" order by "+sortBy;

var q=CRM.CreateQueryObj(sql);
q.SelectSQL();
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
			"entityid": q("Addr_Address1"),
			"entity":entity,
			"tilecolor":getTileColour(entity),
			"tileicon":getTileIcon(entity)
	  }
	  for(var c=0;c<fields.length;c++)
	  {
		_tmpobj[fields[c].name.toLowerCase()]=getSearchListFieldsData(entity, fields[c], q(fields[c].name), true);
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
	"entity":"address",
	"sortBy":sortBy,
	"sortDesc":sortDesc,
	"page":page,
	"MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
    "searchstring":"AdLi_CompanyID="+_contextcompanyid,
    "tableData": tableData,
    "tableColumns": tableColumns
  }
}
res=JSON.stringify(res);
Response.Write(res);
%>