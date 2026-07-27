<%

function getDefaultNewApptScreen(editMode, contextquery)
{

    var _CommfieldsToUse="'comm_datetime','comm_todatetime','comm_action','comm_status','comm_subject','comm_location','comm_note'";

    var sql="select colp_ColName as SeaP_ColName, @@rowcount as SeaP_Order,'' as SeaP_Jump, 'false' as SeaP_Required,"+
			"'' as SeaP_CreateScript, Colp_Restricted,ColP_EntryType,ColP_DefaultValue,ColP_EntrySize"+
			",ColP_LookupFamily,ColP_LookupWidth, ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, "+
			"Colp_ssViewField, ColP_LinkedField ,ColP_DefaultType, Colp_SearchSQL, '' as SeaP_OnChangeScript from Custom_Edits "+
			"where 	colp_ColName in ("+_CommfieldsToUse+") "+
			"and ColP_Entity='Communication' "+
			"and ColP_Deleted is null order by SeaP_Order";
    var q=CRM.CreateQueryObj(sql);
    q.SelectSQL();		

    var res= JSON.clone(_FormScreenMetadata);
    if (editMode)
    {
        res.name="EditAppointment";
        res.title=CRM.GetTrans("Button","Appointment");
    }else{
        res.name="NewAppointment";
        res.title=CRM.GetTrans("NewMenu","Appointment");
    }
    res.title=capitalize(res.title);
    res.subheader=capitalize(CRM.GetTrans("Entities","Appointment"));
    res.entity="appointment";
    res.content="";
    res.screenname="getDefaultNewApptScreen";
    res.hint="Create or Edit Communication screen apptofficeintnew in CRM to customise";	
    var tableobj=getTableInfo("communication");

    //assigned user id
    var formelmuser= JSON.clone(_MyFormElement);
    formelmuser.name="CmLi_Comm_UserId";
    formelmuser.caption=CRM.GetTrans("ColNames","CmLi_Comm_UserId");
    //get the users
    formelmuser.options=getOptionsUsers();	
    formelmuser.value=[];
    if (editMode)
    {
        //add all users
        var vallCommusersSQL="select CmLi_CommLinkId,CmLi_Comm_UserId "+
			"from Comm_Link where CmLi_Deleted is null "+
			"and CmLi_Comm_CommunicationId="+contextquery("Comm_CommunicationId");
        var vallCommusers=CRM.CreateQueryObj(vallCommusersSQL);
        vallCommusers.SelectSQL();
        while(!vallCommusers.eof){
            formelmuser.value.push({"text":getSelectUser(vallCommusers("CmLi_Comm_UserId")),
                "value":vallCommusers("CmLi_Comm_UserId")});	
            vallCommusers.NextRecord();
        }
    }else{
        //user..current user
        formelmuser.value.push({"text":getSelectUser(getUserId()),"value":getUserId()});
    }
    formelmuser.required=true;
    formelmuser.order=1;
    formelmuser.componentType=getComponentType("28");
    res.formElements.push(formelmuser);
		  
    while (!q.eof){

        var formelm=getNewScreenField(q,tableobj,null,null);		
        var SeaP_ColName=new String(q.FieldValue("SeaP_ColName"));
        SeaP_ColName=SeaP_ColName.toLowerCase();  

        if (SeaP_ColName=="comm_todatetime")
        {
            formelm.componentType=getComponentType("41");
            formelm.required=true;
            formelm.order=3;
            var _defaultval=null;
            if (editMode)
            {
				_defaultval=new Date(contextquery(SeaP_ColName));
				_defaultval=adjustUserDate(_defaultval);
            }else{
                _defaultval=new Date(); 
				_defaultval=adjustUserDate(_defaultval);
                _defaultval.setMinutes(_defaultval.getMinutes() + 30);
            }		 
			//round the time
				var minutes = _defaultval.getMinutes();
				var roundedMinutes = Math.ceil(minutes / 5) * 5;

				if (roundedMinutes === 60) {
					_defaultval.setHours(_defaultval.getHours() + 1);
					roundedMinutes = 0;
				}
				_defaultval.setMinutes(roundedMinutes);
				_defaultval.setSeconds(0);
				_defaultval.setMilliseconds(0);			
            formelm.value= { date: _defaultval.getFullYear()+"-"+
              padDate(_defaultval.getMonth()+1)+"-"+
              padDate(_defaultval.getDate()), time: padDate(_defaultval.getHours())+":"+padDate(_defaultval.getMinutes()) };
        }else if (SeaP_ColName=="comm_datetime")
        {	
            formelm.componentType=getComponentType("41");
            formelm.required=true;
            var _defaultval=null;
            if (editMode)
            {
                _defaultval=new Date(contextquery("comm_datetime"));
            }else{
                _defaultval=new Date(); 
            }					  
			_defaultval=adjustUserDate(_defaultval);
						
            formelm.order=2;
			//round the time
				var minutes = _defaultval.getMinutes();
				var roundedMinutes = Math.ceil(minutes / 5) * 5;

				if (roundedMinutes === 60) {
					_defaultval.setHours(_defaultval.getHours() + 1);
					roundedMinutes = 0;
				}
				_defaultval.setMinutes(roundedMinutes);
				_defaultval.setSeconds(0);
				_defaultval.setMilliseconds(0);				
            formelm.value= { date: _defaultval.getFullYear()+"-"+
              padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate()), 
                time: padDate(_defaultval.getHours())+":"+padDate(_defaultval.getMinutes()) };
        }else if (SeaP_ColName=="comm_location")
        {
            formelm.required=false;
            formelm.order=4;
            if (editMode)
            {
                formelm.value=contextquery(SeaP_ColName);
            }			  
        }else if (SeaP_ColName=="comm_action")
        {
            formelm.required=true;
            formelm.order=5;
            if (editMode)
            {
                formelm.value={text:CRM.GetTrans("comm_status",contextquery(SeaP_ColName)),value:contextquery(SeaP_ColName)} 
            }	else {
                formelm.value={text:CRM.GetTrans("comm_action","Meeting"),value:"Meeting"} 
            }
        }else if (SeaP_ColName=="comm_status")
        {
            formelm.required=true;
            formelm.order=6;
            if (editMode)
            {
                formelm.value={text:CRM.GetTrans("comm_status",contextquery(SeaP_ColName)),value:contextquery(SeaP_ColName)} 
            }else{
                formelm.value={text:CRM.GetTrans("comm_status",GetWebConfigValue("comm_status")),value:"Pending"} 
            }		  
        }else if (SeaP_ColName=="comm_subject")
        {
            formelm.required=true;
            formelm.order=5;
            if (editMode)
            {
                formelm.value=contextquery(SeaP_ColName);
            }		  
        }else if (SeaP_ColName=="comm_note")
        {
            formelm.componentType=getComponentType("11");
            formelm.order=6;
            if (editMode)
            {
                formelm.value=contextquery(SeaP_ColName);
            }		  
        }	  
        res.formElements.push(formelm);
        q.NextRecord();
    }	
    //order the data
    res.formElements.sort( formElements_order_compare );
    return res;
}


