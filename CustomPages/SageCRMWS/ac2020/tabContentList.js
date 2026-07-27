<%

function getTabSearchObject(parentEntity,entityid, tab, filtersObj){
  parentEntity=new String(parentEntity);
  parentEntity=parentEntity.toLowerCase();
  var tres={	
	entity:parentEntity,
	parentEntity:parentEntity,
	parentEntityId:entityid,
	whereclause:'',
	orderby:'comm_datetime desc',
	view:'',
	linked:false
  }
  if ((tab.tabAction.toLowerCase()=="list_address")||(tab.tabAction.toLowerCase()=="listmx_address")||(tab.tabAction.toLowerCase()=="listac_address"))
  {
		tres.entity='address';
		tres.linked=false;
		if (parentEntity.toLowerCase()=="company")
		  tres.whereclause='AdLi_PersonID is null and adli_companyId='+entityid;
		else if (parentEntity.toLowerCase()=="person")
		  tres.whereclause='adli_personId='+entityid;
  }else
  if ((tab.tabAction.toLowerCase()=="list_address_link")||(tab.tabAction.toLowerCase()=="listmx_address_link")||(tab.tabAction.toLowerCase()=="listac_address_link"))
  {
		tres.orderby='adli_updateddate desc';
		tres.entity='address_link';
		tres.linked=false;
		tres.whereclause='adli_addressId='+entityid;
  }else
  if ((tab.tabAction.toLowerCase()=="list_library")||(tab.tabAction.toLowerCase()=="listmx_library")||(tab.tabAction.toLowerCase()=="listac_library"))
  {
		tres.orderby='libr_updateddate desc';
		tres.entity='library';
		tres.linked=false;
		tres.canUploadFile=true;
		if (parentEntity=='company')
		{
			tres.whereclause='Libr_CompanyId='+entityid;
        } else if (parentEntity == 'person' || parentEntity == 'people')
		{
			tres.whereclause='Libr_PersonId='+entityid;
		}else if ((parentEntity=='case')||(parentEntity=='cases'))
		{
			tres.whereclause='Libr_CaseId='+entityid;
		}else if (parentEntity=='opportunity')
		{
			tres.whereclause='Libr_OpportunityId='+entityid;
        } else if (parentEntity == 'lead' || parentEntity == 'leads')
		{
			tres.whereclause='libr_leadid='+entityid;
		}else if ((parentEntity=='quote')||(parentEntity=='quotes'))
		{
			tres.whereclause='Libr_QuoteId='+entityid;
		}else if ((parentEntity=='order')||(parentEntity=='orders'))
		{
			tres.whereclause='Libr_OrderId='+entityid;
		}else{
            //custom entity?..check field exists to do
			tres.whereclause='libr_'+parentEntity+'id='+entityid;
		}				
		if ((parentEntity=='communication')||(parentEntity=='communications'))
		{
			tres.canUploadFile=false;
		}
		tres.whereclause+=" and libr_private is null";
  }else   
  if ((tab.tabAction.toLowerCase()=="list_notes")||(tab.tabAction.toLowerCase()=="listmx_notes")||(tab.tabAction.toLowerCase()=="listac_notes"))
  {
		tres.orderby='notes_updateddate desc';
		tres.entity='notes';
		tres.linked=false;
		tres.whereclause='Note_ForeignTableId='+get_Note_ForeignTableId(parentEntity)+
						' and Note_ForeignId='+entityid;
  }else  
  if (tab.tabAction.indexOf('listCases.aspx')>0)
  {
		tres.orderby='case_updateddate desc';
		tres.entity='cases';
		tres.linked=true;
		if (parentEntity=='company')
		{
			tres.whereclause='case_primarycompanyid='+entityid;
		}else if (parentEntity=='person')
		{
			var bcases_ShowCompanyListUnderPerson=GetWebConfigValue("cases_ShowCompanyListUnderPerson")=="Y";
			if (bcases_ShowCompanyListUnderPerson)
			{
				var _personcompanyid=-1;
			    var qc=CRM.FindRecord("person","7200=7200 and pers_personid="+entityid);
				if (!qc.eof)
					_personcompanyid=qc("pers_companyid");
				
				//fall back if we need to
				if (!Defined(_personcompanyid))
					tres.whereclause='case_primarypersonid='+entityid;
				else
					tres.whereclause='case_primarycompanyid='+_personcompanyid;
			}else{
				tres.whereclause='case_primarypersonid='+entityid;
			}
		}
  }else   
  if (tab.tabAction.indexOf('listOpportunity.aspx')>0)
  {
		tres.orderby='oppo_updateddate desc';
		tres.entity='opportunity';
		tres.linked=true;
		if (parentEntity=='company')
		{
			tres.whereclause='oppo_primarycompanyid='+entityid;
		}else if (parentEntity=='person')
		{
			var bopportunities_ShowCompanyListUnderPerson=GetWebConfigValue("opportunities_ShowCompanyListUnderPerson")=="Y";
			if (bopportunities_ShowCompanyListUnderPerson)
			{
				var _personcompanyid=-1;
			    var qc=CRM.FindRecord("person","7201=7201 and pers_personid="+entityid);
				if (!qc.eof)
					_personcompanyid=qc("pers_companyid");
				
				//fall back if we need to
				if (!Defined(_personcompanyid))
					tres.whereclause='oppo_primarypersonid='+entityid;	
				else
					tres.whereclause='oppo_primarycompanyid='+_personcompanyid;		
				
			}else{
				tres.whereclause='oppo_primarypersonid='+entityid;
			}
		}
  }else if (tab.tabAction.indexOf('listCommunications.aspx')>0){
		tres.orderby='comm_datetime desc';
		tres.entity='communication';
		tres.view='vcommunication';
		tres.linked=false;
		if (parentEntity=='company')
		{
			tres.whereclause='cmli_comm_companyid='+entityid;
		}else if (parentEntity=='person')
		{
			tres.whereclause='cmli_comm_personid='+entityid;
		}else if (parentEntity=='cases')
		{
			tres.whereclause='comm_caseid='+entityid;
		}else if (parentEntity=='opportunity')
		{
			tres.whereclause='comm_opportunityid='+entityid;
		}else if (parentEntity=='lead')
		{
			tres.whereclause='comm_leadid='+entityid+" or cmli_comm_leadid="+entityid;
		}else if ((parentEntity=='solution')||(parentEntity=='solutions'))
		{
			tres.whereclause='comm_solutionid='+entityid;	
		}else if ((parentEntity=='quote')||(parentEntity=='quotes'))
		{
			tres.whereclause='comm_quoteid='+entityid;		
		}else if ((parentEntity=='order')||(parentEntity=='orders'))
		{
			tres.whereclause='comm_orderid='+entityid;					
		}else{
            //custom entity?..check field exists to do
			tres.whereclause='comm_'+parentEntity+'id='+entityid;
		}		
		tres.whereclause+=" and comm_private is null";
  }else if (tab.tabAction.indexOf('listPeople.aspx')>0){
		tres.orderby='pers_lastname,pers_firstname desc';
		tres.entity='person';
		tres.linked=true;
		tres.whereclause='pers_companyid='+entityid;
  }else if (tab.tabAction.indexOf('listcustomfiles.aspx')>0){
    
  }else if (tab.tabAction.indexOf('listQuotes.aspx')>0){
		tres.orderby='quot_updateddate desc';
		tres.entity='quotes';
		tres.linked=true;
		if (parentEntity=='company')
		{
			tres.whereclause='Oppo_PrimaryCompanyId='+entityid;
		}else if (parentEntity=='person')
		{
			tres.whereclause='Oppo_PrimaryPersonId='+entityid;
		}else
		{
			tres.whereclause='Quot_opportunityid='+entityid;
		}
  }else if (tab.tabAction.indexOf('listOrders.aspx')>0){
		tres.orderby='orde_updateddate desc';
		tres.entity='orders';
		tres.linked=true;
		if (parentEntity=='company')
		{
			tres.whereclause='Oppo_PrimaryCompanyId='+entityid;
		}else if (parentEntity=='person')
		{
			tres.whereclause='Oppo_PrimaryPersonId='+entityid;
		}else
		{
			tres.whereclause='orde_opportunityid='+entityid;  
		}
  }else if ((tab.tabcustomfilename)&&(tab.tabcustomfilename.indexOf('list_')==0))
  {
		tres.entity=tab.tabcustomfilename.substring(5);
		if (!Defined(tab.tabwheresql))
		{
			//we ge here and we guess..its a tracking screen?
			var _tmptbl=getTableInfo(parentEntity);
			tres.whereclause=_tmptbl.idfield+'='+entityid;
		}else{
            tres.whereclause = tab.tabwheresql + '=' + entityid; //EG prefix_companyid=123...as we are in the parent..to do..allow for a tab under person display company data
            var _farray = tab.tabwheresql.split("_");
            if (tres.whereclause != "") {
                tres.whereclause += " and " + _farray[0] + "_deleted is null";
            }
		}
  }else if ((tab.tabcustomfilename)&&((tab.tabcustomfilename.indexOf('listmx_')==0)||(tab.tabcustomfilename.indexOf('listac_')==0)))
  {
		tres.entity=tab.tabcustomfilename.substring(7);
		if (!Defined(tab.tabwheresql))
		{
			//we ge here and we guess..its a tracking screen?
			var _tmptbl=getTableInfo(parentEntity);
			tres.whereclause=_tmptbl.idfield+'='+entityid;
		}else{
			tres.whereclause=tab.tabwheresql+'='+entityid;
		}
  }else {
		//summary screen maybe...
		tres.entity='';
  }			
  
  //any filters to add in?
  if ((!filtersObj)||(filtersObj.length==0))
  {
	var _tempscreen=getFilterScreen(tab.tabName);
	if (_tempscreen)
		filtersObj=_tempscreen.formElements;
  }  
  if ((filtersObj)&&(filtersObj.length>0))
  {	
    for(var tt=0;tt<filtersObj.length;tt++)
	{
		if ((typeof filtersObj[tt].value)=="object")  
		{
			if ((filtersObj[tt].value.value!='All')&&(filtersObj[tt].value.value!='sagecrm_code_all'))
			{
				if (tres.whereclause!="")
					tres.whereclause+= " and ";
				tres.whereclause += filtersObj[tt].name+"='" +filtersObj[tt].value.value+"' ";
			}
		}
		else{
			if (filtersObj[tt].value!='All')
			{
				if (tres.whereclause!="")
				  tres.whereclause+= " and ";			
				tres.whereclause += "("+filtersObj[tt].name+" like '" +filtersObj[tt].value+"%' ";
				if ((filtersObj[tt].value==null)||(filtersObj[tt].value==""))
				{
					tres.whereclause += "or ("+filtersObj[tt].name+" is null) ";
				}
				tres.whereclause += ")";
			}
		}
	}
  }else{
	if (tab.tabAction.indexOf('listPeople.aspx')>0){
		tres.whereclause+=" and (pers_status<>'inactive' or pers_status is null)";
	}
  }
  return tres;
}

    function getCommsIcon(val) {
        var res = "";
        val = new String(val);
        val = val.toLowerCase();
        switch (val) {
            case "phoneout":
                res = "mdi-phone-outgoing";
                break;
            case "phonein":
                res = "mdi-phone-incoming";
                break;
            case "emailout":
                res = "mdi-email-outline";
                break;
            case "emailin":
                res = "mdi-email-arrow-left";
                break;
            case "letterout":
                res = "mdi-text-box-minus";
                break;
            case "letterin":
                res = "mdi-text-box-plus";
                break;
            case "smsout":
                res = "mdi-message-alert-outline";
                break;
            case "smsin":
                res = "mdi-message-alert-outline";
                break;				
            case "vacation":
                res = "mdi-sun-clock-outline";
                break;
            case "todo":
                res = "mdi-calendar-check-outline";
                break;
            case "meeting":
                res = "mdi-account-group";
                break;
            case "demo":
                res = "mdi-ev-plug-chademo";
                break;
            case "emarketingemail":
                res = "mdi-email-seal-outline";
                break;				
            default:
                res = "mdi-comment";
                break;
        }
        return res;
    }

