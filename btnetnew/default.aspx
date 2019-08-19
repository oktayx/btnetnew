<%@ Page Language="C#" ValidateRequest="false" %>

<%--<%@ Import Namespace="System.Data.SqlClient" %>--%>
<!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
<!-- #include file = "inc.aspx" -->

<script language="C#" runat="server">

    string sql;

    ///////////////////////////////////////////////////////////////////////
    void Page_Load(Object sender, EventArgs e)
    {

        Util.set_context(HttpContext.Current);

        Util.do_not_cache(Response);

        titl.InnerText = Util.get_setting("AppTitle", "BugTracker.NET") + " - "
            + "logon";

        msg.InnerText = "";

        dbf.Default_CheckDB(msg);

        // Get authentication mode
        string auth_mode = Util.get_setting("WindowsAuthentication", "0");
        HttpCookie username_cookie = Request.Cookies["user"];
        string previous_auth_mode = "0";
        if (username_cookie != null)
        {
            previous_auth_mode = username_cookie["NTLM"];
        }

        // If an error occured, then force the authentication to manual
        if (Request.QueryString["msg"] == null)
        {
            // If windows authentication only, then redirect
            if (auth_mode == "1")
            {
                Util.redirect("loginNT.aspx", Request, Response);
            }

            // If previous login was with windows authentication, then try it again
            if (previous_auth_mode == "1" && auth_mode == "2")
            {
                Response.Cookies["user"]["name"] = "";
                Response.Cookies["user"]["NTLM"] = "0";
                Util.redirect("loginNT.aspx", Request, Response);
            }
        }
        else
        {
            if (Request.QueryString["msg"] != "logged off")
            {
                msg.InnerHtml = "Error during windows authentication:<br>"
                    + HttpUtility.HtmlEncode(Request.QueryString["msg"]);
            }
        }


        // fill in the username first time in
        if (!IsPostBack)
        {
            if (previous_auth_mode == "0")
            {
                if ((Request.QueryString["user"] == null) || (Request.QueryString["password"] == null))
                {
                    //	User name and password are not on the querystring.

                    if (username_cookie != null)
                    {
                        //	Set the user name from the last logon.

                        user.Value = username_cookie["name"];
                    }
                }
                else
                {
                    //	User name and password have been passed on the querystring.

                    user.Value = Request.QueryString["user"];
                    pw.Value = Request.QueryString["password"];

                    on_logon();
                }
            }
        }
        else
        {
            on_logon();
        }

    }

    ///////////////////////////////////////////////////////////////////////
    void on_logon()
    {

        string auth_mode = Util.get_setting("WindowsAuthentication", "0");
        if (auth_mode != "0")
        {
            if (user.Value.Trim() == "")
            {
                Util.redirect("loginNT.aspx", Request, Response);
            }
        }

        bool authenticated = Authenticate.check_password(user.Value, pw.Value);

        if (authenticated)
        {
            sql = "select us_id from users where us_username = N'$us'";
            sql = sql.Replace("$us", user.Value.Replace("'", "''"));
            DataRow dr = DbUtil.get_datarow(sql);
            if (dr != null)
            {
                int us_id = (int)dr["us_id"];

                Security.create_session(
                    Request,
                    Response,
                    us_id,
                    user.Value,
                    "0");

                Util.redirect(Request, Response);
            }
            else
            {
                // How could this happen?  If someday the authentication
                // method uses, say LDAP, then check_password could return
                // true, even though there's no user in the database";
                msg.InnerText = "User not found in database";
            }
        }
        else
        {
            msg.InnerText = "Invalid User or Password.";
        }

    }

</script>

<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1">

    <title id="titl" runat="server">btnet logon</title>
    <link rel="StyleSheet" href="btnet.css" type="text/css">
    <link rel="shortcut icon" href="favicon.ico">
    <link href="Content/bootstrap.min.css" rel="stylesheet" />

    <script src="Scripts/jquery-1.9.1.min.js"></script>
    <script src="Scripts/bootstrap.min.js"></script>
</head>
<body onload="document.forms[0].user.focus()">
    <table border="0">
        <tr>

            <%

                Response.Write(Application["custom_logo"]);

            %>
    </table>
    <div class="container-fluid" align="center" style="width: 400px;">

        <form class="frm1" runat="server">

            <div class="panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title"><strong>Login </strong></h3>
                </div>
                <div class="panel-body">
                    <div>
                        <label for="txtUsername">Username</label>
                        <input runat="server" type="text" class="form-control" id="user">
                    </div>
                    <br />
                    <div>
                        <label for="txtPassword">Password</label>
                        <input runat="server" type="password" class="form-control" id="pw">
                    </div>

                    <div style="padding: 10px 0px 0px;">
                        <input class="btn btn-primary" type="submit" value="Logon" runat="server" style="width: 150px;">
                    </div>
                    <span runat="server" class="err" id="msg">&nbsp;</span>
                </div>
            </div>

            <div align="center">
                <table class="table">
                    <tr>
                        <td>
                            <span>

                                <% if (Util.get_setting("AllowGuestWithoutLogin", "0") == "1")
                                    { %>
                                <p>
                                    <a style="font-size: 8pt;" href="bugs.aspx">Continue as "guest" without logging in</a>
                                <p>
                                    <% } %>

                                    <% if (Util.get_setting("AllowSelfRegistration", "0") == "1")
                                        { %>
                                <p>
                                    <a style="font-size: 8pt;" href="register.aspx">Register</a>
                                <p>
                                    <% } %>

                                    <% if (Util.get_setting("ShowForgotPasswordLink", "1") == "1")
                                        { %>
                                <p>
                                    <a style="font-size: 8pt;" href="forgot.aspx">Forgot your username or password?</a>
                                <p>
                                    <% } %>
                            </span>
                        </td>
                    </tr>
                </table>
            </div>
        </form>
    </div>

    <% Response.Write(Application["custom_welcome"]); %>
</body>
</html>
