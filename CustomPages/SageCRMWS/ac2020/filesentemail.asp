<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->

<!-- #include file ="helpers.js" -->
<!-- #include file ="globalsearch.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="fileemailSearch_utils.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="io.js" -->
<%

///no longer used 18 May 2021!!!

so this is to make sure its not run!!!

Glog("file:filesentemail.asp");
var testurl=CRM.Url("sagecrmws/ac2020/fileemailsearch.asp");
Glog(testurl);
var filesentemaildbgmore=false;
if (!Defined(Request.Form))
{
	//this allows us to test parsing of the data..clever
	Response.Clear();
    Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="emaildata">emaildata:</label><br>');
	Response.Write('<textarea id="emaildata" name="emaildata" rows="20" cols="75">');
	Response.Write('</textarea><br>');
	Response.Write('<label for="datastring">datastring:</label><br>');
	Response.Write('<textarea id="datastring" name="datastring" rows="20" cols="75">');
	Response.Write('</textarea><br>');	
	Response.Write('<label for="Entity">Entity:</label><br>');
	Response.Write('<input type="text" id="Entity" name="Entity" value=""><br>');
	Response.Write('<label for="EntityId">EntityId:</label><br>');
	Response.Write('<input type="text" id="EntityId" name="EntityId" value=""><br>');
	Response.Write('<br><input type="submit" value="Submit">');
	Response.Write('<form>');
	
	Response.Write('<br><br><a href="'+testurl+'" >This url</a>');
	Response.End();
	//sample url
	//"http://win-qb6s2mb2d3i//CRM2021r1/CustomPages/sagecrmws/ac2020/filesentemail.asp?SID=164606665648145"
}

function getEmailDataEntity(EmaildataObj)
{
	Glog("getEmailDataEntity");
	var res={
		entity:"",
		entityid:""
	}
	var q=findPersonByEmail(EmaildataObj.to[0].emailAddress);
	Glog("getEmailDataEntity emailAddress:"+EmaildataObj.to[0].emailAddress);
	if (q.RecordCount>0)
	{
		Glog("getEmailDataEntity person");
		res.entity="person";
		res.entityid=q("pers_personid");
	}else{
		var q=findCompanyByEmail(EmaildataObj.from.emailAddress);
		if (q.RecordCount>0)
		{
			Glog("getEmailDataEntity company");
			res.entity="company";
			res.entityid=q("comp_companyid");
		}else{
			var q=findLeadByEmail(EmaildataObj.from.emailAddress);
			if (q.RecordCount>0)
			{	
				Glog("getEmailDataEntity lead");
				res.entity="lead";
				res.entityid=q("lead_leadid");
			}else{
				Glog("getEmailDataEntity user");
				res.entity="user";
				res.entityid=CRM.GetContextInfo("user","user_userid");
			}
		}
	}
	return res;
}

function getCompanyFolder(companyid)
{
	var res="";
	if (companyid=="")
	  return res;
	var _sql="select comp_librarydir from company where comp_companyid="+companyid;
	var q=CRM.CreateQueryObj(_sql);
	q.SelectSQL();
	if (!q.eof)
	{
		res=q("comp_librarydir");
	}
	return res;
}

function getCompanyidFromEntity(entity,entityid)
{
	var res="";
	if (entity=="company")
	  return entityid;
	if (entityid+""=="undefined")
	  return "";
	
	var idfield=getCompanyIdField(entity);
	var tableinfo=getTableInfo(entity);
	if (idfield)
	{
		var _sql="select "+idfield+" from "+entity+" where "+tableinfo.idfield+"="+entityid;
		var q=CRM.CreateQueryObj(_sql);
		q.SelectSQL();
		if (!q.eof)
		{
			res=q(idfield);
		}
	}
	return res;
}

function getCompanyIdField(entity)
{
  if ((entity.toLowerCase()=="cases")||(entity.toLowerCase()=="case"))
  {
    return "case_primarycompanyid";
  }
  if (entity.toLowerCase()=="opportunity")
  {
    return "oppo_primarycompanyid";
  }
  if (entity.toLowerCase()=="person")
  {
    return "pers_companyid";
  }
  return "";
}

