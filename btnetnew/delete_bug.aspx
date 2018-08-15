<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>

<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<script language="C#" runat="server">

    String sql;

    Security security;

    void Page_Init(object sender, EventArgs e) { ViewStateUserKey = Session.SessionID; }

    ///////////////////////////////////////////////////////////////////////
    void Page_Load(Object sender, EventArgs e)
    {

        Util.do_not_cache(Response);


        security = new Security();
        security.check_security(HttpContext.Current, Security.ANY_USER_OK_EXCEPT_GUEST);

        if (security.user.is_admin || security.user.can_delete_bug)
        {
            //
        }
        else
        {
            Response.Write("You are not allowed to use this page.");
            Response.End();
        }

        string id = Util.sanitize_integer(Request["id"]);

        int permission_level = Bug.get_bug_permission_level(Convert.ToInt32(id), security);
        if (permission_level != Security.PERMISSION_ALL)
        {
            Response.Write("You are not allowed to edit this item");
            Response.End();
        }

        if (IsPostBack)
        {

            Bug.delete_bug(Convert.ToInt32(row_id.Value));
            Server.Transfer("bugs.aspx");

        }
        else
        {

            titl.InnerText = Util.get_setting("AppTitle", "BugTracker.NET") + " - "
                + "delete " + Util.get_setting("SingularBugLabel", "bug");

            back_href.HRef = "edit_bug.aspx?id=" + id;

            sql = @"select bg_short_desc from bugs where bg_id = $1";
            sql = sql.Replace("$1", id);

            DataRow dr = DbUtil.get_datarow(sql);

            confirm_href.InnerText = "confirm delete of "
                    + Util.get_setting("SingularBugLabel", "bug")
                    + ": "
                    + Convert.ToString(dr["bg_short_desc"]);

            row_id.Value = id;
        }

    }


</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
    <!-- #include file = "inc.aspx" -->
    <title id="titl" runat="server">btnet delete bug</title>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% security.write_menu2(Response, "admin"); %>

    <a id="back_href" runat="server" href="">back to <% Response.Write(Util.get_setting("SingularBugLabel", "bug")); %></a>

    <p>or</p>

    <script>
        function submit_form() {
            var frm = document.getElementById("frm");
            frm.submit();
            return true;
        }

    </script>
    <a class="btn btn-danger" id="confirm_href" runat="server" href="javascript: submit_form()"></a>
    <input type="hidden" id="row_id" runat="server">

    <% Response.Write(Application["custom_footer"]); %>
</asp:Content>
