-- Related Items
--
-- Drop the relations data package and tables.
--
-- Copyright (C) 2003 Jeff Davis
-- @author Jeff Davis davis@xarg.net
-- @creation-date 10/22/2003
--
-- @cvs-id $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

delete from acs_rel_types where rel_type = 'content_rel';

create or replace function tmp_content_relations_delete ()
returns integer as '
declare
  coll_rec RECORD;
begin
  for coll_rec in select object_id
      from acs_objects
      where object_type = ''content_rel''
    loop
      PERFORM acs_object__delete (coll_rec.object_id);
    end loop;

    return 1;
end; ' language 'plpgsql';

select tmp_content_relations_delete ();
drop function tmp_content_relations_delete ();

select acs_object_type__drop_type('content_rel', 'f');
drop table content_rels;

select drop_package('content_rel');


