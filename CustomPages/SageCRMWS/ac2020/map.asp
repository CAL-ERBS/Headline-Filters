<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<html>
<head>
<script>
var mapContainer=null;
var _timerx=1000;
var _mapquestkey='<%=GetWebConfigValue("MapQuestAPIKey")%>';

console.log("crmtogether.com Addresss Map Component in Accelerator/MobileX");

function addScriptTag(paramsStr){
	var script=document.createElement('script'); // pretty self explanatory
	script.src=paramsStr; // sets the scripts source to the specified url
	script.type="text/javascript";
	document.getElementsByTagName('head')[0].appendChild(script); // appends the tag to the head
}
function addStyle(path) {
	var head = document.getElementsByTagName("head")[0];         
	var cssNode = document.createElement('link');
	cssNode.type = 'text/css';
	cssNode.rel = 'stylesheet';
	cssNode.href = path;
	cssNode.media = 'screen';
	head.appendChild(cssNode);
}

function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
}

function replaceAll(str, find, replace) {
  return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
}
function waitLoad()
{
   <%
   var adid=new String(Request.Querystring("id"));
   if (adid.indexOf(",")>-1){
	 var _adidarr=adid.split(",");
	 adid=_adidarr[0];
   }
   adid=new Number(adid);
   if (!isNumeric(adid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Address ID found, Addr_AddressId is "+Request.Form('id'));
	  throw "No valid Address ID found";
	}
   var qaddress = CRM.FindRecord("acTempAddress", "965312=965312 and Addr_AddressId = '" + Request.Querystring("id")+"'");
   var _mapaddress=getMapAddress(qaddress);
   _mapaddress = _mapaddress.replace(/["%20"]/g, " ");
   %>
   var _address='<%=_mapaddress%>';
   
   console.log("_address:"+_address);
   if (_mapquestkey!="")
   {
		L.mapquest.key = _mapquestkey;
		var map = L.mapquest.map('map', {
		  center: [0, 0],
		  layers: L.mapquest.tileLayer('map'),
		  zoom: 14
		});
		L.mapquest.geocoding().geocode(_address);
   }
}

document.addEventListener('DOMContentLoaded', function() {
	var x=addScriptTag("https://api.mqcdn.com/sdk/mapquest-js/v1.3.2/mapquest.js");
	var y=addStyle("https://api.mqcdn.com/sdk/mapquest-js/v1.3.2/mapquest.css");
	setTimeout(waitLoad, _timerx);
}, false);


function pageY(elem) {
    return elem.offsetParent ? (elem.offsetTop + pageY(elem.offsetParent)) : elem.offsetTop;
}

</script>

</head>
<body>
<div id="map" name="map" style="width:100%;height:100%;"  >
<%

var xeditmapkeyurl=getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+CRM.Url("sagecrmws/ac2020/xmap.asp");	
				
 if (!Defined(GetWebConfigValue("MapQuestAPIKey"))|| (GetWebConfigValue("MapQuestAPIKey")==""))
   {
  %>
Adds a mapquest map to Accelerator/MobileX
<br>
Requires your own MapQuest API key. At the time of release there is a free plan available. 
<br>
see
<br>
<a target="NEW" href="https://developer.mapquest.com/">https://developer.mapquest.com/</a>
<br>
Then cick  <a href="<%=xeditmapkeyurl%>">here</a> to update
  <%
   }
   %>
</div>

</body>
</html>