<!-- #include file ="sagecrm.js" -->

<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="globalsearch.js" -->
<!-- #include file ="tabcontentlist.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="mycrm.js" -->
<%

var entity="cases";
var fields=getSearchListFields(entity);
var NumberOfRecordsReturned=5;
var itemsPerPage=Request.Form('itemsPerPage');
var clientsupportsPagination=true;
if (((itemsPerPage+"")=="undefined")||(itemsPerPage==null)||(itemsPerPage==""))
{
  clientsupportsPagination=false;
  itemsPerPage=5;
}
if (!isNumeric(itemsPerPage)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid itemsPerPage found, page is "+Request.Form('itemsPerPage'));
  throw "No valid itemsPerPage found";
}	
NumberOfRecordsReturned=new Number(itemsPerPage);
if (isNaN(NumberOfRecordsReturned))
  NumberOfRecordsReturned=5;

//filter
var filters=Request.Form('filters');
var filtersObj=[];
if (!Defined(filters)||(!filters)){
  //first time in so get the screen
  filter=null;
}else{
  filtersObj=JSON.parse(filters);  
}

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
	//default to first column desc
	if (fields.length>0)
	{
		sortBy=fields[0].name;
		sortDesc=true;
		_sqlsortby=sortBy+" desc";
	}  
}
///////////////////////////////////////////////

//get the data
var userid=getUserId();
var formUserID = Request.Form("userid");
if (Defined(formUserID))
  userid=formUserID;