function getDefaultNewTaskScreen(editMode, contextquery)
{

    var _CommfieldsToUse="'comm_datetime','comm_action','comm_status','comm_subject','comm_note'";

    var sql="select colp_ColName as SeaP_ColName, @@rowcount as SeaP_Order,'' as SeaP_Jump, 'false' as SeaP_Required,"+
			"'' as SeaP_CreateScript, Colp_Restricted,ColP_EntryType,ColP_DefaultValue,ColP_EntrySize"+
			",ColP_LookupFamily,ColP_LookupWidth, ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, "+
			"Colp_ssViewField, ColP_LinkedField ,ColP_DefaultType, Colp_SearchSQL, '' as SeaP_OnChangeScript from Custom_Edits "+
			"where 	colp_ColName in ("+_CommfieldsToUse+") "+
			"and ColP_Entity='Communication' "+
			"and ColP_Deleted is null order by SeaP_Order";
    var q=CRM.CreateQueryObj(sql);
    q.SelectSQL();		

    var res= JSON.clone(_FormScreenMetadata);
    if (editMode)
    {
        res.name="EditTask";
        res.title=CRM.GetTrans("Button","Task");
    }else{
        res.name="NewTask";
        res.title=CRM.GetTrans("NewMenu","New Task");
    }
    res.title=capitalize(res.title);
    res.subheader=capitalize(CRM.GetTrans("Entities","communication"));
    res.entity="communication";
    res.content="";
    res.screenname="getDefaultNewTaskScreen";
    res.hint="Create screen communicationofficeintnew to customise";
    var tableobj=getTableInfo("communication");

    //assigned user id
    var formelmuser= JSON.clone(_MyFormElement);
    formelmuser.name="CmLi_Comm_UserId";
    formelmuser.caption=CRM.GetTrans("ColNames","CmLi_Comm_UserId");
    //get the users
    formelmuser.options=getOptionsUsers();	
    formelmuser.value=[];
    if (editMode)
    {
        formelmuser.componentType=getComponentType("21");		
        formelmuser.value={"text":getSelectUser(contextquery("CmLi_Comm_UserId")),"value":contextquery("CmLi_Comm_UserId")};	
    }else{
        //user..current user
        formelmuser.componentType=getComponentType("28");		
        formelmuser.value=[{"text":getSelectUser(getUserId()),"value":getUserId()}];
    }
    formelmuser.required=true;
    formelmuser.order=1;

    res.formElements.push(formelmuser);
		  
    while (!q.eof){

        var formelm=getNewScreenField(q,tableobj,null,null);		
        var SeaP_ColName=new String(q.FieldValue("SeaP_ColName"));
        SeaP_ColName=SeaP_ColName.toLowerCase();  

        if (SeaP_ColName=="comm_datetime")
        {
            formelm.componentType=getComponentType("41");
            formelm.required=true;

            formelm.order=2;
            var _defaultval=null;
            if (editMode)
            {
                _defaultval=new Date(contextquery("comm_datetime"));
            }else{
                _defaultval=new Date();
            }
			//time rounding
				var minutes = _defaultval.getMinutes();
				var roundedMinutes = Math.ceil(minutes / 5) * 5;

				if (roundedMinutes === 60) {
					_defaultval.setHours(_defaultval.getHours() + 1);
					roundedMinutes = 0;
				}
				_defaultval.setMinutes(roundedMinutes);
				_defaultval.setSeconds(0);
				_defaultval.setMilliseconds(0);
			
            formelm.value= { date: _defaultval.getFullYear()+"-"+
              padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate()), 
                time: padDate(_defaultval.getHours())+":"+padDate(_defaultval.getMinutes()) };
        }else if (SeaP_ColName=="comm_action")
        {
            formelm.required=true;
            formelm.order=3;
            if (editMode)
            {
                formelm.value={text:CRM.GetTrans("comm_status",contextquery(SeaP_ColName)),value:contextquery(SeaP_ColName)} 
            }		  
        }else if (SeaP_ColName=="comm_status")
        {
            formelm.required=true;
            formelm.order=4;
            if (editMode)
            {
                formelm.value={text:CRM.GetTrans("comm_status",contextquery(SeaP_ColName)),value:contextquery(SeaP_ColName)} 
            }else{
                formelm.value={text:CRM.GetTrans("comm_status",GetWebConfigValue("comm_status")),value:"Pending"} 
            }
        }else if (SeaP_ColName=="comm_subject")
        {
            formelm.required=true;
            formelm.order=5;
            if (editMode)
            {
                formelm.value=contextquery(SeaP_ColName);
            }
        }else if (SeaP_ColName=="comm_note")
        {
            formelm.componentType=getComponentType("11");
            formelm.order=6;
            if (editMode)
            {
                formelm.value=contextquery(SeaP_ColName);
            }
        }
        res.formElements.push(formelm);
        q.NextRecord();
    }	
    //order the data
    res.formElements.sort( formElements_order_compare );
    return res;
}
function formElements_order_compare( a, b ) {
    if ( a.order  < b.order ){
        return -1;
    }
    if ( a.order > b.order ){
        return 1;
    }
    return 0;
}

