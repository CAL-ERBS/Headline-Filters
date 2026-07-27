<%
var calendarcolors =['blue', 'indigo', 'deep-purple', 'cyan', 'green', 'orange', 'grey darken-1', 'red'];

function getCalendarStatusColor(statusval, actionval)
{
	var _statusval=new String(statusval);
	_statusval=_statusval.toLowerCase();
	
	
	var _colorindex=6;
	switch(_statusval) {
		case "pending":
			_colorindex=5;
			break;
		case "complete":
			_colorindex=0;
			break;
		case "cancelled":
			_colorindex=7;
			break;
		case "inprogress":
			_colorindex=4;
			break;			
		default:
			_colorindex=1;
			break;				
	}	 
	return _colorindex;
}

function getUTCVal(dt)
{
	var year = dt.getFullYear();
	var month = ('0' + (dt.getMonth() + 1)).slice(-2); // Month is zero-based
	var day = ('0' + dt.getDate()).slice(-2);
	var hours = ('0' + dt.getHours()).slice(-2);
	var minutes = ('0' + dt.getMinutes()).slice(-2);
	var formatted = year + '-' + month + '-' + day;
	return formatted;
}
	
function getCalendarData(from, to, userId, type)
{
	
	from=adjustUserDateToServerDate(from,userId);
	to=adjustUserDateToServerDate(to,userId);
	
	from =getQueryVal(from);
	to = new Date(to.getTime() + 24 * 60 * 60 * 1000);//ad 24hrs
	to=getQueryVal(to,-1);

	var _whereclause="9512=9512 and comm_type='"+type 
			+"' AND cmli_deleted is null and comm_private is null "
			+" AND cmli_comm_userid ="+userId+" "
			+" AND (comm_datetime between '"+(from)+"' and '"+(to)+"'"
			+" OR comm_todatetime between '"+(from)+"' and '"+(to)+"')";

	if (!Defined(userId) || (userId==""))
	{
		_whereclause="9513=9513 and comm_type='"+type 
			+"' AND cmli_deleted is null  and comm_private is null "
			+" AND cmli_comm_userid is null "
			+" AND (comm_datetime between '"+(from)+"' and '"+(to)+"'"
			+" OR comm_todatetime between '"+(from)+"' and '"+(to)+"')";
	}
	//Response.Write("_whereclause="+_whereclause+"ZZZZZZZZZZZZZZZZZ");
	var comm = null;
	var result = [];				
	comm = CRM.FindRecord("Communication, vCommunicationAll", _whereclause);
	while (!comm.eof) {
		var allDay=comm('Comm_IsAllDayEvent')=='Y';
		var _sdate=new Date(comm("comm_datetime"));
		_sdate=adjustUserDate(_sdate);
		var _edate=new Date(comm("comm_todatetime"));
		_edate=adjustUserDate(_edate);
		var _cnote=new String(comm("comm_note"));
		if (!Defined(_cnote))
		  _cnote="";		
		var _clocation=new String(comm("comm_location"));
		if (!Defined(_clocation))
		  _clocation="";
		var resultArray = _cnote.split(" ");
		if(resultArray.length > _baseConfig.listdatawordlength){
				resultArray = resultArray.slice(0,_baseConfig.listdatawordlength);
				_cnote = resultArray.join(" ")+"...";
		}	
		//build our data section
		var _commsection=JSON.clone(_section);
		_commsection.name="commsection";
		_commsection.title="";
		_commsection.subheader="";
		_commsection.entity="communication";
		_commsection.data=[];
		
		var comm_location=JSON.clone(_SectionDataItem);	
		
		comm_location.name="comm_location";
		comm_location.caption=CRM.GetTrans("colnames","comm_location");		
		comm_location.newline=true;
		comm_location.value=comm_location;
		comm_location.componentType=getComponentType(10);
		comm_location.type=10;
		comm_location.displayvalue=_clocation;
		//	_commsection.data.push(comm_location);//this is causing a crash...
		
		var _item1=JSON.clone(_SectionDataItem);	
		_item1.name="comm_note";
		_item1.caption=CRM.GetTrans("colnames","comm_note");		
		_item1.newline=true;
		_item1.value=_cnote;
		_item1.componentType=getComponentType(11);
		_item1.type=11;
		_item1.displayvalue=_cnote;
		_commsection.data.push(_item1);			
		
		var _companyField={
				  name:"CmLi_Comm_CompanyId",
				  order:1,
				  type:56,
				  componentType:getComponentType(56),
				  lookup:"company",
				  newline:true,
				  viewfields:"comp_name"
				}
		var _company=getSearchListFieldsData("commlink", _companyField, comm(_companyField.name), false);
		var _item2=JSON.clone(_SectionDataItem);	
		_item2.name="CmLi_Comm_CompanyId";
		_item2.caption=CRM.GetTrans("colnames","CmLi_Comm_CompanyId");		
		_item2.newline=true;
		_item2.value=comm(_companyField.name);
		_item2.displayvalue=_company;
		_item2.componentType=getComponentType(56);
		_item2.type=56;		
		_commsection.data.push(_item2);	
		
		if (!Defined(_company))
			_company="";
		_item2.internallink={
			"entity":"company",
			"entityid":comm(_companyField.name),
			"icon":"mdi-office-building",
			"color":"orange"
		}	
		
		var _personField={
				  name:"CmLi_Comm_PersonId",
				  order:1,
				  type:56,
				  componentType:getComponentType(56),
				  lookup:"person",
				  newline:true,
				  viewfields:"pers_fullname"
				}			
		var _person=getSearchListFieldsData("commlink", _personField, comm(_personField.name), false);
		var _item3=JSON.clone(_SectionDataItem);	
		_item3.name="CmLi_Comm_PersonId";
		_item3.caption=CRM.GetTrans("colnames","CmLi_Comm_PersonId");		
		_item3.newline=true;
		_item3.value=comm(_personField.name);
		_item3.displayvalue=_person;
		_item3.componentType=getComponentType(56);
		_item3.type=56;		
		_commsection.data.push(_item3);			
		
		if (!Defined(_person))
			_person="";
		_item3.internallink={
			"entity":"person",
			"entityid":comm(_personField.name),
			"icon":"mdi-account",
			"color":"blue"
		}			
		
		//lead
		var _leadField={
				  name:"Comm_LeadId",
				  order:1,
				  type:56,
				  componentType:getComponentType(56),
				  lookup:"lead",
				  newline:true,
				  viewfields:"lead_description"
				}
		var _company=getSearchListFieldsData("lead", _leadField, comm(_leadField.name), false);
		var _item4=JSON.clone(_SectionDataItem);	
		_item4.name="Comm_LeadId";
		_item4.caption=CRM.GetTrans("colnames","Comm_LeadId");		
		_item4.newline=true;
		_item4.value=comm(_leadField.name);
		_item4.displayvalue=_company;
		_item4.componentType=getComponentType(56);
		_item4.type=56;		
		_commsection.data.push(_item4);		
		
		if (!Defined(_company))
			_company="";
		_item4.internallink={
			"entity":"lead",
			"entityid":comm(_leadField.name),
			"icon":"mdi-card-account-details",
			"color":"purple"
		}	
		var icslink = "";
		if (((G_appMode=="AC") &&(GetWebConfigValue("comm_enableICSAC")=="Y"))||
			((G_appMode=="MX") &&(GetWebConfigValue("comm_disableICSMX")!="Y")))
		{
			//generate ics file - so can be added to phone/outlook calendar etc
			icslink = getCRMProtocol() + get_SERVER_NAME()
				+ ":" + get_SERVER_PORT() +
				CRM.Url("sagecrmws/ac2020/getICSac.asp") +isportalcode()+"commId=" + comm("comm_communicationid");
		}		
        var event =  { 
            "start" : getCalendarDate(_sdate),
            "end" : getCalendarDate(_edate),
            "startdisplay" : getUserDateSmart(_sdate,true),
            "enddisplay" : getUserDateSmart(_edate,true),
			"timediffdisplay":helpers_getTimeDiff(_sdate,_edate),
            "name" : comm("comm_subject"),
			"data": [{
					"sections": [_commsection]
				}],	
			"color" : calendarcolors[getCalendarStatusColor(comm("comm_status"),comm("comm_action"))],
            "eventId" : comm.RecordId,
			"timed": allDay,
			"icslink":icslink
        };
        result.push(event);
        comm.NextRecord();
    }
    return result;
}

