/*
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
*/

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using anmar.SharpMimeTools;
using System.Data;

namespace btnet
{

    public class MyPop3
    {
        public static int error_count = 0;
        public static string Pop3Server = Util.get_setting("Pop3Server", "pop.gmail.com");
        public static int Pop3Port = Convert.ToInt32(Util.get_setting("Pop3Port", "995"));
        public static bool Pop3UseSSL = Util.get_setting("Pop3UseSSL", "1") == "1";
        public static string Pop3ServiceUsername = Util.get_setting("Pop3ServiceUsername", "admin");
        public static int Pop3TotalErrorsAllowed = Convert.ToInt32(Util.get_setting("Pop3TotalErrorsAllowed", "100"));
        public static bool Pop3ReadInputStreamCharByChar = Util.get_setting("Pop3ReadInputStreamCharByChar", "0") == "1";

        public static string Pop3SubjectMustContain = Util.get_setting("Pop3SubjectMustContain", "");
        public static string Pop3SubjectCannotContain = Util.get_setting("Pop3SubjectCannotContain", "");
        public static string Pop3FromMustContain = Util.get_setting("Pop3FromMustContain", "");
        public static string Pop3FromCannotContain = Util.get_setting("Pop3FromCannotContain", "");

        public static bool Pop3DeleteMessagesOnServer = Util.get_setting("Pop3DeleteMessagesOnServer", "0") == "1";
        public static bool Pop3WriteRawMessagesToLog = Util.get_setting("Pop3WriteRawMessagesToLog", "0") == "1";

        //*************************************************************
        public static void start_pop3(System.Web.HttpApplicationState app)
        {
            System.Threading.Thread thread = new System.Threading.Thread(threadproc_pop3);
            thread.Start(app);
        }

        //*************************************************************