if (!isNumeric(userid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid User ID found, userid is "+userid);
  throw "No valid User ID found";
}  

var __whereclause="case_AssignedUserId="+userid+" AND case_status = N'"+getDefaultStatus('case_status')+"' ";
//any filters to add in?
var _crmfilterscreen=getFilterScreen("casepipeline");
if ((!filtersObj)||(filtersObj.length==0))
{
	if (_crmfilterscreen)
		filtersObj=_crmfilterscreen.formElements;
}  
//reset any filter values
if ((filtersObj)&&(filtersObj.length>0))
{	
	for(var pp=0;pp<_crmfilterscreen.formElements.length;pp++)
	{
		var ObjA=_crmfilterscreen.formElements[pp];
		for(var tt=0;tt<filtersObj.length;tt++)
		{
			var ObjB=filtersObj[pp];
			if (ObjA.name==ObjB.name)
			{
				ObjA.value=ObjB.value;
			}
		}
	}
}		
if ((filtersObj)&&(filtersObj.length>0))
{	
	for(var tt=0;tt<filtersObj.length;tt++)
	{
		if (!ValidDBColumn(filtersObj[tt].name))
		{
		  //log to CRM's logs
		  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid filter field found, field name is "+ObjB.name);
		  throw "No valid filter field found";
		}
		if ((typeof filtersObj[tt].value)=="object")  
		{
			if ((filtersObj[tt].value.value!='All')&&(filtersObj[tt].value.value!='sagecrm_code_all'))
			{
				if (__whereclause!="")
					__whereclause+= " and ";
				__whereclause += filtersObj[tt].name+"='" +escapeSQL(filtersObj[tt].value.value)+"' ";
			}
		}
		else{
			if (filtersObj[tt].value!='All')
			{
				if (__whereclause!="")
				  __whereclause+= " and ";			
				__whereclause += filtersObj[tt].name+" like '" +escapeSQL(filtersObj[tt].value)+"%' ";
			}
		}
	}
}

var sqlFilter2=CRM.FindRecord("cases,vListCases",__whereclause);
var caseIdFilter="";
while (!sqlFilter2.eof)
{
	if (caseIdFilter!="")
		caseIdFilter+=",";
	caseIdFilter+=sqlFilter2.item("case_caseid")
	sqlFilter2.NextRecord();
}
if (caseIdFilter!="")
	caseIdFilter="("+caseIdFilter+")";
else
    caseIdFilter="(-1)";
		
var fieldtoget="";
	for(var c=0;c<fields.length;c++)
	{
	    if (fieldtoget!="")
			fieldtoget+=",";
		if (fields[c].type=="51")
		{
			fieldtoget+=fields[c].name+"_CID,"+fields[c].name
		}else{		
			fieldtoget+=fields[c].name
		}
	}
	
var sql="SELECT case_caseid, "+fieldtoget+" FROM ( select * , ROW_NUMBER() over(ORDER BY  case_status, Case_CaseId) AS rowranking "+
		" from vListCases  "+
		"WITH (NOLOCK)  WHERE 7100=7100 and "+__whereclause+
		" and case_caseid in "+caseIdFilter+
		"		) as A"+
		" order by "+_sqlsortby;		

var q=CRM.CreateQueryObj(sql);
try{
	q.SelectSQL();
}catch(e){
  Response.Write("ERROR IN SQL:"+sql);
}
var recordcount=q.recordcount;
var tableData=[];

var rowCount=0;
var startFrom=(((NumberOfRecordsReturned*page)-NumberOfRecordsReturned)+1);
var _xfield={
		type:"31",
		name:"case_caseid",
		lookup:"cases"
  }
var _getTileIcon=getTileIcon("cases");
var _getTileColour=getTileColour("cases");  
while(!q.eof)
{
  rowCount++;
  if (rowCount>=startFrom)
  {  
	_tmpobj={
		"count":rowCount,
		"entityid": q.FieldValue("case_caseid"),
		"entity":entity,
		"color":getTileColour(entity),
		"icon":getTileIcon(entity),
		"hasInternalLink":true,
		"externallink":{
			"url":getExternalLink(_xfield, q),
			"icon":_getTileIcon,
			"color":_getTileColour
		}		
	}
	for(var c=0;c<fields.length;c++)
	{
		if (fields[c].type=="51")
		{
			_tmpobj[fields[c].name]=getCurrencyCID(q.FieldValue(fields[c].name+"_CID"))+ " "+getSearchListFieldsData(entity, fields[c], q.FieldValue(fields[c].name),true);
		}else{		
			_tmpobj[fields[c].name]=getSearchListFieldsData(entity, fields[c], q.FieldValue(fields[c].name), true);
		}
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
        "value": fields[c].name,
        "text": CRM.GetTrans("colNames",fields[c].name),
		"componentType":fields[c].componentType
      });
}

var _userObject=getUserObject("and user_userid="+CRM.GetContextInfo("user","user_userid"));	
var _userObjectCalendar=getUserObject("and user_userid="+userid);
var _users=[];
if (_userObject.user_per_todo==3)
{
  _users=getUsersForCalendar("",_userObject.user_per_todo);
}else 
if (_userObject.user_per_todo==1)
{
  _users=getUsersForCalendar("and user_userid="+CRM.GetContextInfo("user","user_userid"),_userObject.user_per_todo);
}else{
  _users=getUsersForCalendar("and 1=2",null)
}


//fix up data for clients that do not have pagination
if (!clientsupportsPagination)
  page=0;
  
if (!clientsupportsPagination)
  page=0;
 
//pipeline display data
var configSearchEntities=new String(GetWebConfigValue("SearchEntities"));
	if (isPortalRequest) {
		configSearchEntities = Defined(CurrentPortalCRMUser("acpu_searchentities")) ?  CurrentPortalCRMUser("acpu_searchentities") :  "";
	}
configSearchEntities=configSearchEntities.toLowerCase();
var sysUsesCases=configSearchEntities.indexOf("cases")>-1;

var casesdata=null;
var casesdataLabels=null;
var _case_permission=hasPermissionView("cases");
if (_case_permission && sysUsesCases)
{
	casesdata=getCasesData(userid);
	casesdataLabels=getCasesDataLabel();
}  
   
var res={
  "screenMetadata": {
	"page":"getCasesList",
	"filterscreen":_crmfilterscreen,
	"users":_users,
	"appuser":_userObject,
	"caseuser":_userObjectCalendar,
	"whereclause":__whereclause
  },
  "data": {
	"recordcount":recordcount,
	"entity":"cases",
	"sortBy":sortBy,
	"sortDesc":sortDesc,
	"page":page,
	"MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
    "searchstring":CRM.GetTrans("TabNames","cases")+" where "+__whereclause,
    "tableData": tableData,
    "tableColumns": tableColumns,
	"casestats":getPipelineStatsJSON(casesdata,casesdataLabels)	
  }
}
res=JSON.stringify(res);
Response.Write(res);
%>