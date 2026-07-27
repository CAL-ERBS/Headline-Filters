<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<%

var book_entityname=Request.Form("entity");

var table=getTableInfo(book_entityname);
if (!Defined(table.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
  throw "No valid Entity found";
}

var book_entityid=Request.Form("entityid");
entityid=new Number(book_entityid);
if (!isNumeric(entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
  throw "No valid Entity ID found";
}

//check we have a bookmark
var sql = "select * from Bookmarks WITH (NOLOCK) where " +
		"book_userid=" + getUserId() + " and book_deleted is null "+
		"and book_entityname='"+book_entityname+"' and book_entityid="+book_entityid;
	
var q=CRM.CreateQueryObj(sql);	

q.SelectSQL();
var testres="";
var entDesc="";
if (!q.eof)
{
	//remove it
	var delq=CRM.FindRecord("bookmarks","book_userid=" + getUserId() + " and book_deleted is null and book_entityname='"+book_entityname+"' and book_entityid="+book_entityid);
	delq.DeleteRecord = true;
	delq.SaveChangesNoTLS();
	testres="Removed";
}else{
	//add it...we are moving from our bookmarks..se we never add new items
	/*
	var addq=CRM.CreateRecord("bookmarks");
	addq("book_userid")=getUserId();
	addq("book_entityname")=book_entityname;
	addq("book_entityid")=book_entityid;
	entDesc=getEntityDesc(book_entityname,book_entityid)
	addq("book_title")=entDesc;
	addq.SaveChangesNoTLS();
	updateEntityByFields("bookmarks", addq.RecordId);
	testres="Added";	
	*/
}

//test to make sure it hasnt been removed...otherwise we just re-add it to favs
if (testres=="")
{
	var _table=getTableInfo(book_entityname);
	var sql2 = "select usrc_UserRecordsId from UserRecords WITH (NOLOCK) where usrc_Type='Favourites' and usrc_UserId=" + getUserId() +
			" and usrc_RecordId=" + book_entityid + " and usrc_EntityId="+_table.tableId +" ";//and usrc_Deleted is null...alas not used here
	var q2=CRM.CreateQueryObj(sql2);	

	q2.SelectSQL();
	var testres="";
	var entDesc="";
	if (!q2.eof)
	{
		//remove it
		var delq=CRM.FindRecord("UserRecords","usrc_UserRecordsId=" + q2("usrc_UserRecordsId"));
		delq.DeleteRecord = true;
		delq.SaveChangesNoTLS();
		//hard delete needed
		CRM.ExecSQL("delete from UserRecords where usrc_UserRecordsId=" + q2("usrc_UserRecordsId"));
		testres="Removed";
	}else{
		var addq=CRM.CreateRecord("UserRecords");
		addq("usrc_Type")="Favourites";
		addq("usrc_UserId")=getUserId();
		addq("usrc_RecordId")=book_entityid;
		addq("usrc_EntityId")=_table.tableId;
		addq.SaveChangesNoTLS();
		updateEntityByFields("UserRecords", addq.RecordId);
		testres="Added";	
	}
}

var res={
  "screenMetadata": {
		"lang": getUserLang(),
		"sql":sql,
		"book_userid":getUserId(),
		"book_entityname":""+book_entityname,
		"book_entityid":""+book_entityid,
		"book_title":entDesc
  },
  "data": {
		"result":testres
	}
}
res=JSON.stringify(res);
Response.Write(res);
%>