<%

//file IO
function createFileFullPath(fullpath, msg) {
	if (GetWebConfigValue("lockedsystem")=="Y")
	{
		return createFile2(fullpath,false);
	}else{
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		thefile=fso.CreateTextFile(fullpath,"false");
		thefile.WriteLine(msg);
		thefile.Close();
		return true;
	}
	return false;
}

function createFile(fname, msg) {

    var fso = new ActiveXObject("Scripting.FileSystemObject");
	var fsopath=Server.MapPath(".");
    thefile=fso.CreateTextFile(fsopath+"\\"+fname,false);
    thefile.WriteLine(msg);
    thefile.Close();
	fso=null;
}

function createFolder(path) {
	if (GetWebConfigValue("lockedsystem")=="Y")
	{
		return createFolder2(path);
	}else{
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		if (!fso.FolderExists(path))
			fso.CreateFolder(path);
		fso=null;
		return true;
	}
	return false;
}
function FolderExists(path) 
{
	var res=false;
	var myObject = new ActiveXObject("Scripting.FileSystemObject");
	if(myObject.FolderExists(path))
	{	
		res=true;
	}
	fso=null;
	return res;
}
function createFolder2(path) {
	var _url=getCRMProtocol()+Request.ServerVariables("SERVER_NAME")
		+":"+Request.ServerVariables("SERVER_PORT")+
		CRM.Url("sagecrmws/KonnexGateway.aspx")+isportalcode()+"action=setupFolder";
	//path=new String(path);
	path=path.replace(/\\\\\\/g, "\\");	
	path=path.replace(/\\\\/g, "\\");
	//dev line
	if (false)
		_url="http://localhost:1898/KonnexGateway.aspx?SID="+Request.QueryString("SID")+isportalcode()+"action=setupFolder";
    return posturl(_url,"path="+path);
}
function createFile2(path,overwrite) {
	var _url=getCRMProtocol()+Request.ServerVariables("SERVER_NAME")
			+":"+Request.ServerVariables("SERVER_PORT")+
			CRM.Url("sagecrmws/KonnexGateway.aspx")+isportalcode()+"action=createFile&overwrite="+overwrite;
	//path=new String(path);
	path=path.replace(/\\\\\\/g, "\\");	
	path=path.replace(/\\\\/g, "\\");
	//dev line
	if (false)
		_url="http://localhost:1898/KonnexGateway.aspx?SID="+Request.QueryString("SID")+isportalcode()+"action=createFile&overwrite="+overwrite;	
    return posturl(_url,"path="+path);
}
function writeout(fname, msg) {

    var fso = new ActiveXObject("Scripting.FileSystemObject"),
    thefile=fso.OpenTextFile(fname,8,true);

    thefile.WriteLine(msg);
    thefile.Close();
	fso=null;
}

function dbgX(msg) {

  //writeout("C:\\Program Files (x86)\\Sage\\CRM\\CRM\\WWWRoot\\CustomPages\\SageCRMWS\\ac2020\\logfs2.txt",msg+"\n");
}

function readallFile(path) {

    var fso = new ActiveXObject("Scripting.FileSystemObject"),
    thefile=fso.OpenTextFile(path,1,false);
    var res=thefile.ReadAll();
    thefile.Close();
	fso=null;
	return res;
}
function FileExists(path) 
{
	var res=false;
	var myObject = new ActiveXObject("Scripting.FileSystemObject");
	if(myObject.FileExists(path))
	{	
		res=true;
	}
	myObject=null;
	return res;
}

%>