        public static bool fetch_messages(string project_user, string project_password, int projectid)
        {

            // experimental, under construction

            POP3Client.POP3client client = new POP3Client.POP3client(Pop3ReadInputStreamCharByChar);

            string[] SubjectCannotContainStrings = Util.rePipes.Split(Pop3SubjectCannotContain);
            string[] FromCannotContainStrings = Util.rePipes.Split(Pop3FromCannotContain);

            //try
            {
                System.Data.DataRow defaults = Bug.get_bug_defaults();

                //int projectid = (int)defaults["pj"];
                int categoryid = (int)defaults["ct"];
                int priorityid = (int)defaults["pr"];
                int statusid = (int)defaults["st"];
                int udfid = (int)defaults["udf"];

                Util.write_to_log("pop3:" + client.connect(Pop3Server, Pop3Port, Pop3UseSSL));

                Util.write_to_log("pop3:sending POP3 command USER");
                Util.write_to_log("pop3:" + client.USER(project_user));

                Util.write_to_log("pop3:sending POP3 command PASS");
                Util.write_to_log("pop3:" + client.PASS(project_password));

                Util.write_to_log("pop3:sending POP3 command STAT");
                Util.write_to_log("pop3:" + client.STAT());

                Util.write_to_log("pop3:sending POP3 command LIST");
                string list;
                list = client.LIST();
                Util.write_to_log("pop3:list follows:");
                Util.write_to_log(list);

                string[] messages = null;
                System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex("\r\n");
                messages = regex.Split(list);

                int end = messages.Length - 1;

                // loop through the messages
                for (int i = 1; i < end; i++)
                {
                    int space_pos = messages[i].IndexOf(" ");
                    int message_number = Convert.ToInt32(messages[i].Substring(0, space_pos));
                    string message_raw_string = client.RETR(message_number);

                    if (Pop3WriteRawMessagesToLog)
                    {
                        Util.write_to_log("raw email message:");
                        Util.write_to_log(message_raw_string);
                    }

                    SharpMimeMessage mime_message = MyMime.get_sharp_mime_message(message_raw_string);

                    string from_addr = MyMime.get_from_addr(mime_message);
                    string subject = MyMime.get_subject(mime_message);


                    if (Pop3SubjectMustContain != "" && subject.IndexOf(Pop3SubjectMustContain) < 0)
                    {
                        Util.write_to_log("skipping because subject does not contain: " + Pop3SubjectMustContain);
                        continue;
                    }

                    bool bSkip = false;

                    for (int k = 0; k < SubjectCannotContainStrings.Length; k++)
                    {
                        if (SubjectCannotContainStrings[k] != "")
                        {
                            if (subject.IndexOf(SubjectCannotContainStrings[k]) >= 0)
                            {
                                Util.write_to_log("skipping because subject cannot contain: " + SubjectCannotContainStrings[k]);
                                bSkip = true;
                                break;  // done checking, skip this message
                            }
                        }
                    }

                    if (bSkip)
                    {
                        continue;
                    }

                    if (Pop3FromMustContain != "" && from_addr.IndexOf(Pop3FromMustContain) < 0)
                    {
                        Util.write_to_log("skipping because from does not contain: " + Pop3FromMustContain);
                        continue; // that is, skip to next message
                    }

                    for (int k = 0; k < FromCannotContainStrings.Length; k++)
                    {
                        if (FromCannotContainStrings[k] != "")
                        {
                            if (from_addr.IndexOf(FromCannotContainStrings[k]) >= 0)
                            {
                                Util.write_to_log("skipping because from cannot contain: " + FromCannotContainStrings[k]);
                                bSkip = true;
                                break; // done checking, skip this message
                            }
                        }
                    }

                    if (bSkip)
                    {
                        continue;
                    }


                    int bugid = MyMime.get_bugid_from_subject(ref subject);
                    string cc = MyMime.get_cc(mime_message);
                    string comment = MyMime.get_comment(mime_message);
                    string headers = MyMime.get_headers_for_comment(mime_message);
                    if (headers != "")
                    {
                        comment = headers + "\n" + comment;
                    }

                    Security security = MyMime.get_synthesized_security(mime_message, from_addr, Pop3ServiceUsername);
                    int orgid = security.user.org;

                    if (bugid == 0)
                    {
                        if (security.user.forced_project != 0)
                        {
                            projectid = security.user.forced_project;
                        }

                        if (subject.Length > 200)
                        {
                            subject = subject.Substring(0, 200);
                        }

                        Bug.NewIds new_ids = Bug.insert_bug(
                            subject,
                            security,
                            "", // tags
                            projectid,
                            orgid,
                            categoryid,
                            priorityid,
                            statusid,
                            0, // assignedid,
                            udfid,
                            "", "", "", // project specific dropdown values
                            comment,
                            comment,
                            from_addr,
                            cc,
                            "text/plain",
                            false, // internal only
                            null, // custom columns
                            false);

                        MyMime.add_attachments(mime_message, new_ids.bugid, new_ids.postid, security);

                        // your customizations
                        Bug.apply_post_insert_rules(new_ids.bugid);

                        Bug.send_notifications(Bug.INSERT, new_ids.bugid, security);
                        WhatsNew.add_news(new_ids.bugid, subject, "added", security);

                        MyPop3.auto_reply(new_ids.bugid, from_addr, subject, projectid);

                    }
                    else // update existing
                    {
                        string StatusResultingFromIncomingEmail = Util.get_setting("StatusResultingFromIncomingEmail", "0");

                        string sql = "";

                        if (StatusResultingFromIncomingEmail != "0")
                        {

                            sql = @"update bugs
				                set bg_status = $st
				                where bg_id = $bg
				                ";

                            sql = sql.Replace("$st", StatusResultingFromIncomingEmail);

                        }

                        sql += "select bg_short_desc from bugs where bg_id = $bg";
                        sql = sql.Replace("$bg", Convert.ToString(bugid));
                        DataRow dr2 = DbUtil.get_datarow(sql);

                        // Add a comment to existing bug.
                        int postid = Bug.insert_comment(
                            bugid,
                            security.user.usid, // (int) dr["us_id"],
                            comment,
                            comment,
                            from_addr,
                            cc,
                            "text/plain",
                            false); // internal only

                        MyMime.add_attachments(mime_message, bugid, postid, security);
                        Bug.send_notifications(Bug.UPDATE, bugid, security);
                        WhatsNew.add_news(bugid, (string)dr2["bg_short_desc"], "updated", security);
                    }

                    if (Pop3DeleteMessagesOnServer)
                    {
                        Util.write_to_log("sending POP3 command DELE");
                        Util.write_to_log(client.DELE(message_number));
                    }
                }
            }
            //catch (Exception ex)
            //{
            //    Util.write_to_log("pop3:exception in fetch_messages: " + ex.Message);
            //    error_count++;
            //    if (error_count > Pop3TotalErrorsAllowed)
            //    {
            //        return false;
            //    }
            //}


            Util.write_to_log("pop3:quit");
            Util.write_to_log("pop3:" + client.QUIT());
            return true;

        }


