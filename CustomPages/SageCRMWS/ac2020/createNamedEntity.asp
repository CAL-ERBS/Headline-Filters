<%
var G_Values=null;
function ExtractNumbersAndDecimals(inputString) {
	//function that extracts only numbers and decimals from a given string:
	if (!Defined(inputString))
	  return inputString;	
	inputString=new String(inputString);
    // Use a regular expression to match only digits and decimal points
    var cleanedString = inputString.replace(/[^0-9.]/g, ''); // Remove all non-digit and non-decimal characters
    cleanedString = cleanedString.replace(/,/g, ''); // Remove any commas
    return cleanedString;
}
//called from Validate scripts
function Values(fieldName)
{
  var res="";
  for(var i=0;i<G_Values.length;i++)
  {
	var xfield=G_Values[i];
	if (xfield.name.toLowerCase()==fieldName.toLowerCase())
	{
	  res=xfield.value;
	  break;
	}
  }
  return res;
}
function getScreenFieldsForValidation(entity, screenName)
{
	var res=[];
	var sql="select SeaP_ColName, SeaP_Order,SeaP_Jump, SeaP_Required,SeaP_CreateScript, Colp_Restricted,"+
		"ColP_EntryType,ColP_DefaultValue,ColP_EntrySize,ColP_LookupFamily,ColP_LookupWidth, "+
		"ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, Colp_ssViewField, ColP_LinkedField  "+
		",ColP_DefaultType,Colp_SearchSQL,SeaP_OnChangeScript,SeaP_ValidateScript from Custom_Screens "+
		"left join Custom_Edits on SeaP_ColName=ColP_ColName "+
		"where SeaP_SearchBoxName= '"+screenName+"' and ColP_Entity='"+entity+"' "+
		"and SeaP_ColName<>'comm_secterr' "+
		"and Seap_DeviceID is null and ColP_Deleted is null and SeaP_Deleted is null "+
		"order by SeaP_Order";
	var q=CRM.CreateQueryObj(sql);
	q.SelectSQL();
	while(!q.eof)
	{
		var formelm= JSON.clone(_MyFormElement);
		formelm.name=q("SeaP_ColName");
		formelm.SeaP_ValidateScript=q("SeaP_ValidateScript");
		res.push(formelm);
		q.NextRecord();
	}
	return res;
}
function validateNamedEntity(_entity, _data, wf)
{
  G_Values=_data;
  //get any screen and validatescript
  var xfieldScreen=_data[_data.length-1];
  var _screenName="";
  for(var i=0;i<_data.length;i++)
  { 
	var xfieldScreen=_data[i];  
	if (xfieldScreen.name=="__screenName")
	{
	  _screenName=xfieldScreen.value;
	}
  }
  var _newscreen=getScreenFieldsForValidation(_entity, _screenName);
  for(var i=0;i<_newscreen.length;i++)
  {  
	var xfield=_newscreen[i];
	var _validateScript= xfield.SeaP_ValidateScript != null ? new String(xfield.SeaP_ValidateScript) : "";
	var Valid=true;
	var ErrorStr="";
	try{
		_validateScript = _validateScript.replace(/CRM.GetContextInfo/ig, "GetContextInfo");
        _validateScript = _validateScript.replace(/eWare.GetContextInfo/ig, "GetContextInfo");
		eval(_validateScript);
		xfield.serverValid=Valid;
		xfield.serverValidationMessage=ErrorStr;
		if (xfield.serverValid===false)
		  return xfield;
	}catch(e){
		//ignore
		xfield.errormessage=e.message;
	}	
  }
  return true;
}

