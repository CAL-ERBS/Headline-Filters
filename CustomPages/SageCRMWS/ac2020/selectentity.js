
<%

//ignoreTopContent is used for file email screens
function _selectEntity(entity,entityid,q, includetabs, ignoreTopContent,includeCustomtop)
{
	var res= JSON.clone(_base_selectEntity);
	res.screenMetadata.entity=entity;
	res.screenMetadata.entityid=entityid;
	res.screenMetadata.entityName=getEntityName(q,entity);
	res.screenMetadata.entityIcon=getEntityIcon(entity);
	res.screenMetadata.entityIconColor=getTileColour(entity);
	
	//for a company get the person..for oppos/cases get the company/person..for lead show the company?company link?
	//should be hyperlinks? and call selectentity
	var __entity=new String(entity);
	__entity=__entity.toLowerCase();
	var ti=getTableInfo(__entity);

	if (__entity=="users")
	{
		res.screenMetadata.entityName2=q.item("user_logon");
		res.screenMetadata.emailaddress=q.item("user_emailaddress");
	}else if (__entity=="company")
	{
		res.screenMetadata.entityName2=getEntityName(q,'person');
		res.screenMetadata.entityIcon2=getEntityIcon('person');
		res.screenMetadata.entityIconColor2=getTileColour('person');
		res.screenMetadata.emailaddress=getEntityEmail(q,'company');
		res.screenMetadata.favicon=getEntityFavIcon(q,'company');
	}else if (__entity=="person")
	{
		res.screenMetadata.entityName2=getEntityName(q,'company');
		res.screenMetadata.entityIcon2=getEntityIcon('company');
		res.screenMetadata.entityIconColor2=getTileColour('company');
		res.screenMetadata.emailaddress=getEntityEmail(q,'person');		
		res.screenMetadata.favicon=getEntityFavIcon(q,'person');		
	}else if ((__entity=="opportunity")||(__entity=="cases"))
	{
			res.screenMetadata.entityName2=getEntityName(q,'company');
			res.screenMetadata.entityIcon2=getEntityIcon('company');
			res.screenMetadata.entityIconColor2=getTileColour('company');
			res.screenMetadata.entityName3=getEntityName(q,'person');	
			res.screenMetadata.entityIcon3=getEntityIcon('person');
			res.screenMetadata.entityIconColor3=getTileColour('person');
			res.screenMetadata.emailaddress=getEntityEmail(q,__entity);
			res.screenMetadata.favicon=getEntityFavIcon(q,__entity);		
	}else if (__entity=="lead")
	{
		res.screenMetadata.entityName2=q("lead_personfirstname")+" "+q("lead_personlastname");
		res.screenMetadata.entityIconColor2=getTileColour('lead');
		res.screenMetadata.emailaddress=getEntityEmail(q,'lead');
		res.screenMetadata.favicon=getEntityFavIcon(q,'lead');
	}else if (__entity=="quotes")
	{
		res.screenMetadata.entityName2=q.item("quot_status");
		res.screenMetadata.entityName3=q.item("quot_description");
	}else if (__entity=="orders")
	{
		res.screenMetadata.entityName2=q.item("orde_status");
		res.screenMetadata.entityName3=q.item("orde_description");
	}else if (__entity=="library")
	{
		res.screenMetadata.entityName2=q("libr_type");
		res.screenMetadata.entityName3=q("libr_category");
	}else if (__entity=="communication")
	{
		res.screenMetadata.entityName2=CRM.GetTrans("comm_action",q.item("comm_action"));
		res.screenMetadata.entityName3=q.item("comm_status");
	}else if (__entity=="address")
	{
		res.screenMetadata.entityName2=q.item("addr_city");
		res.screenMetadata.entityName3=q.item("addr_postcode");
	} 
	//clever..topcontent for address search
	if ((_topscreen)&&(_topscreen.name=="AddressOfficeIntTop"))
	{
		res.screenMetadata.entityName=q.item('addr_address1');
		res.screenMetadata.entityIcon=getEntityIcon('address');
		res.screenMetadata.entityIconColor=getTileColour('address');
		res.screenMetadata.entityName2=q.item('addr_city');
		res.screenMetadata.entityIcon2=getEntityIcon('address');
		res.screenMetadata.entityIconColor2=getTileColour('address');
		res.screenMetadata.entityName3=q.item('addr_postcode');
		res.screenMetadata.entityIcon3=getEntityIcon('address');
		res.screenMetadata.entityIconColor3=getTileColour('address');		
	}	
	//clever..topcontent for library search
	if ((_topscreen)&&(_topscreen.name=="LibraryOfficeIntTop"))
	{
		res.screenMetadata.entityName=q.item('Libr_FileName');
		res.screenMetadata.entityIcon=getEntityIcon('library');
		res.screenMetadata.entityIconColor=getTileColour('library');
		res.screenMetadata.entityName2=q.item('Libr_Type');
		res.screenMetadata.entityIcon2=getEntityIcon('library');
		res.screenMetadata.entityIconColor2=getTileColour('library');
		res.screenMetadata.entityName3=q.item('Libr_Category');
		res.screenMetadata.entityIcon3=getEntityIcon('library');
		res.screenMetadata.entityIconColor3=getTileColour('library');
	}	
	//includeCustomtop allows us use the custom OfficeIntTop screen
	if (ignoreTopContent!==true || includeCustomtop===true)	
	{
		//custom values
		var _topscreen="";
		var _topscreencacheKey="topscreen_"+entity+"_"+entity+"OfficeIntTop";
		var _topscreencacheres=getCache(_topscreencacheKey);
		if (_topscreencacheres){
			_topscreen = _topscreencacheres;
		}else{
			_topscreen=	(entity,entity+"OfficeIntTop");
			setCache(_topscreencacheKey,_topscreen);
		}
		if ((_topscreen)&&(_topscreen.formElements))
		{
			if (_topscreen.formElements.length>0)
			{
				res.screenMetadata.entityName=getSearchListFieldsData(entity, _topscreen.formElements[0], q.item(_topscreen.formElements[0].name), true);	
				if (Defined(res.screenMetadata.entityName)&& (res.screenMetadata.entityName.length>50))
				{
					res.screenMetadata.entityName=res.screenMetadata.entityName.substring(0,50)+"...";
				}			
			}
			if (_topscreen.formElements.length>1)
			{
				var __entityName2=getSearchListFieldsData(entity, _topscreen.formElements[1], q.item(_topscreen.formElements[1].name), true);
				if (Defined(__entityName2)&& (__entityName2.length>50))
				{
					res.screenMetadata.entityName2=__entityName2.substring(0,50)+"...";
				}else if (Defined(__entityName2))
				{
					res.screenMetadata.entityName2=__entityName2;
				}	
			}
			if (_topscreen.formElements.length>2)
			{
				var __entityName3=getSearchListFieldsData(entity, _topscreen.formElements[2], q.item(_topscreen.formElements[2].name), true);
				if (Defined(__entityName3)&& (__entityName3.length>50))
				{
					res.screenMetadata.entityName3=__entityName3.substring(0,50)+"...";
				}else if (Defined(__entityName3))
				{
					res.screenMetadata.entityName3=__entityName3;
				}
			}
		}
	}
    res.screenMetadata.tilecolor=getTileColour(entity);


	//get tabs
	if (includetabs!==false)
	{	
		res.screenMetadata.tabs=getScreenTabs(entity,entityid);
	}	
	entity=new String(entity);
	if ((entity.toLowerCase()!="address")&&(entity.toLowerCase()!="library")&&(entity.toLowerCase()!="communication")){
	  res.screenMetadata.entitytag=getEntityTag(entity, entityid);
	}
    if (ignoreTopContent!==true)	
	{

		//get activity for graph
		var actdata=getEntityActivityData(entity, entityid, res.screenMetadata);
		res.screenMetadata.activitydata=actdata;

			/*
			REMOVE THIS!!!!
		activitydatalabels=[];
		var monthNameList = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		__now=new Date();
		__now.setMonth(__now.getMonth()+1);
		for(var x=0; x<12; ++x) {
			activitydatalabels.push(monthNameList[__now.getMonth()]);
			__now.setMonth(__now.getMonth()+1);
		}
		//res.screenMetadata.activitydatalabels=activitydatalabels;	
			*/
		if ((entity!="communication")&&(entity!="communications")){
			if (actdata.commsCount>0)	
				res.screenMetadata.activitydataText1=CRM.GetTrans("Accelerator","Communicationsthisyear")+": "+actdata.commsCount;
			if (actdata.caseCount>0)
				res.screenMetadata.activitydataText2=CRM.GetTrans("Accelerator","ActiveCases")+": "+actdata.caseCount;
			if (actdata.oppoCount>0)
				res.screenMetadata.activitydataText3=CRM.GetTrans("Accelerator","ActiveOpportunities")+": "+actdata.oppoCount;
		}
		if ((entity=="person")||(entity=="company"))
		{
			if (actdata.quotCount>0)
				res.screenMetadata.activitydataText4=CRM.GetTrans("Accelerator","ActiveQuotes")+": "+actdata.quotCount;
			if (actdata.ordeCount>0)
				res.screenMetadata.activitydataText5=CRM.GetTrans("Accelerator","ActiveOrders")+": "+actdata.ordeCount;		
		}else
		if (entity=="opportunity")
		{
			if (actdata.quotCount>0)
				res.screenMetadata.activitydataText2=CRM.GetTrans("Accelerator","ActiveQuotes")+": "+actdata.quotCount;
			if (actdata.ordeCount>0)
				res.screenMetadata.activitydataText3=CRM.GetTrans("Accelerator","ActiveOrders")+": "+actdata.ordeCount;
		}
	}
	if (entity.toLowerCase()=="communication"){
		 ti.hascommunications=false;
	}
	res.screenMetadata.canfile=ti.hascommunications==true;	
	res.screenMetadata.hasCommunications=ti.hascommunications;
	res.screenMetadata.canBookmark=ti.canBookmark;
	res.screenMetadata.canEdit=ti.canEdit;
	if (_topscreen)
		res.screenMetadata.screenUsed=_topscreen.name;
	
	if (entity.toLowerCase()=="person")
	{
		if (((G_appMode=="AC") &&(GetWebConfigValue("person_enablevcardAC")=="Y"))||
			((G_appMode=="MX") &&(GetWebConfigValue("person_disablevcardMX")!="Y")))
		{
			//link to generate an VCF file
			res.screenMetadata.downloadlink = getCRMProtocol() + get_SERVER_NAME()
					+ ":" + get_SERVER_PORT() +
					CRM.Url("sagecrmws/ac2020/qrbusinesscardp.asp") +isportalcode()+"id=" + entityid +
					"&entity=" + entity + "&entityid=" + entityid+ "&download=Y";	
		}
	}		
	if (entity.toLowerCase()=="library" && !isportalcode())
	{
		//link to file
		res.screenMetadata.downloadlink = getCRMProtocol() + get_SERVER_NAME()
			+ ":" + get_SERVER_PORT() +
			CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp") +isportalcode()+"id=" + entityid +
			"&entity=" + entity + "&entityid=" + entityid;			
	}else if (entity.toLowerCase()=="communication")
	{
		if ((q.item("Comm_action")=="EmailIn")||(q.item("Comm_action")=="EmailOut")||(q.item("Comm_type")=="Email") && !isportalcode()){
			//link to generate an EML file
			res.screenMetadata.downloadlink = getCRMProtocol() + get_SERVER_NAME()
				+ ":" + get_SERVER_PORT() +
				CRM.Url("sagecrmws/ac2020/getCommunicationEML.asp") +isportalcode()+"id=" + entityid +
				"&entity=" + entity + "&entityid=" + entityid;			
		}else
		if (q.item("Comm_action")=="Meeting")
		{
			if (((G_appMode=="AC") &&(GetWebConfigValue("comm_enableICSAC")=="Y"))||
				((G_appMode=="MX") &&(GetWebConfigValue("comm_disableICSMX")!="Y")))
			{
				//generate ics file -so can be added to phone/outlook calendar etc
				res.screenMetadata.downloadlink = getCRMProtocol() + get_SERVER_NAME()
					+ ":" + get_SERVER_PORT() +
					CRM.Url("SageCRMWS/ac2020/getICSac.asp") +isportalcode()+"commId=" + entityid;				
			}
		}
	}	

	var _comms_permission=false;
	if (entity.toLowerCase()!="communication")
		_comms_permission=hasPermissionInsert("communication");
	
	if (!_comms_permission)
	{	
		res.screenMetadata.canfile=false;
	}
	if ((entity.toLowerCase()!="address")){
		res.screenMetadata.isbookmarked=getIsBookmarked(entity,entityid);
	}
	//get sections for main tab?
			
	var sections=getScreenSections(entity, q);
	
	//clever...for communications
	if (entity.toLowerCase()=="communication")
	{
		if ((q.item("Comm_action")=="EmailIn")||(q.item("Comm_action")=="EmailOut")||(q.item("Comm_type")=="Email")){
			var _defaultEmail = JSON.clone(_MyFormElement);
			_defaultEmail.name = "comm_email";
			_defaultEmail.caption = CRM.GetTrans("ColNames", "comm_email");
			_defaultEmail.componentType = "MyFormHTMLViewer";
			_defaultEmail.value = ""
			_defaultEmail.displayvalue=q.item("comm_email");  
			 sections[0].data.push(_defaultEmail);
		
			var _defaultfrom = JSON.clone(_MyFormElement);
			_defaultfrom.name = "comm_from";
			_defaultfrom.caption = CRM.GetTrans("ColNames", "comm_from");
			_defaultfrom.componentType = "MyFormInput";
			_defaultfrom.value = "";
			_defaultfrom.newline=true;
			_defaultfrom.displayvalue=q.item("comm_from");  
			var _defaultto = JSON.clone(_MyFormElement);
			_defaultto.name = "comm_to";
			_defaultto.caption = CRM.GetTrans("ColNames", "comm_to");
			_defaultto.componentType = "MyFormInput";
			_defaultto.value = "";
			_defaultto.newline=true;
			_defaultto.displayvalue=q.item("comm_to");  
			var _defaultsubject = JSON.clone(_MyFormElement);
			_defaultsubject.name = "comm_subject";
			_defaultsubject.caption = CRM.GetTrans("ColNames", "comm_subject");
			_defaultsubject.componentType = "MyFormInput";
			_defaultsubject.value = "";
			_defaultsubject.newline=true;
			_defaultsubject.displayvalue=q.item("comm_subject");  	
			sections[0].data.splice(0,0,_defaultfrom,_defaultto,_defaultsubject);		
			
			//********************************************
			//START check the library for a file
			//********************************************
				var libsql="select top 1 Libr_FileName,Libr_FilePath from vlibrary where Libr_FileName='email.html' and libr_communicationid="+q.item("comm_communicationid");
				var qlib=CRM.CreateQueryObj(libsql);
				qlib.SelectSQL();
				var hasComm_email=false;
				if (!qlib.eof){
					var Libr_FileName=qlib.FieldValue("Libr_FileName");
					var _fullpath=getLibraryRootPath()+qlib.FieldValue("Libr_FilePath")+"\\"+Libr_FileName;
					//get the file
					if (FileExists(_fullpath)){
						var _defaultEmail = JSON.clone(_MyFormElement);
						_defaultEmail.name = "comm_email";
						_defaultEmail.caption = CRM.GetTrans("ColNames", "comm_email");
						_defaultEmail.componentType = "MyFormHTMLViewer";
						_defaultEmail.value = ""
						_defaultEmail.displayvalue=readFile(_fullpath);  
						// Remove BOM if present..utf 8 code
						if ( _defaultEmail.displayvalue.charCodeAt(0) === 239) 
							 _defaultEmail.displayvalue =  _defaultEmail.displayvalue.substring(3);		
						sections[0].data.push(_defaultEmail);
						hasComm_email=true;
					}else
					  res.value="File does not exist at: "+_fullpath;
				}
			//********************************************
			//END check the library for a file
			//********************************************
			
		}else
		if (q.item("Comm_action")=="Meeting")
		{
			var _defaultlocation = JSON.clone(_MyFormElement);
			_defaultlocation.name = "comm_location";
			_defaultlocation.caption = CRM.GetTrans("ColNames", "comm_location");
			_defaultlocation.componentType = "MyFormInput";
			_defaultlocation.value = "";
			_defaultlocation.newline=true;
			_defaultlocation.displayvalue=q.item("comm_location");  
			sections[0].data.splice(0,0,_defaultlocation);		
		}
	}else
	//clever...for quotes /orders items
	if ((entity=="quotes")||(entity=="quote"))
	{
		var qSQL="select QuIt_LineItemID from QuoteItems where 290562=290562 and quit_orderquoteid="+entityid+" and quit_deleted is null order by QuIt_linenumber asc";
		var qQuit=CRM.CreateQueryObj(qSQL);
		qQuit.SelectSQL();
		var qsection=JSON.clone(_section);
		qsection.name="QuoteItems";
		qsection.title="Items";
		qsection.subheader="";
		qsection.entity=entity;
		qsection.data=[];		
		qsection.displayStyle="List";
		while(!qQuit.EOF)
		{			
			var qQuititem=CRM.Findrecord("QuoteItems","29056=29056 and QuIt_LineItemID="+qQuit("QuIt_LineItemID")+" and quit_deleted is null");
			var qsectionItem=null;
			if (qQuititem.item("QuIt_LineType")=="c")
				qsectionItem=getScreenSection("QuoteItems", qQuititem, "QuoteCommentItemSummary", CRM.GetTrans("TabNames", "Items"),true,true);				
			else 
			if (qQuititem.item("QuIt_LineType")=="f")
				qsectionItem=getScreenSection("QuoteItems", qQuititem, "QuoteFreeTextItemSummary", CRM.GetTrans("TabNames", "Items"),true,true);					
			else
				qsectionItem=getScreenSection("QuoteItems", qQuititem, "QuoteItemsSummary", CRM.GetTrans("TabNames", "Items"),true,true);		
			qsection.data.push(qsectionItem.data);
			qQuit.NextRecord();
		}
		sections.push(qsection);		
	}else if ((entity=="orders")||(entity=="order"))
	{	
		var qSQL="select OrIt_LineItemID from orderItems where 390562=390562 and orit_orderquoteid='"+entityid+"' and orit_deleted is null  order by OrIt_LineType asc";
		var qQuit=CRM.CreateQueryObj(qSQL);
		qQuit.SelectSQL();
		var qsection=JSON.clone(_section);
		qsection.name="OrderItems";
		qsection.title="Items";
		qsection.subheader="";
		qsection.entity=entity;
		qsection.data=[];		
		qsection.displayStyle="List";
		while(!qQuit.EOF)
		{			
			var qQuititem=CRM.Findrecord("orderItems","29056=29056 and OrIt_LineItemID="+qQuit("OrIt_LineItemID")+" and orit_deleted is null");
			var qsectionItem=null;
			if (qQuititem.item("orit_LineType")=="c")
				qsectionItem=getScreenSection("orderItems", qQuititem, "OrderCommentItemSummary", CRM.GetTrans("TabNames", "Items"),true,true);				
			else 
			if (qQuititem.item("orit_LineType")=="f")
				qsectionItem=getScreenSection("orderItems", qQuititem, "OrderFreeTextItemSummary", CRM.GetTrans("TabNames", "Items"),true,true);					
			else
				qsectionItem=getScreenSection("orderItems", qQuititem, "OrderItemsSummary", CRM.GetTrans("TabNames", "Items"),true,true);				
			qsection.data.push(qsectionItem.data);
			qQuit.NextRecord();
		}
		sections.push(qsection);		
	}
	res.data[0].sections=(sections);

	return res;
}

