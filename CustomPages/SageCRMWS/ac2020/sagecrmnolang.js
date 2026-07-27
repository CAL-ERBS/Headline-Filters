<%
var GLOBAL_TIMESTART = new Date().getTime();
Response.Expires = -1;
//only turn on with an engineer and turn off when done!!!!
var GLOBAL_DEBUG_LOGGING = false;
var ACAPP = false;//to be used in scripts within Sage CRM for example so you can mix up classic and this new version
var log4User = "";//allows us log for only a given user..leave blank for all users..
var GlogUser = "";//this is set below

var CRM = {};
var CONTEXT_RECORD = null;
// Sage CRM mode constants

var View = 0, Edit = 1, Save = 2, PreDelete = 3, PostDelete = 4, Clear = 6;

// Sage CRM button position constants

var Bottom = 0, Left = 1, Right = 2, Top = 3;

// Sage CRM caption location constants

var CapDefault = 0, CapTop = 1, CapLeft = 2, CapLeftAligned = 3, CapRight = 4, CapRightAligned = 5, CapLeftAlignedRight = 6;

// determine is this is a wap page

var Accept = new String(Request.ServerVariables("HTTP_ACCEPT"));
var IsWap = (Accept.indexOf("wml") != -1);

var Button_Default = "1", Button_Delete = "2", Button_Continue = "4";

var iKey_CustomEntity = 58;

// create and initialise the Sage CRM object

var sInstallName = getInstallName(Request.ServerVariables("URL"));
var ClassName = "eWare." + sInstallName;

var http_protocol = "http://";
if (Request.ServerVariables("HTTPS") == "on") {
    http_protocol = "https://";
}
var _form = Request.Form;
var _qs = Request.Querystring;
var _HTTPS = Request.ServerVariables("HTTPS");
var _SERVER_NAME = Request.ServerVariables("SERVER_NAME");
var _HTTP_USER_AGENT = Request.ServerVariables("HTTP_USER_AGENT");
var isPortalRequest = Defined(Request.ServerVariables("HTTP_Authorization"));
if (Defined(Request.QueryString("token")))
    isPortalRequest = true;
var authToken = isPortalRequest ?
    Request.ServerVariables("HTTP_Authorization") : Request.QueryString("token");
if (!Defined(authToken))
    authToken = Request.QueryString("token");


var G_appMode="";//values are AC and MX...we send as "App-Mode" but here its shown as HTTP_APP_MODE
if (Defined(Request.ServerVariables("HTTP_APP_MODE"))){
	G_appMode=new String(Request.ServerVariables("HTTP_APP_MODE"));	
}
	
var G_appPlatform="";//needed to account for different behaviours in ios
if (Defined(Request.ServerVariables("HTTP_APP_CAPACITOR_PLATFORM"))){
	G_appPlatform=new String(Request.ServerVariables("HTTP_APP_CAPACITOR_PLATFORM"));
}



//parse all headers...useful if you are not sure of the value
var e = new Enumerator(Request.ServerVariables);
for (; !e.atEnd(); e.moveNext()) {
	var key = e.item();
	//Response.Write("///"+key+"==="+Request.ServerVariables(key));
}		
//from acplus send functions
if (!Defined(authToken))
    authToken = Request.ServerVariables("Authorization");

var CurrentPortalCRMUser = null;
var UserLanguage = "US";
var logFile = null;