function createNamedEntity(_entity, _data, wf)
{
  Glog("createNamedEntity:"+_entity);
  var qCreate=CRM.CreateRecord(_entity);
  
  var tableObj=getTableInfo(_entity);
  if (tableObj.appFlagField!="")
  {
	qCreate(tableObj.appFlagField)="Accelerator";
  }  
  
  var _dsrec={}
  for(var i=0;i<_data.length;i++)
  {
	var xfield=_data[i];
	if (xfield.name=="__screenName")
	{
		//ignore...
	}else
	if (xfield.name=="workflow")
	{
		var wfobj=getWorkflowById(xfield.value);
		wf.workflow=wfobj.work_description;
		wf.workflowstate=wfobj.wkst_name;
        //option to hard code this in the config
		var _WFState=GetWebConfigValue(wf.workflow + "_WFState");
		if ((_WFState!=null)&&(_WFState!=''))
		{
			Glog("_WFState found:"+wf.workflow + "_WFState");
		    wf.workflowstate=_WFState;
		}
	}else{
		var _elmntquery=queryCustomEdits(xfield.name);
		var _fieldcomponentType="";
		if (!_elmntquery.eof)
		  _fieldcomponentType=getComponentType(_elmntquery("ColP_EntryType"));
		var _x2field={
			"name":xfield.name,
			"componentType":_fieldcomponentType,
			value:xfield.value
		}
		if (_fieldcomponentType=="MyFormDateTime" || _fieldcomponentType=="MyFormDate") {

			var _tmpdtValue=createDateFromParts(_x2field.value);
			//Response.Write("1:"+_tmpdtValue);
			_tmpdtValue=adjustUserDateToServerDate(_tmpdtValue);
			//Response.Write("1:"+_tmpdtValue);
			//Response.End();
		
			_x2field.value.date=_tmpdtValue.getFullYear()+"-"+padDate(_tmpdtValue.getMonth()+1)+"-"+padDate(_tmpdtValue.getDate());
			_x2field.value.time=padDate(_tmpdtValue.getHours())+":"+padDate(_tmpdtValue.getMinutes());
		
			var xccal=getCreateFieldValue(_x2field);		
			_dsrec[_x2field.name]=_x2field.value;
			if (xccal!=null && !isNaN(xccal))
			{
				Glog(_x2field.name+"="+xccal);
				qCreate(_x2field.name)=xccal;
			}		
		}else	
		if (((_x2field.value)&&(_x2field.value.currency))||_fieldcomponentType=="MyFormCurrency")
		{
			if (_x2field.value && _x2field.value.currency && _x2field.value.amount){
				qCreate(_x2field.name+"_cid")=_x2field.value.currency;	
				qCreate(_x2field.name)=ExtractNumbersAndDecimals(_x2field.value.amount);	
				_dsrec[_x2field.name+"_cid"]=_x2field.value.currency;
				_dsrec[_x2field.name]=ExtractNumbersAndDecimals(_x2field.value.amount);		
			}		
		}else{
			Glog(_x2field.name+" was="+JSON.stringify(_x2field.value));
			var xccal=getCreateFieldValue(_x2field);		
			_dsrec[_x2field.name]=_x2field.value;
			if (xccal!=null)
			{
				Glog(_x2field.name+"="+xccal);
				qCreate(_x2field.name)=xccal;
			}
		}
	}
  }

  if ((wf)&&(wf.workflow!=null)&&(wf.workflowstate!=null))
  {
    qCreate.setWorkFlowInfo(wf.workflow, wf.workflowstate);
  }


	setDefaultTerritory(_entity, qCreate);

	
  try{
	qCreate.SaveChanges();
  }catch(e) {
	SendError("createNamedEntity", _entity, e.message);
  }


  updateEntityByFields(_entity, qCreate.RecordId);
  _rec_res = {
	  entity:_entity,
	  entityid:qCreate.RecordId,
	  data:_dsrec
  }

  if ((wf)&&(wf.workflow!=null)&&(wf.workflowstate!=null))
  {
	_rec_res.workflow=wf.workflow;
	_rec_res.workflowstate=wf.workflowstate;
  }
  
  return _rec_res;
}

