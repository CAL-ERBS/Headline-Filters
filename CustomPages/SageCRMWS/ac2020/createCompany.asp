<%

function createAddress(_data,companyid, personid)
{
  var q=CRM.CreateRecord("address");
  
  var tableObj=getTableInfo("address");
  if (tableObj.appFlagField!="")
  {
	q(tableObj.appFlagField)="Accelerator";
  }  

  for(var i=0;i<_data.length;i++)
  {
	var xfield=_data[i];
	var fname=new String(xfield.name);
	if (fname.indexOf("addr_")==0)
	{
		q(xfield.name)=getCreateFieldValue(xfield);
	}
  }
  q.SaveChangesNoTLS();
	updateEntityByFields("address", q.RecordId); 
  var addressid = q.RecordId;
  
  //address link for company
  if (companyid!=null)
  {  
	  var qal=CRM.CreateRecord("Address_Link");
	  qal("adli_companyid")=companyid;
	  qal("AdLi_AddressId")=addressid;
	  qal("AdLi_Type")="Business";
	  qal.SaveChangesNoTLS();
	updateEntityByFields("Address_Link", qal.RecordId); 
  }
  if (personid!=null)
  {
	  //address link for person
	  var qalp=CRM.CreateRecord("Address_Link");
	  qalp("adli_companyid")=companyid;
	  qalp("adli_personid")=personid;
	  qalp("AdLi_AddressId")=addressid;
	  qalp("AdLi_Type")="Business";
	  qalp.SaveChangesNoTLS();  
	updateEntityByFields("Address_Link", qalp.RecordId); 
  }
  return addressid;
}

function createPerson(_data,companyid,wf)
{
  var q=CRM.CreateRecord("person");

  var tableObj=getTableInfo("person");
  if (tableObj.appFlagField!="")
  {
	q(tableObj.appFlagField)="Accelerator";
  }  
  
  if (companyid)
	q("pers_companyid")=companyid;
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
	if (xfield.name.indexOf("pers_")==0)
	{
		if ((_x2field.value)&&(_x2field.value.currency))
		{
			q(_x2field.name+"_cid")=_x2field.value.currency;	
			q(_x2field.name)=_x2field.value.amount;			
		}else{		
			q(xfield.name)=getCreateFieldValue(_x2field);
		}
	}	  
  }
  if (wf)
  {
    q.setWorkFlowInfo(wf.workflow, wf.workflowstate);
  }  
  if (Defined(q("pers_companyid")))
  {
	  var dataObj={entity:"company", entityid:q("pers_companyid")}
	  var assignmentObject=getAssignmentObject(dataObj);  
	  if (Defined(assignmentObject.territory))
	  {
		q("pers_secterr")=assignmentObject.territory;
	  }
  }
  if (q("pers_status")==null)
  {
	q("pers_status")="Active";
  }  
	try {
		q.SaveChangesNoTLS();
	} catch(ex) {
		SendError("createPerson", "person", ex.message)
	}


  var personid = q.RecordId;
  updateEntityByFields("person", personid); 

  //person link
  if (q("pers_companyid"))
  {
	  var qal=CRM.CreateRecord("Person_Link");
	  qal("peli_companyid")=q("pers_companyid");
	  qal("peli_personid")=personid;
	  qal.SaveChangesNoTLS();
	  updateEntityByFields("Person_Link", qal.RecordId);
  }
  return personid;
}