//util for urls 
function isportalcode() {
    var res = "&";
    if (isPortalRequest)
        res = "?";
    return res;
}
var eMsg=null;
if (isPortalRequest) {


    if (authToken == null) {
        //Response.Status = 401;
        //Response.Write("");
        Response.End();
    }

    var crmUserId = validateToken(authToken);
    //var crmUserId=1;
    if (crmUserId === false) {
        //Response.Status = 401;
        Response.Write("\nInvalid Token or Session Expired\n");
        Response.Write(authToken);
        Response.End();
    }

    GlogUser = crmUserId + "Portal";

    eWare = Server.CreateObject("eWare.eWareSelfService");

    eMsg = eWare.Init(
        _qs,
        _form,
        Request.Cookies("eware"),
        true);

    if (eMsg != "") {
        Glog(eMsg);
        Response.Write(eMsg);
        //Response.StatusCode = 500;
        //Response.Status = eMsg;
        Response.End();
    }

    CurrentPortalCRMUser = eWare.FindRecord("Users,vAcceleratorPortalCRMUsers", "user_userid=" + crmUserId);

    UserLanguage = Defined(CurrentPortalCRMUser("user_language")) ? CurrentPortalCRMUser("user_language") : "US";

    //override missing self service eWare functions 
    CRM.CreateRecord = function (sEntity) {
        return eWare.CreateRecord(sEntity);
    }

    CRM.FindRecord = CRM.Findrecord = function (table, whereclause) {
        return eWare.FindRecord(table, whereclause)
    }

    CRM.GetContextInfo = function (table, field) {
        if (table == "user" && CurrentPortalCRMUser != null) {
            return CurrentPortalCRMUser(field);
        } else {
            if (Defined(Request.Form("screenMetadata_entityid"))) {
                var _table = getTableInfo(table);
                var recordId = Request.Form("screenMetadata_entityid");
                var record = eWare.FindRecord(table, "7180=7180 and " + _table.idfield + "=" + recordId);
                return !record.eof ? record(field) : "";
            }
        }
    }

    CRM.GetBlock = CRM.GetBlock = function (blockname) {
        return eWare.GetBlock(blockname);
    }

    CRM.ExecSql = CRM.ExecSQL = function (sql) {
        var queryExec = eWare.CreateQueryObj(sql);
        return queryExec.ExecSql();
    }

    CRM.CreateQueryObj = function (sql) {
        return eWare.CreateQueryObj(sql);
    }


    CRM.Button = function (entity0, s1, s2, entity, sPermissionType) {
        var _entityToCheck = entity.trim().toLowerCase();

        var userSearchEntities = Defined(CurrentPortalCRMUser("acpu_searchentities")) ? CurrentPortalCRMUser("acpu_searchentities").toLowerCase().split(",") : "";
        var userNewEntities = Defined(CurrentPortalCRMUser("acpu_newentities")) ? CurrentPortalCRMUser("acpu_newentities").toLowerCase().split(",") : "";

        var sReturn = "false";

        if (_entityToCheck == "cases")
            _entityToCheck = "case";
        else if (_entityToCheck == "quote")
            _entityToCheck = "quotes";
        else if (_entityToCheck == "opportunities")
            _entityToCheck = "opportunity";


        switch (sPermissionType) {
            case "VIEW":
                Glog("Check Portal user has  " + sPermissionType + " permisions for entity '" + _entityToCheck + "' in Search Entities" + userSearchEntities);
                sReturn = arrayIncludes(userSearchEntities, _entityToCheck);
                break;
            case "INSERT":
                Glog("Check Portal user has  " + sPermissionType + " permisions for entity '" + _entityToCheck + " in New Entities " + userSearchEntities);
                if (_entityToCheck == "communication")
                    sReturn = "true"; //alow this so logfile and logcall buttons are enabled by default for portal connections
                else
                    sReturn = arrayIncludes(userNewEntities, _entityToCheck);
                break;
            case "EDIT":
                sReturn = "false";
                break;
            case "DELETE":
                sReturn = "false";
                break;
            default:
                sReturn = "false";
                break;
        }

        Glog("permision result: " + sReturn);
        return sReturn;
    }



    CRM.Url = CRM.url = function (sActionUrl) {
        var action = parseInt(sActionUrl);
        Glog("CRM.url action:" + sActionUrl + "isNaN" + isNaN(action));
        if (!isNaN(action)) return false; //for crm action of type numbers(e.g. 200)  return false  
        return "/" + sInstallName + "/CustomPages/" + sActionUrl; //TODO
    }

    CRM.GetTrans = function (family, code) {
        var captRecord = eWare.FindRecord("custom_captions", "2277=2277 and capt_family='" + family + "' AND capt_code='" + code + "'");
        if (!captRecord.Eof) {
            return captRecord("capt_" + UserLanguage);
        }
        return code;
    }
    // end override 



} else {
    CRM = eWare = Server.CreateObject(ClassName);
    eWare.Host = "DPP";
	try{
		eMsg = eWare.Init(
			_qs,
			_form,
			_HTTPS,
			_SERVER_NAME,
			true,
			_HTTP_USER_AGENT,
			Accept);
	}
	catch(initException){
		var SessionErr={
			"DeadSession":true,
			"CRMException":initException.message,
			"eMsg":eMsg,
			"Message":"Session Expired"
		}
		Response.Status="500 Expired Session";
		Response.Write(JSON.stringify(SessionErr));
		//throw JSON.stringify(SessionErr);
        Response.End();
	}
	//we do not always get an exception...sometimes we get just a html logon page
	if ((eMsg!=null) && (eMsg.indexOf("<html>")==0))
	{
		var SessionErr={
			"DeadSession":true,
			"CRMException":"Logon Page Shown",
			"eMsg":"not showing as html page returned",
			"Message":"No Session Found"
		}
		Response.Status="500 Expired Session";
		Response.Write(JSON.stringify(SessionErr));
		//throw JSON.stringify(SessionErr);
        Response.End();
	}

}


// check for errors	
if (eMsg != "") {
    //Response.Write(eMsg);
    Glog("401 Unauthorized");
    //Response.Status="401 Unauthorized";
    Response.Status = "500 Error";
    //Response.End;
}

