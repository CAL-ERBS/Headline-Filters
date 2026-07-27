<%
//notes.js
//notes functions
function get_Note_ForeignTableId(entity)
{
	var res=getTableInfo(entity);
	return res.tableId;
}

%>