function getNewScreen(entity, screenName, contextentity, contextentityName, addAll, addinScreenName, editMode, searchMode)
{
    if (entity == "case")
        entity = "cases";
    else if (entity == "leads")
        entity = "lead";
    else if (entity == "appt")
        entity = "communication";

    if (contextentityName)
        contextentityName=contextentityName.toLowerCase();
	
	if ((entity!="opportunitypipeline")&&(entity!="casepipeline"))
	{    
		var tableobj=getTableInfo(entity);		
		if (!Defined(tableobj.name)){
		  //log to CRM's logs
		  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entcode is "+entity);
		  throw "No valid Entity found";
		}
	}
	screenName=escapeSQL(screenName);
	
	var tableobj=getTableInfo(entity);
		
	var _entityWhereFilter=  "and ColP_Entity='"+entity+"' ";
	//below used to build search screens
	if (searchMode===true)
		_entityWhereFilter="";
	
    var sql="select SeaP_ColName, SeaP_Order,SeaP_Jump, SeaP_Required,SeaP_CreateScript, Colp_Restricted,"+
            "ColP_EntryType,ColP_DefaultValue,ColP_EntrySize,ColP_LookupFamily,ColP_LookupWidth, "+
            "ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, Colp_ssViewField, ColP_LinkedField  "+
            ",ColP_DefaultType,Colp_SearchSQL,SeaP_OnChangeScript from Custom_Screens "+
            "left join Custom_Edits on SeaP_ColName=ColP_ColName "+
            "where 8430=8430 and SeaP_SearchBoxName= '"+screenName+"' "+
            _entityWhereFilter+
            "and SeaP_ColName<>'comm_secterr' "+
            "and Seap_DeviceID is null and ColP_Deleted is null and SeaP_Deleted is null "+
            "order by SeaP_Order";
    //we do this to cope with comm link fields
    if ((screenName.toLowerCase()=="communicationofficeintnew")||
        (screenName.toLowerCase()=="apptofficeintnew")||
		(screenName.toLowerCase()=="opportunitypipelineofficeintfilter")||
		(screenName.toLowerCase()=="casepipelineofficeintfilter"))
    {
        sql="select distinct SeaP_ColName, SeaP_Order,SeaP_Jump, SeaP_Required,CAST(SeaP_CreateScript AS NVARCHAR(MAX)) as SeaP_CreateScript, Colp_Restricted,"+
            "ColP_EntryType,ColP_DefaultValue,ColP_EntrySize,ColP_LookupFamily,ColP_LookupWidth, "+
            "ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, Colp_ssViewField, ColP_LinkedField  "+
            ",ColP_DefaultType,Colp_SearchSQL,CAST(SeaP_OnChangeScript AS NVARCHAR(MAX)) as SeaP_OnChangeScript from Custom_Screens "+
            "left join Custom_Edits on SeaP_ColName=ColP_ColName "+
            "where 8444=8444 and SeaP_SearchBoxName= '"+screenName+"' "+
            "and SeaP_ColName<>'comm_secterr' "+
            "and Seap_DeviceID is null and ColP_Deleted is null and SeaP_Deleted is null "+
            "order by SeaP_Order";
    }
    var q=null;
    try{
        q=CRM.CreateQueryObj(sql);
        q.SelectSQL();	
    }catch(e){
        if ((screenName.toLowerCase()=="communicationofficeintnew")||
			(screenName.toLowerCase()=="apptofficeintnew"))
        {
            sql="select SeaP_ColName, SeaP_Order,SeaP_Jump, SeaP_Required,SeaP_CreateScript, Colp_Restricted,"+
                "ColP_EntryType,ColP_DefaultValue,ColP_EntrySize,ColP_LookupFamily,ColP_LookupWidth, "+
                "ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, Colp_ssViewField, ColP_LinkedField  "+
                ",ColP_DefaultType,Colp_SearchSQL,SeaP_OnChangeScript from Custom_Screens "+
                "left join Custom_Edits on SeaP_ColName=ColP_ColName "+
                "where 8431=8431 and SeaP_SearchBoxName= '"+screenName+"' "+
                "and SeaP_ColName<>'comm_secterr' "+
                "and Seap_DeviceID is null and ColP_Deleted is null and SeaP_Deleted is null "+
                "order by SeaP_Order";
        }	
        q=CRM.CreateQueryObj(sql);
		try{
			q.SelectSQL();	
		}catch(errgfm){
			Response.Write("ERROR 5202:"+errgfm.message);
			Response.Write(sql);
			Response.End();
		}
    }
    if (q.eof){
        sql="select SeaP_ColName, SeaP_Order,SeaP_Jump, SeaP_Required,SeaP_CreateScript, Colp_Restricted,"+
                        "ColP_EntryType,ColP_DefaultValue,ColP_EntrySize,ColP_LookupFamily,ColP_LookupWidth, "+
                        "ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, Colp_ssViewField, ColP_LinkedField"+
                        ",ColP_DefaultType,Colp_SearchSQL,SeaP_OnChangeScript from Custom_Screens "+
                        "left join Custom_Edits on SeaP_ColName=ColP_ColName "+
                        "where 8432=8432 and SeaP_SearchBoxName= '"+entity+"NewEntry' and ColP_Entity='"+entity+"' "+
                        "and SeaP_ColName<>'comm_secterr' "+
                        "and Seap_DeviceID is null and ColP_Deleted is null and SeaP_Deleted is null "+
                        "order by SeaP_Order";		
        q=CRM.CreateQueryObj(sql);
        q.SelectSQL();	
    }
    var res= JSON.clone(_FormScreenMetadata);
    res.name=screenName;
    if (entity=="cases")
    {
        res.title=CRM.GetTrans("NewMenu","case");
    }else{
        res.title=CRM.GetTrans("NewMenu",entity);
    }
    if (editMode===true)
    {
        res.title=capitalize(CRM.GetTrans("Entities",entity));
    }
    res.subheader=capitalize(CRM.GetTrans("Entities",entity));
    res.entity=entity;
    res.content="";
		
    var cacheKey2="getCobj_CustomContent_"+screenName;
    var cacheres2=getCache(cacheKey2);
    if (cacheres2!=null){
        res.content = cacheres2;
    }else{		
        var sqlScreen="select Cobj_CustomContent from Custom_ScreenObjects where 9110=9110 and cobj_name='"+screenName+"'";
        var qsqlScreen=CRM.CreateQueryObj(sqlScreen);
        qsqlScreen.SelectSQL();		
        if (!qsqlScreen.eof){
            res.content=qsqlScreen("Cobj_CustomContent");
            if (!res.content)
                res.content="";
            setCache(cacheKey2,res.content);
        }		
    }
    var _lastfield="";
    while (!q.eof){
        formelm=getNewScreenField(q,tableobj, contextentity, contextentityName,addAll,editMode);
        if (_lastfield!=formelm.name)
        {
            if (formelm.name=="cmli_comm_userid")
            {
                if (editMode){
                    formelm.componentType=getComponentType("21");
                    formelm.required=true;		  
                    //user only
                    formelm.value={"text":getSelectUser(getUserId()),"value":getUserId()};				  
                }else{
                    formelm.componentType=getComponentType("28");
                    formelm.required=true;		  
                    formelm.value=[];
                    //user..current user
                    formelm.value.push({"text":getSelectUser(getUserId()),"value":getUserId()});
                }
            }else if (formelm.name=="comm_datetime")
            {
                //default to todays Date
                var _defaultval=new Date();
                formelm.value= { date: _defaultval.getFullYear()+"-"+padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate()), time: padDate(_defaultval.getHours())+":"+padDate(_defaultval.getMinutes()) };			  
            }else
                if (formelm.name=="comp_name")
                {
                    if (!isPortalRequest) {
                        formelm.dedupeurl=getCRMProtocol()+get_SERVER_NAME()
                            +":"+get_SERVER_PORT()+
                            CRM.Url("sagecrmws/ac2020/comp_dedupe.asp");
                    }
                }else		  
                    if (formelm.name=="pers_lastname")
                    {
                        if (!isPortalRequest) {
                            formelm.dedupeurl=getCRMProtocol()+get_SERVER_NAME()
                                +":"+get_SERVER_PORT()+
                                CRM.Url("sagecrmws/ac2020/pers_dedupe.asp");
                        }
                    }		  
            res.formElements.push(formelm);
        }
        _lastfield=formelm.name;
        q.NextRecord();			
    }
    if (addinScreenName===true)
    {
        //add in screen name...we need this for server side validation
        var formelmScreenName= JSON.clone(_MyFormElement);
        formelmScreenName.name="__screenName";
        formelmScreenName.value=screenName;
        formelmScreenName.hidden=true;
        formelmScreenName.caption="screenName";
        formelmScreenName.ColP_EntryType="10";
        res.formElements.push(formelmScreenName);
    }
    return res;
}