function getIsBookmarked(book_entityname,book_entityid)
{
	var sql = "select * from Bookmarks WITH (NOLOCK) where " +
		"3360=3360 and book_userid=" + getUserId() + " and book_deleted is null "+
		"and book_entityname='"+book_entityname+"' and book_entityid="+book_entityid+
		" order by book_updateddate desc";
	var q=CRM.CreateQueryObj(sql);
	q.SelectSQL();
	if(!q.eof)
	{
		return true;	
	}
	//check now crm favourites
	var _table=getTableInfo(book_entityname);
	var _sql="select usrc_RecordId as book_entityid,usrc_EntityId from UserRecords	"+
			"where usrc_Type='Favourites' and usrc_EntityId="+_table.tableId+" and usrc_UserId="+getUserId()+
			" and usrc_RecordId="+book_entityid;
	var q2=CRM.CreateQueryObj(_sql);
	q2.SelectSQL();
	if(!q2.eof)
	{
		return true;	
	}
	return false;
}


function getEntityActivityData(entity, entityid, refObj)
{
	var cacheKey="getEntityActivityData_"+entity+"_"+entityid;
	var cacheres=getCache(cacheKey);
	if (cacheres){
		return cacheres;
	}	
	
	entity=new String(entity);
	entity=entity.toLowerCase();
	var res=[0,0,0,0,0,0,0,0,0,0,0,0];
	var comms_whereclause="";
	var case_whereclause="";
	var oppo_whereclause="";
	var quot_whereclause="";
	var orde_whereclause="";
	var orderquotes_whereclause="";
	var ti=getTableInfo(entity);

	if (entity=="company")
	{
		comms_whereclause="CmLi_Comm_CompanyID="+entityid;
		case_whereclause="case_primaryCompanyID="+entityid;
		oppo_whereclause="oppo_primaryCompanyID="+entityid;
		orderquotes_whereclause="comp_companyid="+entityid;
	}else if (entity=="person")
	{
		comms_whereclause="CmLi_Comm_PersonID="+entityid;
		case_whereclause="case_primarypersonID="+entityid;		
		oppo_whereclause="oppo_primarypersonID="+entityid;
		orderquotes_whereclause="pers_personid="+entityid;		
		var bcases_ShowCompanyListUnderPerson=GetWebConfigValue("cases_ShowCompanyListUnderPerson")=="Y";
		var bopportunities_ShowCompanyListUnderPerson=GetWebConfigValue("opportunities_ShowCompanyListUnderPerson")=="Y";
		var qc=null;
		var _personcompanyid=-1;			
		if ((bcases_ShowCompanyListUnderPerson)||(bopportunities_ShowCompanyListUnderPerson))
		{
			qc=CRM.FindRecord("person","3350=3350 and pers_personid="+entityid);
			if ((!qc.eof)&&(qc("pers_companyid")))
				_personcompanyid=qc("pers_companyid");			
		}
		if (bcases_ShowCompanyListUnderPerson)
		{
			case_whereclause='case_primarycompanyid='+_personcompanyid;
		}
		if (bopportunities_ShowCompanyListUnderPerson)
		{
			oppo_whereclause='oppo_primarycompanyid='+_personcompanyid;
		}		

	}else if (entity=="lead")
	{
		comms_whereclause="Comm_LeadID="+entityid+" or cmli_comm_leadid="+entityid;
	}else if (entity=="opportunity")
	{
		comms_whereclause="Comm_OpportunityID="+entityid;
		quot_whereclause="quot_opportunityid="+entityid;
		orde_whereclause="orde_opportunityid="+entityid;
	}else if (entity=="quotes")
	{
		comms_whereclause="Comm_QuoteId="+entityid;
	}else if (entity=="orders")
	{
		comms_whereclause="Comm_OrderId="+entityid;
	}else if (entity=="cases")
	{
		comms_whereclause="Comm_CaseID="+entityid;
	}else{
		if (ti.hascommunications)
		{
			comms_whereclause="Comm_"+entity+"ID="+entityid;
		}
	}
	if (comms_whereclause=="")
		return res;

	//comms
	var commsCount=0;
	var _comms_permission=hasPermissionView("communication");
		
	if (_comms_permission)
	{
		var sql="select count(*) as activitycount,MONTH(Comm_Datetime) as activitymonth , year(Comm_Datetime) as activityyear "+
				"from "+
            " vCommunication where 9034=9034 and comm_deleted is null and " + comms_whereclause +" and  year(Comm_Datetime)=year(getdate()) "+
				"group by MONTH(Comm_Datetime),year(Comm_Datetime) "+
				"order by activityyear, activitymonth"; 
		var resObjComm=getActivityData(sql,res,1);
		res=resObjComm.data;
		commsCount=resObjComm.count;
	}
	var caseCount=0;
	var oppoCount=0;
	var quotCount=0;
	var ordeCount=0;
			
	if ((entity=="company")||(entity=="person"))
	{
		//cases
		var _case_permission=hasPermissionView("cases");
		if (_case_permission)
		{
			var sqlcases="select count(*) as activitycount,MONTH(case_createddate) as activitymonth , year(case_createddate) as activityyear "+
					"from "+
					"vCases where 9035=9035 and "+case_whereclause+" "+
					"AND case_status='"+getDefaultStatus('case_status')+"' "+
					"group by MONTH(case_createddate),year(case_createddate) "+
					"order by activityyear, activitymonth"; 
					
			var resObjCase=getActivityData(sqlcases,res,10);
			res=resObjCase.data;
			caseCount=resObjCase.count;		
		}
		var _oppo_permission=hasPermissionView("opportunity");
		if (_oppo_permission)
		{					
			var sqloppos="select count(*) as activitycount,MONTH(oppo_createddate) as activitymonth , year(oppo_createddate) as activityyear "+
					"from "+
					"vOpportunity where 9036=9036 and "+oppo_whereclause+" "+
					"AND oppo_status='"+getDefaultStatus('oppo_status')+"' "+					
					"group by MONTH(oppo_createddate),year(oppo_createddate) "+
					"order by activityyear, activitymonth"; 
			var resObjOppo=getActivityData(sqloppos,res,10);	
			//Response.Write(JSON.stringify(resObjOppo);
			res=resObjOppo.data;	
			oppoCount=resObjOppo.count;			

			//quotes
			var sqlquot="select count(*) as activitycount,MONTH(quot_createddate) as activitymonth , year(quot_createddate) as activityyear "+
					"from "+
					"vSummaryQuote where 9037=9037 and "+orderquotes_whereclause+" "+
					"AND Quot_Status='Active' "+
					"group by MONTH(quot_createddate),year(quot_createddate) "+
					"order by activityyear, activitymonth"; 

			var resObjQuot=getActivityData(sqlquot,res,10);	
			res=resObjQuot.data;	
			quotCount=resObjQuot.count;				

			//orders
			var sqlorder="select count(*) as activitycount,MONTH(orde_createddate) as activitymonth , year(orde_createddate) as activityyear "+
					"from "+
					"vSummaryOrder where 9038=9038 and "+orderquotes_whereclause+" "+
					"AND Orde_Status='Active' "+
					"group by MONTH(orde_createddate),year(orde_createddate) "+
					"order by activityyear, activitymonth"; 
					
			var resObjQuot=getActivityData(sqlorder,res,10);	
			res=resObjQuot.data;	
			ordeCount=resObjQuot.count;	
		}
	}else 
	if (entity=="opportunity")
	{	
			//quotes
			var sqlquot="select count(*) as activitycount,MONTH(quot_createddate) as activitymonth , year(quot_createddate) as activityyear "+
					"from "+
					"vQuotes where 9039=9039 and "+quot_whereclause+" "+
					"AND Quot_Status='Active' "+
					"group by MONTH(quot_createddate),year(quot_createddate) "+
					"order by activityyear, activitymonth"; 

			var resObjQuot=getActivityData(sqlquot,res,10);	
			res=resObjQuot.data;	
			quotCount=resObjQuot.count;		
			//orders
			var sqlorder="select count(*) as activitycount,MONTH(orde_createddate) as activitymonth , year(orde_createddate) as activityyear "+
					"from "+
					"vOrders where 9040=9040 and "+orde_whereclause+" "+
					"AND Orde_Status='Active' "+
					"group by MONTH(orde_createddate),year(orde_createddate) "+
					"order by activityyear, activitymonth"; 
					
			var resObjQuot=getActivityData(sqlorder,res,10);	
			res=resObjQuot.data;	
			ordeCount=resObjQuot.count;			
	}
	// data:null, ....instead of null this was res but we dont use this data in the UI so
	// we have removed it.
	var returnValue= {
		data:null, 
		commsCount:commsCount,
		caseCount:caseCount,
		oppoCount:oppoCount,
		quotCount:quotCount,
		ordeCount:ordeCount
	};
	setCache(cacheKey,returnValue);
	return returnValue;
}

