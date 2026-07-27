	<!-- #include file ="sagecrm.js" -->

<!-- #include file ="helpers.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="entrytype44.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="workflow.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="selectentity.js" -->
<%

function getCommRecord(viewtoUse, id, extendedfilter) {
    var tableinfo = getTableInfo("communication");
	var __whereclause="8481=8481 and " + tableinfo.idfield + "=" + id;
	if (extendedfilter)
		__whereclause+=" and "+extendedfilter;
    var res = CRM.FindRecord("communication,"+viewtoUse, __whereclause);
    return res;
}

	var isACMenuExtItem =false;
	var _workflowScreen = null;
	var _workFlowName = "";
	var _workFlowState = "";

var _entity=new String(Request.Querystring('entity'));
_entity=_entity.toLowerCase();
var _entitytable=getTableInfo(_entity);
if (!Defined(_entitytable.name)&&(_entity!='appointment')&&(_entity!='appt')){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
  throw "No valid Entity found";
}

var _entityid=new String(Request.Querystring('entityid'));
if (!isNumeric(_entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
  throw "No valid Entity ID found";
}

screenMetadata_entity=new String(Request.Form('screenMetadata_entity'));
if (Defined(screenMetadata_entity)&&(screenMetadata_entity!="")&&(screenMetadata_entity!="appointment")&&(screenMetadata_entity!="appt"))
{
	var screenMetadatatable=getTableInfo(screenMetadata_entity);
	if (!Defined(screenMetadatatable.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid screenMetadata_entity found, entity is "+Request.Form('screenMetadata_entity'));
	  throw "No valid screenMetadata_entity found";
	}
}
screenMetadata_entityid=new String(Request.Form('screenMetadata_entityid'));
if (Defined(screenMetadata_entityid)&&(screenMetadata_entityid!=""))
{
	if (!isNumeric(screenMetadata_entityid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid screenMetadata_entityid found, screenMetadata_entityid is "+Request.Form('screenMetadata_entityid'));
	  throw "No valid screenMetadata_entityid found";
	}
}

//context data? -EG when creating a case under a company
var contextEntity=null;
//this is our record!!!!!!
if ((_entity=="appt")||(_entity=="appointment")||(_entity=="communication"))
{
  contextEntity=getCommRecord("vlistCommunication", _entityid, "CmLi_Deleted is null");
}else{
  contextEntity=getEntityRecord(_entity, _entityid);
}

var useScreen = _entity+"officeintnew";	
	
	//check if this is a AcNewMenuExt call 
	var ACNewMenuExt = CRM.FindRecord("Custom_Tabs", "tabs_caption='"+_entity+"' AND Tabs_Entity ='ACNewMenuExt'");
	Glog("ACNewMenuExt:" + "tabs_caption='"+_entity+"' AND Tabs_Entity ='ACNewMenuExt'")
	if (!ACNewMenuExt.eof) {		
		var tabs_wheresql = ACNewMenuExt("tabs_wheresql").split("#"); //LegalCaseScreen#Legal Case#New Case#cases#red#mdi-cash-multiple
		useScreen = tabs_wheresql[0]; //TODO Check if this is valid screen 
		_workFlowName = tabs_wheresql[1];
		_workFlowState = tabs_wheresql[2];
		_entity = tabs_wheresql[3];		
		
		isACMenuExtItem = true;
	}
	// \end ACNewMenu 

	
	Glog("useScreen:" + useScreen);

//first screen
var _crmscreen= getNewScreen(_entity,useScreen,contextEntity,screenMetadata_entity,null,null,true);
_crmscreen.subheader="";
var _allscreens=[];

if ((_entity=="appt")||(_entity=="appointment"))
{
	//this can happen if apptofficeintnew does not exist..usually on a new appt
	_crmscreen=getDefaultNewApptScreen(true,contextEntity);
	
	var _tmpscreen= getNewScreen(_entity,"apptofficeintnew",contextEntity,screenMetadata_entity,null,null,true);
	if (_tmpscreen.formElements.length>1)
	{
		for(var tt=0;tt<_tmpscreen.formElements.length;tt++)
		{
		  if (_tmpscreen.formElements[tt].name.toLowerCase()=="cmli_comm_personid")
		  {
		    _tmpscreen.formElements[tt].filterObjectName="cmli_comm_companyid";//clever....default in metadata is cmli_comm_accountid
		  }
		}
	}	
	if (_tmpscreen.formElements.length>0)
	{
		_crmscreen.formElements=_crmscreen.formElements.concat(_tmpscreen.formElements);
	}
}else
if (_entity=="communication")
{
	//this can happen if communicationofficeintnew does not exist..usually on a new task
	_crmscreen=getDefaultNewTaskScreen(true,contextEntity);
	var _tmpscreen= getNewScreen(_entity,"communicationofficeintnew",contextEntity,screenMetadata_entity,null,null,true);
	if (_tmpscreen.formElements.length>0)
	{
		_crmscreen.formElements=_crmscreen.formElements.concat(_tmpscreen.formElements);
	}	
}
	
_allscreens.push(_crmscreen);

//entities like company/person have more than one form...address/phone/email etc
if (_entity=="company")
{
    var qaddress=CRM.FindRecord("address,vAddressCompany","Addr_AddressId="+contextEntity("Comp_PrimaryAddressId"));
	//address
	var _crmAddressscreen=getNewScreen("address","AddressOfficeInt",qaddress,null, null, null, true);
	_crmAddressscreen.subheadericon="mdi-map-marker";
	_allscreens.push(_crmAddressscreen);
	
	//phone
	var _crmPhonescreen=getPhoneScreen("company","comp",null,_entityid);
	_allscreens.push(_crmPhonescreen);
	
	//email
	var _crmEmailscreen=getEmailScreen("company","comp",null,_entityid);
	_allscreens.push(_crmEmailscreen);
	
} else if (_entity=="person")
{
	//phone
	var _crmPhonescreen=getPhoneScreen("person","pers",contextEntity, _entityid);
	_allscreens.push(_crmPhonescreen);
	
	//email
	var _crmEmailscreen=getEmailScreen("person","pers",contextEntity, _entityid);
	_allscreens.push(_crmEmailscreen);

	//address
    var qaddress=CRM.FindRecord("address,vAddressCompany","Addr_AddressId="+contextEntity("pers_PrimaryAddressId"));
	var _crmAddressscreen=getNewScreen("address","AddressOfficeInt",contextEntity);
	_crmAddressscreen.pickerurl=getCRMProtocol()+get_SERVER_NAME()
		+":"+get_SERVER_PORT()+
		CRM.Url("sagecrmws/ac2020/companyaddresses.asp");
	_crmAddressscreen.subheadericon="mdi-map-marker";
	_allscreens.push(_crmAddressscreen);	
}

//************************************************************
//set up...case_primarypersonid	and other SSA fields
	var assignObj={
		entity:screenMetadata_entity,
		entityid:screenMetadata_entityid
	}
	var assignmentObject=getAssignmentObject(assignObj,"", "");
	for(var oo=0;oo<_crmscreen.formElements.length;oo++)
	{
	  var _elmnt=_crmscreen.formElements[oo];
	  if ((_elmnt.name.toLowerCase()=="case_primarypersonid")||
	       (_elmnt.name.toLowerCase()=="oppo_primarypersonid"))
	  {
		if (assignmentObject.personid)
		{
			var tmpsearchObject={fieldname:"pers_personid",
				searchfilter:{entity:"person",entityid:assignmentObject.personid}};	
			Glog("getFormMetadata:person");	
			var es=doEntitySearch("person",tmpsearchObject,"","",1);
			Glog("getFormMetadata es.data.tableData.length:"+es.data.tableData.length);
			for(var i=0;i<es.data.tableData.length;i++)
			{
				var itemraw=es.data.tableData[i];
				var _displayText='';
				for(var x=1;x<es.data.tableColumns.length;x++)
				{
					var colname=es.data.tableColumns[x].value;
					if (_displayText!='')
						_displayText+=' ';
					_displayText+=itemraw[colname];
				}
				var xitem={
					text: _displayText, value:{entity: itemraw.entity, entityid: itemraw.entityid},icon: itemraw.tileicon 
				}
				if (_elmnt.options.length==0)
				{
					_elmnt.options.push(xitem);
					_elmnt.value=xitem;
				}
			}
			
		}
	  }else if ((_elmnt.name.toLowerCase()=="case_primarycompanyid")||
	       (_elmnt.name.toLowerCase()=="oppo_primarycompanyid"))
	  {
		if (assignmentObject.companyid)
		{
			var tmpsearchObject={fieldname:"comp_companyid",
				searchfilter:{entity:"company",entityid:assignmentObject.companyid}};	
			Glog("getFormMetadata #2: company");		
			var es=doEntitySearch("company",tmpsearchObject,"","",1);
			Glog("getFormMetadata #2 es.data.tableData.length:"+es.data.tableData.length);
			for(var i=0;i<es.data.tableData.length;i++)
			{
				var itemraw=es.data.tableData[i];
				var _displayText='';
				for(var x=1;x<es.data.tableColumns.length;x++)
				{
					var colname=es.data.tableColumns[x].value;
					if (_displayText!='')
						_displayText+=' ';
					_displayText+=itemraw[colname];
				}
				var xitem={
					text: _displayText, value:{entity: itemraw.entity, entityid: itemraw.entityid},icon: itemraw.tileicon 
				}
				Glog("getFormMetadata options #1 len:"+_elmnt.options.length);		
				Glog("getFormMetadata options push:"+_displayText);		
				if (_elmnt.options.length==0)
				{
					_elmnt.options.push(xitem);
					_elmnt.value=xitem;
				}
				Glog("getFormMetadata options #2 len:"+_elmnt.options.length);			
			}
		}
	  }
	}
//************************************************************


var resGFM={
  "screenMetadata": {
    "lang": getUserLang(),
	"page":"getFormMetadataEdit",
	"entity":_entity,
	"entityid":_entityid,
	"screens":_allscreens,
	"contextentity": "",
	"contextentityIcon": "",
	"contextentityIcon2": "",
	"contextentityIconColor": "",
	"contextentityIconColor2": "",
	"contextentityName": "",
	"contextentityName2": "",
	"contextentityName3": ""
  },
  "data": null
}

//extra context for comms
if ((_entity=="appt")||(_entity=="appointment")||(_entity=="communication"))
{
  var _contextselectentity="";
  var _contextselectentityid="";
  if(Defined(contextEntity("comm_leadid")))
  {
    _contextselectentity="lead";
	_contextselectentityid=contextEntity("comm_leadid");  
  }else    
  if(Defined(contextEntity("comm_caseid")))
  {
    _contextselectentity="case";
	_contextselectentityid=contextEntity("comm_caseid");  
  }else   
  if(Defined(contextEntity("comm_opportunityid")))
  {
    _contextselectentity="opportunity";
	_contextselectentityid=contextEntity("comm_opportunityid");  
  }else 
  if(Defined(contextEntity("cmli_comm_personid")))
  {
    _contextselectentity="person";
	_contextselectentityid=contextEntity("cmli_comm_personid");
  }else
  if(Defined(contextEntity("cmli_comm_companyid")))
  {
    _contextselectentity="company";
	_contextselectentityid=contextEntity("cmli_comm_companyid");
  }
  if (_contextselectentity!="")
  {
	//get the context info
	var table=getTableInfo(_contextselectentity);
	var tableNameView=getTableNameView(_contextselectentity);
	//get the data
	var q=CRM.Findrecord(tableNameView,"9059=9059 and "+table.idfield+"="+_contextselectentityid);
	var _selent=_selectEntity(_contextselectentity,_contextselectentityid,q, false, true);

	resGFM.screenMetadata.context={};
	resGFM.screenMetadata.context.screenMetadata={};
	resGFM.screenMetadata.context.screenMetadata.entity=_selent.screenMetadata.entity;
	resGFM.screenMetadata.context.screenMetadata.entityid=_selent.screenMetadata.entityid;
	resGFM.screenMetadata.context.screenMetadata.entityIcon=_selent.screenMetadata.entityIcon;
	resGFM.screenMetadata.context.screenMetadata.entityIcon2=_selent.screenMetadata.entityIcon2;
	resGFM.screenMetadata.context.screenMetadata.entityIconColor=_selent.screenMetadata.entityIconColor;
	resGFM.screenMetadata.context.screenMetadata.entityIconColor2=_selent.screenMetadata.entityIconColor2;
	resGFM.screenMetadata.context.screenMetadata.entityName=_selent.screenMetadata.entityName;
	resGFM.screenMetadata.context.screenMetadata.entityName2=_selent.screenMetadata.entityName2;
	//clever-for comms we need to check the value...lets not assume the person exists or is set as the primary
	if(Defined(contextEntity("cmli_comm_companyid")))
    {
	  if(!Defined(contextEntity("cmli_comm_personid"))){
		resGFM.screenMetadata.context.screenMetadata.entityName2="";
		resGFM.screenMetadata.context.screenMetadata.entityIcon2="";
      }	
	}
	resGFM.screenMetadata.context.screenMetadata.entityName3=_selent.screenMetadata.entityName3;
  }
}


//branding start
getBranding(resGFM.screenMetadata);
//branding end

resGFM=JSON.stringify(resGFM);
Response.Write(resGFM);
%>