var Globalformelm=null;
function getNewScreenField(q, tableobj, contextentity, contextentityName, addAll, editmode)
{
    var formelm= JSON.clone(_MyFormElement);
    formelm.name=q.FieldValue("SeaP_ColName");
    formelm.caption=CRM.GetTrans("ColNames",q("SeaP_ColName"));
    formelm.ColP_EntryType=q.FieldValue("ColP_EntryType");
    formelm.ColP_LookupFamily=q.FieldValue("ColP_LookupFamily");
    formelm.SeaP_CreateScript=q.FieldValue("SeaP_CreateScript");
    formelm.filterSQL=q.FieldValue("Colp_SearchSQL");	
    formelm.onChangeScript=q.FieldValue("SeaP_OnChangeScript");	
	
    var DefaultCurrency="";
    if (formelm.componentType=="MyFormDateTime")
    {
        formelm.value={"date":"","time":""}
    }
    if (q.FieldValue("ColP_EntryType")=="22")
    {
        if (q.FieldValue("ColP_DefaultType")==2)
        {
            //user..current user
            formelm.value={"text":getSelectUser(getUserId()),"value":getUserId()}
        }else  if (q.FieldValue("ColP_DefaultType")==4)
        {
            //user..specific user
            formelm.value={"text":getSelectUser(q.FieldValue("ColP_DefaultValue")),"value":q.FieldValue("ColP_DefaultValue")}
        }
    } else 
        if (q.FieldValue("ColP_EntryType")=="23")
        {
            if (q.FieldValue("ColP_DefaultType")==1)
            {
                //team/channel -specific team
                formelm.value={"text":getSelectChannel(q.FieldValue("ColP_DefaultValue")),"value":q.FieldValue("ColP_DefaultValue")}
            }else if (q.FieldValue("ColP_DefaultType")==3)
            {
                //team/channel -current users team
                formelm.value={"text":getSelectChannel(getUser_PrimaryChannelId()),"value":getUser_PrimaryChannelId()}
            }
        }else
            if (q.FieldValue("ColP_EntryType")=="51")
            {
                //DefaultCurrency=getSysParam("BaseCurrency");
                //formelm.value={currency:DefaultCurrency,amount:q("ColP_DefaultValue")};
				//above 2 lines are ignoring the users preference
				var DefaultCurrency=getUserBaseCurrency();
				formelm.value={currency:DefaultCurrency,amount:q.FieldValue("ColP_DefaultValue")};
                formelm.options=getOptionsCurrency();
            }else if (q.FieldValue("ColP_EntryType")=="59")
            {
               if (Defined(q.FieldValue("ColP_DefaultValue"))&&(q.FieldValue("ColP_DefaultValue")!=""))
                {
                    formelm.value=getOptionsCurrencyById(q("ColP_DefaultValue")); 
                }else{
					formelm.value=getOptionsCurrencyById(getUserBaseCurrency());
				}
                formelm.options=getOptionsCurrency();
            }
            else if (q.FieldValue("ColP_EntryType")=="44")
            {
                formelm.value=getReferenceID(tableobj.name,tableobj.idfield,q.FieldValue("SeaP_ColName"));
            }else if (q.FieldValue("ColP_EntryType")=="41")
            {
                formelm.value={"date":"","time":""}
                var _defaultval=new Date();
				_defaultval=adjustUserDate(_defaultval);
                if (q.FieldValue("ColP_DefaultType")=="6")
                {
                    formelm.value= { date: _defaultval.getFullYear()+"-"+padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate()), time: padDate(_defaultval.getHours())+":"+padDate(_defaultval.getMinutes()) };			
                }else if (q.FieldValue("ColP_DefaultType")=="18")
                {
                    //add on ColP_DefaultValue minutes
                    _defaultval=addMinutes(_defaultval,q.FieldValue("ColP_DefaultValue"));
                    formelm.value= { date: _defaultval.getFullYear()+"-"+padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate()), time: padDate(_defaultval.getHours())+":"+padDate(_defaultval.getMinutes()) };			
                }
            }else if (q.FieldValue("ColP_EntryType")=="42")
            {
                var _defaultval=new Date();
				_defaultval=adjustUserDate(_defaultval);
                if (q.FieldValue("ColP_DefaultType")=="6")
                {
                    formelm.value= _defaultval.getFullYear()+"-"+padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate());
                }else if (q.FieldValue("ColP_DefaultType")=="18")
                {
                    //add on ColP_DefaultValue minutes
                    _defaultval=addMinutes(_defaultval,q.FieldValue("ColP_DefaultValue"));
                    formelm.value= _defaultval.getFullYear()+"-"+padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate());
                }
            }else{
                formelm.value=q.FieldValue("ColP_DefaultValue");
                if ((!formelm.value)||(formelm.value==null))
                    formelm.value='';
            }
    formelm.required=q.FieldValue("ColP_Required")=="Y";
    formelm.readonly=false;
    formelm.maxLength=getFieldMaxLength(tableobj.name,formelm.name,q.FieldValue("ColP_EntryType"));
    formelm.componentType=getComponentType(q.FieldValue("ColP_EntryType"));

    //check our context data also for a value
    try{
        if ((contextentity!=null)&&(contextentity+""!="undefined")&&(contextentity.RecordCount>0))
        {
            var mappedAddressFieldsArr=["addr_address1","addr_address2","addr_address3","addr_address4","addr_address5",
						"addr_city","addr_state","addr_country","addr_postcode"]
            if(formelm.name=="pers_website")
            {
                formelm.value=contextentity("comp_website");
            }else if(formelm.name=="emailfield_Business")
            {
                formelm.value= contextentity("Comp_EmailAddress");
            }else if(formelm.name=="phonefield_Business")
            {
                formelm.value= {areacode_value:contextentity("Comp_PhoneAreaCode"),
                    countrycode_value:contextentity("Comp_PhoneCountryCode"), 
                    phonenumber_value:contextentity("Comp_PhoneNumber")}
				
            }else{
                //check array
                for(var tt=0;tt<mappedAddressFieldsArr.length;tt++)
                {
                    if(formelm.name==mappedAddressFieldsArr[tt])
                    {
                        formelm.value= contextentity(mappedAddressFieldsArr[tt]);
                    }
                }
            }
				
        }
    }catch(e4)
    {
        //we ignore this
    }
    if (formelm.componentType=="MyFormLabelOnly")
    {
        formelm.readonly=true;
    }else
        if (q.FieldValue("ColP_EntryType")=="51")
        {
            if (typeof formelm.value==="number")
            {
                formelm.value={currency:getSysParam("BaseCurrency"),amount:formelm.value}
            }
        }else
            if (((q.FieldValue("ColP_EntryType")!="22")&&(q.FieldValue("ColP_EntryType")!="23")&&(q.FieldValue("ColP_EntryType")!="59"))&&
                (formelm.componentType=="MyFormSelect"))
            {
                formelm.value={"text":CRM.GetTrans(formelm.ColP_LookupFamily,formelm.value),"value":formelm.value}			
            }else 
                if (formelm.componentType=="MyFormSelectMultiple")
                {
                    var _musel=new String(formelm.value);
                    var _muselarr=_musel.split(",");
                    var _muselval=[];
                    for(var gg=0;gg<_muselarr.length;gg++)
                    {
                        var _musqlbase={"text":CRM.GetTrans(formelm.ColP_LookupFamily,_muselarr[gg]),"value":_muselarr[gg]};
                        _muselval.push(_musqlbase);
                    }
                    formelm.value=_muselval;		
                }  		

    if (formelm.componentType=="MyFormRemoteLookup")
    {
        formelm.icon=getEntityIcon(q.FieldValue("ColP_LookupFamily"));
        formelm.iconColor=getTileColour(q.FieldValue("ColP_LookupFamily"));
        formelm.entity=q.FieldValue("ColP_LookupFamily");
        ssaTable=getTableInfo(formelm.entity);
        if ((contextentity!=null)&&(Defined(contextentity))&&
			(contextentity+""!="undefined")&&(contextentity.RecordCount>0)&&
			(ssaTable.name==contextentityName))
        {
            var tmpsearchObject={fieldname:formelm.name,				
                searchfilter:{entity:formelm.entity,entityid:contextentity(ssaTable.idfield)}};		
            Glog("getScreenWithData doEntitySearch #2:"+formelm.entity);
            var es=doEntitySearch(formelm.entity,tmpsearchObject,"","",1);
            Glog("getScreenWithData doEntitySearch #2 records:"+es.data.tableData.length);
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
                Glog("getNewScreenField _displayText:"+_displayText);
                formelm.options.push(xitem);
                formelm.value=xitem;
            }
        }else
            if (typeof formelm.value==="number")
            {
                //we hit this if someone puts in custom code..EG DefaultValue=880;
                var tmpsearchObject={fieldname:formelm.name,
                    searchfilter:{entity:formelm.entity,entityid:formelm.value}};		
                Glog("getScreenWithData doEntitySearch #2:"+formelm.entity);
                var es=doEntitySearch(formelm.entity,tmpsearchObject,"","",1);
                Glog("getScreenWithData doEntitySearch #2 records:"+es.data.tableData.length);
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
                    Glog("getNewScreenField _displayText:"+_displayText);
                    formelm.options.push(xitem);
                    formelm.value=xitem;		
                }				
            }
        //check formelm.crmdefaulttype (17 is company and 16 is person)
        if (formelm.crmdefaulttype=="17")
        {
            //ssa table
            if (ssaTable.CompanyField)
                formelm.filterSQL="985=985 and "+ssaTable.CompanyField+"="+contextentity("comp_companyid")
        }else if (formelm.crmdefaulttype=="16")
        {
            if (ssaTable.PersonField)
                formelm.filterSQL="986=986 and "+ssaTable.PersonField+"="+contextentity("pers_personid");
            else if (ssaTable.CompanyField)
                formelm.filterSQL="987=987 and "+ssaTable.CompanyField+"="+contextentity("comp_companyid")
        }		
        if (q.FieldValue("Colp_Restricted")!=null)
        {
            var Colp_Restricted=new String(q.FieldValue("Colp_Restricted"));
            Colp_Restricted=Colp_Restricted.toLowerCase();
            if (Colp_Restricted.indexOf("primaryaccountid")>0)
            {
                Colp_Restricted=Colp_Restricted.replace("primaryaccountid","primarycompanyid");
            }
            formelm.filterObjectName=Colp_Restricted;	
        }
    }
	
    if (q.FieldValue("ColP_EntryType")=="11")
    {
        //textarea...done by default
    }else 		
        if (q.FieldValue("ColP_EntryType")=="41")
        {
            //date time =42...
            if ((typeof formelm.value==="string")&&(formelm.value!=""))
            {
                var _tmpdate=new Date(formelm.value);
                formelm.value= { date: _tmpdate.getFullYear()+"-"+padDate(_tmpdate.getMonth()+1)+"-"+padDate(_tmpdate.getDate()), time: padDate(_tmpdate.getHours())+":"+padDate(_tmpdate.getMinutes()) };
            }else if (typeof formelm.value==="date")
            {
                var _tmpdate=new Date(formelm.value);
                formelm.value= { date: _tmpdate.getFullYear()+"-"+padDate(_tmpdate.getMonth()+1)+"-"+padDate(_tmpdate.getDate()), time: padDate(_tmpdate.getHours())+":"+padDate(_tmpdate.getMinutes()) };
            }
        }else if (q.FieldValue("ColP_EntryType")=="42")
        {
            //date only=42...
            if ((typeof formelm.value==="string")&&(formelm.value!=null)&&(formelm.value.length>11))
            {
                var _tmpdate=new Date(formelm.value);
                formelm.value=_tmpdate.getFullYear()+"-"+padDate(_tmpdate.getMonth()+1)+"-"+padDate(_tmpdate.getDate());
            }else if (typeof formelm.value==="date")
            {
                var _tmpdate=new Date(formelm.value);
                formelm.value= _tmpdate.getFullYear()+"-"+padDate(_tmpdate.getMonth()+1)+"-"+padDate(_tmpdate.getDate());
            }
        }else 	
            if (q.FieldValue("ColP_EntryType")=="59")
            {
                //currency only
                if (typeof formelm.value==="number")
                {
                    formelm.value=getOptionsCurrencyById(formelm.value); 
                }else if (typeof formelm.value==="string")
                {
                    formelm.value=getOptionsCurrencyByName(formelm.value); 
                }
            }else 		
                if (q.FieldValue("ColP_EntryType")=="53")
                {
                    //get territories
                    formelm.options=getTerritoryOptions(q.FieldValue("ColP_LookupFamily"));
                }
                else if ((q.FieldValue("ColP_EntryType")=="21")||(q.FieldValue("ColP_EntryType")=="28")||(q.FieldValue("ColP_EntryType")=="27"))
                {
                    //get lookup
                    formelm.options=getOptions(q.FieldValue("ColP_LookupFamily"),(addAll===true),true);	
                }else if ((q.FieldValue("ColP_EntryType")=="22")||(q.FieldValue("ColP_EntryType")=="24"))
                {
	
                    //get the users
                    formelm.options=getOptionsUsers();		
                    if (typeof formelm.value==="number")
                    {
                        var _xuserval=new String(formelm.value);
                        formelm.value={"text":getSelectUser(formelm.value),"value":_xuserval}		
                    }	   
                }else if (q.FieldValue("ColP_EntryType")=="23")
                {
                    //get the teams/channel
                    formelm.options=getOptionsChannel();	
                    if (typeof formelm.value==="string")
                    {
                        var _getSelectChannelByName=getSelectChannelByName(formelm.value);
                        if ((!_getSelectChannelByName)||(_getSelectChannelByName==''))
                            formelm.value={"text":getSelectChannel(formelm.value),"value":formelm.value}
                        else
                            formelm.value={"text":formelm.value,"value":_getSelectChannelByName}	
                    }
                    else if (typeof formelm.value==="number")
                    {
                        formelm.value=new String(formelm.value);
                        formelm.value={"text":getSelectChannel(formelm.value),"value":formelm.value}
                    }
                }
	
    //*****************
    //create script...clever...
	Globalformelm=formelm;
    var SeaP_CreateScript=q.FieldValue("SeaP_CreateScript");
    var Caption=formelm.caption;
    var Required=formelm.required;
    var DefaultValue=formelm.value;
    var ReadOnly=formelm.readonly;
    var Hidden=formelm.hidden;
    var SearchSQL=formelm.filterSQL;	
    var LinkedElement=formelm.LinkedElement;
		
    try{
        if (!editmode) {
            if (Defined(SeaP_CreateScript)){
                SeaP_CreateScript = SeaP_CreateScript.replace(/CRM.GetContextInfo/ig, "GetContextInfo");
                SeaP_CreateScript = SeaP_CreateScript.replace(/eWare.GetContextInfo/ig, "GetContextInfo");
                eval(SeaP_CreateScript);
            }
        }
    }catch(e){
        //ignore
        formelm.errormessage=e.message;
    }
    formelm.filterSQL=SearchSQL;
    formelm.caption=Caption;
    formelm.required=Required;
    formelm.value=DefaultValue;
	//fix up?
	//normal select
	if ((formelm.componentType == "MyFormSelect")&&(q.FieldValue("ColP_EntryType")=="21")&&(typeof formelm.value==="string")) {
		formelm.value = { "text": CRM.GetTrans(formelm.name, formelm.value), "value": formelm.value }
	}else
	if ((formelm.componentType == "MyFormSelect")&&(q.FieldValue("ColP_EntryType")=="22")&&(typeof formelm.value==="string")) {
		//user select
		formelm.value={"text":getSelectUser(formelm.value),"value":formelm.value}		
	}else
	if ((formelm.componentType == "MyFormSelect")&&(q.FieldValue("ColP_EntryType")=="23")&&(typeof formelm.value==="string")) {
		//team/channel select
		var _getSelectChannelByName=getSelectChannelByName(formelm.value);
                        if ((!_getSelectChannelByName)||(_getSelectChannelByName==''))	
                            formelm.value={"text":getSelectChannel(formelm.value),"value":formelm.value}
                        else
                            formelm.value={"text":formelm.value,"value":_getSelectChannelByName}	
	}	
    formelm.readonly=ReadOnly;
    if (SeaP_CreateScript && (SeaP_CreateScript.indexOf('Readonly')>-1))
        formelm.readonly=Readonly; //fallback as lots of systems use lowercase o in Readonly	
    formelm.hidden=Hidden;
    formelm.LinkedElement=LinkedElement;
    //*****************	
    if (editmode)
    {
        setEditModeValues(formelm, contextentity);
    }
	
    formelm.defaultvalue=formelm.value;	
    return formelm;
}