function updateNamedEntity(_entity, _entityid, _data)
{
  var tb=getTableInfo(_entity);
  var q=CRM.FindRecord(_entity," 33654=33654 and "+tb.idfield+"="+_entityid);
  var _dsrec={}  
  var changelog="";
  var changeArr=[];
  for(var i=0;i<_data.length;i++)
  {
	var xfield=_data[i];	
	var _elmntquery=queryCustomEdits(xfield.name);
	var _fieldcomponentType="";
	if (!_elmntquery.eof)
  	  _fieldcomponentType=getComponentType(_elmntquery("ColP_EntryType"));
	var _x2field={
		"name":xfield.name,
		"componentType":_fieldcomponentType,
		value:xfield.value
	}
	var changeobj=null;
	if (_fieldcomponentType=="MyFormDateTime") {

		var _tmpdtValue=createDateFromParts(_x2field.value);
		_tmpdtValue=adjustUserDateToServerDate(_tmpdtValue,-1);
		
		_x2field.value.date=_tmpdtValue.getFullYear()+"-"+padDate(_tmpdtValue.getMonth()+1)+"-"+padDate(_tmpdtValue.getDate());
		_x2field.value.time=padDate(_tmpdtValue.getHours())+":"+padDate(_tmpdtValue.getMinutes());
		
		var xccal=getCreateFieldValue(_x2field);		
		_dsrec[_x2field.name]=_x2field.value;
		if (xccal!=null)
		{
			Glog(_x2field.name+"="+xccal);
			q(_x2field.name)=xccal;
		}
	}
	else if (_fieldcomponentType=="MyFormDate")
	{
		var _tmpdtValue=createDateFromParts(_x2field.value);
		_tmpdtValue=adjustUserDate(_tmpdtValue,-1);
		_x2field.value.date=_tmpdtValue.getFullYear()+"-"+padDate(_tmpdtValue.getMonths()+1)+"-"+padDate(_tmpdtValue.getDate());
		
		var xccal=getCreateFieldValue(_x2field);		
		_dsrec[_x2field.name]=_x2field.value;
		if (xccal!=null)
		{
			Glog(_x2field.name+"="+xccal);
			q(_x2field.name)=xccal;
		}			
	}else		
	if (((_x2field.value)&&(_x2field.value.currency))||_fieldcomponentType=="MyFormCurrency")
	{
		if (_x2field.value && _x2field.value.currency && _x2field.value.amount){
			changeobj={
					"name":_x2field.name+"_cid",
					"originalvalue":q(_x2field.name+"_cid"),
					"newvalue":_x2field.value.currency
			}	
			q(_x2field.name+"_cid")=_x2field.value.currency;	
			if (getDifference(changeobj.originalvalue,changeobj.newvalue)!="")
				changeArr.push(changeobj);		
			changeobj={
					"name":xfield.name,
					"originalvalue":q(xfield.name),
					"newvalue":_x2field.value.amount
			}		
			if (getDifference(changeobj.originalvalue,changeobj.newvalue)!="")
				changeArr.push(changeobj);		
			q(_x2field.name)=_x2field.value.amount;	
			_dsrec[_x2field.name+"_cid"]=_x2field.value.currency.value;
			_dsrec[_x2field.name]=_x2field.value.amount;	
		}
	}else{
		var xccal=getCreateFieldValue(_x2field);
		_dsrec[_x2field.name]=xccal;
		if (xccal!=null)
		{
			Glog(_x2field.name+"="+xccal);
			changeobj={
					"name":xfield.name,
					"originalvalue":q(xfield.name),
					"newvalue":_dsrec[_x2field.name]
			}	
			if (_x2field.componentType=="MyFormDateTime")
			{
				changeobj={
						"name":xfield.name,
						"originalvalue":(new String(new Date(q(xfield.name)).getVarDate())),
						"newvalue":(new String(_dsrec[xfield.name]))
				}	
			}
			if (getDifference(changeobj.originalvalue,changeobj.newvalue)!="")
			{
			  changeArr.push(changeobj);	
			}
			q(_x2field.name)=xccal;				
		}	
	}
  }
  try{
	//q.SaveChangesNoTLS();
	q.SaveChanges();
  }catch(e){
    Response.Write("ERROR: "+e.message);
  }
  
  if (changeArr.length>0)
    changelog=JSON.stringify(changeArr);
  
  updateEntityByFields(_entity, _entityid);

  _rec_res = {
	  entity:_entity,
	  entityid:_entityid,
	  data:_dsrec,
	  log: changelog
  }  
  return _rec_res;  
}


%>