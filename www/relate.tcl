# /packages/cop-ui/www/related/relate.tcl
ad_page_contract {
    Relate object_id.
    Requires registration.

    @author Jeff Davis davis@xarg.net
    @creation-date 10/30/2003
    @cvs-id $Id$
} {
    object_one:integer,notnull
    {orderby "clipboard,desc"}
}

set user_id [auth::require_login]

set admin_p [permission::permission_p -object_id [ad_conn package_id] -privilege admin]

set title "Relate"
if {![empty_string_p $object_one]} {
    set object_name [db_string object_name {select acs_object__name(:object_one);} -default {}]
    if {![empty_string_p object_name]} { 
        append title " to $object_name"
    } else { 
        append title " to object $object_on"
    }
}


set context [list [list ./ relate] {relate object}]

set elements {
    type {
        label {Type}
        display_template "@relate.pretty_name@"
    }
    object_title {
        label {Item}
    }
    clipboard {
        label {Clipboard}
    }
    clipped { 
        label {Clipped on}
        display_template "@relate.clipped;noquote@"
        html {align right} 
    }
}

#lappend elements extra {
#    label {Debug}
#}

set bulk [list "Relate" relation-add]


template::list::create \
    -name relate \
    -multirow relate \
    -key object_id \
    -elements $elements \
    -orderby { 
        type {
            orderby lower(t.pretty_name),x.clipped
        }
        object_title {
            orderby lower(x.object_title),x.clipped
        }
        clipboard {
            orderby lower(x.clipboard),x.clipped
        }
        clipped { 
            orderby x.clipped
        } 
    } -filters { 
        object_one {}
    } -bulk_actions $bulk -bulk_action_export_vars object_one 

set now [clock_to_ansi [clock seconds]]

db_multirow -extend extra relate relate "
 SELECT * FROM (
   SELECT t.pretty_name,o.object_id, co.title as clipboard, coalesce(o.title,'? '|| o.object_type || o.object_id) as object_title, to_char(cm.clipped_on,'YYYY-MM-DD HH24:MI:SS') as clipped
     FROM acs_objects o, cop_clipboards c, acs_objects co, cop_clipboard_object_map cm, acs_object_types t
    WHERE c.owner_id = :user_id
      and cm.clipboard_id = c.clipboard_id
      and o.object_id = cm.object_id
      and co.object_id = c.clipboard_id 
      and cm.object_id != :object_one
      and t.object_type = o.object_type
    UNION ALL
   SELECT t.pretty_name, v.object_id, 'viewed', coalesce(o.title,'? ' || o.object_type || o.object_id) as object_title, to_char(v.last_viewed,'YYYY-MM-DD HH24:MI:SS')
     FROM cop_object_views v, acs_objects o, acs_object_types t
    WHERE o.object_id = v.object_id
      and v.viewer_id = :user_id
      and v.object_id != :object_one
      and t.object_type = o.object_type
  ) x 
  WHERE not exists (
       SELECT 1 
         FROM acs_rels 
        WHERE rel_type = 'cop_rel' 
          and (    (object_id_one = :object_one and object_id_two = x.object_id)
                or (object_id_one = x.object_id and object_id_two = :object_one)))
   [template::list::orderby_clause -orderby -name "relate"]" {
       set clipped [regsub -all { } [util::age_pretty -hours_limit 0 -mode_2_fmt "%X %a" -mode_3_fmt "%x" -timestamp_ansi $clipped -sysdate_ansi $now] {\&nbsp;}]
   }


