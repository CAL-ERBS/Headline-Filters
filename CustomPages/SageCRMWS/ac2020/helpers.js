<%
if (typeof JSON.clone !== "function") {
    JSON.clone = function (obj) {
        return JSON.parse(JSON.stringify(obj));
    };
}

var user_userid = "";
function getUserId() {
    if (user_userid == "")
        user_userid = CRM.GetContextInfo("user", "user_userid");
    return user_userid;
}
var user_firstname = "";
function getUser_firstname() {
    if (user_firstname == "")
        user_firstname = CRM.GetContextInfo("user", "user_firstname");
    return user_firstname;
}
var user_lastname = "";
function getUser_lastname() {
    if (user_lastname == "")
        user_lastname = CRM.GetContextInfo("user", "user_lastname");
    return user_lastname;
}
var User_PrimaryTerritory = "";
function getUser_PrimaryTerritory() {
    if (CRM.GetContextInfo("user", "User_Per_Admin") == "3")
        User_PrimaryTerritory = get_PrimaryTerritory();
    if (User_PrimaryTerritory == "")
        User_PrimaryTerritory = CRM.GetContextInfo("user", "User_PrimaryTerritory");
    return User_PrimaryTerritory;
}
//get the worldwide
function get_PrimaryTerritory() {
    var qterr = CRM.CreateQueryObj("select Terr_TerritoryID from Territories " +
        "where Terr_ParentID=0 and Terr_Deleted is null " +
        "order by Terr_DBID");
    qterr.SelectSQL();
    res = "-1";
    if (!qterr.eof)
        res = qterr.FieldValue("Terr_TerritoryID")

    return res;
}
var User_PrimaryChannelId = "";
function getUser_PrimaryChannelId() {
    if (User_PrimaryChannelId == "")
        User_PrimaryChannelId = CRM.GetContextInfo("user", "User_PrimaryChannelId");
    return User_PrimaryChannelId;
}

function getUserLang() {
    var res = new String(CRM.GetContextInfo("User", "User_Language"));
    res = res.toLowerCase();
    if ((res == "us") || (res == "uk")) {
        res = "en-" + res;
    } else if (res == "de") {
        res = res + "-" + res;
    } else {
        es = "en-us";
    }
    if (!Defined(res))
        res = "en-us";//fallback
    return res;
}
function getCRMUserLang() {
    var res = new String(CRM.GetContextInfo("user", "User_Language"));
    res = res.toLowerCase();
    if ((res == "") || (res == null))
        res = "US";
    return res;
}

function hasPermissionView(entity) {
    var res = true;
    var _h = CRM.Button(entity, '', '', entity, "VIEW");
    if (_h == "") {
        res = false;
    }
    if (!res) {
        res = hasPermissionInsert(entity);
    }
    //some crm's installs dont like this for secondary entities so we check these
    if (!res) {
        //check if its a secondary entity...
        var sql="select bord_tableid "+
			" from custom_tables where bord_name='" + entity + "' and Bord_PrimaryTable is null";
        var qSec=CRM.CreateQueryObj(sql);	
        qSec.SelectSQL();
        if (!qSec.eof)
            res=true;
    }
    return res;
}


function hasPermissionEdit(entity) {
    var _h = CRM.Button(entity, '', '', entity, "EDIT");
    if (_h == "") {
        return false;
    }
    return true;
}


function hasPermissionInsert(entity) {
    var _h = CRM.Button(entity, '', '', entity, "INSERT");
    if (_h == "") {
        return false;
    }
    return true;
}
function getLibrEntityColumn(entity, hasColumn) {
    entity = entity.toLowerCase();
	if (!hasColumn)
		return false;
    switch (entity) {
        case "user":
            res = "";
            break;
        case "users":
            res = "";
            break;
        case "company":
            res = "libr_companyid";
            break;
        case "person":
            res = "libr_personid";
            break;
        case "opportunity":
            res = "libr_opportunityid";
            break;
        case "cases":
        case "case":
            res = "libr_caseid";
            break;
        case "case":
            res = "libr_caseid";
            break;
        case "channel":
            res = "libr_channelid";
            break;
        case "orders":
            res = "libr_orderid";
            break;
        case "quotes":
            res = "libr_quoteid";
            break;
        case "account":
            res = "libr_accountid";
            break;
        case "solution":
        case "solutions":
            res = "libr_solutionid";
            break;
        case "lead":
            res = "libr_leadid";
            break;
        case "communication":
            res = "libr_communicationid";
            break;
        default:
            res = "libr_"+entity+"id";//guess?
            break;
    }
    return res;
}

function getCommEntityColumn(entity) {
    entity = entity.toLowerCase();
    switch (entity) {
        case "user":
        case "users":
            res = "comm_userid";
            break;
        case "company":
            res = "cmli_comm_companyid";
            break;
        case "person":
            res = "cmli_comm_personid";
            break;
        case "opportunity":
            res = "comm_opportunityid";
            break;
        case "cases":
        case "case":
            res = "comm_caseid";
            break;
        case "orders":
            res = "comm_orderid";
            break;
        case "quotes":
            res = "comm_quoteid";
            break;
        case "account":
            res = "comm_accountid";
            break;
        case "solution":
        case "solutions":
            res = "comm_solutionid";
            break;
        case "lead":
            res = "comm_leadid";
            break;
        default:
            res = "comm_"+entity+"id";//guess?
            break;
    }
    return res;
}

function escapeSQL(val) {
    val = new String(val);
    val = replaceAll(val, "'", "''");
    return val;
}

function getEntityWhereClause(entity, searchsql, BACKTOBASIC) {
    var __trim = 'trim';
    entity = new String(entity);
    entity = entity.toLowerCase();
    var table = getTableInfo(entity);
    var res = "(";
    if (searchsql == "") return "1=1 and (" + table.prefix + "_deleted is null)";
    //fix up sql
    searchsql = escapeSQL(searchsql);
    switch (entity) {
        case "company":
            if (searchsql.indexOf(".") > 0) {
                res += "comp_name like '%" + searchsql + "%' or comp_emailaddress like '%" + searchsql + "%'";
            } else {
                res += "comp_name like '%" + searchsql + "%' ";
            }
            break;
        case "person":
            var _emailStringSearch = searchsql;
            _emailStringSearch = _emailStringSearch.replace('%', '');
            if (BACKTOBASIC === true) {
                res += "pers_lastname like '%" + searchsql + "%' or pers_firstname like '%"
                    + searchsql + "%') or Pers_EmailAddress = '" + _emailStringSearch + "'";
            } else {
                res += "( ((RTRIM(pers_firstname) + ' ' + RTRIM(pers_lastname)) like '%"
                    + searchsql + "%') or pers_lastname like '%" + searchsql + "%' or pers_firstname like '%"
                    + searchsql + "%') or Pers_EmailAddress = '" + _emailStringSearch + "'";
            }
            break;
        case "cases":
        case "case":
            res += "(case_description like '%" + searchsql + "%' or case_referenceid like '%" + searchsql + "%')";
            break;
        case "opportunity":
            res += "oppo_description like '%" + searchsql + "%'";
            break;
        case "orders":
        case "order":
            res += "orde_description like '%" + searchsql + "%' or orde_reference like '%" + searchsql + "%'";
            break;
        case "quotes":
        case "quote":
            res += "quot_description like '%" + searchsql + "%' or quot_reference like '%" + searchsql + "%'";
            break;
        case "solution":
        case "solutions":
            res += "6142=6142 and Soln_Description like '%" + searchsql + "%' or Soln_ReferenceId like '%" + searchsql + "%'";
            break;			
        case "address":
            res += "addr_address1 like '%" + searchsql + "%' or addr_address2 like '%" + searchsql + "%' or "+
                "addr_address3 like '%" + searchsql + "%' or addr_address5 like '%" + searchsql + "%' or " +
                "addr_city like '%" + searchsql + "%' or " +
					"Addr_PostCode like '%" + searchsql + "%' or addr_uszipplusfour like '%" + searchsql + "%'"
            break;			
        case "library":
		    var _scolarr=['Libr_FileName','Libr_Note'];
            res += "(";
			var _sFound=false;//flag to make sure even with no index we get a field
			for (var i = 0; i < _scolarr.length; i++) {
				if (_hasSQLIndex("Library",_scolarr[i])){
      			  if (i > 0)
				    res+=" OR ";
				  res += " 	("+_scolarr[i]+" like '%" + searchsql + "%') ";
				  _sFound=true;
				}
			}
			if (!_sFound)			
				res += "Libr_FileName like '%" + searchsql + "%' or Libr_Note like '%" + searchsql + "%'";
			res += ") ";      
            break;			
        case "communication":
		case "communications":
			//changed this as we need indexed columns only...too slow otherwise
            //res += "comm_private is null and (Comm_Description like '%" + searchsql + "%' or Comm_Subject like '%" + searchsql + "%' or Comm_Note like '%" + searchsql + "%')";
			var _scolarr=['Comm_Subject','Comm_Description','Comm_Location','Comm_From','Comm_TO','Comm_CC','Comm_Note','Comm_DateTime'];//todo...move to db later?
            res += "(";
			for (var i = 0; i < _scolarr.length; i++) {
				if ((_scolarr[i]=="Comm_DateTime")&&(_hasSQLIndex("communication",_scolarr[i])))
				{
				   //res += " ("+_scolarr[i]+" = '%" + searchsql + "%') ";
				   var _Comm_DateTime=new Date(searchsql);
				   if (!isNaN(_Comm_DateTime.getVarDate())){
					  if (i > 0)
						res+=" OR ";
					  res += " ("+_scolarr[i]+" between '"+getSQLDate(_Comm_DateTime)+" 00:00' and '"+getSQLDate(_Comm_DateTime)+" 23:59')";
				   }
				}
				else
				if (_hasSQLIndex("communication",_scolarr[i])){
      			  if (i > 0)
				    res+=" OR ";
				  res += " 	("+_scolarr[i]+" like '%" + searchsql + "%') ";
				}
			}
			res += ") and comm_private is null";
            break;						
        case "lead":
            if (BACKTOBASIC === true) {
                res += "(lead_companyname like '%" + searchsql + "%' or lead_personlastname like '%" + searchsql + "%' or lead_personfirstname like '%"
                    + searchsql + "%' or lead_description like '%" + searchsql + "% or lead_personemail like '%" + searchsql + "%' )";
            } else {
                res += "( ((RTRIM(lead_personfirstname) + ' ' + RTRIM(lead_personlastname)) like '%" + searchsql + "%') or lead_companyname like '%" + searchsql + "%' or lead_personlastname like '%" + searchsql + "%' or lead_personfirstname like '%" + searchsql + "%' or lead_description like '%" + searchsql + "%' or lead_personemail like '%" + searchsql + "%'  )";
            }
            break;
        default:
            if ((table.descriptionField != "") && (table.descriptionField + "" != "undefined")) {
                res += table.descriptionField + " like '%" + searchsql + "%'"
            } else {
                //check for _name column
                var _namecolumn = table.prefix + "_name";
                var qce = queryCustomEdits(_namecolumn);
                if (!qce.eof)
                    res += table.prefix + "_name like '%" + searchsql + "%'";
                else {
                    var _statuscolumn = table.prefix + "_status";
                    var qce2 = queryCustomEdits(_statuscolumn);
                    if (!qce2.eof)	
                        res += table.prefix + "_status like '%" + searchsql + "%'";
                    else{
                        var _descriptioncolumn = table.prefix + "_description";//table.descriptionField not set in metadata but exists
                        var qce3 = queryCustomEdits(_descriptioncolumn);
                        if (!qce3.eof)
                            res += table.prefix + "_description like '%" + searchsql + "%'";
                    }
					
                }
            }

            break;
    }
    //now get any custom search items
	//getNewScreen(entity, screenName, contextentity, contextentityName, addAll, addinScreenName, editMode, searchMode=true)
    var _customsearchscreen = getNewScreen(entity, entity + "OfficeIntSearch",null, null, null, null, null, true);
    for (var oo = 0; oo < _customsearchscreen.formElements.length; oo++) {
        var _elmnt = _customsearchscreen.formElements[oo];
		if (_elmnt.componentType=="MyFormNumber")
		{ 
	        if (isNumeric(searchsql))
			  res += " OR " + _elmnt.name + " = " + searchsql + " "; //otherwise we ignore
		}else{
			res += " OR " + _elmnt.name + " like '%" + searchsql + "%'";
		}
    }
    res += ") and (" + table.prefix + "_deleted is null)";
    return res;
}

function getListScreenName(entity) {
    var res = "";

    var _cachekey = "getListScreenName_" + entity;
    var _cachedObj = getCache(_cachekey);
    if (_cachedObj != null) {
        return _cachedObj;
    }

    var sql = "select * from Custom_ScreenObjects where 777=777 and CObj_EntityName='" + entity + "' and (cobj_name = '" + entity + "officeintsmall'";
    //historical metadata issue
    if (entity == "quotes") {
        sql += " or cobj_name = 'Quoteofficeintsmall'";
    } else if (entity == "orders") {
        sql += " or cobj_name = 'Orderofficeintsmall'";
    }
    sql += ")";
    Glog("getListScreenName sql:" + sql);
    var q1 = CRM.CreateQueryObj(sql);
    q1.SelectSQL();
    if (q1.eof) {
        sql = "select * from Custom_ScreenObjects where 778=778 and CObj_EntityName='" + entity + "' " +
            "and cobj_name = '" + entity + "Grid'";
        Glog("getListScreenName sql2:" + sql);
        q1 = CRM.CreateQueryObj(sql);
        q1.SelectSQL();
    }
    if (q1.eof) {
        sql = "select * from Custom_ScreenObjects where 779=779 and CObj_EntityName='" + entity + "' " +
            "and cobj_name = '" + entity + "DetailBox'";
        Glog("getListScreenName sql3:" + sql);
        q1 = CRM.CreateQueryObj(sql);
        q1.SelectSQL();
    }
    if (!q1.eof) {
        res = q1.FieldValue("CObj_Name");
        setCache(_cachekey, res);
    }
    return res;
}

function getACListFields(entity) {
    return getACObjectFields(entity, getListScreenName(entity));
}

function getACObjectFields(entity, screenName, dofallback) {
    var res = [];
    var _cachekey = "getACObjectFields_" + entity + "_" + screenName;
    var _cachedObj = getCache(_cachekey);
    if (_cachedObj != null) {
        return _cachedObj;
    }

    var quoteorderpatch = "";
    if (screenName == 'quotesOfficeInt')
        quoteorderpatch = " or SeaP_SearchBoxName='quoteOfficeInt'";
    if (screenName == 'ordersOfficeInt')
        quoteorderpatch = " or SeaP_SearchBoxName='orderOfficeInt'";

    var sql = "select distinct lower(ColP_ColName) as ColP_ColName, SeaP_Order,SeaP_Newline, ColP_EntryType, convert(varchar(max),SeaP_CreateScript) as SeaP_CreateScript,ColP_LookupFamily, Colp_ssViewField " +
        "from Custom_Screens left join Custom_Edits on ColP_ColName=SeaP_ColName " +
        "where Seap_DeviceID is null and (SeaP_SearchBoxName='" + screenName + "' " + quoteorderpatch + " ) and 854=854 "+
		"and ColP_ColName is not null ";	
	
	//for email comms we need to get specific fields

	if (screenName.toLowerCase()=="communicationofficeintemail")
	{
	    sql = "select distinct lower(ColP_ColName) as ColP_ColName, CASE ColP_ColName "+
			"     WHEN 'comm_from' THEN 1 	 WHEN 'comm_to' THEN 2 	 WHEN 'comm_cc' THEN 3 	 WHEN 'comm_bcc' THEN 4 "+
			"	 WHEN 'comm_datetime' THEN 5	 WHEN 'comm_subject' THEN 6	 WHEN 'comm_email' THEN 7 "+
			"	 WHEN 'comm_hasattachments' THEN 8     ELSE 99 END as SeaP_Order,"+
			"1 as SeaP_Newline, ColP_EntryType, ''  as SeaP_CreateScript ,ColP_LookupFamily,Colp_ssViewField "+
			"from Custom_Edits where ColP_ColName in "+
			"('comm_from','comm_to','comm_cc','comm_bcc','Comm_DateTime','Comm_subject','Comm_Email','Comm_HasAttachments')  "+
			"and 1854=1854 ";		  
	}
	if ((screenName.toLowerCase()=="communicationofficeint")||(screenName.toLowerCase()=="communicationofficeintemail"))
	{
		
		sql += " union ";//we get any linked main entity
		sql += "select distinct lower(ColP_ColName) as ColP_ColName, 99 as SeaP_Order, 1 as SeaP_Newline, ColP_EntryType, '' as SeaP_CreateScript,ColP_LookupFamily, Colp_ssViewField "+
            " from Custom_Edits  "+
            " where (ColP_Entity='communication' or ColP_Entity='comm_link') and ColP_EntryType=56 "+
			" and colp_colname not in ('cmli_comm_communicationid','comm_communicationid','cmli_externalpersonid')";
	}
	
	sql+=" order by SeaP_Order ";
	
//Response.Write(sql);
	
    //Response.Write("getACObjectFields sql:"+sql);						

    var q1 = CRM.CreateQueryObj(sql);
    q1.SelectSQL();
    if ((dofallback) && (q1.eof)) {
        //fallback
        sql = "select distinct lower(ColP_ColName) as ColP_ColName, SeaP_Order, SeaP_Newline, ColP_EntryType, convert(varchar(max),SeaP_CreateScript) as SeaP_CreateScript,ColP_LookupFamily, Colp_ssViewField " +
            "from Custom_Screens left join Custom_Edits on ColP_ColName=SeaP_ColName " +
            "where ColP_Entity='" + entity + "' and SeaP_SearchBoxName='" + entity + "NewEntry' and 454=454  order by SeaP_Order";
        Glog("getACObjectFields sql2:" + sql);
        q1 = CRM.CreateQueryObj(sql);
        q1.SelectSQL();
    }	
	//second fallback
    if ((q1.eof)&&(entity.toLowerCase()=="library") && (screenName.toLowerCase() == 'libraryofficeint')) {
        //fallback
        sql = "select distinct lower(ColP_ColName) as ColP_ColName, SeaP_Order, SeaP_Newline, ColP_EntryType, convert(varchar(max),SeaP_CreateScript) as SeaP_CreateScript,ColP_LookupFamily, Colp_ssViewField " +
            "from Custom_Screens left join Custom_Edits on ColP_ColName=SeaP_ColName " +
            "where ColP_Entity='" + entity + "' and SeaP_SearchBoxName='LibraryItemBoxLong' and 4542=4542 ";
		sql += " union ";//we get any linked main entity
		sql += "select distinct lower(ColP_ColName) as ColP_ColName, 99 as SeaP_Order, 1 as SeaP_Newline, ColP_EntryType, '' as SeaP_CreateScript,ColP_LookupFamily, Colp_ssViewField "+
            " from Custom_Edits  "+
            " where ColP_Entity='library' and ColP_EntryType=56 "+
			" order by SeaP_Order";

       // Response.Write("getACObjectFields sql2:" + sql);
        q1 = CRM.CreateQueryObj(sql);
        q1.SelectSQL();
    }	
	//fallback for progress screens with no columns
    if ((q1.eof)&&(screenName.toLowerCase().indexOf("progressofficeintsmall")>0)) {
        //fallback
		var _tbl=getTableInfo(entity);
	    sql = "select distinct lower(ColP_ColName) as ColP_ColName, grip_Order as SeaP_Order, 'y' as SeaP_Newline, "+
			"ColP_EntryType, '' as SeaP_CreateScript,ColP_LookupFamily, Colp_ssViewField  "+
            "from Custom_Lists left join Custom_Edits on ColP_ColName=GriP_ColName  "+
            "where ColP_Entity='"+entity+"' and GriP_GridName='"+entity+"List' and 4548=4548 "+
			"order by SeaP_Order";
        //Response.Write("getACObjectFields sql2:" + sql);
        q1 = CRM.CreateQueryObj(sql);
        q1.SelectSQL();
    }	
    var __SeaP_ColName = "";
	var __colsAdded=[];
    while (!q1.eof) {
        var _lookup = q1.FieldValue("ColP_LookupFamily");
        if ((_lookup != null) && (_lookup.toLowerCase() == "case"))
            _lookup = "cases";
        var _newline = (q1.FieldValue("SeaP_Newline") == 1);
		var tmpColP_EntryType=q1.FieldValue("ColP_EntryType");
		if (Defined(q1.FieldValue("ColP_ColName"))&&(q1.FieldValue("ColP_ColName").toLowerCase()=="libr_communicationid"))
		{
			tmpColP_EntryType=56;//clever fix for bad metadata
			_lookup="communication";//...very bad metadata
		}else if (Defined(q1.FieldValue("ColP_ColName"))&&
		 ( (q1.FieldValue("ColP_ColName").toLowerCase()=="quot_opportunityid")|| (q1.FieldValue("ColP_ColName").toLowerCase()=="orde_opportunityid")))
		{
			tmpColP_EntryType=56;//clever fix for bad metadata in quotes/orders
			_lookup="opportunity";//...very bad metadata
		}
        //remove any duplicates
        if ((__SeaP_ColName != q1.FieldValue("ColP_ColName"))&&(Defined(q1.FieldValue("ColP_ColName")))&&(!arrayIncludes(__colsAdded,q1.FieldValue("ColP_ColName").toLowerCase()))) {	
            res.push({
                name: q1.FieldValue("ColP_ColName"),
                order: q1.FieldValue("SeaP_Order"),
                newline: _newline,
                type: tmpColP_EntryType,
                componentType: getComponentType(tmpColP_EntryType),
                lookup: _lookup,
                viewfields: q1.FieldValue("Colp_ssViewField"),
                SeaP_CreateScript: q1.FieldValue("SeaP_CreateScript")
            });	
			__colsAdded.push(q1.FieldValue("ColP_ColName"));
        }
        __SeaP_ColName = q1.FieldValue("ColP_ColName");

        q1.NextRecord();
    }	
    if (res.length > 0) {
        setCache(_cachekey, res);
    }
    return res;
}

