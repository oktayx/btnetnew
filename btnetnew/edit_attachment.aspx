<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>

<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<script language="C#" runat="server">

    int id;
    int bugid;
    String sql;


    Security security;

    void Page_Init(object sender, EventArgs e) { ViewStateUserKey = Session.SessionID; }


    ///////////////////////////////////////////////////////////////////////
    void Page_Load(Object sender, EventArgs e)
    {

        Util.do_not_cache(Response);

        security = new Security();

        security.check_security(HttpContext.Current, Security.ANY_USER_OK_EXCEPT_GUEST);

        if (security.user.is_admin || security.user.can_edit_and_delete_posts)
        {
            //
        }
        else
        {
            Response.Write("You are not allowed to use this page.");
            Response.End();
        }


        titl.InnerText = Util.get_setting("AppTitle", "BugTracker.NET") + " - "
            + "edit attachment";

        msg.InnerText = "";

        string var = Request.QueryString["id"];
        id = Convert.ToInt32(var);

        var = Request.QueryString["bug_id"];
        bugid = Convert.ToInt32(var);

        int permission_level = Bug.get_bug_permission_level(bugid, security);
        if (permission_level != Security.PERMISSION_ALL)
        {
            Response.Write("You are not allowed to edit this item");
            Response.End();
        }


        if (security.user.external_user || Util.get_setting("EnableInternalOnlyPosts", "0") == "0")
        {
            internal_only.Visible = false;
            internal_only_label.Visible = false;
        }

        if (!IsPostBack)
        {

            // Get this entry's data from the db and fill in the form

            sql = @"select bp_comment, bp_file, bp_hidden_from_external_users from bug_posts where bp_id = $1";
            sql = sql.Replace("$1", Convert.ToString(id));
            DataRow dr = DbUtil.get_datarow(sql);

            // Fill in this form
            desc.Value = (string)dr["bp_comment"];
            filename.InnerText = (string)dr["bp_file"];
            internal_only.Checked = Convert.ToBoolean((int)dr["bp_hidden_from_external_users"]);

        }
        else
        {
            on_update();
        }

    }


    ///////////////////////////////////////////////////////////////////////
    Boolean validate()
    {

        Boolean good = true;

        return good;
    }

    ///////////////////////////////////////////////////////////////////////
    void on_update()
    {

        Boolean good = validate();

        if (good)
        {

            sql = @"update bug_posts set
			bp_comment = N'$1',
			bp_hidden_from_external_users = $internal
			where bp_id = $3";

            sql = sql.Replace("$3", Convert.ToString(id));
            sql = sql.Replace("$1", desc.Value.Replace("'", "''"));
            sql = sql.Replace("$internal", Util.bool_to_string(internal_only.Checked));

            DbUtil.execute_nonquery(sql);

            if (!internal_only.Checked)
            {
                Bug.send_notifications(Bug.UPDATE, bugid, security);
            }

            Response.Redirect("edit_bug.aspx?id=" + Convert.ToString(bugid));

        }
        else
        {
            msg.InnerText = "Attachment was not updated.";
        }

    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
    <!-- #include file = "inc.aspx" -->
    <title id="titl" runat="server">btnet edit attachment</title>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% security.write_menu2(Response, Util.get_setting("PluralBugLabel", "bugs")); %>


    <a href="edit_bug.aspx?id=<% Response.Write(Convert.ToString(bugid));%>">back to <% Response.Write(Util.get_setting("SingularBugLabel", "bug")); %></a>
    <table class="table">

        <tr>
            <td class="lbl">Description:</td>
            <td>
                <input runat="server" type="text" class="form-control" id="desc" maxlength="80" size="80"></td>
            <td runat="server" class="err" id="desc_err">&nbsp;</td>
        </tr>

        <tr>
            <td class="lbl">Filename:</td>
            <td><b><span id="filename" runat="server">&nbsp;</span></b></td>
            <td>&nbsp;</td>
        </tr>


        <tr>
            <td colspan="3">
                <asp:CheckBox runat="server" class="cb" ID="internal_only" />
                <span runat="server" id="internal_only_label">Visible to internal users only</span>
            </td>
        </tr>


        <tr>
            <td colspan="3" align="left">
                <span runat="server" class="err" id="msg">&nbsp;</span>
            </td>
        </tr>

        <tr>
            <td colspan="2" align="center">
                <input runat="server" class="btn btn-info" type="submit" id="sub" value="Update">
        </tr>
    </table>

    <% Response.Write(Application["custom_footer"]); %>
</asp:Content>



