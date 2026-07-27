<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="workflow.js" -->
<%
Glog("getScreenSetup START");

function compareVersion(v1, v2) {
    if (typeof v1 !== 'string') return false;
    if (typeof v2 !== 'string') return false;
    v1 = v1.split('.');
    v2 = v2.split('.');
    var k = Math.min(v1.length, v2.length);
    for (var i = 0; i < k; ++ i) {
        v1[i] = parseInt(v1[i], 10);
        v2[i] = parseInt(v2[i], 10);
        if (v1[i] > v2[i]) return 1;
        if (v1[i] < v2[i]) return -1;        
    }
    return v1.length == v2.length ? 0: (v1.length < v2.length ? -1 : 1);
}

var _appversioninfo=JSON.parse(readallFile(Server.MapPath("version.json")));


////////////////////////////patch for first release issue//////
if (isPortalRequest) {
  var patchSQL="update AcceleratorPortalUsers set acpu_deleted=1 where acpu_username is null";
  CRM.ExecSQL(patchSQL);
}
////////////////////////////////////
////////////////////////////////////
//get the searchEntities
//5.3 now has address, documents and communication
//var searchEntities_sql= "select Bord_Name,Bord_Caption from Custom_Tables where Bord_PrimaryTable='Y' "+
	//					"and bord_name not in ('address','communication') order by Bord_Caption";
var searchEntities_sql= "select Bord_Name,Bord_Caption from Custom_Tables where Bord_PrimaryTable='Y' "+
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
  var _permission=hasPermissionView(q("Bord_Name"));
  if (_permission)
  {
		var Bord_Name=new String(q("Bord_Name"));
		Bord_Name=Bord_Name.toLowerCase();
		_tmpobj={
			"name": Bord_Name,
			"caption": CRM.GetTrans("TabNames",q("Bord_Caption")),
			"color":getTileColour(q("Bord_Name")),
			"icon":getTileIcon(q("Bord_Name"))
		}

		if (contains(configSearchEntities_arr,q("Bord_Name"))) //only add in entities that are in the config
		{
				//Response.Write("_permission:"+q("Bord_Name")+"::"+_permission);
			searchEntities_temp.push(_tmpobj);
		}
  }
  q.NextRecord();
}

var searchHasQuickSearchEnabled=false;
//fix up the order so its like our config
for(var xx=0;xx<configSearchEntities_arr.length;xx++)
{
	for(var yy=0;yy<searchEntities_temp.length;yy++)
	{
		if (searchEntities_temp[yy].name==configSearchEntities_arr[xx])
		{
		  searchEntities.push(searchEntities_temp[yy]);
		}
	}
	if ((configSearchEntities_arr[xx].toLowerCase()=="quicksearch")&& (!searchHasQuickSearchEnabled)){
		//searchHasQuickSearchEnabled=true;//removed for now as CORS issues
	}
	if ((configSearchEntities_arr[xx].toLowerCase()=="address")){
		searchEntities.push({
			"name": configSearchEntities_arr[xx],
			"caption": CRM.GetTrans("TabNames",	configSearchEntities_arr[xx].toLowerCase()),
			"color":getTileColour("address"),
			"icon":getTileIcon("address")
		});
	}	
	if ((configSearchEntities_arr[xx].toLowerCase()=="phone")){
		searchEntities.push({
			"name": configSearchEntities_arr[xx],
			"caption": CRM.GetTrans("TabNames",	configSearchEntities_arr[xx].toLowerCase()),
			"color":getTileColour("phone"),
			"icon":getTileIcon("phone")
		});
	}	
	if ((configSearchEntities_arr[xx].toLowerCase()=="email")){
		searchEntities.push({
			"name": configSearchEntities_arr[xx],
			"caption": CRM.GetTrans("TabNames",	configSearchEntities_arr[xx].toLowerCase()),
			"color":getTileColour("email"),
			"icon":getTileIcon("email")
		});
	}		
	
}
if (searchEntities.length==0)
{
	//bug in crm...locked down users profiles cause the issue
	for(var xx=0;xx<configSearchEntities_arr.length;xx++)
	{
		searchEntities.push(configSearchEntities_arr[xx]);
	}
}