function getEntityPath(fileentity, fileentityid, commid)
{
	var compid=getCompanyidFromEntity(fileentity,fileentityid);
	var libr_path=getCompanyFolder(compid);
	if (libr_path=="")
		libr_path=CRM.GetContextInfo("user","user_firstname")+" "+CRM.GetContextInfo("user","user_lastname");
		
	//create a subfolder EG "Comm121"
	//we do this below as demo systems have the paths set but not existing in the library
	//EG H\\Harold inc....
	///so the folder H would be missing and cause a crash
	var _xpath=new String(getLibraryRootPath() +"\\" + libr_path);
	var _xpatharr=_xpath.split("\\");
	var _pathbuilder="";
	for(var tt=0;tt<_xpatharr.length;tt++)
	{
		if (_pathbuilder=="")
			_pathbuilder=_xpatharr[tt];
		else
			_pathbuilder+="\\"+_xpatharr[tt];
		createFolder(_pathbuilder);	
	}
	
	createFolder(getLibraryRootPath() +"\\" + libr_path);	
	createFolder(getLibraryRootPath() +"\\" + libr_path+"\\Comm"+commid);	
	return libr_path+"\\Comm"+commid;
}
var emaildataStr="";
var email=null;
var entity="";
var entityid="";
var datastring="";
var datastringObj=null;
//LINE BELOW SHOULD BE TRUE FOR LIVE
if (!filesentemaildbgmore)
{

	emaildataStr=new String(Request.Form("emaildata"));
	Glog("filesentemail emaildataStr START:");
	Glog(emaildataStr);
	Glog("filesentemail emaildataStr END:");
	email=JSON.parse(emaildataStr);
	Glog("entryid="+email.entryid);
	datastring=new String(Request.Form("datastring"));
	if (!Defined(datastring))
	  datastring="";
	Glog("filesentemail datastring:");
	Glog(datastring);
	entity=new String(Request.Form("entity"));
	if (!Defined(entity))
	  entity="";
	entityid=new String(Request.Form("entityid"));
	if (datastring!="")
	{
		datastringObj=JSON.parse(datastring);
	}
}else{
	//test data..insert where null is below..DO NOT CHECK IN WITH A VALUE
	//entity="person";
	//entityid="1662";//1662=Thomas Beesley
	//email=null;
	//{"from":{"displayName":"Marc Reidy","emailAddress":"marc@CRMTogetherDev.onmicrosoft.com","type":null},"replyto":null,"fullName":"Marc Reidy","phoneNumbers":[],"to":[{"displayName":"Marc Reidy","emailAddress":"marc@CRMTogetherDev.onmicrosoft.com","type":null}],"cc":[],"bcc":[],"subject":"RE: 11111111111111111","body":" \r\n \r\nFrom: Marc Reidy <marc@CRMTogetherDev.onmicrosoft.com> \r\nSent: Wednesday, February 10, 2021 2:01 PM\r\nTo: Marc Reidy <marc@CRMTogetherDev.onmicrosoft.com>\r\nSubject: RE: 11111111111111111\r\n \r\naaaaaaa\r\n","htmlBody":"<html xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:w=\"urn:schemas-microsoft-com:office:word\" xmlns:m=\"http://schemas.microsoft.com/office/2004/12/omml\" xmlns=\"http://www.w3.org/TR/REC-html40\"><head><meta name=Generator content=\"Microsoft Word 15 (filtered medium)\"><style><!--\r\n/* Font Definitions */\r\n@font-face\r\n\t{font-family:\"Cambria Math\";\r\n\tpanose-1:2 4 5 3 5 4 6 3 2 4;}\r\n@font-face\r\n\t{font-family:Calibri;\r\n\tpanose-1:2 15 5 2 2 2 4 3 2 4;}\r\n/* Style Definitions */\r\np.MsoNormal, li.MsoNormal, div.MsoNormal\r\n\t{margin:0in;\r\n\tfont-size:11.0pt;\r\n\tfont-family:\"Calibri\",sans-serif;}\r\nspan.EmailStyle19\r\n\t{mso-style-type:personal-reply;\r\n\tfont-family:\"Calibri\",sans-serif;\r\n\tcolor:windowtext;}\r\n.MsoChpDefault\r\n\t{mso-style-type:export-only;\r\n\tfont-size:10.0pt;}\r\n@page WordSection1\r\n\t{size:8.5in 11.0in;\r\n\tmargin:1.0in 1.0in 1.0in 1.0in;}\r\ndiv.WordSection1\r\n\t{page:WordSection1;}\r\n--></style><!--[if gte mso 9]><xml>\r\n<o:shapedefaults v:ext=\"edit\" spidmax=\"1026\" />\r\n</xml><![endif]--><!--[if gte mso 9]><xml>\r\n<o:shapelayout v:ext=\"edit\">\r\n<o:idmap v:ext=\"edit\" data=\"1\" />\r\n</o:shapelayout></xml><![endif]--></head><body lang=EN-US link=\"#0563C1\" vlink=\"#954F72\" style='word-wrap:break-word'><div class=WordSection1><p class=MsoNormal><o:p>&nbsp;</o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p><div><div style='border:none;border-top:solid #E1E1E1 1.0pt;padding:3.0pt 0in 0in 0in'><p class=MsoNormal><b>From:</b> Marc Reidy &lt;marc@CRMTogetherDev.onmicrosoft.com&gt; <br><b>Sent:</b> Wednesday, February 10, 2021 2:01 PM<br><b>To:</b> Marc Reidy &lt;marc@CRMTogetherDev.onmicrosoft.com&gt;<br><b>Subject:</b> RE: 11111111111111111<o:p></o:p></p></div></div><p class=MsoNormal><o:p>&nbsp;</o:p></p><p class=MsoNormal><span lang=EN-IE>aaaaaaa<o:p></o:p></span></p></div></body></html>","attachments":[],"entryid":"000000004D98DA14CCC0C3439F241C3CF9C2A23E070067DD41A834432A4EBDCEE9790DF77BBE00000000010A000067DD41A834432A4EBDCEE9790DF77BBE00060B1C922D0000","urls":[],"addresses":null,"sentItem":false,"receivedDateTime":{"year":2021,"month":2,"day":10,"hour":14,"minute":10,"second":0,"raw":"2021-02-10T14:10:00","rawutc":"2021-02-10T14:10:00Z","TZ":{"StandardName":"GMT Standard Time","DaylightName":"GMT Daylight Time"}},"sentDateTime":{"year":2021,"month":2,"day":10,"hour":14,"minute":10,"second":22,"raw":"2021-02-10T14:10:22.752","rawutc":"2021-02-10T14:10:22.752Z","TZ":{"StandardName":"GMT Standard Time","DaylightName":"GMT Daylight Time"}},"companies":null};
	//set this to test the context...ie send and prompt
	//datastring="{\"screenMetadata\":{\"container\":\"\",\"entity\":\"person\",\"entityid\":\"1780\",\"entityIcon\":\"mdi-account\",\"entityName\":\"Marc Reidy\",\"sendMode\":false,\"screensetup\":{\"container\":\"SageCRM\",\"entity\":\"person\",\"entityid\":\"1780\",\"buttonAction\":\"\",\"lang\":\"en-uk\",\"entityIcon\":\"mdi-account\",\"entityName\":\"Marc Reidy\",\"entityName2\":\"\",\"entityName3\":\"\",\"entitytag\":\"\",\"tabs\":[],\"comm_screen_metadata\":{\"screenMetadata\":{\"screens\":[{\"title\":\"Communication\",\"subheader\":\"communication\",\"name\":\"AcceleratorCommunicationPicker\",\"entity\":\"communication\",\"formElements\":[{\"name\":\"comm_priority\",\"componentType\":\"MyFormSelect\",\"value\":{\"text\":\"Normal\",\"value\":\"Normal\"},\"icon\":\"\",\"iconColor\":\"\",\"caption\":\"Priority\",\"placeholder\":\"\",\"options\":[{\"text\":\"Low\",\"value\":\"Low\"},{\"text\":\"Normal\",\"value\":\"Normal\"},{\"text\":\"High\",\"value\":\"High\"}],\"remoteMethod\":null,\"filterObject\":null,\"filter\":\"\",\"required\":false,\"readonly\":false,\"maxLength\":40},{\"name\":\"comm_channelid\",\"componentType\":\"MyFormSelect\",\"icon\":\"\",\"iconColor\":\"\",\"caption\":\"Team\",\"placeholder\":\"\",\"options\":[{\"text\":\"Direct Sales\",\"value\":\"1\"},{\"text\":\"Telesales\",\"value\":\"2\"},{\"text\":\"Customer Service\",\"value\":\"3\"},{\"text\":\"Marketing\",\"value\":\"4\"},{\"text\":\"Operations\",\"value\":\"5\"}],\"remoteMethod\":null,\"filterObject\":null,\"filter\":\"\",\"required\":false,\"readonly\":false,\"maxLength\":2}]}]}},\"library_screen_metadata\":{\"screenMetadata\":{\"screens\":[{\"title\":\"Library\",\"subheader\":\"library\",\"name\":\"AcceleratorDocumentPicker\",\"entity\":\"library\",\"formElements\":[{\"name\":\"libr_type\",\"componentType\":\"MyFormSelect\",\"value\":\"EmailAttachment\",\"icon\":\"\",\"iconColor\":\"\",\"caption\":\"Type\",\"placeholder\":\"\",\"options\":[{\"text\":\"Brochure\",\"value\":\"Brochure\"},{\"text\":\"Contract\",\"value\":\"Contract\"},{\"text\":\"E-mail Attachment\",\"value\":\"EmailAttachment\"},{\"text\":\"Fax\",\"value\":\"Fax\"},{\"text\":\"Letter\",\"value\":\"Letter\"},{\"text\":\"Order\",\"value\":\"Order\"},{\"text\":\"Proposal\",\"value\":\"Proposal\"},{\"text\":\"Purchase Order\",\"value\":\"Purchase\"},{\"text\":\"Quote\",\"value\":\"Quote\"},{\"text\":\"Report\",\"value\":\"Report\"},{\"text\":\"Request for Information\",\"value\":\"Request_Information\"},{\"text\":\"Request for Proposal\",\"value\":\"Request_Proposal\"},{\"text\":\"Response to RFI\",\"value\":\"Response_RFI\"},{\"text\":\"Response to RFP\",\"value\":\"Response_RFP\"},{\"text\":\"E-mail Inline Image\",\"value\":\"EmailInline\"},{\"text\":\"Group Export\",\"value\":\"TargetListExport\"}],\"remoteMethod\":null,\"filterObject\":null,\"filter\":\"\",\"required\":false,\"readonly\":false,\"maxLength\":25},{\"name\":\"libr_category\",\"componentType\":\"MyFormSelect\",\"value\":{\"text\":\"Sales\",\"value\":\"Sales\"},\"icon\":\"\",\"iconColor\":\"\",\"caption\":\"Category\",\"placeholder\":\"\",\"options\":[{\"text\":\"Finance\",\"value\":\"Finance\"},{\"text\":\"Legal\",\"value\":\"Legal\"},{\"text\":\"Marketing\",\"value\":\"Marketing\"},{\"text\":\"My Crm\",\"value\":\"MyCrm\"},{\"text\":\"Sales\",\"value\":\"Sales\"},{\"text\":\"Support\",\"value\":\"Support\"}],\"remoteMethod\":null,\"filterObject\":null,\"filter\":\"\",\"required\":false,\"readonly\":false,\"maxLength\":40},{\"name\":\"libr_status\",\"componentType\":\"MyFormSelect\",\"value\":{\"text\":\"Final\",\"value\":\"Final\"},\"icon\":\"\",\"iconColor\":\"\",\"caption\":\"Status\",\"placeholder\":\"\",\"options\":[{\"text\":\"Complete\",\"value\":\"Complete\"},{\"text\":\"Draft\",\"value\":\"Draft\"},{\"text\":\"Final\",\"value\":\"Final\"},{\"text\":\"In Progress\",\"value\":\"InProgress\"},{\"text\":\"Pending\",\"value\":\"Pending\"}],\"remoteMethod\":null,\"filterObject\":null,\"filter\":\"\",\"required\":false,\"readonly\":false,\"maxLength\":40},{\"name\":\"libr_active\",\"componentType\":\"MyFormSelect\",\"value\":{\"text\":\"Y\",\"value\":\"Y\"},\"icon\":\"\",\"iconColor\":\"\",\"caption\":\"Active\",\"placeholder\":\"\",\"options\":[{\"text\":\"No\",\"value\":\"N\"},{\"text\":\"Yes\",\"value\":\"Y\"}],\"remoteMethod\":null,\"filterObject\":null,\"filter\":\"\",\"required\":false,\"readonly\":false,\"maxLength\":40},{\"name\":\"libr_channelid\",\"componentType\":\"MyFormSelect\",\"icon\":\"\",\"iconColor\":\"\",\"caption\":\"Team\",\"placeholder\":\"\",\"options\":[{\"text\":\"Direct Sales\",\"value\":\"1\"},{\"text\":\"Telesales\",\"value\":\"2\"},{\"text\":\"Customer Service\",\"value\":\"3\"},{\"text\":\"Marketing\",\"value\":\"4\"},{\"text\":\"Operations\",\"value\":\"5\"}],\"remoteMethod\":null,\"filterObject\":null,\"filter\":\"\",\"required\":false,\"readonly\":false,\"maxLength\":2}]}]}},\"branding\":{\"clientPrimaryColor\":\"#106EBE\",\"secondaryLogo\":\"\",\"secondaryURL\":\"https://www.crmtogether.com\"},\"themes\":{\"light\":{\"primary\":\"#106EBE\"},\"dark\":{\"primary\":\"#106EBE\"}}},\"comm_screen_metadata\":{},\"library_screen_metadata\":{}},\"EmailList\":[{\"from\":{\"displayName\":\"\",\"emailAddress\":\"marc@CRMTogetherDev.onmicrosoft.com\",\"type\":null},\"replyto\":null,\"fullName\":null,\"phoneNumbers\":[{\"number\":\"1073732485\",\"type\":\"business\"}],\"to\":[{\"displayName\":\"Marc Reidy\",\"emailAddress\":\"marc@CRMTogetherDev.onmicrosoft.com\",\"type\":null}],\"cc\":[],\"bcc\":[],\"subject\":{\"name\":\"subject\",\"value\":\"RE: 333\",\"caption\":\"\"},\"body\":\" \\r\\n \\r\\nFrom: Marc Reidy <marc@CRMTogetherDev.onmicrosoft.com> \\r\\nSent: Thursday, February 11, 2021 12:12 PM\\r\\nTo: Marc Reidy <marc@CRMTogetherDev.onmicrosoft.com>\\r\\nSubject: 333\\r\\n \\r\\n3333\",\"htmlBody\":{\"name\":\"details\",\"value\":{\"text\":\" \\r\\n \\r\\nFrom: Marc Reidy <marc@CRMTogetherDev.onmicrosoft.com> \\r\\nSent: Thursday, February 11, 2021 12:12 PM\\r\\nTo: Marc Reidy <marc@CRMTogetherDev.onmicrosoft.com>\\r\\nSubject: 333\\r\\n \\r\\n3333\",\"html\":\"<html xmlns:v=\\\"urn:schemas-microsoft-com:vml\\\" xmlns:o=\\\"urn:schemas-microsoft-com:office:office\\\" xmlns:w=\\\"urn:schemas-microsoft-com:office:word\\\" xmlns:m=\\\"http://schemas.microsoft.com/office/2004/12/omml\\\" xmlns=\\\"http://www.w3.org/TR/REC-html40\\\"><head><meta name=ProgId content=Word.Document><meta name=Generator content=\\\"Microsoft Word 15\\\"><meta name=Originator content=\\\"Microsoft Word 15\\\"><link rel=File-List href=\\\"cid:filelist.xml@01D7007D.5B8A20D0\\\"><!--[if gte mso 9]><xml>\\r\\n<o:OfficeDocumentSettings>\\r\\n<o:AllowPNG/>\\r\\n</o:OfficeDocumentSettings>\\r\\n</xml><![endif]--><link rel=themeData href=\\\"~~themedata~~\\\"><link rel=colorSchemeMapping href=\\\"~~colorschememapping~~\\\"><!--[if gte mso 9]><xml>\\r\\n<w:WordDocument>\\r\\n<w:DocumentKind>DocumentEmail</w:DocumentKind>\\r\\n<w:TrackMoves/>\\r\\n<w:TrackFormatting/>\\r\\n<w:EnvelopeVis/>\\r\\n<w:ValidateAgainstSchemas/>\\r\\n<w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>\\r\\n<w:IgnoreMixedContent>false</w:IgnoreMixedContent>\\r\\n<w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>\\r\\n<w:DoNotPromoteQF/>\\r\\n<w:LidThemeOther>EN-US</w:LidThemeOther>\\r\\n<w:LidThemeAsian>X-NONE</w:LidThemeAsian>\\r\\n<w:LidThemeComplexScript>X-NONE</w:LidThemeComplexScript>\\r\\n<w:Compatibility>\\r\\n<w:DoNotExpandShiftReturn/>\\r\\n<w:BreakWrappedTables/>\\r\\n<w:SplitPgBreakAndParaMark/>\\r\\n<w:EnableOpenTypeKerning/>\\r\\n</w:Compatibility>\\r\\n<w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>\\r\\n<m:mathPr>\\r\\n<m:mathFont m:val=\\\"Cambria Math\\\"/>\\r\\n<m:brkBin m:val=\\\"before\\\"/>\\r\\n<m:brkBinSub m:val=\\\"&#45;-\\\"/>\\r\\n<m:smallFrac m:val=\\\"off\\\"/>\\r\\n<m:dispDef/>\\r\\n<m:lMargin m:val=\\\"0\\\"/>\\r\\n<m:rMargin m:val=\\\"0\\\"/>\\r\\n<m:defJc m:val=\\\"centerGroup\\\"/>\\r\\n<m:wrapIndent m:val=\\\"1440\\\"/>\\r\\n<m:intLim m:val=\\\"subSup\\\"/>\\r\\n<m:naryLim m:val=\\\"undOvr\\\"/>\\r\\n</m:mathPr></w:WordDocument>\\r\\n</xml><![endif]--><!--[if gte mso 9]><xml>\\r\\n<w:LatentStyles DefLockedState=\\\"false\\\" DefUnhideWhenUsed=\\\"false\\\" DefSemiHidden=\\\"false\\\" DefQFormat=\\\"false\\\" DefPriority=\\\"99\\\" LatentStyleCount=\\\"376\\\">\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"0\\\" QFormat=\\\"true\\\" Name=\\\"Normal\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" QFormat=\\\"true\\\" Name=\\\"heading 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"heading 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"heading 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"heading 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"heading 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"heading 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"heading 7\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"heading 8\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"9\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"heading 9\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 7\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 8\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index 9\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 7\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 8\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toc 9\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Normal Indent\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"footnote text\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"annotation text\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"header\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"footer\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"index heading\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"35\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"caption\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"table of figures\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"envelope address\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"envelope return\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"footnote reference\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"annotation reference\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"line number\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"page number\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"endnote reference\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"endnote text\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"table of authorities\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"macro\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"toa heading\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Bullet\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Number\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Bullet 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Bullet 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Bullet 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Bullet 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Number 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Number 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Number 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Number 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"10\\\" QFormat=\\\"true\\\" Name=\\\"Title\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Closing\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Signature\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"1\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Default Paragraph Font\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Body Text\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Body Text Indent\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Continue\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Continue 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Continue 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Continue 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"List Continue 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Message Header\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"11\\\" QFormat=\\\"true\\\" Name=\\\"Subtitle\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Salutation\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Date\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Body Text First Indent\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Body Text First Indent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Note Heading\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Body Text 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Body Text 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Body Text Indent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Body Text Indent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Block Text\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Hyperlink\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"FollowedHyperlink\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"22\\\" QFormat=\\\"true\\\" Name=\\\"Strong\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"20\\\" QFormat=\\\"true\\\" Name=\\\"Emphasis\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Document Map\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Plain Text\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"E-mail Signature\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Top of Form\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Bottom of Form\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Normal (Web)\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Acronym\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Address\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Cite\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Code\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Definition\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Keyboard\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Preformatted\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Sample\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Typewriter\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"HTML Variable\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"annotation subject\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"No List\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Outline List 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Outline List 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Outline List 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Simple 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Simple 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Simple 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Classic 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Classic 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Classic 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Classic 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Colorful 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Colorful 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Colorful 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Columns 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Columns 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Columns 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Columns 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Columns 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Grid 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Grid 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Grid 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Grid 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Grid 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Grid 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Grid 7\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Grid 8\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table List 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table List 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table List 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table List 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table List 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table List 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table List 7\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table List 8\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table 3D effects 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table 3D effects 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table 3D effects 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Contemporary\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Elegant\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Professional\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Subtle 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Subtle 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Web 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Table Web 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Balloon Text\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" Name=\\\"Table Grid\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" Name=\\\"Placeholder Text\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"1\\\" QFormat=\\\"true\\\" Name=\\\"No Spacing\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"60\\\" Name=\\\"Light Shading\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"61\\\" Name=\\\"Light List\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"62\\\" Name=\\\"Light Grid\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"63\\\" Name=\\\"Medium Shading 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"64\\\" Name=\\\"Medium Shading 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"65\\\" Name=\\\"Medium List 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"66\\\" Name=\\\"Medium List 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"67\\\" Name=\\\"Medium Grid 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"68\\\" Name=\\\"Medium Grid 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"69\\\" Name=\\\"Medium Grid 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"70\\\" Name=\\\"Dark List\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"71\\\" Name=\\\"Colorful Shading\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"72\\\" Name=\\\"Colorful List\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"73\\\" Name=\\\"Colorful Grid\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"60\\\" Name=\\\"Light Shading Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"61\\\" Name=\\\"Light List Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"62\\\" Name=\\\"Light Grid Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"63\\\" Name=\\\"Medium Shading 1 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"64\\\" Name=\\\"Medium Shading 2 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"65\\\" Name=\\\"Medium List 1 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" Name=\\\"Revision\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"34\\\" QFormat=\\\"true\\\" Name=\\\"List Paragraph\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"29\\\" QFormat=\\\"true\\\" Name=\\\"Quote\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"30\\\" QFormat=\\\"true\\\" Name=\\\"Intense Quote\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"66\\\" Name=\\\"Medium List 2 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"67\\\" Name=\\\"Medium Grid 1 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"68\\\" Name=\\\"Medium Grid 2 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"69\\\" Name=\\\"Medium Grid 3 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"70\\\" Name=\\\"Dark List Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"71\\\" Name=\\\"Colorful Shading Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"72\\\" Name=\\\"Colorful List Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"73\\\" Name=\\\"Colorful Grid Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"60\\\" Name=\\\"Light Shading Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"61\\\" Name=\\\"Light List Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"62\\\" Name=\\\"Light Grid Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"63\\\" Name=\\\"Medium Shading 1 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"64\\\" Name=\\\"Medium Shading 2 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"65\\\" Name=\\\"Medium List 1 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"66\\\" Name=\\\"Medium List 2 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"67\\\" Name=\\\"Medium Grid 1 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"68\\\" Name=\\\"Medium Grid 2 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"69\\\" Name=\\\"Medium Grid 3 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"70\\\" Name=\\\"Dark List Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"71\\\" Name=\\\"Colorful Shading Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"72\\\" Name=\\\"Colorful List Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"73\\\" Name=\\\"Colorful Grid Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"60\\\" Name=\\\"Light Shading Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"61\\\" Name=\\\"Light List Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"62\\\" Name=\\\"Light Grid Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"63\\\" Name=\\\"Medium Shading 1 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"64\\\" Name=\\\"Medium Shading 2 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"65\\\" Name=\\\"Medium List 1 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"66\\\" Name=\\\"Medium List 2 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"67\\\" Name=\\\"Medium Grid 1 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"68\\\" Name=\\\"Medium Grid 2 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"69\\\" Name=\\\"Medium Grid 3 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"70\\\" Name=\\\"Dark List Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"71\\\" Name=\\\"Colorful Shading Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"72\\\" Name=\\\"Colorful List Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"73\\\" Name=\\\"Colorful Grid Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"60\\\" Name=\\\"Light Shading Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"61\\\" Name=\\\"Light List Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"62\\\" Name=\\\"Light Grid Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"63\\\" Name=\\\"Medium Shading 1 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"64\\\" Name=\\\"Medium Shading 2 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"65\\\" Name=\\\"Medium List 1 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"66\\\" Name=\\\"Medium List 2 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"67\\\" Name=\\\"Medium Grid 1 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"68\\\" Name=\\\"Medium Grid 2 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"69\\\" Name=\\\"Medium Grid 3 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"70\\\" Name=\\\"Dark List Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"71\\\" Name=\\\"Colorful Shading Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"72\\\" Name=\\\"Colorful List Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"73\\\" Name=\\\"Colorful Grid Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"60\\\" Name=\\\"Light Shading Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"61\\\" Name=\\\"Light List Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"62\\\" Name=\\\"Light Grid Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"63\\\" Name=\\\"Medium Shading 1 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"64\\\" Name=\\\"Medium Shading 2 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"65\\\" Name=\\\"Medium List 1 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"66\\\" Name=\\\"Medium List 2 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"67\\\" Name=\\\"Medium Grid 1 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"68\\\" Name=\\\"Medium Grid 2 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"69\\\" Name=\\\"Medium Grid 3 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"70\\\" Name=\\\"Dark List Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"71\\\" Name=\\\"Colorful Shading Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"72\\\" Name=\\\"Colorful List Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"73\\\" Name=\\\"Colorful Grid Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"60\\\" Name=\\\"Light Shading Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"61\\\" Name=\\\"Light List Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"62\\\" Name=\\\"Light Grid Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"63\\\" Name=\\\"Medium Shading 1 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"64\\\" Name=\\\"Medium Shading 2 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"65\\\" Name=\\\"Medium List 1 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"66\\\" Name=\\\"Medium List 2 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"67\\\" Name=\\\"Medium Grid 1 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"68\\\" Name=\\\"Medium Grid 2 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"69\\\" Name=\\\"Medium Grid 3 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"70\\\" Name=\\\"Dark List Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"71\\\" Name=\\\"Colorful Shading Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"72\\\" Name=\\\"Colorful List Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"73\\\" Name=\\\"Colorful Grid Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"19\\\" QFormat=\\\"true\\\" Name=\\\"Subtle Emphasis\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"21\\\" QFormat=\\\"true\\\" Name=\\\"Intense Emphasis\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"31\\\" QFormat=\\\"true\\\" Name=\\\"Subtle Reference\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"32\\\" QFormat=\\\"true\\\" Name=\\\"Intense Reference\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"33\\\" QFormat=\\\"true\\\" Name=\\\"Book Title\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"37\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Bibliography\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"39\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" QFormat=\\\"true\\\" Name=\\\"TOC Heading\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"41\\\" Name=\\\"Plain Table 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"42\\\" Name=\\\"Plain Table 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"43\\\" Name=\\\"Plain Table 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"44\\\" Name=\\\"Plain Table 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"45\\\" Name=\\\"Plain Table 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"40\\\" Name=\\\"Grid Table Light\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"Grid Table 1 Light\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"Grid Table 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"Grid Table 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"Grid Table 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"Grid Table 5 Dark\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"Grid Table 6 Colorful\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"Grid Table 7 Colorful\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"Grid Table 1 Light Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"Grid Table 2 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"Grid Table 3 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"Grid Table 4 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"Grid Table 5 Dark Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"Grid Table 6 Colorful Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"Grid Table 7 Colorful Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"Grid Table 1 Light Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"Grid Table 2 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"Grid Table 3 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"Grid Table 4 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"Grid Table 5 Dark Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"Grid Table 6 Colorful Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"Grid Table 7 Colorful Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"Grid Table 1 Light Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"Grid Table 2 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"Grid Table 3 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"Grid Table 4 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"Grid Table 5 Dark Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"Grid Table 6 Colorful Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"Grid Table 7 Colorful Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"Grid Table 1 Light Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"Grid Table 2 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"Grid Table 3 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"Grid Table 4 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"Grid Table 5 Dark Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"Grid Table 6 Colorful Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"Grid Table 7 Colorful Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"Grid Table 1 Light Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"Grid Table 2 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"Grid Table 3 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"Grid Table 4 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"Grid Table 5 Dark Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"Grid Table 6 Colorful Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"Grid Table 7 Colorful Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"Grid Table 1 Light Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"Grid Table 2 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"Grid Table 3 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"Grid Table 4 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"Grid Table 5 Dark Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"Grid Table 6 Colorful Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"Grid Table 7 Colorful Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"List Table 1 Light\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"List Table 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"List Table 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"List Table 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"List Table 5 Dark\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"List Table 6 Colorful\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"List Table 7 Colorful\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"List Table 1 Light Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"List Table 2 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"List Table 3 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"List Table 4 Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"List Table 5 Dark Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"List Table 6 Colorful Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"List Table 7 Colorful Accent 1\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"List Table 1 Light Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"List Table 2 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"List Table 3 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"List Table 4 Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"List Table 5 Dark Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"List Table 6 Colorful Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"List Table 7 Colorful Accent 2\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"List Table 1 Light Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"List Table 2 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"List Table 3 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"List Table 4 Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"List Table 5 Dark Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"List Table 6 Colorful Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"List Table 7 Colorful Accent 3\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"List Table 1 Light Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"List Table 2 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"List Table 3 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"List Table 4 Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"List Table 5 Dark Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"List Table 6 Colorful Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"List Table 7 Colorful Accent 4\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"List Table 1 Light Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"List Table 2 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"List Table 3 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"List Table 4 Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"List Table 5 Dark Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"List Table 6 Colorful Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"List Table 7 Colorful Accent 5\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"46\\\" Name=\\\"List Table 1 Light Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"47\\\" Name=\\\"List Table 2 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"48\\\" Name=\\\"List Table 3 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"49\\\" Name=\\\"List Table 4 Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"50\\\" Name=\\\"List Table 5 Dark Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"51\\\" Name=\\\"List Table 6 Colorful Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" Priority=\\\"52\\\" Name=\\\"List Table 7 Colorful Accent 6\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Mention\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Smart Hyperlink\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Hashtag\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Unresolved Mention\\\"/>\\r\\n<w:LsdException Locked=\\\"false\\\" SemiHidden=\\\"true\\\" UnhideWhenUsed=\\\"true\\\" Name=\\\"Smart Link\\\"/>\\r\\n</w:LatentStyles>\\r\\n</xml><![endif]--><style><!--\\r\\n/* Font Definitions */\\r\\n@font-face\\r\\n\\t{font-family:\\\"Cambria Math\\\";\\r\\n\\tpanose-1:2 4 5 3 5 4 6 3 2 4;\\r\\n\\tmso-font-charset:0;\\r\\n\\tmso-generic-font-family:roman;\\r\\n\\tmso-font-pitch:variable;\\r\\n\\tmso-font-signature:3 0 0 0 1 0;}\\r\\n@font-face\\r\\n\\t{font-family:Calibri;\\r\\n\\tpanose-1:2 15 5 2 2 2 4 3 2 4;\\r\\n\\tmso-font-charset:0;\\r\\n\\tmso-generic-font-family:swiss;\\r\\n\\tmso-font-pitch:variable;\\r\\n\\tmso-font-signature:-536858881 -1073732485 9 0 511 0;}\\r\\n/* Style Definitions */\\r\\np.MsoNormal, li.MsoNormal, div.MsoNormal\\r\\n\\t{mso-style-unhide:no;\\r\\n\\tmso-style-qformat:yes;\\r\\n\\tmso-style-parent:\\\"\\\";\\r\\n\\tmargin:0in;\\r\\n\\tmso-pagination:widow-orphan;\\r\\n\\tfont-size:11.0pt;\\r\\n\\tfont-family:\\\"Calibri\\\",sans-serif;\\r\\n\\tmso-fareast-font-family:Calibri;\\r\\n\\tmso-fareast-theme-font:minor-latin;}\\r\\na:link, span.MsoHyperlink\\r\\n\\t{mso-style-noshow:yes;\\r\\n\\tmso-style-priority:99;\\r\\n\\tcolor:#0563C1;\\r\\n\\ttext-decoration:underline;\\r\\n\\ttext-underline:single;}\\r\\na:visited, span.MsoHyperlinkFollowed\\r\\n\\t{mso-style-noshow:yes;\\r\\n\\tmso-style-priority:99;\\r\\n\\tcolor:#954F72;\\r\\n\\ttext-decoration:underline;\\r\\n\\ttext-underline:single;}\\r\\np.msonormal0, li.msonormal0, div.msonormal0\\r\\n\\t{mso-style-name:msonormal;\\r\\n\\tmso-style-unhide:no;\\r\\n\\tmso-margin-top-alt:auto;\\r\\n\\tmargin-right:0in;\\r\\n\\tmso-margin-bottom-alt:auto;\\r\\n\\tmargin-left:0in;\\r\\n\\tmso-pagination:widow-orphan;\\r\\n\\tfont-size:11.0pt;\\r\\n\\tfont-family:\\\"Calibri\\\",sans-serif;\\r\\n\\tmso-fareast-font-family:Calibri;\\r\\n\\tmso-fareast-theme-font:minor-latin;}\\r\\nspan.EmailStyle18\\r\\n\\t{mso-style-type:personal;\\r\\n\\tmso-style-noshow:yes;\\r\\n\\tmso-style-unhide:no;\\r\\n\\tfont-family:\\\"Calibri\\\",sans-serif;\\r\\n\\tmso-ascii-font-family:Calibri;\\r\\n\\tmso-hansi-font-family:Calibri;\\r\\n\\tmso-bidi-font-family:Calibri;\\r\\n\\tcolor:windowtext;}\\r\\nspan.EmailStyle19\\r\\n\\t{mso-style-type:personal-reply;\\r\\n\\tmso-style-noshow:yes;\\r\\n\\tmso-style-unhide:no;\\r\\n\\tmso-ansi-font-size:11.0pt;\\r\\n\\tmso-bidi-font-size:11.0pt;\\r\\n\\tfont-family:\\\"Calibri\\\",sans-serif;\\r\\n\\tmso-ascii-font-family:Calibri;\\r\\n\\tmso-ascii-theme-font:minor-latin;\\r\\n\\tmso-fareast-font-family:Calibri;\\r\\n\\tmso-fareast-theme-font:minor-latin;\\r\\n\\tmso-hansi-font-family:Calibri;\\r\\n\\tmso-hansi-theme-font:minor-latin;\\r\\n\\tmso-bidi-font-family:\\\"Times New Roman\\\";\\r\\n\\tmso-bidi-theme-font:minor-bidi;\\r\\n\\tcolor:windowtext;}\\r\\n.MsoChpDefault\\r\\n\\t{mso-style-type:export-only;\\r\\n\\tmso-default-props:yes;\\r\\n\\tfont-size:10.0pt;\\r\\n\\tmso-ansi-font-size:10.0pt;\\r\\n\\tmso-bidi-font-size:10.0pt;}\\r\\n@page WordSection1\\r\\n\\t{size:8.5in 11.0in;\\r\\n\\tmargin:1.0in 1.0in 1.0in 1.0in;\\r\\n\\tmso-header-margin:.5in;\\r\\n\\tmso-footer-margin:.5in;\\r\\n\\tmso-paper-source:0;}\\r\\ndiv.WordSection1\\r\\n\\t{page:WordSection1;}\\r\\n--></style><!--[if gte mso 10]><style>/* Style Definitions */\\r\\ntable.MsoNormalTable\\r\\n\\t{mso-style-name:\\\"Table Normal\\\";\\r\\n\\tmso-tstyle-rowband-size:0;\\r\\n\\tmso-tstyle-colband-size:0;\\r\\n\\tmso-style-noshow:yes;\\r\\n\\tmso-style-priority:99;\\r\\n\\tmso-style-parent:\\\"\\\";\\r\\n\\tmso-padding-alt:0in 5.4pt 0in 5.4pt;\\r\\n\\tmso-para-margin:0in;\\r\\n\\tmso-pagination:widow-orphan;\\r\\n\\tfont-size:10.0pt;\\r\\n\\tfont-family:\\\"Times New Roman\\\",serif;}\\r\\n</style><![endif]--><!--[if gte mso 9]><xml>\\r\\n<o:shapedefaults v:ext=\\\"edit\\\" spidmax=\\\"1026\\\" />\\r\\n</xml><![endif]--><!--[if gte mso 9]><xml>\\r\\n<o:shapelayout v:ext=\\\"edit\\\">\\r\\n<o:idmap v:ext=\\\"edit\\\" data=\\\"1\\\" />\\r\\n</o:shapelayout></xml><![endif]--></head><body lang=EN-US link=\\\"#0563C1\\\" vlink=\\\"#954F72\\\" style='tab-interval:.5in;word-wrap:break-word'><div class=WordSection1><p class=MsoNormal><span style='mso-ascii-font-family:Calibri;mso-ascii-theme-font:minor-latin;mso-hansi-font-family:Calibri;mso-hansi-theme-font:minor-latin;mso-bidi-font-family:\\\"Times New Roman\\\";mso-bidi-theme-font:minor-bidi'><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><a name=\\\"_MailEndCompose\\\"><span style='mso-ascii-font-family:Calibri;mso-ascii-theme-font:minor-latin;mso-hansi-font-family:Calibri;mso-hansi-theme-font:minor-latin;mso-bidi-font-family:\\\"Times New Roman\\\";mso-bidi-theme-font:minor-bidi'><o:p>&nbsp;</o:p></span></a></p><span style='mso-bookmark:_MailEndCompose'></span><div><div style='border:none;border-top:solid #E1E1E1 1.0pt;padding:3.0pt 0in 0in 0in'><p class=MsoNormal><a name=\\\"_MailOriginal\\\"><b><span style='mso-fareast-font-family:\\\"Times New Roman\\\"'>From:</span></b></a><span style='mso-bookmark:_MailOriginal'><span style='mso-fareast-font-family:\\\"Times New Roman\\\"'> Marc Reidy &lt;marc@CRMTogetherDev.onmicrosoft.com&gt; <br><b>Sent:</b> Thursday, February 11, 2021 12:12 PM<br><b>To:</b> Marc Reidy &lt;marc@CRMTogetherDev.onmicrosoft.com&gt;<br><b>Subject:</b> 333<o:p></o:p></span></span></p></div></div><p class=MsoNormal><span style='mso-bookmark:_MailOriginal'><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><span style='mso-bookmark:_MailOriginal'><span lang=EN-IE style='mso-ansi-language:EN-IE'>3333</span></span><span lang=EN-IE style='mso-ansi-language:EN-IE'><o:p></o:p></span></p></div></body></html>\"},\"caption\":\"Details\",\"height\":200},\"attachments\":[],\"entryid\":null,\"urls\":[],\"addresses\":null,\"sentItem\":true,\"receivedDateTime\":{\"year\":2021,\"month\":2,\"day\":11,\"hour\":13,\"minute\":54,\"second\":6,\"raw\":\"2021-02-11T13:54:06.1595789+00:00\",\"rawutc\":\"2021-02-11T13:54:06.1595789Z\",\"TZ\":{\"StandardName\":\"GMT Standard Time\",\"DaylightName\":\"GMT Daylight Time\"}},\"sentDateTime\":{\"year\":2021,\"month\":2,\"day\":11,\"hour\":13,\"minute\":54,\"second\":6,\"raw\":\"2021-02-11T13:54:06.1595789+00:00\",\"rawutc\":\"2021-02-11T13:54:06.1595789Z\",\"TZ\":{\"StandardName\":\"GMT Standard Time\",\"DaylightName\":\"GMT Daylight Time\"}},\"companies\":null}]}";
	//datastringObj=JSON.parse(datastring);
}
if (datastringObj!=null)
{
	Glog("filesentemail datastringObj:");
	//we do this to get the altered subject....and the context is set also
	var emailalt=datastringObj.EmailList[0];
	email.subject=emailalt.subject.value;
	entity=datastringObj.screenMetadata.entity;
	entityid=datastringObj.screenMetadata.entityid;
	Glog("filesentemail datastringObj #1 entity:"+entity);
	Glog("filesentemail datastringObj #1 entityid:"+entityid);
}

