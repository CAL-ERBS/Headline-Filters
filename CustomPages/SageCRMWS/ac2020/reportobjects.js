<!-- #include file ="sagecrm.js" -->
<!-- #include file ="json2.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="configreader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="SearchHistory.js" -->
<!-- #include file ="getFormMetadata.js" -->
<%
//File: reportobjects.js

if (typeof JSON.clone !== "function") {
    JSON.clone = function(obj) {
        return JSON.parse(JSON.stringify(obj));
    };
}

var _reportClass={
			"name": "",
			"title":"report title",
			"reportapiversion":"1.0.0.0",
			"type":"report",
			"reportheader": [],
			"reportfooter": [],
			"reportdetails":[]
		}
		
//componenttype		=chart, screen, list
//type = //doughnut-chart
var _reportItem={
  'name':'',
  'componenttype':''
}	

function _getCompanyName(id)
{
	var _res="";

	if (id)
	{
		var _x=CRM.CreateQueryObj("select comp_name from company where comp_companyid="+id);
		_x.SelectSQL();
		if (!_x.eof)
		{
			_res=_x("comp_name");
		}
	}
	return _res;
}

function _getPersonName(id)
{
	var _res="";

	if (id)
	{
		var _x=CRM.CreateQueryObj("select pers_fullname from vsummaryperson where pers_personid="+id);
		_x.SelectSQL();
		if (!_x.eof)
		{
			_res=_x("pers_fullname");
		}
	}
	return _res;
}
function _getOppoName(id)
{
	var _res="";

	if (id)
	{
		var _x=CRM.CreateQueryObj("select oppo_description from opportunity where oppo_opportunityid="+id);
		_x.SelectSQL();
		if (!_x.eof)
		{
			_res=_x("oppo_description");
		}
	}
	return _res;
}
function _getCaseName(id)
{
	var _res="";

	if (id)
	{
		var _x=CRM.CreateQueryObj("select case_referenceid+' '+case_description as case_description from cases where case_caseid="+id);
		_x.SelectSQL();
		if (!_x.eof)
		{
			_res=_x("case_description");
		}
	}
	return _res;
}

function getListSection(q, param_entity, fields, showInternalLink, ListTitle)
{
	var NumberOfRecordsReturned=0;
	var _tableinfo=getTableInfo(param_entity);
	var recordcount=q.recordcount;
	var tableData=[];
	var rowCount=0;
	var startFrom=1;
	if (!ListTitle)
		ListTitle="";
	if (!showInternalLink)
		showInternalLink=false;
	while(!q.eof)
	{
		rowCount++;
		var _tmpobj={
			"count":rowCount,
			"entityid": q(_tableinfo.idfield),
			"entity":param_entity,
			"tilecolor":getTileColour(param_entity),
			"tileicon": getEntityIcon(param_entity),
			"hasInternalLink":showInternalLink,
			"loadfielddatalinks":[]
		}  		
		for(var c=0;c<fields.length;c++)
		{
			_tmpobj[fields[c]]=q(fields[c]);
		}	
		tableData.push(_tmpobj); 
		q.NextRecord();
	}	
	var tableColumns=[];
	if (showInternalLink)
	{
		tableColumns.push({
			"value": "__Select__",
			"text": "",
			"sortable":false
		  });
	}
	for(var c=0;c<fields.length;c++)
	{
	  tableColumns.push({
			"value": fields[c],
			"text": CRM.GetTrans("colNames",fields[c])
		  });
	}
	var res={
		"recordcount":recordcount,
		"Entity":param_entity,
		"sortBy":"",
		"sortDesc":"",	
		"hasInternalLink":showInternalLink,
		"linked":showInternalLink,
		"title":ListTitle,
		"slimversion":false,
		//"page":-1,..we dont set this as it shows the scroll section and we dont want that
		"parentEntity":"company",
		"parentEntityId":"313",
		"MaxNumberOfRecordsReturned":recordcount,
		"searchstring":"getListSection",
		"tableData": tableData,
		"tableColumns": tableColumns
	}
	return res;
}


function getListSectionRel(q, entity, param_entity, fields, showInternalLink, ListTitle)
{
	var NumberOfRecordsReturned=0;
	var _tableinfo=getTableInfo(param_entity);
	var recordcount=q.recordcount;
	var tableData=[];
	var rowCount=0;
	var startFrom=1;
	if (!ListTitle)
		ListTitle="";
	if (!showInternalLink)
		showInternalLink=false;
	
var _fCompany={
                name: "comp_id",
                componentType: getComponentType(56),
                lookup: "company",
                viewfields: "comp_name"
            };
			
	while(!q.eof)
	{
		var rend_Entity2=q("rend_Entity2");
		if (rend_Entity2.toLowerCase()=="case")
			rend_Entity2="Cases";
		rowCount++;
		var _tmpobj={
			"count":rowCount,
			"entityid": q("rend_Entity2Id"),
			"entity":rend_Entity2,
			"tilecolor":getTileColour(q("rend_Entity2")),
			"tileicon": getEntityIcon(q("rend_Entity2")),
			"hasInternalLink":showInternalLink,
			"loadfielddatalinks":[]
		}  		
		for(var c=0;c<fields.length;c++)
		{
			if (fields[c]=="rend_Entity2")
			{
				if (q(fields[c])=="Company")
				{
				  _tmpobj[fields[c]] =_getCompanyName(q("rend_Entity2Id"))
				}else if (q(fields[c])=="Person")
				{
				  _tmpobj[fields[c]] =_getPersonName(q("rend_Entity2Id"))
				}else if (q(fields[c])=="Opportunity")
				{
				  _tmpobj[fields[c]] =_getOppoName(q("rend_Entity2Id"))
				}else if (q(fields[c])=="Case")
				{
				  _tmpobj[fields[c]] =_getCaseName(q("rend_Entity2Id"))
				}
					
			}else
			if (fields[c]=="rend_relationship")
				_tmpobj[fields[c]]=CRM.GetTrans("RelatedEntityLink",q(fields[c]));
			else
			if (fields[c]=="rend_Type")
			_tmpobj[fields[c]]=CRM.GetTrans("rend_Type",q(fields[c]));
				else
			_tmpobj[fields[c]]=q(fields[c]);
		}	
		tableData.push(_tmpobj); 
		q.NextRecord();
	}	
	var tableColumns=[];
	if (showInternalLink)
	{
		tableColumns.push({
			"value": "__Select__",
			"text": "",
			"sortable":false
		  });
	}
	for(var c=0;c<fields.length;c++)
	{
		if (fields[c]=="rend_Entity2")
			tableColumns.push({
				"value": fields[c],
				"text": CRM.GetTrans("colNames","Entity")
			  });			
		else
			tableColumns.push({
				"value": fields[c],
				"text": CRM.GetTrans("colNames",fields[c])
			  });
	}
	var res={
		"recordcount":recordcount,
		"Entity":param_entity,
		"sortBy":"",
		"sortDesc":"",	
		"hasInternalLink":showInternalLink,
		"linked":showInternalLink,
		"title":ListTitle,
		"slimversion":false,
		//"page":-1,..we dont set this as it shows the scroll section and we dont want that
		"parentEntity":"company",
		"parentEntityId":"313",
		"MaxNumberOfRecordsReturned":recordcount,
		"searchstring":"getListSection",
		"tableData": tableData,
		"tableColumns": tableColumns
	}
	return res;
}

%>