////////////////////////////////////
//get the newEntities
var newEntities_sql= "select Bord_Name,Bord_Caption from Custom_Tables where Bord_PrimaryTable='Y' "+
					"and bord_name not in ('address', 'quotes','orders','solutions','communication','library') order by Bord_Caption";
var q2=CRM.CreateQueryObj(newEntities_sql);
q2.SelectSQL();
var newEntities_temp=[];
var newEntities=[];
var configNewEntities=new String(GetWebConfigValue("NewEntities"));
	if (isPortalRequest) {
		configNewEntities = Defined(CurrentPortalCRMUser("acpu_newentities")) ?  CurrentPortalCRMUser("acpu_newentities") : "";
	}

var configNewEntities_arr=configNewEntities.split(",");
//fix up cases/case or ac plus
for(var xx=0;xx<configNewEntities_arr.length;xx++)
{
	if (configNewEntities_arr[xx].toLowerCase()=="case")
	{
	  configNewEntities_arr[xx]="cases";
	  break;
	}
}
while(!q2.eof)
{
  var _permission=hasPermissionInsert(q2("Bord_Name"));
  if (_permission)
  {
	  _tmpobj={
			"name": q2("Bord_Name"),
			"caption": CRM.GetTrans("TabNames",q2("Bord_Caption")),
			"color":getTileColour(q2("Bord_Name")),
			"icon":getTileIcon(q2("Bord_Name")),
			enabled:true
	  }
	  if (contains(configNewEntities_arr,q2("Bord_Name"))) //only add in entities that are in the config
	  {	  
		newEntities_temp.push(_tmpobj);
	  }
  }
  q2.NextRecord();
}
//individual check
if (contains(configNewEntities_arr,"Individual"))
{	  
  var _tmpobjin={
		"name": "Individual",
		"caption": CRM.GetTrans("TabNames","Individual"),
		"color":getTileColour("Individual"),
		"icon":getTileIcon("Individual"),
		enabled:true
  }
  newEntities_temp.push(_tmpobjin);
}

//fix up the order so its like our config
for(var xx=0;xx<configNewEntities_arr.length;xx++)
{
	for(var yy=0;yy<newEntities_temp.length;yy++)
	{
		if (newEntities_temp[yy].name.toLowerCase()==configNewEntities_arr[xx].toLowerCase())
		{
		  newEntities.push(newEntities_temp[yy]);
		}
	}
}
if (newEntities.length==0)
{
	//bug in crm...locked down users profiles cause the issue
	for(var xx=0;xx<configNewEntities_arr.length;xx++)
	{
		newEntities.push(configNewEntities_arr[xx]);
	}
}
function arrayIndexOfEntities(tablename, arraytouse){
	var res=-1;
	for(var xx=0;xx<arraytouse.length;xx++)
	{
		if (tablename.toLowerCase()==arraytouse[xx].name.toLowerCase()){
			res=xx;
			break;
		}
	}	
	return res;
}
//workflow22 work--
var newEntities22=JSON.stringify(newEntities);
newEntities22=JSON.parse(newEntities22);
for(var xx=0;xx<newEntities.length;xx++)
{
	var _primaryrules=getWorkflowPrimaryRules22(newEntities[xx].name);
	if (_primaryrules.length>0)
	{
		//copy what we need
		var __color=newEntities[xx].color;
		var __icon=newEntities[xx].icon;
		//remove the default from our new array
		//	newEntities22.splice(xx,1);
		//add in the rules		
		for(var yy=0;yy<_primaryrules.length;yy++){
			var _tmpobj={
				"name": _primaryrules[yy].tablename+"_",
				"caption": _primaryrules[yy].caption,
				"color": __color,
				"icon": __icon,
				enabled:true
			}
			
			//insert in primary rule
			newEntities22.splice(xx+yy,0,_tmpobj);
		}		
		var _indexToRemove=arrayIndexOfEntities(newEntities[xx].name,newEntities22);
		newEntities22.splice(_indexToRemove,1);
	}
}

	//get ACNewMenuExt items
	var ACNewMenuExt = CRM.FindRecord("Custom_Tabs","tabs_entity ='ACNewMenuExt' AND tabs_wheresql IS NOT NULL");
	ACNewMenuExt.OrderBy = "Tabs_Order ASC";
	while (!ACNewMenuExt.eof) {
		var color = "green";
		var icon  = "mdi-new-box";		
		var tabs_wheresql = ACNewMenuExt("tabs_wheresql").split("#"); //LegalCaseScreen#Legal Case#New Case#cases#red#mdi-cash-multiple
		var entity = tabs_wheresql[3]; //TODO check if this is truly an entity ? 
		color = tabs_wheresql[4];
		icon = tabs_wheresql[5];
		newEntities.push({
			"name": ACNewMenuExt("Tabs_Caption"),
			"caption": ACNewMenuExt("Tabs_Caption"),
			"color": color,
			"icon": icon,
			enabled:true
		});

		ACNewMenuExt.NextRecord();
	}