//if no entity defined we parse the email
if ((!Defined(entity))||(entity==""))
{
	Glog("filesentemail parse the email subject:"+email.subject);
	//check for a tag
	var _sentemailtag=extractTag(email.subject);
	if ((_sentemailtag.entity=="")||(_sentemailtag.entity==null))
	{
		Glog("filesentemail parse the email body:"+email.body);
	  _sentemailtag=extractTag(email.body);
	}
	if ((_sentemailtag.entity=="")||(_sentemailtag.entity==null))
	{
		Glog("Nothing found..parsing email...");
		Glog(JSON.stringify(email));
	}
	Glog("filesentemail _sentemailtag:"+JSON.stringify(_sentemailtag));
	if ((_sentemailtag.entity=="")||(_sentemailtag.entity==null))
	{
		Glog("filesentemail no tag found");
		//search based on the email
		var ede=getEmailDataEntity(email);
		entity=ede.entity;
		entityid=ede.entityid;	
	}else{
		//set entity based on tag
		entity=_sentemailtag.entity;
		entityid=_sentemailtag.entityid;	
	}
	Glog("filesentemail datastringObj #2 entity:"+entity);
	Glog("filesentemail datastringObj #2 entityid:"+entityid);	
	Glog("filesentemail datastringObj #2 entityTag:"+_sentemailtag.entityTag);	
}

