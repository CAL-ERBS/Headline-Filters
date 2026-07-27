<!-- #include file ="sagecrm.js" -->

<!-- #include file ="helpers.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="entrytype44.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="workflow.js" -->
<!-- #include file ="emailparser.js" -->
<%
	var isACMenuExtItem =false;
	var _workflowScreen = null;
	var _workFlowName = "";
	var _workFlowState = "";
	
function mailIsGenericAddress(_pemailAddress)
{
  _pemailAddress=new String(_pemailAddress);
  _pemailAddress=_pemailAddress.toLowerCase();
  var GenericEmailAddressesList=new String(GetWebConfigValue("GenericEmailAddressesList"));
  if (!Defined(GenericEmailAddressesList)||(GenericEmailAddressesList=="null")||(GenericEmailAddressesList==null)||(GenericEmailAddressesList==""))
  {
	GenericEmailAddressesList="@gmail.com,@hotmail.com,@yahoo.com,@aol.com,@outlook.com";
  }
  var GenericEmailAddressesList_arr=GenericEmailAddressesList.split(",");
  for(var cc=0;cc<GenericEmailAddressesList_arr.length;cc++)
  {
	if (_pemailAddress.indexOf(GenericEmailAddressesList_arr[cc])>-1)
	{
		return true;
	}
  }
  return false;
}

if (!Defined(Request.Form))
{
	//this allows us to test parsing of the data..clever
	Response.Clear();
	Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="Entity">Entity:</label><br>');
	Response.Write('<input type="text" id="entity" name="entity" value=""><br>');

	Response.Write('<label for="screenMetadata_entity">screenMetadata_entity:</label><br>');
	Response.Write('<input type="text" id="screenMetadata_entity" name="screenMetadata_entity" value=""><br>');

	Response.Write('<label for="screenMetadata_entityid">screenMetadata_entityid:</label><br>');
	Response.Write('<input type="text" id="screenMetadata_entityid" name="screenMetadata_entityid" value=""><br>');

	Response.Write('<label for="currentemail">currentemail:</label><br>');
	Response.Write('<textarea id="currentemail" name="currentemail" rows="30" cols="100">');
	Response.Write('</textarea><br>');	
	Response.Write('<br><input type="submit" value="Submit">');
	Response.Write('<form>');
	
	Response.End();
}

var _entity=new String(Request.Form('entity'));
_entity=_entity.toLowerCase();

var UseIndividuals=false;
if (_entity=="individual")
{
  UseIndividuals=true;
  _entity="person";
}

var _entitytable=getTableInfo(_entity);
if (!Defined(_entitytable.name)&&(_entity!='appointment')&&(_entity!='appt')){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
  throw "No valid Entity found";
}

var screenMetadata_entity=new String(Request.Form('screenMetadata_entity'));
if (Defined(screenMetadata_entity)&&(screenMetadata_entity!=""))
{
	var screenMetadatatable=getTableInfo(screenMetadata_entity);
	if ((screenMetadata_entity!="none") && (!Defined(screenMetadatatable.name))){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid screenMetadata_entity found, entity is "+Request.Form('screenMetadata_entity'));
	  throw "No valid screenMetadata_entity found";
	}
}

