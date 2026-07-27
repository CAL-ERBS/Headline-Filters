<!-- #include file ="sagecrm.js" -->

<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="createCompany.asp" -->
<!-- #include file ="createPerson.asp" -->
<!-- #include file ="createNamedEntity.asp" -->
<!-- #include file ="createCommunication.asp" -->
<!-- #include file ="SearchHistory.js" -->
<!-- #include file ="workflow.js" -->
<%
//this file is used to create "primary" entities only
function createProgressRecord(createRes,_entity,_data, wf)
{
	var _tableinfo=getTableInfo(_entity);
	var _newdata=[];
	var createResProgress=null;
	if ((_tableinfo.ProgressTableName)&&(_tableinfo.ProgressTableName!=null)&&(_tableinfo.ProgressTableName!=""))
	{
		for(var i=0;i<_data.length;i++)
		{
			var xfield=_data[i];
			var _isProgressField=queryCustomEditsByEntity(xfield.name,_tableinfo.ProgressTableName);			
			if (!_isProgressField.eof)
			{
				_newdata.push(xfield);
			}
		}		
		//add in ID field...eg Oppo_OpportunityId
		var _idfield={
			name:_tableinfo.idfield,
			value:createRes.entityid
		}
		_newdata.push(_idfield);
		createResProgress=createNamedEntity(_tableinfo.ProgressTableName,_newdata, null);
	}
	return createResProgress;
}

var thisdata=Request.Form('data');
var dataObj=JSON.parse(thisdata);

var emailentryid=new String(Request.Form('emailentryid'));	
var emailsubject=new String(Request.Form('emailsubject'));	

var _entity=new String(Request.Form('entity'));	
_entity=_entity.toLowerCase();

if (!Defined(_entity)&&(_entity!='appointment')&&(_entity!='appt')){
	var testtable=getTableInfo(_entity);
	if (!Defined(testtable.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
	  throw "No valid Entity found";
	}
}

var createRes={
  valid:false,
  entity:_entity,
  entityid:null
}

//workflow
var wf=getWorkflowObj(_entity);
  
if (_entity=="company")
{
  createRes=createCompany(dataObj,wf);
} else 
if (_entity=="person")
{
  createRes=createPersonRecord(dataObj,wf);
} else 
if ((_entity=="appt")||(_entity=="appointment"))
{
  dataObj.push({"name":"comm_type","value":"Appointment"});
  createRes=createCommunicationRecord(_entity,dataObj);
}else 
if (_entity=="communication")
{
  createRes=createCommunicationRecord(_entity,dataObj);
}else 
{
  var validRes=validateNamedEntity(_entity,dataObj, wf);
  if (validRes===true)
  {	
	createRes=createNamedEntity(_entity,dataObj, wf);
  }else{
    var resValidation={
	  "screenMetadata": {
		"page":"createEntity",
		"entity":_entity,
		"action":"ValidationError"
	  },
	  "data": validRes
	}
	Response.Clear();
	Response.Write(JSON.stringify(resValidation));
	Response.End()
  }
}

//------------------------------------------------------------------------------
updateEntityByFields(_entity, createRes.entityid); 
//------------------------------------------------------------------------------

//progress records now (if any)
createProgressRecord(createRes,_entity,dataObj, wf);

var res={
  "screenMetadata": {
	"page":"createEntity",
	"entity":_entity
  },
  "data": createRes
}

if ((createRes.entity!="communication")&&(createRes.entity!="users")&&(createRes.entity!="user"))
{
  var sHistoryObj=addToSearchHistory(createRes.entity,createRes.entityid);
  
  //update our link from this email to the entity-new to v6.0
  if (Defined(emailentryid) && checkTableExists("ctEntityLinks"))
  {
	var qctEntityLinks=CRM.CreateRecord("ctEntityLinks");
	qctEntityLinks("cten_entityname")=createRes.entity;	
	qctEntityLinks("cten_entityid")=createRes.entityid;	
	qctEntityLinks("cten_title")=sHistoryObj.sear_title;	
	qctEntityLinks("cten_userid")=getUserId();	
	qctEntityLinks("cten_outlooksubject")=emailsubject;		//max size is 255
	qctEntityLinks("cten_outlookEntryID")=emailentryid;	//link the entity to the email used to create it
	qctEntityLinks.SaveChanges();
  }  
}



var GLOBAL_TIMEEND = new Date().getTime();
res.screenMetadata.time = GLOBAL_TIMEEND - GLOBAL_TIMESTART;

res=JSON.stringify(res);
Response.Write(res);

%>