var fileentity=entity;
var fileentityid=entityid;

var Comm_From=email.from.displayName+"<"+email.from.emailAddress+">";
var Comm_HasAttachments="";
if (email.attachments.length>0)
{
  Comm_HasAttachments="Y";
}
var Comm_TO="";
if (email.to)
{
	for(var ee=0;ee<email.to.length;ee++)
	{
		if (Comm_TO!="")
		  Comm_TO+=";";
		var _rec=email.to[ee];
		Comm_TO+=_rec.displayName+"<"+_rec.emailAddress+">";
	}
}
var Comm_CC="";
if (email.cc)
{
	for(var ee=0;ee<email.cc.length;ee++)
	{
		if (Comm_CC!="")
		  Comm_CC+=";";
		var _rec=email.cc[ee];
		Comm_CC+=_rec.displayName+"<"+_rec.emailAddress+">";
	}
}
var Comm_BCC="";
if (email.bcc)
{
	for(var ee=0;ee<email.bcc.length;ee++)
	{
		if (Comm_BCC!="")
		  Comm_BCC+=";";
		var _rec=email.bcc[ee];
		Comm_BCC+=_rec.displayName+"<"+_rec.emailAddress+">";
	}
}
var Comm_Description=email.subject;
var Comm_Subject=email.subject;
var comm_outlookEntryID=email.entryid; 
Glog("filesentemail comm_outlookEntryID:"+comm_outlookEntryID);
var Comm_Note=email.body;
var Comm_Email=email.htmlBody;
var Comm_IsHtml="Y";
//defaults
var dataObj={entity:fileentity, entityid:fileentityid}
Glog("filesentemail dataObj :"+JSON.stringify(dataObj));
var assignmentObject=getAssignmentObject(dataObj);
Glog("filesentemail assignmentObject :"+JSON.stringify(assignmentObject));
var cdate = new Date(email.receivedDateTime.year, email.receivedDateTime.month-1, email.receivedDateTime.day, email.receivedDateTime.hour, email.receivedDateTime.minute, email.receivedDateTime.second);

