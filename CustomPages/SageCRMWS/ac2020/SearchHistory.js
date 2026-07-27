<%
function addToSearchHistory(entity,entityid)
{
	entity=new String(entity);
	if (entity.toLowerCase()=="case")
		entity="cases";
	var ti=getTableInfo(entity);
	if (!ti.DescField)
		return;
	var uid=getUserId();
	
if (!isNumeric(uid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid User ID found, uid is "+uid);
  throw "No valid User ID found";
}
if (!isNumeric(entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+entityid);
  throw "No valid Entity ID found";
}
if (!Defined(ti.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+entity);
  throw "No valid Entity found";
}	
	var whereclause="7124=7124 and sear_userid=" + uid + " and sear_entityname='" + entity + "' and sear_entityid=" + entityid + " and sear_deleted is null " +
                    " and sear_updateddate> DATEADD(day, DATEDIFF(day, 0, getdate()), 0)";
	var searchon="SearchHistory";
	
	var histrec=CRM.FindRecord(searchon,whereclause);
					
	var ssasql="select "+ti.DescField+" from "+ti.searchView+" where "+ti.idfield+"="+entityid;

	var q1=CRM.CreateQueryObj(ssasql);
	q1.SelectSQL();
		
	if (histrec.eof)
	{
		histrec=CRM.CreateRecord("SearchHistory");
	}
	histrec("sear_userid")=uid;
	histrec("sear_entityname")=entity;
	histrec("sear_entityid")=entityid;
	var _desc=new String(ti.DescField);
	var _descarr=_desc.split(",");
	var _descvalue="";
	for (var x=0;x<_descarr.length;x++)
	{
		if (_descvalue!="")
			_descvalue+="-";
		_descvalue+=q1(_descarr[x]);
	}
	if (_descvalue.length>100)
	{
		_descvalue=_descvalue.substr(0, 99);
	}
	histrec("sear_title")=_descvalue;

	histrec.SaveChanges();

	updateEntityByFields("SearchHistory", histrec.RecordId);
		
	return {
		sear_userid:uid,
		sear_entityname:entity,
		sear_entityid:entityid,
		sear_title:_descvalue
	}
}

%>