function getFilterScreen(entity) {
    var entcode = new String(entity);
    entcode = entcode.toLowerCase();
    if (entcode == "progress")
        return null;
	
    if (entcode == "cases")
        entcode = "case";
    else if (entcode == "opportunities")
        entcode = "opportunity";
    else if (entcode == "communications")
        entcode = "communication";
    else if (entcode == "people")
        entcode = "person";	
    else if (entcode == "documents")
        entcode = "library";		

	if ((entcode!="opportunitypipeline")&&(entcode!="casepipeline"))
	{	
		var testtable=getTableInfo(entcode);
		if (!Defined(testtable.name)){
		  return null;
		}
	}

    var useScreen = entcode + "officeintfilter";

    //first screen
    var _crmfilterscreen = getNewScreen(entcode, useScreen, "", entcode, true);

    //fallback when the screen might be misnamed
    if (entcode == "case" && _crmfilterscreen.formElements.length == 0) {
        useScreen = "casesofficeintfilter";
        _crmfilterscreen = getNewScreen(entcode, useScreen, "", entcode, true);
    }
    if (_crmfilterscreen.formElements.length == 0) {

        if (entcode == "casepipeline") {
            var _defaultFilter = JSON.clone(_MyFormElement);
            _defaultFilter.name = "case_stage";
            _defaultFilter.caption = CRM.GetTrans("ColNames", "case_stage");
            _defaultFilter.componentType = "MyFormSelect";
            _defaultFilter.options = getOptions("case_stage", true, true);
            _defaultFilter.value = { text: CRM.GetTrans("case_stage", "All"), value: "All" };
            _defaultFilter.defaultvalue = { text: CRM.GetTrans("case_stage", "All"), value: "All" };	
            _crmfilterscreen.formElements.push(_defaultFilter);
        } else
            if (entcode == "opportunitypipeline") {
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "oppo_stage";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "oppo_stage");
                _defaultFilter.componentType = "MyFormSelect";
                _defaultFilter.options = getOptions("oppo_stage", true, true);
                _defaultFilter.value = { text: CRM.GetTrans("oppo_stage", "All"), value: "All" };
                _defaultFilter.defaultvalue = { text: CRM.GetTrans("oppo_stage", "All"), value: "All" };
                _crmfilterscreen.formElements.push(_defaultFilter);
            } else if ((entcode == "opportunity") || (entcode == "opportunities")) {
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "oppo_status";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "oppo_status");
                _defaultFilter.componentType = "MyFormSelect";
                _defaultFilter.options = getOptions("oppo_status", true, true);

                _defaultFilter.value = { text: CRM.GetTrans("oppo_status", "All"), value: "All" };
                _defaultFilter.defaultvalue = { text: CRM.GetTrans("oppo_status", "All"), value: "All" };
                _crmfilterscreen.formElements.push(_defaultFilter);

            } else if ((entcode == "case") || (entcode == "cases")) {
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "case_status";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "case_status");
                _defaultFilter.componentType = "MyFormSelect";
                _defaultFilter.options = getOptions("case_status", true, true);

                _defaultFilter.value = { text: CRM.GetTrans("case_status", "All"), value: "All" };
                _defaultFilter.defaultvalue = { text: CRM.GetTrans("case_status", "All"), value: "All" };
                _crmfilterscreen.formElements.push(_defaultFilter);
            } else if ((entcode == "communication") || (entcode == "communications")) {
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "comm_status";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "comm_status");
                _defaultFilter.componentType = "MyFormSelect";
                _defaultFilter.options = getOptions("comm_status", true, true);
                _defaultFilter.value = { text: CRM.GetTrans("GenCaptions", "All"), value: "All" };
                _defaultFilter.defaultvalue = { text: CRM.GetTrans("GenCaptions", "All"), value: "All" };
                _crmfilterscreen.formElements.push(_defaultFilter);
                var _defaultFilter2 = JSON.clone(_MyFormElement);
                _defaultFilter2.name = "comm_action";
                _defaultFilter2.caption = CRM.GetTrans("ColNames", "comm_action");
                _defaultFilter2.componentType = "MyFormSelect";
                _defaultFilter2.options = getOptions("comm_action", true, true);
                _defaultFilter2.value = { text: CRM.GetTrans("GenCaptions", "All"), value: "All" };
                _defaultFilter2.defaultvalue = { text: CRM.GetTrans("GenCaptions", "All"), value: "All" };
                _crmfilterscreen.formElements.push(_defaultFilter2);				
            } else if ((entcode == "person") || (entcode == "people")) {
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "pers_firstname";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "pers_firstname");
                _defaultFilter.componentType = "MyFormInput";
                _defaultFilter.value = "";
                _defaultFilter.defaultvalue = "";
                _crmfilterscreen.formElements.push(_defaultFilter);
            } else if ((entcode == "quotes") || (entcode == "quote")) {
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "quot_status";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "quot_status");
                _defaultFilter.componentType = "MyFormSelect";
                _defaultFilter.options = getOptions("orqu_status", true, true);
                _defaultFilter.value = { text: CRM.GetTrans("quot_status", "Active"), value: "Active" };
                _defaultFilter.defaultvalue = { text: CRM.GetTrans("quot_status", "Active"), value: "Active" };
                _crmfilterscreen.formElements.push(_defaultFilter);
            } else if ((entcode == "orders") || (entcode == "order")) {
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "orde_status";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "orde_status");
                _defaultFilter.componentType = "MyFormSelect";
                _defaultFilter.options = getOptions("orqu_status", true, true);
                _defaultFilter.value = { text: CRM.GetTrans("orde_status", "Active"), value: "Active" };
                _defaultFilter.defaultvalue = { text: CRM.GetTrans("orde_status", "Active"), value: "Active" };
                _crmfilterscreen.formElements.push(_defaultFilter);
            } else if (entcode == "library") {
				
				 var _defaultFilterFname = JSON.clone(_MyFormElement);
                _defaultFilterFname.name = "libr_filename";
                _defaultFilterFname.caption = CRM.GetTrans("ColNames", "libr_filename");
                _defaultFilterFname.componentType = "MyFormInput";
                _defaultFilterFname.defaultvalue = "";
                _crmfilterscreen.formElements.push(_defaultFilterFname);
				
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "libr_note";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "libr_note");
                _defaultFilter.componentType = "MyFormTextArea";
                _defaultFilter.defaultvalue = "";
                _crmfilterscreen.formElements.push(_defaultFilter);
            } else if (entcode == "notes") {
                var _defaultFilter = JSON.clone(_MyFormElement);
                _defaultFilter.name = "note_note";
                _defaultFilter.caption = CRM.GetTrans("ColNames", "note_note");
                _defaultFilter.componentType = "MyFormTextArea";
                _defaultFilter.defaultvalue = "";
                _crmfilterscreen.formElements.push(_defaultFilter);
            }

    }
    return _crmfilterscreen;
}

