# /packages/related-items/tcl/relation-procs.tcl
ad_library {
    TCL library for the related items

    @author Jeff Davis <davis@xarg.net>

    @creation-date 10/23/2003
    @cvs-id $Id$
}

namespace eval relation {}

ad_proc -public relation::get_related {
    -object_id
    -datasource
} {
    sets a multirow with the related items for object_id

    @return number of related items + the multirow is created as side effect

    @author Jeff Davis davis@xarg.net
    @creation-date 2004-01-30
} {
    # here we pull out all rels where object_one or object_two matches and
    # return the information for the object which is not the one we are
    # are querying on
    db_multirow $datasource related {
        SELECT ar.rel_id,
          (case when ar.object_id_one = :object_id then ar.object_id_two else ar.object_id_one end) as object_id,
          to_char(ro.creation_date,'YYYY-MM-DD HH24:MI') as related_on,
          coalesce(o1.title,'? '||o1.object_type||' '||o1.object_id) as object_title,
          person__name(ro.creation_user) as name
        FROM content_rels r, acs_objects o1, acs_rels ar, acs_objects ro
        WHERE ( (ar.object_id_one = :object_id and o1.object_id = ar.object_id_two)
                 or ( ar.object_id_two = :object_id and o1.object_id = ar.object_id_one) )
          and ar.rel_id = r.rel_id
          and ro.object_id = r.rel_id
    }

    return [template::multirow size $datasource]
}