//copy CRM api
function RemoveLookup(valuetoRemove){
	//we use Globalformelm here
	var newOptions=[];
	for(var qq=0;qq<Globalformelm.options.length;qq++)
	{
	   var qqObj=Globalformelm.options[qq];
	   if (qqObj.value!=valuetoRemove){
		 newOptions.push(qqObj);
	   }
	}
	Globalformelm.options=newOptions;	
}

function setEditModeValues(formelm, contextentity)
{

    if (formelm.componentType=="MyFormDate")
    {
        if (!Defined(contextentity(formelm.name)))
        {
            formelm.value='';
        }else{
            var _defaultval=new Date(contextentity(formelm.name));
            formelm.value=_defaultval.getFullYear()+"-"+
                padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate());
            if (_defaultval.getFullYear()==1899)
                formelm.value="";
        }
    }else
        if (formelm.componentType=="MyFormDateTime")
        {
            if (!Defined(contextentity(formelm.name)))
            {
                formelm.value= { date: "", time: "09:09" };		
            }else{
                var _defaultval=new Date(contextentity(formelm.name));
				//adjust for server and user...
				_defaultval=adjustUserDate(_defaultval);					
				//removing this so we round the time
				//			   formelm.value= { date: _defaultval.getFullYear()+"-"+
					//				padDate(_defaultval.getMonth()+1)+"-"+padDate(_defaultval.getDate()), 
					  //              time: padDate(_defaultval.getHours())+":"+padDate(_defaultval.getMinutes()) };		
					
					// Assuming _defaultval is a Date object
					var minutes = _defaultval.getMinutes();
					var roundedMinutes = Math.ceil(minutes / 5) * 5;

					if (roundedMinutes === 60) {
						_defaultval.setHours(_defaultval.getHours() + 1);
						roundedMinutes = 0;
					}
					_defaultval.setMinutes(roundedMinutes);
					_defaultval.setSeconds(0);
					_defaultval.setMilliseconds(0);

					formelm.value = {
						date: _defaultval.getFullYear() + "-" +
							  padDate(_defaultval.getMonth() + 1) + "-" +
							  padDate(_defaultval.getDate()),
						time: padDate(_defaultval.getHours()) + ":" +
							  padDate(_defaultval.getMinutes())
					};
					
                if (_defaultval.getFullYear()==1899)
                    formelm.value= { date: "",
                        time: "" };		
				
            }
        }else
            if (formelm.componentType=="MyFormCheckbox")
            {
                formelm.value=false;
                if (contextentity(formelm.name)=="Y")
                    formelm.value=true;
            }else
                if (formelm.componentType=="MyFormCurrency")
                {
                    formelm.value={currency:contextentity(formelm.name+"_CID"),amount:contextentity(formelm.name)};
                }else
                    if (formelm.componentType=="MyFormSelectMultiple")
                    {
                        var _musel=new String(contextentity(formelm.name));
                        var _muselarr=_musel.split(",");
                        var _muselval=[];
                        for(var gg=0;gg<_muselarr.length;gg++)
                        {
                            var _musqlbase={"text":CRM.GetTrans(formelm.name,_muselarr[gg]),"value":_muselarr[gg]};
                            _muselval.push(_musqlbase);
                        }
                        formelm.value=_muselval;		
                    }else
                        if (formelm.componentType=="MyFormSelect")
                        {
                            formelm.value={"text":CRM.GetTrans(formelm.name,contextentity(formelm.name)),"value":contextentity(formelm.name)}			
                        }else
                            if (formelm.componentType=="MyFormRemoteLookup")
                            {
                                var ssaTable=getTableInfo(formelm.entity);
                                var __eeid=contextentity(formelm.name);
                                if (!Defined(__eeid))
                                    __eeid="-1";
                                var tmpsearchObject={fieldname:ssaTable.idfield,				
                                    searchfilter:{entity:formelm.entity,entityid:__eeid}};
                                //Response.Write(JSON.stringify(formelm));
                                var es=doEntitySearch(formelm.entity,tmpsearchObject,"","",1);
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
                                    formelm.options.push(xitem);
                                    formelm.value=xitem;
                                }		
                                if (es.data.tableData.length>0)
                                {
                                    var xitem={
                                        text: _displayText, value:{entity: itemraw.entity, entityid: itemraw.entityid},icon: itemraw.tileicon 
                                    }
                                    formelm.options.push(xitem);
                                    formelm.value=xitem;	
                                }
                                if ((formelm.name=="pers_companyid")
                                    ||(formelm.name=="comp_primarypersonid")
                                    ||(formelm.name=="oppo_primarypersonid")
                                    ||(formelm.name=="oppo_primarycompanyid")
                                    ||(formelm.name=="case_primarypersonid")
                                    ||(formelm.name=="case_primarycompanyid")
                                    ||(formelm.name=="lead_primarypersonid")
                                    ||(formelm.name=="lead_primarycompanyid")
                                    ){
                                    //these should be edited only from full CRM
                                    //formelm.readonly=true;		
                                }
                            }else{
	
                                formelm.value=contextentity(formelm.name);
                                //Response.Write("\n"+formelm.name+"="+formelm.value);
                            }
	
}