function getTabAddressLinkList(tobj, filtersObj, page, slimversion){
    var NumberOfRecordsReturned = _baseConfig.listlength;
    var itemsPerPage = 20;//clever

    NumberOfRecordsReturned = new Number(itemsPerPage);

	_adrlinksql="select distinct top 10 AdLi_CompanyID as EntityID, AdLi_Type as [linktype],'company' as Entity "+
							" , (select comp_name from vcompany where Comp_CompanyId=AdLi_CompanyID) as 'entitytitle' "+
							" from vAddress_Link "+
							" where AdLi_CompanyID is not null "+
							" and AdLi_AddressId in ("+tobj.parentEntityId+")"+
							" union "+
							" select distinct top 10 AdLi_PersonID as EntityID, AdLi_Type as [linktype], 'person' as Entity "+
							" , (select pers_fullname from vSearchListPerson where pers_personid=AdLi_PersonID) as 'entitytitle' "+
							" from vAddress_Link "+
							" where AdLi_PersonID is not null "+
							" and AdLi_AddressId in ("+tobj.parentEntityId+")"
						
    var q = CRM.CreateQueryObj(_adrlinksql);
	q.SelectSQL();

    var recordcount = q.recordcount;

	var tableData=[];
	var _recCount=0;
	while(!q.eof)
	{
		_recCount++;
	  var _tmpobj={
			"count":_recCount,
			"entityid": q.FieldValue("EntityID"),
			"linktype": q.FieldValue("linktype"),
			"entity":q.FieldValue("Entity"),
			"hasInternalLink":true,
			"entitytitle":q.FieldValue("entitytitle"),
			"tilecolor":getTileColour(q.FieldValue("Entity")),
			"tileicon":getTileIcon(q.FieldValue("Entity"))
	  }  
	  tableData.push(_tmpobj);
	  q.NextRecord();
	}

    var _title = "";
    var res = {
        "screenMetadata": {
            "lang": getUserLang()
        },
        "data": {
            "recordcount": recordcount,
            "errormessage": "",
            "slimversion": slimversion,
            "totalfieldcount": 3,
            "Entity": tobj.entity,
            "parentEntity": tobj.parentEntity,
            "parentEntityId": tobj.parentEntityId,
            "linked": tobj.linked,
            "hasInternalLink": tobj.linked,
            "page": page,
            "MaxNumberOfRecordsReturned": NumberOfRecordsReturned,
            "searchstring": tobj.whereclause,
            "orderby": tobj.orderby,
            "sortBy": tobj.sortBy,
            "sortDesc": tobj.sortDesc,
            "title": _title,
			"tableData": tableData,
			"tableColumns": [
			  {
				"value": "__Select__",
				"text": "",
				"sortable": false
			  },
			  {
				"value": "entitytitle",
				"text": CRM.GetTrans("colNames","book_title"),
				"sortable": false				
			  },
			  {
				"value": "linktype",
				"text": CRM.GetTrans("colNames","adli_type"),
				"sortable": false
			  }
			]
        }
    }
    return res;
	
}

