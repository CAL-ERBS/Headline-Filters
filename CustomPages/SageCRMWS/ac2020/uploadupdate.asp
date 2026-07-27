<!-- #include file ="sagecrm.js" -->
<!-- #include file ="json2.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="xcommon.js" -->
<% 
	function getCompanyFolder(companyid)
	{
		var res="";
		if ((companyid=="") ||(!Defined(companyid)))
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
	function getEntityPath(compid)
	{
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
		var xx=getLibraryRootPath() +"\\" + libr_path;
		xx=	replaceAll(xx,'\\\\', '\\');
		createFolder(xx);	
		return libr_path;
	}
	
	function xdbg(msg){
	  if (true)
	    Response.Write(msg+"<br>");
	}
		
	var Libr_FilePath=Request.QueryString("FilePath");
	var Libr_FileName=Request.QueryString("FileName");
	var commid = Request.QueryString("commid");
	var newLibrary = CRM.CreateRecord("Library");
	var comm = CRM.FindRecord("Communication,vCommunication", "comm_communicationid=" + commid);
	var fileSize=0;

		var _path=getEntityPath(comm("CmLi_Comm_CompanyId"), comm("CmLi_Comm_PersonId"),commid);
		//move the file...
		var strPathFolder = new String(Server.mappath("data"));
		
		strPathFolder = new String(Server.mappath("data") + "\\Commid" + commid);
		
		var tmpPathToBeDeleted=strPathFolder;
		strPathFolder = strPathFolder.toLowerCase().replace("wwwroot\\custompages\\sagecrmws\\ac2020\\data", "Library\\DataUpload");
		//Response.Write("after replace ----" + strPathFolder)
		//Response.End();
		Glog("***strPathFolder2***:"+strPathFolder);
		
		var strPath = strPathFolder + "\\" + Libr_FileName;
		Glog("***strPath***:"+strPath);
		//Response.Write(strPath)
		//Response.End();
		var crmfolderpath=_path + "\\Commid" + commid;
		Glog("***crmfolderpath***:"+crmfolderpath);
		var newstrFolder = getLibraryRootPath()+"\\"+_path + "\\Commid" + commid;
		Glog("***newstrFolder***:"+newstrFolder);
		newstrFolder=replaceAll(newstrFolder,'\\\\', '\\');
		Glog("***newstrFolder2***:"+newstrFolder);
		if (!FolderExists(newstrFolder))
		{
		Glog("***FolderExists false***:");
			createFolder(newstrFolder);
			Glog("***createFolder***:");
		}
		var newstrPath = newstrFolder + "\\" + Libr_FileName;
		
		Glog("***newstrPath***:"+newstrPath);
		xdbg(strPath);
		xdbg(newstrPath);
		
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		var mfdone=fso.MoveFile(strPath,newstrPath);

		objFile = fso.GetFile(newstrPath)
		fileSize = objFile.Size

		var objFolder = fso.GetFolder(strPathFolder);
		//last one deletes the comms folder
		xdbg("objFolder.Files.Count:"+objFolder.Files.Count);
		Glog("***objFolder.Files.Count***:"+objFolder.Files.Count);
		if (objFolder.Files.Count==0){
		    xdbg("Delete folder:"+strPathFolder);
			Glog("***Delete.folder***:"+strPathFolder);
			fso.DeleteFolder(strPathFolder);
		}

var entity = new String(Request.QueryString("entity")).toLowerCase();
var entityId = Request.QueryString("Id");

newLibrary.libr_filepath= crmfolderpath;
newLibrary.libr_filename= Libr_FileName;
newLibrary.libr_entity=entity;
newLibrary.libr_companyid=comm("CmLi_Comm_CompanyId");
newLibrary.libr_personid=comm("CmLi_Comm_PersonId");
newLibrary.libr_filesize=fileSize;

if (entity=='opportunity') {
	newLibrary.libr_opportunityid=entityId;
	oppo = CRM.FindRecord("Opportunity", "oppo_opportunityid=" + entityId);
	newLibrary.libr_companyid=oppo("oppo_primarycompanyid");
	newLibrary.libr_personid=oppo("oppo_primarypersonid");
}
else if (entity == 'lead') {
	newLibrary.libr_leadid=entityId;
	lead = CRM.FindRecord("Lead", "lead_leadid=" + entityId);
	newLibrary.libr_companyid=lead("lead_primarycompanyid");
	newLibrary.libr_personid=lead("lead_primarypersonid");
}
else if (entity == 'cases') {
	newLibrary.libr_caseid=entityId;
	caseRecord = CRM.FindRecord("Cases", "case_caseid=" + entityId);
	newLibrary.libr_companyid=caseRecord("case_primarycompanyid");
	newLibrary.libr_personid=caseRecord("case_primarypersonid");
}

newLibrary.libr_communicationid=commid;
newLibrary.libr_type=GetWebConfigValue("libr_type");
newLibrary.libr_status=GetWebConfigValue("libr_status");
newLibrary.libr_active="Y";
newLibrary.libr_category= GetWebConfigValue("libr_category");
newLibrary.libr_userid=getUserId();
newLibrary.libr_note=Defined(comm("comm_note")) ?  comm("comm_note") : Libr_FileName;
newLibrary.SaveChangesNoTls();



xdbg("done");
Response.Clear();	
Response.Write("Communication Created<br/><br/>");
Response.Write("returning to form...");
Glog("***END SCRIPT***:");
%>
<script>
var _timerx=1000;
function backToForm()
{
	window.location="<%=_crmUrl('recording.asp','entity='+entity+"&id="+entityId)%>";	
}
setTimeout(backToForm, _timerx);
</script>