<%@ Page language="C#" MasterPageFile="~/btnetui.Master" %>
<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<title id="titl" runat="server">btnet admin</title>
<link rel="StyleSheet" href="btnet.css" type="text/css">
<script>

var nagspan
var color
var hex_chars = "0123456789ABCDEF"

function decimal_to_hex(dec)
{
	var result = 
		hex_chars.charAt(Math.floor(dec / 16))
		+ hex_chars.charAt(dec % 16)
	return result
}

function RGB2HTML(red, green, blue)
{
	var rgb = "#"
	rgb += String(decimal_to_hex(red));
	rgb += String(decimal_to_hex(green));
	rgb += String(decimal_to_hex(blue));
	return rgb
}

function start_animation()
{
	nagspan = document.getElementById("nagspan")
// cc = 204, 66 = 102
	color = 1
	timer = setInterval(timer_callback,5)
}

function timer_callback()
{
	color += 1
	
	new_color = RGB2HTML(255, color * 2, color)
	
	nagspan.style.background = new_color
	
	if (color == 102) // if the color is now orange
	{
		clearInterval(timer)
	}
}

</script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<% security.write_menu2(Response, "admin"); %>

<div class=align><table border=0><tr><td>
<ul>
<p>
<li class=listitem><a href=users.aspx>Users</a>
<p>
<li class=listitem><a href=orgs.aspx>Organizations</a>
<p>
<li class=listitem><a href=projects.aspx>Projects</a>
<p>
<li class=listitem><a href=categories.aspx>Categories</a>
<p>
<li class=listitem><a href=priorities.aspx>Priorities</a>
<p>
<li class=listitem><a href=statuses.aspx>Statuses</a>
<p>
<li class=listitem><a href=udfs.aspx>User Defined Attribute</a>
&nbsp;&nbsp;<span class=smallnote>(see "ShowUserDefinedBugAttribute" and "UserDefinedBugAttributeName" in Web.config)</span>
<p>
<li class=listitem><a href=customfields.aspx>Custom Fields</a>
&nbsp;&nbsp;<span class=smallnote>(add custom fields to the bug page)</span>
<p>
<li class=listitem><a target=_blank href=query.aspx>Run Ad-hoc Query</a>
    &nbsp;&nbsp;
    <span style="border: solid red 1px; padding: 2px; margin: 3px; color: red; font-size: 9px;">
    This links to query.aspx.&nbsp;&nbsp;Query.aspx is potentially unsafe.&nbsp;&nbsp;Delete it if you are deploying on a public web server.
    </span><br>
<p>
<li class=listitem><a href=notifications.aspx>Queued Email Notifications</a>
<p>
<li class=listitem><a href=edit_custom_html.aspx>Edit Custom Html</a>
<p>
<li class=listitem><a href=edit_web_config.aspx>Edit Web.Config</a>
    &nbsp;&nbsp;
    <span style="border: solid red 1px; padding: 2px; margin: 3px; color: red; font-size: 9px;">
    Many BugTracker.NET features are configurable by editing Web.config, but please be careful!  Web.config is easy to break!
    </span><br>
<p>
<li class=listitem><a href=backup_db.aspx>Backup Database</a>
<p>
<li class=listitem><a href=manage_logs.aspx>Manage Logs</a>
</ul>
</td></tr></table>
<p>&nbsp;<p>
<p>Server Info:
<%
Response.Write ("<br>Path=");
Response.Write (HttpContext.Current.Server.MapPath(null));
Response.Write ("<br>MachineName=");
Response.Write (HttpContext.Current.Server.MachineName);
Response.Write ("<br>ScriptTimeout=");
Response.Write (HttpContext.Current.Server.ScriptTimeout);
Response.Write ("<br>.NET Version=");
Response.Write(Environment.Version.ToString());
Response.Write ("<br>CurrentCulture=");
Response.Write(System.Threading.Thread.CurrentThread.CurrentCulture.Name);

%>

</div>
<% Response.Write(Application["custom_footer"]); %>
</asp:Content>


<script language="C#" runat="server">

Security security;

///////////////////////////////////////////////////////////////////////
void Page_Load(Object sender, EventArgs e)
{
	Util.do_not_cache(Response);
	
	security = new Security();
	security.check_security( HttpContext.Current, Security.MUST_BE_ADMIN);

	titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - " + "admin";		
}


</script>