//GlogUser=CRM.GetContextInfo("user","user_userid");	
// this function is quite useful	
function Defined(Arg) {
    return (Arg + "" != "undefined");
}

function getInstallName(sPath) {
    //Parse the install name out of the path
    var Path = new String(sPath);
    var InstallName = '';
    var iEndChar = 0; iStartChar = 0;

    Path = Path.toLowerCase();
    iEndChar = Path.indexOf('/custompages');
    if (iEndChar != -1) {
        //find the first '/' before this
        iStartChar = Path.substr(0, iEndChar).lastIndexOf('/');
        iStartChar++
        InstallName = Path.substring(iStartChar, iEndChar);
    }
    return InstallName;

}

function getSiteRootUrl() {
    var siteRootUrl, protocol, hostname, port

    if (Request.ServerVariables("HTTPS") == "off")
        protocol = "http"
    else
        protocol = "https"


    siteRootUrl = protocol + "://"

    hostname = Request.ServerVariables("HTTP_HOST")
    siteRootUrl = siteRootUrl + hostname

    port = Request.ServerVariables("SERVER_PORT") 
    if (port != 80 && port != 443) {
        siteRootUrl = siteRootUrl + ":" + port
    }

    return siteRootUrl;
}

function validateToken(authToken) {
    var validateTokenUrl = getSiteRootUrl() + "/" + sInstallName + "/custompages/sagecrmws/ValidateToken.aspx";
    var xmlhttp;
    var status = false;

    try {
        xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP.6.0");
    }
    catch (e) {
        try {
            xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP.4.0");
        }
        catch (e) {
            return false;
            //throw "object MSXML2.ServerXMLHTTP cannot be created";
        }
    }
    xmlhttp.open("GET", validateTokenUrl, false);
    xmlhttp.setRequestHeader("Authorization", authToken);
    xmlhttp.send();

    if (xmlhttp.status != 200) {
        Glog("401 Unauthorized");
        Response.Status = xmlhttp.status;
        Response.Write(xmlhttp.status);
        Response.Write(validateTokenUrl);
        return false;
    } else {
        status = true;
        //var responseObject = JSON.parse();
        return xmlhttp.responseText;

    }

    return status;
}


function Glog(msg) {
    if (GLOBAL_DEBUG_LOGGING) {
        if ((log4User == "") || (log4User == GlogUser)) {
            var fsopath = Server.MapPath(".");
            var fso = new ActiveXObject("Scripting.FileSystemObject");
            //check logs folder exists 
            if (!fso.FolderExists(fsopath + "\\logs")) {
                fso.CreateFolder(fsopath + "\\logs");
            }

            try {
                var logFile = fso.OpenTextFile(fsopath + "\\logs\\GLOBAL_DEBUG_LOG_user_" + GlogUser + ".txt", 8, true, -1);
                logFile.WriteLine(msg);
                logFile.Close();
                logFile = null;
            } catch (e) {
                //nothing
            }
        }
    }
}

function SendError(methodName, entity, message) {
    var resValidation = {
        "screenMetadata": {
            "page": "createEntity",
            "entity": entity,
            "action": "ValidationError"
        },
        "data": {
            serverValidationMessage: message
        }
    }
    Glog(methodName + "ERROR:" + message);

    Response.Clear();
    Response.Write(JSON.stringify(resValidation));
    Response.End();
}

String.prototype.trim = function () {
    return this.replace(/^\s+|\s+$/g, "");
}

function arrayIncludes(arr, term) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] == term)
            return true;
    }
    return false;
}
//sql injection functions
//1. logging to crm
function LogtoCRMsLogs(msg){
  try{
	   CRM.CreateQueryObj('/* CRMTogether Log Item for user ('+CRM.GetContextInfo('user','user_logon')+') : '+msg+' */').SelectSql();
  }catch(e){}
}
//2. test the column name
function ValidDBColumn(colname){
	var res=false;
    var _cachekey = "ValidDBColumn_" + colname;
    var _cachedObj = getCache(_cachekey);
    if (_cachedObj != null) {
        return _cachedObj;
    }
    var q1=queryCustomEdits(colname);
	
	if (!q1.eof) {
        res = true;
        setCache(_cachekey, res);
    }
	return res;
}

function containsRestrictedKeywords(inputString) {
    try {
        var testString = new String(inputString);
        if (!Defined(inputString))
            return false;

        if (typeof inputString !== "string")
            return false;

        if (typeof inputString !== "string")
            testString = inputString.toString();//too many alerts with this
        var testresult = testSQLInjection(inputString);
        if (testresult.length > 0) {
            sendSQLEmailMessage("WARNING: SQL Keywords(" + testresult.length + ") Detected in Sage CRM from user '" + CRM.GetContextinfo("user", "user_logon") + "'"
                , "A SQL keyword '" + testresult.toString() + "' was detected in the following text:" + testString);

            return true;
        }
    } catch (mailerror) {

    }

    // If no match is found, return false
    return false;
}