function updatePerson(newCompanyId,addressid,personid,_libraryfolder)
{
	//fix up _libraryfolder if needed
	if (_libraryfolder)
	{
		_libraryfolder=_libraryfolder.replace(/'/g, "''");
	}
	var q=CRM.FindRecord("person","pers_personid="+personid); 
	var updateSQL="update person set "+
		"Pers_PrimaryAddressId="+addressid+","+
		"pers_LibraryDir='"+_libraryfolder+"'";		
	if (newCompanyId!=null)
	{
		updateSQL+=",Pers_companyid="+newCompanyId+" ";
	}
	if (q("Pers_PrimaryUserId")+""=="undefined")
	{
		updateSQL+=",Pers_PrimaryUserId="+getUserId();
	}	
	updateSQL=updateSQL+" where pers_personid="+personid;
	Glog("updatePerson updateSQL:"+updateSQL);
	CRM.ExecSQL(updateSQL);

}

function createPhone(_data, Plink_entityId, PLink_RecordID)
{
	for(var i=0;i<_data.length;i++)
	{
		var xfield=_data[i];
		var fname=new String(xfield.name);
		if ((fname.indexOf("phonefield_")==0)&&(xfield.value)&&(xfield.value.phonenumber_value!=""))
		{
			var q=CRM.CreateRecord("Phone");
			
			var _countrycode_value="";
			if (typeof xfield.value =="object")
				_countrycode_value=xfield.value.countrycode_value;
			else
				_countrycode_value=xfield.value;	
			if(_countrycode_value)
				q("Phon_CountryCode")=_countrycode_value;
				
			var _areacode_value="";
			if (typeof xfield.value =="object")
				_areacode_value=xfield.value.areacode_value;
			else
				_areacode_value=xfield.value;	
			if (_areacode_value)	
				q("Phon_AreaCode")=_areacode_value;
			
			var _phonenumber_value="";
			if (typeof xfield.value =="object")
				_phonenumber_value=xfield.value.phonenumber_value;
			else
				_phonenumber_value=xfield.value;
			if (_phonenumber_value)
				q("Phon_Number")=_phonenumber_value;
			
			q.SaveChangesNoTLS();
			updateEntityByFields("Phone", q.RecordId);
			var Plink_phoneId=q.RecordId;
			//what type...business?mobile?
			var q=CRM.CreateRecord("PhoneLink");
			q("Plink_entityId")=Plink_entityId;
			q("PLink_RecordID")=PLink_RecordID;
			q("Plink_phoneId")=Plink_phoneId;
			var __type=new String(fname.substring(11));
			q("Plink_Type")=__type;
			q.SaveChangesNoTLS();	
			updateEntityByFields("PhoneLink", q.RecordId);
		}
	}
}

function createEmail(_data, Elink_entityId, ELink_RecordID)
{
	for(var i=0;i<_data.length;i++)
	{
		var xfield=_data[i];
		var fname=new String(xfield.name);
		if ((fname.indexOf("emailfield_")==0)&&(xfield.value)&&(xfield.value.emailaddress!=""))
		{
			var q=CRM.CreateRecord("Email");	
			
			var _email="";
			if (typeof xfield.value =="object")
				_email=xfield.value.emailaddress;
			else
				_email=xfield.value;			
			if (_email){
				q("Emai_EmailAddress")=_email;			
				q.SaveChangesNoTLS();
				updateEntityByFields("Email", q.RecordId);
				var Elink_emailId=q.RecordId;
				//what type...business?mobile?
				var q=CRM.CreateRecord("EmailLink");
				q("Elink_entityId")=Elink_entityId;
				q("Elink_emailId")=Elink_emailId;
				q("ELink_RecordID")=ELink_RecordID;
				
				var _email="";
				if (typeof xfield.value =="object")
					q("Elink_Type")=xfield.value.type;
				else
				{
					var __type=new String(fname.substring(11));
					q("Elink_Type")=__type;
				}
				q.SaveChangesNoTLS();
				updateEntityByFields("EmailLink", q.RecordId);
			}
		}
	}
}  

function updateCompany(newCompanyId,addressid,personid,_libraryfolder)
{
	if (_libraryfolder)
	{
		_libraryfolder=_libraryfolder.replace(/'/g, "''");
	}
	var crec=CRM.FindRecord("company","comp_companyid="+newCompanyId);
	var updateSQL="update company set "+
		"Comp_PrimaryAddressId="+addressid+","+
		"Comp_PrimaryPersonId="+personid+","+
		"Comp_LibraryDir='"+_libraryfolder+"'";		
	if (crec("Comp_PrimaryUserId")+""=="undefined")
	{
		updateSQL+=",Comp_PrimaryUserId="+getUserId();
	}	
	updateSQL=updateSQL+" where comp_companyid="+newCompanyId;
    CRM.ExecSQL(updateSQL);
}

function createLibrary2(companyid,personid)
{
  if (companyid==null)
	return createLibrary(null, personid);
  else
	return createLibrary(companyid, null);
}

function createLibrary(companyid, personid)
{
	var crec=null;
	
	var strCompPath ="";
	if (companyid==null)
	{
  	  crec=CRM.FindRecord("person,vsummaryperson","pers_personid="+personid);
	  strCompPath = new String(crec("pers_fullname"));
	}else{
  	  crec=CRM.FindRecord("company","comp_companyid="+companyid);
	  strCompPath = new String(crec("comp_name"));
	}
	strCompPath = strCompPath.replace(/[/\\?%*:|"<>]/g, '-');
	strCompPath = strCompPath.replace(/&/g, " ");
	var strCompPathPart=strCompPath.charAt(0);
	var strdestinationfullpath = getLibraryRootPath() +"\\" + strCompPathPart + "\\" + strCompPath;
	
	//create folder if it doesn't exist
	var arrCompPath = strCompPath.split("\\");

    createFolder(getLibraryRootPath() +"\\" + strCompPathPart);
	createFolder(strdestinationfullpath);
	return strCompPathPart + "\\" + strCompPath;
}
	
  
function createCompany(_data,wf)
{	
  //company
  var q=CRM.CreateRecord("company");

  var tableObj=getTableInfo("company");
  if (tableObj.appFlagField!="")
  {
	q(tableObj.appFlagField)="Accelerator";
  }  
  
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
	if (xfield.name.indexOf("comp_")==0)
	{
		if ((_x2field.value)&&(_x2field.value.currency))
		{
			q(_x2field.name+"_cid")=_x2field.value.currency;	
			q(_x2field.name)=_x2field.value.amount;			
		}else{	
			q(xfield.name)=getCreateFieldValue(_x2field);
		}
	}	
  }
  //check comp_secterr is set..if not set it
  if (q("comp_secterr")==null)
  {
	q("comp_secterr")=getUser_PrimaryTerritory()
  }
  if (q("comp_status")==null)
  {
	q("comp_status")="Active";
  }  
  if (wf)
  {
    q.setWorkFlowInfo(wf.workflow, wf.workflowstate);
  }

	try {
		q.SaveChanges();
	} catch(ex) {
		SendError("createCompany", "company", ex.message)
	}

  var newCompanyId=q.RecordId;
	updateEntityByFields("Company", newCompanyId);
  //person
  var personid=null;
  var _person_permission=hasPermissionInsert("person");
  if (_person_permission)
  {
	personid=createPerson(_data,newCompanyId);
  }
  //address
  var addressid=createAddress(_data,newCompanyId, personid);

  var _libraryfolder=createLibrary(newCompanyId,personid);
  
  //phone
  //createPhone(_data, 5, newCompanyId);//we dont update this now
  if (_person_permission!="")
  {  
	createPhone(_data, 13, personid);
  }
  //email
  //createEmail(_data, 5, newCompanyId);//we dont update this now
  if (_person_permission!="")
  {  
	createEmail(_data, 13, personid);
  }
  
  updateCompany(newCompanyId,addressid,personid,_libraryfolder);   
  
  if (_person_permission!="")
  {
	updatePerson(newCompanyId,addressid,personid,_libraryfolder);
  }

  return {
	  entity:_entity,
	  entityid:newCompanyId
  }
  
}

function updateCompanyRecord(_entityid, dataObj)
{
  var companydataObj=JSON.stringify(dataObj);
  companydataObj=JSON.parse(companydataObj);
  //remove non-company fields
  for(var tt=0;tt<companydataObj.length;tt++)
  {
	var fieidObj=companydataObj[tt];
	if (fieidObj.name.indexOf("comp_")!=0)
	{
	  companydataObj.length=tt;
	  break;
	}
  }
  var updateRes=updateNamedEntity("company",_entityid,companydataObj);
  updateRes.log+="c1x";
  
  //todo items for version2
   //address
   //var primaryAddress = CRM.FindRecord("Address,vAddressCompany", "AdLi_CompanyID=" +_entityid );
   var _Addr_AddressId="-1";
   var compq=CRM.CreateQueryObj("select comp_primaryaddressid from company where comp_companyid="+_entityid);
   compq.SelectSQL();
   _Addr_AddressId=compq("comp_primaryaddressid");
   var primaryAddress = CRM.FindRecord("Address", "Addr_AddressId=" +_Addr_AddressId );
   updateRes.log+="c2x"+primaryAddress.eof;
	if (!primaryAddress.eof) {
		updateRes.log+="c3x"+primaryAddress("addr_addressid");
		var addressRecord = CRM.FindRecord("Address", "addr_addressid=" + primaryAddress("addr_addressid") );
		for(var i=0; i< dataObj.length;i++) {
			if (dataObj[i].name.indexOf("addr_") == 0 && Defined(dataObj[i].value)) {
				updateRes.log+="//"+dataObj[i].name+"="+dataObj[i].value
				addressRecord(dataObj[i].name) = dataObj[i].value;
			}
		}
		try {
			updateRes.log+="addressRecord.SaveChangesNoTls";
			var ares=addressRecord.SaveChangesNoTls();
			updateRes.log+="////ares="+ares;
		} catch(Exception) {
			updateRes.log+="-Address update error: "+Exception.message;
		}
	}



  //phone
  
  //email
  
  
  return updateRes;
}


%>