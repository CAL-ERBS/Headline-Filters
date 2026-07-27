<!-- #include file ="sagecrm.js" -->

<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="createCompany.asp" -->
<!-- #include file ="createPerson.asp" -->
<!-- #include file ="createNamedEntity.asp" -->
<!-- #include file ="createCommunication.asp" -->
<%

//this file is used to UPDATE "primary" entities only
function createProgressRecord(createRes,_entity,_data)
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
		//add in case_progressnote
		var progressnote={
			name:_tableinfo.prefix+"_progressnote",
			value:createRes.log
		}
		_newdata.push(progressnote);
		
		createResProgress=createNamedEntity(_tableinfo.ProgressTableName,_newdata, null);
	}else{
	  //create communication????
	  
	}
	return createResProgress;
}

var thisdata=Request.Form('data');
var dataObj=JSON.parse(thisdata);

var _entity=new String(Request.Form('entity'));	
if ((_entity!="appointment")&&(_entity!="appt")){
	_entity=_entity.toLowerCase();
	var testtable=getTableInfo(_entity);
	if (!Defined(testtable.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
	  throw "No valid Entity found";
	}
}

var _entityid=new Number(Request.Form('entityid'));	
if (!isNumeric(_entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
  throw "No valid Entity ID found";
}
//update/create phone and email  - costi 28th June, 2022
//not sure if should this to it's own function

for(var i=0; i< dataObj.length;i++) {
	if (dataObj[i].name.indexOf("phonefield_") == 0) {

		if (!Defined(dataObj[i].value.recordId)  || dataObj[i].value.recordId == "" ) {

			if (dataObj[i].value.phonenumber_value != "" ) {		
				//create phone and phone link 
				var newPhoneRecord = CRM.CreateRecord("Phone");
				newPhoneRecord("phon_number") = dataObj[i].value.phonenumber_value;
				newPhoneRecord("phon_areacode") = dataObj[i].value.areacode_value;
				newPhoneRecord("phon_countrycode") = dataObj[i].value.countrycode_value;
				newPhoneRecord.SaveChangesNoTls();
		
				var newPhoneLinkRecord = CRM.CreateRecord("PhoneLink");
				newPhoneLinkRecord("PLink_PhoneId") = newPhoneRecord.RecordId;
				newPhoneLinkRecord("PLink_EntityId") = _entity == "company" ? 5 :13; 
				newPhoneLinkRecord("PLink_RecordId") = _entityid;
				newPhoneLinkRecord("PLink_Type") = dataObj[i].value.type;
				newPhoneLinkRecord.SaveChangesNoTls();
			}

		} else {
			//UPDATE PHONE
			var sqlUpdatePhone = "UPDATE TOP(1) Phone SET phon_areacode='" + (dataObj[i].value.areacode_value || "") + "', phon_number='"+ (dataObj[i].value.phonenumber_value || "") 
					+ "',phon_countrycode='" + (dataObj[i].value.countrycode_value || "")  + "'" + 
					"  WHERE phon_deleted IS NULL AND phon_phoneid=" + dataObj[i].value.recordId;
			var myQuery = CRM.CreateQueryObj(sqlUpdatePhone);
			try {
				myResult = myQuery.ExecSql();
			} catch(Exception) {
				Response.Write(sqlUpdatePhone);
				Response.End();
			}
		}
	} else if (dataObj[i].name.indexOf("emailfield_") == 0) { 
	
		if (!Defined(dataObj[i].value.recordId) || dataObj[i].value.recordId == "")  {

			if (dataObj[i].value.emailaddress != "" ) {
				var newEmailRecord = CRM.CreateRecord("Email");
				newEmailRecord("emai_emailaddress") = dataObj[i].value.emailaddress;
				newEmailRecord.SaveChangesNoTls();
		
				var newEmailLinkRecord = CRM.CreateRecord("EmailLink");
				newEmailLinkRecord("ELink_EmailId") = newEmailRecord.RecordId;
				newEmailLinkRecord("ELink_EntityId") = _entity == "company" ? 5 :13; 
				newEmailLinkRecord("ELink_RecordId") = _entityid;
				newEmailLinkRecord("ELink_Type") = dataObj[i].value.type;
				newEmailLinkRecord.SaveChangesNoTls();
			}
			
		} else {
			//UPDATE EMAIL
			var sqlUpdateRecord = "UPDATE TOP(1) Email SET emai_emailaddress='" + dataObj[i].value.emailaddress+ "' WHERE emai_deleted IS NULL AND emai_emailid=" + dataObj[i].value.recordId;
			var myQuery = CRM.CreateQueryObj(sqlUpdateRecord);
			try {
				myResult = myQuery.ExecSql();
			} catch(Exception) {
				Response.Write(sqlUpdateRecord);
				Response.End();
			}
		}
	}
}

//---end update phone email 

var updateRes={
  valid:false,
  entity:_entity,
  entityid:_entityid
}

var _updatemethod="";
 
if (_entity=="company")
{
  updateRes=updateCompanyRecord(_entityid,dataObj);
  _updatemethod="updateCompanyRecord";
} else 
if (_entity=="person")
{
  updateRes=updatePersonRecord(_entityid,dataObj);
  _updatemethod="updatePersonRecord";
}else 
if ((_entity=="appt")||(_entity=="appointment")||(_entity=="communication")) 
{
  updateRes=updateCommunicationRecord(_entityid,dataObj);
  _updatemethod="updateCommunicationRecord";
}else 
{
  var validRes=validateNamedEntity(_entity,dataObj);
  if (validRes===true)
  {	
	updateRes=updateNamedEntity(_entity,_entityid,dataObj);
	_updatemethod="updateNamedEntity";
  }else{
    var resValidation={
	  "screenMetadata": {
		"page":"updateEntity",
		"entity":_entity,
		"action":"ValidationError"
	  },
	  "data": validRes
	}
	resValidation=JSON.stringify(resValidation);
	Response.Write(resValidation);
	Response.End()
  }
}


//------------------------------------------------------------------------------
updateEntityByFields(_entity, updateRes.entityid); 
//------------------------------------------------------------------------------

//progress records now (if any)
createProgressRecord(updateRes,_entity,dataObj);

var res={
  "screenMetadata": {
	"page":"updateEntity",
	"entity":_entity,
	"updatemethod":_updatemethod
  },
  "data": updateRes
}

res=JSON.stringify(res);
Response.Write(res);

%>