////////////////////////////////////	

var defaultSearchEntity=GetWebConfigValue("SearchEntityDefault");
var NewEntityDefault=GetWebConfigValue("NewEntityDefault");
if ((NewEntityDefault==null)||(NewEntityDefault==""))
{
	NewEntityDefault="Company";
}											 
if (isPortalRequest) {
	defaultSearchEntity=Defined(CurrentPortalCRMUser("acpu_defaultsearchentity")) ? CurrentPortalCRMUser("acpu_defaultsearchentity") : "";
	NewEntityDefault=Defined(CurrentPortalCRMUser("acpu_newentitydefault")) ? CurrentPortalCRMUser("acpu_newentitydefault") : "";
}
if ((defaultSearchEntity==null) ||(defaultSearchEntity==""))
{
	defaultSearchEntity=NewEntityDefault;
}

var _comms_permission=hasPermissionInsert("communication");

var fileemailwebhook=getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+
				CRM.Url("sagecrmws/ac2020/fileemail.asp");

var apptwebhook=getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+
				CRM.Url("sagecrmws/ac2020/apptwebhookendpoint.asp");
				
var _startupmessage="";		
var _supdateObj={"version":"unknown"}
if (!isPortalRequest) {
	if (CRM.GetContextInfo("user", "User_Per_Admin") == "3"){
		var _supdate=geturl("https://update.crmtogether.com/serverindex52.json");
		_supdateObj={"version":"9.9.9.9","filename":"serverapi5211.zip","appfilename":"webapp5208.zip","appfilenamemx":"webappmx5205.zip","appfilenameplus":"webappplus5200.zip","description": "202304 release2"}
		try
		{
		 _supdateObj=JSON.parse(_supdate);
		 if (compareVersion(_supdateObj.version,_appversioninfo.version)==1)
		 {
			_startupmessage=""+CRM.GetTrans("Accelerator","UpdateAvailable")+". "+CRM.GetTrans("DocumentPluginErrors","ContactPluginAdministrator")+
			" - "+_appversioninfo.version+" < "+_supdateObj.version;
		 }		
		}catch(eurl){
			//carry on..geturl can fail if a proxy or server config blocks things
		}
	}
}
	
	//costi - entity menu options from user settings 
	var defaultEntityOptionsMenu = [{
                name:'focus',
                caption:CRM.GetTrans("Accelerator","Focus"),
				color:'black',
				icon:'mdi-image-filter-center-focus',
				enabled:true,
				enabledContext:'explorer',
				value:false
            },{
                name:'taskmx',
                caption:CRM.GetTrans("NewMenu","Task"),
				color:'blue',
				icon:'mdi-calendar-check',
				enabledContext:'explorer,compose',
				enabled:_comms_permission!=""
            },{
                name:'attachdocuments',
                caption:CRM.GetTrans("ColNames","attF"),
				color:'purple',
				icon:'mdi-attachment',
				enabledContext:'compose',
				enabled:true,
				value:false
            },{
                name:'tagemail',
                caption:CRM.GetTrans("Accelerator","Add Tag"),
				color:'red',
				icon:'mdi-email-edit',
				enabledContext:'explorer,compose',
				enabled:true,
				value:false
            },{
                name:'replytagemail',
                caption:CRM.GetTrans("Accelerator","Reply and Tag"),
				color:'green',
				icon:'mdi-email',
				enabledContext:'explorer',
				enabled:_comms_permission!=""
            },{
                name:'newemail',
                caption:CRM.GetTrans("NewMenu","E-mail"),
				color:'purple',
				icon:'mdi-email-plus',
				enabledContext:'explorer',
				enabled:_comms_permission!=""
            },{
                name:'newapptmx',
                caption:CRM.GetTrans("NewMenu","Appointment"),
				color:'green',
				icon:'mdi-calendar',
				enabledContext:'explorer',
				enabled:_comms_permission!=""
            },{
                name:'newappt',
                caption:"Outlook:"+CRM.GetTrans("NewMenu","Appointment"),
				color:'blue',
				icon:'mdi-calendar',
				enabledContext:'explorer',
				enabled:_comms_permission!=""
            }];

	var user_ct_acentityoptionsmenu = "";
	var entity_options_menu = CRM.FindRecord("Custom_Captions" , "capt_family='_crmtconfig' AND capt_code='entity_options_menu'");

	if (!entity_options_menu.eof && entity_options_menu.capt_us != null && entity_options_menu.capt_us !="") {
		try { 
			user_ct_acentityoptionsmenu = JSON.parse(entity_options_menu.capt_us);
		} catch (ex) { }
		if (user_ct_acentityoptionsmenu != "" || user_ct_acentityoptionsmenu != null)
		{
			
      defaultEntityOptionsMenu= defaultEntityOptionsMenu.concat(user_ct_acentityoptionsmenu);
		}
	}