        //*************************************************************
        static void threadproc_pop3(object obj)
        {
            //System.Web.HttpApplication app = (System.Web.HttpApplication)obj;

            while (true)
            {
                int Pop3FetchIntervalInMinutes = Convert.ToInt32(Util.get_setting("Pop3FetchIntervalInMinutes", "15"));

                try
                {
                    // get all the projects that have been associated with pop3 usernames 
                    string sql = @"select pj_id, pj_pop3_username, pj_pop3_password	from projects where pj_enable_pop3 = 1";

                    DataSet ds = DbUtil.get_dataset(sql);
                    foreach (DataRow dr in ds.Tables[0].Rows)
                    {

                        Util.write_to_log("pop3:processing project " + Convert.ToString(dr["pj_id"]) + " using account " + dr["pj_pop3_username"]);

                        bool result = fetch_messages(
                            (string)dr["pj_pop3_username"],
                            (string)dr["pj_pop3_password"],
                            (int)dr["pj_id"]);

                        if (!result)
                        {
                            Util.write_to_log("pop3:exiting thread because error count has reached the limit");
                            return;
                        }
                    }
                }
                catch (Exception e)
                {
                    Util.write_to_log("pop3:exception in threadproc_pop3:");
                    Util.write_to_log(e.Message);
                    Util.write_to_log(e.StackTrace);
                    return;
                }

                System.Threading.Thread.Sleep(Pop3FetchIntervalInMinutes * 60 * 1000);
            }
        }


        //*************************************************************
        public static void auto_reply(int bugid, string from_addr, string short_desc, int projectid)
        {
            string auto_reply_text = Util.get_setting("AutoReplyText", "");
            if (auto_reply_text == "")
                return;

            auto_reply_text = auto_reply_text.Replace("$BUGID$", Convert.ToString(bugid));


            string sql = @"select
						pj_pop3_email_from
						from projects
						where pj_id = $pj";

            sql = sql.Replace("$pj", Convert.ToString(projectid));

            object project_email = DbUtil.execute_scalar(sql);

            if (project_email == null)
            {
                Util.write_to_log("skipping auto reply because project email is blank");
                return;
            }

            string project_email_string = Convert.ToString(project_email);

            if (project_email_string == "")
            {
                Util.write_to_log("skipping auto reply because project email is blank");
                return;
            }

            // To avoid an infinite loop of replying to emails and then having to reply to the replies!
            if (project_email_string.ToLower() == from_addr.ToLower())
            {
                Util.write_to_log("skipping auto reply because from address is same as project email:" + project_email_string);
                return;
            }

            string outgoing_subject = short_desc + "  ("
                + Util.get_setting("TrackingIdString", "DO NOT EDIT THIS:")
                + Convert.ToString(bugid) + ")";

            bool use_html_format = (Util.get_setting("AutoReplyUseHtmlEmailFormat", "0") == "1");

            // commas cause trouble
            string cleaner_from_addr = from_addr.Replace(",", " ");

            Email.send_email(// 4 args
                cleaner_from_addr, // we are responding TO the address we just received email FROM
                project_email_string,
                "", // cc
                outgoing_subject,
                auto_reply_text,
                use_html_format ? BtnetMailFormat.Html : BtnetMailFormat.Text);

        }
    }
}