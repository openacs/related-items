# /packages/cop-ui/www/related/index.tcl
ad_page_contract {
    Display the recently related items

    @author Jeff Davis (davis@xarg.net)
    @creation-date 11/12/2003

    @cvs-id $Id$
} {
    {orderby "related_on,desc"}    
}

set user_id [auth::refresh_login]

set title "Related items"

set context [list {related items}]

set elements {
    object_one_title {
        label {Item1}
        display_template {<a href="/o/@related.object_id_one@">@related.object_one_title@</a>}
    }
    object_two_title {
        label {Item2}
        display_template {<a href="/o/@related.object_id_two@">@related.object_two_title@</a>}
    }
    related_on {
        label {Added}
    }
    name {
        label {By}
	link_url_col user_url 
    }
}

set packages [cop::util::packages -node_id [ad_conn node_id]]

template::list::create \
    -name related \
    -multirow related \
    -elements $elements \
    -orderby { 
        object_one_title { orderby lower(o1.title) }
        object_two_title { orderby lower(o2.title) }
        related_on { orderby ro.creation_date }
        name { orderby {lower(person__name(ro.creation_user))}}
    }

db_multirow -extend {extra user_url} related related "
    SELECT to_char(ro.creation_date,'YYYY-MM-DD HH24:MI') as related_on, coalesce(o1.title,'? '||o1.object_type||o1.object_id) as object_one_title, o2.title as object_two_title, person__name(ro.creation_user) as name, object_id_one, object_id_two
      FROM cop_rels r, acs_objects o1, acs_objects o2, acs_rels ar, acs_objects ro
     WHERE o1.object_id = ar.object_id_one
       and o2.object_id = ar.object_id_two
       and ar.rel_id = r.rel_id 
       and ro.object_id = r.rel_id
       and ( o1.package_id in ([join $packages ,])
             or o2.package_id in ([join $packages ,]))
   [template::list::orderby_clause -orderby -name "related"]" {
       set user_url [acs_community_member_url -user_id $user_id]
       set extra foo
   }
