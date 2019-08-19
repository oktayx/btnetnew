-- ----------------------------------------------------------------------------
-- MySQL Workbench Migration
-- Migrated Schemata: btnet
-- Source Schemata: btnet
-- Created: Mon Aug 19 11:24:59 2019
-- Workbench Version: 8.0.17
-- ----------------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- Schema btnet
-- ----------------------------------------------------------------------------
DROP SCHEMA IF EXISTS `btnet` ;
CREATE SCHEMA IF NOT EXISTS `btnet` ;

/* 
-- Drop tables
drop table [bug_posts] 
drop table [bug_subscriptions] 
drop table [bugs] 
drop table [categories] 
drop table [priorities] 
drop table [project_user_xref] 
drop table [projects] 
drop table [queries] 
drop table [reports] 
drop table [sessions] 
drop table [statuses] 
drop table [user_defined_attribute] 
drop table [users] 
drop table [bug_relationships] 
drop table [custom_col_metadata] 
drop table [svn_affected_paths] 
drop table [svn_revisions] 
drop table [bug_post_attachments] 
drop table [orgs] 
drop table [bug_user] 
drop table [emailed_links] 
drop table [queued_notifications] 
drop table [dashboard_items] 
drop table [bug_tasks] 
drop table [git_affected_paths] 
drop table [git_commits] 
drop table [hg_affected_paths] 
drop table [hg_revisions] 

*/

