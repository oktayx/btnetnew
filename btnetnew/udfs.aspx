<%@ Page language="C#" MasterPageFile="~/btnet.Master"%>
<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<title id="titl" runat="server">btnet user defined attributes</title>
<script type="text/javascript" language="JavaScript" src="sortable.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<% security.write_menu2(Response, "admin"); %>


<div class=align>
<a href=edit_udf.aspx>add new user defined attribute value</a>
<p>
<%
    

if (ds.Tables[0].Rows.Count > 0)
{
	SortableHtmlTable.create_from_dataset(
		Response, ds, "edit_udf.aspx?id=", "delete_udf.aspx?id=");

}
else
{
	Response.Write ("No user defined attributes in the database.");
}
%>
</div>
<% Response.Write(Application["custom_footer"]); %>

</asp:Content>

<script language="C#" runat="server">

DataSet ds;

Security security;

void Page_Load(Object sender, EventArgs e)
{

	Util.do_not_cache(Response);
	
	security = new Security();
	security.check_security( HttpContext.Current, Security.MUST_BE_ADMIN);

	titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
		+ "user defined attribute values";

	ds = DbUtil.get_dataset(
		@"select udf_id [id],
		udf_name [user defined attribute value],
		udf_sort_seq [sort seq],
		case when udf_default = 1 then 'Y' else 'N' end [default],
		udf_id [hidden]
		from user_defined_attribute order by udf_name");

}


</script>
