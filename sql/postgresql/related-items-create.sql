-- Related items
--
-- Relate items the openacs way!  For publicly visible related items (like relating forum post to a bug)
--
-- Copyright (C) 2003 Jeff Davis
-- @author Jeff Davis <davis@xarg.net>
-- @creation-date 10/22/2003
--
-- @cvs-id $Id$
--
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

create table content_rels (
        rel_id         integer references acs_rels(rel_id)
);

comment on table content_rels is 'content_rels is for higher level content relations supported by the related-items package.  This is a stupid table -- just there to feed the table gods.  DonB rescue me from this absurdity.';

select acs_object_type__create_type(
        'content_rel',
        'Related content',
        'Related content',
        'relationship',
        'content_rels',
        'rel_id',
        'content_rel',
        'f',
        'content_rel__title',
        null
);

insert into acs_rel_types (rel_type, object_type_one, role_one, min_n_rels_one, max_n_rels_one, object_type_two, role_two, min_n_rels_two, max_n_rels_two)
values ('content_rel','acs_object',null,0,null,'acs_object',null,0,null);


create or replace function content_rel__new (integer,integer,integer,integer,integer,varchar)
returns integer as '
declare
  new_rel_id            alias for $1;  -- default null
  object_id_one         alias for $2;
  object_id_two         alias for $3;
  context_id            alias for $4;  -- default null
  creation_user         alias for $5;  -- default null
  creation_ip           alias for $6;  -- default null
  v_rel_id              acs_rels.rel_id%TYPE;
begin
  v_rel_id := acs_rel__new(new_rel_id, ''content_rel'',object_id_one, object_id_two, context_id, creation_user, creation_ip);

  insert into content_rels(rel_id) values (v_rel_id);

  return v_rel_id;

end;' language 'plpgsql';

select define_function_args('content_rel__new','rel_id,object_id_one,object_id_two,context_id,creation_user,creation_ip');


create or replace function content_rel__del(integer) 
returns integer as '
declare
  rel_id                 alias for $1;
begin
    PERFORM acs_object__delete(rel_id);

    return 0;
end;' language 'plpgsql';

select define_function_args('content_rel__del','rel_id');


create or replace function content_rel__title(integer) 
returns varchar as '
declare
  rel_id                 alias for $1;
  v_title       acs_objects.title%TYPE;
begin
    select title into v_title from acs_objects where object_id = rel_id and object_type = ''content_rel'';
    return v_title;
end;' language 'plpgsql';

select define_function_args('content_rel__title','rel_id');