-- ----------------------------------------------------------------------------
-- Table btnet.user_defined_attribute
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`user_defined_attribute` (
  `udf_id` INT NOT NULL AUTO_INCREMENT,
  `udf_name` VARCHAR(60) CHARACTER SET 'utf8mb4' NOT NULL,
  `udf_sort_seq` INT NOT NULL DEFAULT 0,
  `udf_default` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`udf_id`),
  UNIQUE INDEX `unique_udf_name` (`udf_name` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.statuses
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`statuses` (
  `st_id` INT NOT NULL AUTO_INCREMENT,
  `st_name` VARCHAR(60) CHARACTER SET 'utf8mb4' NOT NULL,
  `st_sort_seq` INT NOT NULL DEFAULT 0,
  `st_style` VARCHAR(30) CHARACTER SET 'utf8mb4' NULL,
  `st_default` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`st_id`),
  UNIQUE INDEX `unique_st_name` (`st_name` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.priorities
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`priorities` (
  `pr_id` INT NOT NULL AUTO_INCREMENT,
  `pr_name` VARCHAR(60) CHARACTER SET 'utf8mb4' NOT NULL,
  `pr_sort_seq` INT NOT NULL DEFAULT 0,
  `pr_background_color` VARCHAR(14) CHARACTER SET 'utf8mb4' NOT NULL,
  `pr_style` VARCHAR(30) CHARACTER SET 'utf8mb4' NULL,
  `pr_default` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`pr_id`),
  UNIQUE INDEX `unique_pr_name` (`pr_name` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.custom_col_metadata
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`custom_col_metadata` (
  `ccm_colorder` INT NOT NULL,
  `ccm_dropdown_vals` VARCHAR(1000) CHARACTER SET 'utf8mb4' NOT NULL DEFAULT '',
  `ccm_sort_seq` INT NULL DEFAULT 0,
  `ccm_dropdown_type` VARCHAR(20) NULL,
  PRIMARY KEY (`ccm_colorder`));

-- ----------------------------------------------------------------------------
-- Table btnet.svn_revisions
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`svn_revisions` (
  `svnrev_id` INT NOT NULL AUTO_INCREMENT,
  `svnrev_revision` INT NOT NULL,
  `svnrev_bug` INT NOT NULL,
  `svnrev_repository` VARCHAR(400) CHARACTER SET 'utf8mb4' NOT NULL,
  `svnrev_author` VARCHAR(100) CHARACTER SET 'utf8mb4' NOT NULL,
  `svnrev_svn_date` VARCHAR(100) CHARACTER SET 'utf8mb4' NOT NULL,
  `svnrev_btnet_date` DATETIME NOT NULL,
  `svnrev_msg` LONGTEXT NOT NULL,
  INDEX `svn_bug_index` (`svnrev_bug` ASC),
  PRIMARY KEY (`svnrev_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.svn_affected_paths
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`svn_affected_paths` (
  `svnap_id` INT NOT NULL AUTO_INCREMENT,
  `svnap_svnrev_id` INT NOT NULL,
  `svnap_action` VARCHAR(8) CHARACTER SET 'utf8mb4' NOT NULL,
  `svnap_path` VARCHAR(400) CHARACTER SET 'utf8mb4' NOT NULL,
  INDEX `svn_revision_index` (`svnap_svnrev_id` ASC),
  PRIMARY KEY (`svnap_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.git_commits
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`git_commits` (
  `gitcom_id` INT NOT NULL AUTO_INCREMENT,
  `gitcom_commit` CHAR(40) NULL,
  `gitcom_bug` INT NOT NULL,
  `gitcom_repository` VARCHAR(400) CHARACTER SET 'utf8mb4' NOT NULL,
  `gitcom_author` VARCHAR(100) CHARACTER SET 'utf8mb4' NOT NULL,
  `gitcom_git_date` VARCHAR(100) CHARACTER SET 'utf8mb4' NOT NULL,
  `gitcom_btnet_date` DATETIME NOT NULL,
  `gitcom_msg` LONGTEXT NOT NULL,
  INDEX `git_bug_index` (`gitcom_bug` ASC),
  PRIMARY KEY (`gitcom_id`),
  UNIQUE INDEX `git_unique_commit` (`gitcom_commit` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.git_affected_paths
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`git_affected_paths` (
  `gitap_id` INT NOT NULL AUTO_INCREMENT,
  `gitap_gitcom_id` INT NOT NULL,
  `gitap_action` VARCHAR(8) CHARACTER SET 'utf8mb4' NOT NULL,
  `gitap_path` VARCHAR(400) CHARACTER SET 'utf8mb4' NOT NULL,
  INDEX `gitap_gitcom_index` (`gitap_gitcom_id` ASC),
  PRIMARY KEY (`gitap_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.hg_revisions
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`hg_revisions` (
  `hgrev_id` INT NOT NULL AUTO_INCREMENT,
  `hgrev_revision` INT NULL,
  `hgrev_bug` INT NOT NULL,
  `hgrev_repository` VARCHAR(400) CHARACTER SET 'utf8mb4' NOT NULL,
  `hgrev_author` VARCHAR(100) CHARACTER SET 'utf8mb4' NOT NULL,
  `hgrev_hg_date` VARCHAR(100) CHARACTER SET 'utf8mb4' NOT NULL,
  `hgrev_btnet_date` DATETIME NOT NULL,
  `hgrev_msg` LONGTEXT NOT NULL,
  INDEX `hg_bug_index` (`hgrev_bug` ASC),
  PRIMARY KEY (`hgrev_id`),
  UNIQUE INDEX `hg_unique_revision` (`hgrev_revision` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.hg_affected_paths
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`hg_affected_paths` (
  `hgap_id` INT NOT NULL AUTO_INCREMENT,
  `hgap_hgrev_id` INT NOT NULL,
  `hgap_action` VARCHAR(8) CHARACTER SET 'utf8mb4' NOT NULL,
  `hgap_path` VARCHAR(400) CHARACTER SET 'utf8mb4' NOT NULL,
  INDEX `hgap_hgrev_index` (`hgap_hgrev_id` ASC),
  PRIMARY KEY (`hgap_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.reports
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`reports` (
  `rp_id` INT NOT NULL AUTO_INCREMENT,
  `rp_desc` VARCHAR(200) CHARACTER SET 'utf8mb4' NOT NULL,
  `rp_sql` LONGTEXT NOT NULL,
  `rp_chart_type` VARCHAR(8) NOT NULL,
  PRIMARY KEY (`rp_id`),
  UNIQUE INDEX `unique_rp_desc` (`rp_desc` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.queries
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`queries` (
  `qu_id` INT NOT NULL AUTO_INCREMENT,
  `qu_desc` VARCHAR(200) CHARACTER SET 'utf8mb4' NOT NULL,
  `qu_sql` LONGTEXT NOT NULL,
  `qu_default` INT NULL,
  `qu_user` INT NULL,
  `qu_org` INT NULL,
  PRIMARY KEY (`qu_id`),
  UNIQUE INDEX `unique_qu_desc` (`qu_desc` ASC, `qu_user` ASC, `qu_org` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.queued_notifications
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`queued_notifications` (
  `qn_id` INT NOT NULL AUTO_INCREMENT,
  `qn_date_created` DATETIME NOT NULL,
  `qn_bug` INT NOT NULL,
  `qn_user` INT NOT NULL,
  `qn_status` VARCHAR(30) CHARACTER SET 'utf8mb4' NOT NULL,
  `qn_retries` INT NOT NULL,
  `qn_last_exception` VARCHAR(1000) CHARACTER SET 'utf8mb4' NOT NULL,
  `qn_to` VARCHAR(200) CHARACTER SET 'utf8mb4' NOT NULL,
  `qn_from` VARCHAR(200) CHARACTER SET 'utf8mb4' NOT NULL,
  `qn_subject` VARCHAR(400) CHARACTER SET 'utf8mb4' NOT NULL,
  `qn_body` LONGTEXT NOT NULL,
  PRIMARY KEY (`qn_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.dashboard_items
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`dashboard_items` (
  `ds_id` INT NOT NULL AUTO_INCREMENT,
  `ds_user` INT NOT NULL,
  `ds_report` INT NOT NULL,
  `ds_chart_type` VARCHAR(8) NOT NULL,
  `ds_col` INT NOT NULL,
  `ds_row` INT NOT NULL,
  INDEX `ds_user_index` (`ds_user` ASC),
  PRIMARY KEY (`ds_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.orgs
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`orgs` (
  `og_id` INT NOT NULL AUTO_INCREMENT,
  `og_name` VARCHAR(80) CHARACTER SET 'utf8mb4' NOT NULL,
  `og_domain` VARCHAR(80) CHARACTER SET 'utf8mb4' NULL,
  `og_non_admins_can_use` INT NOT NULL DEFAULT 0,
  `og_external_user` INT NOT NULL DEFAULT 0,
  `og_can_be_assigned_to` INT NOT NULL DEFAULT 1,
  `og_can_only_see_own_reported` INT NOT NULL DEFAULT 0,
  `og_can_edit_sql` INT NOT NULL DEFAULT 0,
  `og_can_delete_bug` INT NOT NULL DEFAULT 0,
  `og_can_edit_and_delete_posts` INT NOT NULL DEFAULT 0,
  `og_can_merge_bugs` INT NOT NULL DEFAULT 0,
  `og_can_mass_edit_bugs` INT NOT NULL DEFAULT 0,
  `og_can_use_reports` INT NOT NULL DEFAULT 0,
  `og_can_edit_reports` INT NOT NULL DEFAULT 0,
  `og_can_view_tasks` INT NOT NULL DEFAULT 0,
  `og_can_edit_tasks` INT NOT NULL DEFAULT 0,
  `og_can_search` INT NOT NULL DEFAULT 1,
  `og_other_orgs_permission_level` INT NOT NULL DEFAULT 2,
  `og_can_assign_to_internal_users` INT NOT NULL DEFAULT 0,
  `og_category_field_permission_level` INT NOT NULL DEFAULT 2,
  `og_priority_field_permission_level` INT NOT NULL DEFAULT 2,
  `og_assigned_to_field_permission_level` INT NOT NULL DEFAULT 2,
  `og_status_field_permission_level` INT NOT NULL DEFAULT 2,
  `og_project_field_permission_level` INT NOT NULL DEFAULT 2,
  `og_org_field_permission_level` INT NOT NULL DEFAULT 2,
  `og_udf_field_permission_level` INT NOT NULL DEFAULT 2,
  `og_tags_field_permission_level` INT NOT NULL DEFAULT 2,
  `og_active` INT NOT NULL DEFAULT 1,
  `og_test_field_permission_level` INT NULL,
  `og_drop1_field_permission_level` INT NULL,
  PRIMARY KEY (`og_id`),
  UNIQUE INDEX `unique_og_name` (`og_name` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.users
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`users` (
  `us_id` INT NOT NULL AUTO_INCREMENT,
  `us_username` VARCHAR(40) CHARACTER SET 'utf8mb4' NOT NULL,
  `us_salt` INT NULL,
  `us_password` VARCHAR(64) CHARACTER SET 'utf8mb4' NOT NULL,
  `us_firstname` VARCHAR(60) CHARACTER SET 'utf8mb4' NULL,
  `us_lastname` VARCHAR(60) CHARACTER SET 'utf8mb4' NULL,
  `us_email` VARCHAR(120) CHARACTER SET 'utf8mb4' NULL,
  `us_admin` INT NOT NULL DEFAULT 0,
  `us_default_query` INT NOT NULL DEFAULT 0,
  `us_enable_notifications` INT NOT NULL DEFAULT 1,
  `us_auto_subscribe` INT NOT NULL DEFAULT 0,
  `us_auto_subscribe_own_bugs` INT NULL DEFAULT 0,
  `us_auto_subscribe_reported_bugs` INT NULL DEFAULT 0,
  `us_send_notifications_to_self` INT NULL DEFAULT 0,
  `us_active` INT NOT NULL DEFAULT 1,
  `us_bugs_per_page` INT NULL,
  `us_forced_project` INT NULL,
  `us_reported_notifications` INT NOT NULL DEFAULT 4,
  `us_assigned_notifications` INT NOT NULL DEFAULT 4,
  `us_subscribed_notifications` INT NOT NULL DEFAULT 4,
  `us_signature` VARCHAR(1000) CHARACTER SET 'utf8mb4' NULL,
  `us_use_fckeditor` INT NOT NULL DEFAULT 0,
  `us_enable_bug_list_popups` INT NOT NULL DEFAULT 1,
  `us_created_user` INT NOT NULL DEFAULT 1,
  `us_org` INT NOT NULL DEFAULT 1,
  `us_most_recent_login_datetime` DATETIME NULL,
  PRIMARY KEY (`us_id`),
  UNIQUE INDEX `unique_us_username` (`us_username` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.sessions
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`sessions` (
  `se_id` CHAR(37) NOT NULL,
  `se_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `se_user` INT NOT NULL,
  PRIMARY KEY (`se_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.emailed_links
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`emailed_links` (
  `el_id` CHAR(37) NOT NULL,
  `el_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `el_email` VARCHAR(120) CHARACTER SET 'utf8mb4' NOT NULL,
  `el_action` VARCHAR(20) CHARACTER SET 'utf8mb4' NOT NULL,
  `el_username` VARCHAR(40) CHARACTER SET 'utf8mb4' NULL,
  `el_user_id` INT NULL,
  `el_salt` INT NULL,
  `el_password` VARCHAR(64) CHARACTER SET 'utf8mb4' NULL,
  `el_firstname` VARCHAR(60) CHARACTER SET 'utf8mb4' NULL,
  `el_lastname` VARCHAR(60) CHARACTER SET 'utf8mb4' NULL,
  PRIMARY KEY (`el_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.categories
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`categories` (
  `ct_id` INT NOT NULL AUTO_INCREMENT,
  `ct_name` VARCHAR(80) CHARACTER SET 'utf8mb4' NOT NULL,
  `ct_sort_seq` INT NOT NULL DEFAULT 0,
  `ct_default` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`ct_id`),
  UNIQUE INDEX `unique_ct_name` (`ct_name` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.projects
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`projects` (
  `pj_id` INT NOT NULL AUTO_INCREMENT,
  `pj_name` VARCHAR(80) CHARACTER SET 'utf8mb4' NOT NULL,
  `pj_active` INT NOT NULL DEFAULT 1,
  `pj_default_user` INT NULL,
  `pj_auto_assign_default_user` INT NULL,
  `pj_auto_subscribe_default_user` INT NULL,
  `pj_enable_pop3` INT NULL,
  `pj_pop3_username` VARCHAR(50) NULL,
  `pj_pop3_password` VARCHAR(20) CHARACTER SET 'utf8mb4' NULL,
  `pj_pop3_email_from` VARCHAR(120) CHARACTER SET 'utf8mb4' NULL,
  `pj_enable_custom_dropdown1` INT NOT NULL DEFAULT 0,
  `pj_enable_custom_dropdown2` INT NOT NULL DEFAULT 0,
  `pj_enable_custom_dropdown3` INT NOT NULL DEFAULT 0,
  `pj_custom_dropdown_label1` VARCHAR(80) CHARACTER SET 'utf8mb4' NULL,
  `pj_custom_dropdown_label2` VARCHAR(80) CHARACTER SET 'utf8mb4' NULL,
  `pj_custom_dropdown_label3` VARCHAR(80) CHARACTER SET 'utf8mb4' NULL,
  `pj_custom_dropdown_values1` VARCHAR(800) CHARACTER SET 'utf8mb4' NULL,
  `pj_custom_dropdown_values2` VARCHAR(800) CHARACTER SET 'utf8mb4' NULL,
  `pj_custom_dropdown_values3` VARCHAR(800) CHARACTER SET 'utf8mb4' NULL,
  `pj_default` INT NOT NULL DEFAULT 0,
  `pj_description` VARCHAR(200) CHARACTER SET 'utf8mb4' NULL,
  PRIMARY KEY (`pj_id`),
  UNIQUE INDEX `unique_pj_name` (`pj_name` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.bugs
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`bugs` (
  `bg_id` INT NOT NULL AUTO_INCREMENT,
  `bg_short_desc` VARCHAR(200) CHARACTER SET 'utf8mb4' NOT NULL,
  `bg_reported_user` INT NOT NULL,
  `bg_reported_date` DATETIME NOT NULL,
  `bg_status` INT NOT NULL,
  `bg_priority` INT NOT NULL,
  `bg_org` INT NOT NULL,
  `bg_category` INT NOT NULL,
  `bg_project` INT NOT NULL,
  `bg_assigned_to_user` INT NULL,
  `bg_last_updated_user` INT NULL,
  `bg_last_updated_date` DATETIME NULL,
  `bg_user_defined_attribute` INT NULL,
  `bg_project_custom_dropdown_value1` VARCHAR(120) CHARACTER SET 'utf8mb4' NULL,
  `bg_project_custom_dropdown_value2` VARCHAR(120) CHARACTER SET 'utf8mb4' NULL,
  `bg_project_custom_dropdown_value3` VARCHAR(120) CHARACTER SET 'utf8mb4' NULL,
  `bg_tags` VARCHAR(200) CHARACTER SET 'utf8mb4' NULL,
  `test` VARCHAR(10) NULL,
  `drop1` VARCHAR(11) NULL,
  PRIMARY KEY (`bg_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.bug_posts
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`bug_posts` (
  `bp_id` INT NOT NULL AUTO_INCREMENT,
  `bp_bug` INT NOT NULL,
  `bp_type` VARCHAR(8) NOT NULL,
  `bp_user` INT NOT NULL,
  `bp_date` DATETIME NOT NULL,
  `bp_comment` LONGTEXT NOT NULL,
  `bp_comment_search` LONGTEXT NULL,
  `bp_email_from` VARCHAR(800) CHARACTER SET 'utf8mb4' NULL,
  `bp_email_to` VARCHAR(800) CHARACTER SET 'utf8mb4' NULL,
  `bp_file` VARCHAR(1000) CHARACTER SET 'utf8mb4' NULL,
  `bp_size` INT NULL,
  `bp_content_type` VARCHAR(200) CHARACTER SET 'utf8mb4' NULL,
  `bp_parent` INT NULL,
  `bp_original_comment_id` INT NULL,
  `bp_hidden_from_external_users` INT NOT NULL DEFAULT 0,
  `bp_email_cc` VARCHAR(800) CHARACTER SET 'utf8mb4' NULL,
  INDEX `bp_index_1` (`bp_bug` ASC),
  PRIMARY KEY (`bp_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.bug_tasks
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`bug_tasks` (
  `tsk_id` INT NOT NULL AUTO_INCREMENT,
  `tsk_bug` INT NOT NULL,
  `tsk_created_user` INT NOT NULL,
  `tsk_created_date` DATETIME NOT NULL,
  `tsk_last_updated_user` INT NOT NULL,
  `tsk_last_updated_date` DATETIME NOT NULL,
  `tsk_assigned_to_user` INT NULL,
  `tsk_planned_start_date` DATETIME NULL,
  `tsk_actual_start_date` DATETIME NULL,
  `tsk_planned_end_date` DATETIME NULL,
  `tsk_actual_end_date` DATETIME NULL,
  `tsk_planned_duration` DECIMAL(6,2) NULL,
  `tsk_actual_duration` DECIMAL(6,2) NULL,
  `tsk_duration_units` VARCHAR(20) CHARACTER SET 'utf8mb4' NULL,
  `tsk_percent_complete` INT NULL,
  `tsk_status` INT NULL,
  `tsk_sort_sequence` INT NULL,
  `tsk_description` VARCHAR(400) CHARACTER SET 'utf8mb4' NULL,
  INDEX `tsk_index_1` (`tsk_bug` ASC),
  PRIMARY KEY (`tsk_id`));

-- ----------------------------------------------------------------------------
-- Table btnet.bug_post_attachments
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`bug_post_attachments` (
  `bpa_id` INT NOT NULL AUTO_INCREMENT,
  `bpa_post` INT NOT NULL,
  `bpa_content` LONGBLOB NOT NULL,
  PRIMARY KEY (`bpa_id`),
  UNIQUE INDEX `bpa_index` (`bpa_post` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.bug_subscriptions
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`bug_subscriptions` (
  `bs_bug` INT NOT NULL,
  `bs_user` INT NOT NULL,
  UNIQUE INDEX `bs_index_2` (`bs_bug` ASC, `bs_user` ASC),
  UNIQUE INDEX `bs_index_1` (`bs_user` ASC, `bs_bug` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.bug_user
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`bug_user` (
  `bu_bug` INT NOT NULL,
  `bu_user` INT NOT NULL,
  `bu_flag` INT NOT NULL,
  `bu_flag_datetime` DATETIME NULL,
  `bu_seen` INT NOT NULL,
  `bu_seen_datetime` DATETIME NULL,
  `bu_vote` INT NOT NULL,
  `bu_vote_datetime` DATETIME NULL,
  UNIQUE INDEX `bu_index_1` (`bu_bug` ASC, `bu_user` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.bug_relationships
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`bug_relationships` (
  `re_id` INT NOT NULL AUTO_INCREMENT,
  `re_bug1` INT NOT NULL,
  `re_bug2` INT NOT NULL,
  `re_type` VARCHAR(500) CHARACTER SET 'utf8mb4' NULL,
  `re_direction` INT NOT NULL,
  PRIMARY KEY (`re_id`),
  UNIQUE INDEX `re_index_1` (`re_bug1` ASC, `re_bug2` ASC),
  UNIQUE INDEX `re_index_2` (`re_bug2` ASC, `re_bug1` ASC));

-- ----------------------------------------------------------------------------
-- Table btnet.project_user_xref
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `btnet`.`project_user_xref` (
  `pu_id` INT NOT NULL AUTO_INCREMENT,
  `pu_project` INT NOT NULL,
  `pu_user` INT NOT NULL,
  `pu_auto_subscribe` INT NOT NULL DEFAULT 0,
  `pu_permission_level` INT NOT NULL DEFAULT 2,
  `pu_admin` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`pu_id`),
  UNIQUE INDEX `pu_index_1` (`pu_project` ASC, `pu_user` ASC),
  UNIQUE INDEX `pu_index_2` (`pu_user` ASC, `pu_project` ASC));
SET FOREIGN_KEY_CHECKS = 1;


/* DATA */

USE btnet;

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query, us_org)
values ('admin', 'System', 'Administrator', 'admin', 1, 1, 1);

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query, us_org)
values ('developer', 'Al', 'Kaline', 'admin', 0, 2, 2);

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query, us_org)
values ('tester', 'Norman', 'Cash', 'admin', 0, 4, 4);

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query, us_org)
values ('customer1', 'Bill', 'Freehan', 'admin', 0, 1, 4);

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query, us_org)
values ('customer2', 'Denny', 'McClain', 'admin', 0, 1, 5);

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query)
values ('email', 'for POP3', 'btnet_service.exe', 'x', 0, 1);

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query, us_forced_project)
values ('viewer', 'Read', 'Only', 'admin', 0, 1, 1);

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query, us_forced_project)
values ('reporter', 'Report And', 'Comment Only', 'admin', 0, 1, 1);

insert into users (
us_username, us_firstname, us_lastname, us_password, us_admin, us_default_query, us_forced_project, us_active)
values ('guest', 'Special', 'cannot save searches, settings', 'guest', 0, 1, 1, 0);


insert into orgs (og_name, og_external_user, og_can_be_assigned_to, og_other_orgs_permission_level) values ('org1',0,1,2);
insert into orgs (og_name, og_external_user, og_can_be_assigned_to, og_other_orgs_permission_level) values ('developers',0,1,2);
insert into orgs (og_name, og_external_user, og_can_be_assigned_to, og_other_orgs_permission_level) values ('testers',0,1,2);
insert into orgs (og_name, og_external_user, og_can_be_assigned_to, og_other_orgs_permission_level) values ('client one',1,0,0);
insert into orgs (og_name, og_external_user, og_can_be_assigned_to, og_other_orgs_permission_level) values ('client two',1,0,0);


insert into categories (ct_name) values('bug');
insert into categories (ct_name) values('enhancement');
insert into categories (ct_name) values('task');
insert into categories (ct_name) values('question');
insert into categories (ct_name) values('ticket');


insert into projects (pj_name) values('project 1');
insert into projects (pj_name) values('project 2');


insert into project_user_xref (pu_project, pu_user, pu_permission_level) values (1,7,1);
insert into project_user_xref (pu_project, pu_user, pu_permission_level) values (2,7,1);
insert into project_user_xref (pu_project, pu_user, pu_permission_level) values (1,8,3);
insert into project_user_xref (pu_project, pu_user, pu_permission_level) values (2,8,0);
insert into project_user_xref (pu_project, pu_user, pu_permission_level) values (1,9,1);
insert into project_user_xref (pu_project, pu_user, pu_permission_level) values (2,9,1);


insert into user_defined_attribute (udf_name) values ('whatever');
insert into user_defined_attribute (udf_name) values ('anything');


insert into statuses (st_name, st_sort_seq, st_style, st_default) values ('new', 1, 'st1', 1);
insert into statuses (st_name, st_sort_seq, st_style, st_default) values ('in progress', 2, 'st2', 0);
insert into statuses (st_name, st_sort_seq, st_style, st_default) values ('checked in', 3, 'st3', 0);
insert into statuses (st_name, st_sort_seq, st_style, st_default) values ('re-opened', 4, 'st4', 0);
insert into statuses (st_name, st_sort_seq, st_style, st_default) values ('closed', 5, 'st5', 0);


insert into priorities (pr_name, pr_sort_seq, pr_background_color, pr_style) values ('high', 1, '#ff9999', 'pr1_');
insert into priorities (pr_name, pr_sort_seq, pr_background_color, pr_style) values ('med', 2, '#ffdddd', 'pr2_');
insert into priorities (pr_name, pr_sort_seq, pr_background_color, pr_style) values ('low', 3, '#ffffff', 'pr3_');



/* Some examples to get you started */

USE btnet;

/* REPORTS */

insert into reports (rp_desc, rp_sql, rp_chart_type)
values('Bugs by Status',
CONCAT('select st_name [status], count(1) [count] '
, char(13,10) , ' from bugs '
, char(13,10) , ' inner join statuses on bg_status = st_id '
, char(13,10) , ' group by st_name '
, char(13,10) , ' order by st_name'),
'pie');

insert into reports (rp_desc, rp_sql, rp_chart_type)
values('Bugs by Priority',
CONCAT('select pr_name [priority], count(1) [count] '
, char(13,10) , ' from bugs '
, char(13,10) , ' inner join priorities on bg_priority = pr_id '
, char(13,10) , ' group by pr_name '
, char(13,10) , ' order by pr_name'),
'pie');

insert into reports (rp_desc, rp_sql, rp_chart_type)
values('Bugs by Category',
CONCAT('select ct_name [category], count(1) [count] '
, char(13,10) , ' from bugs '
, char(13,10) , ' inner join categories on bg_category = ct_id '
, char(13,10) , ' group by ct_name '
, char(13,10) , ' order by ct_name'),
'pie');

insert into reports (rp_desc, rp_sql, rp_chart_type)
values('Bugs by Month',
CONCAT('select month(bg_reported_date) [month], count(1) [count] '
, char(13,10) , ' from bugs '
, char(13,10) , ' group by year(bg_reported_date), month(bg_reported_date) '
, char(13,10) , ' order by year(bg_reported_date), month(bg_reported_date)'),
'bar');

insert into reports (rp_desc, rp_sql, rp_chart_type)
values('Bugs by Day of Year',
CONCAT('select datepart(dy, bg_reported_date) [day of year], count(1) [count] '
, char(13,10) , ' from bugs '
, char(13,10) , ' group by datepart(dy, bg_reported_date), '
, char(13,10) , ' datepart(dy,bg_reported_date) order by 1'),
'line');

insert into reports (rp_desc, rp_sql, rp_chart_type)
values('Bugs by User',
CONCAT('select bg_reported_user, count(1) [r] '
, char(13,10) , ' into #t '
, char(13,10) , ' from bugs '
, char(13,10) , ' group by bg_reported_user; '
, char(13,10) , ' select bg_assigned_to_user, count(1) [a] '
, char(13,10) , ' into #t2 '
, char(13,10) , ' from bugs '
, char(13,10) , ' group by bg_assigned_to_user; '
, char(13,10) , ' select us_username, r [reported], a [assigned] '
, char(13,10) , ' from users '
, char(13,10) , ' left outer join #t on bg_reported_user = us_id '
, char(13,10) , ' left outer join #t2 on bg_assigned_to_user = us_id '
, char(13,10) , ' order by 1'), 
'table');

insert into reports (rp_desc, rp_sql, rp_chart_type)
values ('Hours by Org, Year, Month',
CONCAT('select og_name [organization], '
, char(13,10) , ' datepart(year,tsk_created_date) [year],  '
, char(13,10) , ' datepart(month,tsk_created_date) [month], '
, char(13,10) , ' convert(decimal(8,1),sum( '
, char(13,10) , ' case when tsk_duration_units = ''minutes'' then tsk_actual_duration / 60.0 '
, char(13,10) , ' when tsk_duration_units = ''days'' then tsk_actual_duration * 8.0  '
, char(13,10) , ' else tsk_actual_duration * 1.0 end)) [total hours] '
, char(13,10) , ' from bug_tasks '
, char(13,10) , ' inner join bugs on tsk_bug = bg_id '
, char(13,10) , ' inner join orgs on bg_org = og_id '
, char(13,10) , ' where isnull(tsk_actual_duration,0) <> 0 '
, char(13,10) , ' group by og_name,datepart(year,tsk_created_date), datepart(month,tsk_created_date) '),
'table');

insert into reports (rp_desc, rp_sql, rp_chart_type)
values ('Hours Remaining by Project',
CONCAT('select pj_name [project], '
, char(13,10) , ' convert(decimal(8,1),sum( '
, char(13,10) , ' case  '
, char(13,10) , ' when tsk_duration_units = ''minutes'' then  '
, char(13,10) , ' tsk_planned_duration / 60.0 * .01 * (100 - isnull(tsk_percent_complete,0)) '
, char(13,10) , ' when tsk_duration_units = ''days'' then ' 
, char(13,10) , ' tsk_planned_duration * 8.0  * .01 * (100 - isnull(tsk_percent_complete,0)) '
, char(13,10) , ' else tsk_planned_duration * .01 * (100 - isnull(tsk_percent_complete,0)) '
, char(13,10) , ' end)) [total hours] '
, char(13,10) , ' from bug_tasks '
, char(13,10) , ' inner join bugs on tsk_bug = bg_id '
, char(13,10) , ' inner join projects on bg_project = pj_id '
, char(13,10) , ' where isnull(tsk_planned_duration,0) <> 0 '
, char(13,10) , ' group by pj_name '),
'table');

/* QUERIES */

/*

The web pages that display the bugs expect the first two columns of the
queries to be the color or style of the row and the bug id.

Here are examples to get you started.

*/

insert into queries (qu_desc, qu_sql, qu_default) values (
'all bugs',
CONCAT('select isnull(pr_background_color,''#ffffff''), bg_id [id], isnull(bu_flag,0) [$FLAG], '
, char(13,10) , ' bg_short_desc [desc], isnull(pj_name,'''') [project], isnull(og_name,'''') [organization], isnull(ct_name,'''') [category], rpt.us_username [reported by],'
, char(13,10) , ' bg_reported_date [reported on], isnull(pr_name,'''') [priority], isnull(asg.us_username,'''') [assigned to],'
, char(13,10) , ' isnull(st_name,'''') [status], isnull(lu.us_username,'''') [last updated by], bg_last_updated_date [last updated on]'
, char(13,10) , ' from bugs '
, char(13,10) , ' left outer join bug_user on bu_bug = bg_id and bu_user = $ME '
, char(13,10) , ' left outer join users rpt on rpt.us_id = bg_reported_user'
, char(13,10) , ' left outer join users asg on asg.us_id = bg_assigned_to_user'
, char(13,10) , ' left outer join users lu on lu.us_id = bg_last_updated_user'
, char(13,10) , ' left outer join projects on pj_id = bg_project'
, char(13,10) , ' left outer join orgs on og_id = bg_org'
, char(13,10) , ' left outer join categories on ct_id = bg_category'
, char(13,10) , ' left outer join priorities on pr_id = bg_priority'
, char(13,10) , ' left outer join statuses on st_id = bg_status'
, char(13,10) , ' order by bg_id desc'),
1);

insert into queries (qu_desc, qu_sql, qu_default) values (
'open bugs',
CONCAT('select isnull(pr_background_color,''#ffffff''), bg_id [id], isnull(bu_flag,0) [$FLAG], '
, char(13,10) , ' bg_short_desc [desc], isnull(pj_name,'''') [project], isnull(og_name,'''') [organization], isnull(ct_name,'''') [category], rpt.us_username [reported by],'
, char(13,10) , ' bg_reported_date [reported on], isnull(pr_name,'''') [priority], isnull(asg.us_username,'''') [assigned to],'
, char(13,10) , ' isnull(st_name,'''') [status], isnull(lu.us_username,'''') [last updated by], bg_last_updated_date [last updated on]'
, char(13,10) , ' from bugs '
, char(13,10) , ' left outer join bug_user on bu_bug = bg_id and bu_user = $ME '
, char(13,10) , ' left outer join users rpt on rpt.us_id = bg_reported_user'
, char(13,10) , ' left outer join users asg on asg.us_id = bg_assigned_to_user'
, char(13,10) , ' left outer join users lu on lu.us_id = bg_last_updated_user'
, char(13,10) , ' left outer join projects on pj_id = bg_project'
, char(13,10) , ' left outer join orgs on og_id = bg_org'
, char(13,10) , ' left outer join categories on ct_id = bg_category'
, char(13,10) , ' left outer join priorities on pr_id = bg_priority'
, char(13,10) , ' left outer join statuses on st_id = bg_status'
, char(13,10) , ' where bg_status <> 5 order by bg_id desc'),
0);

insert into queries (qu_desc, qu_sql, qu_default) values (
'open bugs assigned to me',
CONCAT('select isnull(pr_background_color,''#ffffff''), bg_id [id], isnull(bu_flag,0) [$FLAG], '
, char(13,10) , ' bg_short_desc [desc], isnull(pj_name,'''') [project], isnull(og_name,'''') [organization], isnull(ct_name,'''') [category], rpt.us_username [reported by],'
, char(13,10) , ' bg_reported_date [reported on], isnull(pr_name,'''') [priority], isnull(asg.us_username,'''') [assigned to],'
, char(13,10) , ' isnull(st_name,'''') [status], isnull(lu.us_username,'''') [last updated by], bg_last_updated_date [last updated on]'
, char(13,10) , ' from bugs '
, char(13,10) , ' left outer join bug_user on bu_bug = bg_id and bu_user = $ME '
, char(13,10) , ' left outer join users rpt on rpt.us_id = bg_reported_user'
, char(13,10) , ' left outer join users asg on asg.us_id = bg_assigned_to_user'
, char(13,10) , ' left outer join users lu on lu.us_id = bg_last_updated_user'
, char(13,10) , ' left outer join projects on pj_id = bg_project'
, char(13,10) , ' left outer join orgs on og_id = bg_org'
, char(13,10) , ' left outer join categories on ct_id = bg_category'
, char(13,10) , ' left outer join priorities on pr_id = bg_priority'
, char(13,10) , ' left outer join statuses on st_id = bg_status'
, char(13,10) , ' where bg_status <> 5 and bg_assigned_to_user = $ME order by bg_id desc'),
0);

insert into queries (qu_desc, qu_sql, qu_default) values (
'checked in bugs - for QA',
CONCAT('select isnull(pr_background_color,''#ffffff''), bg_id [id], isnull(bu_flag,0) [$FLAG], '
, char(13,10) , ' bg_short_desc [desc], isnull(pj_name,'''') [project], isnull(og_name,'''') [organization], isnull(ct_name,'''') [category], rpt.us_username [reported by],'
, char(13,10) , ' bg_reported_date [reported on], isnull(pr_name,'''') [priority], isnull(asg.us_username,'''') [assigned to],'
, char(13,10) , ' isnull(st_name,'''') [status], isnull(lu.us_username,'''') [last updated by], bg_last_updated_date [last updated on]'
, char(13,10) , ' from bugs '
, char(13,10) , ' left outer join bug_user on bu_bug = bg_id and bu_user = $ME '
, char(13,10) , ' left outer join users rpt on rpt.us_id = bg_reported_user'
, char(13,10) , ' left outer join users asg on asg.us_id = bg_assigned_to_user'
, char(13,10) , ' left outer join users lu on lu.us_id = bg_last_updated_user'
, char(13,10) , ' left outer join projects on pj_id = bg_project'
, char(13,10) , ' left outer join orgs on og_id = bg_org'
, char(13,10) , ' left outer join categories on ct_id = bg_category'
, char(13,10) , ' left outer join priorities on pr_id = bg_priority'
, char(13,10) , ' left outer join statuses on st_id = bg_status'
, char(13,10) , ' where bg_status = 3 order by bg_id desc'),
0);


insert into queries (qu_desc, qu_sql, qu_default) values (
'demo use of css classes',
CONCAT('select isnull(pr_style , st_style,''datad''), bg_id [id], isnull(bu_flag,0) [$FLAG], bg_short_desc [desc], isnull(pr_name,'''') [priority], isnull(st_name,'''') [status]'
, char(13,10) , ' from bugs '
, char(13,10) , ' left outer join bug_user on bu_bug = bg_id and bu_user = $ME '
, char(13,10) , ' left outer join priorities on pr_id = bg_priority '
, char(13,10) , ' left outer join statuses on st_id = bg_status '
, char(13,10) , ' order by bg_id desc'),
0);

insert into queries (qu_desc, qu_sql, qu_default) values (
'demo last comment as column',
CONCAT('select ''#ffffff'', bg_id [id], bg_short_desc [desc], ' 
, char(13,10) , ' substring(bp_comment_search,1,40) [last comment], bp_date [last comment date]'
, char(13,10) , ' from bugs'
, char(13,10) , ' left outer join bug_posts on bg_id = bp_bug'
, char(13,10) , ' and bp_type = ''comment''' 
, char(13,10) , ' and bp_date in (select max(bp_date) from bug_posts where bp_bug = bg_id)'
, char(13,10) , ' WhErE 1 = 1'
, char(13,10) , ' order by bg_id desc'),
0);


insert into queries (qu_desc, qu_sql, qu_default) values (
'days in status',
CONCAT('select case '
, char(13,10) , ' when datediff(d, isnull(bp_date,bg_reported_date), getdate()) > 90 then ''#ff9999'' '
, char(13,10) , ' when datediff(d, isnull(bp_date,bg_reported_date), getdate()) > 30 then ''#ffcccc'' '
, char(13,10) , ' when datediff(d, isnull(bp_date,bg_reported_date), getdate()) > 7 then ''#ffdddd''  '
, char(13,10) , ' else ''#ffffff'' end, '
, char(13,10) , ' bg_id [id], bg_short_desc [desc], '
, char(13,10) , ' datediff(d, isnull(bp_date,bg_reported_date), getdate()) [days in status],'
, char(13,10) , ' st_name [status], '
, char(13,10) , ' isnull(bp_comment,'''') [last status change], isnull(bp_date,bg_reported_date) [status date]'
, char(13,10) , ' from bugs'
, char(13,10) , ' inner join statuses on bg_status = st_id'
, char(13,10) , ' left outer join bug_posts on bg_id = bp_bug'
, char(13,10) , ' and bp_type = ''update'' '
, char(13,10) , ' and bp_comment like ''changed status from%'' '
, char(13,10) , ' and bp_date in (select max(bp_date) from bug_posts where bp_bug = bg_id)'
, char(13,10) , ' WhErE 1 = 1 '
, char(13,10) , ' order by 4 desc '),
0);


insert into queries (qu_desc, qu_sql, qu_default) values (
'bugs with attachments',
CONCAT('select bp_bug, sum(bp_size) bytes '
, char(13,10) , ' into #t '
, char(13,10) , ' from bug_posts '
, char(13,10) , ' where bp_type = ''file'' '
, char(13,10) , ' group by bp_bug '
, char(13,10) , ' select ''#ffffff'', bg_id [id], bg_short_desc [desc], '
, char(13,10) , ' bytes, rpt.us_username [reported by] ' 
, char(13,10) , ' from bugs '
, char(13,10) , ' inner join #t on bp_bug = bg_id '
, char(13,10) , ' left outer join users rpt on rpt.us_id = bg_reported_user '
, char(13,10) , ' WhErE 1 = 1 '
, char(13,10) , ' order by bytes desc ' 
, char(13,10) , ' drop table #t '),
0);

insert into queries (qu_desc, qu_sql, qu_default) values (
'bugs with related bugs',
CONCAT('select ''#ffffff'', bg_id [id], bg_short_desc [desc], '
, char(13,10) , ' isnull(st_name,'''') [status], '
, char(13,10) , ' count(*) [number of related bugs] '
, char(13,10) , ' from bugs '
, char(13,10) , ' inner join bug_relationships on re_bug1 = bg_id '
, char(13,10) , ' inner join statuses on bg_status = st_id '
, char(13,10) , ' /*ENDWHR*/ '
, char(13,10) , ' group by bg_id, bg_short_desc, isnull(st_name,'''') '
, char(13,10) , ' order by bg_id desc '),
0);

insert into queries (qu_desc, qu_sql, qu_default) values (
'demo votes feature',
CONCAT('select ''#ffffff'', bg_id [id], '
, char(13,10) , ' (isnull(vote_total,0) * 10000) , isnull(bu_vote,0) [$VOTE], '
, char(13,10) , ' bg_short_desc [desc], isnull(st_name,'''') [status] '
, char(13,10) , ' from bugs '
, char(13,10) , ' left outer join bug_user on bu_bug = bg_id and bu_user = $ME '
, char(13,10) , ' left outer join votes_view on vote_bug = bg_id '
, char(13,10) , ' left outer join statuses on st_id = bg_status '
, char(13,10) , ' order by 3 desc '),
0);