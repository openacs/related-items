# /packages/related-items/lib/related/relaion-add.tcl
ad_page_contract {
    Relate object_id to object_two (can be multiple)
    Requires registration.

    @author Jeff Davis davis@xarg.net
    @creation-date 10/30/2003
    @cvs-id $Id$
} {
    object_one:integer,notnull
    object_id:multiple,integer,notnull
    {return_url {}}
}
set user_id [auth::require_login]

set vars [list \
              [list object_id_one $object_one] \
              [list creation_user $user_id] \
              [list creation_ip [ad_conn peeraddr]] \
             ]

# don't insert a rel for the same object more than once.
set seen($object_one) 1
set count 0
foreach object $object_id {
    if {![info exists seen($object)]} { 
        package_exec_plsql -var_list [concat $vars [list [list object_id_two $object]]] content_rel new
        set seen($object) 1
        incr count
    } 
}

if {[string is space $return_url]} {
    set return_url /o/$object_one
}

ad_returnredirect -message "Added $count related items" $return_url