function getTaskData(from, to, userObject, type, filter)
{
	
	from=adjustUserDateToServerDate(from,userId);
	to=adjustUserDateToServerDate(to,userId);
	
	from =getQueryVal(from);
	to = new Date(to.getTime() + 24 * 60 * 60 * 1000);//ad 24hrs
	to=getQueryVal(to,-1);	
	
	var _whereclause="987=987 and comm_type='"+type 
			+"' AND cmli_comm_userid ="+userObject.user_userid+" and comm_private is null "
			+" AND (comm_datetime between '"+(from)+"' and '"+(to)+"'"
			+" OR comm_todatetime between '"+(from)+"' and '"+(to)+"') "+
			filter;

	var comm = null;
	var result = [];				
	comm = CRM.FindRecord("Communication,vCommunicationTask", _whereclause);
	comm.OrderBy="Comm_CommunicationId";
	while (!comm.eof) {
		var _sdate=new Date(comm.item("comm_datetime"));
		_sdate=adjustUserDate(_sdate);
		var _edate=new Date(comm.item("comm_todatetime"));
		_edate=adjustUserDate(_edate);
		var _cnote=new String(comm.item("comm_note"));
		if (!Defined(_cnote))
		  _cnote="";		
		var _clocation=new String(comm.item("comm_location"));
		if (!Defined(_clocation))
		  _clocation="";
		var resultArray = _cnote.split(" ");
		if(resultArray.length > _baseConfig.listdatawordlength){
				resultArray = resultArray.slice(0,_baseConfig.listdatawordlength);
				_cnote = resultArray.join(" ")+"...";
		}	
		//build our data section
		var _commsection=JSON.clone(_section);
		_commsection.name="commsection";
		_commsection.title="";
		_commsection.subheader="";
		_commsection.entity="communication";
		_commsection.data=[];
		
		var comm_location=JSON.clone(_SectionDataItem);	
		
		comm_location.name="comm_location";
		comm_location.caption=CRM.GetTrans("colnames","comm_location");		
		comm_location.newline=true;
		comm_location.value=comm_location;
		comm_location.componentType=getComponentType(10);
		comm_location.type=10;
		comm_location.displayvalue=_clocation;
		//	_commsection.data.push(comm_location);//this is causing a crash...
		
		var _item1=JSON.clone(_SectionDataItem);	
		_item1.name="comm_note";
		_item1.caption=CRM.GetTrans("colnames","comm_note");		
		_item1.newline=true;
		_item1.value=_cnote;
		_item1.componentType=getComponentType(11);
		_item1.type=11;
		_item1.displayvalue=_cnote;
		_commsection.data.push(_item1);			
		
		var _companyField={
				  name:"CmLi_Comm_CompanyId",
				  order:1,
				  type:56,
				  componentType:getComponentType(56),
				  lookup:"company",
				  newline:true,
				  viewfields:"comp_name"
				}
		var _company=getSearchListFieldsData("commlink", _companyField, comm.item(_companyField.name), false);
		var _item2=JSON.clone(_SectionDataItem);	
		_item2.name="CmLi_Comm_CompanyId";
		_item2.caption=CRM.GetTrans("colnames","CmLi_Comm_CompanyId");		
		_item2.newline=true;
		_item2.value=comm.item(_companyField.name);
		_item2.displayvalue=_company;
		_item2.componentType=getComponentType(56);
		_item2.type=56;		
		_commsection.data.push(_item2);	
		
		if (!Defined(_company))
			_company="";
		_item2.internallink={
			"entity":"company",
			"entityid":comm.item(_companyField.name),
			"icon":"mdi-office-building",
			"color":"orange"
		}	
		
		var _personField={
				  name:"CmLi_Comm_PersonId",
				  order:1,
				  type:56,
				  componentType:getComponentType(56),
				  lookup:"person",
				  newline:true,
				  viewfields:"pers_fullname"
				}			
		var _person=getSearchListFieldsData("commlink", _personField, comm.item(_personField.name), false);
		var _item3=JSON.clone(_SectionDataItem);	
		_item3.name="CmLi_Comm_PersonId";
		_item3.caption=CRM.GetTrans("colnames","CmLi_Comm_PersonId");		
		_item3.newline=true;
		_item3.value=comm.item(_personField.name);
		_item3.displayvalue=_person;
		_item3.componentType=getComponentType(56);
		_item3.type=56;		
		_commsection.data.push(_item3);			
		
		if (!Defined(_person))
			_person="";
		_item3.internallink={
			"entity":"person",
			"entityid":comm.item(_personField.name),
			"icon":"mdi-account",
			"color":"blue"
		}			
		
		var icslink = getCRMProtocol() + get_SERVER_NAME()
			+ ":" + get_SERVER_PORT() +
			CRM.Url("sagecrmws/ac2020/getIcs.asp") +isportalcode()+"commId=" + comm("comm_communicationid");
			
		var icsemaillink="";
		if (Defined(GetWebConfigValue("EmailHost")+"") && GetWebConfigValue("EmailHost")!=null)
		{
			icsemaillink = getCRMProtocol() + get_SERVER_NAME()
			+ ":" + get_SERVER_PORT() +
			CRM.Url("sagecrmws/ac2020/getIcs.asp") +isportalcode()+"email=y&commId=" + comm("comm_communicationid");	
		}
		
        var event =  { 
            "start" : getCalendarDate(_sdate),
            "end" : getCalendarDate(_edate),
            "startdisplay" : getUserDateSmart(_sdate,true),
            "enddisplay" : getUserDateSmart(_edate,true),
			"timediffdisplay":helpers_getTimeDiff(_sdate,_edate),
            "name" : comm.item("comm_subject"),
			"data": [{
					"sections": [_commsection]
				}],	
			"color" : calendarcolors[getCalendarStatusColor(comm.item("comm_status"),comm.item("comm_action"))],
            "eventId" : comm.RecordId,
			"category": userObject.user_fullname,
			"icslink":icslink
        };
        result.push(event);
        comm.NextRecord();
    }
	result.whereclause=_whereclause;
    return result;
}

%>