function getScreenWithData(entity, screenName, contextEntity, contextentityName) {
    Glog("getScreenWithData START:"+entity);
    if (contextentityName)
        contextentityName = contextentityName.toLowerCase();
	screenName=escapeSQL(screenName);
    var tableobj = getTableInfo(entity);
    var sql = "select SeaP_ColName, SeaP_Order,SeaP_Jump, SeaP_Required,SeaP_CreateScript, Colp_Restricted," +
        "ColP_EntryType,ColP_DefaultValue,ColP_EntrySize,ColP_LookupFamily,ColP_LookupWidth, " +
        "ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, Colp_ssViewField, ColP_LinkedField  " +
        "from Custom_Screens " +
        "left join Custom_Edits on SeaP_ColName=ColP_ColName " +
        "where SeaP_SearchBoxName= '" + screenName + "'" +
        "and Seap_DeviceID is null and ColP_Deleted is null and SeaP_Deleted is null " +
        "order by SeaP_Order";


    //Response.Write(sql);
    //and ColP_Entity= '" + entity + "'"
    var q = CRM.CreateQueryObj(sql);
    q.SelectSQL();
    if (q.eof) {
        sql = "select SeaP_ColName, SeaP_Order,SeaP_Jump, SeaP_Required,SeaP_CreateScript, Colp_Restricted," +
            "ColP_EntryType,ColP_DefaultValue,ColP_EntrySize,ColP_LookupFamily,ColP_LookupWidth, " +
            "ColP_Required, ColP_AllowEdit, ColP_DataSize, Colp_TiedFields, Colp_ssViewField, ColP_LinkedField  " +
            "from Custom_Screens " +
            "left join Custom_Edits on SeaP_ColName=ColP_ColName " +
            "where SeaP_SearchBoxName= '" + entity + "NewEntry' and ColP_Entity='" + entity + "'" +
            "and Seap_DeviceID is null and ColP_Deleted is null and SeaP_Deleted is null " +
            "order by SeaP_Order";
        q = CRM.CreateQueryObj(sql);
        q.SelectSQL();
    }

    var resx = JSON.clone(_FormScreenMetadata);
    resx.name = screenName;
    resx.title = CRM.GetTrans("NewMenu", entity);
    resx.title = capitalize(resx.title);
    resx.subheader = capitalize(CRM.GetTrans("Entities", entity));
    resx.entity = entity;
    resx.content = "";

    var sqlScreen = "select * from Custom_ScreenObjects where cobj_name='" + screenName + "'";
    var qsqlScreen = CRM.CreateQueryObj(sqlScreen);
    qsqlScreen.SelectSQL();
    if (!qsqlScreen.eof) {
        resx.content = qsqlScreen("Cobj_CustomContent");
    }

    while (!q.eof) {

        var recordValue = contextEntity(q("SeaP_ColName"));

        var formelm = JSON.clone(_MyFormElement);
        formelm.name = q("SeaP_ColName");
        formelm.caption = CRM.GetTrans("ColNames", q("SeaP_ColName"));
        if (q("ColP_EntryType") == "51") {

            formelm.value = { currency: getSysParam("BaseCurrency"), amount: recordValue };
            formelm.options = getOptionsCurrency();
        } else if (q("ColP_EntryType") == "44") {
            formelm.value = getReferenceID(entity, tableobj.idfield, q("SeaP_ColName"));
        } else {
            formelm.value = recordValue;
        }
        formelm.required = q("ColP_Required") == "Y";
        formelm.readonly = false;
        formelm.maxLength = getFieldMaxLength(entity, formelm.name,q("ColP_EntryType"));
        //*****************

        //create script...clever...
        //Costi - since we use this method for existing records we need the Create Script DefaultValue to work only for new records; 
        if (contextEntity == null) {
            var SeaP_CreateScript = q("SeaP_CreateScript");
            var Caption = formelm.caption;
            var Required = formelm.required;
            var DefaultValue = formelm.value;
            var ReadOnly = formelm.readonly;			
            try {

                SeaP_CreateScript = SeaP_CreateScript.replace(/CRM.GetContextInfo/ig, "GetContextInfo");
                SeaP_CreateScript = SeaP_CreateScript.replace(/eWare.GetContextInfo/ig, "GetContextInfo");
                eval(SeaP_CreateScript);
            }catch(e){
                //ignore
            }			
            formelm.caption = Caption;
            formelm.required = Required;
            formelm.value = DefaultValue;
            formelm.readonly = ReadOnly;
        }
        //*****************
        //check our context data also for a value

        formelm.componentType = getComponentType(q("ColP_EntryType"));
        if (formelm.componentType == "MyFormSelect") {
            formelm.value = { "text": CRM.GetTrans(formelm.name, formelm.value), "value": formelm.value }
        }
        if (formelm.componentType == "MyFormDateTime") {
            formelm.value = { "date": "", "time": "" }
        }
        if (formelm.componentType == "MyFormRemoteLookup") {
            formelm.icon = getEntityIcon(q("ColP_LookupFamily"));
            formelm.iconColor = getTileColour(q("ColP_LookupFamily"));
            formelm.entity = q("ColP_LookupFamily");
            ssaTable = getTableInfo(formelm.entity);
            if ((contextEntity != null) && (contextEntity.RecordCount > 0) && (ssaTable.name == contextentityName)) {
                var tmpsearchObject = {
                    fieldname: formelm.name,
                    searchfilter: { entity: formelm.entity, entityid: contextentity(ssaTable.idfield) }
                };
                Glog("getScreenWithData doEntitySearch #1:"+formelm.entity);
                var es = doEntitySearch(formelm.entity, tmpsearchObject, "", "", 1);
                Glog("getScreenWithData doEntitySearch #1 records:"+es.data.tableData.length);
                for (var i = 0; i < es.data.tableData.length; i++) {
                    var itemraw = es.data.tableData[i];
                    var _displayText = '';
                    for (var x = 1; x < es.data.tableColumns.length; x++) {
                        var colname = es.data.tableColumns[x].value;
                        if (_displayText != '')
                            _displayText += ' ';
                        _displayText += itemraw[colname];
                    }
                    var xitem = {
                        text: _displayText, value: { entity: itemraw.entity, entityid: itemraw.entityid }, icon: itemraw.tileicon
                    }
                    Glog("getScreenWithData _displayText #1:"+_displayText);
                    formelm.options.push(xitem);
                    formelm.value = xitem;
                }
            }
            if (q("Colp_Restricted") != null) {
                var Colp_Restricted = new String(q("Colp_Restricted"));
                Colp_Restricted = Colp_Restricted.toLowerCase();
                if (Colp_Restricted.indexOf("primaryaccountid") > 0) {
                    Colp_Restricted = Colp_Restricted.replace("primaryaccountid", "primarycompanyid");
                }
                formelm.filterObjectName = Colp_Restricted;
            }
        } else
            if (q("ColP_EntryType") == "53") {
                //get territories
                formelm.options = getTerritoryOptions(q("ColP_LookupFamily"));
            }
            else if (q("ColP_EntryType") == "21") {
                //get lookup
                formelm.options = getOptions(q("ColP_LookupFamily"),false,true);
            } else if ((q("ColP_EntryType") == "22") || (q("ColP_EntryType") == "24")) {
                //get the users
                formelm.options = getOptionsUsers();
            } else if (q("ColP_EntryType") == "23") {
                //get the teams/channel
                formelm.options = getOptionsChannel();
            }
        resx.formElements.push(formelm);
        q.NextRecord();
    }

    return resx;
}