function getActivityData(sql,_p_res,activityWeight)
{
	var result={
			data:null,
			count:null,
			sql:sql
		};
	try{
		var qdata=CRM.CreateQueryObj(sql);
		qdata.SelectSQL();//weird thing....this nulls _p_res
		var resData=[];
		var resCount=0;
		while(!qdata.eof)
		{
			var xcount=(new Number(qdata.FieldValue("activitycount")));
			resCount+=xcount;
			xcount=xcount*activityWeight;
			resData.push({
				year:(new Number(qdata.FieldValue("activityyear"))),
				month:(new Number(qdata.FieldValue("activitymonth")))-1,
				count:xcount
			});
			qdata.NextRecord();
		}
		var __now=new Date();
		__now.setMonth(__now.getMonth()+1);
	
		for(var i=0; i<12; i++) {
			var mth=__now.getMonth();
			_p_res[i]+=0;
			
			for(var x=0;x<resData.length;x++)
			{
				var resDataObj=resData[x];	
				if (resDataObj.month==mth){
					_p_res[i]+=resDataObj.count;
				}
			}		
			__now.setMonth(__now.getMonth()+1);
		}	
		result= {
				data:_p_res,
				count:resCount,
				sql:sql,
				error:null
			};
	}catch(aeerr){
		result= {
				data:_p_res,
				count:resCount,
				sql:sql,
				error:"ERROR 728:"+aeerr.message
			};
	}		
	return result;
}
%>