<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<%
var Max=_baseConfig.listlength;

var NumberOfRecordsReturned=Max;
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
/*
MR removed 27 nov as not real columns so this check is wrong
if ((sortBy!="")&&(!ValidDBColumn(sortBy)))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid sortBy found, sortBy is "+Request.Form('sortBy'));
  throw "No valid sortBy found";
}
*/
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
  sortBy="pers_firstname"
}
///////////////////////////////////////////////

var searchString=Request.Form('s');
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

var _topsql="";
if (!clientsupportsPagination)
  _topsql="top " + Max;
  
//get the data
var sql= "SELECT "+_topsql+" *, emai_emailaddress as emailaddress from vAcceleratorEmail WITH (NOLOCK) where " +
					" (emai_emailaddress is not null and emai_emailaddress <>'') and"+
                    " (pers_firstname like '%" + searchString + "%' " +
                    " or pers_lastname like '%" + searchString + "%' " +
                    " or pers_fullname like '%" + searchString + "%' " +
                    " or emai_emailaddress like '%" + searchString + "%')"+
					" and (pers_status is null or pers_status <>'Inactive')"+
					" and (pers_mailrestriction is null or pers_mailrestriction='N')";			
if (sortBy!="")					
  sql+=" order by "+sortBy;			

var qaddresses=CRM.CreateQueryObj(sql);

try{
	qaddresses.SelectSQL();
}catch(e){
  //the view might be the issue so we fix this here...can happen if metadata is not updated
  CRM.ExecSQL("drop view vAcceleratorEmail");
  var vAcceleratorEmail="CREATE VIEW vAcceleratorEmail AS "+  
	  " select distinct pers_firstname, pers_lastname,pers_status,pers_mailrestriction, pers_personid as 'emai_personid',"+   
	  " elink_type as 'emai_type', emai_emailaddress, "+
	  " rtrim(pers_firstname) +' ' + rtrim(pers_lastname) as 'pers_fullname' "+ 
	  " from emaillink,email, vperson "+ 
	  " where  "+
	  " emaillink.elink_entityid=13  "+
	  " and emaillink.elink_emailid=email.emai_emailid "+
	  " and elink_recordid=pers_personid "+
	  " and pers_personid is not null";
  CRM.ExecSQL(vAcceleratorEmail);
}
var recordcount=qaddresses.recordcount;
var tableData=[];
var rowCount=0;
var startFrom=(((NumberOfRecordsReturned*page)-NumberOfRecordsReturned)+1);
while(!qaddresses.eof)
{
	rowCount++;
	if (rowCount>=startFrom)
	{ 
	  _tmpobj={
			"entityid": rowCount,
			"pers_fullname": qaddresses.FieldValue("pers_fullname"),
			"emailaddress": qaddresses.FieldValue("emai_emailaddress")
	  }
	  tableData.push(_tmpobj);
	  if (rowCount>=(NumberOfRecordsReturned*page))
		break;	  
	}   
	qaddresses.NextRecord();
}
	
var res={
  "screenMetadata": {
    "container": "core",
    "buttonAction": "nothing",
    "page": "searchAddressBook",
	"sql":sql
  },
  "data": {
	"recordcount":recordcount,
	"entity":"searchAddressBook",
	"sortBy":sortBy,
	"sortDesc":sortDesc,
	"page":page,
	"MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
    "searchstring":searchString,    
	"to":[],
	"cc":[],
	"bcc":[],
    "tableData": tableData,
    "tableColumns": [
      {
        "value": "pers_fullname",
        "text": CRM.GetTrans("ColNames","pers_fullname")
      },
      {
        "value": "emailaddress",
        "text":CRM.GetTrans("Accelerator","Email Address")
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