var screenMetadata_entityid=new String(Request.Form('screenMetadata_entityid'));
if (Defined(screenMetadata_entityid)&&(screenMetadata_entityid!=""))
{
	if (!isNumeric(screenMetadata_entityid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid screenMetadata_entityid found, screenMetadata_entityid is "+Request.Form('screenMetadata_entityid'));
	  throw "No valid screenMetadata_entityid found";
	}
}

var _currentemailStr=new String(Request.Form('currentemail'));

var _currentemailObj=null;
try{
  _currentemailObj=JSON.parse(_currentemailStr);

	 //_currentemailObj.sentItem=true;//test line only
	 if (Defined(_currentemailObj)&& Defined(_currentemailObj.from))
	 { 
		 if (_currentemailObj.from.emailAddress==null || _currentemailObj.from.emailAddress=="")
		 {
			_currentemailObj.from.emailAddress="noemailaddress@inthisemail.com";
			//so...we fix 2 issues here
			//internal systems sending emails with not emailAddress set (bad practice) so we flag this with that email address
			//also though...we treat these as sent emails
			_currentemailObj.sentItem=true;
		 }else{
		   var _user_emailaddress=new String(CRM.GetContextInfo('user','user_emailaddress'));
		   _user_emailaddress=_user_emailaddress.toLowerCase();
		   if (!_currentemailObj.sentItem && (_currentemailObj.from.emailAddress.toLowerCase()==_user_emailaddress))
			_currentemailObj.sentItem=true;//we assume its a sent email even
		 }
	 }

}catch(ee){}

 //_currentemailObj.sentItem=true;//test line only
 if (_currentemailObj!=null && Defined(_currentemailObj)&& Defined(_currentemailObj.from))
 { 
	 if (_currentemailObj.from.emailAddress==null || _currentemailObj.from.emailAddress=="")
	 {
		_currentemailObj.from.emailAddress="noemailaddress@inthisemail.com";
		//so...we fix 2 issues here
		//internal systems sending emails with not emailAddress set (bad practice) so we flag this with that email address
		//also though...we treat these as sent emails
		_currentemailObj.sentItem=true;
	 }else{
	   var _user_emailaddress=new String(CRM.GetContextInfo('user','user_emailaddress'));
	   _user_emailaddress=_user_emailaddress.toLowerCase();
	   if (!_currentemailObj.sentItem && (_currentemailObj.from.emailAddress.toLowerCase()==_user_emailaddress))
		_currentemailObj.sentItem=true;//we assume its a sent email even
	 }
 }

var regextArray=[];
var regExParseResult=[];
if (_currentemailObj)
{
    if (!validEmailAddress(_currentemailObj.from.emailAddress))
	{
		  //log to CRM's logs
		  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid emailAddress found, emailAddress is "+_currentemailObj.from.emailAddress);
		  throw "No valid emailAddress found";	
	}

	//check for parse rules
	var _parseRuleSQL="select capt_captionid,capt_uk from custom_captions where capt_deleted is null and capt_family='EmailParse' and convert(nvarchar(255),capt_us)='"+escapeSQL(_currentemailObj.from.emailAddress)+"' order by capt_order";
	var parseRule=CRM.CreateQueryObj(_parseRuleSQL);
	parseRule.SelectSQL();
	while (!parseRule.eof)
	{
		//get  the ruleset now
		var _rulesetSQL="select capt_captionid,capt_us as entity,capt_uk as regexcode,capt_fr as regexoption,"+
			"capt_de as itemextract,capt_es as mappedField from custom_captions where capt_deleted is null and capt_family='"+
			parseRule("capt_uk")+"' order by capt_order";
		var parseRuleSet=CRM.CreateQueryObj(_rulesetSQL);
		parseRuleSet.SelectSQL();
		while (!parseRuleSet.eof)
		{
			var _newRule={entity:parseRuleSet("entity"),
							Exp:parseRuleSet("regexcode"),
							param:parseRuleSet("regexoption"), 
							extract:parseRuleSet("itemextract"),
							mappedField:parseRuleSet("mappedField")
							}
			regextArray.push(_newRule);
			parseRuleSet.NextRecord();
		}
		parseRule.NextRecord();
	}

	if (_currentemailObj.from.emailAddress=="left here as a reference")
	{
		//these are samples used when developing...left here as useful references
		regextArray.push({entity:"person","Exp":"(Name: \n)(.*)(?=\nPhone)","param":"gi", extract:"Name: ",mappedField:"fullname"});
		regextArray.push({entity:"person","Exp":"Name:(\s+([a-zA-Z]+\s+)+)","param":"gi", extract:"Name: ",mappedField:"fullname"});
		regextArray.push({entity:"person","Exp":"(name: )(.*)(?=\r\nemail: )","param":"gi", extract:"name: ",mappedField:"fullname"});

		regextArray.push({entity:"phone","Exp":"(Phone: \n)(.*)(?=\nEmail)","param":"gi", extract:"phone: ",mappedField:""});
		regextArray.push({entity:"phone","Exp":"Phone:(\s+([a-zA-Z]+\s+)+)","param":"gi", extract:"Phone: ",mappedField:""});
		regextArray.push({entity:"phone","Exp":".*phone:\s*([0-9]).+","param":"gi", extract:null,mappedField:""});
		regextArray.push({entity:"phone","Exp":"(phone:.*\n)","param":"gi", extract:"phone: ",mappedField:""});


		regextArray.push({entity:"email","Exp":"(Email: \n)(.*)(?=\nReason)","param":"gi", extract:"phone: ",mappedField:""});
		regextArray.push({entity:"email","Exp":"Email:(\s+([a-zA-Z]+\s+)+)","param":"gi", extract:"Email: ",mappedField:""});
		regextArray.push({entity:"email","Exp":"(email:.*\n)","param":"gi", extract:"email: ",mappedField:""});

		regextArray.push({entity:"company","Exp":"(Name\t)(.*)(?=\t\r\nEmail)","param":"gi", extract:"Name", 
						mappedField:"comp_name"});			
		regextArray.push({entity:"company","Exp":"(name: )(.*)(?=\r\nemail: )","param":"gi", extract:"name: ", 
						mappedField:"comp_name"});							

		regextArray.push({entity:"person","Exp":"(Name\t)(.*)(?=\t\r\nEmail)","param":"gi", extract:"Name",mappedField:"fullname"});
		regextArray.push({entity:"email","Exp":"(Email\t)(.*)(?=\t\r\nProduct)","param":"gi", extract:"Email",mappedField:""});
		regextArray.push({entity:"phone","Exp":"(Phone)(.*)(?=test)","param":"gi", extract:"Phone",mappedField:""});

			
		regextArray.push({entity:"lead","Exp":"(Email\t)(.*)(?=\t\r\nProduct)","param":"gi", extract:"Email",
						mappedField:"lead_personemail"});				
						
		//persons name in lead
		regextArray.push({entity:"lead","Exp":"(Name\t)(.*)(?=\t\r\nEmail)","param":"gi", extract:"Name",mappedField:""});	
		
		regextArray.push({entity:"lead","Exp":"(Name\t)(.*)(?=\t\r\nEmail)","param":"gi", extract:"Name",
						mappedField:"lead_companyname"});
		regextArray.push({entity:"lead","Exp":"(name: )(.*)(?=\r\nemail: )","param":"gi", extract:"name: ", 
						mappedField:"lead_companyname"});						
		regextArray.push({entity:"lead","Exp":"(email:.*\n)","param":"gi", extract:"email: ",mappedField:"lead_personemail"});
		regextArray.push({entity:"lead","Exp":"(name: )(.*)(?=\r\nemail: )","param":"gi", extract:"name: ",mappedField:"fullname"});
		regextArray.push({entity:"lead","Exp":"(phone:.*\n)","param":"gi", extract:"phone: ",mappedField:"lead_personphonenumber"});

	}
	if (regextArray.length>0)
	{
		regExParseResult=parseEmail(_currentemailObj.body,regextArray);

		//extract domain for website values..clever
		if (regExParseResult.email.length>0)
		{
		  var _regexdEmailAddress=regExParseResult.email[0].matchObject[0];
		  var regextArrayWebsite=[];
		  regextArrayWebsite.push({entity:"company","Exp":"((?:[a-z0-9-]+\\.)*)([a-z0-9-]+\\.[a-z]+)($|\\s|\\:\\d{1,5})","param":"g", extract:"",
						mappedField:"comp_website"});	  
		  var regExParseResultwebsite=parseEmail(_regexdEmailAddress,regextArrayWebsite);
		  if(regExParseResultwebsite.company.length>0)
			regExParseResult.company.push(regExParseResultwebsite.company[0]);

		  var regextArrayWebsiteLead=[];
		  regextArrayWebsiteLead.push({entity:"lead","Exp":"((?:[a-z0-9-]+\\.)*)([a-z0-9-]+\\.[a-z]+)($|\\s|\\:\\d{1,5})","param":"g", extract:"",
						mappedField:"lead_companywebsite"});	  
		  var regExParseResultwebsiteLead=parseEmail(_regexdEmailAddress,regextArrayWebsiteLead);
		  if (regExParseResultwebsiteLead.lead && regExParseResultwebsiteLead.lead.length>0)
			regExParseResult.lead.push(regExParseResultwebsiteLead.lead[0]);
		}
	}
}



//context data? -EG when creating a case under a company
var contextEntity=null;
if ((_entity!="company")&&( screenMetadata_entityid!="-1")&&(Defined(screenMetadata_entity)&&(screenMetadata_entity!="")))
{
  contextEntity=getEntityRecord(screenMetadata_entity, screenMetadata_entityid);
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
var _crmscreen=getNewScreen(_entity,useScreen,contextEntity,screenMetadata_entity,null,true);

//appt
_crmscreen.subheader="";
var _allscreens=[];
if (UseIndividuals){
  //remove the company field from the person screen
  if (_crmscreen.formElements.length>1)
	{
		for(var tt=0;tt<_crmscreen.formElements.length;tt++)
		{
		  if (_crmscreen.formElements[tt].name.toLowerCase()=="pers_companyid")
		  {
		    _crmscreen.formElements=removeArrayItem(_crmscreen.formElements,tt);
			break;
		  }
		}
	}
}else
if ((_entity=="appt")||(_entity=="appointment"))
{
	//screen used in mx appt
	_crmscreen=getDefaultNewApptScreen();	
	//now we get any other fields from crm screen apptofficeintnew
	var _tmpscreen=getNewScreen("communication","apptofficeintnew",contextEntity,screenMetadata_entity,null,true);
	if (_tmpscreen.formElements.length>1)
	{
		for(var tt=0;tt<_tmpscreen.formElements.length;tt++)
		{
		  if (_tmpscreen.formElements[tt].name.toLowerCase()=="cmli_comm_personid")
		  {
		    _tmpscreen.formElements[tt].filterObjectName="cmli_comm_companyid";
		  }
		}
		_crmscreen.formElements=_crmscreen.formElements.concat(_tmpscreen.formElements);
	}
}else
if (_entity=="communication")
{
	//this can happen if communicationofficeintnew does not exist..usually on a new task
	_crmscreen=getDefaultNewTaskScreen();
	//now we get any other fields from crm screen apptofficeintnew
	var _tmpscreen=getNewScreen("communication","communicationofficeintnew",contextEntity,screenMetadata_entity,null,true);
	if (_tmpscreen.formElements.length>1)
	{
		_crmscreen.formElements=_crmscreen.formElements.concat(_tmpscreen.formElements);
	}	
}

_allscreens.push(_crmscreen);

//apply regex results
applyRegex(_entity,_crmscreen, regExParseResult[_entity]);	

//entities like company/person have more than one form...address/phone/email etc
if (_entity=="company")
{
	//apply regex results
	applyRegex("company",_crmscreen, regExParseResult.company);	
	//address
	var _crmAddressscreen=getNewScreen("address","AddressOfficeInt",null );
	_crmAddressscreen.subheadericon="mdi-map-marker";
	_allscreens.push(_crmAddressscreen);
	//apply regex results
	applyRegex("address",_crmAddressscreen, regExParseResult.address);	
	//person
	var _person_permission=hasPermissionInsert("person");
	if (_person_permission)
	{
		var _crmscreen2= getNewScreen("person","PersonOfficeIntSmall",null );
		_crmscreen2.subheadericon="mdi-account";
		_allscreens.push(_crmscreen2);
		//apply regex results
		applyRegex("person",_crmscreen2, regExParseResult.person);
	}
	//phone
	var _crmPhonescreen=getPhoneScreen("person","pers",null,null,_currentemailObj);
	_allscreens.push(_crmPhonescreen);
	//apply regex results
	applyRegex("phone",_crmPhonescreen, regExParseResult.phone);
	//email
	var _crmEmailscreen=getEmailScreen("person","pers",null);
	_allscreens.push(_crmEmailscreen);
	//apply regex results
	applyRegex("email",_crmEmailscreen, regExParseResult.email);	
	
} else if (_entity=="person")
{
	//apply regex results
	applyRegex("person",_crmscreen, regExParseResult.person);	
	//phone
	var _crmPhonescreen=getPhoneScreen("person","pers",contextEntity,null,_currentemailObj);
	_allscreens.push(_crmPhonescreen);
	//apply regex results
	applyRegex("phone",_crmPhonescreen, regExParseResult.phone);	
	//email 
	var _crmEmailscreen=getEmailScreen("person","pers",contextEntity);
	_allscreens.push(_crmEmailscreen);
	//apply regex results
	applyRegex("email",_crmEmailscreen, regExParseResult.email);	
	//address
	var _crmAddressscreen=getNewScreen("address","AddressOfficeInt",contextEntity);
	_crmAddressscreen.pickerurl=getCRMProtocol()+get_SERVER_NAME()
		+":"+get_SERVER_PORT()+
		CRM.Url("sagecrmws/ac2020/companyaddresses.asp");
	_crmAddressscreen.subheadericon="mdi-map-marker";
	_allscreens.push(_crmAddressscreen);	
	//apply regex results
	applyRegex("address",_crmAddressscreen, regExParseResult.address);		
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
	  if (_elmnt.name.toLowerCase()=="comp_name")
	  {
		if ((_currentemailObj)&&(mailIsGenericAddress(_currentemailObj.from.emailAddress)))
		{
		   _elmnt.value=_currentemailObj.fullName;
		}
	  }
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
//copy screen(s)
//var _allscreens22=JSON.stringify(_allscreens);
//var _allscreens22=JSON.parse(_allscreens22);
//workflow options
	if (!isACMenuExtItem) {	
		_workflowScreen=getWorkflowScreen(_entity);
	} else {
		_workflowScreen=getWorkflowScreen(_entity, _workFlowName,  _workFlowState);
	}

	if (_workflowScreen!=null)
	{
		_allscreens.push(_workflowScreen);
	}

//new workflow


var res={
  "screenMetadata": {
    "lang": getUserLang(),
	"page":"getFormMetadata",
	"screens":_allscreens,
	//"screens22":_allscreens22,
	"regExParseResult":regExParseResult
  },
  "data": null,
  "email": _currentemailObj
}

//branding start
getBranding(res.screenMetadata);
//branding end

res=JSON.stringify(res);
Response.Write(res);
%>