var Comm_ChannelId=CRM.GetContextInfo("user","user_primarychannelid");
var Comm_Type = "Email";
var Comm_Action	= "EmailOut";//always sent
var Comm_Status	= "Complete";
var Comm_Priority = "Normal";	
var Comm_DateTime =cdate.getVarDate();
var Comm_Private="";
var Comm_SecTerr=assignmentObject.territory;
	
var CmLi_Comm_UserID=CRM.GetContextInfo("user","user_userid");

//create communication
var cdate = new Date();
var new_comm = eWare.CreateRecord("Communication");
new_comm("Comm_From") = Comm_From;
new_comm("Comm_TO") = Comm_TO;
new_comm("Comm_CC") = Comm_CC;
new_comm("Comm_BCC") = Comm_BCC;
new_comm("Comm_Type") = Comm_Type;
new_comm("Comm_Action") = Comm_Action;
if (Comm_Subject==null)
  Comm_Subject="";
new_comm("Comm_Subject") = Comm_Subject;	
new_comm("comm_outlookEntryID") = comm_outlookEntryID;	
if (Comm_Description==null)
  Comm_Description="";
new_comm("Comm_description") = Comm_Description;
new_comm("Comm_note") = Comm_Note;	
new_comm("Comm_Email") = Comm_Email;	
new_comm("Comm_IsHtml") = Comm_IsHtml;	
new_comm("Comm_Status") = Comm_Status;	
new_comm("Comm_datetime") = Comm_DateTime;
new_comm("Comm_Priority") = Comm_Priority;
new_comm("Comm_Private") = Comm_Private;
new_comm("Comm_ChannelId") = Comm_ChannelId;
new_comm("Comm_SecTerr") = Comm_SecTerr;
//crm primary entity
var contextfield=getCommContextField(fileentity);
if (contextfield!="")
{
	new_comm(contextfield) = fileentityid;
}
if (true && (datastringObj!=null))
{
    Glog("filesentemail comm_screen_metadata:");
	//now we grab any "custom" fields
	var comm_screen_metadata=datastringObj.screenMetadata.screensetup.comm_screen_metadata.screenMetadata.screens[0].formElements;
		
	if (comm_screen_metadata)
	{
	  for(var j=0;j<comm_screen_metadata.length;j++)
	  {
		new_comm(comm_screen_metadata[j].name) = getCreateFieldValue(comm_screen_metadata[j]);
	  }
	}
}
new_comm.SaveChanges();	
		updateEntityByFields("communication", new_comm.RecordId);
