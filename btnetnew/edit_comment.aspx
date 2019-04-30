<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" ValidateRequest="false" %>

<script language="C#" runat="server">

    int id;
    String sql;


    Security security;

    bool use_fckeditor = false;
    int bugid;

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
            + "edit comment";

        msg.InnerText = "";

        id = Convert.ToInt32(Request["id"]);

        if (!IsPostBack)
        {
            sql = @"select bp_comment, bp_type,
        isnull(bp_comment_search,bp_comment) bp_comment_search,
        isnull(bp_content_type,'') bp_content_type,
        bp_bug, bp_hidden_from_external_users
        from bug_posts where bp_id = $id";
        }
        else
        {
            sql = @"select bp_bug, bp_type,
        isnull(bp_content_type,'') bp_content_type,
        bp_hidden_from_external_users
        from bug_posts where bp_id = $id";
        }

        sql = sql.Replace("$id", Convert.ToString(id));
        DataRow dr = DbUtil.get_datarow(sql);

        bugid = (int)dr["bp_bug"];

        int permission_level = Bug.get_bug_permission_level(bugid, security);
        if (permission_level == Security.PERMISSION_NONE
        || permission_level == Security.PERMISSION_READONLY
        || (string)dr["bp_type"] != "comment")
        {
            Response.Write("You are not allowed to edit this item");
            Response.End();
        }

        string content_type = (string)dr["bp_content_type"];

        if (security.user.use_fckeditor && content_type == "text/html" && Util.get_setting("DisableFCKEditor", "0") == "0")
        {
            use_fckeditor = true;
        }
        else
        {
            use_fckeditor = false;
        }

        if (security.user.external_user || Util.get_setting("EnableInternalOnlyPosts", "0") == "0")
        {
            internal_only.Visible = false;
            internal_only_label.Visible = false;
        }

        if (!IsPostBack)
        {
            internal_only.Checked = Convert.ToBoolean((int)dr["bp_hidden_from_external_users"]);

            if (use_fckeditor)
            {
                comment.Value = (string)dr["bp_comment"];
            }
            else
            {
                comment.Value = (string)dr["bp_comment_search"];
            }
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

        if (comment.Value.Length == 0)
        {
            msg.InnerText = "Comment cannot be blank.";
            return false;
        }

        return good;
    }

    ///////////////////////////////////////////////////////////////////////
    void on_update()
    {

        Boolean good = validate();

        if (good)
        {

            sql = @"update bug_posts set
                    bp_comment = N'$cm',
                    bp_comment_search = N'$cs',
                    bp_content_type = N'$cn',
                    bp_hidden_from_external_users = $internal
                where bp_id = $id

                select bg_short_desc from bugs where bg_id = $bugid";

            if (use_fckeditor)
            {
                string text = Util.strip_dangerous_tags(comment.Value);
                sql = sql.Replace("$cm", text.Replace("'", "&#39;"));
                sql = sql.Replace("$cs", Util.strip_html(comment.Value).Replace("'", "''"));
                sql = sql.Replace("$cn", "text/html");
            }
            else
            {
                sql = sql.Replace("$cm", HttpUtility.HtmlDecode(comment.Value).Replace("'", "''"));
                sql = sql.Replace("$cs", comment.Value.Replace("'", "''"));
                sql = sql.Replace("$cn", "text/plain");
            }

            sql = sql.Replace("$id", Convert.ToString(id));
            sql = sql.Replace("$bugid", Convert.ToString(bugid));
            sql = sql.Replace("$internal", Util.bool_to_string(internal_only.Checked));
            DataRow dr = DbUtil.get_datarow(sql);

            // Don't send notifications for internal only comments.
            // We aren't putting them the email notifications because it that makes it
            // easier for them to accidently get forwarded to the "wrong" people...
            if (!internal_only.Checked)
            {
                Bug.send_notifications(Bug.UPDATE, bugid, security);
                WhatsNew.add_news(bugid, (string)dr["bg_short_desc"], "updated", security);
            }


            Response.Redirect("edit_bug.aspx?id=" + Convert.ToString(bugid));

        }

    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
    <!-- #include file = "inc.aspx" -->

    <title id="titl" runat="server">btnet edit comment</title>

    <script type="text/javascript" language="JavaScript" src="jquery/jquery-1.3.2.min.js"></script>
    <script type="text/javascript" language="JavaScript" src="jquery/jquery-ui-1.7.2.custom.min.js"></script>
    <script type="text/javascript" language="JavaScript" src="jquery/jquery.textarearesizer.compressed.js"></script>
    <%  if (security.user.use_fckeditor)
        { %>
    <script type="text/javascript" src="ckeditor/ckeditor.js"></script>
    <% } %>

    <script>

        $(document).ready(do_doc_ready);

        function do_doc_ready() {

        <% 
            if (security.user.use_fckeditor)
            {
                //CKEditor update
                //Response.Write("CKEDITOR.replace( 'comment' )"); //OLD ck3.4.2
                Response.Write("loadCKEditor()"); //NEW ck5
            }
            else
            {
                Response.Write("$('textarea.resizable2:not(.processed)').TextAreaResizer()");
            }

	    %>	
        }

        function loadCKEditor() {
            ClassicEditor
            .create( document.querySelector( '#comment' ) )
            .catch( error => {
                console.error( error );
            } );
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% security.write_menu2(Response, Util.get_setting("PluralBugLabel", "bugs")); %>


    <a href="edit_bug.aspx?id=<% Response.Write(Convert.ToString(bugid));%>">back to <% Response.Write(Util.get_setting("SingularBugLabel", "bug")); %></a>

    <table border="0">
        <tr>
            <td colspan="3">
                <textarea rows="16" cols="80" runat="server" class="txt resizable" id="comment"></textarea>
            </td>
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
            </td>
        </tr>
    </table>

    <% Response.Write(Application["custom_footer"]); %>
</asp:Content>


