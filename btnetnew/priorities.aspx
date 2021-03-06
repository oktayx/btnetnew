<%@ Page language="C#" MasterPageFile="~/btnetui.Master"%>
<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<title id="titl" runat="server">btnet priorities</title>
<script type="text/javascript" lang="JavaScript" src="sortable.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<% security.write_menu2(Response, "admin"); %>

<div class=align>
<a href=edit_priority.aspx>add new priority</a>
<p>
<%

    
if (ds.Tables[0].Rows.Count > 0)
{
	SortableHtmlTable.create_from_dataset(
		Response, ds, "edit_priority.aspx?id=", "delete_priority.aspx?id=", false);

}
else
{
	Response.Write ("No priorities in the database.");
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
		+ "priorities";

	ds = DbUtil.get_dataset (
		@"select pr_id [id],
		pr_name [description],
		pr_sort_seq [sort seq],
		'<div style=''background:' + pr_background_color + ';''>' + pr_background_color + '</div>' [background<br>color],
		pr_style [css<br>class],
		case when pr_default = 1 then 'Y' else 'N' end [default],
		pr_id [hidden] from priorities");

}


</script>
