# /packages/related-items/lib/related/relation-delete.tcl
ad_page_contract {
    Relate object_id to object_two (can be multiple)
    Requires registration.

    @author Jeff Davis davis@xarg.net
    @creation-date 10/30/2003
    @cvs-id $Id$
} {
    rel_id:multiple,integer,notnull
    {return_url {}}
}
set user_id [auth::require_login]

foreach rel $rel_id {
    package_exec_plsql -var_list [list [list rel_id $rel]] content_rel del
}

if {[string is space $return_url]} {
    set return_url 
}

ad_returnredirect -message "Deleted [llength $rel_id] related items" $return_url
