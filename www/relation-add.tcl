# /packages/cop-ui/www/related/relate.tcl
ad_page_contract {
    Relate object_id to object_two (can be multiple)
    Requires registration.

    @author Jeff Davis davis@xarg.net
    @creation-date 10/30/2003
    @cvs-id $Id$
} {
    object_one:integer,notnull
    object_id:multiple,integer,notnull
}

set user_id [auth::require_login]

set vars [list \
              [list object_id_one $object_one] \
              [list creation_user $user_id] \
              [list creation_ip [ad_conn peeraddr]] \
             ]

foreach object $object_id {
    ns_log DEBUG "JCD: relating $object to $object_one ($object_id)"
    package_exec_plsql -var_list [concat $vars [list [list object_id_two $object]]] cop_rel new
}

ad_returnredirect -message "Added [llength $object_id] related items" relate?object_one=$object_one