function getSearchListFields(entity) {
    var _cachekey = "getSearchListFields_" + entity;
    var _cachedObj = getCache(_cachekey);
    if (_cachedObj != null) {
        return _cachedObj;
    }

    entity = new String(entity);
    if (entity.toLowerCase() == "case")
        entity = "cases";
    var res = [];
    entity = new String(entity);
    entity = entity.toLowerCase();
    res = getACListFields(entity);
    var tableinfo = getTableInfo(entity);

    switch (entity) {
        case "user":
        case "users":
            if (res.length == 0) {
                res.push({
                    name: "user_firstname",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    newline: true,
                    viewfields: ""
                });
                res.push({
                    name: "user_lastname",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    newline: true,
                    viewfields: ""
                });
                res.push({
                    name: "user_emailaddress",
                    order: 1,
                    type: 12,
                    componentType: getComponentType(12),
                    lookup: "",
                    newline: true,
                    viewfields: ""
                });
                res.push({
                    name: "user_mobilephone",
                    order: 1,
                    type: 10,
                    componentType: "MyFormPhone",
                    lookup: "",
                    newline: true,
                    viewfields: ""
                });
                res.push({
                    name: "user_homephone",
                    order: 1,
                    type: 10,
                    componentType: "MyFormPhone",
                    lookup: "",
                    newline: true,
                    viewfields: ""
                });
            }
            break;
        case "address":
            if (res.length == 0) {
                res.push({
                    name: "Addr_Address1",
                    order: 10,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "Addr_PostCode",
                    order: 17,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });					
                res.push({
                    name: "Addr_City",
                    order: 14,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });				
                res.push({
                    name: "Addr_Address2",
                    order: 11,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "Addr_Address3",
                    order: 12,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "Addr_Address4",
                    order: 13,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "Addr_State",
                    order: 15,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "Addr_Country",
                    order: 16,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "Addr_Country",
                    viewfields: ""
                });										
            }
            break;
        case "company":
            if (res.length == 0) {
                res.push({
                    name: "comp_name",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;
        case "solution":
		case "solutions":
            if (res.length == 0) {
				res.push({
                    name: "Soln_ReferenceId",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
				});
                res.push({
                    name: "Soln_Description",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;				
        case "person":
            if (res.length == 0) {
                res.push({
                    name: "pers_fullname",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;
        case "cases":
        case "case":
            if (res.length == 0) {
                res.push({
                    name: "case_referenceid",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                }, {
                    name: "case_description",
                    order: 2,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;
        case "opportunity":
            if (res.length == 0) {
                res.push({
                    name: "oppo_description",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;
        case "quotes":
        case "quote":
            if (res.length == 0) {
                res.push({
                    name: "quot_reference",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "quot_description",
                    order: 2,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "quot_status",
                    order: 2,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "orqu_status",
                    viewfields: ""
                });
            }
            break;
        case "orders":
        case "order":
            if (res.length == 0) {
                res.push({
                    name: "orde_reference",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "orde_description",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "orde_status",
                    order: 2,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "orqu_status",
                    viewfields: ""
                });
            }
            break;
        case "lead":
            if (res.length == 0) {
                res.push({
                    name: "lead_personfirstname",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                }, {
                    name: "lead_personlastname",
                    order: 2,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;
        case "communication":
            if (res.length == 0) {
                res.push({
                    name: "comm_subject",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;
        case "library":
            if (res.length == 0) {
                res.push({
                    name: "libr_updateddate",
                    order: 1,
                    type: 41,
                    componentType: getComponentType(41),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "libr_filename",
                    order: 2,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "libr_type",
                    order: 3,
                    type: 21,
                    componentType: getComponentType(21),
                    lookup: "libr_type",
                    viewfields: ""
                });
                res.push({
                    name: "libr_category",
                    order: 4,
                    type: 21,
                    componentType: getComponentType(21),
                    lookup: "libr_category",
                    viewfields: ""
                });
                res.push({
                    name: "libr_userid",
                    order: 5,
                    type: 22,
                    componentType: getComponentType(22),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "libr_note",
                    order: 6,
                    type: 11,
                    componentType: getComponentType(11),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "libr_status",
                    order: 7,
                    type: 21,
                    componentType: getComponentType(21),
                    lookup: "libr_status",
                    viewfields: ""
                });
            }
            break;
        case "notes":
            if (res.length == 0) {
                res.push({
                    name: "note_createddate",
                    order: 1,
                    type: 41,
                    componentType: getComponentType(41),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "note_createdby",
                    order: 1,
                    type: 22,
                    componentType: getComponentType(22),
                    lookup: "",
                    viewfields: ""
                });
                res.push({
                    name: "note_note",
                    order: 1,
                    type: 11,
                    componentType: getComponentType(11),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;
        case "phone":
            if (res.length == 0) {
                res.push({
                    name: "phon_number",
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;			
        default:
            if (res.length == 0) {
                var _tmpnamefield = tableinfo.prefix + "_name";
                var _tmpq = queryCustomEditsByEntity(_tmpnamefield,entity);
                if (!_tmpq.eof){
                    res.push({
                        name: _tmpnamefield,
                        order: 1,
                        type: 10,
                        componentType: getComponentType(10),
                        lookup: "",
                        viewfields: ""
                    });
                }
            }
            if (res.length == 0) {
                var _tmpdescfield = tableinfo.prefix + "_description";
                var _tmpq2 = queryCustomEditsByEntity(_tmpdescfield,entity);
                if (!_tmpq2.eof){
                    res.push({
                        name: _tmpdescfield,
                        order: 1,
                        type: 10,
                        componentType: getComponentType(10),
                        lookup: "",
                        viewfields: ""
                    });
                }
            }
            //last chance....we just add in the ID field
            if (res.length == 0) {
                _tmpidfield = tableinfo.idfield;
                res.push({
                    name: _tmpidfield,
                    order: 1,
                    type: 10,
                    componentType: getComponentType(10),
                    lookup: "",
                    viewfields: ""
                });
            }
            break;
    }
    setCache(_cachekey, res);
    return res;
}

//fixes up the data from a code to a translation (if needed)
function getSearchListFieldsData(entity, fieldObject, fieldvalue, _forlist, useSmartDisplay) {
    var res = new String(fieldvalue);
    if (!Defined(useSmartDisplay))
        useSmartDisplay = true;
    //Response.Write("<br>"+fieldObject.name+"="+fieldObject.type+"...res="+res);
    //return "";
    if (res == null)
        res = "";

    var fieldname = fieldObject.name;
    var ColP_EntryType = fieldObject.type;
    var ColP_LookupFamily = fieldObject.lookup;
    var Colp_ssViewField = fieldObject.viewfields;	

    if (ColP_EntryType == null) {
        var _cachekey = "getSearchListFieldsData_" + entity + "_" + fieldname;
        var _cachedObj = getCache(_cachekey);
        if (_cachedObj != null) {
            ColP_EntryType = _cachedObj.ColP_EntryType;
            ColP_LookupFamily = _cachedObj.ColP_LookupFamily;
            Colp_ssViewField = _cachedObj.Colp_ssViewField;
        } else {
            //fallback to get the entry type
            //query the custom_edits
            var sql = "select ColP_EntryType, ColP_LookupFamily, ColP_ColName, Colp_ssViewField " +
                "from Custom_Edits " +
                "where 3001=3001 and ColP_Entity='" + entity + "' and ColP_ColName='" + fieldname + "'";
            Glog("getSearchListFieldsData sql:" + sql);
            ColP_EntryType = 10;//default
            var q1 = CRM.CreateQueryObj(sql);
            q1.SelectSQL();
            if (!q1.eof) {
                ColP_EntryType = new Number(q1.FieldValue("ColP_EntryType"));
                ColP_LookupFamily = q1.FieldValue("ColP_LookupFamily");
                Colp_ssViewField = q1.FieldValue("Colp_ssViewField");
            }
            //update cache_
            var _cacheval = {
                ColP_EntryType: ColP_EntryType,
                ColP_LookupFamily: ColP_LookupFamily,
                Colp_ssViewField: Colp_ssViewField
            }
            setCache(_cachekey, _cacheval);
        }
    }
    //Response.Write("ColP_EntryType="+ColP_EntryType);
    if (ColP_EntryType == "41" || ColP_EntryType == "42") {
        //datetime and date fields
        var _fieldvalue = new Date(fieldvalue);
        fieldvalue = adjustUserDate(_fieldvalue);
    }
    if ((!useSmartDisplay) && (ColP_EntryType == "11")) {
        if (fieldvalue)
            fieldvalue = fieldvalue.replace(/\n/g, "<br>");
        else
            fieldvalue = "";
        res = fieldvalue;
    } else
        if ((_forlist) && ((ColP_EntryType == "11") || (ColP_EntryType == "10"))) {
            var resultArray = res.split(" ");
            if (fieldname == "comm_email") {
                res = "-";
                if ((!Defined(fieldvalue)) || (fieldvalue == null)) {
                    res = "";
                }
            } else {
                if (resultArray.length > _baseConfig.listdatawordlength) {
                    resultArray = resultArray.slice(0, _baseConfig.listdatawordlength);
                    res = resultArray.join(" ") + "...";
                }
            }
        } else
            if (ColP_EntryType == "31") {
                //number...but could be ID field				
                if (Colp_ssViewField != "")
                    res = getSSADisplayValue(entity, fieldvalue, Colp_ssViewField, useSmartDisplay);				
                else
                    res = fieldvalue
            } else
                if (ColP_EntryType == "57") {
                    //duration (minutes)
                    res = _formatDurationVal(fieldvalue);
                } else
                    if (ColP_EntryType == "51") {
                        //currency
                        res = _formatMoneyVal(fieldvalue);
                    } else
                        if ((ColP_EntryType == "21") || (ColP_EntryType == "27")) {
                            //selection
                            res = CRM.GetTrans(ColP_LookupFamily, fieldvalue);
                        } else if (ColP_EntryType == "22") {
                            //user
                            res = getUser(fieldvalue);
                        } else if (ColP_EntryType == "56") {
                            res = getSSADisplayValue(ColP_LookupFamily, fieldvalue, Colp_ssViewField, useSmartDisplay);
                        } else if (ColP_EntryType == "23") {
                            //channel
                            res = getTeam(fieldvalue);
                        } else if ((ColP_EntryType == "41") || (ColP_EntryType == "42")) {
                            if (useSmartDisplay)
                                res = getUserDateSmart(fieldvalue, ColP_EntryType == "41");
                            else
                                res = getUserDate(fieldvalue, ColP_EntryType == "41");
                        } else if (ColP_EntryType == "53") {
                            //territory (_secterr)
                            res = getTerritory(fieldvalue);
                        } else if (ColP_EntryType == "59") {
                            //currency symbol
                            res = getCurrencyCID(fieldvalue);
                        } else if (ColP_EntryType == "28") {
                            //multi-selects
                            res = "";
                            var _fieldvalue = new String(fieldvalue);
                            var fieldvaluearr = _fieldvalue.split(",");
                            for (var zz = 0; zz < fieldvaluearr.length; zz++) {
                                if (res != "")
                                    res += ",";
                                res += CRM.GetTrans(ColP_LookupFamily, fieldvaluearr[zz]);
                            }
                        }

    res = res + "";
    if (res == "undefined")
        res = "";
    return res;

}
function getCurrency(value) {
    //todo..add in cid
    return value;
}
function getCurrencyCID(id) {
    var cacheKey = "getCurrencyCID_" + id;
    var cacheres = getCache(cacheKey);
    if (cacheres) {
        return cacheres;
    }
    var res = id;
    if (!id)
        return "";
    var sql = "select Curr_Symbol from Currency where 77456=77456 and Curr_CurrencyID=" + id;
    var q = CRM.CreateQueryObj(sql);
    q.SelectSQL();
    if (!q.eof) {
        res = q.FieldValue("Curr_Symbol");
    }
    setCache(cacheKey, res);
    return res;
}

function getSSADisplayFields(entity, Colp_ssViewField, tableinfo) {
    Glog("getSSADisplayFields START:" + entity + " - " + Colp_ssViewField);
    Colp_ssViewField = new String(Colp_ssViewField);
	//Response.Write(JSON.stringify(tableinfo));	
    if ((Colp_ssViewField == "") || (Colp_ssViewField == null) || (Colp_ssViewField + "" == "undefined") || (Colp_ssViewField.length < 4)) {
        Colp_ssViewField = new String(tableinfo.descriptor);
		
        Glog("getSSADisplayFields Colp_ssViewField:" + Colp_ssViewField);
        var find = '#';
        var re = new RegExp(find, 'g');
        Colp_ssViewField = Colp_ssViewField.replace(re, "");
    }
    if (Colp_ssViewField.slice(-1) == ",")
        Colp_ssViewField = Colp_ssViewField.slice(0, -1);
    if (Colp_ssViewField.indexOf(",") == 0)
        Colp_ssViewField = Colp_ssViewField.slice(1);
    Glog("getSSADisplayFields Colp_ssViewField #2:" + Colp_ssViewField);
    if (entity.toLowerCase() == "company") {
        if (Colp_ssViewField.indexOf("comp_name") == -1)
            Colp_ssViewField = "comp_name";
    }
    if (entity.toLowerCase() == "communication") {
        if (Colp_ssViewField.indexOf("comm_subject") == -1)
            Colp_ssViewField = "comm_subject";
    }	
    if ((Colp_ssViewField == "") || (!Defined(Colp_ssViewField))) {
        var _tmpq22 = queryCustomEdits(tableinfo.prefix + "_name");//make sure the field exists
        if (!_tmpq22.eof)
            Colp_ssViewField = tableinfo.prefix + "_name";
    }
    //fix for bad data where there is a space and not a comma seperating the fields
    var find = ' ';
    var re = new RegExp(find, 'g');
    Colp_ssViewField = Colp_ssViewField.replace(re, ",");

	//test to make sure the column exists
	/*--MR removed this as pers_fullname is a composite field in the view and not in custom edits so breaks things
	var _tmpq2 = queryCustomEdits(Colp_ssViewField);
    if (_tmpq2.eof){
		Colp_ssViewField=tableinfo.idfield;
	}*/
    Glog("getSSADisplayFields END:");
    return Colp_ssViewField;
}

var tables = {}
function getTableInfo(entity) {
    if (entity == "") {
        return {}
    }
    var _cachekey = "getTableInfo_" + entity;
    var _cachedObj = getCache(_cachekey);
    if (_cachedObj != null) {
        return _cachedObj;
    }

    entity = new String(entity);
    entity = entity.toLowerCase();
    if (entity == "case")
        entity = "cases";
	else if (entity == "communications")
        entity = "communication";
	
    var res = {};
    if (entity == "user") {
        res = {
            name: "users",
            tableId: "-1",
            idfield: "user_userid",
            descriptor: "user_fullname",
            searchView: "vusers",
            prefix: "user",
            descriptionField: "user_fullname",
            hascommunications: "N",
            haslibrary: "N",
            DescField: "user_fullname",
            ProgressTableName: null,
            primaryEntity: false,
            isProgressTable: false,
            WorkflowIdField: "",
            CompanyField: "",
            PersonField: "",
            UserField: "",
            IsWebServiceTable: true,
			communicationField:"",
			appFlagField:"",
			canBookmark:false,
			canEdit:false
        }
		//FlagField is a field we use to flag if the record was created by AC/MX...field 
		//name must be prefix_ct_appFlagField..EG comp_ct_appFlagField
        setCache(_cachekey, res);
        return res;
    }
    var q1 = CRM.CreateQueryObj("select bord_tableid, bord_name,bord_idfield,Bord_RecDescriptor,Bord_Prefix,bord_DescriptionField,Bord_PrimaryTable," +
        "Bord_WorkflowIdField, Bord_HasCommunication,Bord_HasLibrary,Bord_ProgressTableName" +
        ",Bord_CompanyUpdateFieldName,Bord_PersonUpdateFieldName,bord_AssignedUserId,bord_WebServiceTable" +
        " from custom_tables where 6400=6400 and bord_name='" + entity + "'");
    try {
        q1.SelectSQL();
    } catch (e) {
        //older versions of CRM..7.3 for example?..THEY DONT HAVE Bord_RecDescriptor
        q1 = CRM.CreateQueryObj("select bord_tableid, bord_name,bord_idfield,'' as Bord_RecDescriptor,Bord_Prefix,bord_DescriptionField,Bord_PrimaryTable," +
            "Bord_WorkflowIdField, Bord_HasCommunication,Bord_HasLibrary,Bord_ProgressTableName,bord_WebServiceTable" +
            " from custom_tables where 6401=6401 and bord_name='" + entity + "'");
        q1.SelectSQL();
    }
    if (!q1.eof) {
        var view = getTableNameViewOnly(entity);
        var RecDescriptor = new String(q1.FieldValue("Bord_RecDescriptor"));
        var descField = GetWebConfigValue(entity + "_descfield");
        if (!Defined(RecDescriptor)||(RecDescriptor == "")) {
			if (Defined(descField))
              RecDescriptor = descField;
			else
			  RecDescriptor = q1.FieldValue("Bord_Prefix")+"_name";///assuming they created this entity with the wizard
        }	
        reHash = new RegExp("#", "g");
        RecDescriptor = RecDescriptor.replace(reHash, "");
        reColon = new RegExp(":", "g");
        RecDescriptor = RecDescriptor.replace(reColon, ",");
        var bord_name = new String(q1.FieldValue("bord_name"));
        bord_name = bord_name.toLowerCase();
        var tableId = new String(q1.FieldValue("bord_tableid"));
        var _Bord_PrimaryTable = new String(q1.FieldValue("Bord_PrimaryTable"));
        _Bord_PrimaryTable = _Bord_PrimaryTable.toLowerCase();
        res = {
            name: bord_name,
            tableId: tableId,
            idfield: q1.FieldValue("bord_idfield"),
            descriptor: RecDescriptor,
            searchView: view,
            prefix: q1.FieldValue("Bord_Prefix"),
            descriptionField: q1.FieldValue("bord_DescriptionField"),
            hascommunications: q1.FieldValue("Bord_HasCommunication") == "Y",
            haslibrary: q1.FieldValue("Bord_HasLibrary") == "Y",
			LibraryField:getLibrEntityColumn(bord_name,q1.FieldValue("Bord_HasCommunication") == "Y"),
            DescField: descField,
            ProgressTableName: q1.FieldValue("Bord_ProgressTableName"),
            primaryEntity: _Bord_PrimaryTable == 'y',
            isProgressTable: helpers_isProgressTable(entity),
            WorkflowIdField: q1.FieldValue("Bord_WorkflowIdField"),
            CompanyField: q1.FieldValue("Bord_CompanyUpdateFieldName"),
            PersonField: q1.FieldValue("Bord_PersonUpdateFieldName"),
            UserField: q1.FieldValue("bord_AssignedUserId"),
            IsWebServiceTable: true,
			communicationField:"",
			appFlagField:"",
			canBookmark:true,
			canEdit:true
        }
		if (bord_name=="library")
		{
			//clever...
			res.haslibrary=false;//metadata has this as true...which is wrong	
			res.searchView="vlibrary";
			res.DescField="libr_filename";
			res.descriptor="libr_filename";
			res.canBookmark=true;
			res.canEdit=false;
		}else
		if (bord_name=="address")
		{
			//clever...
			res.haslibrary=false;
			res.searchView="vAddress";
			res.DescField="addr_address1";
			res.descriptor="addr_address1";
			res.canBookmark=false;
			res.canEdit=false;
		}else
		if ((bord_name=="communication")||(bord_name=="communications"))
		{
			//clever...
			res.haslibrary=true;
			res.canBookmark=true;
			res.canEdit=false;
			res.DescField="comm_subject";
			res.descriptor="comm_subject";
			res.hascommunications="N";
		}
        var qappFlagField = CRM.CreateQueryObj("select * from Custom_Edits where 716255=716255 and ColP_Entity='"+res.name+"' "+
			"and colp_colname='"+res.prefix+"_ct_appFlagField' and ColP_EntryType=10"+
			"and ColP_EntrySize=20");
		try {
			qappFlagField.SelectSQL();
			if (!qappFlagField.eof)
				res.appFlagField=qappFlagField.FieldValue("ColP_ColName");	
		} catch (e) {
		   
		}		
		if (res.hascommunications){			
			var comm_info_sql="select ColP_ColName from custom_edits where 71625=71625 and ColP_Entity='Communication'and ColP_LookupFamily='"+res.name+"'";
			q1comm = CRM.CreateQueryObj(comm_info_sql);
			q1comm.SelectSQL();
			if (!q1comm.eof)
				res.communicationField=q1comm.FieldValue("ColP_ColName");
			else{
				//fallback..when no metadata	
				if (res.name.toLowerCase()=='lead')
					res.communicationField="comm_leadid";
				else if (res.name.toLowerCase()=='company')
					res.communicationField="cmli_comm_companyid";
				else if (res.name.toLowerCase()=='person')
					res.communicationField="cmli_comm_personid";
				else if (res.name.toLowerCase()=='cases')
					res.communicationField="comm_caseid";
				else if (res.name.toLowerCase()=='opportunity')
					res.communicationField="comm_opportunityid";
				else if (res.name.toLowerCase()=='quotes')
					res.communicationField="comm_quoteId";
				else if (res.name.toLowerCase()=='orders')
					res.communicationField="comm_orderId";
				else 
					res.communicationField=getCommEntityColumn(res.name.toLowerCase());
			}
		}
        if ((res.DescField == "") || (res.DescField == null)) {
            //fallback on missing metadata
            res.DescField = res.prefix + "_name";
            var qs = queryCustomEdits(res.DescField);
            if (qs.eof)
                res.DescField = res.idfield;
        }
        setCache(_cachekey, res);
    }
    return res;
}

function helpers_isProgressTable(entity) {

    var cacheKey = "helpers_isProgressTable_" + entity;
    var cacheres = getCache(cacheKey);
    if (cacheres) {
        return cacheres;
    }
    var res = false;
    var sql = "select * from Custom_Tables where 99531=99531 and Bord_ProgressTableName='" + entity + "'";
    q1 = CRM.CreateQueryObj(sql);
    q1.SelectSQL();
    if (!q1.eof)
        res = true;
    setCache(cacheKey, res);
    return res;
}

function getSSADisplayValue(entity, entityid, Colp_ssViewField, appendAllFields) {
    Glog("getSSADisplayValue START:");
    var cacheKey = "";
    try {
        var res = entityid;
		
        if ((entityid == null)||(entityid == "")||(entityid == "0")||(entityid == "-1"))
            return "";
        if ((entityid != "") && (entityid + "" != "undefined")) {

            var tableinfo = getTableInfo(entity);

            var displayFields = getSSADisplayFields(entity, Colp_ssViewField, tableinfo);
            var ssasql = "select " + displayFields + " from " + tableinfo.searchView + " where 1001=1001 and " + tableinfo.idfield + "=" + entityid + "";
//Response.Write(ssasql);
//Response.End();
            cacheKey = ssasql + "_" + appendAllFields;
            var cacheres = getCache(cacheKey);
            if (cacheres) {
               return cacheres;
            }

            Glog("getSSADisplayValue ssasql:" + ssasql);
            var q1 = CRM.CreateQueryObj(ssasql);
            q1.SelectSQL();
            var fields = displayFields.split(",");
            if (!q1.eof) {
                res = q1.FieldValue(fields[0]);
                if ((appendAllFields) && (fields.length > 1) && (Defined(fields[1])) && (Defined(q1.FieldValue(fields[1])))) {
                    res += "\\" + q1.FieldValue(fields[1]);
                }
                if ((appendAllFields) && (fields.length > 2) && (Defined(fields[2])) && (Defined(q1.FieldValue(fields[2])))) {
                    res += "\\" + q1.FieldValue(fields[2]);
                }
                if ((appendAllFields) && (fields.length > 3) && (Defined(fields[3])) && (Defined(q1.FieldValue(fields[3])))) {
                    res += "\\" + q1.FieldValue(fields[3]);
                }
            }
        }
    } catch (e) {
		//log to  the logs
		LogtoCRMsLogs("getSSADisplayValue ERROR:"+e.message);
		LogtoCRMsLogs("values:"+entity+"//"+entityid+"//"+Colp_ssViewField+"//"+appendAllFields);
        return entityid+"error";
    }
    Glog("getSSADisplayValue END:");
    if (cacheKey != "")
        setCache(cacheKey, res);

    return res;
}

function getUser(userid) {
    var cacheKey = "getUser_" + userid;
    var cacheres = getCache(cacheKey);
    if (cacheres) {
        return cacheres;
    }
    var res = userid;
    if ((userid != "") && (userid + "" != "undefined")) {
        var q1 = CRM.CreateQueryObj("select User_FullName from vusers where 4712=4712 and user_userid=" + userid);
        q1.SelectSQL();
        if (!q1.eof) {
            res = q1.FieldValue("User_FullName");
        }
    }
    setCache(cacheKey, res);
    return res;
}

function getTeam(channelid) {
    var cacheKey = "getTeam_" + channelid;
    var cacheres = getCache(cacheKey);
    if (cacheres) {
        return cacheres;
    }
    var res = channelid;
    if ((channelid != "") && (channelid + "" != "undefined")) {
        var q1 = CRM.CreateQueryObj("select Chan_Description from Channel where 99521=99521 and Chan_ChannelId=" + channelid);
        q1.SelectSQL();
        if (!q1.eof) {
            res = q1.FieldValue("Chan_Description");
        }
    }
    setCache(cacheKey, res);
    return res;
}

function getTerritory(id) {
    var cacheKey = "getTerritory_" + id;
    var cacheres = getCache(cacheKey);
    if (cacheres) {
        return cacheres;
    }
    var res = id;
    if ((id != "") && (id + "" != "undefined")) {
        var q1 = CRM.CreateQueryObj("select Terr_Caption from Territories where 9990=9990 and Terr_TerritoryID=" + id);
        q1.SelectSQL();
        if (!q1.eof) {
            res = q1.FieldValue("Terr_Caption");
        }
    }
    setCache(cacheKey, res);
    return res;
}

function helpers_getTimeDiff(startDate, endDate) {
    if (endDate.getFullYear() == 1899)
        return '';
    //params should be date objects
    var timeDiff = Math.abs(startDate.getTime() - endDate.getTime());
    var hh = Math.floor(timeDiff / 1000 / 60 / 60);
    hh = ('0' + hh).slice(-2)

    timeDiff -= hh * 1000 * 60 * 60;
    var mm = Math.floor(timeDiff / 1000 / 60);
    mm = ('0' + mm).slice(-2)

    timeDiff -= mm * 1000 * 60;
    var res = hh + ":" + mm;
    var _ulang = getCRMUserLang();
    switch (_ulang) {
        case "de":
            res = mm + " minuten";
            if (hh > 0) {
                res = hh + " stunden " + res;
            }
            break;
        case "fr":
            res = mm + " minutes";
            if (hh > 0) {
                res = hh + " heures " + res;
            }
            break;
        case "es":
            res = mm + " minutos";
            if (hh > 0) {
                res = hh + " horas " + res;
            }
            break;
        default:
            res = mm + " minutes";
            if (hh == 1) {
                res = hh + " hour " + res;
            } else if (hh > 0) {
                res = hh + " hours " + res;
            }
            break;
    }
    return res;
}

function getUserDateSmart(value, includeTime) {

    ///Response.Write("value=xx="+value);
    var valuedt = new Date(value);

    if (valuedt.getFullYear() == 1899)
        return "";
    var res = getUserDate(value, includeTime);

    if (GetWebConfigValue("DisableSmartDates") == "Y")
        return res;

    //smart part....
    var valuedt = new Date(value);
    var _now = new Date();
    //fix for date only fields
    if ((valuedt.getHours() == 0) && (valuedt.getMinutes() == 0) && (valuedt.getSeconds() == 0)) {
        valuedt.setHours(_now.getHours());
        valuedt.setMinutes(_now.getMinutes() + 1);
    }

    var oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
    var diffDays = Math.round(Math.abs((_now - valuedt) / oneDay));
    var diffMonths = Math.round(Math.abs((_now - valuedt) / (oneDay * 30)));
    var diffYears = Math.round(Math.abs(diffMonths / 12));
    var diffDaysdisplay = diffDays;
    var diffMonthsdisplay = diffMonths;
    var diffYearsdisplay = diffYears;
    if (_now > valuedt) {
        diffDays = diffDays * -1;
        diffMonths = diffMonths * -1;
        diffYears = diffYears * -1;
    }

    if (diffYears >= 2) {
        if (getCRMUserLang() == "de") {
            res += " (in " + diffYearsdisplay + " Jahren)";
        } else if (getCRMUserLang() == "fr") {
            res += " (en " + diffYearsdisplay + " ans)";
        } else if (getCRMUserLang() == "es") {
            res += " (en " + diffYearsdisplay + " años)";
        } else
            res += " (In " + diffYearsdisplay + " years)";
    } else
        if (diffYears <= -2) {
            if (getCRMUserLang() == "de") {
                res += " (vor " + diffYearsdisplay + " Jahren)";
            } else if (getCRMUserLang() == "fr") {
                res += " (il y a " + diffYearsdisplay + " ans)";
            } else if (getCRMUserLang() == "es") {
                res += " (hace " + diffYearsdisplay + " años)";
            } else
                res += " (" + diffYearsdisplay + " years ago)";
        } else
            if (diffDays == 0) {
                if (getCRMUserLang() == "de") {
                    res += " (Heute) ";
                } else if (getCRMUserLang() == "fr") {
                    res += " (Aujourd'hui) ";
                } else if (getCRMUserLang() == "es") {
                    res += " (Hoy dia) ";
                } else
                    res += " (Today) ";
				res+= " " + getDayOfWeek(value);
            } else if ((diffDays < 0) && (diffDays > -62)) {
                if (getCRMUserLang() == "de") {
                    res += " (vor " + diffDaysdisplay + " Tagen)";
                } else if (getCRMUserLang() == "fr") {
                    res += " (il y a " + diffDaysdisplay + " jours)";
                } else if (getCRMUserLang() == "es") {
                    res += " (hace " + diffDaysdisplay + " días)";
                } else
                    res += " (" + diffDaysdisplay + " days ago)";
				res+= " " + getDayOfWeek(value);
            } else if (diffDays < -62) {
                if (getCRMUserLang() == "de") {
                    res += " (vor " + diffMonthsdisplay + " Monaten)";
                } else if (getCRMUserLang() == "fr") {
                    res += " (il y a " + diffMonthsdisplay + " mois)";
                } else if (getCRMUserLang() == "es") {
                    res += " (hace " + diffMonthsdisplay + " meses)";
                } else
                    res += " (" + diffMonthsdisplay + " months ago)";
            } else if ((diffDays > 0) && (diffDays > 62)) {
                if (getCRMUserLang() == "de") {
                    res += " (in " + diffMonthsdisplay + " Monaten)";
                } else if (getCRMUserLang() == "fr") {
                    res += " (en " + diffMonthsdisplay + " mois)";
                } else if (getCRMUserLang() == "es") {
                    res += " (en " + diffMonthsdisplay + " meses)";
                } else
                    res += " (In " + diffMonthsdisplay + " months)";
            }
    return res;
}
function getDayOfWeek(val) {
    var valuedt = new Date(val);
    return CRM.GetTrans("WeekStartDay", valuedt.getDay() + 1);
}

function getUserDate(value, includeTime) {
    var userid = getUserId();
    var dtformat = getUserDateDisplayFormat(userid);
    dtformat = dtformat.toLowerCase();
    var valuedt = new Date(value);
    var res = new Date(value);
    if (res.getFullYear() == 1899) {
        return '';
    }
    //test formats..sql to get the formats in crm
    //select * from Custom_Captions where capt_family = 'UserDateFormat'
    if (dtformat == "d.m.yyyy") {
        res = res.getDate() + "." + (res.getMonth() + 1) + "." + res.getFullYear();
    } else if (dtformat == "dd.mm.yyyy") {
        res = padDate(res.getDate()) + "." + padDate(res.getMonth() + 1) + "." + res.getFullYear();
    } else if (dtformat == "dd/mm/yyyy") {
        res = padDate(res.getDate()) + "/" + padDate(res.getMonth() + 1) + "/" + res.getFullYear();
    } else if (dtformat == "m.d.yyyy") {
        res = (res.getMonth() + 1) + "." + res.getDate() + "." + res.getFullYear();
    } else if (dtformat == "m/d/yyyy") {
        res = (res.getMonth() + 1) + "/" + res.getDate() + "/" + res.getFullYear();
    } else if (dtformat == "mm.dd.yyyy") {
        res = padDate(res.getMonth() + 1) + "." + padDate(res.getDate()) + "." + res.getFullYear();
    } else if (dtformat == "mm/dd/yyyy") {
        res = padDate(res.getMonth() + 1) + "/" + padDate(res.getDate()) + "/" + res.getFullYear();
    } else if (dtformat == "yyyy.mm.dd") {
        res = res.getFullYear() + "." + padDate(res.getMonth() + 1) + "." + padDate(res.getDate());
    } else if (dtformat == "yyyy/mm/dd") {
        res = res.getFullYear() + "/" + padDate(res.getMonth() + 1) + "/" + padDate(res.getDate());
    }
    if (includeTime) {
        res += " " + padDate(valuedt.getHours()) + ":" + padDate(valuedt.getMinutes());
    }
    return res;
}

function padDate(val) {
    val = new String(val);
    if (val.length < 2)
        val = "0" + val;
    return val;
}

var UserDateDisplayFormat = "";
function getUserDateDisplayFormat(userid) {
    if (UserDateDisplayFormat != "") {
        return UserDateDisplayFormat;
    }
    UserDateDisplayFormat = getUserSetting(userid, "NSet_UserDateFormat");
    return UserDateDisplayFormat;
}

function getUserSetting(userid, settingName) {
    var res = userid;
    if ((userid != "") && (userid + "" != "undefined")) {
        var sql = "select USet_Value from UserSettings where 29531=29531 and USet_Key='" + settingName + "' and USet_UserId=" + userid;
        var q1 = CRM.CreateQueryObj(sql);
        q1.SelectSQL();
        if (!q1.eof) {
            return q1("USet_Value");
        }
    }
    return "";
}

function getUserPrefs(userid, setting) {
    var res = "1";
	if ((userid == "") || (userid + "" == "undefined")||(userid == null)) 
		userid="-1";
		
	var sql = "select USet_Value from UserSettings where 295313=295313 and USet_Key='"+setting+"' and USet_UserId=" + userid;
	var q1 = CRM.CreateQueryObj(sql);
	q1.SelectSQL();
	if (!q1.eof) {
		res = q1.FieldValue("USet_Value");
	}
    return res;
}
function isOdd (number) {
  return (number & 1) === 1;
}
function getDiaryStartTime(userid)
{
	var res="00:00";
	var _val=new Number(getUserPrefs(userid, "NSet_DiaryStartTime"));
	if (!isOdd(_val))
		_val--;
	var dt = new Date();	
	dt.setHours(24, 0, 0, 0);
	if (_val>1)
		dt.setMinutes(dt.getMinutes() + (30*(_val-1)));
	//res= padDate(dt.getHours())+":"+padDate(dt.getMinutes());
	res= dt.getHours();
	return res;
}

function getDiaryEndTime(userid)
{
	var res="00:00";
	var _val=new Number(getUserPrefs(userid, "NSet_DiaryEndTime"));
	if (!isOdd(_val))
		_val++;	
	var dt = new Date();	
	dt.setHours(24, 0, 0, 0);
	if (_val>1)
		dt.setMinutes(dt.getMinutes() + (30*(_val-1)));
	res= dt.getHours();
	return res;
}
function getTableNameViewOnly(entity) {
    Glog("getTableNameViewOnly START:" + entity);
    var cacheKey = "getTableNameViewOnly_" + entity;
    var cacheres = getCache(cacheKey);
    if (cacheres) {
        return cacheres;
    }

    var res = entity;
    if (entity.toLowerCase() == "case")
        entity = "cases";
    if (entity.toLowerCase() == "users")
        entity = "users";
    var res = "";
    entity = new String(entity);
    entity = entity.toLowerCase();
    if (entity == "cases") {
        entity = "case";
    }
    //check the view exists...clever..allow one for AC/MX specifcally
    var sys_sql = "select id from sysobjects where 8344=8344 and name = 'vACSearchlist" + entity + "'";
    Glog("getTableNameViewOnly sys_sql:" + sys_sql);
    var q1 = CRM.CreateQueryObj(sys_sql);
    q1.SelectSQL();
    if (!q1.eof) {
        res = "vACSearchlist" + entity;
    } else {
		//check the view exists
		var sys_sql = "select id from sysobjects where 8361=8361 and name = 'vSearchlist" + entity + "'";
		Glog("getTableNameViewOnly sys_sql:" + sys_sql);
		var q1 = CRM.CreateQueryObj(sys_sql);
		q1.SelectSQL();
		if (!q1.eof) {
			res = "vSearchlist" + entity;
		} else {
			if (entity.toLowerCase() == "lead")
				res = "lead";
			else
				res = "v" + entity;
		}
	}
    sys_sql2 = "select id from sysobjects where 8362=8362 and name = '" + res + "'";//final check;
    Glog("getTableNameViewOnly sys_sql2:" + sys_sql2);
    var q2 = CRM.CreateQueryObj(sys_sql2);
    q2.SelectSQL();
    if (q2.eof) {
        res = entity;
    }	
    if (entity.toLowerCase() == "waveitems") {
        res = "vSearchCampaignsWithWaveItem";
    }else
	if (entity.toLowerCase() == "address") {
        res = "vAddressExchange";
    }else
	if (entity.toLowerCase() == "library") {
        res = "vlibrary";
    }else
	if (entity.toLowerCase() == "communication") {
        res = "vcommunication";//a bit clever...usually its vsearchlistcommunication but it does not have the comm link fields
    }	
    setCache(cacheKey, res);
    return res;
}
function getTableNameView(entity) {
    var cacheKey = "getTableNameView_" + entity;
    var cacheres = getCache(cacheKey);
    if (cacheres) {
        return cacheres;
    }
    var res = entity;
    entity = new String(entity);
    if (entity.toLowerCase() == "case")
        entity = "cases";
    var view = getTableNameViewOnly(entity);
    if (view != "") {
        if (entity.toLowerCase() != view.toLowerCase())
            res = entity + "," + view;
        else
            res = entity;
    }
    setCache(cacheKey, res);
    return res;
}

function getEntityName(recordObject, entity) {
    var res = '';
    var fields = getSearchListFields(entity);
    entity = new String(entity);
    entity = entity.toLowerCase();
    if (entity == 'users') {
        var fname = recordObject.item('user_firstname');
        if (fname + '' == 'undefined')
            fname = '';
        var lname = recordObject.item('user_lastname');
        if (lname + '' == 'undefined')
            lname = '';
        res = fname + ' ' + lname;
    } else
        if (entity == 'person') {
            var fname = recordObject.item('pers_firstname');
            if (fname + '' == 'undefined')
                fname = '';
            var lname = recordObject.item('pers_lastname');
            if (lname + '' == 'undefined')
                lname = '';
            res = fname + ' ' + lname;
        } else if (entity == 'company') {
            var comp_name = recordObject.item('comp_name');
            if (comp_name + '' == 'undefined')
                comp_name = '';
            res = comp_name;
        } else if (entity == 'lead') {
            var comp_name = recordObject.item('lead_companyname');
            if (comp_name + '' == 'undefined')
                comp_name = '';
            res = comp_name;
        } else if (entity == 'opportunity') {
            var oppo_description = recordObject.item('oppo_description');
            if (oppo_description + '' == 'undefined')
                oppo_description = '';
            res = oppo_description;
        } else if ((entity == 'case') || (entity == 'cases')) {
            var case_description = recordObject.item('case_referenceid');
            if (case_description + '' == 'undefined')
                case_description = '';
            res = case_description;
        } else if ((entity == 'quote') || (entity == 'quotes')) {
            var quot_reference = recordObject.item('quot_reference');
            if (quot_reference + '' == 'undefined')
                quot_reference = '';
            res = quot_reference;
        } else if ((entity == 'order') || (entity == 'orders')) {
            var orde_reference = recordObject.item('orde_reference');
            if (orde_reference + '' == 'undefined')
                orde_reference = '';
            res = orde_reference;
        }else if (entity == 'address') {
            var addr_address1 = recordObject.item('addr_address1');
            if (addr_address1 + '' == 'undefined')
                addr_address1 = '';
            res = addr_address1;
        }else if (entity == 'library') {
            var libr_filename = recordObject.item('libr_filename');
            if (libr_filename + '' == 'undefined')
                libr_filename = '';
            res = libr_filename;			
        }else if (entity == 'communication') {
            var comm_subject = recordObject.item('comm_subject');
            if (comm_subject + '' == 'undefined')
                comm_subject = '';
            res = comm_subject;				
        }  else {
            res = recordObject.item(fields[0].name);
            if (res + '' == 'undefined')
                res = '';
        }
    return res;
}

function getEntityFavIcon(recordObject, entity) {
	var res="";
	//test for CRM images
	if ((entity == 'company') && recordObject.item('comp_companyid')) {
		var csql="select top 1 libr_libraryid,Libr_Type, Libr_FilePath, Libr_FileName from vlibrary where " +
			" Libr_Type ='CompanyImage' "+
			" and libr_companyid="+recordObject.item('comp_companyid')+
			" order by libr_updateddate desc";
		var libq=CRM.CreateQueryObj(csql);
		libq.SelectSQL();
		if(!libq.eof  && !isportalcode())
		{
			return getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+
				CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp")+isportalcode()+"id="+libq.FieldValue("Libr_LibraryId")+
				"&entity="+entity+"&entityid="+recordObject.item('comp_companyid')
		}			
	}
	if ((entity == 'person') && recordObject.item('pers_personid')) {
		var csql="select top 1 libr_libraryid,Libr_Type, Libr_FilePath, Libr_FileName from vlibrary where " +
			" Libr_Type ='Image' "+
			" and libr_personid="+recordObject.item('pers_personid')+
			" order by libr_updateddate desc";
		var libq=CRM.CreateQueryObj(csql);
		libq.SelectSQL();
		if(!libq.eof  && !isportalcode())
		{
			return getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+
				CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp")+isportalcode()+"id="+libq.FieldValue("Libr_LibraryId")+
				"&entity="+entity+"&entityid="+recordObject.item('pers_personid')
		}	}	
	///fallback
	if ((entity == 'company') && recordObject.item('comp_companyid')) {
		res = recordObject.item('comp_website')+"/favicon.ico";
	}else if (entity == 'lead') {
		res = recordObject.item('Lead_CompanyWebSite')+"/favicon.ico";
	}
	
	if (res=="")
	{
		//fallback to company icon		
		var _x_table=getTableInfo(entity);
		var __dataObj={entity:entity, entityid:recordObject(_x_table.idfield)}
		var assignmentObject=getAssignmentObject(__dataObj);
		if (assignmentObject.companyid!=null)
		{
			var _qf=CRM.FindRecord("company","comp_companyid="+assignmentObject.companyid);
			if (!_qf.eof)
			   res=getEntityFavIcon(_qf, "company")
		}
	}
	if ((res.indexOf("http://")==-1)&&(res.indexOf("https://")==-1))
	  res="https://"+res;
    else if (res.indexOf("http://")==0)
	  res=res.replace("http://","https://");//most sites not are on https but crm has a lot of legacy data
  
	return res;
}

var getEntityEmail_pers_emailaddress = "";
var getEntityEmail_comp_emailaddress = "";
function getEntityEmail(recordObject, entity) {
    var res = '';
    var fields = getSearchListFields(entity);
    entity = new String(entity);
    entity = entity.toLowerCase();
    if (entity == 'users') {
        var user_emailaddress = recordObject.item('user_emailaddress');
        res = user_emailaddress;
    } else
        if ((entity == 'person') && recordObject.item('pers_personid')) {
            if (getEntityEmail_pers_emailaddress == "") {
                var qp1email = CRM.CreateQueryObj("select pers_emailaddress from vsummaryperson where 5498=5498 and pers_personid=" + recordObject.item('pers_personid'));
                qp1email.SelectSQL();
                if (!qp1email.eof) {
                    getEntityEmail_pers_emailaddress = qp1email.FieldValue('pers_emailaddress');
                }
            }
            return getEntityEmail_pers_emailaddress;
        } else if ((entity == 'company') && recordObject.item('comp_companyid')) {
            var _comp_emailaddress = "";
            if (getEntityEmail_comp_emailaddress == "") {
                var qp1email = CRM.CreateQueryObj("select comp_emailaddress from vsummarycompany where 5499=5499 and comp_companyid=" + recordObject.item('comp_companyid'));
                qp1email.SelectSQL();
                if (!qp1email.eof) {
                    _comp_emailaddress = qp1email.FieldValue('comp_emailaddress');
                }
                if (((!_comp_emailaddress) || (_comp_emailaddress == "")) && recordObject('comp_primarypersonid')) {
                    if (recordObject.item('comp_primarypersonid')) {
                        var qp2email = CRM.CreateQueryObj("select pers_emailaddress from vsummaryperson where 5500=5500 and pers_personid=" + recordObject.item('comp_primarypersonid'));
                        qp2email.SelectSQL();
                        if (!qp2email.eof)
                            _comp_emailaddress = qp2email.FieldValue('pers_emailaddress');
                    }
                }
                getEntityEmail_comp_emailaddress = _comp_emailaddress;
            }
            _comp_emailaddress = getEntityEmail_comp_emailaddress;
            return _comp_emailaddress;
        } else if (entity == 'lead') {
            var lead_personemail = recordObject.item('lead_personemail');
            if (lead_personemail + '' == 'undefined')
                lead_personemail = '';
            res = lead_personemail;
        } else if (entity == 'opportunity') {
            if (recordObject.item('oppo_primarypersonid')) {
                var qp2email = CRM.CreateQueryObj("select pers_emailaddress from vsummaryperson where 5501=5501 and pers_personid=" + recordObject.item('oppo_primarypersonid'));
                qp2email.SelectSQL();
                if (!qp2email.eof)
                    res = qp2email.FieldValue('pers_emailaddress');
            }
        } else if ((entity == 'case') || (entity == 'cases')) {
            if (recordObject.item('case_primarypersonid')) {
                var qp2email = CRM.CreateQueryObj("select pers_emailaddress from vsummaryperson where 5502=5502 and pers_personid=" + recordObject.item('case_primarypersonid'));
                qp2email.SelectSQL();
                if (!qp2email.eof)
                    res = qp2email.FieldValue('pers_emailaddress');
            }
        } else {
            //to do ...parse out company or person and get the email for them...
            res = '';
        }
    return res;
}


function getScreenTabs(entity, entityid) {
    var res = [];
    var sql = "select distinct Tabs_Caption, ISNULL(tabs_customfilename, ''), Tabs_Order, Tabs_CustomFileName, convert(varchar(max),Tabs_WhereSQL) as Tabs_WhereSQL from Custom_Tabs WHERE 4610=4610 and Tabs_Entity='" + entity + "int' " +
        "and tabs_deviceid is null and tabs_deleted is null";

    if (isPortalRequest) {
        sql += " AND (tabs_customfilename LIKE '%_acplus%' or tabs_customfilename LIKE '%.aspx') ";
    } else {
        sql += " AND (tabs_customfilename NOT LIKE '%_acplus%')";
    }
	if (G_appMode=="AC")
	{
		sql += " AND (tabs_customfilename NOT LIKE 'listmx_%')";
		//EXCLUDE MX asp pages
		sql += " AND (tabs_customfilename NOT LIKE '%mxonly_%')";
	}		
	else
		if (G_appMode=="MX")
		{
			sql += " AND (tabs_customfilename NOT LIKE 'listac_%')";
			//EXCLUDE AC asp pages
			sql += " AND (tabs_customfilename NOT LIKE '%aconly_%')";
		}

    sql += " ORDER BY Tabs_Order";

//Response.Write("G_appMode:"+sql);		
//Response.End();	

  //  Response.Write("getScreenTabs sql:"+sql);		
//Response.End();	
    var q1 = CRM.CreateQueryObj(sql);
    q1.SelectSQL();
    while (!q1.eof) {
        var xtab = JSON.clone(_tab);
        xtab.tabName = q1.FieldValue("Tabs_Caption");
        if (Defined(q1.FieldValue("tabs_customfilename")))
            xtab.tabAction = q1.FieldValue("tabs_customfilename");
        if ((xtab) && ((xtab.tabAction.indexOf(".asp") > 0) || (xtab.tabAction.indexOf(".dll") > 0))) {
            xtab.tabAction = CRM.Url(xtab.tabAction);
            xtab.tabAction = http_protocol + get_SERVER_NAME() + xtab.tabAction;
            if (isPortalRequest) {
                xtab.tabAction +="?3=3";
            }
            xtab.tabAction += "&app=ac2020&appmode="+G_appMode+"&appplatform="+G_appPlatform+"&entity=" + entity + "&id=" + entityid;//app=ac2020 is to allow the page know what is calling it
			/*
			-this is not needed here as it breaks asp pages on mobilex for example if the user is not logged into crm (which they would not be)
            if (!isPortalRequest) {
                var securityoff = GetWebConfigValue("securityoff") == "true";			
                if ((!securityoff) && (xtab.tabAction.indexOf("_js.") == -1)) {
                    //now put in our normal SID...needed to work around browser security issue
                    var crmsid = getLastFullSID();
                    var thisSID = Request.QueryString("SID");
                    if (crmsid != "") {
                        xtab.tabAction = xtab.tabAction.replace(thisSID, crmsid);
                    }
                }
            }*/
        }
        xtab.tabCaption = CRM.GetTrans("TabNames", q1("Tabs_Caption"));
        xtab.tabOrder = q1.FieldValue("Tabs_Order");
        xtab.tabIcon = getEntityIcon(xtab.tabName);
        xtab.tabwheresql = q1.FieldValue("Tabs_WhereSQL");
        xtab.enabled = true;
        xtab.tabcustomfilename = q1.FieldValue("Tabs_CustomFileName");
        if (res.length == 0) {
            //summary tab
            xtab.tabColor = getTileColour(entity);
        } else {
            xtab.tabColor = getTileColour(xtab.tabName);
        }
        if (xtab.tabAction.toLowerCase().indexOf("_js.") > 0) {
            xtab.component = "EntityReportX";
        } else
            if (xtab.tabAction.toLowerCase().indexOf("xxxxlistcommunications.aspx") > 0) {
                xtab.component = "EntityTimelineX";
            } else if ((xtab.tabAction.indexOf("list") >= 0) && (xtab.tabAction.indexOf(".aspx") > 1)) {
                xtab.component = "EntityListX";
            } else if ((xtab.tabAction.indexOf("int") >= 0) && (xtab.tabAction.indexOf(".aspx") > 1)) {
                xtab.component = "EntityViewX";//needs to be either EntityViewX or EntityListX or EntityViewFrame
            } else if ((xtab.tabAction.indexOf("list_") >= 0)||(xtab.tabAction.indexOf("listmx_") >= 0)||(xtab.tabAction.indexOf("listac_") >= 0)) {
                xtab.component = "EntityListX";
            } else {
				if ((xtab.tabAction)&&(xtab.tabAction.indexOf("http")==-1)&&(xtab.tabAction.indexOf("SID")==-1))
				{
					var _tmpurl=CRM.Url("fakeurl.asp");
					_tmpurl=_tmpurl.replace("fakeurl.asp",xtab.tabcustomfilename);
					xtab.tabAction = getCRMProtocol()+get_SERVER_NAME()+
								":"+get_SERVER_PORT()+_tmpurl;
				}
                xtab.component = "EntityViewFrame";//needs to be either EntityViewX or EntityListX or EntityViewFrame
            }

        xtab.selected = xtab.tabOrder == 1;
        var _entPermission = new String(xtab.tabName);
        _entPermission = _entPermission.toLowerCase();
        if (_entPermission == "people")
            _entPermission = "person";
        if (_entPermission == "communications")
            _entPermission = "communication";

        var _permission = true;

        //Glog("tabAction:" + q1("tabs_customfilename") + ">>>>pos" + q1("tabs_customfilename").indexOf(".asp") + ">>length" + q1("tabs_customfilename").length);

        if (q1.FieldValue("tabs_customfilename").indexOf(".asp") == q1.FieldValue("tabs_customfilename").length - 4 || xtab.tabOrder == 1) {
            _permission = true;
        } else {
            _permission = hasPermissionView(_entPermission);
        }
        if ((isPortalRequest) || (_entPermission == "communication")|| (_entPermission == "notes")) {       
            //we allow comms by default...otherwise whats the point
            _permission = true;
        }
        xtab.permissionEntity=_entPermission;

        //check the where clause doesn't omit it...
        try {
            if ((Defined(xtab.tabwheresql))&&(xtab.tabwheresql.indexOf(" ")>-1)) {
                var __tabtable = getTableInfo(entity);
                var _tabsqlfiter = "select " + __tabtable.idfield + " from v" + entity + " where 5577=5577 and " + __tabtable.idfield + "=" + entityid +
                    " and " + xtab.tabwheresql;
                if (xtab.tabwheresql.toLowerCase().indexOf("user_") > -1)
                    _tabsqlfiter = "select user_userid from vUsers where 4713=4713 and user_userid=" + getUserId() +
                        " and " + xtab.tabwheresql;
                if (_tabsqlfiter.indexOf("#" + __tabtable.idfield.toLowerCase() + "#") > -1) {
                    _tabsqlfiter = replaceAlli(_tabsqlfiter, "#" + __tabtable.idfield.toLowerCase() + "#", entityid);
                }
                var _tabsqlfiterq = CRM.CreateQueryObj(_tabsqlfiter);
                _tabsqlfiterq.SelectSQL();
                if (_tabsqlfiterq.eof)
                    _permission = "";
            }
        } catch (e) {
            //carry on
        }
        if (_permission != "") {
            res.push(xtab);
        }
        q1.NextRecord();
    }
    if (res.length == 0) {
        //no metadata so just create the summary
        var xtab = JSON.clone(_tab);
		xtab.tabName = "Summary";
        xtab.tabAction = "summary";
		xtab.tabCaption = "Summary";
        xtab.tabOrder = 1;
        xtab.tabIcon = getEntityIcon(entity);
        xtab.component = "EntityViewX";
        xtab.enabled = true;
        xtab.selected = true;
        res.push(xtab);
    }
	if ((res.length == 1) && (entity.toLowerCase()=="communication")){
		//check there is an item..otherwise we dont add it
		var _lbrc_commchecksql="select Libr_LibraryId from Library where libr_communicationId="+entityid;
		var _lbrc_commchecksqlq=CRM.CreateQueryObj(_lbrc_commchecksql);
		_lbrc_commchecksqlq.SelectSQL();
		if (!_lbrc_commchecksqlq.eof){
			var xtabLibr = JSON.clone(_tab);
			xtabLibr.tabName = "library";
			xtabLibr.tabCaption = CRM.GetTrans("TabNames", "library");
			xtabLibr.tabOrder = 5;
			xtabLibr.tabIcon = getEntityIcon("library");
			xtabLibr.component = "EntityListX";
			xtabLibr.enabled = true;
			xtabLibr.selected = false;
			xtabLibr.tabAction = "list_library";
			res.push(xtabLibr);		
		}
	}
	if (entity.toLowerCase()=="address"){
		
        var xtabaddrLink = JSON.clone(_tab);
        xtabaddrLink.tabName = "Address_Link";
        xtabaddrLink.tabCaption = CRM.GetTrans("ColNames", "is_address_linked");
        xtabaddrLink.tabOrder = 10;
        xtabaddrLink.tabIcon = getEntityIcon("company");
        xtabaddrLink.component = "EntityListX";
        xtabaddrLink.enabled = true;
        xtabaddrLink.selected = false;
		xtabaddrLink.tabAction = "list_address_link";
        res.push(xtabaddrLink);		
		
        var xtabaddr = JSON.clone(_tab);
        xtabaddr.tabName = "AddressMap";
        xtabaddr.tabCaption = CRM.GetTrans("Accelerator", "Map");
        xtabaddr.tabOrder = 99;
        xtabaddr.tabIcon = getEntityIcon("AddressMap");
		xtabaddr.tabcustomfilename = "sagecrmws/ac2020/map.asp";
        xtabaddr.component = "EntityViewFrame";
        xtabaddr.enabled = true;
        xtabaddr.selected = false;
		xtabaddr.tabAction = CRM.Url(xtabaddr.tabcustomfilename);
		xtabaddr.tabAction = http_protocol + get_SERVER_NAME() + xtabaddr.tabAction;
		if (isPortalRequest) {
			xtabaddr.tabAction +="?4=4";
		}
		xtabaddr.tabAction += "&app=ac2020&entity=" + entity + "&id=" + entityid;//app=ac2020 is to allow the page know what is calling it
		/*
		--removed as breaks mobilex 
		if (!isPortalRequest) {
			var securityoff = GetWebConfigValue("securityoff") == "true";			
			if ((!securityoff) && (xtabaddr.tabAction.indexOf("_js.") == -1)) {
				//now put in our normal SID...needed to work around browser security issue
				var crmsid = getLastFullSID();
				var thisSID = Request.QueryString("SID");
				if (crmsid != "") {
					xtabaddr.tabAction = xtabaddr.tabAction.replace(thisSID, crmsid);
				}
			}
		}*/		
        res.push(xtabaddr);		
	}
    return res;
}

function getEntityIcon(tabName) {
    var res = "";
    tabName = new String(tabName);
    tabName = tabName.toLowerCase();
    //check the config file first
    res = GetWebConfigValue(tabName + "_acicon");
    if ((res != null) && (res != "")) {
        return res;
    }
    switch (tabName) {
        case "individual":
            res = "mdi-account-star-outline";
            break;		
        case "progress":
        case "tracking":
            res = "mdi-progress-clock";
            break;
        case "user":
        case "users":
            res = "mdi-account";
            break;
        case "company":
        case "companies":
        case "Sagecrmws/intcompany.aspx":
            res = "mdi-office-building-outline";
            break;
        case "person":
        case "people":
        case "Sagecrmws/intperson.aspx":
        case "Sagecrmws/listpeople.aspx":
            res = "mdi-account-outline";
            break;
        case "opportunity":
        case "opportunities":
        case "Sagecrmws/intopportunity.aspx":
        case "Sagecrmws/listopportunity.aspx":
            res = "mdi-cash-multiple";
            break;
        case "cases":
        case "case":
        case "Sagecrmws/intcases.aspx":
        case "Sagecrmws/listcases.aspx":
            res = "mdi-briefcase-outline";
            break;
        case "order":
        case "orders":
        case "Sagecrmws/intorders.aspx":
        case "Sagecrmws/listorders.aspx":
            res = "mdi-sale";
            break;
        case "quotes":
        case "quote":
        case "Sagecrmws/intquotes.aspx":
        case "Sagecrmws/listquotes.aspx":
            res = "mdi-account-cash";
            break;
        case "lead":
        case "leads":
        case "Sagecrmws/intlead.aspx":
            res = "mdi-card-account-details-outline";
            break;
        case "communication":
        case "communications":
        case "Sagecrmws/listcommunications.aspx":
            res = "mdi-comment-outline";
            break;
        case "address":
            res = "mdi-map-outline";
            break;
        case "addressmap":
            res = "mdi-map-marker-outline";
            break;						
        case "email":
            res = "mdi-email-outline";
            break;
        case "phone":
            res = "mdi-phone";
            break;
        case "project":
        case "projects":
            res = "mdi-file-tree";
            break;
        case "contract":
        case "contracts":
        case "agreement":
        case "agreements":
            res = "mdi-handshake-outline";
            break;
        case "equipment":
        case "equipement":
            res = "mdi-hammer-screwdriver";
            break;
        case "files":
        case "file":
            res = "file-multiple";
            break;
        case "document":
        case "documents":
        case "library":
            res = "mdi-file-document-multiple";
            break;
        case "notes":
        case "note":
            res = "mdi-note-multiple";
            break;
        case "task":
        case "tasks":
            res = "mdi-checkbox-marked-circle-plus-outline";
            break;
        case "product":
        case "product":
        case "items":
		case "inventory":
		case "warehouse":
            res = "mdi-warehouse";
            break;		
		case "video":
		case "videos":		
            res = "mdi-video-check-outline";
            break;				
		case "sound":
		case "voice":		
		case "record":		
		case "recording":				
            res = "mdi-microphone";
            break;	
		case "camera":
		case "cameras":		
            res = "mdi-camera-image";
            break;		
		case "site":
		case "website":		
		case "sites":
		case "websites":		
            res = "mdi-sitemap";
            break;				
		case "photo":
		case "photos":		
		case "image":
		case "images":
		case "picture":
		case "pictures":
            res = "mdi-image-multiple";
            break;			
		case "card":
		case "vcard":
		case "qr card":		
		case "qr vcard":				
            res = "mdi-card-bulleted-settings-outline";
            break;	
		case "calendar":
		case "vcalendar":
		case "diary":		
		case "ics":				
		case "appt":				
		case "appointments":	
		case "appointment":			
		case "day":			
		case "week":			
		case "days":			
		case "weeks":			
            res = "mdi-calendar-clock-outline ";
            break;				
        default:
            var tabNameLC = tabName.toLowerCase();
	        if (tabNameLC.indexOf("equipment") > -1) {
                 res = "mdi-hammer-screwdriver";
            } else					
              if (tabNameLC.indexOf("summary") > -1) {
                  res = "mdi-grid";
              } else
                if (tabNameLC.indexOf("sale") > -1) {
                    res = "mdi-sale";
                } else
                    if (tabNameLC.indexOf("mail") > -1) {
                        res = "mdi-email-outline";
                    } else
                        if (tabNameLC.indexOf("phone") > -1) {
                            res = "mdi-phone";
                        } else
                            if (tabNameLC.indexOf("graph") > -1) {
                                res = "mdi-chart-bar";
                            } else if (tabNameLC.indexOf("project") > -1) {
                                res = "mdi-file-tree";
                            } else if (tabNameLC.indexOf("contract") > -1) {
                                res = "mdi-handshake-outline";
                            } else if (tabNameLC.indexOf("agreement") > -1) {
                                res = "mdi-handshake-outline";
							} else if (tabNameLC.indexOf("sage") > -1) {
                                res = "mdi-account-box";
							} else if (tabNameLC.indexOf("report") > -1) {
                                res = "mdi-chart-tree";	
                            } else if (tabNameLC.indexOf("location") > -1) {
                                res = "mdi-office-building-marker";
                            } else if ((tabNameLC.indexOf("product") > -1) || (tabNameLC.indexOf("factory") > -1)) {
                                res = "mdi-factory";
                            } else {
                                res = "mdi-file-table-box-outline";
                            }
            break;
    }
    return res;
}

function getScreenSections(entity, query) {
    entity = new String(entity);
    entity = entity.toLowerCase();
    var res = [];
	
	var screenname=entity + "OfficeInt";
	var showAllDisplayData=false;
	if (entity=="communication"){
		if (Defined(query.item("comm_email"))){
		  screenname=entity + "OfficeIntEmail";	  
		}
        showAllDisplayData=true;
	}

    var summary = getScreenSection(entity, query, screenname, CRM.GetTrans("TabNames", "Summary"),true,showAllDisplayData,true);
	if (summary==null)
	{
		screenname=entity + "NewEntry";//custom entities for example
		summary = getScreenSection(entity, query, screenname, CRM.GetTrans("TabNames", "Summary"),true,showAllDisplayData);
	}

	if ((summary==null)&&(entity=="library")){
		//clever..fallback
		summary = getScreenSection(entity, query, "LibraryItemBoxLong", CRM.GetTrans("TabNames", "Summary"),true,showAllDisplayData);
	}
	if (entity.toLowerCase()=="library"  && isportalcode())
	{
		//link to file
		summary.downloadlink = getCRMProtocol() + get_SERVER_NAME()
			+ ":" + get_SERVER_PORT() +
			CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp") +isportalcode()+"id=" + q.RecordID +
			"&entity=" + entity + "&entityid=" + q.RecordID;			
	}	
    res.push(summary);
    //get any secondary screens
    var screensXflags = true;
    var screensXflagsCount = 0;
    while (screensXflags === true) {
        screensXflagsCount++;
        var summaryX = getScreenSection(entity, query, entity + "OfficeInt" + screensXflagsCount, 
								CRM.GetTrans("Screens", entity + "OfficeInt" + screensXflagsCount), true,showAllDisplayData,false);
        if (summaryX == null)
            screensXflags = false;
        else
            res.push(summaryX);

        if (screensXflagsCount > 10)
            screensXflags = false;//to prevent infinite loops...fallback, failsafe
    }
	if (entity == "address") {
		var _mapAddress = getMapAddress(query);
		summary.externallink.url = "https://www.google.com/maps?q=" + _mapAddress;        
	}else
    if ((entity == "company") || (entity == "person")) {
        //company only stuff
        if (entity == "company") {

            //phone
            var phone = getPhoneScreenSection(entity, query.RecordId, CRM.GetTrans("TabNames", "Phone"));
            if (phone != null)
                res.push(phone);

            //email
            var emails = getEmailScreenSection(entity, query.RecordId, CRM.GetTrans("TabNames", "Email"));
            if (emails != null)
                res.push(emails);

            if (query.item("Comp_PrimaryAddressId") != null) {
                var qaddress = CRM.FindRecord("address,vAddressCompany", "96531=96531 and Addr_AddressId=" + query.item("Comp_PrimaryAddressId"));
                var AddressOfficeInt = getScreenSection("address", qaddress, "AddressOfficeInt", CRM.GetTrans("TabNames", "Address"));
                var _mapAddress = getMapAddress(qaddress);
                AddressOfficeInt.externallink.url = "https://www.google.com/maps?q=" + _mapAddress;
                if (AddressOfficeInt != null)
                    res.push(AddressOfficeInt);

            }
        }
        if ((entity == "company") && query.item("comp_primarypersonid") != null) {

            var qperson = CRM.FindRecord("person,vsummaryperson", "96532=96532 and pers_personid=" + query.item("comp_primarypersonid"));
            var PersonOfficeIntSmall = getScreenSection("person", qperson, "PersonOfficeIntSmall", CRM.GetTrans("TabNames", "Person"));
            PersonOfficeIntSmall.internallink = {
                "entity": "person",
                "entityid": query.item("comp_primarypersonid"),
                "color": getTileColour("person"),
                "icon": getEntityIcon("person")
            }
            if (PersonOfficeIntSmall != null) {
                res.push(PersonOfficeIntSmall);
                //phone
                var phone = getPhoneScreenSection("person", query.item("comp_primarypersonid"), CRM.GetTrans("TabNames", "Phone"));
                if (phone != null)
                    res.push(phone);

                //email
                var emails = getEmailScreenSection("person", query.item("comp_primarypersonid"), CRM.GetTrans("TabNames", "Email"));
                if (emails != null)
                    res.push(emails);
            }
        } else if (entity == "person") {

            //phone
            var phone = getPhoneScreenSection(entity, query.RecordId, CRM.GetTrans("TabNames", "Phone"));
            if (phone != null)
                res.push(phone);

            //email
            var emails = getEmailScreenSection(entity, query.RecordId, CRM.GetTrans("TabNames", "Email"));
            if (emails != null)
                res.push(emails);

            if (query.item("pers_PrimaryAddressId") != null) {
                var qaddress = CRM.FindRecord("address,vAddressPerson", "2300=2300 and Addr_AddressId=" + query.item("pers_PrimaryAddressId"));
                var AddressOfficeInt = getScreenSection("address", qaddress, "AddressOfficeInt", CRM.GetTrans("TabNames", "Address"));
                var _mapAddress = getMapAddress(qaddress);
                AddressOfficeInt.externallink.url = "https://www.google.com/maps?q=" + _mapAddress;
                if (AddressOfficeInt != null)
                    res.push(AddressOfficeInt);
            }
        }
    }

    var workflowscreen = getWorkflowStatusScreen(entity, query);
    if (workflowscreen != null)
        res.push(workflowscreen);

    return res;
}

function getWorkflowStatusScreen(entity, query) {

    var res = null;
    try {
        var _tableinfo = getTableInfo(entity);
        if (!_tableinfo.WorkflowIdField)
            return null;
        var WkIn_InstanceID = query.item(_tableinfo.WorkflowIdField);
        if (!WkIn_InstanceID)
            return null;

        var instancesql = "select WkIn_WorkflowId,WkIn_CurrentStateId from WorkflowInstance where 2870=2870 and WkIn_Deleted is null and WkIn_InstanceID=" + WkIn_InstanceID;

        var instancesqlq = CRM.CreateQueryObj(instancesql);
        instancesqlq.SelectSQL();
        if (instancesqlq.eof)
            return null;

        if (!Defined(instancesqlq("WkIn_CurrentStateId") + '') || instancesqlq("WkIn_CurrentStateId") == null)
            return null;

        var workflowsql = "select Work_Description from Workflow where 2871=2871 and Work_Deleted is null and Work_WorkflowId=" + instancesqlq.FieldValue("WkIn_WorkflowId");
        var workflowsqlq = CRM.CreateQueryObj(workflowsql);
        workflowsqlq.SelectSQL();
        if (workflowsqlq.eof)
            return null;

        var statesql = "select WkSt_Name from WorkflowState where 2872=2872 and WkSt_deleted is null and WkSt_StateId=" + instancesqlq.FieldValue("WkIn_CurrentStateId") + " and WkSt_WorkflowId=" + instancesqlq.FieldValue("WkIn_WorkflowId");
        var statesqlq = CRM.CreateQueryObj(statesql);
        statesqlq.SelectSQL();
        if (statesqlq.eof)
            return null;

        res = JSON.clone(_section);
        res.name = "WorkflowScreen";
        res.title = CRM.GetTrans("Tables", "Workflow");
        res.title = capitalize(res.title);
        res.subheader = CRM.GetTrans("Tables", "Workflow");
        res.entity = "workflow";
        res.content = "";
        res.externallink.url = "";

        var _sectionitem1 = JSON.clone(_SectionDataItem);
        _sectionitem1.name = "Workflow";
        _sectionitem1.caption = CRM.GetTrans("Tables", "Workflow");
        _sectionitem1.newline = true;
        _sectionitem1.value = instancesqlq.FieldValue("WkIn_WorkflowId");
        _sectionitem1.displayvalue = workflowsqlq.FieldValue("Work_Description");
        res.data.push(_sectionitem1);

        var _sectionitem2 = JSON.clone(_SectionDataItem);
        _sectionitem2.name = "State";
        _sectionitem2.caption = CRM.GetTrans("ColNames", "wkin_currentstateid");
        _sectionitem2.newline = true;
        _sectionitem2.value = instancesqlq.FieldValue("WkIn_CurrentStateId");
        _sectionitem2.displayvalue = statesqlq.FieldValue("WkSt_Name");
        res.data.push(_sectionitem2);
    }
    catch (exception) {
        //ignore
    }
    return res;
}
function getMapAddress(param_query) {
    var res = new String("");
    if (Defined(param_query.item("addr_address1")))
        res += param_query.item("addr_address1");
    if (Defined(param_query.item("addr_address2")))
        res += " " + param_query.item("addr_address2");
    if (Defined(param_query.item("addr_address3")))
        res += " " + param_query.item("addr_address3");
    if (Defined(param_query.item("addr_address4")))
        res += " " + param_query.item("addr_address4");
    if (Defined(param_query.item("addr_address5")))
        res += param_query.item("addr_address5");
    if (Defined(param_query.item("addr_city")))
        res += " " + param_query.item("addr_city");
    if (Defined(param_query.item("addr_state")))
        res += " " + param_query.item("addr_state");
    if (Defined(param_query.item("addr_postcode")))
        res += " " + param_query.item("addr_postcode");
    if (Defined(param_query.item("addr_country")))
        res += " " + param_query.item("addr_country");

    res = res.replace(/[" "]/g, "%20");
    return res;
}

function getScreenSection(entity, query, screenname, screentitle, isSubscreen, showAllDisplayData,showLinks) {
	if (!Defined(showAllDisplayData))
		showAllDisplayData=false;
	
    var res = JSON.clone(_section);
    res.title = screentitle;
    res.name = screenname;
    res.closed = false;
    res.searchData = query.RecordId;
    var table = getTableInfo(entity);
    var field = {
        type: "31",
        name: table.idfield,
        lookup: entity
    }
	
	if (showLinks!==false){
		res.externallink.url = getExternalLink(field, query);
		res.pagelink.url = getPageLink(field, query);
	}
	if (screenname=="communicationofficeint")
	{
		screenname="communicationofficeintemail";
	}

    var cacheKey = "getCobj_CustomContent_" + screenname;
    var cacheres = getCache(cacheKey);
    if (cacheres != null) {
        res.content = cacheres;
    } else {
        //custom content?
        var sqlScreen = "select Cobj_CustomContent from Custom_ScreenObjects where 7129=7129 and cobj_name='" + screenname + "'";
        var qsqlScreen = CRM.CreateQueryObj(sqlScreen);
        qsqlScreen.SelectSQL();
        if (!qsqlScreen.eof) {
            res.content = qsqlScreen.FieldValue("Cobj_CustomContent");
            if (!res.content)
                res.content = "";
            setCache(cacheKey, res.content);
        }
    }

    //if (isSubscreen === true) //not sure why this was here..leaving for now in case we realise something...issue is it was overwriting links in summary
    //    res.externallink.url = "";
    res.tilecolor = getTileColour(entity);
    res.tileicon = getTileIcon(entity);
    res.entity = entity;
    var fields = getACObjectFields(entity, screenname, !isSubscreen);
    if ((fields.length == 0) && (entity.toLowerCase() == "users")) {
        fields = getSearchListFields("users");
    }
    for (var c = 0; c < fields.length; c++) {
        var _sectionitem = JSON.clone(_SectionDataItem);
        _sectionitem.name = fields[c].name;
        _sectionitem.newline = fields[c].newline;
        _sectionitem.componentType = fields[c].componentType;	
        if (fields[c].type == "11") {
            _sectionitem.value = query.item(fields[c].name);
			//default is not to show all...mutliline text fields get loaded by the user..mostly
			if (showAllDisplayData===false)
			{
				if (Defined(_sectionitem.value)) {
					var field_resultArray = _sectionitem.value.split(" ");
					if (field_resultArray.length > _baseConfig.listdatawordlength) {
						field_resultArray = field_resultArray.slice(0, _baseConfig.listdatawordlength);
						_sectionitem.value = field_resultArray.join(" ") + "...";
					} else {
						if (_sectionitem.value.length > 50)
							_sectionitem.value = _sectionitem.value.substr(0, 50) + "...";
					}
				}
			
				_sectionitem.displayvalue = _sectionitem.value;
				//load field data link now....
				var _fieldurl = "";
				var _loadlinkentity = entity;
				var _loadlinkentityidfield = table.idfield;
				//if (_loadlinkentity == "communication") {
				//	_loadlinkentityidfield = "cmli_commlinkid";
				//}
				if (isPortalRequest) {
					_fieldurl = getCRMProtocol() + get_SERVER_NAME()
						+ ":" + get_SERVER_PORT() +
						CRM.Url("sagecrmws/ac2020/getFieldData.asp") + "?entity=" + _loadlinkentity + "&entityid=" + query.item(_loadlinkentityidfield) + "&field=" + fields[c].name;
				} else {
					_fieldurl = getCRMProtocol() + get_SERVER_NAME()
						+ ":" + get_SERVER_PORT() +
						CRM.Url("sagecrmws/ac2020/getFieldData.asp") + "&entity=" + _loadlinkentity + "&entityid=" + query.item(_loadlinkentityidfield) + "&field=" + fields[c].name;
				}
			}else{
				_sectionitem.displayvalue = _sectionitem.value;
			}
			/*
			Removed as we do not do this here as this data is used in the AC/MX app
            var securityoff = GetWebConfigValue("securityoff") == "true";
            if (!securityoff) {
                //now put in our normal SID...needed to work around browser security issue
                var crmsid = getLastFullSID();
                var thisSID = Request.QueryString("SID");
                if (Defined(_fieldurl)&&(crmsid != "")) {
                    _fieldurl = _fieldurl.replace(thisSID, crmsid);
                }
            }*/
            _sectionitem.loadlink = _fieldurl;
        } else
            if (fields[c].type == "59") {
                //51=currency
                _sectionitem.value = query.item(fields[c].name);
                _sectionitem.displayvalue = getCurrencyCID(query.item(fields[c].name));
            } else
                if (fields[c].type == "28") {
                    //multi-currency
                    _sectionitem.value = query.item(fields[c].name);
                    _sectionitem.displayvalue = getSearchListFieldsData(entity, fields[c], query.item(fields[c].name));
                } else
                    if (fields[c].type == "51") {
                        //51=currency
                        _sectionitem.value = { currency: query.item(fields[c].name + "_CID"), amount: query.item(fields[c].name) };
                        _sectionitem.displayvalue = getCurrencyCID(query.item(fields[c].name + "_CID")) + " " + getSearchListFieldsData(entity, fields[c], query.item(fields[c].name));
                    } else
                        if ((fields[c].type == "41") || (fields[c].type == "42")) {
                            _sectionitem.displayvalue = getSearchListFieldsData(entity, fields[c], query.item(fields[c].name));
                            _sectionitem.value = new String(query.item(fields[c].name));
                        } else {
                            try {
                                _sectionitem.value = query.item(fields[c].name);
                                _sectionitem.displayvalue = getSearchListFieldsData(entity, fields[c], query.item(fields[c].name));
                            } catch (e) {
                                _sectionitem.value = "ERROR on field:" + fields[c].name;
                                _sectionitem.displayvalue = "ERROR message:" + e.message;
                            }
                        }
        _sectionitem.type = fields[c].type;
        _sectionitem.caption = CRM.GetTrans("ColNames", fields[c].name);

			_sectionitem.externallink.url = getExternalLink(fields[c], query);
			_sectionitem.pagelink.url = getPageLink(fields[c], query);

        if ((_sectionitem.externallink.url == "") && (c == 0)) {
            _sectionitem.externallink.url = res.externallink.url;
        }
        _sectionitem.internallink = getInternallLink(fields[c], query);

        //*****************
        //create script...clever...
        var SeaP_CreateScript = fields[c].SeaP_CreateScript;

        var Caption = _sectionitem.caption;
        var Value = _sectionitem.value;		
        var DisplayValue = _sectionitem.displayvalue;
		if (_sectionitem.componentType=="MyFormCheckbox"){
			//checkbox...clever..need to fix data for vue TO DO...THIS IS NOT ACTUALLY WORKING!!!
			if (Value=="Y")
				Value=true;
			else 
				Value=false;			
		}		
        var Hidden = _sectionitem.hidden;
        var ValueStyle = _sectionitem.displayvalue_style;
        var CaptionStyle = _sectionitem.caption_style;
        try {
            if (Defined(SeaP_CreateScript)) {

                SeaP_CreateScript = new String(SeaP_CreateScript).replace(/#entity#/ig, entity || "");
                SeaP_CreateScript = SeaP_CreateScript.replace(/CRM.GetContextInfo/ig, "GetContextInfo");
                SeaP_CreateScript = SeaP_CreateScript.replace(/eWare.GetContextInfo/ig, "GetContextInfo");
                eval(SeaP_CreateScript);

            }
        } catch (e) {
            //ignore
        }
        _sectionitem.caption = Caption;
        _sectionitem.value = Value;
        //Response.Write("<br>"+_sectionitem.caption+"="+_sectionitem.value);
        _sectionitem.hidden = Hidden;
        _sectionitem.displayvalue_style = ValueStyle;
        _sectionitem.caption_style = CaptionStyle;
        _sectionitem.displayvalue = DisplayValue;	
	
        //*****************

        res.data.push(_sectionitem);
    }
    if (res.data.length == 0)
        return null;
    return res;
}

function getTileColour(entity) {
    var res = "";
    var xentity = new String(entity);
    xentity = xentity.toLowerCase();
    if (entity == "case")
        entity = "cases";
    //check the config file first
    res = GetWebConfigValue(entity + "_accolor");
    if ((res != null) && (res != "")) {
        return res;
    }
    res = "black";
    switch (xentity) {
        case "individual":
            res = "red";
            break;		
        case "company":
            res = "orange";
            break;
        case "person":
        case "people":
            res = "blue";
            break;
        case "opportunity":
            res = "green";
            break;
        case "cases":
            res = "purple";
        case "lead":
        case "leads":
            res = "purple";
            break;
        case "address":
            res = "cyan";
            break;				
        case "communication":
        case "communications":
			res="blue";
			break;
        case "email":
        case "phone":
            res = "grey";
            break;
        case "library":
            res = "black";
            break;			
        default:
            res = "purple";
            break;
    }
    return res;
}
function getTileIcon(entity) {
    return getEntityIcon(entity);
}

function EntityInSearchEntities(entity) {
    var res = false;
    var configSearchEntities = new String(GetWebConfigValue("SearchEntities"));
    configSearchEntities = configSearchEntities.toLowerCase();
    var configSearchEntities_arr = configSearchEntities.split(",");
    if (contains(configSearchEntities_arr, entity)) {
        res = true;
    }
    return res;
}

function getInternallLink(field, query) {
    var res = { "entity": "", "entityid": "", "icon": "" }
    try {
        if (!query.item(field.name))
            return res;
    } catch (e) {
        return res;
    }
    if ((field.type == "56") || (field.type == "31")) {
        if ((field.lookup) && (EntityInSearchEntities(field.lookup.toLowerCase()))) {
            res = {
                "entity": field.lookup.toLowerCase(),
                "entityid": query.item(field.name),
                "color": getTileColour(field.lookup.toLowerCase()),
                "icon": getEntityIcon(field.lookup.toLowerCase())
            }
        }
    }
    return res;
}

var G_LastFullSID = "";
var G_LastFullSIDRequested = false;
function getLastFullSID() {
    if (G_LastFullSIDRequested) {
        return G_LastFullSID;
    }
    var _sql = "select top 1 acty_SID from vUserActivity where 4720=4720 and User_UserId=" + getUserId() + " and acty_logout is null and acty_method not like 'WebServices%' order by Acty_CreatedDate desc";
    var q = CRM.CreateQueryObj(_sql);
    q.SelectSQL();
    if (!q.eof) {
        G_LastFullSID = q.FieldValue("acty_SID");
        if (!Defined(G_LastFullSID))
            G_LastFullSID = "";
    }
    G_LastFullSIDRequested = true;
    return G_LastFullSID;
}

//this link opens a page on crm and sets the localstorage value which is then picked up 
//a js file in the js/custom folder...ct_accelerator.js
function getPageLink(field, query) {
    if (isPortalRequest) return "";
	
	var UsePageLink = GetWebConfigValue("UsePageLink") == "Y";
	if (!UsePageLink) return "";
	
    var res = "";

    try {
        if (!query.item(field.name))
            return res;
    } catch (e) {
        return res;
    }
	///clever file download
	if (field.name.toLowerCase() == "libr_filename"  && !isportalcode()) {
		res = getCRMProtocol() + get_SERVER_NAME()
			+ ":" + get_SERVER_PORT() +
			CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp") +isportalcode()+"id=" + query.item("libr_libraryid") +
			"&entity=library&entityid=" + query.item("libr_libraryid");	
	}
    if ((field.type == "56") || (field.type == "31")) {
        if (field.lookup == null)
            field.lookup = "";
		if (field.lookup.toLowerCase() == "company") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(200) + "&Key0=1&Key1=" + query.item(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "person") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(220) + "&Key0=2&Key2=" + query.item(field.name);
            res = res.replace("Key0=58", "");
        }
        else if ((field.lookup.toLowerCase() == "cases") || (field.lookup.toLowerCase() == "case")) {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(281) + "&Key0=8&Key8=" + query.item(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "opportunity") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(260) + "&Key0=7&Key7=" + query.item(field.name);
            res = res.replace("&Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "lead") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(192) + "&Key0=44&Key44=" + query.item(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "quotes") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(1469) + "&Key0=86&Key86=" + query.item(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "orders") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(1463) + "&Key0=71&Key71=" + query.item(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "solutions") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(1284) + "&Key0=68&Key68=" + query(field.name);
            res = res.replace("Key0=58", "");
        }			
        else if (field.lookup.toLowerCase() == "communication") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(363) + "&Key6=" + query.item(field.name) + "&Comm_CommunicationId=" + query.item(field.name);
            //remove...&Key0=58
            res = new String(res);
            res = res.replace("Key0=58", "");
        }
        else if ((field.lookup.toLowerCase() == "address")||(field.lookup.toLowerCase() == "library")) {
			return "";
			/*
			--does not work for address...leaving here as reminder
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(240) + "&Key6=" + query.item(field.name) + "&Addr_AddressId=" + query.item(field.name);
            //remove...&Key0=58
            res = new String(res);
            res = res.replace("Key0=58", "");*/
        }		
        else {
            //custom entity...result should look something like this
            //CustomPages/Project/ProjectSummary.asp?proj_ProjectID=4&SID=119418504940440&F=&J=Project/ProjectSummary.asp
            var sql = "select top 1 Tabs_CustomFileName,Tabs_Action,Tabs_CustomFunction, Tabs_Entity from Custom_Tabs where 96537=96537 and Tabs_Entity='" + field.lookup.toLowerCase() + "' order by Tabs_Order";
            var q3 = CRM.CreateQueryObj(sql);
            q3.SelectSQL();
            if (!q3.eof) {
                if (query.item(field.name) + "" != "undefined") {
                    var Tabs_CustomFileName = q3.FieldValue("Tabs_CustomFileName");
                    var table = getTableInfo(field.lookup.toLowerCase());
                    if (q3.FieldValue("Tabs_Action") + "" == "customdotnetdll") {
                        res = getCRMProtocol() + get_SERVER_NAME()
                            + ":" + get_SERVER_PORT() +
                            CRM.url(Tabs_CustomFileName + "-" + q3.FieldValue("Tabs_CustomFunction")) + "&" + table.idfield + "=" + query.item(field.name) +
                            "&J=" + q3.FieldValue("Tabs_Entity");
                        if (res.indexOf("dotnetdll=") == -1) {
                            //fallback to manual fix
                            var crm_url432 = CRM.Url(432);
                            res = getCRMProtocol() + get_SERVER_NAME()
                                + ":" + get_SERVER_PORT() + "/" + crm_url432 +
                                '&dotnetdll=' + Tabs_CustomFileName + '&dotnetfunc=' + q3.FieldValue('Tabs_CustomFunction') +
                                "&" + table.idfield + "=" + query.item(field.name) +
                                "&J=" + q3.FieldValue("Tabs_Entity");
                        }
                    }
                    else {
                        res = getCRMProtocol() + get_SERVER_NAME()
                            + ":" + get_SERVER_PORT() +
                            CRM.url(Tabs_CustomFileName) + "&" + table.idfield + "=" + query.item(field.name) +
                            "&J=" + Tabs_CustomFileName;
                    }
                }

            }
        }
    }
	/*
	--no longer needed as we only open in CRM when its active
    var securityoff = GetWebConfigValue("securityoff") == "true";
    if (!securityoff) {
        //now put in our normal SID...needed to work around browser security issue
        var crmsid = getLastFullSID();
        if (crmsid == "")
            return "";///no external link
        var thisSID = Request.QueryString("SID");
        if (crmsid != "") {
            res = res.replace(thisSID, crmsid);
        }
    }*/
	//now fix up the url so it goes into a query string easy
	//__SID__
	res=replaceSIDParam(res,"__SID__");
	res=encodeURIComponent(res)
	if (res!=""){
		res=getCRMProtocol() + get_SERVER_NAME()+ ":" + get_SERVER_PORT() +"/"+
			sInstallName+"/custompages/sagecrmws/ac2020/ct_open.asp?sagecrmurl="+res;
	}
    return res;
}

function getExternalLink(field, query) {
    if (isPortalRequest) return "";

	var UseExternalLink = GetWebConfigValue("UseExternalLink") == "Y";
	if (!UseExternalLink){
		//check ..if UsePageLink is also not set we assume true
		if (GetWebConfigValue("UsePageLink") != "Y")
			UseExternalLink=true;
	}
	if (!UseExternalLink) return "";

    var res = "";

    try {
        if (!query(field.name))
            return res;
    } catch (e) {
        return res;
    }
    if ((field.type == "56") || (field.type == "31")) {
        if (field.lookup == null)
            field.lookup = "";
        if (field.lookup.toLowerCase() == "company") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(200) + "&Key0=1&Key1=" + query(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "person") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(220) + "&Key0=2&Key2=" + query(field.name);
            res = res.replace("Key0=58", "");
        }
        else if ((field.lookup.toLowerCase() == "cases") || (field.lookup.toLowerCase() == "case")) {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(281) + "&Key0=8&Key8=" + query(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "opportunity") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(260) + "&Key0=7&Key7=" + query(field.name);
            res = res.replace("&Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "lead") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(192) + "&Key0=44&Key44=" + query(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "quotes") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(1469) + "&Key0=86&Key86=" + query(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "orders") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(1463) + "&Key0=71&Key71=" + query(field.name);
            res = res.replace("Key0=58", "");
        }
        else if (field.lookup.toLowerCase() == "communication") {
            res = getCRMProtocol() + get_SERVER_NAME()
                + ":" + get_SERVER_PORT() +
                CRM.url(363) + "&Key6=" + query(field.name) + "&Comm_CommunicationId=" + query(field.name);
            //remove...&Key0=58
            res = new String(res);
            res = res.replace("Key0=58", "");
        }
        else {
            //custom entity...result should look something like this
            //CustomPages/Project/ProjectSummary.asp?proj_ProjectID=4&SID=119418504940440&F=&J=Project/ProjectSummary.asp
            var sql = "select top 1 Tabs_CustomFileName,Tabs_Action,Tabs_CustomFunction, Tabs_Entity from Custom_Tabs where 96537=96537 and Tabs_Entity='" + field.lookup.toLowerCase() + "' order by Tabs_Order";
            var q3 = CRM.CreateQueryObj(sql);
            q3.SelectSQL();
            if (!q3.eof) {
                if (query(field.name) + "" != "undefined") {
                    var Tabs_CustomFileName = q3.FieldValue("Tabs_CustomFileName");
                    var table = getTableInfo(field.lookup.toLowerCase());
                    if (q3.FieldValue("Tabs_Action") + "" == "customdotnetdll") {
                        res = getCRMProtocol() + get_SERVER_NAME()
                            + ":" + get_SERVER_PORT() +
                            CRM.url(Tabs_CustomFileName + "-" + q3.FieldValue("Tabs_CustomFunction")) + "&" + table.idfield + "=" + query(field.name) +
                            "&J=" + q3.FieldValue("Tabs_Entity");
                        if (res.indexOf("dotnetdll=") == -1) {
                            //fallback to manual fix
                            var crm_url432 = CRM.Url(432);
                            res = getCRMProtocol() + get_SERVER_NAME()
                                + ":" + get_SERVER_PORT() + "/" + crm_url432 +
                                '&dotnetdll=' + Tabs_CustomFileName + '&dotnetfunc=' + q3.FieldValue('Tabs_CustomFunction') +
                                "&" + table.idfield + "=" + query(field.name) +
                                "&J=" + q3.FieldValue("Tabs_Entity");
                        }
                    }
                    else {
                        res = getCRMProtocol() + get_SERVER_NAME()
                            + ":" + get_SERVER_PORT() +
                            CRM.url(Tabs_CustomFileName) + "&" + table.idfield + "=" + query(field.name) +
                            "&J=" + Tabs_CustomFileName;
                    }
                }

            }
        }
    }
    var securityoff = GetWebConfigValue("securityoff") == "true";
    if (!securityoff) {
        //now put in our normal SID...needed to work around browser security issue
        var crmsid = getLastFullSID();
        if (crmsid == "")
            return "";///no external link
        var thisSID = Request.QueryString("SID");
        if (crmsid != "") {
            res = res.replace(thisSID, crmsid);
        }
    }
    return res;
}

function replaceSIDParam(url, newSIDValue) {
    // Define a regular expression pattern
    var regex = /(\bSID=)[^&]*/;

    // Replace the matched pattern with the new SID value
    var updatedURL = url.replace(regex, '$1' + newSIDValue);

    return updatedURL;
}

function getEmailScreenSection(entity, id, screentitle) {
    var res = JSON.clone(_section);
    res.title = screentitle;
    res.name = entity + "_email";
    res.entity = "email";
    res.tilecolor = getTileColour("email");
    res.tileicon = getTileIcon("email");
    res.closed = false;
    res.searchData = entity + "=" + id;
    var Capt_Family = "Link_CompEmai";
    if (entity == "person")
        Capt_Family = "Link_PersEmai";
    var sql = "select Capt_" + getCRMUserLang() + " as Title,Emai_EmailAddress from v" + entity + "EmailCaption " +
        "WHERE 963531=963531 and Elink_RecordId = " + id + " AND Capt_Family = N'" + Capt_Family + "'  " +
        "ORDER BY capt_order, Elink_Type";

    var q1 = CRM.CreateQueryObj(sql);
    q1.SelectSQL();
    while (!q1.eof) {
        var _sectionitem = JSON.clone(_SectionDataItem);
        _sectionitem.name = q1.FieldValue("Title");
        _sectionitem.value = q1.FieldValue("Emai_EmailAddress");
        _sectionitem.type = "email";
        _sectionitem.displayvalue = q1.FieldValue("Emai_EmailAddress");
        _sectionitem.caption = CRM.GetTrans(Capt_Family, q1.FieldValue("Title"));
        res.data.push(_sectionitem);
        q1.NextRecord();
    }
    if (res.data.length == 0)
        return null;
    return res;
}
function getPhoneScreenSection(entity, id, screentitle) {
    var res = JSON.clone(_section);
    res.title = screentitle;
    res.name = entity + "_phone";
    res.entity = "phone";
    res.tilecolor = getTileColour("phone");
    res.tileicon = getTileIcon("phone");
    res.closed = false;
    res.searchData = entity + "=" + id;
    var Capt_Family = "Link_CompPhon";
    if (entity == "person")
        Capt_Family = "Link_PersPhon";
    var sql = "select Capt_" + getCRMUserLang() + " as Title,Phon_FullNumber," +
        "Phon_AreaCode,Phon_CountryCode,Phon_Number " +
        " from v" + entity + "PhoneCaption " +
        " WHERE 963532=963532 and Plink_recordID = " + id + " AND Capt_Family = N'" + Capt_Family + "'  " +
        " ORDER BY capt_order, Plink_Type";
    var q1 = CRM.CreateQueryObj(sql);
    q1.SelectSQL();
    while (!q1.eof) {
        var _sectionitem = JSON.clone(_SectionDataItem);
        _sectionitem.name = q1.FieldValue("Title");
        _sectionitem.value = { countrycode_value: q1.FieldValue("Phon_CountryCode"), areacode_value: q1.FieldValue("Phon_AreaCode"), phonenumber_value: q1.FieldValue("Phon_Number") };
        _sectionitem.type = "phone";
        _sectionitem.displayvalue = q1.FieldValue("Phon_FullNumber");
        _sectionitem.caption = CRM.GetTrans(Capt_Family, q1.FieldValue("Title"));
        res.data.push(_sectionitem);
        q1.NextRecord();
    }
    if (res.data.length == 0)
        return null;
    return res;
}

function capitalize(val) {
    val = new String(val);
    return val.charAt(0).toUpperCase() + val.slice(1).toLowerCase();
}

function getEntityRecord(entity, id, extendedfilter) {
    var viewtoUse = getTableNameView(entity);
    var tableinfo = getTableInfo(entity);
    //Response.Write(viewtoUse + "??" + tableinfo.idfield + "=" + id);
	var __whereclause="8081=8081 and " + tableinfo.idfield + "=" + id;
	if (entity=="comm_link")
		__whereclause="8081=8081 and CmLi_Comm_CommunicationId=" + id;
	if (extendedfilter)
		__whereclause+=" and "+extendedfilter;
    var res = CRM.FindRecord(viewtoUse, __whereclause);
    return res;
}

//used in entitysearch
//searchObject.searchfilter.whereclause
function doEntitySearch(entity, searchObject, searchString, orderBy, NumberOfRecordsReturned, page) {
    Glog("doEntitySearch START:" + entity);
    var __message = '';
    if (!page)
        page = 1;
    if (entity.toLowerCase() == "case")
        entity = "cases";
    var fields = getSearchListFields(entity);
    var table = getTableInfo(entity);

    //get the data
    var whereClause = '808=808 and (' + getEntityWhereClause(entity, searchString) + ')';

    var origwhereClause = whereClause;
    Glog("doEntitySearch whereClause-----:" + whereClause);
    //next line used by SSA fields	
    if ((searchObject != null) && (searchObject.searchfilter != null) && (searchObject.searchfilter != '')) {

        if (!searchObject.searchfilter.entityid) {
            var getFieldSQL = "select ColP_ColName from Custom_Edits where 621=621 and  " +
                "ColP_LookupFamily='" + searchObject.searchfilter.entity + "' and ColP_Entity='" + entity + "' and ColP_ColName is not null";
            Glog("doEntitySearch getFieldSQL:" + getFieldSQL);
            var fsq = CRM.CreateQueryObj(getFieldSQL);
            fsq.SelectSQL();
            if (!fsq.eof)
                whereClause += " and " + fsq.FieldValue("ColP_ColName") + "=" + searchObject.searchfilter.entityid;
            else {
                var tble = getTableInfo(searchObject.searchfilter.entity);
                whereClause = tble.idfield + "=" + searchObject.searchfilter.entityid;
            }
        } else {
            Glog("doEntitySearch searchObject:" + JSON.stringify(searchObject));
            whereClause = getSSAWhereFilter(searchObject);
            whereClause += " and " + origwhereClause;//this is our filter on the name for example
            Glog("doEntitySearch whereClause #77:" + whereClause);
        }
        if (searchObject.searchfilter.whereclause != null) {
            whereClause = searchObject.searchfilter.whereclause;
            searchString = whereClause;
            Glog("doEntitySearch whereClause #88:" + whereClause);
        }
    }
	
    if (typeof searchObject == "object" && searchObject != null) {
        if (searchObject.filterSQL != null) {
            whereClause += " and (" + searchObject.filterSQL + ")";
        }
        NumberOfRecordsReturned = 20;//SSA fields in this case	
    }
	
    var tableNameView = null;
    tableNameView = getTableNameView(entity);
    if (tableNameView == "vSearchCampaignsWithWaveItem") {
        orderBy = "WaIt_Name";
        whereClause += " and wait_Deleted is Null and 963541=963541";
    } else if (searchObject
        && searchObject.searchfilter
        && searchObject.searchfilter.entity
        && searchObject.searchfilter.entity.toLowerCase() == "company" && entity.toLowerCase() == "address")
        tableNameView = "Address,vAddressCompany"; //clever ..coping with address and its odd structure
    else if (searchObject
        && searchObject.searchfilter
        && searchObject.searchfilter.entity
        && searchObject.searchfilter.entity.toLowerCase() == "person" && entity.toLowerCase() == "address")
        tableNameView = "Address,vAddressPerson";//clever ..coping with address and its odd structure


    Glog("doEntitySearch " + entity + " whereClause FINAL:" + whereClause);
    Glog("doEntitySearch tableNameView:" + tableNameView);
    var q = null;
	
	if (entity.toLowerCase()=="address")
	{
		//make sure we have our table
		var tableSQL="IF OBJECT_ID(N'acTempAddress', N'U') IS NULL BEGIN "+
			"CREATE TABLE acTempAddress ( "+
			"[Addr_Address1] [nvarchar](40) NULL,[Addr_Address2] [nvarchar](40) NULL,[Addr_Address3] [nvarchar](40) NULL, "+
			"[Addr_Address4] [nvarchar](40) NULL,[Addr_Address5] [nvarchar](40) NULL,[Addr_City] [nvarchar](30) NULL, "+
			"[Addr_State] [nvarchar](30) NULL,[Addr_Country] [nvarchar](30) NULL,[Addr_PostCode] [nvarchar](10) NULL, "+
			"[addr_uszipplusfour] [nchar](4) NULL,[Addr_addressid] [nvarchar](max) NULL,[Addr_CreatedBy] [int] NULL, "+
			"[Addr_CreatedDate] [datetime] NULL,[Addr_UpdatedBy] [int] NULL,[Addr_UpdatedDate] [datetime] NULL, "+
			"[Addr_TimeStamp] [datetime] NULL,[Addr_Deleted] [tinyint] NULL,); END";
		CRM.ExecSQL(tableSQL);	
		var clearPrevResults="delete from acTempAddress where Addr_CreatedBy="+getUserId();
		CRM.ExecSQL(clearPrevResults);	
		var addressaql="INSERT INTO acTempAddress "+
						"(Addr_addressid,addr_address1, addr_address2, addr_address3, addr_address4, Addr_Address5,  "+"Addr_City, Addr_State,Addr_Country,Addr_PostCode,addr_uszipplusfour,Addr_CreatedBy) "+
						"SELECT	STRING_AGG(addr_addressid, ',') as Addr_addressid, "+
						"addr_address1, addr_address2, addr_address3, addr_address4, Addr_Address5,  "+
						"Addr_City, Addr_State,Addr_Country,Addr_PostCode,addr_uszipplusfour, "+getUserId()+" as Addr_CreatedBy "+
						"FROM vAddressExchange "+
						"WHERE 809=809 and (addr_address1 is not null and addr_address1<>'') and "+whereClause+
						"GROUP BY	addr_address1, addr_address2, addr_address3, addr_address4, Addr_Address5, Addr_City,  "+ "Addr_State,Addr_Country,Addr_PostCode,addr_uszipplusfour ";
			CRM.ExecSQL(addressaql);
		//check is the metadata there...
		var _checkacSQL="select Bord_Caption from custom_tables where 7843=7843 and Bord_Name='acTempAddress' and bord_deleted is null";
		var _checkacSQLq=CRM.CreateQueryObj(_checkacSQL);
		_checkacSQLq.SelectSQL();
		if (_checkacSQLq.eof)
		{
			var _accreate=CRM.CreateRecord("custom_tables");
			_accreate("Bord_Caption")="acTempAddress";
			_accreate("Bord_Name")="acTempAddress";
			_accreate("Bord_Prefix")="addr";
			_accreate.SaveChanges();
			CRM.RefreshMetaData();
		}
		q = CRM.Findrecord("AcTempAddress", "8104=8104 and Addr_CreatedBy="+getUserId());
	}else{
		//clever fix for the weird way comms work
		if (tableNameView=="communication,vcommunication")
		{
			tableNameView="communication";
		}		
		//default		
		q = CRM.Findrecord(tableNameView, whereClause);	
	}
	
    var _sortBy = [];
    var _sortDesc = false;

    //removed as it broke the client
    if (!Defined(orderBy) || (orderBy == "") || (orderBy == null) || (orderBy == "null")) {
        //default to first column desc
        if (fields.length > 0) {
            //_sortBy=fields[0].name;
            _sortBy = [];
            orderBy = fields[0].name + " asc";
        }
        try {
            q.OrderBy = orderBy;
        } catch (e) {
            Response.Write("ERROR1 in doEntitySearch:" + e.description);
            Response.Write("<br/>tableNameView #1:" + tableNameView + "-whereClause:" + whereClause + "-orderBy:" + orderBy);
        }
    } else
        if (orderBy != "") {
            try {
                q.OrderBy = orderBy;
                if (_sortBy.length == 0) {
                    var orderBy_arr = orderBy.split(" ");
                    _sortBy = [orderBy_arr[0]];
                    _sortDesc = false;
                    if (Defined(orderBy_arr[1]) && (orderBy_arr.length > 0) && (orderBy_arr[1].toLowerCase() == "desc")) {
                        _sortDesc = true;
                    }
                }
            } catch (e) {
                __message += "ERROR in doEntitySearch:" + e.description;
                __message += "---tableNameView:" + tableNameView + "-whereClause:" + whereClause + "-orderBy:" + orderBy;
            }
        }

    Glog("doEntitySearch orderBy:" + orderBy);
    var recordcount = q.recordcount;
	q.OrderBy += " OFFSET "+((page-1)*NumberOfRecordsReturned)+" ROWS FETCH NEXT "+NumberOfRecordsReturned+" ROWS ONLY;";
	
    Glog("doEntitySearch recordcount:" + recordcount);
    var tableData = [];
    var rowCount = 0;
    //var startFrom = (((NumberOfRecordsReturned * page) - NumberOfRecordsReturned) + 1);
	var startFrom =0;
    try {
        var _xx = q.eof;//test the query....
    } catch (e) {
        __message += '-ERROR2:' + e.description;
        q = CRM.Findrecord(tableNameView, whereClause);
        q.OrderBy = '';	//...assume the order by is on an old ntext column which is not allowed
    }
    while (!q.eof) {
        rowCount++;
        if (rowCount >= startFrom) {
            var _getTileIcon = getTileIcon(entity);
            var _getTileColour = getTileColour(entity);
            var field = {
                type: "31",
                name: table.idfield,
                lookup: entity
            }
            _tmpobj = {
                "count": rowCount,
                "entityid": q.RecordID,
                "entity": entity,
                "tilecolor": getTileColour(entity),
                "tileicon": getTileIcon(entity),
                "externallink": {
                    "url": getExternalLink(field, q),
                    "icon": _getTileIcon,
                    "color": _getTileColour
                },
				"pagelink": {
                    "url": getPageLink(field, q),
                    "icon": _getTileIcon,
                    "color": _getTileColour
                },
                "loadfielddatalinks": []
            }
			if (entity.toLowerCase()=="library"  && isportalcode())
			{
				//link to file
				_tmpobj.downloadlink = getCRMProtocol() + get_SERVER_NAME()
					+ ":" + get_SERVER_PORT() +
					CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp") +isportalcode()+"id=" + q.RecordID +
					"&entity=" + entity + "&entityid=" + q.RecordID;			
			}
			if (entity.toLowerCase()=="address")
			{
				_tmpobj.entityid=q.item("addr_addressid");//clever...its a comma seperated list of values
			}
            Glog("doEntitySearch add row:" + rowCount);
            for (var c = 0; c < fields.length; c++) {
                var _fieldurl = "";
                if (fields[c].type == "11") {
                    _tmpobj[fields[c].name] = getSearchListFieldsData(entity, fields[c], q.item(fields[c].name), true);
                    if (Defined(_tmpobj[fields[c].name])) {
                        var field_resultArray = _tmpobj[fields[c].name].split(" ");
                        if (field_resultArray.length > _baseConfig.listdatawordlength) {
                            field_resultArray = field_resultArray.slice(0, _baseConfig.listdatawordlength);
                            _tmpobj[fields[c].name] = field_resultArray.join(" ") + "...";
                        } else {
                            if (_tmpobj[fields[c].name].length > 50)
                                _tmpobj[fields[c].name] = _tmpobj[fields[c].name].substr(0, 50) + "...";
                        }
                    }
                    if (isPortalRequest)
                        _fieldurl = getCRMProtocol() + get_SERVER_NAME()
                            + ":" + get_SERVER_PORT() +
                            CRM.Url("sagecrmws/ac2020/getFieldData.asp") + "?entity=" + entity + "&entityid=" + q.RecordID + "&field=" + fields[c].name;
                    else
                        _fieldurl = getCRMProtocol() + get_SERVER_NAME()
                            + ":" + get_SERVER_PORT() +
                            CRM.Url("sagecrmws/ac2020/getFieldData.asp") + "&entity=" + entity + "&entityid=" + q.RecordID + "&field=" + fields[c].name;
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
                    }*/
                    var _loadlink = {
                        "field": fields[c].name,
                        "url": _fieldurl
                    }
                    _tmpobj.loadfielddatalinks.push(_loadlink);
                } else
                    if (fields[c].type == "59") {
                        //59=currency symbol
                        _tmpobj[fields[c].name] = getCurrencyCID(q.item(fields[c].name));
                    } else
                        if (fields[c].type == "28") {
                            //multi-currency
                            _tmpobj[fields[c].name] = getSearchListFieldsData(entity, fields[c], q.item(fields[c].name));
                        } else
                            if (fields[c].type == "51") {
                                //51=currency
                                _tmpobj[fields[c].name] = getCurrencyCID(q.item(fields[c].name + "_CID")) + " " + getSearchListFieldsData(entity, fields[c], q.item(fields[c].name));
                            } else {
                                _tmpobj[fields[c].name] = getSearchListFieldsData(entity, fields[c], q.item(fields[c].name));
                                if (entity.toLowerCase() == "waveitems") {
                                    _tmpobj[fields[c].name] += "(" + getSearchListFieldsData(entity, fields[c], q.item("camp_name")) + ")";
                                }
                            }
            }

            tableData.push(_tmpobj);
            Glog("doEntitySearch tableData length:" + tableData.length);
            if (rowCount >= (NumberOfRecordsReturned * page))
                break;
        }
        q.NextRecord();
    }

    var tableColumns = [];
    //add in select field
    tableColumns.push({
        "value": "__Select__",
        "text": "",
        "sortable": false
    });
    for (var c = 0; c < fields.length; c++) {
        tableColumns.push({
            "value": fields[c].name,
            "text": CRM.GetTrans("colNames", fields[c].name),
            "componentType": fields[c].componentType
        });
    }

    var res = {
        "screenMetadata": {
            "lang": getUserLang()
        },
        "data": {
            "recordcount": recordcount,
            "entity": entity,
            "fieldname": (searchObject != null) ? searchObject.fieldname || "" : "",
            "MaxNumberOfRecordsReturned": NumberOfRecordsReturned,
            "page": page,
            "searchstring": searchString,
			"tableNameView":tableNameView,
            "whereclause": whereClause,
            "orderby": orderBy,
            "sortBy": _sortBy,
            "sortDesc": _sortDesc,
            "tableData": tableData,
            "tableColumns": tableColumns,
            "message": __message
        }
    }
    Glog("doEntitySearch END");
    return res;
}

function _hasSQLIndex(tableName, columnsName)
{
	//sql seems slow..so we added cache
  var _ckey=tableName+"_idx_"+columnsName;
  var cacheres2=getCache(_ckey);
  if (cacheres2){
        return cacheres2;
  }
  var _sql="SELECT i.name AS IndexName, i.type_desc AS IndexType "+
	"FROM     sys.indexes AS i "+
	"JOIN  "+
    "sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id "+
	"JOIN  "+
    "sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id "+
	"WHERE  "+
    "OBJECT_NAME(i.object_id) = '"+tableName+"'  "+
	"AND c.name = '"+columnsName+"'; ";
	
  var qi=CRM.CreateQueryObj(_sql);
  qi.SelectSQL();
  var res=false;
  if (qi.eof)
	  res=false;
  else
	  res=true;
  setCache(_ckey,res);  
  return res;  
}

function getTableInfoFromField(fieldName) {

    var cacheKey = "getTableInfoFromField_" + fieldName;
    var cacheres = getCache(cacheKey);
    if (cacheres) {
        return cacheres;
    }

    var res = null;
    var _sql = "select ColP_Entity from custom_edits where 5320=5320 and ColP_ColName='" + fieldName + "'";
    var _q = CRM.CreateQueryObj(_sql);
    _q.SelectSQL();
    if (!_q.eof) {
        res = getTableInfo(_q.FieldValue("ColP_Entity"));
    }
    setCache(cacheKey, res);

    return res;
}

function getSSAWhereFilter(searchObject) {
    Glog("getSSAWhereFilter START");
    //EXAMPLE
    //{"searchstring":"","searchfilter":{"entity":"CaseType","entityid":1},"fieldname":"case_c_caseproblem"}
    var senderField = queryCustomEdits(searchObject.fieldname);
    var senderColp_Restricted = senderField("Colp_Restricted");
    var senderColP_LookupFamily = senderField("ColP_LookupFamily");
    Glog("getSSAWhereFilter senderColp_Restricted:" + senderColp_Restricted);
    Glog("getSSAWhereFilter senderColP_LookupFamily:" + senderColP_LookupFamily);
    var res = "";
    if (Defined(senderColp_Restricted) && (senderColP_LookupFamily != searchObject.searchfilter.entity)) {
        var filtercolumn = queryCustomEdits2(senderColP_LookupFamily, searchObject.searchfilter.entity);
        if (!filtercolumn.eof)
            res = filtercolumn("ColP_ColName") + "=" + searchObject.searchfilter.entityid;
    } else {
        var tble = getTableInfo(searchObject.searchfilter.entity);
        res = tble.idfield + "=" + searchObject.searchfilter.entityid;
    }
    Glog("getSSAWhereFilter res:" + res);
    Glog("getSSAWhereFilter END");
    return res;
}
function queryCustomEdits2(ColP_Entity, ColP_LookupFamily) {
    var sql = "select ColP_ColName from Custom_Edits where 5320=5320 and ColP_Entity='" + ColP_Entity + "' " +
        "and ColP_LookupFamily='" + ColP_LookupFamily + "'";
    Glog("queryCustomEdits2 :" + sql);
    var res = CRM.CreateQueryObj(sql);
    res.SelectSQL();
    if (res.eof && ColP_Entity.toLowerCase() == "address") {
        sql = "";
        if (ColP_LookupFamily.toLowerCase() == "company")
            sql = "select 'AdLi_CompanyId' as ColP_ColName";
        else if (ColP_LookupFamily.toLowerCase() == "person")
            sql = "select 'AdLi_PersonId' as ColP_ColName";
        if (sql != "") {
            res = CRM.CreateQueryObj(sql);
            res.SelectSQL();
        }
    }
    return res;
}
function queryCustomEdits(fieldName) {
    var sql = "select * from Custom_Edits where 5321=5321 and ColP_ColName='" + fieldName + "'";
    var res = CRM.CreateQueryObj(sql);
    Glog("queryCustomEdits :" + sql);
    res.SelectSQL();
    return res;
}
function queryCustomEditsByEntity(fieldName, _entity) {
    var sql = "select * from Custom_Edits where 5322=5322 and ColP_Entity='" + _entity + "' and ColP_ColName='" + fieldName + "'";
    var res = CRM.CreateQueryObj(sql);
    Glog("queryCustomEditsByEntity :" + sql);
    res.SelectSQL();
    return res;
}
//get the workflow settings from the web.config file
function getWorkflowObj(entity) {
    return {
        "workflow": GetWebConfigValue(entity + "_WorkflowName"),
        "workflowstate": GetWebConfigValue(entity + "_WFState")
    }
}

//we have to query the core db for this
function getFieldMaxLength(entity, fieldname, ColP_EntryType) {
    if ((ColP_EntryType == "11") || (ColP_EntryType == "41") || (ColP_EntryType == "42") || (ColP_EntryType == "22")) {
        return "";
    }
    var res = "";
    var sql = "SELECT st.name AS DBColType, sc.length AS DBColLength, sc.name AS DBColName, sc.xprec AS DBPrecision, " +
        "CASE WHEN ISNULLABLE = '1' THEN 'true' ELSE 'false' END as AllowsNull  " +
        "FROM syscolumns sc, sysobjects so, systypes st WHERE 5323=5323 and sc.id = so.id AND sc.xusertype = st.xusertype AND  " +
        "so.name = '" + entity + "' AND sc.name LIKE '" + fieldname + "' ";
    var qa = CRM.CreateQueryObj(sql);
    qa.SelectSQL();
    if (!qa.EOF) {
        res = new Number(qa.FieldValue("DBColLength"));
        res = res / 2;
    }
    return res;

}

function getLibraryRootPath() {
    var _docstore = getSysParam("docstore");
    _docstore = replaceAll(_docstore, '\\', '\\\\');
    return _docstore;
}
function replaceAll(str, find, replace) {
    return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
}
function replaceAlli(str, find, replace) {
    return str.replace(new RegExp(escapeRegExp(find), 'gi'), replace);
}
function escapeRegExp(string) {
    return string.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
}

function getSysParam(parmname) {
    var res = "";
    var sql = "select parm_value from Custom_SysParams where 5340=5340 and parm_name='" + parmname + "'";
    var q = CRM.CreateQueryObj(sql);
    q.SelectSQL();
    if (!q.eof)
        res = q.FieldValue("parm_value");

    return res;
}

function contains(arr, element) {
    element = new String(element);
    element = element.toLowerCase();
    for (var i = 0; i < arr.length; i++) {
        var arrval = new String(arr[i]);
        arrval = arrval.toLowerCase();
        if (arrval == element) {
            return true;
        }
    }
    return false;
}
function undefinedToBlank(val) {
    if (val + "" == "undefined")
        return "";
    return val;
}

function getBranding(screenMetadata) {
    var brandingObject = {
        secondaryLogo: "",
        secondaryURL: ""
    }
    if (GetWebConfigValue("enableBranding") == "Y") {
        brandingObject = {
            secondaryLogo: GetWebConfigValue("secondaryLogo"),
            secondaryURL: GetWebConfigValue("secondaryURL")
        }
    }
    screenMetadata.branding = brandingObject;
    return screenMetadata;
}

function setDefaultTerritory(sEntity, CRMRecord) {
    if (sEntity.toLowerCase().indexOf("progress") > -1) return;
    var tblInfo = getTableInfo(sEntity);
    var companyId = CRMRecord(tblInfo.prefix.toLowerCase() + "_primarycompanyid")
    var personId = CRMRecord(tblInfo.prefix.toLowerCase() + "_primarypersonid");

    var territory = null;

	//5th Sept 23-without this its overwriting any screen value
	if (Defined(CRMRecord(tblInfo.prefix + "_secterr")) && (CRMRecord(tblInfo.prefix + "_secterr")!=null)&& (CRMRecord(tblInfo.prefix + "_secterr")!="")){
		return;//do nothing
	}

    if (Defined(companyId)) {
        var r = CRM.FindRecord("company", "1=1 and comp_companyid=" + companyId);
        territory = !r.eof ? r.item("comp_secterr") : null;
        Glog("setDefaultTerritory:company territory ?:" + territory);
    }

    if (Defined(personId) && territory == null) {
        var r = CRM.FindRecord("Person", "2=2 and pers_personid=" + personId);
        territory = !r.eof ? r.item("pers_secterr") : null;
        Glog("setDefaultTerritory:person territory ?:" + territory);
    }

    if (territory == null) {
        territory = CRM.GetContextInfo("User", "User_PrimaryTerritory");
        Glog("setDefaultTerritory:user territory ?:" + territory);
    }

    if (territory != null) {
        try {
            Glog("setDefaultTerritory: try set " + sEntity + " default territory  to " + territory);
            CRMRecord(tblInfo.prefix + "_secterr") = territory;
        } catch (ex) {
            Glog("setDefaultTerritory:Cannot set default territory:" + ex.message);
            //
        }
    }

    return territory;
}


function getAssignmentObject(dataObj, contextentity, contextentityid, withSave) {
    Glog("getAssignmentObject START");
    Glog("dataObj.entity:" + dataObj.entity.toLowerCase());

    if (withSave === undefined) withSave = false;
    var res = {
        companyid: null,
        personid: null,
        territory: null
    }
    contextentity = new String(contextentity);
    contextentity = contextentity.toLowerCase();

    Glog("contextentity:" + contextentity + "=contextentityid:" + contextentityid);


    if (dataObj.entity.toLowerCase() == "opportunity") {
        var qc = CRM.FindRecord("opportunity", "oppo_opportunityid=" + dataObj.entityid);
        if (!qc.eof) {
            res.companyid = qc.item("oppo_primarycompanyid");
            res.personid = qc.item("oppo_primarypersonid");

            if (Defined(res.companyid)) {
                var qcComp = CRM.FindRecord("company", "3=3 and comp_companyid=" + res.companyid);
                if (!qcComp.eof) {
                    res.territory = qcComp.item("comp_secterr");
                }
            } else if (Defined(res.personid)) {
                var qcPers = CRM.FindRecord("person", "7231=7231 and pers_personid=" + res.personid);
                if (!qcPers.eof) {
                    res.territory = qcPers.item("pers_secterr");
                }
            } else {
                res.territory = CRM.GetContextInfo("User", "User_PrimaryTerritory");
            }


            if (withSave && res.territory != null) {
                qc.oppo_secterr = res.territory
                qc.SaveChangesNoTLS();
            }
        }
    } else if ((dataObj.entity.toLowerCase() == "cases") || (dataObj.entity.toLowerCase() == "case")) {
        var qc = CRM.FindRecord("cases", "case_caseid=" + dataObj.entityid);
        if (!qc.eof) {
            res.companyid = qc.item("case_primarycompanyid");
            res.personid = qc.item("case_primarypersonid");
            if (res.companyid) {
                var qcComp = CRM.FindRecord("company", "4=4 and comp_companyid=" + res.companyid);
                if (!qcComp.eof) {
                    res.territory = qcComp.item("comp_secterr");
                }
            } else if (res.personid) {
                var qcPers = CRM.FindRecord("person", "7232=7232 and pers_personid=" + res.personid);
                if (!qcPers.eof) {
                    res.territory = qcPers.item("pers_secterr");
                }
            } else {
                res.territory = CRM.GetContextInfo("User", "User_PrimaryTerritory");
            }
            if (withSave && res.territory != null) {
                qc.case_secterr = res.territory
                qc.SaveChangesNoTLS();
            }
        }
    } else
        if (dataObj.entity.toLowerCase() == "person") {
            res.personid = dataObj.entityid;
            var qc = CRM.FindRecord("person", "7233=7233 and pers_personid=" + dataObj.entityid);
            if (!qc.eof) {
                res.companyid = qc.item("pers_companyid");
                res.territory = qc.item("pers_secterr");
            }
        } else if (dataObj.entity.toLowerCase() == "company") {
            var qc = CRM.FindRecord("company", "5=5 and comp_companyid=" + dataObj.entityid);
            if (!qc.eof) {
                res.personid = qc.item("comp_primarypersonid");
                res.territory = qc.item("comp_secterr");
            }
            res.companyid = dataObj.entityid;
        }
    if (contextentity == "person") {
        //get the company
        var qc = CRM.FindRecord("person", "7234=7234 and pers_personid=" + contextentityid);
        if (!qc.eof) {
            res.companyid = qc.item("pers_companyid");
            res.territory = qc.item("pers_secterr");
        }
        res.personid = contextentityid;
    } else if (contextentity == "company") {
        var qc = CRM.FindRecord("company", "6=6 and comp_companyid=" + contextentityid);
        if (!qc.eof) {
            res.personid = qc.item("comp_primarypersonid");
            res.territory = qc.item("comp_secterr");
        }
        res.companyid = contextentityid;
    } else {
        //its a custom Entity...11 June 25
        var tmpTable_gas = getTableInfo(contextentity);
        if (tmpTable_gas.PersonField) {
            var tmpTable_gas_qc = CRM.FindRecord(contextentity, "77834=77834 and " +
                tmpTable_gas.idfield + "=" + contextentityid);
            res = getAssignmentObject(dataObj, "person", tmpTable_gas_qc(tmpTable_gas.PersonField));
        } else if (tmpTable_gas.CompanyField) {
            var tmpTable_gas_qc2 = CRM.FindRecord(contextentity, "77834=77834 and " +
                tmpTable_gas.idfield + "=" + contextentityid);
            res = getAssignmentObject(dataObj, "company", tmpTable_gas_qc2(tmpTable_gas.CompanyField));
        }
    }
    Glog(JSON.stringify(res));
    Glog("getAssignmentObject END");
    return res;
}





function getCommContextField(entity) {
    return getEntityContextField("communication", entity);
}
function getEntityContextField(MainEntity, entity) {
    var res = "";
    var __entity = new String(entity);
    __entity = __entity.toLowerCase();
    if (__entity == "cases")
        __entity = "case";
    var sql = "select top 1 ColP_ColName from Custom_Edits where 556=556 and ColP_Entity='" + MainEntity + "' and  ColP_LookupFamily='" + __entity + "' order by colp_createddate";
    var q = CRM.CreateQueryObj(sql);
    q.SelectSQL();
    while (!q.eof) {
        res = q.FieldValue("ColP_ColName");
        q.NextRecord();
    }
    //now if there is missing metadata...usually lead is missing
    if (__entity == "lead")
        res = "comm_leadid";
    if ((__entity == "solution")||(__entity == "solutions"))
        res = "comm_solutionid";	
    return res;
}


//used to make sure our value is correct as CRM expects
function getCreateFieldValue(xfield) {
    Glog("getCreateFieldValue:" + JSON.stringify(xfield) + "=" + xfield.value);
    var res = null;
    if (xfield.componentType == "MyFormRemoteLookup") {
        if ((xfield.value) && (xfield.value.value) && (xfield.value.value.entityid))
            return xfield.value.value.entityid;
        else if (xfield.value)
            return xfield.value;
        else
            return null;
    } else
        if (xfield.componentType == "MyFormSelectMultiple") {
            var _multival = "";
            for (var tt = 0; tt < xfield.value.length; tt++) {
                if (_multival != "")
                    _multival += ",";
                _multival += xfield.value[tt].value;
            }
            return _multival;
        } else
            if (xfield.componentType == "MyFormSelect") {
                var _val = "";
                if ((typeof xfield.value) == "object") {
                    try {
                        _val = xfield.value.value;
                    } catch (e) {
                        _val = xfield.value;
                    }
                } else {
                    _val = xfield.value;
                }
                if (!Defined(_val))
                    _val = "";
                return _val;
            } else
                if (xfield.componentType == "MyFormCheckbox") {
                    var _val = "";
                    if (xfield.value)
                        _val = "Y";
                    return _val;
                } else
                    if ((xfield.componentType == "MyFormDate") || (xfield.componentType == "MyFormDateTime")) {
                        if ((xfield.value.date == "") || (xfield.value.date == null)) {
                            if ((xfield.value.date == "") || (xfield.value.date == null)) {
                                if ((typeof xfield.value) == "string") {
                                    xfield.value = { 'date': xfield.value };
                                } else {
                                    return "";
                                }
                            }
                        }
                        var datestr = new String(xfield.value.date);
                        var datestrarr = datestr.split("-");
                        if ((xfield.value.time == "") || (xfield.value.time == null)) {
                            res = new Date(datestrarr[0], datestrarr[1] - 1, datestrarr[2]);
                            res = res.getVarDate();
                        } else {
                            var timestr = new String(xfield.value.time);
                            var timestrarr = timestr.split(":");
                            res = new Date(datestrarr[0], datestrarr[1] - 1, datestrarr[2], timestrarr[0], timestrarr[1]);
                            res = res.getVarDate();
                        }
                    } else {
                        res = xfield.value;
                    }
    return res;
}

function getEntityDesc(entity, entityid) {
    Glog("getEntityDesc params:" + entity + "=" + entityid);
    entity = new String(entity);
    if (entity.toLowerCase() == "case")
        entity = "cases";
    var ti = getTableInfo(entity);

    var ssasql = "select " + ti.DescField + " from " + ti.searchView + " where 756=756 and " + ti.idfield + "=" + entityid;
    Glog("getEntityDesc=" + ssasql);

    var q1 = CRM.CreateQueryObj(ssasql);
    q1.SelectSQL();
    var res = "";
    var descfields = new String(ti.DescField);
    var descfieldsarr = descfields.split(",");
    for (var tt = 0; tt < descfieldsarr.length; tt++) {
        if (res != "")
            res += "-";
        res += q1.FieldValue(descfieldsarr[tt]);
    }
    return res;
}

//used for embedded images
function convertImageToBase64(filePath) {
    var inputStream = new ActiveXObject('ADODB.Stream');
    inputStream.Open();
    inputStream.Type = 1;  // adTypeBinary
    inputStream.LoadFromFile(filePath);
    var bytes = inputStream.Read();
    var dom = new ActiveXObject('Microsoft.XMLDOM');
    var elem = dom.createElement('tmp');
    elem.dataType = 'bin.base64';
    elem.nodeTypedValue = bytes;
    var ret = 'data:image/png;base64,' + elem.text.replace(/[^A-Z\d+=\/]/gi, '');
    return ret;
}

function isEmbeddedImage(imageName, TextToSearch) {
    var sTextToSearch = new String(TextToSearch);
    if (sTextToSearch.indexOf("src=\"" + imageName + "\"") != -1) {
        return true;
    }
    return false;
}

function getCompanyNameFlag() {
    var res = "" + GetWebConfigValue("companynameflag");
    if ((res == "null") || (res == null) || (res == "") ||(!Defined(res))) {
        res = "" + get_SERVER_NAME();
    }
    return res;
}

function getComponentType(ColP_EntryType) {
    var res = "MyFormInput";
    if (ColP_EntryType == "28") {
        //selection
        res = "MyFormSelectMultiple";
    } else
        if ((ColP_EntryType == "21") || (ColP_EntryType == "27")) {
            //selection
            //27=intelligent select in crm
            res = "MyFormSelect";
        } else if ((ColP_EntryType == "22") || (ColP_EntryType == "24")) {
            //user
            res = "MyFormSelect";
        } else if ((ColP_EntryType == "56") || (ColP_EntryType == "26") || (ColP_EntryType == "25")) {
            //ssa, ssa,productid
            res = "MyFormRemoteLookup";
        } else if (ColP_EntryType == "23") {
            //channel/team
            res = "MyFormSelect";
        } else if ((ColP_EntryType == "41")) {
            //datetime
            res = "MyFormDateTime";
        } else if ((ColP_EntryType == "42")) {
            //date only
            res = "MyFormDate";
        } else if (ColP_EntryType == "23") {
            //channel
            res = "MyFormSelect";
        } else if ((ColP_EntryType == "21") || (ColP_EntryType == "27")) {
            //select
            res = "MyFormSelect";
        } else if (ColP_EntryType == "13") {
            //website 
            res = "MyFormURL";
        } else if (ColP_EntryType == "46") {
            //phone area code 
            res = "MyFormInput";
        } else if ((ColP_EntryType == "32") || (ColP_EntryType == "57")) {
            //57=minutes...needs its own type in the vue app
            //numeric
            res = "MyFormNumber";
        } else if (ColP_EntryType == "12") {
            //email
            res = "MyFormEmail";
        } else if (ColP_EntryType == "44") {
            //case_reference for example
            res = "MyFormLabelOnly";
        } else if (ColP_EntryType == "59") {
            //currency id
            res = "MyFormSelect";
        } else if (ColP_EntryType == "53") {
            //territory
            res = "MyFormSelect";
        } else if (ColP_EntryType == "45") {
            //checkbox
            res = "MyFormCheckbox";
        } else if (ColP_EntryType == "31") {
            //number but also could be comp_companyid...
            res = "MyFormNumber";
        } else if (ColP_EntryType == "11") {
            //text area
            res = "MyFormTextArea";
        } else if (ColP_EntryType == "51") {
            //currency
            res = "MyFormCurrency";
        }
    return res;
}


function getCache(name) {
    if (_baseConfig.useCache===false)
        return null;
    if (Application("cache_" + name)) {
        var _cachedObjectStr = Application("cache_" + name);
        var _cachedObject = JSON.parse(_cachedObjectStr);
        var currentD = new Date();
        var cahedt = new Date(_cachedObject.cachedt);
        var milliseconds = currentD - cahedt;
        var minutes = milliseconds / (60000);
        if (minutes <= _baseConfig.cacheitemlifetime) {
            //			Response.Write("<br>"+name);
            return _cachedObject.data;
        }
    }
    return null;
}

//value is an object in string format
function setCache(name, value) {
    if (!_baseConfig.useCache)
        return null;
    var currentD = new Date();
    var _cacheObject = { cachedt: currentD.toString(), data: value };
    Application("cache_" + name) = JSON.stringify(_cacheObject);
}

function getSessionCache(name) {
    if (Session("cache_" + name)) {
		return Session("cache_" + name);
    }
    return null;
}

//value is an object in string format
function setSessionCache(name, value) {
    Session("cache_" + name) = value;
}


function addMinutes(date, minutes) {
    return new Date(date.getTime() + minutes * 60000);
}

function _formatMoneyVal(val) {
    if (!Defined(val)) {
        return "0";
    }
    if (val == 0)
        return val;
    val = +val; //convert to number
    val = val.toLocaleString();
    return val;
}

function helers_getBusCal() {
    var res = 8.5;//default
    var _sql = "select BCal_TotalWorkingHrs from vBusinessCalendar where 557=557 and BCal_Default=1";
    var _q = CRM.CreateQueryObj(_sql);
    _q.SelectSQL();
    if (!_q.eof) {
        res = new Number(_q.FieldValue("BCal_TotalWorkingHrs"));
    }
    return res;
}



function _formatDurationVal(val) {
    var x = helers_getBusCal();
    var _unit = x * 60;
    if (!Defined(val)) {
        return "0 " + CRM.GetTrans("TimePeriods", "Minutes");
    }
    if (val == 0)
        return "0 " + CRM.GetTrans("TimePeriods", "Minutes");
    val = +val; //convert to number
    val = val / _unit;
    var _decimalpart = val - Math.floor(val);
    var minutes = (_decimalpart) * _unit;
    var hours = minutes / 60;
    hours = Math.floor(hours);
    minutes = minutes - (hours * 60);
    minutes = Math.floor(minutes);
    var res = "";
    if (Math.floor(val) != 0) {
        res = Math.floor(val) + " " + CRM.GetTrans("TimePeriods", "Days") + " ";
    }
    if (hours != 0) {
        res += hours + " " + CRM.GetTrans("TimePeriods", "Hours") + " ";
    }
    if (minutes != 0) {
        res += minutes + " " + CRM.GetTrans("TimePeriods", "Minutes");
    }
    return res;
}

function getCalendarDate(valuedt) {
    var res = "";
    if (valuedt.getFullYear() == 1899) {
        return '';
    }
    res = valuedt.getFullYear() + "-" + padDate(valuedt.getMonth() + 1) + "-" + padDate(valuedt.getDate());
    res += " " + padDate(valuedt.getHours()) + ":" + padDate(valuedt.getMinutes());
    return res;
}


function updateEntityByFields(sEntity, nRecordId) {
    if (CurrentPortalCRMUser != null && isPortalRequest) {
        var tblInfo = getTableInfo(sEntity);
        var updateByQuery = "UPDATE TOP(1) " + sEntity + " SET " + tblInfo.prefix + "_createdby=" + CurrentPortalCRMUser.RecordId + "," + tblInfo.prefix + "_updatedby=" + CurrentPortalCRMUser.RecordId +
            " WHERE " + tblInfo.prefix + "_deleted IS NULL AND " + tblInfo.idfield + "=" + nRecordId;
        try {
            var updateByQueryObj = CRM.CreateQueryObj(updateByQuery);
            updateByQueryObj.ExecSql();
        } catch (ex) {
            Glog("ERROR updateEntityByFields:" + ex.message + ">>>" + updateByQuery);

        }
    }
}

function isNumeric(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

function removeslarhr(val) {
    if ((!Defined(val)) || (val == null))
        val = new String("");
    if (typeof val === "string") {
        val = replaceAll(val, "\r", "");
    }
    return val;
}

function getDifference(a, b) {
    try {
        if ((!Defined(a)) || (!Defined(b))) {
            return "";
        }
        b = new String(b);
        var diff = "";
        var baRR = b.split('');
        for (var i = 0; i < baRR.length; i++) {
            if (baRR[i] != a.charAt(i))
                diff += baRR[i];
        }
    } catch (e) {
        diff = e.message;
    }
    return diff;
}

function millisToMinutesAndSeconds(millis) {
    var minutes = Math.floor(millis / 60000);
    var seconds = ((millis % 60000) / 1000).toFixed(4);
    return minutes + ":" + (seconds < 10 ? '0' : '') + seconds;
}

var SQLDATEFORMAT = "";
function getSQLDate(dateObject) {
    if (SQLDATEFORMAT == "") {
        var _cdt = CRM.CreateQueryObj("select isdate('2022-11-19') as isdateformat");
        _cdt.selectSQL();
        if (_cdt.FieldValue("isdateformat") == "1") {
            SQLDATEFORMAT = "YYYY-MM-DD";
        } else {
            SQLDATEFORMAT = "YYYY-DD-MM";
        }
    }
    if (SQLDATEFORMAT == "YYYY-MM-DD") {
        return dateObject.getFullYear() + "-" + padDate(dateObject.getMonth() + 1) + "-" + padDate(dateObject.getDate());
    } else {
        return dateObject.getFullYear() + "-" + padDate(dateObject.getDate()) + "-" + padDate(dateObject.getMonth() + 1);
    }
}

function endsWith(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

function getUserObject(pfilter) {
    var res = {
        "user_fullname": "",
        "user_userid": "",
        "user_per_todo": ""
    };
    var userlookupsql = "select user_userid, user_fullname,User_Per_ToDo, " +
        "User_PrimaryChannelId, User_Department, User_Logon,RTRIM(User_LastName) as User_LastName, RTRIM(User_FirstName) as User_FirstName,RTRIM(user_emailaddress ) as user_emailaddress " +
        "from vusers " +
        "where 557=557 and user_logon is not null and User_Disabled is null " +
        pfilter +
        " order by user_fullname";
    var q = CRM.CreateQueryObj(userlookupsql);
	try{
    q.SelectSQL();
    while (!q.eof) {
        res.user_fullname = q.FieldValue("user_fullname");
        res.user_userid = q.FieldValue("user_userid");
        res.user_per_todo = q.FieldValue("User_Per_ToDo");
        res.user_primarychannelid = q.FieldValue("User_PrimaryChannelId");
        res.user_department = q.FieldValue("User_Department");
        res.user_logon = q.FieldValue("User_Logon");
        res.user_lastName = q.FieldValue("User_LastName");
        res.user_firstName = q.FieldValue("User_FirstName");
		res.user_emailaddress = q.FieldValue("user_emailaddress");

        q.NextRecord();
    }
	}catch(sqle){
		Response.Write(userlookupsql);
		Response.End();
	}
    return res;
}
function getUsersForCalendar(pfilter, per_todo) {
    var res = [];

    /*var userlookupsql = "select user_userid, user_fullname,User_Per_ToDo from vusers " +
		"where user_logon is not null and User_Disabled is null " +
		pfilter +
		"order by user_fullname";
    var q = CRM.CreateQueryObj(userlookupsql);
    q.SelectSQL();
    */

    var q = CRM.FindRecord("Users,vUsers", "558=558 and user_logon is not null and User_Disabled is null " + pfilter);
    q.OrderBy = "user_fullname";

    while (!q.eof) {
        var opt = {
            text: q.item("user_fullname"),
            value: q.item("user_userid")
        }
        res.push(opt);
        q.NextRecord();
    }

    if (per_todo == 3) { //if the logged on user can see All users
        res.push({
            text: CRM.GetTrans("ColNames", "Unassigned"),
            value: ""
        });
    }

    return res;
}

function validEmailAddress(value) {
    if ((value == null) || (value == ""))
        return false;
    var regexEmail = new RegExp(
        "\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*",
        "gi"
    );
    var _isEmail = value.match(regexEmail);
    if (_isEmail == null)
        return false
    else
        return true;
}

function removeArrayDuplicates(originalArray, prop1, prop2) {
    var newArray = [];
    var lookupObject = {};

    for (var i in originalArray) {
        lookupObject[originalArray[i][prop1].toLowerCase() + "_" + originalArray[i][prop2]] = originalArray[i];
    }

    for (i in lookupObject) {
        newArray.push(lookupObject[i]);
    }
    return newArray;
}
function removeArrayEmptyItems(originalArray) {
    var newArray = [];
    for (var i in originalArray) {
        if ((originalArray[i] != "") && (originalArray[i] != null))
            newArray.push(originalArray[i]);
    }
    return newArray;
}
function removeArrayItem(originalArray,_index) {
    var newArray = [];
    for (var i in originalArray) {
        if (i!=_index)
            newArray.push(originalArray[i]);
    }
    return newArray;
}

function getDefaultStatus(Capt_Family) {
    //added in and Capt_Code<>'Closed' as default CRM has this as the first item
    var sql = "select top 1 Capt_Code from Custom_Captions " +
        "where 7155=7155 and Capt_Family='"+Capt_Family+"' and Capt_FamilyType='Choices' and Capt_Code<>'Closed' order by Capt_Order";
    var q = CRM.CreateQueryObj(sql);
    q.SelectSQL();
    if (!q.eof) {
        return q.FieldValue("Capt_Code");
    }
    //fallback to cases
    sql = "select top 1 Capt_Code from Custom_Captions " +
        "where 7153=7153 and Capt_Family='Case_Status' and Capt_FamilyType='Choices' order by Capt_Order";
    var q2 = CRM.CreateQueryObj(sql);
    q2.SelectSQL();
    if (!q2.eof) {
        return q2.FieldValue("Capt_Code");
    }
    //last fall back
    return 'In Progress';
}

//---email already filed?
function checkMessage(entryid){
  var res={
	  "message":"",
	  "tableData":[]
	 };
  if (!Defined(entryid))
	  return res;
  entryid=escapeSQL(entryid);
  var sql="select comm_communicationid from communication where 80032=80032 "+
		"and comm_outlookEntryID='"+entryid+"' order by comm_createddate desc";
  qpsql=CRM.CreateQueryObj(sql);
  qpsql.SelectSQL();
  if (!qpsql.eof)
  {	
	res.message=CRM.GetTrans("OutlookPlugin","CRM_FILED");
  }
  while (!qpsql.eof)
  {
	var _td=globalSearch_Findrecord(qpsql.FieldValue("comm_communicationid"), "communication","","Communication", {matchconfidence:100,matchon:CRM.GetTrans("Accelerator","Filed")});//get this record
	res.tableData=res.tableData.concat(_td);
	qpsql.NextRecord();
  }  
  return res;
}

//---email already filed?
//limitMatchConfidenceValue allows us to limit to say 100% only
//values are 25, 50, 75, 100 and its >= the limitMatchConfidenceValue
function checkMessageFileTo(searchObject, subject){
	var res=[];
	var entryid=escapeSQL(searchObject.entryid);
	var subject="....BBB";//when subject is null we need a default
	if (searchObject.subject)
	{
		if (searchObject.subject.value)
			subject=escapeSQL(searchObject.subject.value);
		else
			subject=escapeSQL(searchObject.subject);
    }
	//unicode stuff!! makes sql not match...to do...need to remove this or cut where the first one is

	var subject2="";//cope now with an email thats a reply Re: Fw: etc
	var subcolonindex=subject.indexOf(": ");
	if (subcolonindex>0 && subcolonindex<4)
		subject2=subject.substring(subcolonindex+2);
	//get our search columns for smart tags
	var searchEntities_sql= "select Bord_Name,Bord_Caption, Bord_TableId from Custom_Tables where Bord_PrimaryTable='Y' "+
							"order by Bord_Caption";
	var q=CRM.CreateQueryObj(searchEntities_sql);
	q.SelectSQL();
	var searchEntities_temp=[];
	var searchEntities=[];
	var configSearchEntities=new String(GetWebConfigValue("SearchEntities"));
		if (isPortalRequest) {
			configSearchEntities = Defined(CurrentPortalCRMUser("acpu_searchentities")) ?  CurrentPortalCRMUser("acpu_searchentities") :  "";
		}
	configSearchEntities=configSearchEntities.toLowerCase();
	var configSearchEntities_arr=configSearchEntities.split(",");
	for(var xx=0;xx<configSearchEntities_arr.length;xx++)
	{
		if (configSearchEntities_arr[xx].toLowerCase()=="case")
		{
		  configSearchEntities_arr[xx]="cases";
		  break;
		}
	}
	while(!q.eof)
	{
	  var _permission=hasPermissionView(q.FieldValue("Bord_Name"));
	  if (_permission)
	  {
			var Bord_Name=new String(q.FieldValue("Bord_Name"));
			Bord_Name=Bord_Name.toLowerCase();
			_tmpobj={
				"name": Bord_Name,
				"caption": CRM.GetTrans("TabNames",q.FieldValue("Bord_Caption")),
				"order":q.FieldValue("Bord_TableId")
			}
			if (contains(configSearchEntities_arr,q.FieldValue("Bord_Name"))) //only add in entities that are in the config
			{
				searchEntities_temp.push(_tmpobj);
			}
	  }
	  q.NextRecord();
	}
	var comm_columns="";
	var comm_columnsArray=[];
	var comm_columncasesql=" ,CASE ";
	for(var yy=0;yy<searchEntities_temp.length;yy++)
	{
		//get table info
		var _tmptable=getTableInfo(searchEntities_temp[yy].name);
		if (_tmptable.communicationField!=""){
			comm_columns+=","+_tmptable.communicationField;
			comm_columnsArray.push(_tmptable.communicationField);
			if ((_tmptable.communicationField.toLowerCase()!="cmli_comm_personid") &&
				(_tmptable.communicationField.toLowerCase()!="cmli_comm_companyid"))
			comm_columncasesql+=" WHEN "+_tmptable.communicationField+" is not null THEN "+searchEntities_temp[yy].order;
		}
	}	
	comm_columncasesql+=" WHEN cmli_comm_personid is not null THEN 70 ";
	comm_columncasesql+=" WHEN cmli_comm_companyid is not null THEN 80 ";
	comm_columncasesql+=" END AS entityOrder,Comm_From, comm_subject	 ";
	//matchFlag tells us how the record was found
  var sql="select distinct top 5 comm_communicationid,'commid' as matchFlag,comm_updateddate,100 as matchconfidence"+comm_columns+comm_columncasesql+
			" ,'"+CRM.GetTrans("Accelerator","Filed")+"' as matchon from vcommunication where 800377=800377 "+
			"and comm_outlookEntryID='"+entryid+"'";//the exact email...if filed already it will match
		
	//NOTE WE USE NEW SQL BELOW!!
	if (false && GetWebConfigValue("useSmartTags")=="Y")
	{
		sql+=" union ";//magic tags code here...
		sql+="select distinct top 5 comm_communicationid,'magic' as matchFlag,comm_updateddate,755 as matchconfidence"+comm_columns+comm_columncasesql+
				" ,'"+CRM.GetTrans("ColNames","Subject")+"/"+CRM.GetTrans("GenCaptions","From")+"/"+CRM.GetTrans("GenCaptions","To")+"' as matchon "+
				" from vcommunication where 800376=800376 ";
		sql+="and ((CHARINDEX('"+subject+"', comm_subject) > 0 OR "+
			" comm_subject = LTRIM(SUBSTRING('"+subject+"', CHARINDEX(':', '"+subject+"') + 1, LEN('"+subject+"'))))"
			")";
		if (subject2!="")
		{
			sql+="OR (CHARINDEX('"+subject2+"', comm_subject) > 0)  ";
		}
		var __emailToUse="";
		if (searchObject.from)
			__emailToUse=searchObject.from.emailAddress;
		else
			__emailToUse=searchObject;
		//changed OR to AND -MR 27 Nov 24
		//sql+=") and (CHARINDEX('"+__emailToUse+"', Comm_From) > 0 or CHARINDEX('"+__emailToUse+"', Comm_TO) > 0)";
		sql+=") and (CHARINDEX('"+__emailToUse+"', Comm_From) > 0 AND CHARINDEX('"+__emailToUse+"', Comm_TO) > 0)";
		sql+="and comm_updateddate >getdate()-60";		//last 60 days?		

		//loose confidence here...
		sql+=" union ";//magic tags code here...
		sql+="select distinct top 5 comm_communicationid,'magic' as matchFlag,comm_updateddate,25 as matchconfidence"+comm_columns+comm_columncasesql+
				" ,'"+CRM.GetTrans("ColNames","Subject")+" ("+CRM.GetTrans("ColNames","Exact")+")' as matchon "+
				" from vcommunication where 800374=800374 ";
		sql+="and comm_subject = '"+subject+"'";
		if (subject2!="")
		{
			sql+="OR comm_subject='"+subject2+"' ";
		}
		var __emailToUse="";
		if (searchObject.from)
			__emailToUse=searchObject.from.emailAddress;
		else
			__emailToUse=searchObject;
		sql+="and comm_updateddate >getdate()-60 ";		//last 60 days?		
		
		//loose confidence here...removed the Comm_From and Comm_TO filters 
		sql+=" union ";//magic tags code here...
		sql+="select distinct top 5 comm_communicationid,'magic' as matchFlag,comm_updateddate,25 as matchconfidence"+comm_columns+comm_columncasesql+
			" ,'"+CRM.GetTrans("ColNames","Subject")+" ("+CRM.GetTrans("ColNames","Like")+")' as matchon "+
			" from vcommunication where 800374=800374 ";
		sql+="and ((CHARINDEX('"+subject+"', comm_subject) > 0 OR "+
			" comm_subject = LTRIM(SUBSTRING('"+subject+"', CHARINDEX(':', '"+subject+"') + 1, LEN('"+subject+"'))))"
			")";
		if (subject2!="")
		{
			sql+="OR (CHARINDEX('"+subject2+"', comm_subject) > 0)  ";
		}
		var __emailToUse="";
		if (searchObject.from)
			__emailToUse=searchObject.from.emailAddress;
		else
			__emailToUse=searchObject;
		sql+="and comm_updateddate >getdate()-60)";		//last 60 days?		
		
		//finally order the results
		sql+=" order by matchconfidence desc, entityOrder asc, comm_updateddate desc  ";	
	
		//dev line...
		//	Response.Write(sql);Response.End();
		//Response.Write(sql);Response.End();
		

	}
	
	if (GetWebConfigValue("useSmartTags")=="Y")
	{
		//testing..later remove above code as this seems quicker
		sql=getChatgptsql(entryid,subject, subject2,__emailToUse,__emailToUse,searchEntities_temp);		
		//Response.Write(sql);Response.End();
	}
	
  qpsql=CRM.CreateQueryObj(sql);
  qpsql.SelectSQL();
  var _cmlires=[];
  while (!qpsql.eof)
  {
	  for (var tt=0;tt<searchEntities_temp.length;tt++)
	  {
		  var _tmptable=getTableInfo(searchEntities_temp[tt].name);
		  if ((_tmptable.communicationField!="")&&(Defined(qpsql.FieldValue(_tmptable.communicationField))))
		  {
				var filedObj={
						"entity":_tmptable.name,
						"entityid":qpsql.FieldValue(_tmptable.communicationField),
						"entityOrder":qpsql.FieldValue("entityOrder"),
						"matchconfidence":qpsql.FieldValue("matchconfidence"),
						"matchon":qpsql.FieldValue("matchon")
				}	
				if (_tmptable.communicationField.indexOf("cmli_")==0)
				{
					if (_tmptable.communicationField.toLowerCase()=="cmli_comm_personid")
						_cmlires.unshift(filedObj);//make sure person is first in this array
					else
						_cmlires.push(filedObj);
				}
				else
					res.push(filedObj);
			  
		  }
	  }	  
	  //now join on _cmlires...we do this as other entities should be first and the obvious ones to tag
	  res = res.concat(_cmlires);
	  qpsql.NextRecord();
  }
  res=removeArrayDuplicates(res,"entity","entityid");
  
  //now add in entities created from this
  if (checkTableExists("ctEntityLinks"))
  {
	var _entSQLtag="select top 10 cten_entityname, cten_entityid, cten_title,100 as matchconfidence, "+
		" '"+CRM.GetTrans("GenCaptions","Created")+"' as matchon,"+
		"3 as entityOrder from ctEntityLinks where "+
				"cten_outlookEntryID='"+entryid+"' and cten_outlookEntryID is not null "+
				"order by cten_createddate asc";
	//Response.Write(_entSQLtag);Response.End();
	var qctEntityLinks=CRM.CreateQueryObj(_entSQLtag);
	qctEntityLinks.SelectSQL();
	if (qctEntityLinks.eof)
	{
		//fallback to subject search...needed where we have created an entity but not filed the email and click reply
		_entSQLtag="select top 5 cten_entityname, cten_entityid, cten_title,35 as matchconfidence, "+
			" '"+CRM.GetTrans("ColNames","Subject")+" ("+CRM.GetTrans("ColNames","Exact")+")' as matchon, "+
			"3 as entityOrder from ctEntityLinks where "+
			//	"( (CHARINDEX('"+subject+"', cten_outlooksubject) > 0)  "; //charindex gave bad results....
			" cten_outlooksubject= '"+subject+"' ";
		if (subject2!="")
			{
				_entSQLtag+="OR cten_outlooksubject='"+subject2+"' ";
			}				
			
		_entSQLtag+=" order by cten_createddate desc";//asc so they get added to the result correctly
		//Response.Write(_entSQLtag);Response.End();
		qctEntityLinks=CRM.CreateQueryObj(_entSQLtag);
		qctEntityLinks.SelectSQL();		
	}
	
	while (!qctEntityLinks.eof){
		var filedObj2={
						"entity":qctEntityLinks.FieldValue("cten_entityname"),
						"entityid":qctEntityLinks.FieldValue("cten_entityid"),
						"entityOrder":qctEntityLinks.FieldValue("entityOrder"),
						"matchconfidence":qctEntityLinks.FieldValue("matchconfidence"),
						"matchon":qctEntityLinks.FieldValue("matchon")
				}
		if(qctEntityLinks.FieldValue("matchconfidence")==100)
		{
			//Response.Write(qctEntityLinks.FieldValue("cten_entityname"));//Response.End();
			res.unshift(filedObj2);
		}
		else {
			res.push(filedObj2);
		}
		qctEntityLinks.NextRecord();
	}

	res=removeArrayDuplicates(res,"entity","entityid");
		//Response.Write(JSON.stringify(res));
  }  
  
  return res;
}


function getChatgptsql(pcomm_outlookEntryID,pcomm_subject,pcomm_subject2,pComm_From,pComm_TO,searchEntities){
	//to do...
	//note//need to get ids and not hard coded in Comm_ctProductSupportId for example!!
	var _customids="";
	var _customwhen="";
	
	////////////////////////////////////
	//get the searchEntities
	var searchEntities_sql= "select bord_tableid, Bord_Name,Bord_Caption from Custom_Tables where Bord_PrimaryTable='Y' "+
							"and bord_name not in ('address', 'communication','lead','leads','cases','case','opportunity','company','person') "+
							"order by Bord_Caption";
							
	var q=CRM.CreateQueryObj(searchEntities_sql);
	q.SelectSQL();
	var searchEntities=[];
	var configSearchEntities=new String(GetWebConfigValue("SearchEntities"));
	var configSearchEntities_arr=configSearchEntities.split(",");
	while(!q.eof)
	{
	  var _permission=hasPermissionView(q("Bord_Name"));
	  if (_permission)
	  {
		  var _tmpobj={
				"name": q.FieldValue("Bord_Name"),
				"id": q.FieldValue("bord_tableid")
		  }
		  if (contains(configSearchEntities_arr,q.FieldValue("Bord_Name"))) //only add in entities that are in the config
		  {
			searchEntities.push(_tmpobj);
		  }
	  }
	  q.NextRecord();
	}

	////////////////////////////////////
	for(var xx=0;xx<searchEntities.length;xx++)
	{
		var _tmpTable=getTableInfo(searchEntities[xx].name);
		if (_tmpTable.communicationField && _tmpTable.communicationField!="")
		{
			_customids+=" "+_tmpTable.communicationField+", ";
			_customwhen+=" WHEN "+_tmpTable.communicationField+" IS NOT NULL THEN "+searchEntities[xx].id+" ";
		}
	}	
	
	var sqlQuery = "WITH FilteredVComm AS (" +
           "    SELECT " +
           "        comm_communicationid," +
           "        comm_updateddate," +
           "        comm_caseid," +
           "        cmli_comm_companyid," +
           _customids+
           "        comm_leadid," +
           "        Comm_OpportunityId," +
           "        cmli_comm_personid," +
           "        Comm_From," +
           "        comm_subject, " +
           "        comm_outlookEntryID, " +
           "        Comm_TO	 " +
           "    FROM vcommunication " +
           "    WHERE comm_updateddate > GETDATE() - 60" +
           "), " +
           "EntityOrderCalc AS (" +
           "    SELECT *, " +
           "        CASE " +
           "            WHEN comm_caseid IS NOT NULL THEN 3 " +
           _customwhen +
           "            WHEN comm_leadid IS NOT NULL THEN 59 " +
           "            WHEN Comm_OpportunityId IS NOT NULL THEN 10 " +
           "            WHEN cmli_comm_personid IS NOT NULL THEN 70 " +
           "            WHEN cmli_comm_companyid IS NOT NULL THEN 80 " +
           "        END AS entityOrder " +
           "    FROM FilteredVComm " +
           "), " +
           "RankedMatches AS (" +
           "    SELECT DISTINCT TOP 5 " +
           "        comm_communicationid, " +
           "        'commid' AS matchFlag, " +
           "        99 AS matchconfidence, " +
		   " '"+CRM.GetTrans("GenCaptions","Created")+"' as matchon, "+
           "        entityOrder, " +
           "        Comm_From, " +
           "        comm_subject, " +
		   "        comm_outlookEntryID, " +
		   "        comm_TO, " +		   
           "        comm_updateddate, " +
           "        comm_caseid, " +
           "        cmli_comm_companyid, " +
		   _customids+
           "        comm_leadid, " +
           "        Comm_OpportunityId, " +
           "        cmli_comm_personid " +
           "    FROM EntityOrderCalc " +
           "    WHERE comm_outlookEntryID = '"+pcomm_outlookEntryID+"' " +
           "    UNION ALL " +
           "    SELECT DISTINCT TOP 5 " +
           "        comm_communicationid, " +
           "        'magic' AS matchFlag, " +
           "        75 AS matchconfidence, " +
		   " '"+CRM.GetTrans("ColNames","Subject")+"/"+CRM.GetTrans("GenCaptions","From")+"/"+CRM.GetTrans("GenCaptions","To")+"' as matchon, "+		   
           "        entityOrder, " +
           "        Comm_From, " +
           "        comm_subject, " +
		   "        comm_outlookEntryID, " +
		   "        comm_TO, " +			   
           "        comm_updateddate, " +
           "        comm_caseid, " +
           "        cmli_comm_companyid, " +
		   _customids+
           "        comm_leadid, " +
           "        Comm_OpportunityId, " +
           "        cmli_comm_personid " +
           "    FROM EntityOrderCalc " +
           "    WHERE " +
           "        (" +
           "            CHARINDEX('"+pcomm_subject+"', comm_subject) > 0 " +
           "            OR comm_subject = LTRIM(SUBSTRING('"+pcomm_subject+"', CHARINDEX(':', '"+pcomm_subject+"') + 1, LEN('"+pcomm_subject+"'))) " +
           "        ) " +
           "        OR CHARINDEX('"+pcomm_subject2+"', comm_subject) > 0 " +
           "        AND CHARINDEX('"+pComm_From+"', Comm_From) > 0 " +
           "        AND CHARINDEX('"+pComm_TO+"', Comm_TO) > 0 " +
           "    UNION ALL " +
           "    SELECT DISTINCT TOP 5 " +
           "        comm_communicationid, " +
           "        'magic' AS matchFlag, " +
           "        25 AS matchconfidence, " +
		   " '"+CRM.GetTrans("ColNames","Subject")+" ("+CRM.GetTrans("ColNames","Like")+")' as matchon, "+		   
           "        entityOrder, " +
           "        Comm_From, " +
           "        comm_subject, " +
		   "        comm_outlookEntryID, " +
		   "        comm_TO, " +			   
           "        comm_updateddate, " +
           "        comm_caseid, " +
           "        cmli_comm_companyid, " +
		   _customids+
           "        comm_leadid, " +
           "        Comm_OpportunityId, " +
           "        cmli_comm_personid " +
           "    FROM EntityOrderCalc " +
           "    WHERE comm_subject IN ('"+pcomm_subject+"', '"+pcomm_subject2+"') " +
           ") " +
           "SELECT * FROM RankedMatches;"
	
							//Response.Write(sqlQuery);
							//Response.End();
	return sqlQuery;
}

function getUserBaseCurrency() {
    var res = "";
    var sql = "select UPref_Value from vUserPrefs where UPref_UserId="+ getUserId()+" and UPref_Key='USet_Currency'";
    var q = CRM.CreateQueryObj(sql);
    q.SelectSQL();
    if (!q.eof)
        res = q.FieldValue("UPref_Value");
	else 
		res=getSysParam("BaseCurrency");

    return res;
}
function commHasLibraryEmailFile(commid)
{
	var res=false;
	var libsql="select top 1 libr_communicationid from vlibrary where Libr_FileName='email.html' and libr_communicationid="+commid;
	var qlib=CRM.CreateQueryObj(libsql);
	qlib.SelectSQL();
	if (!qlib.eof){
		res=true;
	}
	return res;
}
function getCommHasLibraryEmailFile(commid)
{
	if (commHasLibraryEmailFile(commid))
	{
		
	}
}
//used to parse email html to plain text
function stripHTML(html) {
    // Regular expression to match HTML tags
    var regexTag = /(<([^>]+)>)/ig;
    // Replace HTML tags with an empty string
    var plainText = html.replace(regexTag, "");

    // Replace &nbsp; with a space
    plainText = plainText.replace(/&nbsp;/gi, " ");

    // Replace multiple spaces with a single space
    plainText = plainText.replace(/\s\s+/g, ' ');

    // Preserve new line characters: convert <br> and <br/> to \n
    plainText = plainText.replace(/<br\s*\/?>/gi, "\n");

    return plainText;
}

function checkTableExists(tablename){
	var qq=CRM.CreateQueryObj("SELECT 1 as tblfound FROM sysobjects WHERE name = '"+tablename+"' AND xtype = 'U'");
	qq.SelectSQL();
	if (qq.eof)
	  return false;
	return true;
}


function get_SERVER_PORT() {
	var res=Request.ServerVariables("SERVER_PORT");
	var ProxyPort = GetWebConfigValue("ProxyPort");
    if (Defined(ProxyPort))
        res=ProxyPort;
    return res;
}
function get_SERVER_NAME() {
	var res=Request.ServerVariables("SERVER_NAME");
	var ServerName = GetWebConfigValue("ServerName");
    if (Defined(ServerName))
        res=ServerName;
    return res;
}
function get_SERVER_PROTOCOL() {
	var res="";
	var ServerName = GetWebConfigValue("ProxyProtocol");
    if (Defined(ServerName))
        res=ServerName;
    return res;
}

function getCRMProtocol() {
    var protocol = get_SERVER_PROTOCOL();
	if (!Defined(protocol) || protocol==null || protocol=="" || protocol.length<1)
	{
		if (Request.ServerVariables("HTTPS") == "off") {
			protocol = "http://"
		} else {
			protocol = "https://"
		}
	}
    return protocol;
}


function getQueryVal(_pdt)
{
	var dt=_pdt;
	var year = dt.getFullYear();
	var month = ('0' + (dt.getMonth() + 1)).slice(-2); // Month is zero-based
	var day = ('0' + dt.getDate()).slice(-2);
	var hours = ('0' + dt.getHours()).slice(-2);
	var minutes = ('0' + dt.getMinutes()).slice(-2);
	var formatted = year + '-' + month + '-' + day + ' '+hours+':'+minutes;
	return formatted;
}

function adjustDateForOffset(originalDate, offsetStr, adjust) {
	if (!originalDate)
		return originalDate;
	//offsetStr is in the format +06:30 for example
  offsetStr=new String(offsetStr);
  if (!adjust)
	adjust=1;
  // Parse the offset string (e.g., "-06:45" or "+02:30")
  var match = offsetStr.match(/^([+-])(\d{2}):(\d{2})$/);
  if (!match) {
    throw new Error("Invalid offset format. Use ±HH:MM format."+offsetStr);
  }

  var sign = match[1] === '-' ? -1 : 1;
  var hours = parseInt(match[2], 10);
  var minutes = parseInt(match[3], 10);

  // Calculate total offset in milliseconds
  sign=sign*adjust;
  var offsetMillis = sign * ((hours * 60 + minutes) * 60 * 1000);
  //Response.Write(hours+":"+minutes+"**"+sign+"^^");
//Response.Write("originalDate="+originalDate);
  // Create a new Date adjusted by the offset
  var adjustedDate = new Date(originalDate.getTime() + offsetMillis);
  //Response.Write("adjustedDate="+adjustedDate);
  return adjustedDate;
}

function adjustUserDateToServerDate(originalDate, userId) {
    //used when users enter data
    if (!Defined(userId))
        userId = CRM.GetContextInfo("user", "user_userid");
    var y = getUserDateOffsetAdjust(userId);
    var x = getSystemDateOffsetAdjust();

    originalDate.setMinutes(originalDate.getMinutes() + (y - x));

    return originalDate;
}
function adjustUserDate(originalDate, userId) {
    //from system db date..to user date

    if (!Defined(userId))
        userId = CRM.GetContextInfo("user", "user_userid");
    var x = getSystemDateOffsetAdjust();
    //Response.Write("==="+x);
    var y = getUserDateOffsetAdjust(userId);
    //Response.Write("==="+y);

    originalDate.setMinutes(originalDate.getMinutes() - (y - x));

    return originalDate;
}
function getSystemDateOffsetAdjust() {
    var res = 0;
    var rsUser = CRM.CreateQueryObj("select parm_value from Custom_SysParams where parm_name='ServerTimeZone'");
    rsUser.SelectSQL();
    if (!rsUser.eof) {
        res = rsUser("parm_value");
        var currentDateTime_Offset = getCurrentDateTime_Offset();
        res = subtractOffsets(currentDateTime_Offset, res);
    }
    return res;
}
function getUserDateOffsetAdjust(userId) {
    if (!Defined(userId))
        userId = CRM.GetContextInfo("user", "user_userid");

    var res = 0;
    var rsUser = CRM.CreateQueryObj("SELECT upref_value FROM vUserPrefs WHERE upref_key='NSet_TimezoneDelta' and upref_userid=" + userId);
    rsUser.SelectSQL();
    if (!rsUser.eof) {
        res = rsUser("upref_value");
        var currentDateTime_Offset = getCurrentDateTime_Offset();
        res = subtractOffsets(currentDateTime_Offset, res);
    }
    return res;
}

var G_CurrentDateTimeWithOffset = "";
function getCurrentDateTime_Offset() {
    if (G_CurrentDateTimeWithOffset != "")
        return G_CurrentDateTimeWithOffset;
    var _rsUser = CRM.CreateQueryObj("SELECT SYSDATETIMEOFFSET() AS CurrentDateTimeWithOffset");
    _rsUser.SelectSQL();
    if (!_rsUser.eof) {
        var CurrentDateTimeWithOffset = _rsUser("CurrentDateTimeWithOffset");
        G_CurrentDateTimeWithOffset = extractOffset(CurrentDateTimeWithOffset);
    }
    return G_CurrentDateTimeWithOffset;
}
function extractOffset(datetimeStr) {
    // Match the last space followed by + or - and digits like +02:00
    var match = datetimeStr.match(/([+-]\d{2}:\d{2})$/);
    if (match) {
        return match[1]; // "+02:00"
    }
    return null;
}
    
function parseOffsetToMinutes(offsetStr) {
    // Example input: "+02:00" or "-03:30"
    var sign = offsetStr.charAt(0) === "-" ? -1 : 1;
    var parts = offsetStr.substring(1).split(":"); // Remove sign and split
    var hours = parseInt(parts[0], 10);
    var minutes = parseInt(parts[1], 10);
    return sign * (hours * 60 + minutes);
}

function subtractOffsets(offset1, offset2) {
    var minutes1 = parseOffsetToMinutes(offset1);
    var minutes2 = parseOffsetToMinutes(offset2);
    return minutes1 - minutes2; // Result in minutes
}
function getOffsetFromDateString(dateStr) {
    //this is for daylight savings
    dateStr = new String(dateStr);
    var match = dateStr.match(/UTC([+-])(\d{2})(\d{2})/);
    if (!match) {
        throw new Error("Invalid date format or missing UTC offset." + dateStr);
    }

    var sign = match[1] === '-' ? -1 : 1;
    var hours = parseInt(match[2], 10);
    var minutes = parseInt(match[3], 10);

    var totalMinutes = sign * (hours * 60 + minutes);
    return totalMinutes; // Offset in minutes
}
function createDateFromParts(obj) {
    // Split the date and time parts
    var dateParts = obj.date.split("-");
    var timeParts = obj.time.split(":");

    var year = parseInt(dateParts[0], 10);
    var month = parseInt(dateParts[1], 10) - 1; // Month is 0-based in JS
    var day = parseInt(dateParts[2], 10);

    if (timeParts.length > 0) {
        var hours = parseInt(timeParts[0], 10);
        var minutes = parseInt(timeParts[1], 10);

        // Create and return the Date object
        return new Date(year, month, day, hours, minutes);
    } else {
        // Create and return the Date object
        return new Date(year, month, day);
    }
}
%>