function testSQLInjection(str) {
	str=new String(str);
    // List of common SQL injection patterns
	var res=[];
    var sqlInjectionPatterns = [
        /(\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE){0,1}|INSERT( +INTO){0,1}|MERGE|SELECT)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*)/ig,
        /(\b(UNION( +ALL){0,1}|JOIN|FROM|WHERE)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*)/ig,
        /(\b(AND|OR)( +\d+\.\d+){0,1}( += +\d+\.\d+){0,1}\b(?:\/\*.*?\*\/|\*|\n|\r|$)*)/ig,
        /(\b(BETWEEN +\d+ +AND +\d+)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*)/ig,
        /(\b(ORDER +BY|GROUP +BY|HAVING|LIMIT)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*)/ig,
        /(\b(--|\/\*|\*\/)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*)/g,
        /@@version/ig, // MS SQL Server version keyword
		/sysobjects/ig, /DBCC/ig, /information_schema/ig, /WAITFOR/ig,/sp_password/ig,
		/syscolumns/ig, /sysprocesses/ig, /bulk insert/ig, 
		/sp_configure/ig, /xp_cmdshell/ig, /RECONFIGURE/ig, /LIMIT/ig, /COLLATE/ig, /bcp/ig,	
		/sysmessages/ig,/sysservers/ig,/sysxlogins/ig,/sql_logins/ig,/xp_regread/ig,
		/table/ig, /OPENROWSET/ig,  /shutdown/ig,  /xtype/ig, 
        /\b(SELECT.*FROM.*INFORMATION_SCHEMA\..*)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*/ig, // Detect queries involving INFORMATION_SCHEMA
        /\b(SELECT.*FROM.*sys\..*)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*/ig, // Detect queries involving sys schema
        /\b(INSERT +INTO +sys\..*)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*/ig, // Detect potential attempts to insert into sys tables
        /\b(UPDATE +sys\..*)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*/ig, // Detect potential attempts to update sys tables
        /\b(DELETE +FROM +sys\..*)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*/ig, // Detect potential attempts to delete from sys tables
        /\b(SYSTEM_USER|USER_NAME|CURRENT_USER|SESSION_USER|USER_ID|SUSER_SNAME)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*/ig, // Detect Transact-SQL user-related functions
        /\b(IS_SRVROLEMEMBER|ORIGINAL_LOGIN|HOST_NAME|@@SERVERNAME)\b(?:\/\*.*?\*\/|\*|\n|\r|$)*/ig // Detect Transact-SQL server-related functions
    ];

    // Check if the input string matches any SQL injection pattern
    for (var i = 0; i < sqlInjectionPatterns.length; i++) {
        var patternMatches = str.match(sqlInjectionPatterns[i]);
        if (patternMatches) {
			for (var j = 0; j < patternMatches.length; j++) {
				var match = patternMatches[j];
				var isUnique = true;
                // Manual check for uniqueness
                for (var k = 0; k < res.length; k++) {
                    if (res[k].toLowerCase() === match.toLowerCase()) {
                        isUnique = false;
                        break;
                    }
                }
                if (isUnique) {
                    res.push(match);
                }
            }		
		}
    }

    return res;
}	
function sendSQLEmailMessage(pSubject, pBody){
	//check is there an email to send security issues to 
	return;//took out as too many messages
	var _configsql="9033=9033 and capt_code='SQLIAlertEmail' and capt_family='_crmtconfig' and capt_deleted is null";
	var _configValueQ=CRM.FindRecord("custom_captions",_configsql)	
	if (_configValueQ.eof)
	{
		return;//we do nothing
	}
	var _emailaddress=new String(_configValueQ("capt_us"));
	
	if ((_emailaddress==null)||(_emailaddress=="")||(_emailaddress.indexOf("@")==-1))
		return;//no valid email so lets get out of here
	
	var myMailObject = CRM.GetBlock("messageblock");
	with (myMailObject)
	{
	  DisplayForm = false;
	  mSubject = pSubject;
	  mBody = pBody;
	  mShowCC = true;
	  mShowBCC = true;
	  //TO|CC|BCC are valid recipients
	  AddRecipient(_emailaddress,"Sage CRM Admin","TO");
	  Mode=2;
	  Execute();
	  if (mSentOK)
	  {
		LogtoCRMsLogs("sendAdminEmailMessage: "+pSubject);
	  }
	  else
	  {
		LogtoCRMsLogs("sendAdminEmailMessage FAILED: "+mErrorMessage);
	  }
	}
}
%>