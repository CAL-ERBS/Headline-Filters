<%
var webconfigtext = Application("webconfig");

var _Gfam = "_crmtconfig";
var KeyName = "nokeyset";
var KeyDescription = "no KeyDescription set";

function geturl(value) {
	var __res="";
	try {
		var xmlhttp;
		try {
			xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP.6.0");
		}
		catch (e) {
			try {
				xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP.4.0");
			}
			catch (e) {
				throw "object can't created";
			}
		}
		xmlhttp.open("GET", value, false);
		xmlhttp.send();
		__res=(xmlhttp.responseText);
		
	}	
	catch (e) {		
	  //ignore...might just be blocked
	}
    return __res;
}
function posturl(url, postdata) {
    //postdata is name=value&name2=value2 etc
    var xmlhttp;
    try {
        xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP.6.0");
    }
    catch (e) {
        try {
            xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP.4.0");
        }
        catch (e) {
            throw "object MSXML2.ServerXMLHTTP cannot be created";
        }
    }
    xmlhttp.open("POST", url, false);
    xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xmlhttp.send(postdata);
    return (xmlhttp.responseText);
}
function readallFile(path) {	
    var fso = new ActiveXObject("Scripting.FileSystemObject"),
        thefile = fso.OpenTextFile(path, 1, false);
    var res = thefile.ReadAll();
    thefile.Close();
    return res;
}

function ReadWebConfigValue() {
    if ((webconfigtext == "") || (webconfigtext == null)) {
        webconfigtext = readallFile(Server.MapPath("../web.config"));
        Application("webconfig") = webconfigtext;
    }
    return webconfigtext;
}
var oXML = null;
function GetWebConfigValue(KeyName) {
    var res = null;
	var _configsql="select capt_us from custom_captions where 9086=9086 and capt_code='" + KeyName + "' and capt_family='" + _Gfam + "' and capt_deleted is null";
	
    var _cachekey = "GetWebConfigValue_" + KeyName+"_"+_Gfam;
    var _cachedObj = getCache(_cachekey);
    if (_cachedObj != null) {
        return _cachedObj;
    }
	
    var _q = CRM.CreateQueryObj(_configsql);
    _q.SelectSQL();
    if (!_q.eof) {
        res = _q("capt_us");
    }
    if (_q.eof) {

        res = GetWebConfigValueOnly(KeyName);
        if (!Defined(res) || (res == null)) {
            res = '';
        }
        if (_q.eof) {
            //insert value so we have it next time
            var iq = CRM.CreateRecord("custom_captions");
            iq("capt_family") = _Gfam;
            iq("capt_code") = KeyName;
			iq("capt_familytype")="Tags";
            iq("capt_us") = res;
            iq.SaveChangesNoTLS();
        }
    }
	setCache(_cachekey, res);
    return res;
}
function GetWebConfigValueOnly(KeyName) {
    var res = null;
    if (Application("webconfig_" + KeyName)) {
        res = Application("webconfig_" + KeyName);
        return res;
    }
	if (oXML == null) {
        oXML = Server.CreateObject("MSXML2.DOMDocument.6.0");
        var xmltext = ReadWebConfigValue();
        oXML.loadXML(xmltext);
    }
    xmlDocRoot = oXML.selectSingleNode("configuration");
    //if you get an error here ..object required...the issue is probably that the web.confg files is saved in utf-8 format
    try {
        for (var i = 0; i < xmlDocRoot.childNodes.length; i++) {
            dataNode = xmlDocRoot.childNodes[i];
            if (dataNode.nodeName == "appSettings") {
                break;
            }
        }
    } catch (xmlerr) {
        //reset the cache
        Application.Contents.RemoveAll();
    }

    for (var j = 0; j < dataNode.childNodes.length; j++) {
        resNode = dataNode.childNodes[j];
        if (resNode.nodeName == "add") {
            if (resNode.getAttribute("key") == KeyName) {
                res = resNode.getAttribute("value");
            }
        }
    }
    oXML = null;
    Application("webconfig_" + KeyName) = res;
    return res;
}

%>