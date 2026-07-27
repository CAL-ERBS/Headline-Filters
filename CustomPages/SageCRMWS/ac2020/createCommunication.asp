<%

function checkCommFieldExists(obj, fieldname)
{
  var res=false;
  for(var i=0;i<obj.length;i++)
  {
	var xfield=obj[i];
	var xfieldName=new String(xfield.name);
	xfieldName=new String(xfieldName);
	if(xfieldName.toLowerCase()==fieldname.toLowerCase())
	{
		res=true;
	}
  }
  return res;
}

function getCommField(obj, fieldname)
{
  var res=false;
  for(var i=0;i<obj.length;i++)
  {
	var xfield=obj[i];
	var xfieldName=new String(xfield.name);
	xfieldName=new String(xfieldName);
	if(xfieldName.toLowerCase()==fieldname.toLowerCase())
	{
		res=xfield;
		break;
	}
  }
  return res;
}
function createCommunicationRecord(_entity,dataObj)
{
	var contextentity=new String(Request.Form('contextentity'));	
	var contextentityid=new String(Request.Form('contextentityid'));
	var actiondatetime=new String(Request.Form('actiondatetime'));

	var assignObj={
		entity:contextentity,
		entityid:contextentityid
	}
	
	var isAppointment = false;
	if ((_entity=="appt")||(_entity=="appointment"))
		isAppointment = true;
		
	////clever...lets check to see if we have a different one in the context?
	cmli_comm_personid_exists=checkCommFieldExists(dataObj,"cmli_comm_personid");
	cmli_comm_companyid_exists=checkCommFieldExists(dataObj,"cmli_comm_companyid");
	if (cmli_comm_personid_exists){
		contextentity="person";
		contextentityid=getCommField(dataObj,"cmli_comm_personid").value		
	}else if (cmli_comm_companyid_exists){
		contextentity="company";
		contextentityid=getCommField(dataObj,"cmli_comm_companyid").value		
	}

	var assignmentObject=getAssignmentObject(assignObj,contextentity, contextentityid);
	//comm_datetime etc if not there already
	var comm_datetime_exists=checkCommFieldExists(dataObj,"comm_datetime");
	if (!comm_datetime_exists)
	{
		var now=new String(actiondatetime);//actiondatetime=2021-9-12 10:10
		var nowarr=now.split(" ");
		var nowarrdate=nowarr[0].split("-");
		var _m=new Number(nowarrdate[1]);
		_m++;//something broke..quick fix
		dataObj.push({"name":"comm_datetime","value":{date:nowarrdate[0]+"-"+_m+"-"+nowarrdate[2],time:nowarr[1]}});
	}
	//comm_status etc if not there already
	var comm_status_exists=checkCommFieldExists(dataObj,"comm_status");
	if (!comm_status_exists)
	{
		dataObj.push({"name":"comm_status","value":GetWebConfigValue("comm_status")});
	}
	//comm_status etc if not there already
	var comm_priority_exists=checkCommFieldExists(dataObj,"comm_priority");
	if (!comm_priority_exists)
	{
		dataObj.push({"name":"comm_priority","value":GetWebConfigValue("comm_priority")});
	}	
	//territory
	var comm_secterr_exists=checkCommFieldExists(dataObj,"comm_secterr");
	if (!comm_secterr_exists)
	{
		var comm_secterr_value="";
		if (GetWebConfigValue("UseUsersTerritory")!="Y")
		{
			comm_secterr_value=assignmentObject.territory;
		}else{
			comm_secterr_value=getUser_PrimaryTerritory();
		}
		dataObj.push({"name":"comm_secterr","value":comm_secterr_value});
	}		
	var comm_type_exists=checkCommFieldExists(dataObj,"comm_type");
	if (!comm_type_exists)
	{
		dataObj.push({"name":"comm_type","value":"Task"});
	}	
	var comm_channelid_exists=checkCommFieldExists(dataObj,"comm_channelid");
	if (!comm_channelid_exists)
	{
		dataObj.push({"name":"comm_channelid","value":getUser_PrimaryChannelId()});
	}		
	//set comm_description if subject is set
	var _comm_description=checkCommFieldExists(dataObj,"comm_description");
	if (!_comm_description)
	{
		var _comm_subject=checkCommFieldExists(dataObj,"comm_subject");
		if (_comm_subject)		
		  dataObj.push({"name":"comm_description","value":getCommField(dataObj,"comm_subject").value});
	}
	
	dataObjcmli=[];
	//remove any commlink items...
	for (var i = dataObj.length - 1; i >= 0; --i) {
		if (dataObj[i].name.toLowerCase().indexOf("cmli_")==0) {
		    if (dataObj[i].name.toLowerCase().indexOf("cmli_comm_userid")==0)
			{
				dataObjcmli.push(dataObj[i]);
			}
			dataObj.splice(i,1);
		}
	}
	
	//Create the comm link
	if (dataObjcmli.length==0)
	{	
	
	    if (isAppointment)
		  _entity="communication";
		var commRes=createNamedEntity(_entity,dataObj);
		//update with the contextentity
		var contextfield=getCommContextField(contextentity);
		contextentityid=new String(contextentityid);
		contextentityid+="";
		if (Defined(contextentityid)&&(contextfield!="")&&(contextentityid!=null)&&(contextentityid.length>0))
		{
			if (!isNaN(contextentityid)){
				var usql="update communication "+
					"set "+contextfield+"="+contextentityid+
					" where 8231=8231 and comm_communicationid="+commRes.entityid;
				CRM.ExecSQL(usql);
			}
		}	
		//single record
		var RecordComm_Link = CRM.CreateRecord("Comm_Link"); 
  
		var tableObj=getTableInfo("Comm_Link");
		if (tableObj.appFlagField!="")
		{
			RecordComm_Link(tableObj.appFlagField)="Accelerator";
		}  
    
		RecordComm_Link.CmLi_Comm_CommunicationId=commRes.entityid;
		RecordComm_Link.CmLi_Comm_UserId=getUserId(); 
		//person and company
		RecordComm_Link.CmLi_Comm_PersonId=assignmentObject.personid; 
		RecordComm_Link.cmli_comm_companyid=assignmentObject.companyid; 
		//lead commlink field
		if (contextfield=="comm_leadid")
		  RecordComm_Link.cmli_comm_leadid=contextentityid; 
				
	//START 13 Feb 25-update to cope with reminders in tasks
		if (commRes.data["comm_taskreminder"]==true)
			RecordComm_Link.CmLi_Comm_NotifyTime=(new Date()).getVarDate(); 

		if (Defined(commRes.data["comm_notifytime"])){
			var _comm_notifytime=queryCustomEdits("comm_notifytime");
			var _fieldcomponentType="";
			if (!_comm_notifytime.eof)
			  _fieldcomponentType_comm_notifytime=getComponentType(_comm_notifytime("ColP_EntryType"));
			var __comm_notifytimefield={
				"name":"comm_notifytime",
				"componentType":_fieldcomponentType_comm_notifytime,
				value:commRes.data["comm_notifytime"]
			}
			RecordComm_Link.CmLi_Comm_NotifyTime=getCreateFieldValue(__comm_notifytimefield);
		}				
		//END 13 Feb 25-update to cope with reminders	
				
		RecordComm_Link.SaveChanges();

		updateEntityByFields("Comm_Link", RecordComm_Link.RecordId);

	}else{
		//enumerate the users...and create a link record
		var commRes=null
		if (isAppointment){
			_entity="communication";
			commRes=createNamedEntity(_entity,dataObj);
		}
		for(var jj=0;jj<dataObjcmli[0].value.length;jj++)
		{
			if (!isAppointment){
				commRes=createNamedEntity(_entity,dataObj);
			}
			//update with the contextentity
			var contextfield=getCommContextField(contextentity);
			if (contextfield!="")
			{
				var usql="update communication "+
						"set "+contextfield+"="+contextentityid+
						" where comm_communicationid="+commRes.entityid;
				CRM.ExecSQL(usql);
			}		
			var RecordComm_Link = CRM.CreateRecord("Comm_Link"); 
			RecordComm_Link.CmLi_Comm_CommunicationId=commRes.entityid;
			var cmlifield=dataObjcmli[0].value[jj];
			RecordComm_Link.CmLi_Comm_UserId=cmlifield.value; 
			//person and company
			RecordComm_Link.CmLi_Comm_PersonId=assignmentObject.personid; 
			RecordComm_Link.cmli_comm_companyid=assignmentObject.companyid; 			
			if (contextfield=="comm_leadid")
			  RecordComm_Link.cmli_comm_leadid=contextentityid; 
			  
			var tableObj=getTableInfo("Comm_Link");
			if (tableObj.appFlagField!="")
			{
				RecordComm_Link(tableObj.appFlagField)="Accelerator";
			}  			  
			//START 13 Feb 25-update to cope with reminders in tasks
			if (commRes.data["comm_taskreminder"]==true)
				RecordComm_Link.CmLi_Comm_NotifyTime=(new Date()).getVarDate(); 
	
			if (Defined(commRes.data["comm_notifytime"])){
				var _comm_notifytime=queryCustomEdits("comm_notifytime");
				var _fieldcomponentType="";
				if (!_comm_notifytime.eof)
				  _fieldcomponentType_comm_notifytime=getComponentType(_comm_notifytime("ColP_EntryType"));
				var __comm_notifytimefield={
					"name":"comm_notifytime",
					"componentType":_fieldcomponentType_comm_notifytime,
					value:commRes.data["comm_notifytime"]
				}
				RecordComm_Link.CmLi_Comm_NotifyTime=getCreateFieldValue(__comm_notifytimefield);
			}				
			//END 13 Feb 25-update to cope with reminders

			RecordComm_Link.SaveChanges();			
			updateEntityByFields("Comm_Link", RecordComm_Link.RecordId);
		}
	}
 
	
	return commRes;
}
function _containsUser(newDataObjCMLI,cmli_comm_userid)
{
	var res=false;
	for (var z=0;z<newDataObjCMLI.length;z++)
	{
	    if (newDataObjCMLI[z].value==cmli_comm_userid){
		  res=true;
		  break;
		}
	}
	return res;
}

