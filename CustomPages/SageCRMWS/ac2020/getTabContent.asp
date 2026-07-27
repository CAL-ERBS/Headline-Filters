<!-- #include file ="sagecrm.js" -->
<!-- #include file ="json2.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="tabContentList.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="notes.js" -->
<!-- #include file ="mergefunctions.js" -->
<%

if (!Defined(Request.Form))
{
	//this allows us to test parsing of the data..clever
	Response.Clear();
    Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="tab">Tab:</label><br>');
	Response.Write('<input type="text" id="tab" name="tab" value="Communications"><br>');
	Response.Write('<label for="Entity">Entity:</label><br>');
	Response.Write('<input type="text" id="entity" name="entity" value="company"><br>');
	Response.Write('<label for="EntityId">EntityId:</label><br>');
	Response.Write('<input type="text" id="entityid" name="entityid" value="43"><br>');
	Response.Write('<label for="page">Page:</label><br>');
	Response.Write('<input type="text" id="page" name="page" value="1"><br>');
	Response.Write('<label for="filters">Filters:</label><br>');
	Response.Write('<input type="text" id="filters" name="filters" value="null"><br>');
	Response.Write('<br><input type="submit" value="Submit">');
	Response.Write('<form>');
	Response.End();
}

var _formtab=Request.Form('tab');
_formtab=new String(_formtab);
var entity=Request.Form('entity');
entity=new String(entity);

var page=Request.Form('page');
if (((page+"")=="undefined")||(page==null)||(page==""))
  page=1;
page=new Number(page);

var clientsupportsPagination=true;
var itemsPerPage=Request.Form('itemsPerPage');
if (((itemsPerPage+"")=="undefined")||(itemsPerPage==null)||(itemsPerPage==""))
{
  itemsPerPage=100;
  clientsupportsPagination=false;
}
NumberOfRecordsReturned=new Number(itemsPerPage);

///////////////////////////////////////////////SORT BY
var sortBy=Request.Form('sortBy');
if (((sortBy+"")=="undefined")||(sortBy==null)||(sortBy=="")||(sortBy=="[]"))
  sortBy="";
sortBy=new String(sortBy);

if (sortBy.indexOf('["')==0)
{
  sortBy=sortBy.substring(2,sortBy.length-2);
}

///////////////////////////////////////////////SORT DIRECTION
var sortDesc=Request.Form('sortDesc');

if (((sortDesc+"")=="undefined")||(sortDesc==null)||(sortDesc=="")||(sortDesc=="[]"))
  sortDesc="";
sortDesc=new String(sortDesc);

if (sortDesc.indexOf('[')==0)
{
    sortDesc=sortDesc.substring(1,sortDesc.length-1);
	if (sortBy!="")
	{
	  if (sortDesc=="true")
		sortBy+=" desc";
	  else
		sortBy+=" asc";
	}
}
///////////////////////////////////////////////

var table=getTableInfo(entity);
   
if (sortBy && sortBy.toLowerCase().indexOf(table.prefix)==-1)
{
  sortBy="";//wipe it...it has to be wrong
}

var entityid=Request.Form('entityid');

entityid=new String(entityid);

var filters=Request.Form('filters');
var filtersObj=[];
if (!Defined(filters)||(!filters)){
  //first time in so get the screen
  filter=null;
}else{
  filtersObj=JSON.parse(filters);  
}
var res= null;
var appname=Request.Form('appname');

//get the data
var tableNameView=getTableNameView(entity);

//get tabs
var tabs=getScreenTabs(entity,entityid);
//get the content by figuring out the tab
for (var c=0;c<tabs.length;c++)
{
  var tabObject=tabs[c];
  tabObject.tabName=new String(tabObject.tabName);  
  if (tabObject.tabName.toLowerCase()==_formtab.toLowerCase())	
  {
    var tobj=getTabSearchObject(entity,entityid,tabObject,filtersObj);
	if (tabObject.tabOrder<2)
	{
		//summary page...
		var entity=Request.Form('entity');
		entity=new String(entity);
		var table=getTableInfo(entity);   
		var entityid=Request.Form('entityid');
		entityid=new String(entityid);
		//get the data
		var tableNameView=getTableNameView(entity);
		var q=CRM.Findrecord(tableNameView,"7201=7201 and "+table.idfield+"="+entityid);
		res=_selectEntity(entity,entityid,q);
	}else
	if ((tobj.entity!='')&&(tobj.whereclause!='')&&(tobj.whereclause!=null)&&(Defined(tobj.whereclause)))
	{	
		tobj.orderby=sortBy;
		res= getTabContentList(tobj,filtersObj,page,false);
	}else{
	//Response.Write(JSON.stringify(tobj)	);
	}
  }
}
var GLOBAL_TIMEEND = new Date().getTime();
if (res)
  res.time = GLOBAL_TIMEEND - GLOBAL_TIMESTART;

res=JSON.stringify(res);
Response.Write(res);


%>