function getTerritoryOptions()
{
    var res=[];
    var opt={
        text: CRM.GetTrans("GenCaptions","Default"),
        value:""
    }
    res.push(opt);	
    //get users territory
    var quser=CRM.CreateQueryObj("select Terr_TerritoryID,Terr_Caption,Terr_ParentID,Terr_Depth from Territories "+
						"where Terr_TerritoryID="+getUser_PrimaryTerritory()+" "+
						"order by Terr_DBID");
    quser.SelectSQL();

    var _capt = quser("Terr_Caption");
    _capt = CRM.GetTrans("Territory", _capt);
    var opt = {
        text: _capt,
        value: quser("Terr_TerritoryID")
    }
	
    res.push(opt);	
    //get child territories
    var ct=getChildTerritories(getUser_PrimaryTerritory());
    res=res.concat(ct);

    return res;
}
function getChildTerritories(parentid)
{
    var res=[];
    var q=CRM.CreateQueryObj("select Terr_TerritoryID,Terr_Caption,Terr_ParentID,Terr_Depth,Terr_ChildCount from Territories "+
						"where Terr_ParentID="+parentid+" "+
						"and terr_caption not in "+
						"('Children','Userssiblingterritories','Usersparentterritory','Usershometerritory'"+
						",'CreatedBy','Channel','AssignedTo') "+
						"order by Terr_DBID");
    q.SelectSQL();
    while (!q.eof){
        var depth=new Number(q("Terr_Depth"));
        var _indent= new Array(depth + 1).join( "-" );
        var opt={
            text: _indent+q("Terr_Caption"),
            value:q("Terr_TerritoryID")
        }
        res.push(opt);
        if (q("Terr_ChildCount")>0)
        {
            var ct=getChildTerritories(q("Terr_TerritoryID"));
            res=res.concat(ct);		
        }
        q.NextRecord();
    }
    return res;
}
function getOptionsCurrency()
{
    var res=[];
    lookupsql="select Curr_CurrencyID,Curr_Symbol from Currency order by Curr_CurrencyID";
    var q=CRM.CreateQueryObj(lookupsql);
    q.SelectSQL();
    while (!q.eof){
        var opt={
            text: q("Curr_Symbol"),
            value:q("Curr_CurrencyID")
        }
        res.push(opt);
        q.NextRecord();
    }
    return res;
}
function getOptionsCurrencyById(val)
{
    var res={
        text: "",
        value:""
    }
    if (!Defined(val))
        return res;
    var lookupsql="select Curr_CurrencyID,Curr_Symbol from Currency where Curr_CurrencyID="+val;
    var q=null;
    try{
        q=CRM.CreateQueryObj(lookupsql);
        q.SelectSQL();
    }catch(e){
        Response.Write("ERROR getOptionsCurrencyById:"+lookupsql);
    }
    if (!q.eof){
        res={
            text: q("Curr_Symbol"),
            value:q("Curr_CurrencyID")
        }
    }
    return res;
}
function getOptionsCurrencyByName(val)
{
    var res={
        text: "",
        value:""
    }
    if (!Defined(val))
        return res;		
    var lookupsql="select Curr_CurrencyID,Curr_Symbol from Currency where Curr_Symbol='"+val+"'";
    var q=CRM.CreateQueryObj(lookupsql);
    q.SelectSQL();
    if (!q.eof){
        res={
            text: q("Curr_Symbol"),
            value:q("Curr_CurrencyID")
        }
    }
    return res;
}
function getOptionsChannel(replacementSQL)
{
    var res=[];
    var teamlookupsql=GetWebConfigValue("teamlookupsql");
    if (Defined(replacementSQL) && (replacementSQL!=''))
        teamlookupsql=replacementSQL;
    if ((teamlookupsql==null)||(teamlookupsql==""))
    {
        teamlookupsql="select * from vchannel where 5565=5565";
    }
    var q=CRM.CreateQueryObj(teamlookupsql);
    q.SelectSQL();
    while (!q.eof){
        var opt={
            text: q("Chan_Description"),
            value:q("Chan_ChannelId")
        }
        res.push(opt);
        q.NextRecord();
    }
    var optnone={
        text: CRM.GetTrans("GenCaptions","None"),
        value:""
    }
    res.push(optnone);		
    return res;
}
function getSelectChannel(Chan_ChannelId)
{
    var cacheKey="getSelectChannel_"+Chan_ChannelId;
    var cacheres=getCache(cacheKey);
    if (cacheres){
        return cacheres;
    }
    var res="";
    if (!Defined(Chan_ChannelId) || (Chan_ChannelId == null) || (Chan_ChannelId == ''))
    {
        return res;
    }	
    var teamlookupsql="select Chan_Description from vchannel where 5566=5566 and Chan_ChannelId="+Chan_ChannelId;
    var q = CRM.CreateQueryObj(teamlookupsql);
    try {
        q.SelectSQL();
    } catch (ee) {
        return res;
    }
    if (!q.eof){
        res = q("Chan_Description");
    }
    setCache(cacheKey,res);
    return res;
}
function getSelectChannelByName(Chan_Description)
{
    var cacheKey="getSelectChannelByName_"+Chan_Description;
    var cacheres=getCache(cacheKey);
    if (cacheres){
        return cacheres;
    }
	
    var res="";
    if (!Defined(Chan_Description) || (Chan_Description == null) || (Chan_Description == ''))
    {
        return res;
    }	
    var teamlookupsql="select Chan_ChannelId from vchannel where 5567=5567 and Chan_Description='"+Chan_Description+"'";
    var q=CRM.CreateQueryObj(teamlookupsql);
    q.SelectSQL();
    if (!q.eof){
        res = q("Chan_ChannelId");
    }
    setCache(cacheKey,res);
    return res;
}
function getSelectUser(user_userid)
{
    var cacheKey="getSelectUser_"+user_userid;
    var cacheres=getCache(cacheKey);
    if (cacheres){
        return cacheres;
    }	
    var res="";
    if (!Defined(user_userid) || (user_userid == null) || (user_userid == ''))
    {
        return res;
    }	
    var userlookupsql="Select user_fullname from vusers where 4711=4711 and user_userid="+user_userid;
    var q=null;
    try{
        q=CRM.CreateQueryObj(userlookupsql);
        q.SelectSQL();
    }catch(e){
        Response.Write("ERROR getSelectUser:"+userlookupsql);
        Response.End();
    }
    if (!q.eof){
        res=q("user_fullname");
    }		
    setCache(cacheKey,res);
    return res;
}
function getOptionsUsers(replacementSQL)
{
    var cacheKey = "getOptionsUsers" + user_userid;
    var cacheres=getCache(cacheKey);
    if ((cacheres) && !Defined(replacementSQL)){
        return cacheres;
    }	
    var res=[];
    var userlookupsql=GetWebConfigValue("userlookupsql");
    if (Defined(replacementSQL) && (replacementSQL!=''))
        userlookupsql = replacementSQL;

    var q=CRM.CreateQueryObj(userlookupsql);
    q.SelectSQL();
    while (!q.eof){
        var opt={
            text: q("user_fullname"),
            value:q("user_userid")
        }
        res.push(opt);
        q.NextRecord();
    }
    var optnone={
        text: CRM.GetTrans("GenCaptions","None"),
        value:""
    }
    res.push(optnone);	
    setCache(cacheKey,res);
    return res;
}
function getOptions(_lookup,addAll, addNone)
{
    var cacheKey="getOptions_"+_lang+"_"+_lookup;
    var cacheres=getCache(cacheKey);
    if (cacheres){
        return cacheres;
    }
    var res=[];
    var _lang=getCRMUserLang();
    var sql="select capt_code, capt_"+_lang+" from Custom_Captions where 2276=2276 and "+
			"capt_family='"+_lookup+"' and Capt_FamilyType='Choices'"+
			" and Capt_Deleted is null order by  Capt_Order, Capt_Code";
    var q=CRM.CreateQueryObj(sql);
	
    q.SelectSQL();
    while (!q.eof){
        var opt={
            text: CRM.GetTrans(_lookup,q("Capt_Code")),
            value:q("Capt_Code")
        }
        res.push(opt);
        q.NextRecord();
    }
    if (addAll===true)
    {
        var opt={
            text: CRM.GetTrans("GenCaptions","All"),
            value:"All"
        }
        res.push(opt);
    }
    if (addNone===true)
    {
        var opt={
            text: CRM.GetTrans("GenCaptions","None"),
            value:""
        }
        res.push(opt);		
    }	
    setCache(cacheKey,res);
    return res;
}
function getEmailScreen(entity, prefix, contextEntity, _entityid){

    var cacheKey="getEmailScreen_"+entity+"_"+prefix;
    var cacheres=getCache(cacheKey);
    if ((cacheres) && (!Defined(_entityid))){
        return cacheres;
    }
    var res= JSON.clone(_FormScreenMetadata);
    res.name="email_"+entity+"_"+prefix;
    res.title=CRM.GetTrans("Tabnames","CompanyEmail");
    res.subheader=capitalize(CRM.GetTrans("Entities",entity))+" "+CRM.GetTrans("Tabnames","CompanyEmail");
    res.subheadericon="mdi-email";
    res.entity="email_"+entity;
		
    var _lang=getCRMUserLang();
    var sql1="select Capt_Code, Capt_" + _lang + " from Custom_Captions where Capt_Family ='Link_"+prefix+"Emai' and Capt_Deleted is NULL order by Capt_Order";
    var q1=CRM.CreateQueryObj(sql1);
    q1.SelectSQL();		
    while (!q1.eof){
        var formelm= JSON.clone(_MyFormElement);
        formelm.name="emailfield_"+q1("Capt_Code");
        formelm.caption=q1("Capt_" + _lang);	  
        formelm.value = { "emailaddress": "", "type": q1("Capt_Code") }; 

        if (Defined(_entityid))
        {
            var _eRecordsql="select * from v"+entity+"Email WHERE elink_recordID="+_entityid+" and eLink_Type='"+q1("Capt_Code")+"'";
            var _eRecordq=CRM.CreateQueryObj(_eRecordsql);
            _eRecordq.SelectSQL();
            if (!_eRecordq.eof)
            {
                formelm.value = { "emailaddress": _eRecordq("Emai_EmailAddress"), "recordId": _eRecordq("emai_emailId"), "type": _eRecordq("eLink_Type") }; 
            }
        }	  

        formelm.componentType="MyFormEmail";
        res.formElements.push(formelm);
        q1.NextRecord();
    }
    setCache(cacheKey,res);
    return res;
}