Glog("filesentemail new communication :"+new_comm.RecordId);

//create comm link 
var new_link = eWare.CreateRecord( "Comm_Link" );	   
new_link("CmLi_Comm_userId" ) = CmLi_Comm_UserID;
//person and company
if (fileentity=="person")
{
   new_link("CmLi_Comm_PersonId")=assignmentObject.personid; 
}else{
	//check is the email from or sent to a person in the company
	var ede=getEmailDataEntity(email);
	ede_entity=ede.entity;
	ede_entityId=ede.entityid;	
	if (ede_entity=="person") 
      new_link("CmLi_Comm_PersonId")=ede_entityId; 
}
new_link("cmli_comm_companyid")=assignmentObject.companyid; 
new_link("CmLi_Comm_CommunicationId" ) = new_comm.RecordId;
new_link.SaveChanges();
		updateEntityByFields("Comm_Link", new_link.RecordId);
Glog("filesentemail new comm_link :"+new_link.RecordId);

//attachments...create library record...
var attachmentlinks=[];

if (email.attachments.length>0)
{
    var libr_category=GetWebConfigValue("libr_category");
    var libr_status=GetWebConfigValue("libr_status");
    var libr_type=GetWebConfigValue("libr_type");
	for (var ll=0;ll<email.attachments.length;ll++)
	{
		var _att=email.attachments[ll];		

		if (_att.value)
		{
			var new_doc= eWare.CreateRecord("Library");
			//set defaults
			new_doc("libr_category" ) = libr_category;
			new_doc("libr_status" ) = libr_status;
			new_doc("libr_type" ) = libr_type;
			
			var librentityfield="";
			if (librentityfield=="")
			{
				librentityfield="libr_"+fileentity+"id";
				if (fileentity.toLowerCase()=="cases")
				  librentityfield="libr_caseid";
			}
			if (librentityfield!="")
			{
			  new_doc(librentityfield)=fileentityid;
			  var _personField="libr_personid";
			  var _companyField="libr_companyid";
			  if (fileentity=="person")
			  {
				  if (assignmentObject.personid)
					new_doc(_personField)=assignmentObject.personid;
			  }else{
			    //is the person in the email?
				if (ede_entity=="person")
					new_link("CmLi_Comm_PersonId")=ede_entityId; 
			  }
			  if (assignmentObject.companyid)
			    new_doc(_companyField)=assignmentObject.companyid;
			}
			var _entitypath=getEntityPath(fileentity,fileentityid,new_comm.RecordId);
		
			new_doc("Libr_FilePath" ) = _entitypath;
			new_doc("Libr_FileName" ) = _att.name;
			new_doc("Libr_Entity" ) = fileentity;
			new_doc("Libr_FileSize" ) = _att.size;
			new_doc("libr_communicationId" ) = new_comm.RecordId;
			if (true && (datastringObj!=null))
			{
				//custom values
				Glog("filesentemail library_screen_metadata:");
				var library_screen_metadata=datastringObj.screenMetadata.screensetup.library_screen_metadata.screenMetadata.screens[0].formElements;
				if (library_screen_metadata)
				{
				  for(var j=0;j<library_screen_metadata.length;j++)
				  {
					new_doc(library_screen_metadata[j].name) = getCreateFieldValue(library_screen_metadata[j]);
				  }
				}
			}
			//new_doc.SaveChangesNoTLS();
			new_doc.SaveChanges();
			updateEntityByFields("Library", new_doc.RecordId);
			var uploadlink=getCRMProtocol()+get_SERVER_NAME()+"/"+
				CRM.Url("sagecrmws/ac2020fupload.aspx")+					
				"&id="+new_doc.RecordId+"&path="+getLibraryRootPath()+"\\"+replaceAll(escape(_entitypath),'\\', '\\\\')+"&type="+_att.type;;
			
			//holding file..used on actual upload
			createFolder(getLibraryRootPath()+"\\"+_entitypath);
			Glog("Library createFolder: OK");
			createFileFullPath(getLibraryRootPath()+"\\"+_entitypath+"\\"+new_doc.RecordId,"");
			Glog("Library createFileFullPath: OK");
			
			if (false)
			  uploadlink="http://localhost:1898/ac2020fupload.aspx?"+
				"&id="+new_doc.RecordId+"&path="+getLibraryRootPath()+"\\"+replaceAll(_entitypath,'\\', '\\\\')+"&type="+_att.type;
			
			attachmentlinks.push({senderid:_att.id,name:_att.name, id:new_doc.RecordId,link:uploadlink, type:_att.type});
			
		}
	}
}

var res={
  "screenMetadata": {
  },
  "data": {
	"attachmentlinks":attachmentlinks,
	"customproperties":[{
		name:"CRM Status",
		value:"Filed"},
		{name:"CRM Filed To",
		value:getEntityDesc(fileentity,fileentityid)},
		{name:"CRM Filed Entity",
		value:fileentity},
		{name:"CRM Comm ID",
		value:new_comm.RecordId},
		{name:"CRM Filed By",
		value:CRM.GetContextInfo("user","user_firstname")+" "+CRM.GetContextInfo("user","user_lastname")}
	]
  }
}
res=JSON.stringify(res);
Response.Write(res);
Glog("filesentemail res:"+res);
%>