//copy of updateAppointment 
function updateCommunicationRecord(_commid, dataObj)
{	

	var _entity=new String(Request.Form('entity'));	
	var isAppointment = false;
	if ((_entity=="appt")||(_entity=="appointment"))
		isAppointment = true;

	var newDataObj=[];
	var newDataObjCMLI=[];//holds userid and also company and person id
	var toDeleteDataObjCMLI=[];//used when a user is removed from the appt
	var useridIndex=-1;
	for (var eex=0;eex<dataObj.length;eex++)
	{
		dataObj[eex].name=dataObj[eex].name.toLowerCase();
		if (dataObj[eex].name.toLowerCase().indexOf("cmli_comm_")!=0)
		{
			newDataObj.push(dataObj[eex]);
		}else{		
			newDataObjCMLI.push(dataObj[eex]);
			if (dataObj[eex].name.toLowerCase()=="cmli_comm_userid")
			{
				useridIndex=newDataObjCMLI.length-1;
			}
		}		
	}

	var commRes=updateNamedEntity("communication",_commid, newDataObj);
	commRes.entityid=_commid;
	commRes.dataObj=dataObj;
	//build assignmentObject based on current comm links
	var _AssignmentObject={
     companyid:null,
	 personid:null,
	 leadid:null,
	 territory:null
    }
	
if (!isNumeric(_commid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid _commid found, _commid is "+_commid);
  throw "No valid _commid found";
}		
	var asscl=CRM.FindRecord("Comm_Link","1298=1298 and cmli_comm_communicationid="+_commid); 
	if (!asscl.eof)
	{
		_AssignmentObject.companyid=asscl("cmli_comm_companyid");
		_AssignmentObject.personid=asscl("cmli_comm_personid");
		_AssignmentObject.leadid=asscl("CmLi_Comm_LeadID");
	}	

	////clever...lets check to see if we have a different one in the context?
	cmli_comm_personid_exists=checkCommFieldExists(dataObj,"cmli_comm_personid");
	cmli_comm_companyid_exists=checkCommFieldExists(dataObj,"cmli_comm_companyid");
	if (cmli_comm_personid_exists){
		_AssignmentObject.personid=getCommField(dataObj,"cmli_comm_personid").value		
	}
	if (cmli_comm_companyid_exists){
		if (!cmli_comm_personid_exists)
		  _AssignmentObject.personid='';
		_AssignmentObject.companyid=getCommField(dataObj,"cmli_comm_companyid").value		
	}	
	
	if (useridIndex==-1)
	{
		newDataObjCMLI.push({name: "cmli_comm_userid", value: CRM.GetContextInfo("user","user_userid")})
		useridIndex=newDataObjCMLI.length-1
	}
	if (isAppointment){
		//get existing..and check for users removed
		var ExistingComm_Links=CRM.FindRecord("Comm_Link","1230=1230 and cmli_comm_communicationid="+_commid);
		while(!ExistingComm_Links.eof){
			if (!_containsUser(newDataObjCMLI[useridIndex].value,ExistingComm_Links("cmli_comm_userid")))
			  toDeleteDataObjCMLI.push({name: "cmli_comm_userid", value: ExistingComm_Links("cmli_comm_userid")});
			ExistingComm_Links.NextRecord();
		}
		if (toDeleteDataObjCMLI.length>0)
		{
			for (var z2=0;z2<toDeleteDataObjCMLI.length;z2++)
			{		
				var _softDeleteSQL="update comm_link set cmli_deleted=1 where 1239=1239 and cmli_deleted is null and cmli_comm_communicationid="+_commid+ " and cmli_comm_userid="+toDeleteDataObjCMLI[z2].value;
				//Response.Write(_softDeleteSQL);
				//Response.Write(JSON.stringify(newDataObjCMLI[useridIndex].value));
				//Response.End();
				CRM.ExecSQL(_softDeleteSQL);
			}
		}
		//Response.Write(useridIndex+"=x="+JSON.stringify(newDataObjCMLI[useridIndex].value));
		//Response.End();		
	}
	
	if (Defined(newDataObjCMLI[useridIndex]))
	{
		if (typeof newDataObjCMLI[useridIndex].value==="string")
		{
			//task
			//delete previous records
			var RecordComm_Link_existing = CRM.FindRecord("Comm_Link","CmLi_Comm_CommunicationId="+_commid); 
			RecordComm_Link_existing.DeleteRecord=true;//soft delete...	
			RecordComm_Link_existing.SaveChanges(); 				
			var RecordComm_Link = CRM.CreateRecord("Comm_Link"); 
			RecordComm_Link.CmLi_Comm_CommunicationId=commRes.entityid;	
			RecordComm_Link.CmLi_Comm_UserId=newDataObjCMLI[useridIndex].value;	
			if (_AssignmentObject)
			{
				if (_AssignmentObject.companyid)
					RecordComm_Link.CmLi_Comm_companyId=_AssignmentObject.companyid;
				if (_AssignmentObject.personid)	
					RecordComm_Link.CmLi_Comm_personId=_AssignmentObject.personid;
				if (_AssignmentObject.leadid)	
					RecordComm_Link.CmLi_Comm_leadId=_AssignmentObject.leadid;
			}			
			RecordComm_Link.SaveChanges(); 	
			updateEntityByFields("Comm_Link", RecordComm_Link.RecordId);			
		}else{
			//appt
			for (var eex2=0;eex2<newDataObjCMLI[useridIndex].value.length;eex2++)
			{
			    if (newDataObjCMLI[useridIndex].value[eex2].value){
					var _userlinksql="1298=1298 and cmli_deleted is null and cmli_comm_communicationid="+_commid+" and CmLi_Comm_UserId="+newDataObjCMLI[useridIndex].value[eex2].value;
					//Response.Write(_userlinksql);
					var RecordComm_Link=CRM.FindRecord("Comm_Link",_userlinksql);
					
					if (RecordComm_Link.eof){
					  RecordComm_Link = CRM.CreateRecord("Comm_Link");
					}
					RecordComm_Link.CmLi_Comm_CommunicationId=commRes.entityid;	
					RecordComm_Link.CmLi_Comm_UserId=newDataObjCMLI[useridIndex].value[eex2].value;	
					if (_AssignmentObject)
					{
						if (_AssignmentObject.companyid)
							RecordComm_Link.CmLi_Comm_companyId=_AssignmentObject.companyid;
						if (_AssignmentObject.personid)	
							RecordComm_Link.CmLi_Comm_personId=_AssignmentObject.personid;
						if (_AssignmentObject.leadid)	
							RecordComm_Link.CmLi_Comm_leadId=_AssignmentObject.leadid;
					}			
					RecordComm_Link.SaveChangesNoTLS(); 	
					updateEntityByFields("Comm_Link", RecordComm_Link.RecordId);			
				}
			}
		}
	}
	return commRes;
}
%>