//emailObj may contain phonenumbers
function getPhoneScreen(entity, prefix, contextEntity, _entityid, emailObj){

    var cacheKey="getPhoneScreen_"+entity+"_"+prefix;
    var cacheres=getCache(cacheKey);
    if ((cacheres) && !Defined(_entityid)){
        return cacheres;
    }
	
    var res= JSON.clone(_FormScreenMetadata);
    res.name="phone_"+entity+"_"+prefix;
    res.title=CRM.GetTrans("Tabnames","CompanyPhone");
    res.subheader=capitalize(CRM.GetTrans("Entities",entity))+" "+CRM.GetTrans("Tabnames","CompanyPhone");
    res.subheadericon="mdi-phone";
    res.entity="phone_"+entity;
	
    var _lang=getCRMUserLang();
    var sql1="select Capt_Code, Capt_" + _lang + " from Custom_Captions where Capt_Family ='Link_"+prefix+"Phon' and Capt_Deleted is NULL order by Capt_Order";

    //options
    var sql2="select Parm_Name, Parm_Value from Custom_SysParams where Parm_Name in ('UseCountryCode', 'UseAreaCode')";
	
    var UseCountryCode=true;
    var UseAreaCode=true;

    var q2=CRM.CreateQueryObj(sql2);
    q2.SelectSQL();	
	
    while (!q2.eof){
        if ((q2("parm_name")=="UseAreaCode")&&(q2("parm_value")!="Y"))
            UseAreaCode=false;
        else if ((q2("parm_name")=="UseCountryCode")&&(q2("parm_value")!="Y"))
            UseCountryCode=false;
        q2.NextRecord();
    }
	
    var q1=CRM.CreateQueryObj(sql1);
    q1.SelectSQL();		
    var phonenosmetacount=0;
    while (!q1.eof){
        var formelm= JSON.clone(_MyFormElement);
        formelm.name="phonefield_"+q1("Capt_Code");
        formelm.caption=q1("Capt_" + _lang);
        formelm.value = { countrycode_value: '', areacode_value: '', phonenumber_value: '', type: q1("Capt_Code")}; 
        if (Defined(_entityid))
        {
            var _pRecordsql = "select * from v" + entity + "Phone WHERE Plink_recordID=" + _entityid + " and PLink_Type='" + q1("Capt_Code") + "'";

            var _pRecordq=CRM.CreateQueryObj(_pRecordsql);
            _pRecordq.SelectSQL();

            if (emailObj && (emailObj.phoneNumbers) && (emailObj.phoneNumbers[phonenosmetacount]))
            {
                var phonenoarr=emailObj.phoneNumbers[phonenosmetacount].number.split(" ");
                if ((phonenoarr.length==1)&&(emailObj.phoneNumbers[phonenosmetacount].number.indexOf("-")>0))
                {
                    phonenoarr=emailObj.phoneNumbers[phonenosmetacount].number.split("-");
                }
                if ((phonenoarr.length==1) || (!UseCountryCode)){
                    formelm.value={countrycode_value:"", 
                        areacode_value: "", phonenumber_value: emailObj.phoneNumbers[phonenosmetacount].number
                    };
                }
                if (phonenoarr.length==3){
                    formelm.value={countrycode_value:phonenoarr[0], 
                        areacode_value: phonenoarr[1], phonenumber_value: phonenoarr[2]
                    }; 
                }
            }else
                if (!_pRecordq.eof)
                {
				
                    formelm.value={countrycode_value:_pRecordq("Phon_CountryCode"), 
                        areacode_value: _pRecordq("Phon_AreaCode"), phonenumber_value: _pRecordq("Phon_Number"),
                        recordId: _pRecordq("Phon_PhoneId"),
                        type: _pRecordq("Plink_Type")
                    }; 

				
                }
        }
        formelm.componentType="MyFormPhone";
        formelm.options={
            CountryCode:UseCountryCode,
            AreaCode:UseAreaCode
        }
        res.formElements.push(formelm);
        phonenosmetacount++;
        q1.NextRecord();
    }
    setCache(cacheKey,res);
    return res;
}

function GetContextInfo(contextEntity,contextEntityField)
{
    var res="";
    if ((contextEntity.toLowerCase()=="user")||(contextEntity.toLowerCase()=="users"))
    {
        return CRM.GetContextInfo(contextEntity,contextEntityField);
    }
    var _screenMetadata_entity=Request.Form("screenMetadata_entity");
    var _screenMetadata_entityid = Request.Form("screenMetadata_entityid");

    if (Defined(_screenMetadata_entity)) {
        var _table = getTableInfo(contextEntity);
        var __screenMetadata_entityrec = CRM.FindRecord(contextEntity, "7180=7180 and " + _table.idfield + "=" + _screenMetadata_entityid);
        if (!__screenMetadata_entityrec.eof) {
            res = __screenMetadata_entityrec(contextEntityField);
        }
    } else if (CONTEXT_RECORD != null) {
        try {
            res = CONTEXT_RECORD(contextEntityField);
        } catch (e) {
            //
        }
    }
    return res;
}
%>