<!-- #include file ="reportobjects.js" -->
<%

var entity=new String(Request.Querystring("entity"));
entity=entity.toLowerCase();
var entityid=Request.Querystring("id");
////////////////////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////
var myreport= JSON.clone(_reportClass);
myreport.name="relationship";
//title
myreport.title="Relationships";
////////////////////////////////////////////////////////////////////////////////////////////
var entities=["company","person","opportunity","case"];
if (entity=="cases")
    entity="case";
	for(var i=0;i<entities.length;i++)
	{
		var relSQL="select * from vListRelatedEntityReportData where "+
			"rend_entity1 = '"+entity+"' and rend_entity2 = '"+entities[i]+"' "+
			"and rend_Entity1Id="+entityid;			

		var samplelist=JSON.clone(_reportItem);
		samplelist.name=entity+'listchild';
		samplelist.componenttype='list';
		var qsamplelist=CRM.CreateQueryObj(relSQL);
		qsamplelist.SelectSQL();
		if (!qsamplelist.eof)
		{
			samplelist.data=getListSectionRel(qsamplelist, entity, entities[i], ["rend_Entity2","rend_relationship","rend_Type","rend_Notes"],true);
			myreport.reportdetails.push(samplelist);
		}
	}

////////////////////////////////////////////////////////////////////////////////////////////
Response.Write(JSON.stringify(myreport));

%>