function getTabContentList(tobj, filtersObj, page, slimversion) {
	var _timetracker=[];
	var method_TIMESTART = new Date().getTime();	
	_timetracker.push({ stage: 0, time:new Date().getTime()-method_TIMESTART});	

	if (tobj.entity.toLowerCase()=="address_link"){
		return getTabAddressLinkList(tobj, filtersObj, page, slimversion);
	}
	
    var errormessage = "";
    if (tobj.entity + '' == 'undefined') {
        tobj.entity = 'opportunity';
        tobj.searchString = 'oppo_primarycompanyid=-1';
        tobj.title = CRM.GetTrans("Grid", tobj.entity + "List");
         tobj.orderBy = 'oppo_updateddate desc';
    }
    var NumberOfRecordsReturned = _baseConfig.listlength;
    var itemsPerPage = Request.Form('itemsPerPage');
    if (((itemsPerPage + "") == "undefined") || (itemsPerPage == null) || (itemsPerPage == ""))
        itemsPerPage = _baseConfig.listlength;
    NumberOfRecordsReturned = new Number(itemsPerPage);

	_timetracker.push({ stage: 1, time:new Date().getTime()-method_TIMESTART});
    var fields = getSearchListFields(tobj.entity);
	_timetracker.push({ stage: 2, time:new Date().getTime()-method_TIMESTART});
    //get the data
    var tableNameView = getTableNameView(tobj.entity);
	_timetracker.push({ stage: 3, time:new Date().getTime()-method_TIMESTART});
    var _tmptableinfo = getTableInfo(tobj.entity);
	_timetracker.push({ stage: 4, time:new Date().getTime()-method_TIMESTART});

    if ((tobj.view != '')&&(tobj.view != null)&&(Defined(tobj.view)))
        tableNameView = tobj.view;

    if (tobj.entity.toLowerCase() == "communication") {
        //clever fix for sites with bad metadata
        tableNameView = "communication,vcommunication";
    }
	

    var q = CRM.Findrecord(tableNameView, tobj.whereclause);
	_timetracker.push({ stage: 5, time:new Date().getTime()-method_TIMESTART});	
	if (tobj.entity.toLowerCase()=="address"){
		//default to first column asc...this is what CRM does
        if (fields.length > 0) {
            tobj.sortBy = fields[0].name;
            tobj.sortDesc = false;
            tobj.orderby = fields[0].name + " asc";
        }
	}
    if (tobj.orderby == "") {
        //default to first column desc
        if (fields.length > 0) {
            tobj.sortBy = fields[0].name;
            tobj.sortDesc = true;
            tobj.orderby = fields[0].name + " desc";
        }
    } else {
        var orderBy_arr = tobj.orderby.split(" ");
        tobj.sortBy = orderBy_arr[0];
        tobj.sortDesc = false;
        if (orderBy_arr[1].toLowerCase() == "desc")
            tobj.sortDesc = true;
    }
    if (_tmptableinfo.isProgressTable) {
        tobj.orderby = _tmptableinfo.prefix + "_createddate asc";
        tobj.sortBy = _tmptableinfo.prefix + "_createddate";
        tobj.sortDesc = false;
        tobj.title = CRM.GetTrans("TabNames", "Tracking");
    }
	_timetracker.push({ stage: 6, time:new Date().getTime()-method_TIMESTART});

	//var recordcount = q.recordcount;
	var _countfrom=tobj.view;
	if (_countfrom=="")
		_countfrom=tobj.entity;
	if (_countfrom=="address")
		_countfrom="vaddressExchange";
	var _countwry="select count("+_tmptableinfo.idfield+") as 'count' from "+_countfrom+" where 8274=8274 and "+tobj.whereclause;

	var _countwryq=null;
	var recordcount =-1;
	try{
		_countwryq=CRM.CreateQueryObj(_countwry);
		_countwryq.SelectSQL();
		recordcount = _countwryq.FieldValue('count');
		_timetracker.push({ stage: 7, time:new Date().getTime()-method_TIMESTART});
	}catch(_countwryerror){
		Response.Write("Error in SQL:"+ _countwry+"<br>"+_countwryerror.message);
		throw "Error in SQL:"+ _countwry+"<br>"+_countwryerror.message;
	}
	//OKAY SO...some clever stuff here...
	//we added in "OFFSET y ROWS FETCH NEXT x ROWS ONLY" to speed things up SO
	//this also reruns the query but its quicker
	q.OrderBy = tobj.orderby+" OFFSET "+((page-1)*NumberOfRecordsReturned)+" ROWS FETCH NEXT "+NumberOfRecordsReturned+" ROWS ONLY;";
		_timetracker.push({ stage: 8, time:new Date().getTime()-method_TIMESTART});
	tobj.orderby =q.OrderBy;

    var tableData = [];
    var rowCount = 0;
_timetracker.push({ stage: 9, time:new Date().getTime()-method_TIMESTART});	
    var _getTileIcon = getTileIcon(tobj.entity);
    var _getTileColour = getTileColour(tobj.entity);
	//removed this as now using OFFSET...see above a few lines
    //var startFrom = (((NumberOfRecordsReturned * page) - NumberOfRecordsReturned) + 1);
	var startFrom=0;
_timetracker.push({ stage: 10, time:new Date().getTime()-method_TIMESTART});	
	
    while (!q.eof) {
        rowCount++;
        if (rowCount >= startFrom) {
            var _recordid = q.RecordID;
           // if (tobj.entity == "communication")
           //     _recordid = q("CmLi_CommLinkId");
            _tmpobj = {
                "count": rowCount,
                "entityid": _recordid,
                "entity": tobj.entity,
                "icon": _getTileIcon,
                "color": _getTileColour,
                "hasInternalLink": _tmptableinfo.primaryEntity,
                "externallink": {
                    "url": "",
                    "icon": _getTileIcon,
                    "color": _getTileColour
                },
				"pagelink": {
                    "url": "",
                    "icon": _getTileIcon,
                    "color": _getTileColour
                },				
                "loadfielddatalinks": [],	
                "__Select__": true
            }
            if (tobj.entity == "notes") {
                _tmpobj.hasInternalLink = false;
            }
			if (tobj.entity == "address") {
                _tmpobj.hasExternalMapLink = true;
				var _mapAddress=getMapAddress(q);
				_mapAddress=_mapAddress.replace(/" "/g,"%20");
				var _url="https://www.google.com/maps?q=" + _mapAddress;
				_tmpobj.externalmaplink = {
					"type": "map",	
					"color":"grey",
					"icon":"mdi-comment-outline",
					"url":_url
				};				
            }
			if (tobj.entity == "communication"){
				_tmpobj.hasInternalDialogLink = false;
				if ((q.item("Comm_action")=="EmailIn")||(q.item("Comm_action")=="EmailOut")||(q.item("Comm_type")=="Email"))
				{
					_tmpobj.hasInternalDialogLink = true;
					_tmpobj.dialogLink = {
						"type": "email",
						"color":"grey",
						"icon":"mdi-comment-outline",
						"url":getCRMProtocol() + get_SERVER_NAME()
						+ ":" + get_SERVER_PORT() +CRM.Url("sagecrmws/ac2020/selectComm.asp")+"&entityid="+q.RecordID
					};
				}
			}
            var _tabtable = getTableInfo(tobj.entity)
            var _xfield = {
                type: "31",
                name: _tabtable.idfield,
                lookup: tobj.entity
            }
            _tmpobj.externallink.url = getExternalLink(_xfield, q);
			_tmpobj.pagelink.url = getPageLink(_xfield, q);
			
            if (tobj.entity == "library") {
                //link to file
                _tmpobj.downloadlink = getCRMProtocol() + get_SERVER_NAME()
                    + ":" + get_SERVER_PORT() +
                    CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp") +isportalcode()+"id=" + q.RecordID +
                    "&entity=" + tobj.parentEntity + "&entityid=" + tobj.parentEntityId;
            }else if (tobj.entity == "communication") {
                //link to eml or ICS file...if the comm type matches
				if (q.item("comm_type")=="Appointment"){
					if (((G_appMode=="AC") &&(GetWebConfigValue("comm_enableICSAC")=="Y"))||
						((G_appMode=="MX") &&(GetWebConfigValue("comm_disableICSMX")!="Y")))
						{
							_tmpobj.downloadlink = getCRMProtocol() + get_SERVER_NAME()
								+ ":" + get_SERVER_PORT() +
								CRM.Url("sagecrmws/ac2020/getICSac.asp") +isportalcode()+
								"commId="+ q.item("comm_communicationid");
						}	
				}else if (q.item("comm_type")=="Email"){
					_tmpobj.downloadlink = getCRMProtocol() + get_SERVER_NAME()
						+ ":" + get_SERVER_PORT() +
						CRM.Url("sagecrmws/ac2020/getCommunicationEML.asp") +isportalcode()+"id=" + q.RecordID +
						"&entity=communication&entityid=" + q.item("comm_communicationid");
				}
            }
			
            for (var c = 0; c < fields.length; c++) {
                if ((slimversion) && c == 3)
                    break;

                if (fields[c].type == "51") {
                    _tmpobj[fields[c].name] = getCurrencyCID(q.item(fields[c].name + "_CID")) + " " + getSearchListFieldsData(tobj.entity, fields[c], q.item(fields[c].name), true);
                } else {
                    _tmpobj[fields[c].name] = getSearchListFieldsData(tobj.entity, fields[c], q.item(fields[c].name), true);
                }
				if (fields[c].name=="comm_email"){
					if (commHasLibraryEmailFile(q.item("comm_communicationid")))
						_tmpobj[fields[c].name]="-";
				}
                var _fieldurl = "";

                var _compType = getComponentType(fields[c].type);
                if (_compType == "MyFormTextArea") {
                    if (isPortalRequest) {
                        _fieldurl = getCRMProtocol() + get_SERVER_NAME()
                            + ":" + get_SERVER_PORT() +
                            CRM.Url("sagecrmws/ac2020/getFieldData.asp") + "?entity=" + _tmpobj.entity + "&entityid=" + _tmpobj.entityid + "&field=" + fields[c].name;
                    } else {
                        _fieldurl = getCRMProtocol() + get_SERVER_NAME()
                            + ":" + get_SERVER_PORT() +
                            CRM.Url("sagecrmws/ac2020/getFieldData.asp") + "&entity=" + _tmpobj.entity + "&entityid=" + _tmpobj.entityid + "&field=" + fields[c].name;
                    }
					/*
					Removed as we do not do this here as this data is used in the AC/MX app
                    var securityoff = GetWebConfigValue("securityoff") == "true";
                    if (!securityoff) {
                        //now put in our normal SID...needed to work around browser security issue
                        var crmsid = getLastFullSID();
                        var thisSID = Request.QueryString("SID");
                        if (crmsid != "") {
                            _fieldurl = _fieldurl.replace(thisSID, crmsid);
                        }
                    }
					*/
                    var _loadlink = {
                        "field": fields[c].name,
                        "url": _fieldurl
                    }
                    _tmpobj.loadfielddatalinks.push(_loadlink);
                }
                if (fields[c].name == "comm_action") {
                    _tmpobj.color = "primary";
                    var xs = new String(q.item(fields[c].name));
                    if ((xs == "PhoneOut") || (xs == "EmailOut") || (xs == "LetterOut") || (xs == "FaxOut") || (xs == "SMSOut"))
                        _tmpobj.color = "secondary";
                    _tmpobj.icon = getCommsIcon(xs);
                }				
				if (_tabtable.isProgressTable){
						if (fields[c].name.toLowerCase()==(_tabtable.prefix.toLowerCase()+"_duration")){
							//we do not add in _duration..blanking this to hide it
							_tmpobj[_tabtable.prefix.toLowerCase()+"_duration"] 	= "";
						}
				}			
            }
            if ((tobj.entity == "communication") && (q.item("Comm_Type") == "Appointment")) {
                //a column to show things like meeting attendees
                _tmpobj["comm_meetingattendees"] = "";
                //get users
                var commusersql = "select User_FullName from vusers where user_userid in (select cmli_comm_userid from comm_link " +
                    "where CmLi_Comm_CommunicationId=" + q.RecordID + ")";
                var commusersqlq = CRM.CreateQueryObj(commusersql);
                commusersqlq.SelectSQL();
                while (!commusersqlq.eof) {
                    if (_tmpobj["comm_meetingattendees"] != "")
                        _tmpobj["comm_meetingattendees"] += ";";
                    _tmpobj["comm_meetingattendees"] += commusersqlq.FieldValue("User_FullName");
                    commusersqlq.NextRecord();
                }
            }
			tableData.push(_tmpobj);
            if (rowCount >= (NumberOfRecordsReturned * page))
                break;
        }
        q.NextRecord();
    }
	_timetracker.push({ stage: 11, time:new Date().getTime()-method_TIMESTART});	
    var tableColumns = [];
    tableColumns.push({
        "value": "__Select__",
        "text": "",
        "fieldType": "",
        "sortable": false
    });
    var _sortable = true;
    if (_tmptableinfo.isProgressTable) {
        _sortable = false;
    }
	_timetracker.push({ stage: 12, time:new Date().getTime()-method_TIMESTART});	
    for (var c = 0; c < fields.length; c++) {
        if ((slimversion) && c == 3)
            break;


        var _compType = getComponentType(fields[c].type);
        if (fields[c].name == "comm_email")
            _compType = "MyFormHTMLViewer";

        tableColumns.push({
            "value": fields[c].name,
            "text": CRM.GetTrans("colNames", fields[c].name),
            "fieldType": _compType,
            "sortable": _sortable
        });
    }
	_timetracker.push({ stage: 13, time:new Date().getTime()-method_TIMESTART});	
    if (tobj.entity == "communication") {
        tableColumns.push({
            "value": "comm_meetingattendees",
            "text": CRM.GetTrans("Colnames", "cmli_comm_userid"),
            "fieldType": "10",
            "sortable": false
        });
        if (appname == "Accelerator") {
            tobj.linked = true;
			}
    }
    var entcode = new String(tobj.entity);
    if (entcode == "cases")
        entcode = "case";
_timetracker.push({ stage: 14, time:new Date().getTime()-method_TIMESTART});	
    var _crmfilterscreen = getFilterScreen(tobj.entity);
_timetracker.push({ stage: 15, time:new Date().getTime()-method_TIMESTART});		
    //reset any filters	
    if ((filtersObj) && (filtersObj.length > 0)) {
        for (var pp = 0; pp < _crmfilterscreen.formElements.length; pp++) {
            var ObjA = _crmfilterscreen.formElements[pp];
            for (var tt = 0; tt < filtersObj.length; tt++) {
                var ObjB = filtersObj[pp];
                try {
                    if (ObjA.name == ObjB.name) {
                        ObjA.value = ObjB.value;
                    }
                } catch (enameissue) {
                    //ignore
                }
            }
        }	
    }
	_timetracker.push({ stage: 16, time:new Date().getTime()-method_TIMESTART});	
    var _title = CRM.GetTrans("Grid", entcode + "List");
    if (_tmptableinfo.isProgressTable) {
        _title = CRM.GetTrans("TabNames", "Tracking");
        _crmfilterscreen = null;
    }
    var method_TIMEEND = new Date().getTime();
    var method_time = method_TIMEEND - method_TIMESTART;		
    var res = {
        "screenMetadata": {
            "lang": getUserLang(),
            "filterscreen": _crmfilterscreen,
			"method_time":method_time,
			"_timetracker":_timetracker
        },
        "data": {
            "recordcount": recordcount,
			"canUploadFile":tobj.canUploadFile,
            "errormessage": errormessage,
            "slimversion": slimversion,
            "totalfieldcount": fields.length,
            "Entity": tobj.entity,
            "parentEntity": tobj.parentEntity,
            "parentEntityId": tobj.parentEntityId,
            "linked": tobj.linked,
            "hasInternalLink": tobj.linked,
            "page": page,
            "MaxNumberOfRecordsReturned": NumberOfRecordsReturned,
            "searchstring": tobj.whereclause,
            "orderby": tobj.orderby,
            "sortBy": tobj.sortBy,
            "sortDesc": tobj.sortDesc,
            "title": _title,
            "tableData": tableData,
            "tableColumns": tableColumns
        }
    }
    return res;
}

%>