//add in quicksearch? only if sage crm v 2021 or later
var __sagecrmbasever=new String(getSysParam("version"));
__sagecrmbasever=__sagecrmbasever.substring(0,4);
var __sagecrmbasevernum=new Number(__sagecrmbasever);	

var res={
	"version":_appversioninfo.version,
	"versiononline":_supdateObj.version,
	"versioncompare": compareVersion(_appversioninfo.version,_supdateObj.version),
	"startupmessage":_startupmessage,
    "customercode": getCompanyNameFlag(),
    "hasHome": true,
	"crmBaseVersion": __sagecrmbasevernum,
	"useQuickSearch":((__sagecrmbasevernum>=2021)&&(searchHasQuickSearchEnabled)),
    "hasSearch": searchEntities.length>0,
    "hasFileEmail": _comms_permission,
    "hasLogCall": _comms_permission,	
	"diaryStartTime":getDiaryStartTime(getUserId()),
	"diaryEndTime":getDiaryEndTime(getUserId()),	
    "hasOptions": true,
    "hasNew": newEntities.length>0,
    "hasHistory": true,
    "hasBookmarks": true,
	"listColumnCount":_baseConfig.listColumnCount,
    "defaultSearchEntity": defaultSearchEntity,
	"newEntityDefault":NewEntityDefault,
	"newEntities":newEntities,
    "newEntities22":newEntities22,
	"searchEntities":searchEntities,
    "lang": getUserLang(),
	"apptwebhook":apptwebhook,
	"fileemailwebhook":fileemailwebhook,	
	"useTheme":"light",
	"tagPrefixSuffix":GetWebConfigValue("tagPrefixSuffix"),
	"taghtmlstyle":GetWebConfigValue("taghtmlstyle"),
	"crmApp":"Sage CRM",
	"crmVersion":getSysParam("version"),
	"crmLicenseType":CRM.GetContextInfo("user","user_licencetype"),
	"hasTimeline": false,
	"options":defaultEntityOptionsMenu,
	"authorization":authToken+'',
	"clientAppMode":G_appMode,
	"clientAppPlatform":G_appPlatform
}

//add on any custom menu options now....
//check for a file called _custom.js
//check for ...   getscreensetup.options ...and append to the res.options 
var _customFilePath=Server.MapPath("_custom.json");

if (FileExists(_customFilePath))
{
  var _custom=JSON.parse(readallFile(_customFilePath));
  if ((_custom)&&(_custom.getscreensetup)&&(_custom.getscreensetup.options))
  {
    for (var ari=0;ari<_custom.getscreensetup.options.length;ari++)
	{
	    if (_custom.getscreensetup.options[ari].crmurl)
		{
		  _custom.getscreensetup.options[ari].crmurl=getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+CRM.Url(_custom.getscreensetup.options[ari].crmurl);		  
		}
		res.options.push(_custom.getscreensetup.options[ari]);	
	}
  }
}
res=getBranding(res);
res=JSON.stringify(res);

Glog(res);
Glog("getScreenSetup END");
Response.Write(res);
%>