--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.12
-- Dumped by pg_dump version 9.6.23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: aed1995; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA aed1995;


--
-- Name: aed1998; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA aed1998;


--
-- Name: aed2002; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA aed2002;


--
-- Name: aed2007; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA aed2007;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: histogram; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.histogram AS (
	min double precision,
	max double precision,
	count bigint,
	percent double precision
);


--
-- Name: itinerary; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.itinerary AS (
	id integer,
	order_id integer,
	vehicle_id integer,
	point integer,
	at timestamp with time zone
);


--
-- Name: link_point; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.link_point AS (
	id integer,
	name character varying
);


--
-- Name: path_result; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.path_result AS (
	vertex_id integer,
	edge_id integer,
	cost double precision
);


--
-- Name: quantile; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.quantile AS (
	quantile double precision,
	value double precision
);


--
-- Name: valuecount; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.valuecount AS (
	value double precision,
	count integer,
	percent double precision
);


--
-- Name: vertex_result; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vertex_result AS (
	x double precision,
	y double precision
);


--
-- Name: _add_raster_constraint_regular_blocking(name, name, name); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._add_raster_constraint_regular_blocking(rastschema name, rasttable name, rastcolumn name) RETURNS boolean
    LANGUAGE plpgsql STRICT
    AS $_$
	DECLARE
		fqtn text;
		cn name;
		sql text;
	BEGIN

		RAISE INFO 'The regular_blocking constraint is just a flag indicating that the column "%" is regularly blocked.  It is up to the end-user to ensure that the column is truely regularly blocked.', quote_ident($3);

		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_regular_blocking_' || $3;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (TRUE)';
		RETURN _add_raster_constraint(cn, sql);
	END;
	$_$;


--
-- Name: _st_aspect4ma(double precision[], text, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_aspect4ma(matrix double precision[], nodatamode text, VARIADIC args text[]) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        pwidth float;
        pheight float;
        dz_dx float;
        dz_dy float;
        aspect float;
    BEGIN
        pwidth := args[1]::float;
        pheight := args[2]::float;
        dz_dx := ((matrix[3][1] + 2.0 * matrix[3][2] + matrix[3][3]) - (matrix[1][1] + 2.0 * matrix[1][2] + matrix[1][3])) / (8.0 * pwidth);
        dz_dy := ((matrix[1][3] + 2.0 * matrix[2][3] + matrix[3][3]) - (matrix[1][1] + 2.0 * matrix[2][1] + matrix[3][1])) / (8.0 * pheight);
        IF abs(dz_dx) = 0::float AND abs(dz_dy) = 0::float THEN
            RETURN -1;
        END IF;

        aspect := atan2(dz_dy, -dz_dx);
        IF aspect > (pi() / 2.0) THEN
            RETURN (5.0 * pi() / 2.0) - aspect;
        ELSE
            RETURN (pi() / 2.0) - aspect;
        END IF;
    END;
    $$;


--
-- Name: _st_hillshade4ma(double precision[], text, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_hillshade4ma(matrix double precision[], nodatamode text, VARIADIC args text[]) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        pwidth float;
        pheight float;
        dz_dx float;
        dz_dy float;
        zenith float;
        azimuth float;
        slope float;
        aspect float;
        max_bright float;
        elevation_scale float;
    BEGIN
        pwidth := args[1]::float;
        pheight := args[2]::float;
        azimuth := (5.0 * pi() / 2.0) - args[3]::float;
        zenith := (pi() / 2.0) - args[4]::float;
        dz_dx := ((matrix[3][1] + 2.0 * matrix[3][2] + matrix[3][3]) - (matrix[1][1] + 2.0 * matrix[1][2] + matrix[1][3])) / (8.0 * pwidth);
        dz_dy := ((matrix[1][3] + 2.0 * matrix[2][3] + matrix[3][3]) - (matrix[1][1] + 2.0 * matrix[2][1] + matrix[3][1])) / (8.0 * pheight);
        elevation_scale := args[6]::float;
        slope := atan(sqrt(elevation_scale * pow(dz_dx, 2.0) + pow(dz_dy, 2.0)));
        -- handle special case of 0, 0
        IF abs(dz_dy) = 0::float AND abs(dz_dy) = 0::float THEN
            -- set to pi as that is the expected PostgreSQL answer in Linux
            aspect := pi();
        ELSE
            aspect := atan2(dz_dy, -dz_dx);
        END IF;
        max_bright := args[5]::float;

        IF aspect < 0 THEN
            aspect := aspect + (2.0 * pi());
        END IF;

        RETURN max_bright * ( (cos(zenith)*cos(slope)) + (sin(zenith)*sin(slope)*cos(azimuth - aspect)) );
    END;
    $$;


--
-- Name: _st_intersects(public.raster, public.geometry, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_intersects(rast public.raster, geom public.geometry, nband integer DEFAULT NULL::integer) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE COST 1000
    AS $$
	DECLARE
		gr raster;
		scale double precision;
	BEGIN
		IF ST_Intersects(geom, ST_ConvexHull(rast)) IS NOT TRUE THEN
			RETURN FALSE;
		ELSEIF nband IS NULL THEN
			RETURN TRUE;
		END IF;

		-- scale is set to 1/100th of raster for granularity
		SELECT least(scalex, scaley) / 100. INTO scale FROM ST_Metadata(rast);
		gr := _st_asraster(geom, scale, scale);
		IF gr IS NULL THEN
			RAISE EXCEPTION 'Unable to convert geometry to a raster';
			RETURN FALSE;
		END IF;

		RETURN ST_Intersects(rast, nband, gr, 1);
	END;
	$$;


--
-- Name: _st_mapalgebra4unionfinal1(public.raster); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_mapalgebra4unionfinal1(rast public.raster) RETURNS public.raster
    LANGUAGE plpgsql
    AS $$
    DECLARE
    BEGIN
    	-- NOTE: I have to sacrifice RANGE.  Sorry RANGE.  Any 2 banded raster is going to be treated
    	-- as a MEAN
        IF ST_NumBands(rast) = 2 THEN
            RETURN ST_MapAlgebraExpr(rast, 1, rast, 2, 'CASE WHEN [rast2.val] > 0 THEN [rast1.val] / [rast2.val]::float8 ELSE NULL END'::text, NULL::text, 'UNION'::text, NULL::text, NULL::text, NULL::double precision);
        ELSE
            RETURN rast;
        END IF;
    END;
    $$;


--
-- Name: _st_mapalgebra4unionstate(public.raster, public.raster); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_mapalgebra4unionstate(rast1 public.raster, rast2 public.raster) RETURNS public.raster
    LANGUAGE sql
    AS $_$
        SELECT _ST_MapAlgebra4UnionState($1,$2, 'LAST', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
    $_$;


--
-- Name: _st_mapalgebra4unionstate(public.raster, public.raster, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_mapalgebra4unionstate(rast1 public.raster, rast2 public.raster, bandnum integer) RETURNS public.raster
    LANGUAGE sql
    AS $_$
        SELECT _ST_MapAlgebra4UnionState($1,ST_Band($2,$3), 'LAST', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
    $_$;


--
-- Name: _st_mapalgebra4unionstate(public.raster, public.raster, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_mapalgebra4unionstate(rast1 public.raster, rast2 public.raster, p_expression text) RETURNS public.raster
    LANGUAGE sql
    AS $_$
        SELECT _ST_MapAlgebra4UnionState($1,$2, $3, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
    $_$;


--
-- Name: _st_mapalgebra4unionstate(public.raster, public.raster, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_mapalgebra4unionstate(rast1 public.raster, rast2 public.raster, bandnum integer, p_expression text) RETURNS public.raster
    LANGUAGE sql
    AS $_$
        SELECT _ST_MapAlgebra4UnionState($1, ST_Band($2,$3), $4, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
    $_$;


--
-- Name: _st_mapalgebra4unionstate(public.raster, public.raster, text, text, text, double precision, text, text, text, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_mapalgebra4unionstate(rast1 public.raster, rast2 public.raster, p_expression text, p_nodata1expr text, p_nodata2expr text, p_nodatanodataval double precision, t_expression text, t_nodata1expr text, t_nodata2expr text, t_nodatanodataval double precision) RETURNS public.raster
    LANGUAGE plpgsql
    AS $$
    DECLARE
        t_raster raster;
        p_raster raster;
    BEGIN
        -- With the new ST_MapAlgebraExpr we must split the main expression in three expressions: expression, nodata1expr, nodata2expr and a nodatanodataval
        -- ST_MapAlgebraExpr(rast1 raster, band1 integer, rast2 raster, band2 integer, expression text, pixeltype text, extentexpr text, nodata1expr text, nodata2expr text, nodatanodatadaval double precision)
        -- We must make sure that when NULL is passed as the first raster to ST_MapAlgebraExpr, ST_MapAlgebraExpr resolve the nodata1expr
        -- Note: rast2 is always a single band raster since it is the accumulated raster thus far
        -- 		There we always set that to band 1 regardless of what band num is requested
        IF upper(p_expression) = 'LAST' THEN
            --RAISE NOTICE 'last asked for ';
            RETURN ST_MapAlgebraExpr(rast1, 1, rast2, 1, '[rast2.val]'::text, NULL::text, 'UNION'::text, '[rast2.val]'::text, '[rast1.val]'::text, NULL::double precision);
        ELSIF upper(p_expression) = 'FIRST' THEN
            RETURN ST_MapAlgebraExpr(rast1, 1, rast2, 1, '[rast1.val]'::text, NULL::text, 'UNION'::text, '[rast2.val]'::text, '[rast1.val]'::text, NULL::double precision);
        ELSIF upper(p_expression) = 'MIN' THEN
            RETURN ST_MapAlgebraExpr(rast1, 1, rast2, 1, 'LEAST([rast1.val], [rast2.val])'::text, NULL::text, 'UNION'::text, '[rast2.val]'::text, '[rast1.val]'::text, NULL::double precision);
        ELSIF upper(p_expression) = 'MAX' THEN
            RETURN ST_MapAlgebraExpr(rast1, 1, rast2, 1, 'GREATEST([rast1.val], [rast2.val])'::text, NULL::text, 'UNION'::text, '[rast2.val]'::text, '[rast1.val]'::text, NULL::double precision);
        ELSIF upper(p_expression) = 'COUNT' THEN
            RETURN ST_MapAlgebraExpr(rast1, 1, rast2, 1, '[rast1.val] + 1'::text, NULL::text, 'UNION'::text, '1'::text, '[rast1.val]'::text, 0::double precision);
        ELSIF upper(p_expression) = 'SUM' THEN
            RETURN ST_MapAlgebraExpr(rast1, 1, rast2, 1, '[rast1.val] + [rast2.val]'::text, NULL::text, 'UNION'::text, '[rast2.val]'::text, '[rast1.val]'::text, NULL::double precision);
        ELSIF upper(p_expression) = 'RANGE' THEN
        -- have no idea what this is 
            t_raster = ST_MapAlgebraExpr(rast1, 2, rast2, 1, 'LEAST([rast1.val], [rast2.val])'::text, NULL::text, 'UNION'::text, '[rast2.val]'::text, '[rast1.val]'::text, NULL::double precision);
            p_raster := _ST_MapAlgebra4UnionState(rast1, rast2, 'MAX'::text, NULL::text, NULL::text, NULL::double precision, NULL::text, NULL::text, NULL::text, NULL::double precision);
            RETURN ST_AddBand(p_raster, t_raster, 1, 2);
        ELSIF upper(p_expression) = 'MEAN' THEN
        -- looks like t_raster is used to keep track of accumulated count
        -- and p_raster is there to keep track of accumulated sum and final state function
        -- would then do a final map to divide them.  This one is currently broken because 
        	-- have not reworked it so it can do without a final function
            t_raster = ST_MapAlgebraExpr(rast1, 2, rast2, 1, '[rast1.val] + 1'::text, NULL::text, 'UNION'::text, '1'::text, '[rast1.val]'::text, 0::double precision);
            p_raster := _ST_MapAlgebra4UnionState(rast1, rast2, 'SUM'::text, NULL::text, NULL::text, NULL::double precision, NULL::text, NULL::text, NULL::text, NULL::double precision);
            RETURN ST_AddBand(p_raster, t_raster, 1, 2);
        ELSE
            IF t_expression NOTNULL AND t_expression != '' THEN
                t_raster = ST_MapAlgebraExpr(rast1, 2, rast2, 1, t_expression, NULL::text, 'UNION'::text, t_nodata1expr, t_nodata2expr, t_nodatanodataval::double precision);
                p_raster = ST_MapAlgebraExpr(rast1, 1, rast2, 1, p_expression, NULL::text, 'UNION'::text, p_nodata1expr, p_nodata2expr, p_nodatanodataval::double precision);
                RETURN ST_AddBand(p_raster, t_raster, 1, 2);
            END IF;
            RETURN ST_MapAlgebraExpr(rast1, 1, rast2, 1, p_expression, NULL, 'UNION'::text, NULL::text, NULL::text, NULL::double precision);
        END IF;
    END;
    $$;


--
-- Name: _st_slope4ma(double precision[], text, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public._st_slope4ma(matrix double precision[], nodatamode text, VARIADIC args text[]) RETURNS double precision
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        pwidth float;
        pheight float;
        dz_dx float;
        dz_dy float;
    BEGIN
        pwidth := args[1]::float;
        pheight := args[2]::float;
        dz_dx := ((matrix[3][1] + 2.0 * matrix[3][2] + matrix[3][3]) - (matrix[1][1] + 2.0 * matrix[1][2] + matrix[1][3])) / (8.0 * pwidth);
        dz_dy := ((matrix[1][3] + 2.0 * matrix[2][3] + matrix[3][3]) - (matrix[1][1] + 2.0 * matrix[2][1] + matrix[3][1])) / (8.0 * pheight);
        RETURN atan(sqrt(pow(dz_dx, 2.0) + pow(dz_dy, 2.0)));
    END;
    $$;


--
-- Name: add_vertices_geometry(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_vertices_geometry(geom_table character varying) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
	vertices_table varchar := quote_ident(geom_table) || '_vertices';
BEGIN
	
	BEGIN
		EXECUTE 'SELECT addGeometryColumn(''' || 
                        quote_ident(vertices_table)  || 
                        ''', ''the_geom'', -1, ''POINT'', 2)';
	EXCEPTION 
		WHEN DUPLICATE_COLUMN THEN
	END;

	EXECUTE 'UPDATE ' || quote_ident(vertices_table) || 
                ' SET the_geom = NULL';

	EXECUTE 'UPDATE ' || quote_ident(vertices_table) || 
                ' SET the_geom = startPoint(geometryn(m.the_geom, 1)) FROM ' ||
                 quote_ident(geom_table) || 
                ' m where geom_id = m.source';

	EXECUTE 'UPDATE ' || quote_ident(vertices_table) || 
                ' set the_geom = endPoint(geometryn(m.the_geom, 1)) FROM ' || 
                quote_ident(geom_table) || 
                ' m where geom_id = m.target_id AND ' || 
                quote_ident(vertices_table) || 
                '.the_geom IS NULL';

	RETURN;
END;
$$;


--
-- Name: affine(public.geometry, double precision, double precision, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.affine(public.geometry, double precision, double precision, double precision, double precision, double precision, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  $2, $3, 0,  $4, $5, 0,  0, 0, 1,  $6, $7, 0)$_$;


--
-- Name: asgml(public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.asgml(public.geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML(2, $1, 15, 0, null)$_$;


--
-- Name: asgml(public.geometry, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.asgml(public.geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML(2, $1, $2, 0, null)$_$;


--
-- Name: askml(public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.askml(public.geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML(2, ST_Transform($1,4326), 15, null)$_$;


--
-- Name: askml(public.geometry, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.askml(public.geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML(2, ST_transform($1,4326), $2, null)$_$;


--
-- Name: askml(integer, public.geometry, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.askml(integer, public.geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML($1, ST_Transform($2,4326), $3, null)$_$;


--
-- Name: assign_vertex_id(character varying, double precision, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assign_vertex_id(geom_table character varying, tolerance double precision, geo_cname character varying, gid_cname character varying) RETURNS character varying
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
    _r record;
    source_id int;
    target_id int;
    srid integer;
BEGIN

    BEGIN
    DROP TABLE vertices_tmp;
    EXCEPTION 
    WHEN UNDEFINED_TABLE THEN
    END;

    EXECUTE 'CREATE TABLE vertices_tmp (id serial)';

--    FOR _r IN EXECUTE 'SELECT srid FROM geometry_columns WHERE f_table_name='''|| quote_ident(geom_table)||''';' LOOP
--	srid := _r.srid;

    srid := Find_SRID('public',quote_ident(geom_table),quote_ident(geo_cname));


    EXECUTE 'SELECT addGeometryColumn(''vertices_tmp'', ''the_geom'', '||srid||', ''POINT'', 2)';
    CREATE INDEX vertices_tmp_idx ON vertices_tmp USING GIST (the_geom);
			
    FOR _r IN EXECUTE 'SELECT ' || quote_ident(gid_cname) || ' AS id,'
	    || ' StartPoint('|| quote_ident(geo_cname) ||') AS source,'
            || ' EndPoint('|| quote_ident(geo_cname) ||') as target'
	    || ' FROM ' || quote_ident(geom_table) 
    LOOP
        
        source_id := point_to_id(setsrid(_r.source, srid), tolerance);
	target_id := point_to_id(setsrid(_r.target, srid), tolerance);
								
	EXECUTE 'update ' || quote_ident(geom_table) || 
		' SET source = ' || source_id || 
		', target = ' || target_id || 
		' WHERE ' || quote_ident(gid_cname) || ' =  ' || _r.id;
    END LOOP;

    RETURN 'OK';

END;
$$;


--
-- Name: bdmpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bdmpolyfromtext(text, integer) RETURNS public.geometry
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	geomtext alias for $1;
	srid alias for $2;
	mline geometry;
	geom geometry;
BEGIN
	mline := ST_MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
	END IF;

	geom := ST_Multi(ST_BuildArea(mline));

	RETURN geom;
END;
$_$;


--
-- Name: bdpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bdpolyfromtext(text, integer) RETURNS public.geometry
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	geomtext alias for $1;
	srid alias for $2;
	mline geometry;
	geom geometry;
BEGIN
	mline := ST_MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
	END IF;

	geom := ST_BuildArea(mline);

	IF GeometryType(geom) != 'POLYGON'
	THEN
		RAISE EXCEPTION 'Input returns more then a single polygon, try using BdMPolyFromText instead';
	END IF;

	RETURN geom;
END;
$_$;


--
-- Name: buffer(public.geometry, double precision, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.buffer(public.geometry, double precision, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_Buffer($1, $2, $3)$_$;


--
-- Name: cleangeometry(public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cleangeometry(public.geometry) RETURNS public.geometry
    LANGUAGE plpgsql
    AS $_$DECLARE
  inGeom ALIAS for $1;
  outGeom geometry;
  tmpLinestring geometry;

Begin
  
  outGeom := NULL;
  
-- Clean Process for Polygon 
  IF (GeometryType(inGeom) = 'POLYGON' OR GeometryType(inGeom) = 'MULTIPOLYGON') THEN

-- Only process if geometry is not valid, 
-- otherwise put out without change
    if not isValid(inGeom) THEN
    
-- create nodes at all self-intersecting lines by union the polygon boundaries
-- with the startingpoint of the boundary.  
      tmpLinestring := st_union(st_multi(st_boundary(inGeom)),st_pointn(boundary(inGeom),1));
      outGeom = buildarea(tmpLinestring);      
      IF (GeometryType(inGeom) = 'MULTIPOLYGON') THEN      
        RETURN st_multi(outGeom);
      ELSE
        RETURN outGeom;
      END IF;
    else    
      RETURN inGeom;
    END IF;


------------------------------------------------------------------------------
-- Clean Process for LINESTRINGS, self-intersecting parts of linestrings 
-- will be divided into multiparts of the mentioned linestring 
------------------------------------------------------------------------------
  ELSIF (GeometryType(inGeom) = 'LINESTRING') THEN
    
-- create nodes at all self-intersecting lines by union the linestrings
-- with the startingpoint of the linestring.  
    outGeom := st_union(st_multi(inGeom),st_pointn(inGeom,1));
    RETURN outGeom;
  ELSIF (GeometryType(inGeom) = 'MULTILINESTRING') THEN 
    outGeom := multi(st_union(st_multi(inGeom),st_pointn(inGeom,1)));
    RETURN outGeom;
  ELSE 
    RAISE NOTICE 'The input type % is not supported',GeometryType(inGeom);
    RETURN inGeom;
  END IF;	  
End;$_$;


--
-- Name: create_webid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_webid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		--RAISE NOTICE 'table: %', TG_TABLE_NAME;
		IF TG_TABLE_NAME = 'survey_faecal_dna_strata' THEN
		  --RAISE NOTICE 'in the if';
		  --RAISE NOTICE 'id: % % %', NEW.id, OLD.id, OLD.web_id;
			NEW.web_id := concat('GD',NEW.id); 
		  --RAISE NOTICE 'web_id: %', NEW.web_id;
		ELSIF TG_TABLE_NAME = 'survey_individual_registrations' THEN
			NEW.web_id := concat('IR',NEW.id);
		ELSIF TG_TABLE_NAME = 'survey_others' THEN
			NEW.web_id := concat('O',NEW.id);
		ELSIF TG_TABLE_NAME = 'survey_ground_total_count_strata' THEN
			NEW.web_id := concat('GT',NEW.id);
		ELSIF TG_TABLE_NAME = 'survey_ground_sample_count_strata' THEN
			NEW.web_id := concat('GS',NEW.id);
		ELSIF TG_TABLE_NAME = 'survey_dung_count_line_transect_strata' THEN
			NEW.web_id := concat('DC',NEW.id);
		ELSIF TG_TABLE_NAME = 'survey_aerial_total_count_strata' THEN
			NEW.web_id := concat('AT',NEW.id);
		ELSE
			NEW.web_id := concat('AS',NEW.id);
		END IF;
		RETURN NEW;
		
END;
$$;


--
-- Name: ez_darp(text, text, text, text, integer, integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ez_darp(order_table text, vehicle_table text, distance_table text, penalties_table text, depot integer, depot_point integer, penalties integer, orders text) RETURNS SETOF public.itinerary
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
	query text;
	path_result record;
	schedule itinerary;
BEGIN

	query := 'SELECT * FROM darp(''SELECT * FROM '||quote_ident(order_table)||' WHERE order_id IN ('||orders||') ORDER BY id DESC'',
			''SELECT * FROM '||quote_ident(vehicle_table)||' WHERE depot ='||depot||''', 
			''SELECT * FROM '||quote_ident(distance_table)||''', 
			'||depot||', 
			'||depot_point||', 
			''SELECT * FROM '||quote_ident(penalties_table)||' WHERE id ='||penalties||''')';
			
	FOR path_result IN EXECUTE query LOOP
	
         schedule.id  := path_result.id;
         schedule.order_id  := path_result.order_id;
         schedule.vehicle_id  := path_result.vehicle_id;
         schedule.point  := path_result.point;
         schedule.at  := path_result.at;
               
         RETURN NEXT schedule;

	END LOOP;
	RETURN;
END;
$$;


--
-- Name: find_extent(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_extent(text, text) RETURNS public.box2d
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	tablename alias for $1;
	columnname alias for $2;
	myrec RECORD;

BEGIN
	FOR myrec IN EXECUTE 'SELECT ST_Extent("' || columnname || '") As extent FROM "' || tablename || '"' LOOP
		return myrec.extent;
	END LOOP;
END;
$_$;


--
-- Name: find_extent(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_extent(text, text, text) RETURNS public.box2d
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	schemaname alias for $1;
	tablename alias for $2;
	columnname alias for $3;
	myrec RECORD;

BEGIN
	FOR myrec IN EXECUTE 'SELECT ST_Extent("' || columnname || '") FROM "' || schemaname || '"."' || tablename || '" As extent ' LOOP
		return myrec.extent;
	END LOOP;
END;
$_$;


--
-- Name: find_nearest_link_within_distance(character varying, double precision, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_nearest_link_within_distance(point character varying, distance double precision, tbl character varying) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
    row record;
    x float8;
    y float8;
    
    srid integer;
    
BEGIN

    FOR row IN EXECUTE 'select getsrid(the_geom) as srid from '||tbl||' where gid = (select min(gid) from '||tbl||')' LOOP
    END LOOP;
	srid:= row.srid;
    
    
    FOR row in EXECUTE 'select x(GeometryFromText('''||point||''', '||srid||')) as x' LOOP
    END LOOP;
	x:=row.x;

    FOR row in EXECUTE 'select y(GeometryFromText('''||point||''', '||srid||')) as y' LOOP
    END LOOP;
	y:=row.y;


    FOR row in EXECUTE 'select gid, distance(the_geom, GeometryFromText('''||point||''', '||srid||')) as dist from '||tbl||
			    ' where setsrid(''BOX3D('||x-distance||' '||y-distance||', '||x+distance||' '||y+distance||')''::BOX3D, '||srid||')&&the_geom order by dist asc limit 1'
    LOOP
    END LOOP;

    IF row.gid IS NULL THEN
	    --RAISE EXCEPTION 'Data cannot be matched';
	    RETURN NULL;
    END IF;

    RETURN row.gid;

END;
$$;


--
-- Name: find_nearest_node_within_distance(character varying, double precision, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_nearest_node_within_distance(point character varying, distance double precision, tbl character varying) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
    row record;
    x float8;
    y float8;
    d1 double precision;
    d2 double precision;
    d  double precision;
    field varchar;

    node integer;
    source integer;
    target integer;
    
    srid integer;
    
BEGIN

    FOR row IN EXECUTE 'select getsrid(the_geom) as srid from '||tbl||' where gid = (select min(gid) from '||tbl||')' LOOP
    END LOOP;
	srid:= row.srid;


    FOR row in EXECUTE 'select x(GeometryFromText('''||point||''', '||srid||')) as x' LOOP
    END LOOP;
	x:=row.x;

    FOR row in EXECUTE 'select y(GeometryFromText('''||point||''', '||srid||')) as y' LOOP
    END LOOP;
	y:=row.y;


    FOR row in EXECUTE 'select source, distance(StartPoint(the_geom), GeometryFromText('''||point||''', '||srid||')) as dist from '||tbl||
			    ' where setsrid(''BOX3D('||x-distance||' '||y-distance||', '||x+distance||' '||y+distance||')''::BOX3D, '||srid||')&&the_geom order by dist asc limit 1'
    LOOP
    END LOOP;
    
    d1:=row.dist;
    source:=row.source;


    FOR row in EXECUTE 'select target, distance(EndPoint(the_geom), GeometryFromText('''||point||''', '||srid||')) as dist from '||tbl||
			    ' where setsrid(''BOX3D('||x-distance||' '||y-distance||', '||x+distance||' '||y+distance||')''::BOX3D, '||srid||')&&the_geom order by dist asc limit 1'
    LOOP
    END LOOP;

    
    d2:=row.dist;
    target:=row.target;
    IF d1<d2 THEN
	node:=source;
        d:=d1;
    ELSE
	node:=target;
        d:=d2;
    END IF;

    IF d=NULL OR d>distance THEN
        node:=NULL;
    END IF;

    RETURN node;

END;
$$;


--
-- Name: find_node_by_nearest_link_within_distance(character varying, double precision, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_node_by_nearest_link_within_distance(point character varying, distance double precision, tbl character varying) RETURNS public.link_point
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
    row record;
    link integer;
    d1 double precision;
    d2 double precision;
    field varchar;
    res link_point;
    
    srid integer;
BEGIN

    FOR row IN EXECUTE 'select getsrid(the_geom) as srid from '||tbl||' where gid = (select min(gid) from '||tbl||')' LOOP
    END LOOP;
	srid:= row.srid;


    
    FOR row in EXECUTE 'select id from find_nearest_link_within_distance('''||point||''', '||distance||', '''||tbl||''') as id'
    LOOP
    END LOOP;
    IF row.id is null THEN
        res.id = -1;
        RETURN res;
    END IF;
    link:=row.id;

    
    FOR row in EXECUTE 'select distance((select StartPoint(the_geom) from '||tbl||' where gid='||link||'), GeometryFromText('''||point||''', '||srid||')) as dist'
    LOOP
    END LOOP;
    d1:=row.dist;

    FOR row in EXECUTE 'select distance((select EndPoint(the_geom) from '||tbl||' where gid='||link||'), GeometryFromText('''||point||''', '||srid||')) as dist'
    LOOP
    END LOOP;
    d2:=row.dist;

    IF d1<d2 THEN
	field:='source';
    ELSE
	field:='target';
    END IF;
    
    FOR row in EXECUTE 'select '||field||' as id, '''||field||''' as f from '||tbl||' where gid='||link
    LOOP
    END LOOP;
        
    res.id:=row.id;
    res.name:=row.f;
    
    RETURN res;


END;
$$;


--
-- Name: fix_geometry_columns(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fix_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	mislinked record;
	result text;
	linked integer;
	deleted integer;
	foundschema integer;
BEGIN

	-- Since 7.3 schema support has been added.
	-- Previous postgis versions used to put the database name in
	-- the schema column. This needs to be fixed, so we try to
	-- set the correct schema for each geometry_colums record
	-- looking at table, column, type and srid.
	
	return 'This function is obsolete now that geometry_columns is a view';

END;
$$;


--
-- Name: geomcollfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.geomcollfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


--
-- Name: geomcollfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.geomcollfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


--
-- Name: geomcollfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.geomcollfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromWKB($1)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: geomcollfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.geomcollfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromWKB($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: geomfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.geomfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_GeomFromText($1)$_$;


--
-- Name: geomfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.geomfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_GeomFromText($1, $2)$_$;


--
-- Name: geomfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.geomfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_SetSRID(ST_GeomFromWKB($1), $2)$_$;


--
-- Name: insert_vertex(character varying, anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_vertex(vertices_table character varying, geom_id anyelement) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
        vertex_id int;
        myrec record;
BEGIN
        LOOP
          FOR myrec IN EXECUTE 'SELECT id FROM ' || 
                     quote_ident(vertices_table) || 
                     ' WHERE geom_id = ' || quote_literal(geom_id)  LOOP

                        IF myrec.id IS NOT NULL THEN
                                RETURN myrec.id;
                        END IF;
          END LOOP; 
          EXECUTE 'INSERT INTO ' || quote_ident(vertices_table) || 
                  ' (geom_id) VALUES (' || quote_literal(geom_id) || ')';
        END LOOP;
END;
$$;


--
-- Name: linefromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linefromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'LINESTRING'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


--
-- Name: linefromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linefromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'LINESTRING'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


--
-- Name: linefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linefromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'LINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: linefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linefromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: linestringfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linestringfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT LineFromText($1)$_$;


--
-- Name: linestringfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linestringfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT LineFromText($1, $2)$_$;


--
-- Name: linestringfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linestringfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'LINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: linestringfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.linestringfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: locate_along_measure(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.locate_along_measure(public.geometry, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT ST_locate_between_measures($1, $2, $2) $_$;


--
-- Name: mlinefromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mlinefromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTILINESTRING'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


--
-- Name: mlinefromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mlinefromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


--
-- Name: mlinefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mlinefromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: mlinefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mlinefromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: mpointfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mpointfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTIPOINT'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


--
-- Name: mpointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mpointfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1,$2)) = 'MULTIPOINT'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


--
-- Name: mpointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mpointfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: mpointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mpointfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'MULTIPOINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: mpolyfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mpolyfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTIPOLYGON'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


--
-- Name: mpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mpolyfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


--
-- Name: mpolyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mpolyfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: mpolyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mpolyfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: multilinefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multilinefromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: multilinefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multilinefromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: multilinestringfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multilinestringfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_MLineFromText($1)$_$;


--
-- Name: multilinestringfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multilinestringfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MLineFromText($1, $2)$_$;


--
-- Name: multipointfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multipointfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPointFromText($1)$_$;


--
-- Name: multipointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multipointfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPointFromText($1, $2)$_$;


--
-- Name: multipointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multipointfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: multipointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multipointfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'MULTIPOINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: multipolyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multipolyfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: multipolyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multipolyfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: multipolygonfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multipolygonfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPolyFromText($1)$_$;


--
-- Name: multipolygonfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.multipolygonfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPolyFromText($1, $2)$_$;


--
-- Name: pointfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pointfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'POINT'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


--
-- Name: pointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pointfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'POINT'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


--
-- Name: pointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pointfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: pointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pointfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'POINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: polyfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.polyfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'POLYGON'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


--
-- Name: polyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.polyfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'POLYGON'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


--
-- Name: polyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.polyfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: polyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.polyfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'POLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: polygonfromtext(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.polygonfromtext(text) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT PolyFromText($1)$_$;


--
-- Name: polygonfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.polygonfromtext(text, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT PolyFromText($1, $2)$_$;


--
-- Name: polygonfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.polygonfromwkb(bytea) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


--
-- Name: polygonfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.polygonfromwkb(bytea, integer) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'POLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


--
-- Name: probe_geometry_columns(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probe_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	inserted integer;
	oldcount integer;
	probed integer;
	stale integer;
BEGIN


	RETURN 'This function is obsolete now that geometry_columns is a view';
END

$$;


--
-- Name: rename_geometry_table_constraints(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rename_geometry_table_constraints() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT 'rename_geometry_table_constraint() is obsoleted'::text
$$;


--
-- Name: rotate(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rotate(public.geometry, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_rotateZ($1, $2)$_$;


--
-- Name: rotatex(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rotatex(public.geometry, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1, 1, 0, 0, 0, cos($2), -sin($2), 0, sin($2), cos($2), 0, 0, 0)$_$;


--
-- Name: rotatey(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rotatey(public.geometry, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  cos($2), 0, sin($2),  0, 1, 0,  -sin($2), 0, cos($2), 0,  0, 0)$_$;


--
-- Name: rotatez(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rotatez(public.geometry, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  cos($2), -sin($2), 0,  sin($2), cos($2), 0,  0, 0, 1,  0, 0, 0)$_$;


--
-- Name: safe_isect(public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.safe_isect(geom_a public.geometry, geom_b public.geometry) RETURNS public.geometry
    LANGUAGE plpgsql STABLE STRICT
    AS $$
BEGIN
    RETURN ST_Intersection(geom_a, geom_b);
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                RETURN ST_Intersection(ST_Buffer(geom_a, 0.0000001), ST_Buffer(geom_b, 0.0000001));
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN ST_GeomFromText('POLYGON EMPTY');
    END;
END
$$;


--
-- Name: scale(public.geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.scale(public.geometry, double precision, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_scale($1, $2, $3, 1)$_$;


--
-- Name: scale(public.geometry, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.scale(public.geometry, double precision, double precision, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  $2, 0, 0,  0, $3, 0,  0, 0, $4,  0, 0, 0)$_$;


--
-- Name: se_envelopesintersect(public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.se_envelopesintersect(public.geometry, public.geometry) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ 
	SELECT $1 && $2
	$_$;


--
-- Name: se_locatealong(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.se_locatealong(public.geometry, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT SE_LocateBetween($1, $2, $2) $_$;


--
-- Name: snaptogrid(public.geometry, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.snaptogrid(public.geometry, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_SnapToGrid($1, 0, 0, $2, $2)$_$;


--
-- Name: snaptogrid(public.geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.snaptogrid(public.geometry, double precision, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_SnapToGrid($1, 0, 0, $2, $3)$_$;


--
-- Name: st_addband(public.raster, public.raster[], integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_addband(torast public.raster, fromrasts public.raster[], fromband integer DEFAULT 1) RETURNS public.raster
    LANGUAGE plpgsql
    AS $$
	DECLARE var_result raster := torast;
		var_num integer := array_upper(fromrasts,1);
		var_i integer := 1; 
	BEGIN 
		IF torast IS NULL AND var_num > 0 THEN
			var_result := ST_Band(fromrasts[1],fromband); 
			var_i := 2;
		END IF;
		WHILE var_i <= var_num LOOP
			var_result := ST_AddBand(var_result, fromrasts[var_i], 1);
			var_i := var_i + 1;
		END LOOP;
		
		RETURN var_result;
	END;
$$;


--
-- Name: st_area(public.geography); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_area(public.geography) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_Area($1, true)$_$;


--
-- Name: st_asgml(integer, public.geography, integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_asgml(version integer, geog public.geography, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ SELECT _ST_AsGML($1, $2, $3, $4, $5);$_$;


--
-- Name: st_asgml(integer, public.geometry, integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_asgml(version integer, geom public.geometry, maxdecimaldigits integer DEFAULT 15, options integer DEFAULT 0, nprefix text DEFAULT NULL::text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$ SELECT _ST_AsGML($1, $2, $3, $4,$5); $_$;


--
-- Name: st_aspect(public.raster, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_aspect(rast public.raster, band integer, pixeltype text) RETURNS public.raster
    LANGUAGE sql STABLE
    AS $_$ SELECT st_mapalgebrafctngb($1, $2, $3, 1, 1, '_st_aspect4ma(float[][], text, text[])'::regprocedure, 'value', st_pixelwidth($1)::text, st_pixelheight($1)::text) $_$;


--
-- Name: st_clip(public.raster, integer, public.geometry, double precision[], boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_clip(rast public.raster, band integer, geom public.geometry, nodataval double precision[] DEFAULT NULL::double precision[], crop boolean DEFAULT true) RETURNS public.raster
    LANGUAGE plpgsql STABLE
    AS $$
	DECLARE
		newrast raster;
		geomrast raster;
		numband int;
		bandstart int;
		bandend int;
		newextent text;
		newnodataval double precision;
		newpixtype text;
		bandi int;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;
		IF geom IS NULL THEN
			RETURN rast;
		END IF;
		numband := ST_Numbands(rast);
		IF band IS NULL THEN
			bandstart := 1;
			bandend := numband;
		ELSEIF ST_HasNoBand(rast, band) THEN
			RAISE NOTICE 'Raster do not have band %. Returning null', band;
			RETURN NULL;
		ELSE
			bandstart := band;
			bandend := band;
		END IF;

		newpixtype := ST_BandPixelType(rast, bandstart);
		newnodataval := coalesce(nodataval[1], ST_BandNodataValue(rast, bandstart), ST_MinPossibleValue(newpixtype));
		newextent := CASE WHEN crop THEN 'INTERSECTION' ELSE 'FIRST' END;

		-- Convert the geometry to a raster
		geomrast := ST_AsRaster(geom, rast, ST_BandPixelType(rast, band), 1, newnodataval);

		-- Compute the first raster band
		newrast := ST_MapAlgebraExpr(rast, bandstart, geomrast, 1, '[rast1.val]', newpixtype, newextent, newnodataval::text, newnodataval::text, newnodataval);
		-- Set the newnodataval
		newrast := ST_SetBandNodataValue(newrast, bandstart, newnodataval);

		FOR bandi IN bandstart+1..bandend LOOP
			-- for each band we must determine the nodata value
			newpixtype := ST_BandPixelType(rast, bandi);
			newnodataval := coalesce(nodataval[bandi], nodataval[array_upper(nodataval, 1)], ST_BandNodataValue(rast, bandi), ST_MinPossibleValue(newpixtype));
			newrast := ST_AddBand(newrast, ST_MapAlgebraExpr(rast, bandi, geomrast, 1, '[rast1.val]', newpixtype, newextent, newnodataval::text, newnodataval::text, newnodataval));
			newrast := ST_SetBandNodataValue(newrast, bandi, newnodataval);
		END LOOP;

		RETURN newrast;
	END;
	$$;


--
-- Name: st_hillshade(public.raster, integer, text, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_hillshade(rast public.raster, band integer, pixeltype text, azimuth double precision, altitude double precision, max_bright double precision DEFAULT 255.0, elevation_scale double precision DEFAULT 1.0) RETURNS public.raster
    LANGUAGE sql STABLE
    AS $_$ SELECT st_mapalgebrafctngb($1, $2, $3, 1, 1, '_st_hillshade4ma(float[][], text, text[])'::regprocedure, 'value', st_pixelwidth($1)::text, st_pixelheight($1)::text, $4::text, $5::text, $6::text, $7::text) $_$;


--
-- Name: st_length(public.geography); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_length(public.geography) RETURNS double precision
    LANGUAGE sql IMMUTABLE
    AS $_$SELECT ST_Length($1, true)$_$;


--
-- Name: st_pixelaspolygons(public.raster, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_pixelaspolygons(rast public.raster, band integer DEFAULT 1, OUT geom public.geometry, OUT val double precision, OUT x integer, OUT y integer) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $_$
    DECLARE
        rast alias for $1;
        var_w integer;
        var_h integer;
        var_x integer;
        var_y integer;
        value float8 := NULL;
        hasband boolean := TRUE;
    BEGIN
        IF rast IS NOT NULL AND NOT ST_IsEmpty(rast) THEN
            IF ST_HasNoBand(rast, band) THEN
                RAISE NOTICE 'Raster do not have band %. Returning null values', band;
                hasband := false;
            END IF;
            SELECT ST_Width(rast), ST_Height(rast) INTO var_w, var_h;
            FOR var_x IN 1..var_w LOOP
                FOR var_y IN 1..var_h LOOP
                    IF hasband THEN
                        value := ST_Value(rast, band, var_x, var_y);
                    END IF;
                    SELECT ST_PixelAsPolygon(rast, var_x, var_y), value, var_x, var_y INTO geom,val,x,y;
                    RETURN NEXT;
                END LOOP;
            END LOOP;
        END IF;
        RETURN;
    END;
    $_$;


--
-- Name: st_raster2worldcoordx(public.raster, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_raster2worldcoordx(rast public.raster, xr integer) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT longitude FROM _st_raster2worldcoord($1, $2, NULL) $_$;


--
-- Name: st_raster2worldcoordx(public.raster, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_raster2worldcoordx(rast public.raster, xr integer, yr integer) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT longitude FROM _st_raster2worldcoord($1, $2, $3) $_$;


--
-- Name: st_raster2worldcoordy(public.raster, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_raster2worldcoordy(rast public.raster, yr integer) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT latitude FROM _st_raster2worldcoord($1, NULL, $2) $_$;


--
-- Name: st_raster2worldcoordy(public.raster, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_raster2worldcoordy(rast public.raster, xr integer, yr integer) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT latitude FROM _st_raster2worldcoord($1, $2, $3) $_$;


--
-- Name: st_resample(public.raster, integer, double precision, double precision, double precision, double precision, double precision, double precision, text, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_resample(rast public.raster, srid integer DEFAULT NULL::integer, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125) RETURNS public.raster
    LANGUAGE sql STABLE
    AS $_$ SELECT _st_resample($1, $9,	$10, $2, $3, $4, $5, $6, $7, $8) $_$;


--
-- Name: st_resample(public.raster, integer, integer, integer, double precision, double precision, double precision, double precision, text, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_resample(rast public.raster, width integer, height integer, srid integer DEFAULT NULL::integer, gridx double precision DEFAULT NULL::double precision, gridy double precision DEFAULT NULL::double precision, skewx double precision DEFAULT 0, skewy double precision DEFAULT 0, algorithm text DEFAULT 'NearestNeighbour'::text, maxerr double precision DEFAULT 0.125) RETURNS public.raster
    LANGUAGE sql STABLE
    AS $_$ SELECT _st_resample($1, $9,	$10, $4, NULL, NULL, $5, $6, $7, $8, $2, $3) $_$;


--
-- Name: st_slope(public.raster, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_slope(rast public.raster, band integer, pixeltype text) RETURNS public.raster
    LANGUAGE sql STABLE
    AS $_$ SELECT st_mapalgebrafctngb($1, $2, $3, 1, 1, '_st_slope4ma(float[][], text, text[])'::regprocedure, 'value', st_pixelwidth($1)::text, st_pixelheight($1)::text) $_$;


--
-- Name: st_world2rastercoordx(public.raster, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_world2rastercoordx(rast public.raster, xw double precision) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT columnx FROM _st_world2rastercoord($1, $2, NULL) $_$;


--
-- Name: st_world2rastercoordx(public.raster, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_world2rastercoordx(rast public.raster, pt public.geometry) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
	DECLARE
		xr integer;
	BEGIN
		IF ( st_geometrytype(pt) != 'ST_Point' ) THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		SELECT columnx INTO xr FROM _st_world2rastercoord($1, st_x(pt), st_y(pt));
		RETURN xr;
	END;
	$_$;


--
-- Name: st_world2rastercoordx(public.raster, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_world2rastercoordx(rast public.raster, xw double precision, yw double precision) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT columnx FROM _st_world2rastercoord($1, $2, $3) $_$;


--
-- Name: st_world2rastercoordy(public.raster, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_world2rastercoordy(rast public.raster, yw double precision) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT rowy FROM _st_world2rastercoord($1, NULL, $2) $_$;


--
-- Name: st_world2rastercoordy(public.raster, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_world2rastercoordy(rast public.raster, pt public.geometry) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
	DECLARE
		yr integer;
	BEGIN
		IF ( st_geometrytype(pt) != 'ST_Point' ) THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		SELECT rowy INTO yr FROM _st_world2rastercoord($1, st_x(pt), st_y(pt));
		RETURN yr;
	END;
	$_$;


--
-- Name: st_world2rastercoordy(public.raster, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_world2rastercoordy(rast public.raster, xw double precision, yw double precision) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT rowy FROM _st_world2rastercoord($1, $2, $3) $_$;


--
-- Name: translate(public.geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.translate(public.geometry, double precision, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_translate($1, $2, $3, 0)$_$;


--
-- Name: translate(public.geometry, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.translate(public.geometry, double precision, double precision, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1, 1, 0, 0, 0, 1, 0, 0, 0, 1, $2, $3, $4)$_$;


--
-- Name: transscale(public.geometry, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.transscale(public.geometry, double precision, double precision, double precision, double precision) RETURNS public.geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  $4, 0, 0,  0, $5, 0,
		0, 0, 1,  $2 * $4, $3 * $5, 0)$_$;


--
-- Name: tsp_ids(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tsp_ids(geom_table character varying, ids character varying, source integer) RETURNS SETOF integer
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE 
        r record;
        path_result record;
        v_id integer;
	prev integer;

BEGIN
	prev := -1;
	FOR path_result IN EXECUTE 'SELECT vertex_id FROM tsp(''select distinct source::integer as source_id, x(startpoint(the_geom)), y(startpoint(the_geom)) from ' ||
		quote_ident(geom_table) || ' where source in (' || 
                ids || ')  UNION select distinct target as source_id, x(endpoint(the_geom)), y(endpoint(the_geom)) from tsp_test where target in ('||ids||')'', '''|| ids  ||''', '|| source  ||')' LOOP

                v_id = path_result.vertex_id;
        RETURN NEXT v_id;
	END LOOP;

        RETURN;
END;
$$;


--
-- Name: update_cost_from_distance(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cost_from_distance(geom_table character varying) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE 
BEGIN
	BEGIN
	  EXECUTE 'CREATE INDEX ' || quote_ident(geom_table) || 
                  '_edge_id_idx ON ' || quote_ident(geom_table) || 
                  ' (edge_id)';
	EXCEPTION 
		WHEN DUPLICATE_TABLE THEN
		RAISE NOTICE 'Not creating index, already there';
	END;

	EXECUTE 'UPDATE ' || quote_ident(geom_table) || 
              '_edges SET cost = (SELECT sum( length( g.the_geom ) ) FROM ' || 
              quote_ident(geom_table) || 
              ' g WHERE g.edge_id = id GROUP BY id)';

	RETURN;
END;
$$;


--
-- Name: utmzone(public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.utmzone(public.geometry) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
 DECLARE
     geomgeog geometry;
     zone int;
     pref int;

 BEGIN
     geomgeog:= ST_Transform($1,4326);

     IF (ST_Y(geomgeog))>0 THEN
        pref:=32600;
     ELSE
        pref:=32700;
     END IF;

     zone:=floor((ST_X(geomgeog)+180)/6)+1;

     RETURN zone+pref;
 END;
 $_$;


--
-- Name: within(public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.within(public.geometry, public.geometry) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_Within($1, $2)$_$;


--
-- Name: extent(public.geometry); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.extent(public.geometry) (
    SFUNC = public.st_combine_bbox,
    STYPE = public.box3d,
    FINALFUNC = public.box2d
);


--
-- Name: memcollect(public.geometry); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.memcollect(public.geometry) (
    SFUNC = public.st_collect,
    STYPE = public.geometry
);


--
-- Name: st_extent3d(public.geometry); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.st_extent3d(public.geometry) (
    SFUNC = public.st_combine_bbox,
    STYPE = public.box3d
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Category; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Category" (
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "OBJECTID" integer
);


--
-- Name: Continent; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Continent" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" real,
    "PERIMETER" real,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: ContinentData; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."ContinentData" (
    "AREASQKM" integer,
    "RANGEAREA" integer,
    "INPUTAREA" integer,
    "PTAAREA" integer,
    "RANGEPERC" real,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "RANSURV" integer,
    "NONRANGE" integer,
    "SURVPERC" real,
    "INPPERC" real,
    "ESTPTA" integer,
    "AREAPTA" integer,
    "ESTUNP" integer,
    "AREAUNP" integer,
    "ESTPERC" real,
    "AREAPERC" real,
    "RANPTA" integer,
    "RANPPERC" real,
    "OBJECTID" integer
);


--
-- Name: Continent_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Continent_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Contingrp; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Contingrp" (
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" double precision,
    "ACTUALSEEN" double precision,
    "DEFINITE" double precision,
    "PROBABLE" double precision,
    "POSSIBLE" double precision,
    "SPECUL" double precision
);


--
-- Name: Country; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Country" (
    "OBJECTID_12" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(100),
    "RangeState" integer,
    "REGIONID" character varying(4),
    "FAOCODE" integer,
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "CITESHUNTINGQUOTA" integer,
    "CITESAppendix" character varying(4),
    "ListingYr" integer,
    "RainySeasons" character varying(100),
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: Country_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Country_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Countrygrp; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Countrygrp" (
    "CCODE" character varying(6),
    "REGION" character varying(40),
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "OBJECTID" integer
);


--
-- Name: GDB_AnnoSymbols; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_AnnoSymbols" (
    "ID" integer,
    "Symbol" bytea
);


--
-- Name: GDB_AttrRules; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_AttrRules" (
    "RuleID" integer,
    "Subtype" integer,
    "FieldName" character varying(510),
    "DomainName" character varying(510)
);


--
-- Name: GDB_CodedDomains; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_CodedDomains" (
    "DomainID" integer,
    "CodedValues" bytea
);


--
-- Name: GDB_DatabaseLocks; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_DatabaseLocks" (
    "LockID" integer,
    "LockType" integer,
    "UserName" text,
    "MachineName" text
);


--
-- Name: GDB_DefaultValues; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_DefaultValues" (
    "ClassID" integer,
    "FieldName" character varying(510),
    "Subtype" integer,
    "DefaultNumber" double precision,
    "DefaultString" character varying(510)
);


--
-- Name: GDB_Domains; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_Domains" (
    "ID" integer,
    "Owner" character varying(510),
    "DomainName" character varying(510),
    "DomainType" integer,
    "Description" character varying(510),
    "FieldType" integer,
    "MergePolicy" integer,
    "SplitPolicy" integer
);


--
-- Name: GDB_EdgeConnRules; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_EdgeConnRules" (
    "RuleID" integer,
    "FromClassID" integer,
    "FromSubtype" integer,
    "ToClassID" integer,
    "ToSubtype" integer,
    "Junctions" bytea
);


--
-- Name: GDB_Extensions; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_Extensions" (
    "ID" integer,
    "Name" character varying(510),
    "CLSID" character varying(510)
);


--
-- Name: GDB_FeatureClasses; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_FeatureClasses" (
    "ObjectClassID" integer,
    "FeatureType" integer,
    "GeometryType" integer,
    "ShapeField" character varying(510),
    "GeomNetworkID" integer,
    "GraphID" integer
);


--
-- Name: GDB_FeatureDataset; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_FeatureDataset" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "SRID" integer
);


--
-- Name: GDB_FieldInfo; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_FieldInfo" (
    "ClassID" integer,
    "FieldName" character varying(510),
    "AliasName" character varying(510),
    "ModelName" character varying(510),
    "DefaultDomainName" character varying(510),
    "DefaultValueString" character varying(510),
    "DefaultValueNumber" double precision,
    "IsRequired" integer,
    "IsSubtypeFixed" integer,
    "IsEditable" integer
);


--
-- Name: GDB_GeomColumns; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_GeomColumns" (
    "TableName" character varying(510),
    "FieldName" character varying(510),
    "ShapeType" integer,
    "ExtentLeft" double precision,
    "ExtentBottom" double precision,
    "ExtentRight" double precision,
    "ExtentTop" double precision,
    "IdxOriginX" double precision,
    "IdxOriginY" double precision,
    "IdxGridSize" double precision,
    "SRID" integer,
    "HasZ" integer,
    "HasM" integer
);


--
-- Name: GDB_JnConnRules; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_JnConnRules" (
    "RuleID" integer,
    "EdgeClassID" integer,
    "EdgeSubtype" integer,
    "JunctionClassID" integer,
    "JunctionSubtype" integer,
    "EdgeMinCard" integer,
    "EdgeMaxCard" integer,
    "JunctionMinCard" integer,
    "JunctionMaxCard" integer,
    "IsDefault" integer
);


--
-- Name: GDB_ObjectClasses; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_ObjectClasses" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "AliasName" character varying(510),
    "ModelName" character varying(510),
    "CLSID" character varying(510),
    "EXTCLSID" character varying(510),
    "EXTPROPS" bytea,
    "DatasetID" integer,
    "SubtypeField" character varying(510)
);


--
-- Name: GDB_RangeDomains; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_RangeDomains" (
    "DomainID" integer,
    "MinValue" double precision,
    "MaxValue" double precision
);


--
-- Name: GDB_RelClasses; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_RelClasses" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "OriginClassID" integer,
    "DestClassID" integer,
    "ForwardLabel" character varying(510),
    "BackwardLabel" character varying(510),
    "Cardinality" integer,
    "Notification" integer,
    "IsComposite" integer,
    "IsAttributed" integer,
    "OriginPrimaryKey" character varying(510),
    "DestPrimaryKey" character varying(510),
    "OriginForeignKey" character varying(510),
    "DestForeignKey" character varying(510),
    "DatasetID" integer
);


--
-- Name: GDB_RelRules; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_RelRules" (
    "RuleID" integer,
    "OriginSubtype" integer,
    "OriginMinCard" integer,
    "OriginMaxCard" integer,
    "DestSubtype" integer,
    "DestMinCard" integer,
    "DestMaxCard" integer
);


--
-- Name: GDB_ReleaseInfo; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_ReleaseInfo" (
    "Major" integer,
    "Minor" integer,
    "Bugfix" integer
);


--
-- Name: GDB_ReplicaDatasets; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_ReplicaDatasets" (
    "ID" integer,
    "ReplicaID" integer,
    "DatasetType" integer,
    "DatasetID" integer,
    "ParentOwner" character varying(510),
    "ParentDB" character varying(510)
);


--
-- Name: GDB_Replicas; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_Replicas" (
    "ID" integer,
    "Name" character varying(510),
    "Owner" character varying(510),
    "Version" character varying(510),
    "ParentID" integer,
    "RepDate" timestamp without time zone,
    "DefQuery" bytea,
    "RepGuid" character varying(510),
    "RepCInfo" character varying(510),
    "Role" integer
);


--
-- Name: GDB_SpatialRefs; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_SpatialRefs" (
    "SRID" integer,
    "SRTEXT" text,
    "FalseX" double precision,
    "FalseY" double precision,
    "XYUnits" double precision,
    "FalseZ" double precision,
    "ZUnits" double precision,
    "FalseM" double precision,
    "MUnits" double precision
);


--
-- Name: GDB_StringDomains; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_StringDomains" (
    "DomainID" integer,
    "Format" character varying(510)
);


--
-- Name: GDB_Subtypes; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_Subtypes" (
    "ID" integer,
    "ClassID" integer,
    "SubtypeCode" integer,
    "SubtypeName" character varying(510)
);


--
-- Name: GDB_TopoClasses; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_TopoClasses" (
    "ClassID" integer,
    "TopologyID" integer,
    "Weight" double precision,
    "XYRank" integer,
    "ZRank" integer,
    "EventsOnAnalyze" integer
);


--
-- Name: GDB_TopoRules; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_TopoRules" (
    "RuleID" integer,
    "OriginClassID" integer,
    "OriginSubtype" integer,
    "AllOriginSubtypes" integer,
    "DestClassID" integer,
    "DestSubtype" integer,
    "AllDestSubtypes" integer,
    "TopologyRuleType" integer,
    "Name" character varying(510),
    "RuleGUID" character varying(510)
);


--
-- Name: GDB_Topologies; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_Topologies" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetID" integer,
    "Properties" bytea
);


--
-- Name: GDB_UserMetadata; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_UserMetadata" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetType" integer,
    "Xml" bytea
);


--
-- Name: GDB_ValidRules; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."GDB_ValidRules" (
    "ID" integer,
    "RuleType" integer,
    "ClassID" integer,
    "RuleCategory" integer,
    "HelpString" character varying(510)
);


--
-- Name: LineCountryBoundary; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."LineCountryBoundary" (
    "OBJECTID" integer,
    "Shape" bytea,
    "ID" integer,
    "FROMNODE" integer,
    "TONODE" integer,
    "LEFTPOLYGON" integer,
    "RIGHTPOLYGON" integer,
    "Shape_Length" double precision
);


--
-- Name: LineCountryBoundary_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."LineCountryBoundary_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: LineRegionBoundary; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."LineRegionBoundary" (
    "OBJECTID" integer,
    "Shape" bytea,
    "ID" integer,
    "FROMNODE" integer,
    "TONODE" integer,
    "LEFTPOLYGON" integer,
    "RIGHTPOLYGON" integer,
    "Shape_Length" double precision
);


--
-- Name: LineRegionBoundary_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."LineRegionBoundary_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Mapsource; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Mapsource" (
    "CNTRYNAME" character varying(100),
    "TITLE" character varying(100),
    "EDITION" integer,
    "PUBLISHER" character varying(100),
    "SCALE" integer,
    "PROJECTION" character varying(50),
    "YEAR_" character varying(40),
    "COMMENTS" character varying(160),
    "OBJECTID" integer
);


--
-- Name: Paste Errors; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Paste Errors" (
    "INPCODE" integer
);


--
-- Name: Protarea; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Protarea" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" double precision,
    "PERIMETER" double precision,
    "AFRPTADC_" double precision,
    "AFRPTADC_I" double precision,
    "CCODE" character varying(6),
    "CNTRYNAME" character varying(100),
    "INFTCODE" integer,
    "PTACODE" integer,
    "PTANAME" character varying(100),
    "REALAREA" double precision,
    "CALCAREA" double precision,
    "YEAR_" character varying(8),
    "IUCNCAT" character varying(8),
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: Protarea_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Protarea_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RIVERPolygon; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RIVERPolygon" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" double precision,
    "PERIMETER" double precision,
    "RIVERDCW_" double precision,
    "RIVERDCW_I" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RIVERPolygon_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RIVERPolygon_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RIVER_Arc; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RIVER_Arc" (
    "OBJECTID" integer,
    "Shape" bytea,
    "FNODE_" double precision,
    "TNODE_" double precision,
    "LPOLY_" double precision,
    "RPOLY_" double precision,
    "LENGTH" double precision,
    "RIVERDCW_" double precision,
    "RIVERDCW_I" double precision,
    "Shape_Length" double precision
);


--
-- Name: RIVER_Arc_1; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RIVER_Arc_1" (
    "OBJECTID" integer,
    "Shape" bytea,
    "FNODE_" double precision,
    "TNODE_" double precision,
    "LPOLY_" double precision,
    "RPOLY_" double precision,
    "LENGTH" double precision,
    "RIVERDCW_" double precision,
    "RIVERDCW_I" double precision,
    "Shape_Length" double precision
);


--
-- Name: RIVER_Arc_1_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RIVER_Arc_1_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RIVER_Arc_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RIVER_Arc_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RangePoly1995; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RangePoly1995" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" double precision,
    "PERIMETER" double precision,
    "AFRRANDC_" double precision,
    "AFRRANDC_I" double precision,
    "CCODE" character varying(4),
    "CCODEOLD" character varying(6),
    "CNTRYNAME" character varying(100),
    "INFTCODE" integer,
    "RANGE" integer,
    "RANGEAREA" double precision,
    "ReferenceID" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RangePoly1995_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RangePoly1995_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RangePoly1998; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RangePoly1998" (
    "OBJECTID" integer,
    "Shape" bytea,
    "RANGE" integer,
    "RangeQuality" character varying(20),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "AREA_SQKM" integer,
    "ReferenceID" integer,
    "Phenotype" character varying(100),
    "PhenotypeBasis" character varying(100),
    "PhenotypeRefID" integer,
    "DataStatus" character varying(4),
    "DataStatusDetail" text,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RangePoly1998_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RangePoly1998_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Reference; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Reference" (
    "REFERENCE" character varying(100),
    "AUTHOR" character varying(300),
    "PYEAR" character varying(20),
    "TITLE" character varying(400),
    "PUBLISHER" character varying(450),
    "PRESENT" integer,
    "LAEBRA" character varying(100),
    "OBJECTID" integer
);


--
-- Name: Reflink; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Reflink" (
    "INPCODE" integer,
    "REFERENCE" character varying(150),
    "OBJECTID" integer
);


--
-- Name: Regiongrp; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Regiongrp" (
    "REGION" character varying(40),
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" double precision,
    "ACTUALSEEN" double precision,
    "DEFINITE" double precision,
    "PROBABLE" double precision,
    "POSSIBLE" double precision,
    "SPECUL" double precision
);


--
-- Name: Regions; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Regions" (
    "OBJECTID" integer,
    "Shape" bytea,
    "REGIONID" character varying(510),
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: RegionsData; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."RegionsData" (
    "REGION" character varying(40),
    "AREASQKM" integer,
    "RANGEAREA" integer,
    "INPUTAREA" integer,
    "PTAAREA" integer,
    "RANGEPERC" real,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "RANSURV" integer,
    "NONRANGE" integer,
    "SURVPERC" real,
    "INPPERC" real,
    "ESTPTA" integer,
    "AREAPTA" integer,
    "ESTUNP" integer,
    "AREAUNP" integer,
    "ESTPERC" real,
    "AREAPERC" real,
    "RANPTA" integer,
    "RANPPERC" real,
    "OBJECTID" integer
);


--
-- Name: Regions_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Regions_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Roads; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Roads" (
    "OBJECTID" integer,
    "Shape" bytea,
    "FNODE_" double precision,
    "TNODE_" double precision,
    "LPOLY_" double precision,
    "RPOLY_" double precision,
    "LENGTH" double precision,
    "ROADSDCW_" double precision,
    "ROADSDCW_I" double precision,
    "Shape_Length" double precision
);


--
-- Name: Roads_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Roads_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: SelectedObjects; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."SelectedObjects" (
    "SelectionID" integer,
    "ObjectID" integer
);


--
-- Name: Selections; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Selections" (
    "SelectionID" integer,
    "TargetName" character varying(510)
);


--
-- Name: SurveyData; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."SurveyData" (
    "OBJECTID" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "INPCODE" integer,
    "LON" double precision,
    "LAT" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "REFID" integer,
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "COMMENTS" text,
    "AbvDesignate" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "REPORT" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "SURVEYZONE" character varying(160),
    "CALCULATED" integer,
    "DERIVED" integer,
    "DESIGNATE" character varying(100),
    "CNTRYNAME" character varying(60)
);


--
-- Name: SurveyData_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."SurveyData_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: SurveydataDataData; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."SurveydataDataData" (
    "INPCODE" integer,
    "RINPCODE" integer,
    "SURVEYZONE" character varying(160),
    "DESIGNATE" character varying(100),
    "CCODE" character varying(6),
    "CNTRYNAME" character varying(60),
    "AREA_SQKM" integer,
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" integer,
    "CL95" real,
    "CL95P" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(150),
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "Edition" character varying(16),
    "OBJECTID" integer
);


--
-- Name: T_8_DirtyAreas; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_8_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_8_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_8_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_LineErrors; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_8_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_8_LineErrors_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_8_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_PointErrors; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_8_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_8_PointErrors_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_8_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_PolyErrors; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_8_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_8_PolyErrors_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_8_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_DirtyAreas; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_9_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_9_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_9_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_LineErrors; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_9_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_9_LineErrors_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_9_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_PointErrors; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_9_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_9_PointErrors_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_9_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_PolyErrors; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_9_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_9_PolyErrors_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."T_9_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Towns; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Towns" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" double precision,
    "PERIMETER" double precision,
    "TOWNSDCW_" double precision,
    "TOWNSDCW_I" double precision,
    "TWNTYPE" integer,
    "TWNNAME" character varying(80),
    "CCODE" character varying(6),
    "CNTRYNAME" character varying(100)
);


--
-- Name: Towns_Shape_Index; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."Towns_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: continental_and_regional_totals_and_data_quality; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.continental_and_regional_totals_and_data_quality AS
 SELECT 'Africa'::text AS "CONTINENT",
    r."REGION",
    r."DEFINITE",
    r."POSSIBLE",
    r."PROBABLE",
    r."SPECUL",
    r."RANGEAREA",
    round((((r."RANGEAREA")::double precision / (c.continental_rangearea)::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((r."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(r."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(ln(((r."INFOQUALINDEX" + (1)::double precision) / ((r."RANGEAREA")::double precision / (c.continental_rangearea)::double precision)))) AS "PFS"
   FROM aed1995."Regions" r,
    ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed1995."Continent") c
  ORDER BY r."REGION";


--
-- Name: continental_and_regional_totals_and_data_quality_sum; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.continental_and_regional_totals_and_data_quality_sum AS
 SELECT 'Africa'::text AS "CONTINENT",
    r."DEFINITE",
    r."POSSIBLE",
    r."PROBABLE",
    r."SPECUL",
    r."RANGEAREA",
    100 AS "RANGEPERC",
    round((r."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(r."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX"
   FROM aed1995."Continent" r
  ORDER BY 'Africa'::text;


--
-- Name: country_and_regional_totals_and_data_quality; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.country_and_regional_totals_and_data_quality AS
 SELECT c."REGION",
    c."CNTRYNAME",
    c."DEFINITE",
    c."POSSIBLE",
    c."PROBABLE",
    c."SPECUL",
    c."RANGEAREA",
    round((((c."RANGEAREA")::double precision / (r."RANGEAREA")::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((c."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(c."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(log((((c."INFOQUALINDEX")::double precision + (1)::double precision) / ((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision)))) AS "PFS"
   FROM ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed1995."Continent") a,
    (aed1995."Country" c
     JOIN aed1995."Regions" r ON (((c."REGION")::text = (r."REGION")::text)))
  ORDER BY c."REGION", c."CNTRYNAME";


--
-- Name: country_and_regional_totals_and_data_quality_sum; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.country_and_regional_totals_and_data_quality_sum AS
 SELECT c."REGION",
    c."DEFINITE",
    c."POSSIBLE",
    c."PROBABLE",
    c."SPECUL",
    c."RANGEAREA",
    round((((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((c."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(c."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(ln((((c."INFOQUALINDEX")::double precision + (1)::double precision) / ((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision)))) AS "PFS"
   FROM ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed1995."Continent") a,
    aed1995."Regions" c
  ORDER BY c."REGION";


--
-- Name: delCountry; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995."delCountry" (
    "OBJECTID_12" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(100),
    "RangeState" integer,
    "REGIONID" character varying(4),
    "FAOCODE" integer,
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "CITESHUNTINGQUOTA" integer,
    "CITESAppendix" character varying(4),
    "ListingYr" integer,
    "RainySeasons" character varying(100),
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: elephant_estimates_by_country; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.elephant_estimates_by_country AS
 SELECT DISTINCT s."INPCODE",
    a."CCODE" AS ccode,
    s."OBJECTID",
    '-'::text AS "ReasonForChange",
        CASE
            WHEN (s."DESIGNATE" IS NULL) THEN (s."SURVEYZONE")::text
            ELSE (((s."SURVEYZONE")::text || ' '::text) || (s."DESIGNATE")::text)
        END AS survey_zone,
    ((s."METHOD")::text || s."QUALITY") AS method_and_quality,
    s."CATEGORY",
    s."CYEAR",
    s."ESTIMATE",
        CASE
            WHEN (s."CL95" IS NULL) THEN (to_char(s."UPRANGE", '9999999'::text) || '*'::text)
            ELSE to_char(round((s."CL95")::double precision), '9999999'::text)
        END AS "CL95",
    s."REFERENCE",
    round(log((((s."QUALITY")::double precision + (1)::double precision) / ((s."AREA_SQKM")::double precision / (a.country_rangearea)::double precision)))) AS "PFS",
    round((s."AREA_SQKM")::double precision) AS "AREA_SQKM",
    s."LON" AS numeric_lon,
    s."LAT" AS numeric_lat,
        CASE
            WHEN (s."LON" < (0)::double precision) THEN (to_char(abs(s."LON"), '999D9'::text) || 'W'::text)
            WHEN (s."LON" = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs(s."LON"), '999D9'::text) || 'E'::text)
        END AS "LON",
        CASE
            WHEN (s."LAT" < (0)::double precision) THEN (to_char(abs(s."LAT"), '990D9'::text) || 'S'::text)
            WHEN (s."LAT" = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs(s."LAT"), '990D9'::text) || 'N'::text)
        END AS "LAT"
   FROM (aed1995."SurveyData" s
     LEFT JOIN ( SELECT "Country"."CCODE",
            "Country"."RANGEAREA" AS country_rangearea
           FROM aed1995."Country") a ON (((s."CCODE")::text = (a."CCODE")::text)))
  WHERE (s."SELECTION" = 1)
  ORDER BY a."CCODE",
        CASE
            WHEN (s."DESIGNATE" IS NULL) THEN (s."SURVEYZONE")::text
            ELSE (((s."SURVEYZONE")::text || ' '::text) || (s."DESIGNATE")::text)
        END;


--
-- Name: summary_sums_by_continent; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.summary_sums_by_continent AS
 SELECT 'Africa'::text AS "CONTINENT",
    "Continent"."DEFINITE",
    "Continent"."PROBABLE",
    "Continent"."POSSIBLE",
    "Continent"."SPECUL"
   FROM aed1995."Continent";


--
-- Name: summary_sums_by_country; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.summary_sums_by_country AS
 SELECT "Country"."CCODE" AS ccode,
    "Country"."DEFINITE",
    "Country"."PROBABLE",
    "Country"."POSSIBLE",
    "Country"."SPECUL"
   FROM aed1995."Country";


--
-- Name: summary_sums_by_region; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.summary_sums_by_region AS
 SELECT "Regions"."REGION",
    "Regions"."DEFINITE",
    "Regions"."PROBABLE",
    "Regions"."POSSIBLE",
    "Regions"."SPECUL"
   FROM aed1995."Regions";


--
-- Name: summary_totals_by_continent; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.summary_totals_by_continent AS
 SELECT 'Africa'::text AS "CONTINENT",
    "Contingrp"."CATEGORY",
    "Contingrp"."SURVEYTYPE",
    round("Contingrp"."DEFINITE") AS "DEFINITE",
    round("Contingrp"."PROBABLE") AS "PROBABLE",
    round("Contingrp"."POSSIBLE") AS "POSSIBLE",
    round("Contingrp"."SPECUL") AS "SPECUL"
   FROM aed1995."Contingrp"
  ORDER BY "Contingrp"."CATEGORY";


--
-- Name: summary_totals_by_country; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.summary_totals_by_country AS
 SELECT "Countrygrp"."CCODE" AS ccode,
    "Countrygrp"."CATEGORY",
    "Countrygrp"."SURVEYTYPE",
    "Countrygrp"."DEFINITE",
    "Countrygrp"."PROBABLE",
    "Countrygrp"."POSSIBLE",
    "Countrygrp"."SPECUL"
   FROM aed1995."Countrygrp"
  ORDER BY "Countrygrp"."CATEGORY";


--
-- Name: summary_totals_by_region; Type: VIEW; Schema: aed1995; Owner: -
--

CREATE VIEW aed1995.summary_totals_by_region AS
 SELECT "Regiongrp"."REGION",
    "Regiongrp"."CATEGORY",
    "Regiongrp"."SURVEYTYPE",
    round("Regiongrp"."DEFINITE") AS "DEFINITE",
    round("Regiongrp"."PROBABLE") AS "PROBABLE",
    round("Regiongrp"."POSSIBLE") AS "POSSIBLE",
    round("Regiongrp"."SPECUL") AS "SPECUL"
   FROM aed1995."Regiongrp"
  ORDER BY "Regiongrp"."CATEGORY";


--
-- Name: surveytypes; Type: TABLE; Schema: aed1995; Owner: -
--

CREATE TABLE aed1995.surveytypes (
    surveytype text,
    display_order integer
);


--
-- Name: Category; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Category" (
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160)
);


--
-- Name: Continent; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Continent" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" real,
    "PERIMETER" real,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: Continent_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Continent_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Contingrp; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Contingrp" (
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" double precision,
    "ACTUALSEEN" double precision,
    "DEFINITE" double precision,
    "PROBABLE" double precision,
    "POSSIBLE" double precision,
    "SPECUL" double precision,
    "OBJECTID" integer
);


--
-- Name: Country; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Country" (
    "OBJECTID_12" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(100),
    "RangeState" integer,
    "REGIONID" character varying(4),
    "FAOCODE" integer,
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "CITESHUNTINGQUOTA" integer,
    "CITESAppendix" character varying(4),
    "ListingYr" integer,
    "RainySeasons" character varying(100),
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: CountryData; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."CountryData" (
    "OBJECTID" integer,
    "CCODE" character varying(6),
    "CNTRYNAME" character varying(100),
    "FAOCODE" integer,
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANG_" real,
    "SURVRANG_" real
);


--
-- Name: Country_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Country_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Countrygrp; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Countrygrp" (
    "OBJECTID" integer,
    "REGION" character varying(40),
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CCODE" character varying(4)
);


--
-- Name: DesignateAcronyms; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."DesignateAcronyms" (
    "AbvDesig" character varying(10),
    "DESIGNATE" character varying(100)
);


--
-- Name: GDB_AnnoSymbols; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_AnnoSymbols" (
    "ID" integer,
    "Symbol" bytea
);


--
-- Name: GDB_AttrRules; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_AttrRules" (
    "RuleID" integer,
    "Subtype" integer,
    "FieldName" character varying(510),
    "DomainName" character varying(510)
);


--
-- Name: GDB_CodedDomains; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_CodedDomains" (
    "DomainID" integer,
    "CodedValues" bytea
);


--
-- Name: GDB_DatabaseLocks; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_DatabaseLocks" (
    "LockID" integer,
    "LockType" integer,
    "UserName" text,
    "MachineName" text
);


--
-- Name: GDB_DefaultValues; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_DefaultValues" (
    "ClassID" integer,
    "FieldName" character varying(510),
    "Subtype" integer,
    "DefaultNumber" double precision,
    "DefaultString" character varying(510)
);


--
-- Name: GDB_Domains; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_Domains" (
    "ID" integer,
    "Owner" character varying(510),
    "DomainName" character varying(510),
    "DomainType" integer,
    "Description" character varying(510),
    "FieldType" integer,
    "MergePolicy" integer,
    "SplitPolicy" integer
);


--
-- Name: GDB_EdgeConnRules; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_EdgeConnRules" (
    "RuleID" integer,
    "FromClassID" integer,
    "FromSubtype" integer,
    "ToClassID" integer,
    "ToSubtype" integer,
    "Junctions" bytea
);


--
-- Name: GDB_Extensions; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_Extensions" (
    "ID" integer,
    "Name" character varying(510),
    "CLSID" character varying(510)
);


--
-- Name: GDB_FeatureClasses; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_FeatureClasses" (
    "ObjectClassID" integer,
    "FeatureType" integer,
    "GeometryType" integer,
    "ShapeField" character varying(510),
    "GeomNetworkID" integer,
    "GraphID" integer
);


--
-- Name: GDB_FeatureDataset; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_FeatureDataset" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "SRID" integer
);


--
-- Name: GDB_FieldInfo; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_FieldInfo" (
    "ClassID" integer,
    "FieldName" character varying(510),
    "AliasName" character varying(510),
    "ModelName" character varying(510),
    "DefaultDomainName" character varying(510),
    "DefaultValueString" character varying(510),
    "DefaultValueNumber" double precision,
    "IsRequired" integer,
    "IsSubtypeFixed" integer,
    "IsEditable" integer
);


--
-- Name: GDB_GeomColumns; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_GeomColumns" (
    "TableName" character varying(510),
    "FieldName" character varying(510),
    "ShapeType" integer,
    "ExtentLeft" double precision,
    "ExtentBottom" double precision,
    "ExtentRight" double precision,
    "ExtentTop" double precision,
    "IdxOriginX" double precision,
    "IdxOriginY" double precision,
    "IdxGridSize" double precision,
    "SRID" integer,
    "HasZ" integer,
    "HasM" integer
);


--
-- Name: GDB_JnConnRules; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_JnConnRules" (
    "RuleID" integer,
    "EdgeClassID" integer,
    "EdgeSubtype" integer,
    "JunctionClassID" integer,
    "JunctionSubtype" integer,
    "EdgeMinCard" integer,
    "EdgeMaxCard" integer,
    "JunctionMinCard" integer,
    "JunctionMaxCard" integer,
    "IsDefault" integer
);


--
-- Name: GDB_ObjectClasses; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_ObjectClasses" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "AliasName" character varying(510),
    "ModelName" character varying(510),
    "CLSID" character varying(510),
    "EXTCLSID" character varying(510),
    "EXTPROPS" bytea,
    "DatasetID" integer,
    "SubtypeField" character varying(510)
);


--
-- Name: GDB_RangeDomains; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_RangeDomains" (
    "DomainID" integer,
    "MinValue" double precision,
    "MaxValue" double precision
);


--
-- Name: GDB_RelClasses; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_RelClasses" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "OriginClassID" integer,
    "DestClassID" integer,
    "ForwardLabel" character varying(510),
    "BackwardLabel" character varying(510),
    "Cardinality" integer,
    "Notification" integer,
    "IsComposite" integer,
    "IsAttributed" integer,
    "OriginPrimaryKey" character varying(510),
    "DestPrimaryKey" character varying(510),
    "OriginForeignKey" character varying(510),
    "DestForeignKey" character varying(510),
    "DatasetID" integer
);


--
-- Name: GDB_RelRules; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_RelRules" (
    "RuleID" integer,
    "OriginSubtype" integer,
    "OriginMinCard" integer,
    "OriginMaxCard" integer,
    "DestSubtype" integer,
    "DestMinCard" integer,
    "DestMaxCard" integer
);


--
-- Name: GDB_ReleaseInfo; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_ReleaseInfo" (
    "Major" integer,
    "Minor" integer,
    "Bugfix" integer
);


--
-- Name: GDB_ReplicaDatasets; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_ReplicaDatasets" (
    "ID" integer,
    "ReplicaID" integer,
    "DatasetType" integer,
    "DatasetID" integer,
    "ParentOwner" character varying(510),
    "ParentDB" character varying(510)
);


--
-- Name: GDB_Replicas; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_Replicas" (
    "ID" integer,
    "Name" character varying(510),
    "Owner" character varying(510),
    "Version" character varying(510),
    "ParentID" integer,
    "RepDate" timestamp without time zone,
    "DefQuery" bytea,
    "RepGuid" character varying(510),
    "RepCInfo" character varying(510),
    "Role" integer
);


--
-- Name: GDB_SpatialRefs; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_SpatialRefs" (
    "SRID" integer,
    "SRTEXT" text,
    "FalseX" double precision,
    "FalseY" double precision,
    "XYUnits" double precision,
    "FalseZ" double precision,
    "ZUnits" double precision,
    "FalseM" double precision,
    "MUnits" double precision
);


--
-- Name: GDB_StringDomains; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_StringDomains" (
    "DomainID" integer,
    "Format" character varying(510)
);


--
-- Name: GDB_Subtypes; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_Subtypes" (
    "ID" integer,
    "ClassID" integer,
    "SubtypeCode" integer,
    "SubtypeName" character varying(510)
);


--
-- Name: GDB_TopoClasses; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_TopoClasses" (
    "ClassID" integer,
    "TopologyID" integer,
    "Weight" double precision,
    "XYRank" integer,
    "ZRank" integer,
    "EventsOnAnalyze" integer
);


--
-- Name: GDB_TopoRules; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_TopoRules" (
    "RuleID" integer,
    "OriginClassID" integer,
    "OriginSubtype" integer,
    "AllOriginSubtypes" integer,
    "DestClassID" integer,
    "DestSubtype" integer,
    "AllDestSubtypes" integer,
    "TopologyRuleType" integer,
    "Name" character varying(510),
    "RuleGUID" character varying(510)
);


--
-- Name: GDB_Topologies; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_Topologies" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetID" integer,
    "Properties" bytea
);


--
-- Name: GDB_UserMetadata; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_UserMetadata" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetType" integer,
    "Xml" bytea
);


--
-- Name: GDB_ValidRules; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."GDB_ValidRules" (
    "ID" integer,
    "RuleType" integer,
    "ClassID" integer,
    "RuleCategory" integer,
    "HelpString" character varying(510)
);


--
-- Name: LineCountryBoundary; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."LineCountryBoundary" (
    "OBJECTID" integer,
    "Shape" bytea,
    "ID" integer,
    "FROMNODE" integer,
    "TONODE" integer,
    "LEFTPOLYGON" integer,
    "RIGHTPOLYGON" integer,
    "Shape_Length" double precision
);


--
-- Name: LineCountryBoundary_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."LineCountryBoundary_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: LineRegionBoundary; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."LineRegionBoundary" (
    "OBJECTID" integer,
    "Shape" bytea,
    "ID" integer,
    "FROMNODE" integer,
    "TONODE" integer,
    "LEFTPOLYGON" integer,
    "RIGHTPOLYGON" integer,
    "Shape_Length" double precision
);


--
-- Name: LineRegionBoundary_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."LineRegionBoundary_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Protarea98; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Protarea98" (
    "OBJECTID" integer,
    "Shape" bytea,
    "PTACODE" integer,
    "PTANAME" character varying(100),
    "CCODE" character varying(6),
    "YEAR_EST" character varying(8),
    "IUCNCAT" character varying(8),
    "DESIGNATE" character varying(100),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "CALCULATED" integer,
    "RPTACODE" integer,
    "Source" character varying(100),
    "RefID" integer,
    "InRange" character varying(100),
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: Protarea98_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Protarea98_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RIVERPolygon; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."RIVERPolygon" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" double precision,
    "PERIMETER" double precision,
    "RIVERDCW_" double precision,
    "RIVERDCW_I" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RIVERPolygon_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."RIVERPolygon_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RIVER_Arc; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."RIVER_Arc" (
    "OBJECTID" integer,
    "Shape" bytea,
    "FNODE_" double precision,
    "TNODE_" double precision,
    "LPOLY_" double precision,
    "RPOLY_" double precision,
    "LENGTH" double precision,
    "RIVERDCW_" double precision,
    "RIVERDCW_I" double precision,
    "Shape_Length" double precision
);


--
-- Name: RIVER_Arc_1; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."RIVER_Arc_1" (
    "OBJECTID" integer,
    "Shape" bytea,
    "FNODE_" double precision,
    "TNODE_" double precision,
    "LPOLY_" double precision,
    "RPOLY_" double precision,
    "LENGTH" double precision,
    "RIVERDCW_" double precision,
    "RIVERDCW_I" double precision,
    "Shape_Length" double precision
);


--
-- Name: RIVER_Arc_1_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."RIVER_Arc_1_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RIVER_Arc_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."RIVER_Arc_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RangePoly1998; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."RangePoly1998" (
    "OBJECTID" integer,
    "Shape" bytea,
    "RANGE" integer,
    "RangeQuality" character varying(20),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "AREA_SQKM" integer,
    "ReferenceID" integer,
    "Phenotype" character varying(100),
    "PhenotypeBasis" character varying(100),
    "PhenotypeRefID" integer,
    "DataStatus" character varying(4),
    "DataStatusDetail" text,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RangePoly1998_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."RangePoly1998_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Regiongrp; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Regiongrp" (
    "REGION" character varying(40),
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" double precision,
    "ACTUALSEEN" double precision,
    "DEFINITE" double precision,
    "PROBABLE" double precision,
    "POSSIBLE" double precision,
    "SPECUL" double precision,
    "OBJECTID" integer
);


--
-- Name: Regions; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Regions" (
    "OBJECTID" integer,
    "Shape" bytea,
    "REGIONID" character varying(510),
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: Regions_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Regions_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Roads; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Roads" (
    "OBJECTID" integer,
    "Shape" bytea,
    "FNODE_" double precision,
    "TNODE_" double precision,
    "LPOLY_" double precision,
    "RPOLY_" double precision,
    "LENGTH" double precision,
    "ROADSDCW_" double precision,
    "ROADSDCW_I" double precision,
    "Shape_Length" double precision
);


--
-- Name: Roads_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Roads_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: SelectedObjects; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."SelectedObjects" (
    "SelectionID" integer,
    "ObjectID" integer
);


--
-- Name: Selections; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Selections" (
    "SelectionID" integer,
    "TargetName" character varying(510)
);


--
-- Name: Surveydata; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Surveydata" (
    "OBJECTID" integer,
    "Shape" bytea,
    "INPCODE" integer,
    "CCODE" character varying(4),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "REFID" integer,
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "COMMENTS" text,
    "DESIGNATE" character varying(100),
    "AbvDesignate" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "REPORT" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "CNTRYNAME" character varying(60),
    "LON" double precision,
    "LAT" double precision
);


--
-- Name: Surveydata_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Surveydata_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_DirtyAreas; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_8_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_8_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_8_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_LineErrors; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_8_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_8_LineErrors_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_8_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_PointErrors; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_8_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_8_PointErrors_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_8_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_PolyErrors; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_8_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_8_PolyErrors_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_8_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_DirtyAreas; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_9_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_9_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_9_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_LineErrors; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_9_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_9_LineErrors_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_9_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_PointErrors; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_9_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_9_PointErrors_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_9_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_PolyErrors; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_9_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_9_PolyErrors_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."T_9_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Towns; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Towns" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" double precision,
    "PERIMETER" double precision,
    "TOWNSDCW_" double precision,
    "TOWNSDCW_I" double precision,
    "TWNTYPE" integer,
    "TWNNAME" character varying(80),
    "CCODE" character varying(6),
    "CNTRYNAME" character varying(100)
);


--
-- Name: Towns_Shape_Index; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998."Towns_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: continental_and_regional_totals_and_data_quality; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.continental_and_regional_totals_and_data_quality AS
 SELECT 'Africa'::text AS "CONTINENT",
    r."REGION",
    r."DEFINITE",
    r."POSSIBLE",
    r."PROBABLE",
    r."SPECUL",
    r."RANGEAREA",
    round((((r."RANGEAREA")::double precision / (c.continental_rangearea)::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((r."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(r."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(ln(((r."INFOQUALINDEX" + (1)::double precision) / ((r."RANGEAREA")::double precision / (c.continental_rangearea)::double precision)))) AS "PFS"
   FROM aed1998."Regions" r,
    ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed1998."Continent") c
  ORDER BY r."REGION";


--
-- Name: continental_and_regional_totals_and_data_quality_sum; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.continental_and_regional_totals_and_data_quality_sum AS
 SELECT 'Africa'::text AS "CONTINENT",
    r."DEFINITE",
    r."POSSIBLE",
    r."PROBABLE",
    r."SPECUL",
    r."RANGEAREA",
    100 AS "RANGEPERC",
    round((r."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(r."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX"
   FROM aed1998."Continent" r
  ORDER BY 'Africa'::text;


--
-- Name: country_and_regional_totals_and_data_quality; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.country_and_regional_totals_and_data_quality AS
 SELECT c."REGION",
    c."CNTRYNAME",
    c."DEFINITE",
    c."POSSIBLE",
    c."PROBABLE",
    c."SPECUL",
    c."RANGEAREA",
    round((((c."RANGEAREA")::double precision / (r."RANGEAREA")::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((c."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(c."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(log((((c."INFOQUALINDEX")::double precision + (1)::double precision) / ((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision)))) AS "PFS"
   FROM ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed1998."Continent") a,
    (aed1998."Country" c
     JOIN aed1998."Regions" r ON (((c."REGION")::text = (r."REGION")::text)))
  ORDER BY c."REGION", c."CNTRYNAME";


--
-- Name: country_and_regional_totals_and_data_quality_sum; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.country_and_regional_totals_and_data_quality_sum AS
 SELECT c."REGION",
    c."DEFINITE",
    c."POSSIBLE",
    c."PROBABLE",
    c."SPECUL",
    c."RANGEAREA",
    round((((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((c."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(c."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(ln((((c."INFOQUALINDEX")::double precision + (1)::double precision) / ((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision)))) AS "PFS"
   FROM ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed1998."Continent") a,
    aed1998."Regions" c
  ORDER BY c."REGION";


--
-- Name: elephant_estimates_by_country; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.elephant_estimates_by_country AS
 SELECT DISTINCT s."INPCODE",
    a."CCODE" AS ccode,
    s."OBJECTID",
    '-'::text AS "ReasonForChange",
        CASE
            WHEN (s."DESIGNATE" IS NULL) THEN (s."SURVEYZONE")::text
            ELSE (((s."SURVEYZONE")::text || ' '::text) || (s."DESIGNATE")::text)
        END AS survey_zone,
    ((s."METHOD")::text || s."QUALITY") AS method_and_quality,
    s."CATEGORY",
    s."CYEAR",
    s."ESTIMATE",
        CASE
            WHEN (s."CL95" IS NULL) THEN (to_char(s."UPRANGE", '9999999'::text) || '*'::text)
            ELSE to_char(round((s."CL95")::double precision), '9999999'::text)
        END AS "CL95",
    s."REFERENCE",
    round(log((((s."QUALITY")::double precision + (1)::double precision) / ((s."AREA_SQKM")::double precision / (a.country_rangearea)::double precision)))) AS "PFS",
    round((s."AREA_SQKM")::double precision) AS "AREA_SQKM",
    s."LON" AS numeric_lon,
    s."LAT" AS numeric_lat,
        CASE
            WHEN (s."LON" < (0)::double precision) THEN (to_char(abs(s."LON"), '999D9'::text) || 'W'::text)
            WHEN (s."LON" = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs(s."LON"), '999D9'::text) || 'E'::text)
        END AS "LON",
        CASE
            WHEN (s."LAT" < (0)::double precision) THEN (to_char(abs(s."LAT"), '990D9'::text) || 'S'::text)
            WHEN (s."LAT" = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs(s."LAT"), '990D9'::text) || 'N'::text)
        END AS "LAT"
   FROM (aed1998."Surveydata" s
     LEFT JOIN ( SELECT "Country"."CCODE",
            "Country"."RANGEAREA" AS country_rangearea
           FROM aed1998."Country") a ON (((s."CCODE")::text = (a."CCODE")::text)))
  WHERE (s."SELECTION" = 1)
  ORDER BY a."CCODE",
        CASE
            WHEN (s."DESIGNATE" IS NULL) THEN (s."SURVEYZONE")::text
            ELSE (((s."SURVEYZONE")::text || ' '::text) || (s."DESIGNATE")::text)
        END;


--
-- Name: summary_sums_by_continent; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.summary_sums_by_continent AS
 SELECT 'Africa'::text AS "CONTINENT",
    "Continent"."DEFINITE",
    "Continent"."PROBABLE",
    "Continent"."POSSIBLE",
    "Continent"."SPECUL"
   FROM aed1998."Continent";


--
-- Name: summary_sums_by_country; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.summary_sums_by_country AS
 SELECT "Country"."CCODE" AS ccode,
    "Country"."DEFINITE",
    "Country"."PROBABLE",
    "Country"."POSSIBLE",
    "Country"."SPECUL"
   FROM aed1998."Country";


--
-- Name: summary_sums_by_region; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.summary_sums_by_region AS
 SELECT "Regions"."REGION",
    "Regions"."DEFINITE",
    "Regions"."PROBABLE",
    "Regions"."POSSIBLE",
    "Regions"."SPECUL"
   FROM aed1998."Regions";


--
-- Name: summary_totals_by_continent; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.summary_totals_by_continent AS
 SELECT 'Africa'::text AS "CONTINENT",
    "Contingrp"."CATEGORY",
    "Contingrp"."SURVEYTYPE",
    round("Contingrp"."DEFINITE") AS "DEFINITE",
    round("Contingrp"."PROBABLE") AS "PROBABLE",
    round("Contingrp"."POSSIBLE") AS "POSSIBLE",
    round("Contingrp"."SPECUL") AS "SPECUL"
   FROM aed1998."Contingrp"
  ORDER BY "Contingrp"."CATEGORY";


--
-- Name: summary_totals_by_country; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.summary_totals_by_country AS
 SELECT "Countrygrp"."CCODE" AS ccode,
    "Countrygrp"."CATEGORY",
    "Countrygrp"."SURVEYTYPE",
    "Countrygrp"."DEFINITE",
    "Countrygrp"."PROBABLE",
    "Countrygrp"."POSSIBLE",
    "Countrygrp"."SPECUL"
   FROM aed1998."Countrygrp"
  ORDER BY "Countrygrp"."CATEGORY";


--
-- Name: summary_totals_by_region; Type: VIEW; Schema: aed1998; Owner: -
--

CREATE VIEW aed1998.summary_totals_by_region AS
 SELECT "Regiongrp"."REGION",
    "Regiongrp"."CATEGORY",
    "Regiongrp"."SURVEYTYPE",
    round("Regiongrp"."DEFINITE") AS "DEFINITE",
    round("Regiongrp"."PROBABLE") AS "PROBABLE",
    round("Regiongrp"."POSSIBLE") AS "POSSIBLE",
    round("Regiongrp"."SPECUL") AS "SPECUL"
   FROM aed1998."Regiongrp"
  ORDER BY "Regiongrp"."CATEGORY";


--
-- Name: surveytypes; Type: TABLE; Schema: aed1998; Owner: -
--

CREATE TABLE aed1998.surveytypes (
    surveytype text,
    display_order integer
);


--
-- Name: AESRText; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."AESRText" (
    "ID" integer,
    "Site" character varying(100),
    "CCODE" character varying(4),
    "Region" integer,
    "Year" integer,
    "RefID" integer,
    "Section" character varying(100),
    "Text" text,
    "Selection" integer
);


--
-- Name: Category; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Category" (
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160)
);


--
-- Name: ChangeTracker; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."ChangeTracker" (
    "ReasonForChange" character varying(4),
    "Merged" integer,
    "Split" integer,
    "RID" integer,
    "CurrentOID" integer,
    "OldOID" integer
);


--
-- Name: Continent; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Continent" (
    "OBJECTID" integer,
    "Shape" bytea,
    "AREA" real,
    "PERIMETER" real,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "KNOWNRANGEAREA" integer,
    "POSSRANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: Continent_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Continent_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Contingrp; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Contingrp" (
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" double precision,
    "ACTUALSEEN" double precision,
    "DEFINITE" double precision,
    "PROBABLE" double precision,
    "POSSIBLE" double precision,
    "SPECUL" double precision
);


--
-- Name: Country; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Country" (
    "OBJECTID_12" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(100),
    "FR_CNTRYNAME" character varying(70),
    "RangeState" integer,
    "REGIONID" character varying(4),
    "FAOCODE" integer,
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "KNOWNRANGE" integer,
    "POSSRANGE" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEKNOWNPERC" real,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "CITESHUNTINGQUOTA" integer,
    "CITESAppendix" character varying(4),
    "ListingYr" integer,
    "RainySeasons" character varying(100),
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: Country_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Country_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Countrygrp; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Countrygrp" (
    "CCODE" character varying(6),
    "REGION" character varying(40),
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "OBJECTID" integer
);


--
-- Name: DesignateAcronyms; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."DesignateAcronyms" (
    "AbvDesig" character varying(10),
    "DESIGNATE" character varying(100),
    "FR_DESIGNATE" character varying(100)
);


--
-- Name: GDB_AnnoSymbols; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_AnnoSymbols" (
    "ID" integer,
    "Symbol" bytea
);


--
-- Name: GDB_AttrRules; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_AttrRules" (
    "RuleID" integer,
    "Subtype" integer,
    "FieldName" character varying(510),
    "DomainName" character varying(510)
);


--
-- Name: GDB_CodedDomains; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_CodedDomains" (
    "DomainID" integer,
    "CodedValues" bytea
);


--
-- Name: GDB_DatabaseLocks; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_DatabaseLocks" (
    "LockID" integer,
    "LockType" integer,
    "UserName" text,
    "MachineName" text
);


--
-- Name: GDB_DefaultValues; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_DefaultValues" (
    "ClassID" integer,
    "FieldName" character varying(510),
    "Subtype" integer,
    "DefaultNumber" double precision,
    "DefaultString" character varying(510)
);


--
-- Name: GDB_Domains; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_Domains" (
    "ID" integer,
    "Owner" character varying(510),
    "DomainName" character varying(510),
    "DomainType" integer,
    "Description" character varying(510),
    "FieldType" integer,
    "MergePolicy" integer,
    "SplitPolicy" integer
);


--
-- Name: GDB_EdgeConnRules; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_EdgeConnRules" (
    "RuleID" integer,
    "FromClassID" integer,
    "FromSubtype" integer,
    "ToClassID" integer,
    "ToSubtype" integer,
    "Junctions" bytea
);


--
-- Name: GDB_Extensions; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_Extensions" (
    "ID" integer,
    "Name" character varying(510),
    "CLSID" character varying(510)
);


--
-- Name: GDB_FeatureClasses; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_FeatureClasses" (
    "ObjectClassID" integer,
    "FeatureType" integer,
    "GeometryType" integer,
    "ShapeField" character varying(510),
    "GeomNetworkID" integer,
    "GraphID" integer
);


--
-- Name: GDB_FeatureDataset; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_FeatureDataset" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "SRID" integer
);


--
-- Name: GDB_FieldInfo; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_FieldInfo" (
    "ClassID" integer,
    "FieldName" character varying(510),
    "AliasName" character varying(510),
    "ModelName" character varying(510),
    "DefaultDomainName" character varying(510),
    "DefaultValueString" character varying(510),
    "DefaultValueNumber" double precision,
    "IsRequired" integer,
    "IsSubtypeFixed" integer,
    "IsEditable" integer
);


--
-- Name: GDB_GeomColumns; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_GeomColumns" (
    "TableName" character varying(510),
    "FieldName" character varying(510),
    "ShapeType" integer,
    "ExtentLeft" double precision,
    "ExtentBottom" double precision,
    "ExtentRight" double precision,
    "ExtentTop" double precision,
    "IdxOriginX" double precision,
    "IdxOriginY" double precision,
    "IdxGridSize" double precision,
    "SRID" integer,
    "HasZ" integer,
    "HasM" integer
);


--
-- Name: GDB_JnConnRules; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_JnConnRules" (
    "RuleID" integer,
    "EdgeClassID" integer,
    "EdgeSubtype" integer,
    "JunctionClassID" integer,
    "JunctionSubtype" integer,
    "EdgeMinCard" integer,
    "EdgeMaxCard" integer,
    "JunctionMinCard" integer,
    "JunctionMaxCard" integer,
    "IsDefault" integer
);


--
-- Name: GDB_ObjectClasses; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_ObjectClasses" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "AliasName" character varying(510),
    "ModelName" character varying(510),
    "CLSID" character varying(510),
    "EXTCLSID" character varying(510),
    "EXTPROPS" bytea,
    "DatasetID" integer,
    "SubtypeField" character varying(510)
);


--
-- Name: GDB_RangeDomains; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_RangeDomains" (
    "DomainID" integer,
    "MinValue" double precision,
    "MaxValue" double precision
);


--
-- Name: GDB_RelClasses; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_RelClasses" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "OriginClassID" integer,
    "DestClassID" integer,
    "ForwardLabel" character varying(510),
    "BackwardLabel" character varying(510),
    "Cardinality" integer,
    "Notification" integer,
    "IsComposite" integer,
    "IsAttributed" integer,
    "OriginPrimaryKey" character varying(510),
    "DestPrimaryKey" character varying(510),
    "OriginForeignKey" character varying(510),
    "DestForeignKey" character varying(510),
    "DatasetID" integer
);


--
-- Name: GDB_RelRules; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_RelRules" (
    "RuleID" integer,
    "OriginSubtype" integer,
    "OriginMinCard" integer,
    "OriginMaxCard" integer,
    "DestSubtype" integer,
    "DestMinCard" integer,
    "DestMaxCard" integer
);


--
-- Name: GDB_ReleaseInfo; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_ReleaseInfo" (
    "Major" integer,
    "Minor" integer,
    "Bugfix" integer
);


--
-- Name: GDB_ReplicaDatasets; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_ReplicaDatasets" (
    "ID" integer,
    "ReplicaID" integer,
    "DatasetType" integer,
    "DatasetID" integer,
    "ParentOwner" character varying(510),
    "ParentDB" character varying(510)
);


--
-- Name: GDB_Replicas; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_Replicas" (
    "ID" integer,
    "Name" character varying(510),
    "Owner" character varying(510),
    "Version" character varying(510),
    "ParentID" integer,
    "RepDate" timestamp without time zone,
    "DefQuery" bytea,
    "RepGuid" character varying(510),
    "RepCInfo" character varying(510),
    "Role" integer
);


--
-- Name: GDB_SpatialRefs; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_SpatialRefs" (
    "SRID" integer,
    "SRTEXT" text,
    "FalseX" double precision,
    "FalseY" double precision,
    "XYUnits" double precision,
    "FalseZ" double precision,
    "ZUnits" double precision,
    "FalseM" double precision,
    "MUnits" double precision
);


--
-- Name: GDB_StringDomains; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_StringDomains" (
    "DomainID" integer,
    "Format" character varying(510)
);


--
-- Name: GDB_Subtypes; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_Subtypes" (
    "ID" integer,
    "ClassID" integer,
    "SubtypeCode" integer,
    "SubtypeName" character varying(510)
);


--
-- Name: GDB_TopoClasses; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_TopoClasses" (
    "ClassID" integer,
    "TopologyID" integer,
    "Weight" double precision,
    "XYRank" integer,
    "ZRank" integer,
    "EventsOnAnalyze" integer
);


--
-- Name: GDB_TopoRules; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_TopoRules" (
    "RuleID" integer,
    "OriginClassID" integer,
    "OriginSubtype" integer,
    "AllOriginSubtypes" integer,
    "DestClassID" integer,
    "DestSubtype" integer,
    "AllDestSubtypes" integer,
    "TopologyRuleType" integer,
    "Name" character varying(510),
    "RuleGUID" character varying(510)
);


--
-- Name: GDB_Topologies; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_Topologies" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetID" integer,
    "Properties" bytea
);


--
-- Name: GDB_UserMetadata; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_UserMetadata" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetType" integer,
    "Xml" bytea
);


--
-- Name: GDB_ValidRules; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."GDB_ValidRules" (
    "ID" integer,
    "RuleType" integer,
    "ClassID" integer,
    "RuleCategory" integer,
    "HelpString" character varying(510)
);


--
-- Name: InlandCountryBoundary; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."InlandCountryBoundary" (
    "OBJECTID" integer,
    "Shape" bytea,
    "LEFTPOLYGON" character varying(4),
    "RIGHTPOLYGON" character varying(4),
    "Shape_Length" double precision
);


--
-- Name: InlandCountryBoundary_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."InlandCountryBoundary_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: InlandRegionBoundary; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."InlandRegionBoundary" (
    "OBJECTID" integer,
    "Shape" bytea,
    "RightRegion" character varying(2),
    "LeftRegion" character varying(2),
    "Shape_Length" double precision
);


--
-- Name: InlandRegionBoundary_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."InlandRegionBoundary_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: OldSurveydata; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."OldSurveydata" (
    "OBJECTID" integer,
    "Shape" bytea,
    "INPCODE" integer,
    "CCODE" character varying(4),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "REFID" integer,
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "COMMENTS" text,
    "DESIGNATE" character varying(100),
    "AbvDesignate" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "REPORT" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "CNTRYNAME" character varying(60),
    "LON" double precision,
    "LAT" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: OldSurveydata_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."OldSurveydata_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Protarea; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Protarea" (
    "OBJECTID" integer,
    "Shape" bytea,
    "PTACODE" integer,
    "PTANAME" character varying(100),
    "CCODE" character varying(6),
    "YEAR_EST" integer,
    "IUCNCAT" character varying(8),
    "IUCNCATARABIC" smallint,
    "DESIGNATE" character varying(100),
    "AbvDesig" character varying(10),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "CALCULATED" integer,
    "RPTACODE" integer,
    "Source" character varying(100),
    "RefID" integer,
    "InRange" integer,
    "SameSurveyzone" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "Selection" smallint
);


--
-- Name: Protarea_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Protarea_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RIVER_Arc; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."RIVER_Arc" (
    "OBJECTID" integer,
    "Shape" bytea,
    "LineType" double precision,
    "Shape_Length" double precision
);


--
-- Name: RIVER_Arc_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."RIVER_Arc_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Range; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Range" (
    "OBJECTID_1" integer,
    "Shape" bytea,
    "Range" integer,
    "RangeQuality" character varying(20),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "AREA_SQKM" integer,
    "RefID" integer,
    "Year" integer,
    "SourceGeoPrecision" character varying(2),
    "PHENOTYPE" character varying(100),
    "PhTypeBasis" character varying(100),
    "PhTypeRef" integer,
    "DataStatus" character varying(4),
    "DataStatusDetails" text,
    "Comments" text,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "Call_Number" character varying(60)
);


--
-- Name: RangeHabitat; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."RangeHabitat" (
    "OBJECTID" integer,
    "Shape" bytea,
    "Range" integer,
    "RangeQuali" character varying(20),
    "Region" character varying(30),
    "CCODE" character varying(4),
    "AREA_SQKM" integer,
    "RefID" integer,
    "PHENOTYPE" character varying(100),
    "PhTypeBasi" character varying(100),
    "PhTypeRef" integer,
    "DataStatus" character varying(4),
    "Comments" character varying(508),
    "RangeHabitat" character varying(30),
    "Selection" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RangeHabitat_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."RangeHabitat_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RangePoint; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."RangePoint" (
    "OBJECTID" integer,
    "SHAPE" bytea,
    "CCODE" character varying(4),
    "AreaName" character varying(100),
    "Latitude" real,
    "Longitude" real,
    "DateObtained" character varying(100),
    "YearOfRecord" character varying(100),
    "MonthOfRecord" character varying(4),
    "TypeOfRecord" character varying(100),
    "SourceQuality" character varying(4),
    "EleNumber" integer,
    "ReferenceID" integer,
    "DateDigitized" timestamp without time zone,
    "DigitizedBy" character varying(4),
    "GeoPrecision" character varying(4),
    "DataStatus" character varying(4),
    "Call_Number" character varying(60)
);


--
-- Name: RangePoint_SHAPE_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."RangePoint_SHAPE_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Range_Dissolve; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Range_Dissolve" (
    "OBJECTID" integer,
    "Shape" bytea,
    "Range" integer,
    "RangeQuality" character varying(20),
    "CCODE" character varying(4),
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: Range_Dissolve_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Range_Dissolve_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Range_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Range_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Regiongrp; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Regiongrp" (
    "REGION" character varying(40),
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" double precision,
    "ACTUALSEEN" double precision,
    "DEFINITE" double precision,
    "PROBABLE" double precision,
    "POSSIBLE" double precision,
    "SPECUL" double precision
);


--
-- Name: Regions; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Regions" (
    "OBJECTID" integer,
    "Shape" bytea,
    "REGIONID" character varying(510),
    "REGION" character varying(40),
    "FR_REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: Regions_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Regions_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RiverLake; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."RiverLake" (
    "OBJECTID" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "RIVERDCW_I" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RiverLake_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."RiverLake_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Roads; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Roads" (
    "OBJECTID" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "Shape_Length" double precision
);


--
-- Name: Roads_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Roads_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: SelectedObjects; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."SelectedObjects" (
    "SelectionID" integer,
    "ObjectID" integer
);


--
-- Name: Selections; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Selections" (
    "SelectionID" integer,
    "TargetName" character varying(510)
);


--
-- Name: Surveydata; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Surveydata" (
    "OBJECTID" integer,
    "Shape" bytea,
    "INPCODE" character varying(12),
    "CCODE" character varying(4),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "RefID" integer,
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "ReplacesOID" integer,
    "ReasonForChange" character varying(4),
    "Comments" text,
    "DESIGNATE" character varying(100),
    "AbvDesignate" character varying(20),
    "LetterCODE" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "Report" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "CNTRYNAME" character varying(60),
    "LON" double precision,
    "LAT" double precision,
    "Call_Number" character varying(60)
);


--
-- Name: Surveydata_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Surveydata_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: SurveyedRange; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."SurveyedRange" (
    "OBJECTID_12" integer,
    "Shape" bytea,
    "RANGE" integer,
    "RANGEQUALI" character varying(20),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "AREA_SQKM" integer,
    "REFID" integer,
    "YEAR_" integer,
    "PHENOTYPE" character varying(100),
    "PHTYPEBASI" character varying(100),
    "PHTYPEREF" integer,
    "DATASTATUS" character varying(4),
    "COMMENTS" character varying(508),
    "RECODE" integer,
    "INPCODE" character varying(12),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "DESIGNATE" character varying(100),
    "ABVDESIGNA" character varying(20),
    "LETTERCODE" character varying(20),
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "REPORT" integer,
    "DF" integer,
    "NSAMPLE" integer,
    "NTOTAL" integer,
    "T025" double precision,
    "RINPCODE" character varying(6),
    "LON" double precision,
    "LAT" double precision,
    calcestim integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: SurveyedRange_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."SurveyedRange_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_10_DirtyAreas; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_10_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_10_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_10_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_10_LineErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_10_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_10_LineErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_10_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_10_PointErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_10_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_10_PointErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_10_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_10_PolyErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_10_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_10_PolyErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_10_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_4_DirtyAreas; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_4_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_4_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_4_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_4_LineErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_4_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_4_LineErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_4_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_4_PointErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_4_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_4_PointErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_4_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_4_PolyErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_4_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_4_PolyErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_4_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_DirtyAreas; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_8_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_8_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_8_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_LineErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_8_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_8_LineErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_8_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_PointErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_8_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_8_PointErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_8_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_PolyErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_8_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_8_PolyErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_8_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_DirtyAreas; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_9_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_9_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_9_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_LineErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_9_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_9_LineErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_9_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_PointErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_9_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_9_PointErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_9_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_9_PolyErrors; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_9_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_9_PolyErrors_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."T_9_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Towns; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Towns" (
    "OBJECTID_1" integer,
    "Shape" bytea,
    "TWNTYPE" integer,
    "TWNNAME" character varying(80),
    "CCODE" character varying(4)
);


--
-- Name: Towns_Shape_Index; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002."Towns_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: continental_and_regional_totals_and_data_quality; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.continental_and_regional_totals_and_data_quality AS
 SELECT 'Africa'::text AS "CONTINENT",
    r."REGION",
    r."DEFINITE",
    r."POSSIBLE",
    r."PROBABLE",
    r."SPECUL",
    r."RANGEAREA",
    round((((r."RANGEAREA")::double precision / (c.continental_rangearea)::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((r."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(r."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(ln(((r."INFOQUALINDEX" + (1)::double precision) / ((r."RANGEAREA")::double precision / (c.continental_rangearea)::double precision)))) AS "PFS"
   FROM aed2002."Regions" r,
    ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed2002."Continent") c
  ORDER BY r."REGION";


--
-- Name: continental_and_regional_totals_and_data_quality_sum; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.continental_and_regional_totals_and_data_quality_sum AS
 SELECT 'Africa'::text AS "CONTINENT",
    r."DEFINITE",
    r."POSSIBLE",
    r."PROBABLE",
    r."SPECUL",
    r."RANGEAREA",
    100 AS "RANGEPERC",
    round((r."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(r."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX"
   FROM aed2002."Continent" r
  ORDER BY 'Africa'::text;


--
-- Name: country2002; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002.country2002 (
    "OBJECTID_12" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(100),
    "FR_CNTRYNAME" character varying(70),
    "RangeState" integer,
    "REGIONID" character varying(4),
    "FAOCODE" integer,
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "KNOWNRANGE" integer,
    "POSSRANGE" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEKNOWNPERC" real,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "CITESHUNTINGQUOTA" integer,
    "CITESAppendix" character varying(4),
    "ListingYr" integer,
    "RainySeasons" character varying(100),
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "PROBFRACTION" real,
    "INFOQUALINDEX" real
);


--
-- Name: country_and_regional_totals_and_data_quality; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.country_and_regional_totals_and_data_quality AS
 SELECT c."REGION",
    c."CNTRYNAME",
    c."DEFINITE",
    c."POSSIBLE",
    c."PROBABLE",
    c."SPECUL",
    c."RANGEAREA",
    round((((c."RANGEAREA")::double precision / (r."RANGEAREA")::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((c."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(c."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(log((((c."INFOQUALINDEX")::double precision + (1)::double precision) / ((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision)))) AS "PFS"
   FROM ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed2002."Continent") a,
    (aed2002."Country" c
     JOIN aed2002."Regions" r ON (((c."REGION")::text = (r."REGION")::text)))
  ORDER BY c."REGION", c."CNTRYNAME";


--
-- Name: country_and_regional_totals_and_data_quality_sum; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.country_and_regional_totals_and_data_quality_sum AS
 SELECT c."REGION",
    c."DEFINITE",
    c."POSSIBLE",
    c."PROBABLE",
    c."SPECUL",
    c."RANGEAREA",
    round((((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((c."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(c."INFOQUALINDEX", '999999D99'::text) AS "INFQLTYIDX",
    round(log((((c."INFOQUALINDEX")::double precision + (1)::double precision) / ((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision)))) AS "PFS"
   FROM ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed2002."Continent") a,
    aed2002."Regions" c
  ORDER BY c."REGION";


--
-- Name: elephant_estimates_by_country; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.elephant_estimates_by_country AS
 SELECT DISTINCT s."INPCODE",
    a."CCODE" AS ccode,
    s."OBJECTID",
    '-'::text AS "ReasonForChange",
        CASE
            WHEN (s."DESIGNATE" IS NULL) THEN (s."SURVEYZONE")::text
            ELSE (((s."SURVEYZONE")::text || ' '::text) || (s."DESIGNATE")::text)
        END AS survey_zone,
    ((s."METHOD")::text || s."QUALITY") AS method_and_quality,
    s."CATEGORY",
    s."CYEAR",
    s."ESTIMATE",
        CASE
            WHEN (s."CL95" IS NULL) THEN (to_char(s."UPRANGE", '9999999'::text) || '*'::text)
            ELSE to_char(round((s."CL95")::double precision), '9999999'::text)
        END AS "CL95",
    s."REFERENCE",
    round(log((((s."QUALITY")::double precision + (1)::double precision) / ((s."AREA_SQKM")::double precision / (a.country_rangearea)::double precision)))) AS "PFS",
    round((s."AREA_SQKM")::double precision) AS "AREA_SQKM",
    s."LON" AS numeric_lon,
    s."LAT" AS numeric_lat,
        CASE
            WHEN (s."LON" < (0)::double precision) THEN (to_char(abs(s."LON"), '999D9'::text) || 'W'::text)
            WHEN (s."LON" = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs(s."LON"), '999D9'::text) || 'E'::text)
        END AS "LON",
        CASE
            WHEN (s."LAT" < (0)::double precision) THEN (to_char(abs(s."LAT"), '990D9'::text) || 'S'::text)
            WHEN (s."LAT" = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs(s."LAT"), '990D9'::text) || 'N'::text)
        END AS "LAT"
   FROM (aed2002."Surveydata" s
     LEFT JOIN ( SELECT "Country"."CCODE",
            "Country"."RANGEAREA" AS country_rangearea
           FROM aed2002."Country") a ON (((s."CCODE")::text = (a."CCODE")::text)))
  WHERE (s."SELECTION" = 1)
  ORDER BY a."CCODE",
        CASE
            WHEN (s."DESIGNATE" IS NULL) THEN (s."SURVEYZONE")::text
            ELSE (((s."SURVEYZONE")::text || ' '::text) || (s."DESIGNATE")::text)
        END;


--
-- Name: summary_sums_by_continent; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.summary_sums_by_continent AS
 SELECT 'Africa'::text AS "CONTINENT",
    "Continent"."DEFINITE",
    "Continent"."PROBABLE",
    "Continent"."POSSIBLE",
    "Continent"."SPECUL"
   FROM aed2002."Continent";


--
-- Name: summary_sums_by_country; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.summary_sums_by_country AS
 SELECT "Country"."CCODE" AS ccode,
    "Country"."DEFINITE",
    "Country"."PROBABLE",
    "Country"."POSSIBLE",
    "Country"."SPECUL"
   FROM aed2002."Country";


--
-- Name: summary_sums_by_region; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.summary_sums_by_region AS
 SELECT "Regions"."REGION",
    "Regions"."DEFINITE",
    "Regions"."PROBABLE",
    "Regions"."POSSIBLE",
    "Regions"."SPECUL"
   FROM aed2002."Regions";


--
-- Name: summary_totals_by_continent; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.summary_totals_by_continent AS
 SELECT 'Africa'::text AS "CONTINENT",
    "Contingrp"."CATEGORY",
    "Contingrp"."SURVEYTYPE",
    round("Contingrp"."DEFINITE") AS "DEFINITE",
    round("Contingrp"."PROBABLE") AS "PROBABLE",
    round("Contingrp"."POSSIBLE") AS "POSSIBLE",
    round("Contingrp"."SPECUL") AS "SPECUL"
   FROM aed2002."Contingrp"
  ORDER BY "Contingrp"."CATEGORY";


--
-- Name: summary_totals_by_country; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.summary_totals_by_country AS
 SELECT "Countrygrp"."CCODE" AS ccode,
    "Countrygrp"."CATEGORY",
    "Countrygrp"."SURVEYTYPE",
    "Countrygrp"."DEFINITE",
    "Countrygrp"."PROBABLE",
    "Countrygrp"."POSSIBLE",
    "Countrygrp"."SPECUL"
   FROM aed2002."Countrygrp"
  ORDER BY "Countrygrp"."CATEGORY";


--
-- Name: summary_totals_by_region; Type: VIEW; Schema: aed2002; Owner: -
--

CREATE VIEW aed2002.summary_totals_by_region AS
 SELECT "Regiongrp"."REGION",
    "Regiongrp"."CATEGORY",
    "Regiongrp"."SURVEYTYPE",
    round("Regiongrp"."DEFINITE") AS "DEFINITE",
    round("Regiongrp"."PROBABLE") AS "PROBABLE",
    round("Regiongrp"."POSSIBLE") AS "POSSIBLE",
    round("Regiongrp"."SPECUL") AS "SPECUL"
   FROM aed2002."Regiongrp"
  ORDER BY "Regiongrp"."CATEGORY";


--
-- Name: surveytypes; Type: TABLE; Schema: aed2002; Owner: -
--

CREATE TABLE aed2002.surveytypes (
    surveytype text,
    display_order integer
);


--
-- Name: AESRText; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."AESRText" (
    "ID" integer,
    "Site" character varying(100),
    "CCODE" character varying(4),
    "Region" integer,
    "Year" integer,
    "RefID" integer,
    "Section" character varying(100),
    "Text" text,
    "Selection" integer
);


--
-- Name: Category; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Category" (
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160)
);


--
-- Name: CausesOfChange; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."CausesOfChange" (
    "ChangeCODE" character varying(4),
    "CauseofChange" character varying(100),
    display_order integer
);


--
-- Name: ChangesTracker; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."ChangesTracker" (
    "ReasonForChange" character varying(4),
    "Merged" integer,
    "Split" integer,
    "RID" integer,
    "CurrentOID" integer,
    "PreviousOID" integer,
    "DuplReplaces" integer,
    "Comparable" integer
);


--
-- Name: Country; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Country" (
    "OBJECTID_12" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(100),
    "FR_CNTRYNAME" character varying(70),
    "RangeState" integer,
    "REGIONID" character varying(4),
    "FAOCODE" integer,
    "REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "KNOWNRANGE" integer,
    "POSSRANGE" integer,
    "DOUBTRANGE" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEKNOWNPERC" real,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "PROBFRACTION" real,
    "INFQLTYIDX" real,
    "CITESHUNTINGQUOTA" integer,
    "CITESAppendix" character varying(4),
    "ListingYr" integer,
    "RainySeasons" character varying(24),
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: PreviousSurveydata; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."PreviousSurveydata" (
    "OBJECTID" integer,
    "Shape" bytea,
    "INPCODE" character varying(12),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "EFFSAMPINT" real,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "UCL95Asym" real,
    "LCL95Asym" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "RefID" integer,
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "DateIn" timestamp without time zone,
    "DateOut" timestamp without time zone,
    "ReasonForChange" character varying(4),
    "Comments" text,
    "DESIGNATE" character varying(100),
    "AbvDesignate" character varying(20),
    "LetterCODE" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "ScaleDenominator" integer,
    "Report" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "LON" double precision,
    "LAT" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: Regions; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Regions" (
    "OBJECTID" integer,
    "Shape" bytea,
    "REGIONID" character varying(510),
    "REGION" character varying(40),
    "CONTINENT" character varying(20),
    "FR_REGION" character varying(40),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "KNOWNRANGE" integer,
    "POSSRANGE" integer,
    "DOUBTRANGE" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "RANGEKNOWNPERC" real,
    "SURVRANG" integer,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "PROBFRACTION" real,
    "INFQLTYIDX" real,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: Surveydata; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Surveydata" (
    "OBJECTID" integer,
    "Shape" bytea,
    "INPCODE" character varying(12),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "EFFSAMPINT" real,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "UCL95Asym" real,
    "LCL95Asym" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "RefID" integer,
    "Call_Number" character varying(60),
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "PFS" integer,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "DateIn" timestamp without time zone,
    "DateOut" timestamp without time zone,
    "Comments" text,
    "DESIGNATE" character varying(100),
    "AbvDesignate" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "ScaleDenominator" integer,
    "Report" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "LON" double precision,
    "LAT" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: changesgrp; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.changesgrp AS
 SELECT a."CCODE",
    a."CATEGORY",
    a."ReasonForChange",
    a.sumofdefinite,
    a.sumofprobable,
    a.sumofpossible,
    a.sumofspecul
   FROM ( SELECT "Surveydata"."CCODE",
            "Surveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            sum("Surveydata"."DEFINITE") AS sumofdefinite,
            sum("Surveydata"."PROBABLE") AS sumofprobable,
            sum("Surveydata"."POSSIBLE") AS sumofpossible,
            sum("Surveydata"."SPECUL") AS sumofspecul
           FROM (aed2007."Surveydata"
             JOIN aed2007."ChangesTracker" ON (("Surveydata"."OBJECTID" = "ChangesTracker"."CurrentOID")))
          WHERE ("ChangesTracker"."Merged" IS NULL)
          GROUP BY "Surveydata"."CCODE", "Surveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING ((("Surveydata"."CATEGORY")::text = 'A'::text) OR (("Surveydata"."CATEGORY")::text = 'D'::text) OR (("Surveydata"."CATEGORY")::text = 'E'::text))
        UNION
         SELECT "Surveydata"."CCODE",
            "Surveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
                CASE
                    WHEN (((sum("Surveydata"."ESTIMATE"))::double precision - ((1.96)::double precision * sqrt((sum("Surveydata"."VARIANCE"))::double precision))) > (0)::double precision) THEN ((sum("Surveydata"."ESTIMATE"))::double precision - ((1.96)::double precision * sqrt((sum("Surveydata"."VARIANCE"))::double precision)))
                    ELSE (
                    CASE
                        WHEN (sum("Surveydata"."ACTUALSEEN") > 0) THEN sum("Surveydata"."ACTUALSEEN")
                        ELSE (0)::bigint
                    END)::double precision
                END AS sumofdefinite,
                CASE
                    WHEN ((sum("Surveydata"."ESTIMATE"))::double precision < ((1.96)::double precision * sqrt((sum("Surveydata"."VARIANCE"))::double precision))) THEN (sum(("Surveydata"."ESTIMATE" - "Surveydata"."ACTUALSEEN")))::double precision
                    ELSE ((1.96)::double precision * sqrt((sum("Surveydata"."VARIANCE"))::double precision))
                END AS sumofprobable,
            ((1.96)::double precision * sqrt((sum("Surveydata"."VARIANCE"))::double precision)) AS sumofpossible,
            sum("Surveydata"."SPECUL") AS sumofspecul
           FROM (aed2007."Surveydata"
             JOIN aed2007."ChangesTracker" ON (("Surveydata"."OBJECTID" = "ChangesTracker"."CurrentOID")))
          WHERE ("ChangesTracker"."Merged" IS NULL)
          GROUP BY "Surveydata"."CCODE", "Surveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING (("Surveydata"."CATEGORY")::text = 'B'::text)
        UNION
         SELECT "Surveydata"."CCODE",
            "Surveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            sum("Surveydata"."ACTUALSEEN") AS sumofdefinite,
            sum("Surveydata"."ESTIMATE") AS sumofprobable,
            ((1.96)::double precision * sqrt((sum("Surveydata"."VARIANCE"))::double precision)) AS sumofpossible,
            sum("Surveydata"."SPECUL") AS sumofspecul
           FROM (aed2007."Surveydata"
             JOIN aed2007."ChangesTracker" ON (("Surveydata"."OBJECTID" = "ChangesTracker"."CurrentOID")))
          WHERE ("ChangesTracker"."Merged" IS NULL)
          GROUP BY "Surveydata"."CCODE", "Surveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING (("Surveydata"."CATEGORY")::text = 'C'::text)
        UNION
         SELECT "Surveydata"."CCODE",
            "Surveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            avg("Surveydata"."DEFINITE") AS sumofdefinite,
            avg("Surveydata"."PROBABLE") AS sumofprobable,
            avg("Surveydata"."POSSIBLE") AS sumofpossible,
            avg("Surveydata"."SPECUL") AS sumofspecul
           FROM (aed2007."Surveydata"
             JOIN aed2007."ChangesTracker" ON (("Surveydata"."OBJECTID" = "ChangesTracker"."CurrentOID")))
          WHERE ("ChangesTracker"."Merged" = 1)
          GROUP BY "Surveydata"."CCODE", "Surveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING ((("Surveydata"."CATEGORY")::text = 'A'::text) OR (("Surveydata"."CATEGORY")::text = 'D'::text) OR (("Surveydata"."CATEGORY")::text = 'E'::text))
        UNION
         SELECT "Surveydata"."CCODE",
            "Surveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
                CASE
                    WHEN (((avg("Surveydata"."ESTIMATE"))::double precision - ((1.96)::double precision * sqrt(avg("Surveydata"."VARIANCE")))) > (0)::double precision) THEN ((avg("Surveydata"."ESTIMATE"))::double precision - ((1.96)::double precision * sqrt(avg("Surveydata"."VARIANCE"))))
                    ELSE (
                    CASE
                        WHEN (avg("Surveydata"."ACTUALSEEN") > (0)::numeric) THEN avg("Surveydata"."ACTUALSEEN")
                        ELSE (0)::numeric
                    END)::double precision
                END AS sumofdefinite,
                CASE
                    WHEN ((avg("Surveydata"."ESTIMATE"))::double precision < ((1.96)::double precision * sqrt(avg("Surveydata"."VARIANCE")))) THEN (avg(("Surveydata"."ESTIMATE" - "Surveydata"."ACTUALSEEN")))::double precision
                    ELSE ((1.96)::double precision * sqrt(avg("Surveydata"."VARIANCE")))
                END AS sumofprobable,
            ((1.96)::double precision * sqrt(avg("Surveydata"."VARIANCE"))) AS sumofpossible,
            sum("Surveydata"."SPECUL") AS sumofspecul
           FROM (aed2007."Surveydata"
             JOIN aed2007."ChangesTracker" ON (("Surveydata"."OBJECTID" = "ChangesTracker"."CurrentOID")))
          WHERE ("ChangesTracker"."Merged" = 1)
          GROUP BY "Surveydata"."CCODE", "Surveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING (("Surveydata"."CATEGORY")::text = 'B'::text)
        UNION
         SELECT "Surveydata"."CCODE",
            "Surveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            avg("Surveydata"."ACTUALSEEN") AS sumofdefinite,
            avg("Surveydata"."ESTIMATE") AS sumofprobable,
            ((1.96)::double precision * sqrt(avg("Surveydata"."VARIANCE"))) AS sumofpossible,
            avg("Surveydata"."SPECUL") AS sumofspecul
           FROM (aed2007."Surveydata"
             JOIN aed2007."ChangesTracker" ON (("Surveydata"."OBJECTID" = "ChangesTracker"."CurrentOID")))
          WHERE ("ChangesTracker"."Merged" = 1)
          GROUP BY "Surveydata"."CCODE", "Surveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING (("Surveydata"."CATEGORY")::text = 'C'::text)
        UNION
         SELECT "PreviousSurveydata"."CCODE",
            "PreviousSurveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            sum(('-1'::integer * "PreviousSurveydata"."DEFINITE")) AS sumofdefinite,
            sum(('-1'::integer * "PreviousSurveydata"."PROBABLE")) AS sumofprobable,
            sum(('-1'::integer * "PreviousSurveydata"."POSSIBLE")) AS sumofpossible,
            sum(('-1'::integer * "PreviousSurveydata"."SPECUL")) AS sumofspecul
           FROM (aed2007."PreviousSurveydata"
             JOIN aed2007."ChangesTracker" ON (("PreviousSurveydata"."OBJECTID" = "ChangesTracker"."PreviousOID")))
          WHERE ("ChangesTracker"."Split" IS NULL)
          GROUP BY "PreviousSurveydata"."CCODE", "PreviousSurveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING ((("PreviousSurveydata"."CATEGORY")::text = 'A'::text) OR (("PreviousSurveydata"."CATEGORY")::text = 'D'::text) OR (("PreviousSurveydata"."CATEGORY")::text = 'E'::text))
        UNION
         SELECT "PreviousSurveydata"."CCODE",
            "PreviousSurveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            (
                CASE
                    WHEN (((sum("PreviousSurveydata"."ESTIMATE"))::double precision - ((1.96)::double precision * sqrt((sum("PreviousSurveydata"."VARIANCE"))::double precision))) > (0)::double precision) THEN ((sum("PreviousSurveydata"."ESTIMATE"))::double precision - ((1.96)::double precision * sqrt((sum("PreviousSurveydata"."VARIANCE"))::double precision)))
                    ELSE (
                    CASE
                        WHEN (sum("PreviousSurveydata"."ACTUALSEEN") > 0) THEN sum("PreviousSurveydata"."ACTUALSEEN")
                        ELSE (0)::bigint
                    END)::double precision
                END * ('-1'::integer)::double precision) AS sumofdefinite,
            (
                CASE
                    WHEN ((sum("PreviousSurveydata"."ESTIMATE"))::double precision < ((1.96)::double precision * sqrt((sum("PreviousSurveydata"."VARIANCE"))::double precision))) THEN (sum(("PreviousSurveydata"."ESTIMATE" - "PreviousSurveydata"."ACTUALSEEN")))::double precision
                    ELSE ((1.96)::double precision * sqrt((sum("PreviousSurveydata"."VARIANCE"))::double precision))
                END * ('-1'::integer)::double precision) AS sumofprobable,
            (('-1.96'::numeric)::double precision * sqrt((sum("PreviousSurveydata"."VARIANCE"))::double precision)) AS sumofpossible,
            sum(('-1'::integer * "PreviousSurveydata"."SPECUL")) AS sumofspecul
           FROM (aed2007."PreviousSurveydata"
             JOIN aed2007."ChangesTracker" ON (("PreviousSurveydata"."OBJECTID" = "ChangesTracker"."PreviousOID")))
          WHERE ("ChangesTracker"."Split" IS NULL)
          GROUP BY "PreviousSurveydata"."CCODE", "PreviousSurveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING (("PreviousSurveydata"."CATEGORY")::text = 'B'::text)
        UNION
         SELECT "PreviousSurveydata"."CCODE",
            "PreviousSurveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            sum((- "PreviousSurveydata"."ACTUALSEEN")) AS sumofdefinite,
            sum((- "PreviousSurveydata"."ESTIMATE")) AS sumofprobable,
            (('-1.96'::numeric)::double precision * sqrt((sum("PreviousSurveydata"."VARIANCE"))::double precision)) AS sumofpossible,
            sum((- "PreviousSurveydata"."SPECUL")) AS sumofspecul
           FROM (aed2007."PreviousSurveydata"
             JOIN aed2007."ChangesTracker" ON (("PreviousSurveydata"."OBJECTID" = "ChangesTracker"."PreviousOID")))
          WHERE ("ChangesTracker"."Split" IS NULL)
          GROUP BY "PreviousSurveydata"."CCODE", "PreviousSurveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING (("PreviousSurveydata"."CATEGORY")::text = 'C'::text)
        UNION
         SELECT "PreviousSurveydata"."CCODE",
            "PreviousSurveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            (- avg("PreviousSurveydata"."DEFINITE")) AS sumofdefinite,
            (- avg("PreviousSurveydata"."PROBABLE")) AS sumofprobable,
            (- avg("PreviousSurveydata"."POSSIBLE")) AS sumofpossible,
            (- avg("PreviousSurveydata"."SPECUL")) AS sumofspecul
           FROM (aed2007."PreviousSurveydata"
             JOIN aed2007."ChangesTracker" ON (("PreviousSurveydata"."OBJECTID" = "ChangesTracker"."PreviousOID")))
          WHERE ("ChangesTracker"."Split" = 1)
          GROUP BY "PreviousSurveydata"."CCODE", "PreviousSurveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING ((("PreviousSurveydata"."CATEGORY")::text = 'A'::text) OR (("PreviousSurveydata"."CATEGORY")::text = 'D'::text) OR (("PreviousSurveydata"."CATEGORY")::text = 'E'::text))
        UNION
         SELECT "PreviousSurveydata"."CCODE",
            "PreviousSurveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            (
                CASE
                    WHEN (((avg("PreviousSurveydata"."ESTIMATE"))::double precision - ((1.96)::double precision * sqrt(avg("PreviousSurveydata"."VARIANCE")))) > (0)::double precision) THEN ((avg("PreviousSurveydata"."ESTIMATE"))::double precision - ((1.96)::double precision * sqrt(avg("PreviousSurveydata"."VARIANCE"))))
                    ELSE (
                    CASE
                        WHEN (avg("PreviousSurveydata"."ACTUALSEEN") > (0)::numeric) THEN avg("PreviousSurveydata"."ACTUALSEEN")
                        ELSE (0)::numeric
                    END)::double precision
                END * ('-1'::integer)::double precision) AS sumofdefinite,
            (
                CASE
                    WHEN ((avg("PreviousSurveydata"."ESTIMATE"))::double precision < ((1.96)::double precision * sqrt(avg("PreviousSurveydata"."VARIANCE")))) THEN (avg(("PreviousSurveydata"."ESTIMATE" - "PreviousSurveydata"."ACTUALSEEN")))::double precision
                    ELSE ((1.96)::double precision * sqrt(avg("PreviousSurveydata"."VARIANCE")))
                END * ('-1'::integer)::double precision) AS sumofprobable,
            (('-1.96'::numeric)::double precision * sqrt(avg("PreviousSurveydata"."VARIANCE"))) AS sumofpossible,
            sum((- "PreviousSurveydata"."SPECUL")) AS sumofspecul
           FROM (aed2007."PreviousSurveydata"
             JOIN aed2007."ChangesTracker" ON (("PreviousSurveydata"."OBJECTID" = "ChangesTracker"."PreviousOID")))
          WHERE ("ChangesTracker"."Split" = 1)
          GROUP BY "PreviousSurveydata"."CCODE", "PreviousSurveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING (("PreviousSurveydata"."CATEGORY")::text = 'B'::text)
        UNION
         SELECT "PreviousSurveydata"."CCODE",
            "PreviousSurveydata"."CATEGORY",
            "ChangesTracker"."ReasonForChange",
            avg((- "PreviousSurveydata"."ACTUALSEEN")) AS sumofdefinite,
            avg((- "PreviousSurveydata"."ESTIMATE")) AS sumofprobable,
            (('-1.96'::numeric)::double precision * sqrt(avg("PreviousSurveydata"."VARIANCE"))) AS sumofpossible,
            avg((- "PreviousSurveydata"."SPECUL")) AS sumofspecul
           FROM (aed2007."PreviousSurveydata"
             JOIN aed2007."ChangesTracker" ON (("PreviousSurveydata"."OBJECTID" = "ChangesTracker"."PreviousOID")))
          WHERE ("ChangesTracker"."Split" = 1)
          GROUP BY "PreviousSurveydata"."CCODE", "PreviousSurveydata"."CATEGORY", "ChangesTracker"."ReasonForChange"
         HAVING (("PreviousSurveydata"."CATEGORY")::text = 'C'::text)) a
  ORDER BY a."CCODE", a."CATEGORY", a."ReasonForChange";


--
-- Name: ChangesInterpreter; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007."ChangesInterpreter" AS
 SELECT "Regions"."REGION",
    "Country"."CNTRYNAME",
    "CausesOfChange"."CauseofChange",
    "CausesOfChange".display_order,
    sum(changesgrp.sumofdefinite) AS "DIFDEF",
    sum(changesgrp.sumofprobable) AS "DIFPROB",
    sum(changesgrp.sumofpossible) AS "DIFPOSS",
    sum(changesgrp.sumofspecul) AS "DIFSPEC"
   FROM (aed2007."CausesOfChange"
     JOIN ((aed2007."Regions"
     JOIN aed2007."Country" ON ((("Regions"."REGIONID")::text = ("Country"."REGIONID")::text)))
     JOIN aed2007.changesgrp ON ((("Country"."CCODE")::text = (changesgrp."CCODE")::text))) ON ((("CausesOfChange"."ChangeCODE")::text = (changesgrp."ReasonForChange")::text)))
  WHERE (("CausesOfChange"."ChangeCODE")::text <> 'NC'::text)
  GROUP BY "Regions"."REGION", "Country"."CNTRYNAME", "CausesOfChange"."CauseofChange", "CausesOfChange".display_order
  ORDER BY "Regions"."REGION", "Country"."CNTRYNAME", "CausesOfChange".display_order;


--
-- Name: Continent; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Continent" (
    "OBJECTID" integer,
    "Shape" bytea,
    "CONTINENT" character varying(20),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "CNTRYAREA" integer,
    "RANGEAREA" integer,
    "KNOWNRANGE" integer,
    "POSSRANGE" integer,
    "DOUBTRANGE" integer,
    "PA_AREA" integer,
    "SURVEYAREA" integer,
    "PROTRANG" integer,
    "SURVRANG" integer,
    "RANGEKNOWNPERC" real,
    "RANGEPERC" real,
    "PAPERC" real,
    "SURVEYPERC" real,
    "PROTRANGPERC" real,
    "SURVRANGPERC" real,
    "PROBFRACTION" real,
    "INFQLTYIDX" real,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: Continent_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Continent_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Contingrp; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Contingrp" (
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" double precision,
    "ACTUALSEEN" double precision,
    "DEFINITE" double precision,
    "PROBABLE" double precision,
    "POSSIBLE" double precision,
    "SPECUL" double precision
);


--
-- Name: Country_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Country_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Countrygrp; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Countrygrp" (
    "CCODE" character varying(6),
    "REGION" character varying(40),
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "OBJECTID" integer
);


--
-- Name: DesignateAcronyms; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."DesignateAcronyms" (
    "AbvDesig" character varying(10),
    "DESIGNATE" character varying(100),
    "FR_DESIGNATE" character varying(100),
    "OBJECTID" integer
);


--
-- Name: ExcludedSurveys; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."ExcludedSurveys" (
    "OBJECTID" integer,
    "Shape" bytea,
    "INPCODE" character varying(12),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "EFFSAMPINT" real,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "UCL95Asym" real,
    "LCL95Asym" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "RefID" integer,
    "Call_Number" character varying(60),
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "DateIn" timestamp without time zone,
    "DateOut" timestamp without time zone,
    "ReasonForChange" character varying(4),
    "Comments" text,
    "DESIGNATE" character varying(100),
    "AbvDesignate" character varying(20),
    "LetterCODE" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "ScaleDenominator" integer,
    "Report" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "LON" double precision,
    "LAT" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: ExcludedSurveys_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."ExcludedSurveys_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: GDB_AnnoSymbols; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_AnnoSymbols" (
    "ID" integer,
    "Symbol" bytea
);


--
-- Name: GDB_AttrRules; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_AttrRules" (
    "RuleID" integer,
    "Subtype" integer,
    "FieldName" character varying(510),
    "DomainName" character varying(510)
);


--
-- Name: GDB_CodedDomains; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_CodedDomains" (
    "DomainID" integer,
    "CodedValues" bytea
);


--
-- Name: GDB_DatabaseLocks; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_DatabaseLocks" (
    "LockID" integer,
    "LockType" integer,
    "UserName" text,
    "MachineName" text
);


--
-- Name: GDB_DefaultValues; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_DefaultValues" (
    "ClassID" integer,
    "FieldName" character varying(510),
    "Subtype" integer,
    "DefaultNumber" double precision,
    "DefaultString" character varying(510)
);


--
-- Name: GDB_Domains; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_Domains" (
    "ID" integer,
    "Owner" character varying(510),
    "DomainName" character varying(510),
    "DomainType" integer,
    "Description" character varying(510),
    "FieldType" integer,
    "MergePolicy" integer,
    "SplitPolicy" integer
);


--
-- Name: GDB_EdgeConnRules; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_EdgeConnRules" (
    "RuleID" integer,
    "FromClassID" integer,
    "FromSubtype" integer,
    "ToClassID" integer,
    "ToSubtype" integer,
    "Junctions" bytea
);


--
-- Name: GDB_Extensions; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_Extensions" (
    "ID" integer,
    "Name" character varying(510),
    "CLSID" character varying(510)
);


--
-- Name: GDB_FeatureClasses; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_FeatureClasses" (
    "ObjectClassID" integer,
    "FeatureType" integer,
    "GeometryType" integer,
    "ShapeField" character varying(510),
    "GeomNetworkID" integer,
    "GraphID" integer
);


--
-- Name: GDB_FeatureDataset; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_FeatureDataset" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "SRID" integer
);


--
-- Name: GDB_FieldInfo; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_FieldInfo" (
    "ClassID" integer,
    "FieldName" character varying(510),
    "AliasName" character varying(510),
    "ModelName" character varying(510),
    "DefaultDomainName" character varying(510),
    "DefaultValueString" character varying(510),
    "DefaultValueNumber" double precision,
    "IsRequired" integer,
    "IsSubtypeFixed" integer,
    "IsEditable" integer
);


--
-- Name: GDB_GeomColumns; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_GeomColumns" (
    "TableName" character varying(510),
    "FieldName" character varying(510),
    "ShapeType" integer,
    "ExtentLeft" double precision,
    "ExtentBottom" double precision,
    "ExtentRight" double precision,
    "ExtentTop" double precision,
    "IdxOriginX" double precision,
    "IdxOriginY" double precision,
    "IdxGridSize" double precision,
    "SRID" integer,
    "HasZ" integer,
    "HasM" integer
);


--
-- Name: GDB_JnConnRules; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_JnConnRules" (
    "RuleID" integer,
    "EdgeClassID" integer,
    "EdgeSubtype" integer,
    "JunctionClassID" integer,
    "JunctionSubtype" integer,
    "EdgeMinCard" integer,
    "EdgeMaxCard" integer,
    "JunctionMinCard" integer,
    "JunctionMaxCard" integer,
    "IsDefault" integer
);


--
-- Name: GDB_NetDatasets; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_NetDatasets" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetID" integer,
    "Properties" bytea
);


--
-- Name: GDB_ObjectClasses; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_ObjectClasses" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "AliasName" character varying(510),
    "ModelName" character varying(510),
    "CLSID" character varying(510),
    "EXTCLSID" character varying(510),
    "EXTPROPS" bytea,
    "DatasetID" integer,
    "SubtypeField" character varying(510)
);


--
-- Name: GDB_RangeDomains; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_RangeDomains" (
    "DomainID" integer,
    "MinValue" double precision,
    "MaxValue" double precision
);


--
-- Name: GDB_RasterCatalogs; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_RasterCatalogs" (
    "ObjectClassID" integer,
    "RasterField" character varying(510),
    "IsRasterDataset" integer
);


--
-- Name: GDB_RelClasses; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_RelClasses" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "OriginClassID" integer,
    "DestClassID" integer,
    "ForwardLabel" character varying(510),
    "BackwardLabel" character varying(510),
    "Cardinality" integer,
    "Notification" integer,
    "IsComposite" integer,
    "IsAttributed" integer,
    "OriginPrimaryKey" character varying(510),
    "DestPrimaryKey" character varying(510),
    "OriginForeignKey" character varying(510),
    "DestForeignKey" character varying(510),
    "DatasetID" integer
);


--
-- Name: GDB_RelRules; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_RelRules" (
    "RuleID" integer,
    "OriginSubtype" integer,
    "OriginMinCard" integer,
    "OriginMaxCard" integer,
    "DestSubtype" integer,
    "DestMinCard" integer,
    "DestMaxCard" integer
);


--
-- Name: GDB_ReleaseInfo; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_ReleaseInfo" (
    "Major" integer,
    "Minor" integer,
    "Bugfix" integer
);


--
-- Name: GDB_ReplicaDatasets; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_ReplicaDatasets" (
    "ID" integer,
    "ReplicaID" integer,
    "DatasetType" integer,
    "DatasetID" integer,
    "ParentOwner" character varying(510),
    "ParentDB" character varying(510)
);


--
-- Name: GDB_Replicas; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_Replicas" (
    "ID" integer,
    "Name" character varying(510),
    "Owner" character varying(510),
    "Version" character varying(510),
    "ParentID" integer,
    "RepDate" timestamp without time zone,
    "DefQuery" bytea,
    "RepGuid" character varying(510),
    "RepCInfo" character varying(510),
    "Role" integer
);


--
-- Name: GDB_SpatialRefs; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_SpatialRefs" (
    "SRID" integer,
    "SRTEXT" text,
    "FalseX" double precision,
    "FalseY" double precision,
    "XYUnits" double precision,
    "FalseZ" double precision,
    "ZUnits" double precision,
    "FalseM" double precision,
    "MUnits" double precision
);


--
-- Name: GDB_StringDomains; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_StringDomains" (
    "DomainID" integer,
    "Format" character varying(510)
);


--
-- Name: GDB_Subtypes; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_Subtypes" (
    "ID" integer,
    "ClassID" integer,
    "SubtypeCode" integer,
    "SubtypeName" character varying(510)
);


--
-- Name: GDB_Toolboxes; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_Toolboxes" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "Alias" character varying(510),
    "HelpFile" character varying(510),
    "HelpContext" integer
);


--
-- Name: GDB_TopoClasses; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_TopoClasses" (
    "ClassID" integer,
    "TopologyID" integer,
    "Weight" double precision,
    "XYRank" integer,
    "ZRank" integer,
    "EventsOnAnalyze" integer
);


--
-- Name: GDB_TopoRules; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_TopoRules" (
    "RuleID" integer,
    "OriginClassID" integer,
    "OriginSubtype" integer,
    "AllOriginSubtypes" integer,
    "DestClassID" integer,
    "DestSubtype" integer,
    "AllDestSubtypes" integer,
    "TopologyRuleType" integer,
    "Name" character varying(510),
    "RuleGUID" character varying(510)
);


--
-- Name: GDB_Topologies; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_Topologies" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetID" integer,
    "Properties" bytea
);


--
-- Name: GDB_UserMetadata; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_UserMetadata" (
    "ID" integer,
    "DatabaseName" character varying(510),
    "Owner" character varying(510),
    "Name" character varying(510),
    "DatasetType" integer,
    "Xml" bytea
);


--
-- Name: GDB_ValidRules; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."GDB_ValidRules" (
    "ID" integer,
    "RuleType" integer,
    "ClassID" integer,
    "RuleCategory" integer,
    "HelpString" character varying(510)
);


--
-- Name: InlandCountryBoundary; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."InlandCountryBoundary" (
    "OBJECTID" integer,
    "Shape" bytea,
    "LEFTPOLYGON" character varying(4),
    "RIGHTPOLYGON" character varying(4),
    "Shape_Length" double precision
);


--
-- Name: InlandCountryBoundary_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."InlandCountryBoundary_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: InlandRegionBoundary; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."InlandRegionBoundary" (
    "OBJECTID" integer,
    "Shape" bytea,
    "LeftRegion" character varying(2),
    "RightRegion" character varying(2),
    "Shape_Length" double precision
);


--
-- Name: InlandRegionBoundary_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."InlandRegionBoundary_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: PreviousSurveydata_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."PreviousSurveydata_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: ProtRang; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."ProtRang" (
    "OBJECTID" integer,
    "Shape" bytea,
    "Range" integer,
    "RangeQuality" character varying(20),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "AREA_SQKM" integer,
    "RefID" integer,
    "Call_Number" character varying(60),
    "Year_" integer,
    "ScaleDenominator" integer,
    "PHENOTYPE" character varying(100),
    "PhTypeBasis" character varying(100),
    "PhTypeRef" integer,
    "DataStatus" character varying(4),
    "DataStatusDetails" text,
    "Comments" text,
    "PTACODE" integer,
    "PTANAME" character varying(100),
    "CCODE_1" character varying(6),
    "YEAR_EST" integer,
    "IUCNCAT" character varying(8),
    "IUCNCATARABIC" integer,
    "DESIGNATE" character varying(100),
    "AbvDesig" character varying(10),
    "AREA_SQKM_1" integer,
    "REPORTED" integer,
    "CALCULATED" integer,
    "Source" character varying(100),
    "RefID_1" integer,
    "InRange" integer,
    "SameSurveyzone" integer,
    "Selection" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: ProtRang_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."ProtRang_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Protarea; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Protarea" (
    "OBJECTID" integer,
    "Shape" bytea,
    "PTACODE" integer,
    "PTANAME" character varying(100),
    "CCODE" character varying(6),
    "YEAR_EST" integer,
    "IUCNCAT" character varying(8),
    "IUCNCATARABIC" smallint,
    "DESIGNATE" character varying(100),
    "AbvDesig" character varying(10),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "CALCULATED" integer,
    "Source" character varying(100),
    "RefID" integer,
    "InRange" integer,
    "SameSurveyzone" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "Selection" smallint
);


--
-- Name: Protarea_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Protarea_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Range; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Range" (
    "OBJECTID_1" integer,
    "Shape" bytea,
    "Range" integer,
    "RangeQuality" character varying(20),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "AREA_SQKM" integer,
    "RefID" integer,
    "Call_Number" character varying(60),
    "Year" integer,
    "ScaleDenominator" integer,
    "PHENOTYPE" character varying(100),
    "PhTypeBasis" character varying(100),
    "PhTypeRef" integer,
    "DataStatus" character varying(4),
    "DataStatusDetails" text,
    "Comments" text,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RangeHabitat; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."RangeHabitat" (
    "OBJECTID" integer,
    "Shape" bytea,
    "Range" integer,
    "RangeQuali" character varying(20),
    "Region" character varying(30),
    "CCODE" character varying(4),
    "AREA_SQKM" integer,
    "RefID" integer,
    "PHENOTYPE" character varying(100),
    "PhTypeBasi" character varying(100),
    "PhTypeRef" integer,
    "DataStatus" character varying(4),
    "Comments" character varying(508),
    "RangeHabitat" character varying(30),
    "Selection" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RangeHabitat_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."RangeHabitat_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RangeLAZEA; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."RangeLAZEA" (
    "OBJECTID_1" integer,
    "Shape" bytea,
    "Range" integer,
    "RangeQuality" character varying(20),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "AREA_SQKM" integer,
    "RefID" integer,
    "Call_Number" character varying(60),
    "Year_" integer,
    "ScaleDenominator" integer,
    "PHENOTYPE" character varying(100),
    "PhTypeBasis" character varying(100),
    "PhTypeRef" integer,
    "DataStatus" character varying(4),
    "DataStatusDetails" text,
    "Comments" text,
    "Shape_Length" double precision,
    "Shape_Area" double precision,
    "CCRRQ" character varying(30)
);


--
-- Name: RangeLAZEA_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."RangeLAZEA_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RangePoint; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."RangePoint" (
    "OBJECTID" integer,
    "SHAPE" bytea,
    "CCODE" character varying(4),
    "AreaName" character varying(100),
    "Latitude" real,
    "Longitude" real,
    "DateObtained" character varying(100),
    "YearOfRecord" character varying(100),
    "MonthOfRecord" character varying(4),
    "TypeOfRecord" character varying(100),
    "SourceQuality" character varying(4),
    "EleNumber" integer,
    "ReferenceID" integer,
    "Call_Number" character varying(60),
    "DateDigitized" timestamp without time zone,
    "GeoPrecision" character varying(4),
    "InRange" smallint,
    "Show" integer,
    "DataStatus" character varying(4),
    "DataStatusDetails" text
);


--
-- Name: RangePoint_SHAPE_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."RangePoint_SHAPE_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Range_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Range_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: References; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."References" (
    "Ref_ID" integer,
    "Authors" character varying(500),
    "Title" character varying(500),
    "Keywords" text,
    "Ref_mark" character varying(2),
    "Ref_user" character varying(60),
    "Year_pub" integer,
    "Ref_type" character varying(60),
    "Subject" character varying(200),
    "Sec_authors" character varying(500),
    "Sec_title" character varying(500),
    "Notes" text,
    "Place_pub" character varying(200),
    "Publisher" character varying(300),
    "Volume" character varying(40),
    "Number" character varying(40),
    "Page_start" character varying(40),
    "Page_end" character varying(40),
    "Tert_authors" character varying(500),
    "Tert_title" character varying(500),
    "Edition" character varying(40),
    "Date_pub" timestamp without time zone,
    "Type_work" character varying(200),
    "Quat_authors" character varying(500),
    "Quat_title" character varying(500),
    "Isbn_issn" character varying(40),
    "Label" character varying(120),
    "Abstract" text,
    "Date_input" timestamp without time zone,
    "Availability" character varying(100),
    "Location" character varying(300),
    "Address" character varying(500),
    "Language" character varying(60),
    "Country" character varying(60),
    "Url" character varying(500),
    "Custom_1" character varying(500),
    "Custom_2" character varying(500),
    "Custom_3" character varying(200),
    "Custom_4" character varying(200),
    "Ref_doc" text,
    "Date_modified" timestamp without time zone,
    "Ref_read" character varying(2),
    "Priority" character varying(20),
    "Ref_type_ID" integer,
    "Internal" character varying(40),
    "Modified_by" character varying(60),
    "Custom_5" character varying(100),
    "Custom_6" character varying(100),
    "Attachment" character varying(500),
    "File_as" character varying(60),
    "Call_number" character varying(60),
    "Description" character varying(300),
    "Reprint" character varying(24),
    "Date_freeform" character varying(40),
    "Ref_misc" character varying(200),
    "Categories" character varying(200),
    "Web_post_hide" character varying(2),
    "Title_short" character varying(200),
    "Work_reviewed" character varying(200),
    "Extent_work" character varying(200),
    "Section" character varying(40),
    "Accession_num" character varying(40),
    "Last_post" character varying(44),
    "BPPalmId" integer,
    "BPPrivate" integer,
    "BPModified" integer,
    "BPDeleted" integer,
    "BPArchived" integer,
    "BPCategory" integer,
    "BPSyncAction" integer,
    "OBJECTID" integer
);


--
-- Name: Regiongrp; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Regiongrp" (
    "REGION" character varying(40),
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(510),
    "VARIANCE" double precision,
    "ESTIMATE" double precision,
    "ACTUALSEEN" double precision,
    "DEFINITE" double precision,
    "PROBABLE" double precision,
    "POSSIBLE" double precision,
    "SPECUL" double precision
);


--
-- Name: Regions_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Regions_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: RiverLake; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."RiverLake" (
    "OBJECTID" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "FeatureType" integer,
    "Name" character varying(100),
    "Show" integer,
    "Label" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: RiverLake_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."RiverLake_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Roads; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Roads" (
    "OBJECTID" integer,
    "Shape" bytea,
    "CCODE" character varying(4),
    "Shape_Length" double precision
);


--
-- Name: Roads_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Roads_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: SelectedObjects; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."SelectedObjects" (
    "SelectionID" integer,
    "ObjectID" integer
);


--
-- Name: Selections; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Selections" (
    "SelectionID" integer,
    "TargetName" character varying(510)
);


--
-- Name: SurvRang; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."SurvRang" (
    "OBJECTID" integer,
    "Shape" bytea,
    "INPCODE" character varying(12),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "EFFSAMPINT" real,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "UCL95Asym" real,
    "LCL95Asym" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "RefID" integer,
    "Call_Number" character varying(60),
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "PFS" integer,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "DateIn" timestamp without time zone,
    "DateOut" timestamp without time zone,
    "Comments" text,
    "DESIGNATE" character varying(100),
    "AbvDesignate" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "ScaleDenominator" integer,
    "Report" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "LON" double precision,
    "LAT" double precision,
    "Range" integer,
    "RangeQuality" character varying(20),
    "CCODE_1" character varying(4),
    "CNTRYNAME_1" character varying(60),
    "AREA_SQKM_1" integer,
    "RefID_1" integer,
    "Call_Number_1" character varying(60),
    "Year_" integer,
    "ScaleDenominator_1" integer,
    "PHENOTYPE" character varying(100),
    "PhTypeBasis" character varying(100),
    "PhTypeRef" integer,
    "DataStatus" character varying(4),
    "DataStatusDetails" text,
    "Comments_1" text,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: SurvRang_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."SurvRang_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Surveydata_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Surveydata_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_10_DirtyAreas; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_10_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_10_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_10_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_10_LineErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_10_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_10_LineErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_10_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_10_PointErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_10_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_10_PointErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_10_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_10_PolyErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_10_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_10_PolyErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_10_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_11_DirtyAreas; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_11_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_11_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_11_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_11_LineErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_11_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_11_LineErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_11_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_11_PointErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_11_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_11_PointErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_11_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_11_PolyErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_11_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_11_PolyErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_11_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_4_DirtyAreas; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_4_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_4_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_4_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_4_LineErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_4_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_4_LineErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_4_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_4_PointErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_4_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_4_PointErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_4_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_4_PolyErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_4_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_4_PolyErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_4_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_DirtyAreas; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_8_DirtyAreas" (
    "ObjectID" integer,
    "IsRetired" integer,
    "DirtyArea" bytea,
    "DirtyArea_Length" double precision,
    "DirtyArea_Area" double precision
);


--
-- Name: T_8_DirtyAreas_DirtyArea_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_8_DirtyAreas_DirtyArea_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_LineErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_8_LineErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision
);


--
-- Name: T_8_LineErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_8_LineErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_PointErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_8_PointErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer
);


--
-- Name: T_8_PointErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_8_PointErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: T_8_PolyErrors; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_8_PolyErrors" (
    "ObjectID" integer,
    "OriginClassID" integer,
    "OriginID" integer,
    "DestClassID" integer,
    "DestID" integer,
    "TopoRuleType" integer,
    "TopoRuleID" integer,
    "Shape" bytea,
    "IsException" integer,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: T_8_PolyErrors_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."T_8_PolyErrors_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: Towns; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Towns" (
    "OBJECTID_1" integer,
    "Shape" bytea,
    "TWNTYPE" integer,
    "TWNNAME" character varying(80),
    "CCODE" character varying(4),
    "Show" integer
);


--
-- Name: Towns_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."Towns_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: WaterLine; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."WaterLine" (
    "OBJECTID" integer,
    "Shape" bytea,
    "WaterLineType" integer,
    "Name" character varying(100),
    "Show" integer,
    "Label" integer,
    "Shape_Length" double precision
);


--
-- Name: WaterLine_Shape_Index; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."WaterLine_Shape_Index" (
    "IndexedObjectId" integer,
    "MinGX" integer,
    "MinGY" integer,
    "MaxGX" integer,
    "MaxGY" integer
);


--
-- Name: actual_diff_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.actual_diff_continent AS
 SELECT a."CONTINENT",
    (a."DEFINITE" - o."DEFINITE") AS actual_dif_def,
    (a."PROBABLE" - o."PROBABLE") AS actual_dif_prob,
    (a."POSSIBLE" - o."POSSIBLE") AS actual_dif_poss,
    (a."SPECUL" - o."SPECUL") AS actual_dif_spec
   FROM (aed2007."Continent" a
     JOIN ( SELECT 'Africa'::text AS "CONTINENT",
            "Continent"."OBJECTID",
            "Continent"."Shape",
            "Continent"."AREA",
            "Continent"."PERIMETER",
            "Continent"."DEFINITE",
            "Continent"."PROBABLE",
            "Continent"."POSSIBLE",
            "Continent"."SPECUL",
            "Continent"."CNTRYAREA",
            "Continent"."RANGEAREA",
            "Continent"."KNOWNRANGEAREA",
            "Continent"."POSSRANGEAREA",
            "Continent"."PA_AREA",
            "Continent"."SURVEYAREA",
            "Continent"."PROTRANG",
            "Continent"."SURVRANG",
            "Continent"."RANGEPERC",
            "Continent"."PAPERC",
            "Continent"."SURVEYPERC",
            "Continent"."PROTRANGPERC",
            "Continent"."SURVRANGPERC",
            "Continent"."Shape_Length",
            "Continent"."Shape_Area",
            "Continent"."PROBFRACTION",
            "Continent"."INFOQUALINDEX"
           FROM aed2002."Continent") o ON (((a."CONTINENT")::text = o."CONTINENT")));


--
-- Name: actual_diff_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.actual_diff_country AS
 SELECT a."CCODE",
    (a."DEFINITE" - o."DEFINITE") AS actual_dif_def,
    (a."PROBABLE" - o."PROBABLE") AS actual_dif_prob,
    (a."POSSIBLE" - o."POSSIBLE") AS actual_dif_poss,
    (a."SPECUL" - o."SPECUL") AS actual_dif_spec
   FROM (aed2007."Country" a
     JOIN aed2002."Country" o ON (((a."CCODE")::text = (o."CCODE")::text)));


--
-- Name: actual_diff_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.actual_diff_region AS
 SELECT a."REGION",
    (a."DEFINITE" - o."DEFINITE") AS actual_dif_def,
    (a."PROBABLE" - o."PROBABLE") AS actual_dif_prob,
    (a."POSSIBLE" - o."POSSIBLE") AS actual_dif_poss,
    (a."SPECUL" - o."SPECUL") AS actual_dif_spec
   FROM (aed2007."Regions" a
     JOIN aed2002."Regions" o ON (((a."REGION")::text = (o."REGION")::text)));


--
-- Name: fractional_area_of_range_covered_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.fractional_area_of_range_covered_by_country AS
 SELECT 'Africa'::text AS "CONTINENT",
    t1.ccode,
    t1."REGION",
    t1.surveytype,
    t3.known,
    t2.possible,
    t1.total
   FROM ((( SELECT "Country"."CCODE" AS ccode,
            "Country"."REGION",
                CASE
                    WHEN ("SurvRang"."SURVEYTYPE" IS NULL) THEN 'Unassessed Range'::character varying
                    ELSE "SurvRang"."SURVEYTYPE"
                END AS surveytype,
            sum("SurvRang"."Shape_Area") AS total
           FROM (aed2007."SurvRang"
             JOIN aed2007."Country" ON (((("SurvRang"."CNTRYNAME_1")::text = ("Country"."CNTRYNAME")::text) AND ("SurvRang"."Range" = 1))))
          GROUP BY "Country"."CCODE", "Country"."REGION", "SurvRang"."SURVEYTYPE"
          ORDER BY "Country"."CCODE", "SurvRang"."SURVEYTYPE") t1
     LEFT JOIN ( SELECT "Country"."CCODE" AS ccode,
                CASE
                    WHEN ("SurvRang"."SURVEYTYPE" IS NULL) THEN 'Unassessed Range'::character varying
                    ELSE "SurvRang"."SURVEYTYPE"
                END AS surveytype,
            sum("SurvRang"."Shape_Area") AS possible
           FROM (aed2007."SurvRang"
             JOIN aed2007."Country" ON (((("SurvRang"."CNTRYNAME_1")::text = ("Country"."CNTRYNAME")::text) AND ("SurvRang"."Range" = 1) AND (("SurvRang"."RangeQuality")::text = 'Possible'::text))))
          GROUP BY "Country"."CCODE", "SurvRang"."SURVEYTYPE"
          ORDER BY "Country"."CCODE", "SurvRang"."SURVEYTYPE") t2 ON ((((t1.surveytype)::text = (t2.surveytype)::text) AND ((t1.ccode)::text = (t2.ccode)::text))))
     LEFT JOIN ( SELECT "Country"."CCODE" AS ccode,
                CASE
                    WHEN ("SurvRang"."SURVEYTYPE" IS NULL) THEN 'Unassessed Range'::character varying
                    ELSE "SurvRang"."SURVEYTYPE"
                END AS surveytype,
            sum("SurvRang"."Shape_Area") AS known
           FROM (aed2007."SurvRang"
             JOIN aed2007."Country" ON (((("SurvRang"."CNTRYNAME_1")::text = ("Country"."CNTRYNAME")::text) AND ("SurvRang"."Range" = 1) AND (("SurvRang"."RangeQuality")::text = 'Known'::text))))
          GROUP BY "Country"."CCODE", "SurvRang"."SURVEYTYPE"
          ORDER BY "Country"."CCODE", "SurvRang"."SURVEYTYPE") t3 ON ((((t1.surveytype)::text = (t3.surveytype)::text) AND ((t1.ccode)::text = (t3.ccode)::text))));


--
-- Name: surveytypes; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007.surveytypes (
    surveytype text,
    display_order integer
);


--
-- Name: area_of_range_covered_by_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.area_of_range_covered_by_continent AS
 SELECT v."CONTINENT",
    v.surveytype,
    round(sum(v.known)) AS known,
    round(sum(v.possible)) AS possible,
    round(sum(v.total)) AS total
   FROM (aed2007.fractional_area_of_range_covered_by_country v
     JOIN aed2007.surveytypes s ON (((v.surveytype)::text = s.surveytype)))
  GROUP BY v."CONTINENT", v.surveytype, s.display_order
  ORDER BY s.display_order;


--
-- Name: area_of_range_covered_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.area_of_range_covered_by_country AS
 SELECT r.ccode,
    r.surveytype,
    round(r.known) AS known,
    round(r.possible) AS possible,
    round(r.total) AS total
   FROM (aed2007.fractional_area_of_range_covered_by_country r
     JOIN aed2007.surveytypes s ON (((r.surveytype)::text = s.surveytype)))
  ORDER BY s.display_order;


--
-- Name: area_of_range_covered_by_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.area_of_range_covered_by_region AS
 SELECT c."REGION",
    v.surveytype,
    round(sum(v.known)) AS known,
    round(sum(v.possible)) AS possible,
    round(sum(v.total)) AS total
   FROM ((aed2007."Country" c
     JOIN aed2007.fractional_area_of_range_covered_by_country v ON (((c."CCODE")::text = (v.ccode)::text)))
     JOIN aed2007.surveytypes s ON (((v.surveytype)::text = s.surveytype)))
  GROUP BY c."REGION", v.surveytype, s.display_order
  ORDER BY c."REGION", s.display_order;


--
-- Name: area_of_range_covered_sum_by_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.area_of_range_covered_sum_by_continent AS
 SELECT fractional_area_of_range_covered_by_country."CONTINENT",
    round(sum(fractional_area_of_range_covered_by_country.known)) AS known,
    round(sum(fractional_area_of_range_covered_by_country.possible)) AS possible,
    round(sum(fractional_area_of_range_covered_by_country.total)) AS total
   FROM aed2007.fractional_area_of_range_covered_by_country
  GROUP BY fractional_area_of_range_covered_by_country."CONTINENT"
  ORDER BY fractional_area_of_range_covered_by_country."CONTINENT";


--
-- Name: area_of_range_covered_sum_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.area_of_range_covered_sum_by_country AS
 SELECT fractional_area_of_range_covered_by_country.ccode,
    round(sum(fractional_area_of_range_covered_by_country.known)) AS known,
    round(sum(fractional_area_of_range_covered_by_country.possible)) AS possible,
    round(sum(fractional_area_of_range_covered_by_country.total)) AS total
   FROM aed2007.fractional_area_of_range_covered_by_country
  GROUP BY fractional_area_of_range_covered_by_country.ccode
  ORDER BY fractional_area_of_range_covered_by_country.ccode;


--
-- Name: area_of_range_covered_sum_by_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.area_of_range_covered_sum_by_region AS
 SELECT fractional_area_of_range_covered_by_country."REGION",
    round(sum(fractional_area_of_range_covered_by_country.known)) AS known,
    round(sum(fractional_area_of_range_covered_by_country.possible)) AS possible,
    round(sum(fractional_area_of_range_covered_by_country.total)) AS total
   FROM aed2007.fractional_area_of_range_covered_by_country
  GROUP BY fractional_area_of_range_covered_by_country."REGION"
  ORDER BY fractional_area_of_range_covered_by_country."REGION";


--
-- Name: factor_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.factor_continent AS
 SELECT a."CONTINENT",
    ((a.actual_dif_def)::double precision /
        CASE
            WHEN (sum(i."DIFDEF") = (0)::double precision) THEN (1)::double precision
            ELSE sum(i."DIFDEF")
        END) AS def_factor,
    ((a.actual_dif_prob)::double precision /
        CASE
            WHEN (sum(i."DIFPROB") = (0)::double precision) THEN (1)::double precision
            ELSE sum(i."DIFPROB")
        END) AS prob_factor,
    ((a.actual_dif_poss)::double precision /
        CASE
            WHEN (sum(i."DIFPOSS") = (0)::double precision) THEN (1)::double precision
            ELSE sum(i."DIFPOSS")
        END) AS poss_factor,
    ((a.actual_dif_spec)::numeric /
        CASE
            WHEN (sum(i."DIFSPEC") = (0)::numeric) THEN (1)::numeric
            ELSE sum(i."DIFSPEC")
        END) AS spec_factor
   FROM aed2007."ChangesInterpreter" i,
    aed2007.actual_diff_continent a
  GROUP BY a."CONTINENT", a.actual_dif_def, a.actual_dif_prob, a.actual_dif_poss, a.actual_dif_spec;


--
-- Name: fractional_causes_of_change_by_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.fractional_causes_of_change_by_continent AS
 SELECT f."CONTINENT",
    i."CauseofChange",
    (f.def_factor * sum(i."DIFDEF")) AS definite,
    (f.prob_factor * sum(i."DIFPROB")) AS probable,
    (f.poss_factor * sum(i."DIFPOSS")) AS possible,
    (f.spec_factor * sum(i."DIFSPEC")) AS specul
   FROM aed2007."ChangesInterpreter" i,
    aed2007.factor_continent f
  GROUP BY f."CONTINENT", i.display_order, i."CauseofChange", f.def_factor, f.prob_factor, f.poss_factor, f.spec_factor
  ORDER BY f."CONTINENT", i.display_order;


--
-- Name: causes_of_change_by_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.causes_of_change_by_continent AS
 SELECT fractional_causes_of_change_by_continent."CONTINENT",
    fractional_causes_of_change_by_continent."CauseofChange",
    round(fractional_causes_of_change_by_continent.definite) AS definite,
    round(fractional_causes_of_change_by_continent.probable) AS probable,
    round(fractional_causes_of_change_by_continent.possible) AS possible,
    round(fractional_causes_of_change_by_continent.specul) AS specul
   FROM aed2007.fractional_causes_of_change_by_continent;


--
-- Name: factor_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.factor_country AS
 SELECT a."CCODE" AS ccode,
    ((a.actual_dif_def)::double precision /
        CASE
            WHEN (sum(i.sumofdefinite) = (0)::double precision) THEN (1)::double precision
            ELSE sum(i.sumofdefinite)
        END) AS def_factor,
    ((a.actual_dif_prob)::double precision /
        CASE
            WHEN (sum(i.sumofprobable) = (0)::double precision) THEN (1)::double precision
            ELSE sum(i.sumofprobable)
        END) AS prob_factor,
    ((a.actual_dif_poss)::double precision /
        CASE
            WHEN (sum(i.sumofpossible) = (0)::double precision) THEN (1)::double precision
            ELSE sum(i.sumofpossible)
        END) AS poss_factor,
    ((a.actual_dif_spec)::numeric /
        CASE
            WHEN (sum(i.sumofspecul) = (0)::numeric) THEN (1)::numeric
            ELSE sum(i.sumofspecul)
        END) AS spec_factor
   FROM (aed2007.changesgrp i
     JOIN aed2007.actual_diff_country a ON (((i."CCODE")::text = (a."CCODE")::text)))
  WHERE ((i."ReasonForChange")::text <> 'NC'::text)
  GROUP BY a."CCODE", a.actual_dif_def, a.actual_dif_prob, a.actual_dif_poss, a.actual_dif_spec;


--
-- Name: fractional_causes_of_change_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.fractional_causes_of_change_by_country AS
 SELECT g."CCODE" AS ccode,
    "CausesOfChange"."CauseofChange",
    (f.def_factor * sum(g.sumofdefinite)) AS definite,
    (f.prob_factor * sum(g.sumofprobable)) AS probable,
    (f.poss_factor * sum(g.sumofpossible)) AS possible,
    (f.spec_factor * sum(g.sumofspecul)) AS specul
   FROM ((aed2007.changesgrp g
     JOIN aed2007.factor_country f ON (((g."CCODE")::text = (f.ccode)::text)))
     JOIN aed2007."CausesOfChange" ON (((g."ReasonForChange")::text = ("CausesOfChange"."ChangeCODE")::text)))
  GROUP BY g."CCODE", "CausesOfChange".display_order, "CausesOfChange"."CauseofChange", f.def_factor, f.prob_factor, f.poss_factor, f.spec_factor
  ORDER BY g."CCODE", "CausesOfChange".display_order, "CausesOfChange"."CauseofChange";


--
-- Name: causes_of_change_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.causes_of_change_by_country AS
 SELECT fractional_causes_of_change_by_country.ccode,
    fractional_causes_of_change_by_country."CauseofChange",
    round(fractional_causes_of_change_by_country.definite) AS definite,
    round(fractional_causes_of_change_by_country.probable) AS probable,
    round(fractional_causes_of_change_by_country.possible) AS possible,
    round(fractional_causes_of_change_by_country.specul) AS specul
   FROM aed2007.fractional_causes_of_change_by_country;


--
-- Name: factor_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.factor_region AS
 SELECT i."REGION",
    ((a.actual_dif_def)::double precision /
        CASE
            WHEN (sum(i."DIFDEF") = (0)::double precision) THEN (1)::double precision
            ELSE sum(i."DIFDEF")
        END) AS def_factor,
    ((a.actual_dif_prob)::double precision /
        CASE
            WHEN (sum(i."DIFPROB") = (0)::double precision) THEN (1)::double precision
            ELSE sum(i."DIFPROB")
        END) AS prob_factor,
    ((a.actual_dif_poss)::double precision /
        CASE
            WHEN (sum(i."DIFPOSS") = (0)::double precision) THEN (1)::double precision
            ELSE sum(i."DIFPOSS")
        END) AS poss_factor,
    ((a.actual_dif_spec)::numeric /
        CASE
            WHEN (sum(i."DIFSPEC") = (0)::numeric) THEN (1)::numeric
            ELSE sum(i."DIFSPEC")
        END) AS spec_factor
   FROM (aed2007."ChangesInterpreter" i
     JOIN aed2007.actual_diff_region a ON (((i."REGION")::text = (a."REGION")::text)))
  GROUP BY i."REGION", a.actual_dif_def, a.actual_dif_prob, a.actual_dif_poss, a.actual_dif_spec;


--
-- Name: fractional_causes_of_change_by_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.fractional_causes_of_change_by_region AS
 SELECT i."REGION",
    i."CauseofChange",
    (f.def_factor * sum(i."DIFDEF")) AS definite,
    (f.prob_factor * sum(i."DIFPROB")) AS probable,
    (f.poss_factor * sum(i."DIFPOSS")) AS possible,
    (f.spec_factor * sum(i."DIFSPEC")) AS specul
   FROM (aed2007."ChangesInterpreter" i
     JOIN aed2007.factor_region f ON (((i."REGION")::text = (f."REGION")::text)))
  GROUP BY i."REGION", i.display_order, i."CauseofChange", f.def_factor, f.prob_factor, f.poss_factor, f.spec_factor
  ORDER BY i."REGION", i.display_order;


--
-- Name: causes_of_change_by_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.causes_of_change_by_region AS
 SELECT fractional_causes_of_change_by_region."REGION",
    fractional_causes_of_change_by_region."CauseofChange",
    round(fractional_causes_of_change_by_region.definite) AS definite,
    round(fractional_causes_of_change_by_region.probable) AS probable,
    round(fractional_causes_of_change_by_region.possible) AS possible,
    round(fractional_causes_of_change_by_region.specul) AS specul
   FROM aed2007.fractional_causes_of_change_by_region;


--
-- Name: causes_of_change_sums_by_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.causes_of_change_sums_by_continent AS
 SELECT fractional_causes_of_change_by_continent."CONTINENT",
    round(sum(fractional_causes_of_change_by_continent.definite)) AS definite,
    round(sum(fractional_causes_of_change_by_continent.probable)) AS probable,
    round(sum(fractional_causes_of_change_by_continent.possible)) AS possible,
    round(sum(fractional_causes_of_change_by_continent.specul)) AS specul
   FROM aed2007.fractional_causes_of_change_by_continent
  GROUP BY fractional_causes_of_change_by_continent."CONTINENT";


--
-- Name: causes_of_change_sums_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.causes_of_change_sums_by_country AS
 SELECT fractional_causes_of_change_by_country.ccode,
    round(sum(fractional_causes_of_change_by_country.definite)) AS definite,
    round(sum(fractional_causes_of_change_by_country.probable)) AS probable,
    round(sum(fractional_causes_of_change_by_country.possible)) AS possible,
    round(sum(fractional_causes_of_change_by_country.specul)) AS specul
   FROM aed2007.fractional_causes_of_change_by_country
  GROUP BY fractional_causes_of_change_by_country.ccode;


--
-- Name: causes_of_change_sums_by_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.causes_of_change_sums_by_region AS
 SELECT fractional_causes_of_change_by_region."REGION",
    round(sum(fractional_causes_of_change_by_region.definite)) AS definite,
    round(sum(fractional_causes_of_change_by_region.probable)) AS probable,
    round(sum(fractional_causes_of_change_by_region.possible)) AS possible,
    round(sum(fractional_causes_of_change_by_region.specul)) AS specul
   FROM aed2007.fractional_causes_of_change_by_region
  GROUP BY fractional_causes_of_change_by_region."REGION";


--
-- Name: continental_and_regional_totals_and_data_quality; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.continental_and_regional_totals_and_data_quality AS
 SELECT r."CONTINENT",
    r."REGION",
    r."DEFINITE",
    r."POSSIBLE",
    r."PROBABLE",
    r."SPECUL",
    r."RANGEAREA",
    round((((r."RANGEAREA")::double precision / (c.continental_rangearea)::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((r."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(r."INFQLTYIDX", '999999D99'::text) AS "INFQLTYIDX",
    round(ln(((r."INFQLTYIDX" + (1)::double precision) / ((r."RANGEAREA")::double precision / (c.continental_rangearea)::double precision)))) AS "PFS"
   FROM aed2007."Regions" r,
    ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed2007."Continent") c
  ORDER BY r."REGION";


--
-- Name: continental_and_regional_totals_and_data_quality_sum; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.continental_and_regional_totals_and_data_quality_sum AS
 SELECT r."CONTINENT",
    r."DEFINITE",
    r."POSSIBLE",
    r."PROBABLE",
    r."SPECUL",
    r."RANGEAREA",
    100 AS "RANGEPERC",
    round((r."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(r."INFQLTYIDX", '999999D99'::text) AS "INFQLTYIDX"
   FROM aed2007."Continent" r
  ORDER BY r."CONTINENT";


--
-- Name: country_and_regional_totals_and_data_quality; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.country_and_regional_totals_and_data_quality AS
 SELECT c."REGION",
    c."CNTRYNAME",
    c."DEFINITE",
    c."POSSIBLE",
    c."PROBABLE",
    c."SPECUL",
    c."RANGEAREA",
    round((((c."RANGEAREA")::double precision / (r."RANGEAREA")::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((c."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(c."INFQLTYIDX", '999999D99'::text) AS "INFQLTYIDX",
    round(log((((c."INFQLTYIDX")::double precision + (1)::double precision) / ((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision)))) AS "PFS"
   FROM ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed2007."Continent") a,
    (aed2007."Country" c
     JOIN aed2007."Regions" r ON (((c."REGION")::text = (r."REGION")::text)))
  ORDER BY c."REGION", c."CNTRYNAME";


--
-- Name: country_and_regional_totals_and_data_quality_sum; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.country_and_regional_totals_and_data_quality_sum AS
 SELECT c."REGION",
    c."DEFINITE",
    c."POSSIBLE",
    c."PROBABLE",
    c."SPECUL",
    c."RANGEAREA",
    round((((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision) * (100)::double precision)) AS "RANGEPERC",
    round((c."SURVRANGPERC" * (100)::double precision)) AS "SURVRANGPERC",
    to_char(c."INFQLTYIDX", '999999D99'::text) AS "INFQLTYIDX",
    round(ln((((c."INFQLTYIDX")::double precision + (1)::double precision) / ((c."RANGEAREA")::double precision / (a.continental_rangearea)::double precision)))) AS "PFS"
   FROM ( SELECT "Continent"."RANGEAREA" AS continental_rangearea
           FROM aed2007."Continent") a,
    aed2007."Regions" c
  ORDER BY c."REGION";


--
-- Name: elephant_estimates_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.elephant_estimates_by_country AS
 SELECT DISTINCT "Surveydata"."INPCODE",
    "Surveydata"."CCODE" AS ccode,
    "Surveydata"."OBJECTID",
        CASE
            WHEN (("ChangesTracker"."ReasonForChange")::text = 'NC'::text) THEN '-'::character varying
            ELSE "ChangesTracker"."ReasonForChange"
        END AS "ReasonForChange",
        CASE
            WHEN ("Surveydata"."DESIGNATE" IS NULL) THEN ("Surveydata"."SURVEYZONE")::text
            ELSE ((("Surveydata"."SURVEYZONE")::text || ' '::text) || ("Surveydata"."DESIGNATE")::text)
        END AS survey_zone,
    (("Surveydata"."METHOD")::text || "Surveydata"."QUALITY") AS method_and_quality,
    "Surveydata"."CATEGORY",
    "Surveydata"."CYEAR",
    "Surveydata"."ESTIMATE",
        CASE
            WHEN ("Surveydata"."CL95" IS NULL) THEN (to_char("Surveydata"."UPRANGE", '9999999'::text) || '*'::text)
            ELSE to_char(round(("Surveydata"."CL95")::double precision), '9999999'::text)
        END AS "CL95",
    "Surveydata"."REFERENCE",
    "Surveydata"."PFS",
    round(("Surveydata"."AREA_SQKM")::double precision) AS "AREA_SQKM",
    "Surveydata"."LON" AS numeric_lon,
    "Surveydata"."LAT" AS numeric_lat,
        CASE
            WHEN ("Surveydata"."LON" < (0)::double precision) THEN (to_char(abs("Surveydata"."LON"), '999D9'::text) || 'W'::text)
            WHEN ("Surveydata"."LON" = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs("Surveydata"."LON"), '999D9'::text) || 'E'::text)
        END AS "LON",
        CASE
            WHEN ("Surveydata"."LAT" < (0)::double precision) THEN (to_char(abs("Surveydata"."LAT"), '990D9'::text) || 'S'::text)
            WHEN ("Surveydata"."LAT" = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs("Surveydata"."LAT"), '990D9'::text) || 'N'::text)
        END AS "LAT"
   FROM (aed2007."Surveydata"
     LEFT JOIN aed2007."ChangesTracker" ON (("Surveydata"."OBJECTID" = "ChangesTracker"."CurrentOID")))
  ORDER BY "Surveydata"."CCODE",
        CASE
            WHEN ("Surveydata"."DESIGNATE" IS NULL) THEN ("Surveydata"."SURVEYZONE")::text
            ELSE ((("Surveydata"."SURVEYZONE")::text || ' '::text) || ("Surveydata"."DESIGNATE")::text)
        END;


--
-- Name: munyawana; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007.munyawana (
    "OBJECTID" integer,
    "Shape" bytea,
    "INPCODE" character varying(12),
    "CCODE" character varying(4),
    "CNTRYNAME" character varying(60),
    "SURVEYZONE" character varying(160),
    "CYEAR" integer,
    "CSEASON" character varying(20),
    "METHOD" character varying(4),
    "TCRATE" integer,
    "EFFSAMPINT" real,
    "SAMPINT" real,
    "PILENUM" integer,
    "DRMSITE" integer,
    "DDCL95P" real,
    "ESTIMATE" integer,
    "ACTUALSEEN" integer,
    "UPRANGE" integer,
    "STDERROR" real,
    "VARIANCE" real,
    "CL95" real,
    "CL95P" real,
    "UCL95Asym" real,
    "LCL95Asym" real,
    "CARCASS12" integer,
    "CARCASS3" integer,
    "CARCASST" integer,
    "REFERENCE" character varying(200),
    "RefID" integer,
    "Call_Number" character varying(60),
    "QUALITY" integer,
    "CATEGORY" character varying(2),
    "SURVEYTYPE" character varying(160),
    "PFS" integer,
    "DEFINITE" integer,
    "PROBABLE" integer,
    "POSSIBLE" integer,
    "SPECUL" integer,
    "DENSITY" real,
    "CRATIO12" real,
    "CRATIOT" real,
    "SELECTION" integer,
    "DateIn" timestamp without time zone,
    "DateOut" timestamp without time zone,
    "Comments" text,
    "DESIGNATE" character varying(100),
    "AbvDesignate" character varying(20),
    "AREA_SQKM" integer,
    "REPORTED" integer,
    "DERIVED" integer,
    "CALCULATED" integer,
    "ScaleDenominator" integer,
    "Report" integer,
    "DF" integer,
    nsample integer,
    t025 double precision,
    "LON" double precision,
    "LAT" double precision,
    "Shape_Length" double precision,
    "Shape_Area" double precision
);


--
-- Name: summary_sums_by_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.summary_sums_by_continent AS
 SELECT "Continent"."CONTINENT",
    "Continent"."DEFINITE",
    "Continent"."PROBABLE",
    "Continent"."POSSIBLE",
    "Continent"."SPECUL"
   FROM aed2007."Continent";


--
-- Name: summary_sums_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.summary_sums_by_country AS
 SELECT "Country"."CCODE" AS ccode,
    "Country"."DEFINITE",
    "Country"."PROBABLE",
    "Country"."POSSIBLE",
    "Country"."SPECUL"
   FROM aed2007."Country";


--
-- Name: summary_sums_by_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.summary_sums_by_region AS
 SELECT "Regions"."REGION",
    "Regions"."DEFINITE",
    "Regions"."PROBABLE",
    "Regions"."POSSIBLE",
    "Regions"."SPECUL"
   FROM aed2007."Regions";


--
-- Name: summary_totals_by_continent; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.summary_totals_by_continent AS
 SELECT 'Africa'::text AS "CONTINENT",
    "Contingrp"."CATEGORY",
    "Contingrp"."SURVEYTYPE",
    round("Contingrp"."DEFINITE") AS "DEFINITE",
    round("Contingrp"."PROBABLE") AS "PROBABLE",
    round("Contingrp"."POSSIBLE") AS "POSSIBLE",
    round("Contingrp"."SPECUL") AS "SPECUL"
   FROM aed2007."Contingrp"
  ORDER BY "Contingrp"."CATEGORY";


--
-- Name: summary_totals_by_country; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.summary_totals_by_country AS
 SELECT "Countrygrp"."CCODE" AS ccode,
    "Countrygrp"."CATEGORY",
    "Countrygrp"."SURVEYTYPE",
    "Countrygrp"."DEFINITE",
    "Countrygrp"."PROBABLE",
    "Countrygrp"."POSSIBLE",
    "Countrygrp"."SPECUL"
   FROM aed2007."Countrygrp"
  ORDER BY "Countrygrp"."CATEGORY";


--
-- Name: summary_totals_by_region; Type: VIEW; Schema: aed2007; Owner: -
--

CREATE VIEW aed2007.summary_totals_by_region AS
 SELECT "Regiongrp"."REGION",
    "Regiongrp"."CATEGORY",
    "Regiongrp"."SURVEYTYPE",
    round("Regiongrp"."DEFINITE") AS "DEFINITE",
    round("Regiongrp"."PROBABLE") AS "PROBABLE",
    round("Regiongrp"."POSSIBLE") AS "POSSIBLE",
    round("Regiongrp"."SPECUL") AS "SPECUL"
   FROM aed2007."Regiongrp"
  ORDER BY "Regiongrp"."CATEGORY";


--
-- Name: tblDataDictionary; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."tblDataDictionary" (
    "TableName" character varying(256),
    "TableDesc" character varying(510),
    "FieldName" character varying(256),
    "FieldDesc" character varying(510),
    "FieldType" character varying(64),
    "FieldLength" character varying(64)
);


--
-- Name: tblFldTypes; Type: TABLE; Schema: aed2007; Owner: -
--

CREATE TABLE aed2007."tblFldTypes" (
    "VBFldTypeNo" integer,
    "VBFldTypeName" character varying(32),
    "VBFldAttr" integer,
    "VBFldTypeUsable" integer
);


--
-- Name: 2014_range_map_edit_for_2016; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."2014_range_map_edit_for_2016" (
    gid integer NOT NULL,
    range smallint,
    rangequali character varying(10),
    ccode character varying(2),
    cntryname character varying(30),
    area_sqkm integer,
    refid integer,
    datastatus character varying(2),
    comments character varying(254),
    rangetype character varying(20),
    comments_1 character varying(254),
    adjyear_1 character varying(20),
    sourceyear smallint,
    publisyear character varying(20),
    "2016" character varying(20),
    comnts2016 character varying(254),
    ref_2016 character varying(254),
    chnges2016 character varying(254),
    geom public.geometry(MultiPolygon)
);


--
-- Name: 2014_range_map_edit_for_2016_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."2014_range_map_edit_for_2016_gid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 2014_range_map_edit_for_2016_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."2014_range_map_edit_for_2016_gid_seq" OWNED BY public."2014_range_map_edit_for_2016".gid;


--
-- Name: 2014_rangetypeupdates5_final; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."2014_rangetypeupdates5_final" (
    gid integer NOT NULL,
    range smallint,
    rangequali character varying(10),
    ccode character varying(2),
    cntryname character varying(30),
    area_sqkm integer,
    refid integer,
    call_numbe character varying(30),
    scaledenom integer,
    phenotype character varying(50),
    phtypebasi character varying(50),
    phtyperef integer,
    datastatus character varying(2),
    comments character varying(254),
    rangetype character varying(20),
    comments_1 character varying(254),
    adjyear_1 character varying(20),
    sourceyear smallint,
    publisyear character varying(20),
    geom public.geometry(MultiPolygon)
);


--
-- Name: 2014_rangetypeupdates5_final_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."2014_rangetypeupdates5_final_gid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 2014_rangetypeupdates5_final_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."2014_rangetypeupdates5_final_gid_seq" OWNED BY public."2014_rangetypeupdates5_final".gid;


--
-- Name: 2016_aed_pa_layer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."2016_aed_pa_layer" (
    gid integer NOT NULL,
    __gid numeric(10,0),
    ptacode numeric(10,0),
    ptaname character varying(254),
    ccode character varying(254),
    year_est numeric(10,0),
    iucncat character varying(254),
    iucncatara numeric(10,0),
    designate character varying(254),
    abvdesig character varying(254),
    area_sqkm numeric(10,0),
    reported numeric(10,0),
    calculated numeric(10,0),
    source character varying(254),
    refid numeric(10,0),
    inrange numeric(10,0),
    samesurvey numeric(10,0),
    shape_leng numeric,
    shape_area numeric,
    selection numeric(10,0),
    aed2016dis character varying(5),
    geom public.geometry(MultiPolygon,102022)
);


--
-- Name: 2016_aed_pa_layer_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."2016_aed_pa_layer_gid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 2016_aed_pa_layer_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."2016_aed_pa_layer_gid_seq" OWNED BY public."2016_aed_pa_layer".gid;


--
-- Name: 2016_range_only_fixed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."2016_range_only_fixed" (
    gid integer NOT NULL,
    range smallint,
    rangequali character varying(10),
    ccode character varying(2),
    cntryname character varying(30),
    area_sqkm integer,
    refid integer,
    datastatus character varying(2),
    comments character varying(254),
    rangetype character varying(20),
    comments_1 character varying(254),
    adjyear_1 character varying(20),
    sourceyear smallint,
    publisyear character varying(20),
    "2016" character varying(20),
    comnts2016 character varying(254),
    ref_2016 character varying(254),
    chnges2016 character varying(254),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: 2016_range_only_fixed_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."2016_range_only_fixed_gid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: 2016_range_only_fixed_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."2016_range_only_fixed_gid_seq" OWNED BY public."2016_range_only_fixed".gid;


--
-- Name: analyses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analyses (
    analysis_name character varying,
    comparison_year integer,
    analysis_year integer,
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    publication_year integer NOT NULL,
    is_published boolean DEFAULT false,
    title character varying NOT NULL,
    authors character varying NOT NULL,
    pdf_url character varying
);


--
-- Name: dpps_sums_continent_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dpps_sums_continent_category (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    category text,
    definite double precision,
    probable double precision,
    possible double precision,
    speculative double precision
);


--
-- Name: dpps_sums_continent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.dpps_sums_continent AS
 SELECT dpps_sums_continent_category.analysis_name,
    dpps_sums_continent_category.analysis_year,
    dpps_sums_continent_category.continent,
    sum(dpps_sums_continent_category.definite) AS definite,
    sum(dpps_sums_continent_category.probable) AS probable,
    sum(dpps_sums_continent_category.possible) AS possible,
    sum(dpps_sums_continent_category.speculative) AS speculative
   FROM public.dpps_sums_continent_category
  GROUP BY dpps_sums_continent_category.analysis_name, dpps_sums_continent_category.analysis_year, dpps_sums_continent_category.continent
  ORDER BY dpps_sums_continent_category.analysis_name, dpps_sums_continent_category.analysis_year, dpps_sums_continent_category.continent;


--
-- Name: actual_diff_continent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.actual_diff_continent AS
 SELECT y.analysis_name,
    y.analysis_year,
    a.continent,
    (a.definite - o.definite) AS actual_dif_def,
    (a.probable - o.probable) AS actual_dif_prob,
    (a.possible - o.possible) AS actual_dif_poss,
    (a.speculative - o.speculative) AS actual_dif_spec
   FROM ((public.analyses y
     JOIN public.dpps_sums_continent a ON ((((a.analysis_name)::text = (y.analysis_name)::text) AND (a.analysis_year = y.analysis_year))))
     JOIN public.dpps_sums_continent o ON ((((o.analysis_name)::text = (y.analysis_name)::text) AND (o.analysis_year = y.comparison_year) AND ((a.continent)::text = (o.continent)::text))))
  ORDER BY y.analysis_name, y.analysis_year, a.continent;


--
-- Name: dpps_sums_country_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dpps_sums_country_category (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    country character varying(255),
    category text,
    definite double precision,
    probable double precision,
    possible double precision,
    speculative double precision
);


--
-- Name: dpps_sums_country; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.dpps_sums_country AS
 SELECT dpps_sums_country_category.analysis_name,
    dpps_sums_country_category.analysis_year,
    dpps_sums_country_category.continent,
    dpps_sums_country_category.region,
    dpps_sums_country_category.country,
    sum(dpps_sums_country_category.definite) AS definite,
    sum(dpps_sums_country_category.probable) AS probable,
    sum(dpps_sums_country_category.possible) AS possible,
    sum(dpps_sums_country_category.speculative) AS speculative
   FROM public.dpps_sums_country_category
  GROUP BY dpps_sums_country_category.analysis_name, dpps_sums_country_category.analysis_year, dpps_sums_country_category.continent, dpps_sums_country_category.region, dpps_sums_country_category.country
  ORDER BY dpps_sums_country_category.analysis_name, dpps_sums_country_category.analysis_year, dpps_sums_country_category.continent, dpps_sums_country_category.region, dpps_sums_country_category.country;


--
-- Name: actual_diff_country; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.actual_diff_country AS
 SELECT y.analysis_name,
    y.analysis_year,
    a.continent,
    a.region,
    a.country,
    (a.definite - o.definite) AS actual_dif_def,
    (a.probable - o.probable) AS actual_dif_prob,
    (a.possible - o.possible) AS actual_dif_poss,
    (a.speculative - o.speculative) AS actual_dif_spec
   FROM ((public.analyses y
     JOIN public.dpps_sums_country a ON ((((a.analysis_name)::text = (y.analysis_name)::text) AND (a.analysis_year = y.analysis_year))))
     JOIN public.dpps_sums_country o ON ((((o.analysis_name)::text = (y.analysis_name)::text) AND (o.analysis_year = y.comparison_year) AND ((a.country)::text = (o.country)::text))))
  ORDER BY y.analysis_name, y.analysis_year, a.continent, a.region, a.country;


--
-- Name: dpps_sums_region_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dpps_sums_region_category (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    category text,
    definite double precision,
    probable double precision,
    possible double precision,
    speculative double precision
);


--
-- Name: dpps_sums_region; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.dpps_sums_region AS
 SELECT dpps_sums_region_category.analysis_name,
    dpps_sums_region_category.analysis_year,
    dpps_sums_region_category.continent,
    dpps_sums_region_category.region,
    sum(dpps_sums_region_category.definite) AS definite,
    sum(dpps_sums_region_category.probable) AS probable,
    sum(dpps_sums_region_category.possible) AS possible,
    sum(dpps_sums_region_category.speculative) AS speculative
   FROM public.dpps_sums_region_category
  GROUP BY dpps_sums_region_category.analysis_name, dpps_sums_region_category.analysis_year, dpps_sums_region_category.continent, dpps_sums_region_category.region
  ORDER BY dpps_sums_region_category.analysis_name, dpps_sums_region_category.analysis_year, dpps_sums_region_category.continent, dpps_sums_region_category.region;


--
-- Name: actual_diff_region; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.actual_diff_region AS
 SELECT y.analysis_name,
    y.analysis_year,
    a.continent,
    a.region,
    (a.definite - o.definite) AS actual_dif_def,
    (a.probable - o.probable) AS actual_dif_prob,
    (a.possible - o.possible) AS actual_dif_poss,
    (a.speculative - o.speculative) AS actual_dif_spec
   FROM ((public.analyses y
     JOIN public.dpps_sums_region a ON ((((a.analysis_name)::text = (y.analysis_name)::text) AND (a.analysis_year = y.analysis_year))))
     JOIN public.dpps_sums_region o ON ((((o.analysis_name)::text = (y.analysis_name)::text) AND (o.analysis_year = y.comparison_year) AND ((a.region)::text = (o.region)::text))))
  ORDER BY y.analysis_name, y.analysis_year, a.continent, a.region;


--
-- Name: add_sums_country_reason_raw; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_sums_country_reason_raw (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    country character varying(255),
    reason_change character varying(255),
    estimate numeric,
    population_variance double precision,
    guess_min numeric,
    guess_max numeric
);


--
-- Name: add_sums_country; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.add_sums_country AS
 SELECT add_sums_country_reason_raw.analysis_name,
    add_sums_country_reason_raw.analysis_year,
    add_sums_country_reason_raw.continent,
    add_sums_country_reason_raw.region,
    add_sums_country_reason_raw.country,
    sum(add_sums_country_reason_raw.estimate) AS estimate,
    ((1.96)::double precision * sqrt(sum(add_sums_country_reason_raw.population_variance))) AS confidence,
    sum(add_sums_country_reason_raw.guess_min) AS guess_min,
    sum(add_sums_country_reason_raw.guess_max) AS guess_max
   FROM public.add_sums_country_reason_raw
  GROUP BY add_sums_country_reason_raw.analysis_name, add_sums_country_reason_raw.analysis_year, add_sums_country_reason_raw.continent, add_sums_country_reason_raw.region, add_sums_country_reason_raw.country
  ORDER BY add_sums_country_reason_raw.analysis_name, add_sums_country_reason_raw.analysis_year, add_sums_country_reason_raw.continent, add_sums_country_reason_raw.region, add_sums_country_reason_raw.country;


--
-- Name: add_actual_diff_country; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.add_actual_diff_country AS
 SELECT y.analysis_name,
    y.analysis_year,
    a.continent,
    a.region,
    a.country,
    (a.estimate - o.estimate) AS actual_estimate,
    (a.confidence - o.confidence) AS actual_confidence,
    (a.guess_min - o.guess_min) AS actual_guess_min,
    (a.guess_max - o.guess_max) AS actual_guess_max
   FROM ((public.analyses y
     JOIN public.add_sums_country a ON ((((a.analysis_name)::text = (y.analysis_name)::text) AND (a.analysis_year = y.analysis_year))))
     JOIN public.add_sums_country o ON ((((o.analysis_name)::text = (y.analysis_name)::text) AND (o.analysis_year = y.comparison_year) AND ((a.country)::text = (o.country)::text))))
  ORDER BY y.analysis_name, y.analysis_year, a.continent, a.region, a.country;


--
-- Name: add_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_range (
    site_name character varying(255),
    analysis_name character varying,
    analysis_year integer,
    region character varying(255),
    category text,
    reason_change character varying(255),
    population_estimate integer,
    country character varying(255),
    input_zone_id text,
    survey_geometry public.geometry(MultiPolygonZM,4326)
);


--
-- Name: add_sums_continent_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_sums_continent_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    reason_change character varying,
    estimate numeric,
    confidence double precision,
    guess_min double precision,
    guess_max double precision,
    meta_population_variance double precision
);


--
-- Name: add_sums_country_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_sums_country_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    country character varying(255),
    reason_change character varying,
    estimate numeric,
    confidence double precision,
    guess_min double precision,
    guess_max double precision,
    meta_population_variance double precision
);


--
-- Name: add_sums_region_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_sums_region_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    reason_change character varying,
    estimate numeric,
    confidence double precision,
    guess_min double precision,
    guess_max double precision,
    meta_population_variance double precision
);


--
-- Name: add_totals_continent_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_totals_continent_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    estimate numeric,
    confidence double precision,
    guess_min double precision,
    guess_max double precision
);


--
-- Name: add_totals_country_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_totals_country_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    country character varying(255),
    estimate numeric,
    confidence double precision,
    guess_min double precision,
    guess_max double precision
);


--
-- Name: add_totals_region_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.add_totals_region_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    estimate numeric,
    confidence double precision,
    guess_min double precision,
    guess_max double precision
);


--
-- Name: aed_range_layer_2016_data_sharing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aed_range_layer_2016_data_sharing (
    gid integer NOT NULL,
    region character varying(30),
    country character varying(30),
    ccode character varying(5),
    "2016" character varying(20),
    area_sqkm double precision,
    publish_yr smallint,
    geom public.geometry(MultiPolygon,4326),
    range integer,
    rangequali character varying(20)
);


--
-- Name: aed_range_layer_2016_data_sharing_old; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aed_range_layer_2016_data_sharing_old (
    gid integer NOT NULL,
    region character varying(30),
    country character varying(30),
    ccode character varying(5),
    "2016" character varying(20),
    area_sqkm double precision,
    publish_yr smallint,
    geom public.geometry(MultiPolygon,4326),
    range integer,
    rangequali character varying(20)
);


--
-- Name: aed_range_layer_2016_data_sharing_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aed_range_layer_2016_data_sharing_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aed_range_layer_2016_data_sharing_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aed_range_layer_2016_data_sharing_gid_seq OWNED BY public.aed_range_layer_2016_data_sharing_old.gid;


--
-- Name: aed_range_layer_2016_data_sharing_gid_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aed_range_layer_2016_data_sharing_gid_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aed_range_layer_2016_data_sharing_gid_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aed_range_layer_2016_data_sharing_gid_seq1 OWNED BY public.aed_range_layer_2016_data_sharing.gid;


--
-- Name: analyses_analysis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analyses_analysis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analyses_analysis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.analyses_analysis_id_seq OWNED BY public.analyses.id;


--
-- Name: changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.changes (
    id integer NOT NULL,
    analysis_name character varying(255),
    analysis_year integer,
    replacement_name character varying(255),
    replaced_strata character varying(512),
    new_strata character varying(512),
    reason_change character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    country character varying(255),
    analysis_id integer,
    status character varying,
    comments text,
    population character varying,
    sort_key character varying
);


--
-- Name: continents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continents (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    iso_code character varying(255),
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    region_id integer,
    is_surveyed boolean
);


--
-- Name: population_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.population_submissions (
    id integer NOT NULL,
    submission_id integer,
    data_licensing character varying(255),
    embargo_date date,
    site_name character varying(255),
    designate character varying(255),
    area integer,
    completion_year integer,
    completion_month integer,
    season character varying(255),
    survey_type character varying(255),
    survey_type_other character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    abstract text,
    link text,
    citation text,
    submitted boolean,
    released boolean,
    short_citation character varying(255),
    latitude double precision,
    longitude double precision,
    comments text,
    internal_name character varying
);


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id integer NOT NULL,
    user_id integer,
    phenotype character varying(255),
    phenotype_basis character varying(255),
    data_type character varying(255),
    right_to_grant_permission boolean,
    permission_email character varying(255),
    is_mike_site boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    species_id integer,
    country_id integer,
    mike_site_id integer
);


--
-- Name: survey_aerial_sample_count_strata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_aerial_sample_count_strata (
    id integer NOT NULL,
    survey_aerial_sample_count_id integer,
    stratum_name character varying(255),
    stratum_area integer,
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_t double precision,
    population_degrees_of_freedom integer,
    population_confidence_interval double precision,
    population_no_precision_estimate_available boolean,
    sampling_intensity double precision,
    transects_covered integer,
    transects_covered_total_length integer,
    seen_in_transects integer,
    seen_outside_transects integer,
    carcasses_fresh integer,
    carcasses_old integer,
    carcasses_very_old integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    carcasses_age_unknown integer,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    mike_site_id integer,
    is_mike_site boolean,
    survey_geometry_id integer,
    web_id character varying,
    comments text,
    internal_name character varying
);


--
-- Name: survey_aerial_sample_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_aerial_sample_counts (
    id integer NOT NULL,
    population_submission_id integer,
    total_possible_transects integer,
    surveyed_at_stratum_level boolean,
    stratum_level_data_submitted boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_aerial_total_count_strata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_aerial_total_count_strata (
    id integer NOT NULL,
    survey_aerial_total_count_id integer,
    stratum_name character varying(255),
    stratum_area integer,
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_t double precision,
    population_degrees_of_freedom integer,
    population_confidence_interval double precision,
    population_no_precision_estimate_available boolean,
    average_speed integer,
    average_transect_spacing real,
    average_searching_rate integer,
    transects_covered integer,
    transects_covered_total_length integer,
    observations integer,
    carcasses_fresh integer,
    carcasses_old integer,
    carcasses_very_old integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    carcasses_age_unknown integer,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    mike_site_id integer,
    is_mike_site boolean,
    survey_geometry_id integer,
    web_id character varying,
    comments text,
    internal_name character varying
);


--
-- Name: survey_aerial_total_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_aerial_total_counts (
    id integer NOT NULL,
    population_submission_id integer,
    surveyed_at_stratum_level boolean,
    stratum_level_data_submitted boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_dung_count_line_transect_strata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_dung_count_line_transect_strata (
    id integer NOT NULL,
    survey_dung_count_line_transect_id integer,
    stratum_name character varying(255),
    stratum_area integer,
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_t double precision,
    population_degrees_of_freedom integer,
    population_confidence_interval double precision,
    population_no_precision_estimate_available boolean,
    population_asymmetric_upper_confidence_interval integer,
    population_asymmetric_lower_confidence_interval integer,
    transects_covered integer,
    transects_covered_total_length double precision,
    strip_width double precision,
    observations integer,
    observations_distance_method character varying(255),
    actually_seen integer,
    dung_piles integer,
    dung_decay_rate_measurement_method character varying(255),
    dung_decay_rate_estimate_used double precision,
    dung_decay_rate_measurement_site character varying(255),
    dung_decay_rate_measurement_year integer,
    dung_decay_rate_reference character varying(255),
    dung_decay_rate_variance double precision,
    dung_decay_rate_standard_error double precision,
    dung_decay_rate_t double precision,
    dung_decay_rate_degrees_of_freedom integer,
    dung_decay_rate_confidence_interval double precision,
    dung_decay_rate_no_precision_estimate_available boolean,
    defecation_rate_measured_on_site boolean,
    defecation_rate_estimate_used double precision,
    defecation_rate_measurement_site character varying(255),
    defecation_rate_reference character varying(255),
    defecation_rate_variance double precision,
    defecation_rate_standard_error double precision,
    defecation_rate_t double precision,
    defecation_rate_degrees_of_freedom integer,
    defecation_rate_confidence_interval double precision,
    defecation_rate_no_precision_estimate_available boolean,
    dung_density_estimate integer,
    dung_density_variance double precision,
    dung_density_standard_error double precision,
    dung_density_t double precision,
    dung_density_degrees_of_freedom integer,
    dung_density_confidence_interval double precision,
    dung_density_no_precision_estimate_available boolean,
    dung_encounter_rate double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    individual_transect_length double precision,
    dung_density_asymmetric_upper_confidence_interval integer,
    dung_density_asymmetric_lower_confidence_interval integer,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    dung_decay_rate_lower_confidence_limit double precision,
    dung_decay_rate_upper_confidence_limit double precision,
    defecation_rate_lower_confidence_limit double precision,
    defecation_rate_upper_confidence_limit double precision,
    dung_density_lower_confidence_limit double precision,
    dung_density_upper_confidence_limit double precision,
    mike_site_id integer,
    is_mike_site boolean,
    survey_geometry_id integer,
    web_id character varying,
    comments text,
    internal_name character varying
);


--
-- Name: survey_dung_count_line_transects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_dung_count_line_transects (
    id integer NOT NULL,
    population_submission_id integer,
    surveyed_at_stratum_level boolean,
    stratum_level_data_submitted boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_faecal_dna_strata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_faecal_dna_strata (
    id integer NOT NULL,
    survey_faecal_dna_id integer,
    stratum_name character varying(255),
    stratum_area integer,
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_t double precision,
    population_degrees_of_freedom integer,
    population_confidence_interval double precision,
    population_no_precision_estimate_available boolean,
    method_of_analysis character varying(255),
    area_calculation_method character varying(255),
    genotypes_identified integer,
    samples_analyzed integer,
    sampling_locations integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    mike_site_id integer,
    is_mike_site boolean,
    survey_geometry_id integer,
    web_id character varying,
    comments text,
    internal_name character varying
);


--
-- Name: survey_faecal_dnas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_faecal_dnas (
    id integer NOT NULL,
    population_submission_id integer,
    surveyed_at_stratum_level boolean,
    stratum_level_data_submitted boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_ground_sample_count_strata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_ground_sample_count_strata (
    id integer NOT NULL,
    survey_ground_sample_count_id integer,
    stratum_name character varying(255),
    stratum_area integer,
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_t double precision,
    population_degrees_of_freedom integer,
    population_confidence_interval double precision,
    population_no_precision_estimate_available boolean,
    transects_covered integer,
    transects_covered_total_length integer,
    person_hours integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    individual_transect_length double precision,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    mike_site_id integer,
    is_mike_site boolean,
    survey_geometry_id integer,
    web_id character varying,
    comments text,
    internal_name character varying
);


--
-- Name: survey_ground_sample_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_ground_sample_counts (
    id integer NOT NULL,
    population_submission_id integer,
    surveyed_at_stratum_level boolean,
    stratum_level_data_submitted boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_ground_total_count_strata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_ground_total_count_strata (
    id integer NOT NULL,
    survey_ground_total_count_id integer,
    stratum_name character varying(255),
    stratum_area integer,
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_t double precision,
    population_degrees_of_freedom integer,
    population_confidence_interval double precision,
    population_no_precision_estimate_available boolean,
    transects_covered integer,
    transects_covered_total_length integer,
    person_hours integer,
    strip_width double precision,
    observations integer,
    actually_seen integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    mike_site_id integer,
    is_mike_site boolean,
    survey_geometry_id integer,
    web_id character varying,
    comments text,
    internal_name character varying
);


--
-- Name: survey_ground_total_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_ground_total_counts (
    id integer NOT NULL,
    population_submission_id integer,
    surveyed_at_stratum_level boolean,
    stratum_level_data_submitted boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_individual_registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_individual_registrations (
    id integer NOT NULL,
    population_submission_id integer,
    population_estimate integer,
    population_upper_range integer,
    monitoring_years integer,
    monitoring_frequency character varying(255),
    fenced_site character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    porous_fenced_site character varying(255),
    mike_site_id integer,
    is_mike_site boolean,
    survey_geometry_id integer,
    web_id character varying,
    stratum_area integer
);


--
-- Name: survey_others; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_others (
    id integer NOT NULL,
    population_submission_id integer,
    other_method_description character varying(255),
    population_estimate_min integer,
    population_estimate_max integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    mike_site_id integer,
    is_mike_site boolean,
    actually_seen integer,
    informed boolean,
    survey_geometry_id integer,
    web_id character varying,
    stratum_area integer
);


--
-- Name: estimate_factors; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors AS
 WITH ddr_median AS (
         SELECT percentile_disc((0.5)::double precision) WITHIN GROUP (ORDER BY sdclts.dung_decay_rate_estimate_used) AS val
           FROM ((public.survey_dung_count_line_transect_strata sdclts
             JOIN public.survey_dung_count_line_transects sdclt ON ((sdclts.survey_dung_count_line_transect_id = sdclt.id)))
             JOIN public.population_submissions ps ON ((sdclt.population_submission_id = ps.id)))
          WHERE ((sdclts.dung_decay_rate_measurement_method)::text = 'Retrospectively'::text)
        )
 SELECT 'GT'::text AS estimate_type,
    ('GT'::text || survey_ground_total_count_strata.id) AS input_zone_id,
    survey_ground_total_counts.population_submission_id,
    population_submissions.site_name,
    survey_ground_total_count_strata.stratum_name,
    survey_ground_total_count_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_ground_total_count_strata.population_estimate,
    survey_ground_total_count_strata.population_variance,
    survey_ground_total_count_strata.population_standard_error,
    survey_ground_total_count_strata.population_confidence_interval,
    survey_ground_total_count_strata.population_t,
    survey_ground_total_count_strata.population_lower_confidence_limit,
    survey_ground_total_count_strata.population_upper_confidence_limit,
    1 AS quality_level,
    survey_ground_total_count_strata.actually_seen,
    survey_ground_total_count_strata.survey_geometry_id
   FROM (((public.survey_ground_total_count_strata
     JOIN public.survey_ground_total_counts ON ((survey_ground_total_counts.id = survey_ground_total_count_strata.survey_ground_total_count_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_ground_total_counts.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
UNION
 SELECT 'DC'::text AS estimate_type,
    ('DC'::text || survey_dung_count_line_transect_strata.id) AS input_zone_id,
    survey_dung_count_line_transects.population_submission_id,
    population_submissions.site_name,
    survey_dung_count_line_transect_strata.stratum_name,
    survey_dung_count_line_transect_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_dung_count_line_transect_strata.population_estimate,
    survey_dung_count_line_transect_strata.population_variance,
    survey_dung_count_line_transect_strata.population_standard_error,
    survey_dung_count_line_transect_strata.population_confidence_interval,
    survey_dung_count_line_transect_strata.population_t,
    survey_dung_count_line_transect_strata.population_lower_confidence_limit,
    survey_dung_count_line_transect_strata.population_upper_confidence_limit,
    1 AS quality_level,
    survey_dung_count_line_transect_strata.actually_seen,
    survey_dung_count_line_transect_strata.survey_geometry_id
   FROM (((public.survey_dung_count_line_transect_strata
     JOIN public.survey_dung_count_line_transects ON ((survey_dung_count_line_transects.id = survey_dung_count_line_transect_strata.survey_dung_count_line_transect_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_dung_count_line_transects.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
  WHERE (((survey_dung_count_line_transect_strata.dung_decay_rate_measurement_method)::text = 'Retrospectively'::text) AND (survey_dung_count_line_transect_strata.dung_decay_rate_measurement_year = population_submissions.completion_year))
UNION
 SELECT 'DC'::text AS estimate_type,
    ('DC'::text || survey_dung_count_line_transect_strata.id) AS input_zone_id,
    survey_dung_count_line_transects.population_submission_id,
    population_submissions.site_name,
    survey_dung_count_line_transect_strata.stratum_name,
    survey_dung_count_line_transect_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_dung_count_line_transect_strata.population_estimate,
    survey_dung_count_line_transect_strata.population_variance,
    survey_dung_count_line_transect_strata.population_standard_error,
    survey_dung_count_line_transect_strata.population_confidence_interval,
    survey_dung_count_line_transect_strata.population_t,
    survey_dung_count_line_transect_strata.population_lower_confidence_limit,
    survey_dung_count_line_transect_strata.population_upper_confidence_limit,
    1 AS quality_level,
    survey_dung_count_line_transect_strata.actually_seen,
    survey_dung_count_line_transect_strata.survey_geometry_id
   FROM (((public.survey_dung_count_line_transect_strata
     JOIN public.survey_dung_count_line_transects ON ((survey_dung_count_line_transects.id = survey_dung_count_line_transect_strata.survey_dung_count_line_transect_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_dung_count_line_transects.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
  WHERE ((((survey_dung_count_line_transect_strata.dung_decay_rate_measurement_method)::text <> 'Retrospectively'::text) OR (survey_dung_count_line_transect_strata.dung_decay_rate_measurement_year <> population_submissions.completion_year)) AND (survey_dung_count_line_transect_strata.dung_decay_rate_estimate_used >= ( SELECT ddr_median.val
           FROM ddr_median)))
UNION
 SELECT 'DC'::text AS estimate_type,
    ('DC'::text || survey_dung_count_line_transect_strata.id) AS input_zone_id,
    survey_dung_count_line_transects.population_submission_id,
    population_submissions.site_name,
    survey_dung_count_line_transect_strata.stratum_name,
    survey_dung_count_line_transect_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    (round(((survey_dung_count_line_transect_strata.stratum_area)::double precision * ((survey_dung_count_line_transect_strata.dung_density_estimate)::double precision / (survey_dung_count_line_transect_strata.defecation_rate_estimate_used * ( SELECT ddr_median.val
           FROM ddr_median))))))::integer AS population_estimate,
    survey_dung_count_line_transect_strata.population_variance,
    survey_dung_count_line_transect_strata.population_standard_error,
    survey_dung_count_line_transect_strata.population_confidence_interval,
    survey_dung_count_line_transect_strata.population_t,
    survey_dung_count_line_transect_strata.population_lower_confidence_limit,
    survey_dung_count_line_transect_strata.population_upper_confidence_limit,
    1 AS quality_level,
    survey_dung_count_line_transect_strata.actually_seen,
    survey_dung_count_line_transect_strata.survey_geometry_id
   FROM (((public.survey_dung_count_line_transect_strata
     JOIN public.survey_dung_count_line_transects ON ((survey_dung_count_line_transects.id = survey_dung_count_line_transect_strata.survey_dung_count_line_transect_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_dung_count_line_transects.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
  WHERE ((((survey_dung_count_line_transect_strata.dung_decay_rate_measurement_method)::text <> 'Retrospectively'::text) OR (survey_dung_count_line_transect_strata.dung_decay_rate_measurement_year <> population_submissions.completion_year)) AND (survey_dung_count_line_transect_strata.dung_decay_rate_estimate_used < ( SELECT ddr_median.val
           FROM ddr_median)) AND (survey_dung_count_line_transect_strata.defecation_rate_estimate_used > (0)::double precision))
UNION
 SELECT 'DC'::text AS estimate_type,
    ('DC'::text || survey_dung_count_line_transect_strata.id) AS input_zone_id,
    survey_dung_count_line_transects.population_submission_id,
    population_submissions.site_name,
    survey_dung_count_line_transect_strata.stratum_name,
    survey_dung_count_line_transect_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    (survey_dung_count_line_transect_strata.population_estimate - (round(((survey_dung_count_line_transect_strata.stratum_area)::double precision * ((survey_dung_count_line_transect_strata.dung_density_estimate)::double precision / (survey_dung_count_line_transect_strata.defecation_rate_estimate_used * ( SELECT ddr_median.val
           FROM ddr_median))))))::integer) AS population_estimate,
    survey_dung_count_line_transect_strata.population_variance,
    survey_dung_count_line_transect_strata.population_standard_error,
    survey_dung_count_line_transect_strata.population_confidence_interval,
    survey_dung_count_line_transect_strata.population_t,
    survey_dung_count_line_transect_strata.population_lower_confidence_limit,
    survey_dung_count_line_transect_strata.population_upper_confidence_limit,
    0 AS quality_level,
    survey_dung_count_line_transect_strata.actually_seen,
    survey_dung_count_line_transect_strata.survey_geometry_id
   FROM (((public.survey_dung_count_line_transect_strata
     JOIN public.survey_dung_count_line_transects ON ((survey_dung_count_line_transects.id = survey_dung_count_line_transect_strata.survey_dung_count_line_transect_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_dung_count_line_transects.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
  WHERE ((((survey_dung_count_line_transect_strata.dung_decay_rate_measurement_method)::text <> 'Retrospectively'::text) OR (survey_dung_count_line_transect_strata.dung_decay_rate_measurement_year <> population_submissions.completion_year)) AND (survey_dung_count_line_transect_strata.dung_decay_rate_estimate_used < ( SELECT ddr_median.val
           FROM ddr_median)) AND (survey_dung_count_line_transect_strata.defecation_rate_estimate_used > (0)::double precision))
UNION
 SELECT 'AT'::text AS estimate_type,
    ('AT'::text || survey_aerial_total_count_strata.id) AS input_zone_id,
    survey_aerial_total_counts.population_submission_id,
    population_submissions.site_name,
    survey_aerial_total_count_strata.stratum_name,
    survey_aerial_total_count_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_aerial_total_count_strata.population_estimate,
    survey_aerial_total_count_strata.population_variance,
    survey_aerial_total_count_strata.population_standard_error,
    survey_aerial_total_count_strata.population_confidence_interval,
    survey_aerial_total_count_strata.population_t,
    survey_aerial_total_count_strata.population_lower_confidence_limit,
    survey_aerial_total_count_strata.population_upper_confidence_limit,
    1 AS quality_level,
    survey_aerial_total_count_strata.observations AS actually_seen,
    survey_aerial_total_count_strata.survey_geometry_id
   FROM (((public.survey_aerial_total_count_strata
     JOIN public.survey_aerial_total_counts ON ((survey_aerial_total_counts.id = survey_aerial_total_count_strata.survey_aerial_total_count_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_aerial_total_counts.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
UNION
 SELECT 'GS'::text AS estimate_type,
    ('GS'::text || survey_ground_sample_count_strata.id) AS input_zone_id,
    survey_ground_sample_counts.population_submission_id,
    population_submissions.site_name,
    survey_ground_sample_count_strata.stratum_name,
    survey_ground_sample_count_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_ground_sample_count_strata.population_estimate,
    survey_ground_sample_count_strata.population_variance,
    survey_ground_sample_count_strata.population_standard_error,
    survey_ground_sample_count_strata.population_confidence_interval,
    survey_ground_sample_count_strata.population_t,
    survey_ground_sample_count_strata.population_lower_confidence_limit,
    survey_ground_sample_count_strata.population_upper_confidence_limit,
    1 AS quality_level,
    NULL::integer AS actually_seen,
    survey_ground_sample_count_strata.survey_geometry_id
   FROM (((public.survey_ground_sample_count_strata
     JOIN public.survey_ground_sample_counts ON ((survey_ground_sample_counts.id = survey_ground_sample_count_strata.survey_ground_sample_count_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_ground_sample_counts.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
UNION
 SELECT 'AS'::text AS estimate_type,
    ('AS'::text || survey_aerial_sample_count_strata.id) AS input_zone_id,
    survey_aerial_sample_counts.population_submission_id,
    population_submissions.site_name,
    survey_aerial_sample_count_strata.stratum_name,
    survey_aerial_sample_count_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_aerial_sample_count_strata.population_estimate,
    survey_aerial_sample_count_strata.population_variance,
    survey_aerial_sample_count_strata.population_standard_error,
    survey_aerial_sample_count_strata.population_confidence_interval,
    survey_aerial_sample_count_strata.population_t,
    survey_aerial_sample_count_strata.population_lower_confidence_limit,
    survey_aerial_sample_count_strata.population_upper_confidence_limit,
    1 AS quality_level,
    survey_aerial_sample_count_strata.seen_in_transects AS actually_seen,
    survey_aerial_sample_count_strata.survey_geometry_id
   FROM (((public.survey_aerial_sample_count_strata
     JOIN public.survey_aerial_sample_counts ON ((survey_aerial_sample_counts.id = survey_aerial_sample_count_strata.survey_aerial_sample_count_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_aerial_sample_counts.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
UNION
 SELECT 'GD'::text AS estimate_type,
    ('GD'::text || survey_faecal_dna_strata.id) AS input_zone_id,
    survey_faecal_dnas.population_submission_id,
    population_submissions.site_name,
    survey_faecal_dna_strata.stratum_name,
    survey_faecal_dna_strata.stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_faecal_dna_strata.population_estimate,
    survey_faecal_dna_strata.population_variance,
    survey_faecal_dna_strata.population_standard_error,
    survey_faecal_dna_strata.population_confidence_interval,
    survey_faecal_dna_strata.population_t,
    survey_faecal_dna_strata.population_lower_confidence_limit,
    survey_faecal_dna_strata.population_upper_confidence_limit,
    1 AS quality_level,
    survey_faecal_dna_strata.genotypes_identified AS actually_seen,
    survey_faecal_dna_strata.survey_geometry_id
   FROM (((public.survey_faecal_dna_strata
     JOIN public.survey_faecal_dnas ON ((survey_faecal_dnas.id = survey_faecal_dna_strata.survey_faecal_dna_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_faecal_dnas.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
UNION
 SELECT 'IR'::text AS estimate_type,
    ('IR'::text || survey_individual_registrations.id) AS input_zone_id,
    survey_individual_registrations.population_submission_id,
    population_submissions.site_name,
    population_submissions.site_name AS stratum_name,
    population_submissions.area AS stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_individual_registrations.population_estimate,
    NULL::double precision AS population_variance,
    NULL::double precision AS population_standard_error,
    NULL::double precision AS population_confidence_interval,
    NULL::double precision AS population_t,
    NULL::integer AS population_lower_confidence_limit,
    survey_individual_registrations.population_upper_range AS population_upper_confidence_limit,
        CASE
            WHEN (survey_individual_registrations.population_upper_range IS NULL) THEN 1
            ELSE 0
        END AS quality_level,
    survey_individual_registrations.population_estimate AS actually_seen,
    survey_individual_registrations.survey_geometry_id
   FROM ((public.survey_individual_registrations
     JOIN public.population_submissions ON ((population_submissions.id = survey_individual_registrations.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)))
UNION
 SELECT 'O'::text AS estimate_type,
    ('O'::text || survey_others.id) AS input_zone_id,
    survey_others.population_submission_id,
    population_submissions.site_name,
    population_submissions.site_name AS stratum_name,
    population_submissions.area AS stratum_area,
    population_submissions.completion_year,
    submissions.phenotype,
    submissions.phenotype_basis,
    population_submissions.citation,
    population_submissions.short_citation,
    survey_others.population_estimate_min AS population_estimate,
    NULL::double precision AS population_variance,
    NULL::double precision AS population_standard_error,
    NULL::double precision AS population_confidence_interval,
    NULL::double precision AS population_t,
    survey_others.population_estimate_min AS population_lower_confidence_limit,
    survey_others.population_estimate_max AS population_upper_confidence_limit,
        CASE
            WHEN (survey_others.informed = true) THEN 1
            ELSE 0
        END AS quality_level,
    survey_others.actually_seen,
    survey_others.survey_geometry_id
   FROM ((public.survey_others
     JOIN public.population_submissions ON ((population_submissions.id = survey_others.population_submission_id)))
     JOIN public.submissions ON ((submissions.id = population_submissions.submission_id)));


--
-- Name: estimate_factors_confidence; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_confidence AS
 SELECT estimate_factors.estimate_type,
    estimate_factors.input_zone_id,
    estimate_factors.population_submission_id,
    estimate_factors.site_name,
    estimate_factors.stratum_name,
    estimate_factors.stratum_area,
    estimate_factors.completion_year,
    estimate_factors.phenotype,
    estimate_factors.phenotype_basis,
    estimate_factors.citation,
    estimate_factors.short_citation,
    estimate_factors.quality_level,
    estimate_factors.population_estimate,
        CASE
            WHEN (estimate_factors.population_variance IS NOT NULL) THEN estimate_factors.population_variance
            WHEN (estimate_factors.population_standard_error IS NOT NULL) THEN (estimate_factors.population_standard_error ^ (2)::double precision)
            WHEN ((estimate_factors.population_confidence_interval IS NOT NULL) AND (estimate_factors.population_t IS NOT NULL)) THEN ((estimate_factors.population_confidence_interval / estimate_factors.population_t) ^ (2)::double precision)
            WHEN (estimate_factors.population_confidence_interval IS NOT NULL) THEN ((estimate_factors.population_confidence_interval / (1.96)::double precision) ^ (2)::double precision)
            ELSE NULL::double precision
        END AS population_variance,
    estimate_factors.population_standard_error,
        CASE
            WHEN (estimate_factors.population_confidence_interval IS NOT NULL) THEN estimate_factors.population_confidence_interval
            WHEN (estimate_factors.population_standard_error IS NOT NULL) THEN (estimate_factors.population_standard_error * (1.96)::double precision)
            WHEN ((estimate_factors.population_standard_error IS NOT NULL) AND (estimate_factors.population_t IS NOT NULL)) THEN (estimate_factors.population_standard_error * estimate_factors.population_t)
            WHEN (estimate_factors.population_variance IS NOT NULL) THEN (sqrt(estimate_factors.population_variance) * (1.96)::double precision)
            ELSE NULL::double precision
        END AS population_confidence_interval,
    estimate_factors.population_lower_confidence_limit,
    estimate_factors.population_upper_confidence_limit,
        CASE
            WHEN (estimate_factors.actually_seen IS NULL) THEN 0
            ELSE estimate_factors.actually_seen
        END AS actually_seen
   FROM public.estimate_factors;


--
-- Name: new_strata; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.new_strata AS
 SELECT q.analysis_name,
    q.sort_key,
    q.population,
    q.replacement_name,
    q.reason_change,
    q.new_stratum
   FROM ( SELECT DISTINCT changes.analysis_name,
            changes.sort_key,
            changes.population,
            changes.replacement_name,
            changes.reason_change,
            unnest(regexp_split_to_array((changes.new_strata)::text, ','::text)) AS new_stratum
           FROM public.changes) q
  WHERE ((q.new_stratum IS NOT NULL) AND (q.new_stratum <> ''::text))
  ORDER BY q.analysis_name, q.sort_key, q.reason_change, q.new_stratum;


--
-- Name: replaced_strata; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.replaced_strata AS
 SELECT q.analysis_name,
    q.sort_key,
    q.population,
    q.replacement_name,
    '-'::text AS reason_change,
    q.replaced_stratum
   FROM ( SELECT DISTINCT changes.analysis_name,
            changes.sort_key,
            changes.population,
            changes.replacement_name,
            unnest(regexp_split_to_array((changes.replaced_strata)::text, ','::text)) AS replaced_stratum
           FROM public.changes) q
  WHERE ((q.replaced_stratum IS NOT NULL) AND (q.replaced_stratum <> ''::text))
  ORDER BY q.analysis_name, q.sort_key, q.replaced_stratum;


--
-- Name: estimate_factors_analyses; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses AS
 SELECT estimate_factors_confidence.estimate_type,
    estimate_factors_confidence.input_zone_id,
    estimate_factors_confidence.population_submission_id,
    estimate_factors_confidence.site_name,
    estimate_factors_confidence.stratum_name,
    estimate_factors_confidence.stratum_area,
    estimate_factors_confidence.completion_year,
    estimate_factors_confidence.phenotype,
    estimate_factors_confidence.phenotype_basis,
    a.analysis_name,
    a.analysis_year,
    a.comparison_year,
    (a.analysis_year - estimate_factors_confidence.completion_year) AS age,
    n.sort_key,
    n.population,
    n.replacement_name,
    n.reason_change,
    estimate_factors_confidence.citation,
    estimate_factors_confidence.short_citation,
    estimate_factors_confidence.population_estimate,
    estimate_factors_confidence.population_variance,
    estimate_factors_confidence.population_standard_error,
    estimate_factors_confidence.population_confidence_interval,
    estimate_factors_confidence.population_lower_confidence_limit,
    estimate_factors_confidence.population_upper_confidence_limit,
    estimate_factors_confidence.quality_level,
    estimate_factors_confidence.actually_seen
   FROM ((public.estimate_factors_confidence
     JOIN public.new_strata n ON ((n.new_stratum = estimate_factors_confidence.input_zone_id)))
     JOIN public.analyses a ON (((a.analysis_name)::text = (n.analysis_name)::text)))
UNION
 SELECT estimate_factors_confidence.estimate_type,
    estimate_factors_confidence.input_zone_id,
    estimate_factors_confidence.population_submission_id,
    estimate_factors_confidence.site_name,
    estimate_factors_confidence.stratum_name,
    estimate_factors_confidence.stratum_area,
    estimate_factors_confidence.completion_year,
    estimate_factors_confidence.phenotype,
    estimate_factors_confidence.phenotype_basis,
    a.analysis_name,
    a.comparison_year AS analysis_year,
    a.comparison_year,
    (a.comparison_year - estimate_factors_confidence.completion_year) AS age,
    r.sort_key,
    r.population,
    r.replacement_name,
    r.reason_change,
    estimate_factors_confidence.citation,
    estimate_factors_confidence.short_citation,
    estimate_factors_confidence.population_estimate,
    estimate_factors_confidence.population_variance,
    estimate_factors_confidence.population_standard_error,
    estimate_factors_confidence.population_confidence_interval,
    estimate_factors_confidence.population_lower_confidence_limit,
    estimate_factors_confidence.population_upper_confidence_limit,
    estimate_factors_confidence.quality_level,
    estimate_factors_confidence.actually_seen
   FROM ((public.estimate_factors_confidence
     JOIN public.replaced_strata r ON ((r.replaced_stratum = estimate_factors_confidence.input_zone_id)))
     JOIN public.analyses a ON (((a.analysis_name)::text = (r.analysis_name)::text)));


--
-- Name: estimate_factors_analyses_categorized; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized AS
 SELECT estimate_factors_analyses.estimate_type,
    estimate_factors_analyses.input_zone_id,
    estimate_factors_analyses.population_submission_id,
    estimate_factors_analyses.site_name,
    estimate_factors_analyses.stratum_name,
    estimate_factors_analyses.stratum_area,
    estimate_factors_analyses.completion_year,
    estimate_factors_analyses.analysis_name,
    estimate_factors_analyses.analysis_year,
    estimate_factors_analyses.phenotype,
    estimate_factors_analyses.phenotype_basis,
    estimate_factors_analyses.age,
    estimate_factors_analyses.sort_key,
    estimate_factors_analyses.population,
    estimate_factors_analyses.replacement_name,
    (
        CASE
            WHEN (((estimate_factors_analyses.reason_change)::text = '-'::text) AND (estimate_factors_analyses.age >= 10) AND ((estimate_factors_analyses.comparison_year - estimate_factors_analyses.completion_year) <= 10) AND (NOT ((estimate_factors_analyses.estimate_type = 'O'::text) AND ((estimate_factors_analyses.quality_level IS NULL) OR (estimate_factors_analyses.quality_level <> 1))))) THEN 'DD'::character varying
            ELSE estimate_factors_analyses.reason_change
        END)::character varying(255) AS reason_change,
    estimate_factors_analyses.citation,
    estimate_factors_analyses.short_citation,
    estimate_factors_analyses.population_estimate,
    estimate_factors_analyses.population_variance,
    estimate_factors_analyses.population_standard_error,
    estimate_factors_analyses.population_confidence_interval,
    estimate_factors_analyses.population_lower_confidence_limit,
    estimate_factors_analyses.population_upper_confidence_limit,
    estimate_factors_analyses.quality_level,
    estimate_factors_analyses.actually_seen,
        CASE
            WHEN (estimate_factors_analyses.population_lower_confidence_limit IS NOT NULL) THEN (estimate_factors_analyses.population_lower_confidence_limit)::double precision
            WHEN (estimate_factors_analyses.population_confidence_interval < (estimate_factors_analyses.population_estimate)::double precision) THEN ((estimate_factors_analyses.population_estimate)::double precision - estimate_factors_analyses.population_confidence_interval)
            ELSE (0)::double precision
        END AS lcl95,
        CASE
            WHEN (estimate_factors_analyses.age >= 10) THEN 'E'::text
            WHEN (estimate_factors_analyses.estimate_type = 'DC'::text) THEN
            CASE
                WHEN (estimate_factors_analyses.quality_level = 1) THEN 'B'::text
                WHEN ((estimate_factors_analyses.population_variance IS NULL) AND (estimate_factors_analyses.population_standard_error IS NULL)) THEN 'D'::text
                ELSE 'C'::text
            END
            WHEN ((estimate_factors_analyses.estimate_type = 'GD'::text) AND (estimate_factors_analyses.analysis_year > 2007)) THEN 'A'::text
            WHEN ((estimate_factors_analyses.estimate_type = 'GD'::text) AND (estimate_factors_analyses.analysis_year <= 2007)) THEN 'C'::text
            WHEN ((estimate_factors_analyses.estimate_type = 'AT'::text) OR (estimate_factors_analyses.estimate_type = 'GT'::text)) THEN 'A'::text
            WHEN ((estimate_factors_analyses.estimate_type = 'AS'::text) OR (estimate_factors_analyses.estimate_type = 'GS'::text)) THEN
            CASE
                WHEN (estimate_factors_analyses.population_variance IS NOT NULL) THEN 'B'::text
                ELSE 'D'::text
            END
            WHEN (estimate_factors_analyses.estimate_type = 'IR'::text) THEN
            CASE
                WHEN (estimate_factors_analyses.quality_level = 1) THEN 'A'::text
                ELSE 'D'::text
            END
            WHEN (estimate_factors_analyses.estimate_type = 'O'::text) THEN
            CASE
                WHEN (estimate_factors_analyses.quality_level = 1) THEN 'D'::text
                ELSE 'E'::text
            END
            ELSE 'F'::text
        END AS category
   FROM public.estimate_factors_analyses;


--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regions (
    id integer NOT NULL,
    continent_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: surveytypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.surveytypes (
    category character varying(8),
    surveytype character varying(255),
    display_order integer
);


--
-- Name: estimate_factors_analyses_categorized_for_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized_for_add AS
 SELECT m.estimate_type,
    m.category,
    (((st.surveytype)::text || ''::text))::character varying AS surveytype,
    m.analysis_name,
    m.analysis_year,
    m.completion_year,
    ct.name AS continent,
    r.name AS region,
    c.name AS country,
    m.phenotype,
    m.phenotype_basis,
    m.site_name,
    m.best_estimate,
    m.best_population_variance,
    m.population_estimate,
    m.population_variance,
    m.population_lower_confidence_limit,
    m.population_upper_confidence_limit,
    m.actually_seen,
    m.input_zone_id,
    m.population_submission_id,
    m.stratum_name,
    m.stratum_area,
    m.age,
    m.replacement_name,
    m.reason_change,
    m.citation,
    m.short_citation,
    m.population_standard_error,
    m.population_confidence_interval,
    m.lcl95,
    m.quality_level
   FROM ((((((( SELECT e.estimate_type,
                CASE
                    WHEN (e.estimate_type = 'GD'::text) THEN 'N'::text
                    WHEN (e.estimate_type = 'AT'::text) THEN 'H'::text
                    WHEN (e.estimate_type = 'GT'::text) THEN 'I'::text
                    WHEN (e.estimate_type = 'IR'::text) THEN 'M'::text
                    ELSE 'U'::text
                END AS category,
            e.analysis_name,
            e.analysis_year,
            e.completion_year,
            e.phenotype,
            e.phenotype_basis,
            e.site_name,
            e.population_estimate AS best_estimate,
            0 AS best_population_variance,
            e.population_estimate,
            e.population_variance,
            0 AS population_lower_confidence_limit,
            0 AS population_upper_confidence_limit,
            e.actually_seen,
            e.input_zone_id,
            e.population_submission_id,
            e.stratum_name,
            e.stratum_area,
            e.age,
            e.replacement_name,
            e.reason_change,
            e.citation,
            e.short_citation,
            e.population_confidence_interval,
            e.population_standard_error,
            e.lcl95,
            e.quality_level
           FROM public.estimate_factors_analyses_categorized e
          WHERE (e.category = 'A'::text)
        UNION
         SELECT e.estimate_type,
                CASE
                    WHEN (e.estimate_type = 'DC'::text) THEN 'L'::text
                    WHEN (e.estimate_type = 'AS'::text) THEN 'J'::text
                    WHEN (e.estimate_type = 'GS'::text) THEN 'K'::text
                    ELSE 'U'::text
                END AS category,
            e.analysis_name,
            e.analysis_year,
            e.completion_year,
            e.phenotype,
            e.phenotype_basis,
            e.site_name,
                CASE
                    WHEN ((e.population_estimate IS NULL) OR (e.population_estimate = 0)) THEN e.actually_seen
                    ELSE e.population_estimate
                END AS best_estimate,
            e.population_variance AS best_population_variance,
            e.population_estimate,
            e.population_variance,
            0 AS population_lower_confidence_limit,
            0 AS population_upper_confidence_limit,
            e.actually_seen,
            e.input_zone_id,
            e.population_submission_id,
            e.stratum_name,
            e.stratum_area,
            e.age,
            e.replacement_name,
            e.reason_change,
            e.citation,
            e.short_citation,
            e.population_confidence_interval,
            e.population_standard_error,
            e.lcl95,
            e.quality_level
           FROM (public.estimate_factors_analyses_categorized e
             JOIN public.surveytypes st_1 ON ((e.category = (st_1.category)::text)))
          WHERE (e.category = 'B'::text)
        UNION
         SELECT e.estimate_type,
            e.category,
            e.analysis_name,
            e.analysis_year,
            e.completion_year,
            e.phenotype,
            e.phenotype_basis,
            e.site_name,
            e.actually_seen AS best_estimate,
            0 AS best_population_variance,
            e.population_estimate,
            e.population_variance,
                CASE
                    WHEN ((e.population_lower_confidence_limit IS NULL) OR (e.population_upper_confidence_limit IS NULL) OR ((e.population_lower_confidence_limit = 0) AND (e.population_upper_confidence_limit = 0))) THEN (e.population_estimate - e.actually_seen)
                    ELSE (e.population_lower_confidence_limit - e.actually_seen)
                END AS population_lower_confidence_limit,
                CASE
                    WHEN ((e.population_lower_confidence_limit IS NULL) OR (e.population_upper_confidence_limit IS NULL) OR ((e.population_lower_confidence_limit = 0) AND (e.population_upper_confidence_limit = 0))) THEN (e.population_estimate - e.actually_seen)
                    ELSE (e.population_upper_confidence_limit - e.actually_seen)
                END AS population_upper_confidence_limit,
            e.actually_seen,
            e.input_zone_id,
            e.population_submission_id,
            e.stratum_name,
            e.stratum_area,
            e.age,
            e.replacement_name,
            e.reason_change,
            e.citation,
            e.short_citation,
            e.population_confidence_interval,
            e.population_standard_error,
            e.lcl95,
            e.quality_level
           FROM public.estimate_factors_analyses_categorized e
          WHERE (e.category = 'C'::text)
        UNION
         SELECT e.estimate_type,
            e.category,
            e.analysis_name,
            e.analysis_year,
            e.completion_year,
            e.phenotype,
            e.phenotype_basis,
            e.site_name,
            e.actually_seen AS best_estimate,
            0 AS best_population_variance,
            e.population_estimate,
            e.population_variance,
                CASE
                    WHEN ((e.population_lower_confidence_limit IS NULL) OR (e.population_upper_confidence_limit IS NULL) OR ((e.population_lower_confidence_limit = 0) AND (e.population_upper_confidence_limit = 0))) THEN (e.population_estimate - e.actually_seen)
                    ELSE (e.population_lower_confidence_limit - e.actually_seen)
                END AS population_lower_confidence_limit,
                CASE
                    WHEN ((e.population_lower_confidence_limit IS NULL) OR (e.population_upper_confidence_limit IS NULL) OR ((e.population_lower_confidence_limit = 0) AND (e.population_upper_confidence_limit = 0))) THEN (e.population_estimate - e.actually_seen)
                    ELSE (e.population_upper_confidence_limit - e.actually_seen)
                END AS population_upper_confidence_limit,
            e.actually_seen,
            e.input_zone_id,
            e.population_submission_id,
            e.stratum_name,
            e.stratum_area,
            e.age,
            e.replacement_name,
            e.reason_change,
            e.citation,
            e.short_citation,
            e.population_confidence_interval,
            e.population_standard_error,
            e.lcl95,
            e.quality_level
           FROM public.estimate_factors_analyses_categorized e
          WHERE ((e.category = 'D'::text) AND ((e.site_name)::text <> 'Rest of Gabon'::text))
        UNION
         SELECT e.estimate_type,
            e.category,
            e.analysis_name,
            e.analysis_year,
            e.completion_year,
            e.phenotype,
            e.phenotype_basis,
            e.site_name,
            0 AS best_estimate,
            0 AS best_population_variance,
            0 AS population_estimate,
            0 AS population_variance,
                CASE
                    WHEN ((e.population_lower_confidence_limit IS NULL) OR (e.population_upper_confidence_limit IS NULL) OR ((e.population_lower_confidence_limit = 0) AND (e.population_upper_confidence_limit = 0))) THEN (e.population_estimate - e.actually_seen)
                    ELSE (e.population_lower_confidence_limit - e.actually_seen)
                END AS population_lower_confidence_limit,
                CASE
                    WHEN ((e.population_lower_confidence_limit IS NULL) OR (e.population_upper_confidence_limit IS NULL) OR ((e.population_lower_confidence_limit = 0) AND (e.population_upper_confidence_limit = 0))) THEN (e.population_estimate - e.actually_seen)
                    ELSE (e.population_upper_confidence_limit - e.actually_seen)
                END AS population_upper_confidence_limit,
            0 AS actually_seen,
            e.input_zone_id,
            e.population_submission_id,
            e.stratum_name,
            e.stratum_area,
            e.age,
            e.replacement_name,
            e.reason_change,
            e.citation,
            e.short_citation,
            e.population_confidence_interval,
            e.population_standard_error,
            e.lcl95,
            e.quality_level
           FROM public.estimate_factors_analyses_categorized e
          WHERE ((e.category = 'E'::text) AND (e.completion_year > (e.analysis_year - 10)))
        UNION
         SELECT e.estimate_type,
            'F'::text AS category,
            e.analysis_name,
            e.analysis_year,
            e.completion_year,
            e.phenotype,
            e.phenotype_basis,
            e.site_name,
            0 AS best_estimate,
            0 AS best_population_variance,
            e.population_estimate,
            e.population_variance,
            e.population_estimate AS population_lower_confidence_limit,
            e.population_estimate AS population_upper_confidence_limit,
            e.actually_seen,
            e.input_zone_id,
            e.population_submission_id,
            e.stratum_name,
            e.stratum_area,
            e.age,
            e.replacement_name,
            e.reason_change,
            e.citation,
            e.short_citation,
            e.population_confidence_interval,
            e.population_standard_error,
            e.lcl95,
            e.quality_level
           FROM public.estimate_factors_analyses_categorized e
          WHERE ((e.category = 'E'::text) AND (e.completion_year <= (e.analysis_year - 10)))
        UNION
         SELECT e.estimate_type,
            'G'::text AS category,
            e.analysis_name,
            e.analysis_year,
            e.completion_year,
            e.phenotype,
            e.phenotype_basis,
            e.site_name,
            0 AS best_estimate,
            0 AS best_population_variance,
            e.population_estimate,
            e.population_variance,
            e.population_estimate AS population_lower_confidence_limit,
            e.population_estimate AS population_upper_confidence_limit,
            e.actually_seen,
            e.input_zone_id,
            e.population_submission_id,
            e.stratum_name,
            e.stratum_area,
            e.age,
            e.replacement_name,
            e.reason_change,
            e.citation,
            e.short_citation,
            e.population_confidence_interval,
            e.population_standard_error,
            e.lcl95,
            e.quality_level
           FROM public.estimate_factors_analyses_categorized e
          WHERE ((e.category = 'G'::text) OR ((e.category = 'D'::text) AND ((e.site_name)::text = 'Rest of Gabon'::text)))) m
     JOIN public.surveytypes st ON ((m.category = (st.category)::text)))
     JOIN public.population_submissions ps ON ((ps.id = m.population_submission_id)))
     JOIN public.submissions s ON ((ps.submission_id = s.id)))
     JOIN public.countries c ON ((s.country_id = c.id)))
     JOIN public.regions r ON ((c.region_id = r.id)))
     JOIN public.continents ct ON ((r.continent_id = ct.id)));


--
-- Name: changes_expanded; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.changes_expanded AS
 SELECT DISTINCT a.analysis_name,
    a.analysis_year,
    ch.reason_change,
        CASE
            WHEN (ne.reason_change IS NULL) THEN ch.reason_change
            WHEN (((ne.reason_change)::text = ANY ((ARRAY['-'::character varying, 'NC'::character varying])::text[])) AND (ne.age >= 10)) THEN (
            CASE
                WHEN (oe.age >= 10) THEN '-'::text
                ELSE 'DD'::text
            END)::character varying
            ELSE ne.reason_change
        END AS adjusted_reason_change,
    ch.country,
    ch.replaced_stratum,
    ch.new_stratum
   FROM (((( SELECT nc.analysis_name,
            nc.analysis_year,
            nc.reason_change,
            nc.country,
            rc.replaced_stratum,
            nc.new_stratum
           FROM (( SELECT changes.id,
                    changes.analysis_name,
                    changes.analysis_year,
                    changes.reason_change,
                    changes.country,
                    btrim(unnest(regexp_split_to_array((changes.new_strata)::text, ','::text))) AS new_stratum
                   FROM public.changes) nc
             LEFT JOIN ( SELECT changes.id,
                    changes.analysis_name,
                    changes.analysis_year,
                    changes.reason_change,
                    changes.country,
                    changes.new_strata,
                    btrim(unnest(regexp_split_to_array((changes.replaced_strata)::text, ','::text))) AS replaced_stratum
                   FROM public.changes) rc ON (((nc.id = rc.id) AND (nc.new_stratum = ANY (regexp_split_to_array((rc.new_strata)::text, ','::text))))))
        UNION
         SELECT changes.analysis_name,
            changes.analysis_year,
            changes.reason_change,
            changes.country,
            btrim(unnest(regexp_split_to_array((changes.replaced_strata)::text, ','::text))) AS replaced_stratum,
            '-'::text
           FROM public.changes
          WHERE (((changes.new_strata)::text = '-'::text) OR (changes.new_strata IS NULL))) ch
     JOIN public.analyses a ON (((a.analysis_name)::text = (ch.analysis_name)::text)))
     LEFT JOIN public.estimate_factors_analyses_categorized_for_add oe ON ((((oe.analysis_name)::text = (ch.analysis_name)::text) AND (oe.analysis_year = a.comparison_year) AND (oe.input_zone_id = ch.replaced_stratum))))
     LEFT JOIN public.estimate_factors_analyses_categorized_for_add ne ON ((((ne.analysis_name)::text = (ch.analysis_name)::text) AND (ne.analysis_year = a.analysis_year) AND (ne.input_zone_id = ch.new_stratum))));


--
-- Name: estimate_locator; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_locator AS
 SELECT e.estimate_type,
    e.input_zone_id,
    e.population_submission_id,
    e.site_name,
    e.stratum_name,
    e.stratum_area,
    e.completion_year,
    e.analysis_name,
    e.analysis_year,
    e.phenotype,
    e.phenotype_basis,
    e.age,
    e.sort_key,
    e.population,
    e.replacement_name,
    e.reason_change,
    e.citation,
    e.short_citation,
    e.population_estimate,
    e.population_variance,
    e.population_standard_error,
    e.population_confidence_interval,
    e.population_lower_confidence_limit,
    e.population_upper_confidence_limit,
    e.quality_level,
    e.actually_seen,
    e.lcl95,
    e.category,
    countries.name AS country,
    regions.name AS region,
    continents.name AS continent
   FROM (((((public.estimate_factors_analyses_categorized e
     JOIN public.population_submissions ON ((e.population_submission_id = population_submissions.id)))
     JOIN public.submissions ON ((population_submissions.submission_id = submissions.id)))
     JOIN public.countries ON ((submissions.country_id = countries.id)))
     JOIN public.regions ON ((countries.region_id = regions.id)))
     JOIN public.continents ON ((regions.continent_id = continents.id)));


--
-- Name: ioc_add_new_base; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ioc_add_new_base AS
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.phenotype,
    e.phenotype_basis,
    e.input_zone_id,
    e.category,
    c.adjusted_reason_change AS reason_change,
    e.best_estimate AS population_estimate,
    e.best_population_variance AS population_variance,
    e.population_lower_confidence_limit,
    e.population_upper_confidence_limit
   FROM ((( SELECT DISTINCT changes_expanded.analysis_name,
            changes_expanded.analysis_year,
            changes_expanded.new_stratum,
            changes_expanded.adjusted_reason_change
           FROM public.changes_expanded) c
     JOIN public.analyses a ON ((((c.analysis_name)::text = (a.analysis_name)::text) AND (c.analysis_year = a.analysis_year))))
     JOIN public.estimate_factors_analyses_categorized_for_add e ON ((((e.analysis_name)::text = (c.analysis_name)::text) AND (e.analysis_year = a.analysis_year) AND (e.input_zone_id = c.new_stratum))));


--
-- Name: ioc_add_replaced_base; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ioc_add_replaced_base AS
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.phenotype,
    e.phenotype_basis,
    e.input_zone_id,
    e.category,
    c.adjusted_reason_change AS reason_change,
    e.best_estimate AS population_estimate,
    e.best_population_variance AS population_variance,
    e.population_lower_confidence_limit,
    e.population_upper_confidence_limit
   FROM ((( SELECT DISTINCT changes_expanded.analysis_name,
            changes_expanded.analysis_year,
            changes_expanded.replaced_stratum,
            changes_expanded.adjusted_reason_change
           FROM public.changes_expanded) c
     JOIN public.analyses a ON ((((c.analysis_name)::text = (a.analysis_name)::text) AND (c.analysis_year = a.analysis_year))))
     JOIN public.estimate_factors_analyses_categorized_for_add e ON ((((e.analysis_name)::text = (c.analysis_name)::text) AND (e.analysis_year = a.comparison_year) AND (e.input_zone_id = c.replaced_stratum))));


--
-- Name: appendix_2_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.appendix_2_add AS
 SELECT i.analysis_name,
    i.analysis_year,
    i.region,
    i.country,
    i.replacement_name,
    i.estimate_type,
    i.estimate,
    i.confidence
   FROM ( SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.country,
            l.sort_key,
            l.replacement_name,
            l.estimate_type,
            sum(e.population_estimate) AS estimate,
            ((1.96)::double precision * sqrt(sum(e.population_variance))) AS confidence
           FROM (public.ioc_add_new_base e
             JOIN public.estimate_locator l ON ((((l.analysis_name)::text = (e.analysis_name)::text) AND (l.analysis_year = e.analysis_year) AND (l.input_zone_id = e.input_zone_id))))
          WHERE ((e.reason_change)::text = 'RS'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, l.replacement_name, l.estimate_type, l.sort_key
        UNION
         SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.country,
            l.sort_key,
            l.replacement_name,
            l.estimate_type,
            sum(e.population_estimate) AS estimate,
            ((1.96)::double precision * sqrt(sum(e.population_variance))) AS confidence
           FROM (public.ioc_add_replaced_base e
             JOIN public.estimate_locator l ON ((((l.analysis_name)::text = (e.analysis_name)::text) AND (l.analysis_year = e.analysis_year) AND (l.input_zone_id = e.input_zone_id))))
          WHERE ((e.reason_change)::text = 'RS'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, l.replacement_name, l.estimate_type, l.sort_key) i
  ORDER BY i.analysis_name, i.region, i.country, i.sort_key, i.replacement_name, i.analysis_year;


--
-- Name: survey_range_intersection_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_range_intersection_metrics (
    analysis_name character varying,
    analysis_year integer,
    region character varying(255),
    range_quality character varying(10),
    category text,
    reason_change character varying(255),
    country character varying(255),
    area_sqkm double precision
);


--
-- Name: area_of_range_covered; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.area_of_range_covered AS
 SELECT k.analysis_name,
    k.analysis_year,
    k.region,
    k.country,
    k.surveytype,
    k.known,
    p.possible,
    (COALESCE(k.known, (0)::double precision) + COALESCE(p.possible, (0)::double precision)) AS total
   FROM (( SELECT m.analysis_name,
            m.analysis_year,
            m.country,
            m.region,
            t.surveytype,
            sum(m.area_sqkm) AS known
           FROM (public.survey_range_intersection_metrics m
             JOIN public.surveytypes t ON (((t.category)::text = m.category)))
          WHERE ((m.range_quality)::text = 'Known'::text)
          GROUP BY m.analysis_name, m.analysis_year, m.country, m.region, t.surveytype) k
     LEFT JOIN ( SELECT m.analysis_name,
            m.analysis_year,
            m.country,
            m.region,
            t.surveytype,
            sum(m.area_sqkm) AS possible
           FROM (public.survey_range_intersection_metrics m
             JOIN public.surveytypes t ON (((t.category)::text = m.category)))
          WHERE ((m.range_quality)::text = 'Possible'::text)
          GROUP BY m.analysis_name, m.analysis_year, m.country, m.region, t.surveytype) p ON ((((k.analysis_name)::text = (p.analysis_name)::text) AND (k.analysis_year = p.analysis_year) AND ((k.country)::text = (p.country)::text) AND ((k.surveytype)::text = (p.surveytype)::text))))
  ORDER BY k.analysis_name, k.analysis_year, k.region, k.country, k.surveytype;


--
-- Name: area_of_range_covered_subtotals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.area_of_range_covered_subtotals AS
 SELECT area_of_range_covered.analysis_name,
    area_of_range_covered.analysis_year,
    area_of_range_covered.region,
    area_of_range_covered.country,
    sum(area_of_range_covered.known) AS known,
    sum(area_of_range_covered.possible) AS possible,
    sum(area_of_range_covered.total) AS total
   FROM public.area_of_range_covered
  GROUP BY area_of_range_covered.analysis_name, area_of_range_covered.analysis_year, area_of_range_covered.region, area_of_range_covered.country
  ORDER BY area_of_range_covered.analysis_name, area_of_range_covered.analysis_year, area_of_range_covered.region, area_of_range_covered.country;


--
-- Name: country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country (
    gid integer NOT NULL,
    ccode character varying(2),
    cntryname character varying(50),
    fr_cntryna character varying(35),
    rangestate smallint,
    regionid character varying(2),
    faocode smallint,
    region character varying(20),
    definite integer,
    probable integer,
    possible integer,
    specul integer,
    cntryarea integer,
    rangearea integer,
    knownrange integer,
    possrange integer,
    doubtrange integer,
    pa_area integer,
    surveyarea integer,
    protrang integer,
    survrang integer,
    rangeknown double precision,
    rangeperc double precision,
    paperc double precision,
    surveyperc double precision,
    protrangpe double precision,
    survrangpe double precision,
    probfracti double precision,
    infqltyidx double precision,
    citeshunti smallint,
    citesappen character varying(2),
    listingyr smallint,
    rainyseaso character varying(12),
    shape_leng numeric,
    shape_area numeric,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: country_range_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_range_metrics (
    continent text,
    region character varying(20),
    country character varying(50),
    range numeric(10,0),
    range_quality character varying(10),
    area_sqkm double precision
);


--
-- Name: area_of_range_extant; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.area_of_range_extant AS
 SELECT c.region,
    c.cntryname AS country,
    k.known,
    p.possible,
    (COALESCE(k.known, (0)::double precision) + COALESCE(p.possible, (0)::double precision)) AS total
   FROM ((public.country c
     LEFT JOIN ( SELECT m.region,
            m.country,
            sum(m.area_sqkm) AS known
           FROM public.country_range_metrics m
          WHERE ((m.range = (1)::numeric) AND ((m.range_quality)::text = 'Known'::text))
          GROUP BY m.region, m.country) k ON (((k.country)::text = (c.cntryname)::text)))
     LEFT JOIN ( SELECT m.region,
            m.country,
            sum(m.area_sqkm) AS possible
           FROM public.country_range_metrics m
          WHERE ((m.range = (1)::numeric) AND ((m.range_quality)::text = 'Possible'::text))
          GROUP BY m.region, m.country) p ON (((p.country)::text = (c.cntryname)::text)))
  ORDER BY c.region, c.cntryname;


--
-- Name: area_of_range_covered_unassessed; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.area_of_range_covered_unassessed AS
 SELECT n.analysis_name,
    n.analysis_year,
    x.region,
    x.country,
    (x.known - n.known) AS known,
    (x.possible - n.possible) AS possible,
    (x.total - n.total) AS total
   FROM (public.area_of_range_extant x
     JOIN public.area_of_range_covered_subtotals n ON (((x.country)::text = (n.country)::text)))
  ORDER BY n.analysis_name, n.analysis_year, x.region, x.country;


--
-- Name: area_of_range_covered_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.area_of_range_covered_totals AS
 SELECT t.analysis_name,
    t.analysis_year,
    t.region,
    t.country,
    sum(t.known) AS known,
    sum(t.possible) AS possible,
    sum(t.total) AS total
   FROM ( SELECT area_of_range_covered_subtotals.analysis_name,
            area_of_range_covered_subtotals.analysis_year,
            area_of_range_covered_subtotals.region,
            area_of_range_covered_subtotals.country,
            area_of_range_covered_subtotals.known,
            area_of_range_covered_subtotals.possible,
            area_of_range_covered_subtotals.total
           FROM public.area_of_range_covered_subtotals
        UNION
         SELECT area_of_range_covered_unassessed.analysis_name,
            area_of_range_covered_unassessed.analysis_year,
            area_of_range_covered_unassessed.region,
            area_of_range_covered_unassessed.country,
            area_of_range_covered_unassessed.known,
            area_of_range_covered_unassessed.possible,
            area_of_range_covered_unassessed.total
           FROM public.area_of_range_covered_unassessed) t
  GROUP BY t.analysis_name, t.analysis_year, t.region, t.country
  ORDER BY t.analysis_name, t.analysis_year, t.region, t.country;


--
-- Name: backup_analyses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backup_analyses (
    analysis_name character varying,
    comparison_year integer,
    analysis_year integer,
    id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: backup_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backup_changes (
    id integer,
    analysis_name character varying(255),
    analysis_year integer,
    replacement_name character varying(255),
    replaced_strata character varying(255),
    new_strata character varying(255),
    reason_change character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    country character varying(255),
    analysis_id integer,
    status character varying,
    comments text
);


--
-- Name: base_country_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.base_country_range (
    country character varying(50),
    range numeric(10,0),
    range_quality character varying(10),
    range_geometry public.geometry
);


--
-- Name: cause_of_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cause_of_changes (
    code character varying(4),
    name character varying(100),
    display_order integer
);


--
-- Name: dpps_sums_continent_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dpps_sums_continent_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    category text,
    reason_change character varying(255),
    definite double precision,
    probable double precision,
    possible double precision,
    speculative double precision
);


--
-- Name: fractional_causes_of_change_by_continent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fractional_causes_of_change_by_continent AS
 SELECT g.analysis_name,
    g.analysis_year,
    g.continent,
    "CausesOfChange"."CauseofChange",
    sum(g.definite) AS definite,
    sum(g.probable) AS probable,
    sum(g.possible) AS possible,
    sum(g.speculative) AS specul
   FROM (public.dpps_sums_continent_category_reason g
     JOIN aed2007."CausesOfChange" ON (((g.reason_change)::text = ("CausesOfChange"."ChangeCODE")::text)))
  GROUP BY g.analysis_name, g.analysis_year, g.continent, "CausesOfChange".display_order, "CausesOfChange"."CauseofChange"
  ORDER BY g.analysis_name, g.analysis_year, g.continent, "CausesOfChange".display_order, "CausesOfChange"."CauseofChange";


--
-- Name: causes_of_change_by_continent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_by_continent AS
 SELECT fractional_causes_of_change_by_continent.analysis_name,
    fractional_causes_of_change_by_continent.analysis_year,
    fractional_causes_of_change_by_continent.continent,
    fractional_causes_of_change_by_continent."CauseofChange",
    round(fractional_causes_of_change_by_continent.definite) AS definite,
    round(fractional_causes_of_change_by_continent.probable) AS probable,
    round(fractional_causes_of_change_by_continent.possible) AS possible,
    round(fractional_causes_of_change_by_continent.specul) AS specul
   FROM public.fractional_causes_of_change_by_continent;


--
-- Name: causes_of_change_sums_by_continent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_sums_by_continent AS
 SELECT fractional_causes_of_change_by_continent.analysis_name,
    fractional_causes_of_change_by_continent.analysis_year,
    fractional_causes_of_change_by_continent.continent,
    round(sum(fractional_causes_of_change_by_continent.definite)) AS definite,
    round(sum(fractional_causes_of_change_by_continent.probable)) AS probable,
    round(sum(fractional_causes_of_change_by_continent.possible)) AS possible,
    round(sum(fractional_causes_of_change_by_continent.specul)) AS specul
   FROM public.fractional_causes_of_change_by_continent
  GROUP BY fractional_causes_of_change_by_continent.analysis_name, fractional_causes_of_change_by_continent.analysis_year, fractional_causes_of_change_by_continent.continent;


--
-- Name: continent_factors; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.continent_factors AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.continent,
    (a.actual_dif_def /
        CASE
            WHEN (c.definite = (0)::double precision) THEN (1)::double precision
            ELSE c.definite
        END) AS def_factor,
    (a.actual_dif_prob /
        CASE
            WHEN (c.probable = (0)::double precision) THEN (1)::double precision
            ELSE c.probable
        END) AS prob_factor,
    (a.actual_dif_poss /
        CASE
            WHEN (c.possible = (0)::double precision) THEN (1)::double precision
            ELSE c.possible
        END) AS poss_factor,
    (a.actual_dif_spec /
        CASE
            WHEN (c.specul = (0)::double precision) THEN (1)::double precision
            ELSE c.specul
        END) AS spec_factor
   FROM (public.causes_of_change_sums_by_continent c
     JOIN public.actual_diff_continent a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.continent)::text = (c.continent)::text))));


--
-- Name: causes_of_change_by_continent_scaled; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_by_continent_scaled AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.continent,
    c."CauseofChange",
    round((c.definite * a.def_factor)) AS definite,
    round((c.probable * a.prob_factor)) AS probable,
    round((c.possible * a.poss_factor)) AS possible,
    round((c.specul * a.spec_factor)) AS specul
   FROM (public.fractional_causes_of_change_by_continent c
     JOIN public.continent_factors a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.continent)::text = (c.continent)::text))));


--
-- Name: dpps_sums_country_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dpps_sums_country_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    country character varying(255),
    category text,
    reason_change character varying(255),
    definite double precision,
    probable double precision,
    possible double precision,
    speculative double precision
);


--
-- Name: fractional_causes_of_change_by_country; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fractional_causes_of_change_by_country AS
 SELECT g.analysis_name,
    g.analysis_year,
    g.country,
    "CausesOfChange"."CauseofChange",
    sum(g.definite) AS definite,
    sum(g.probable) AS probable,
    sum(g.possible) AS possible,
    sum(g.speculative) AS specul
   FROM (public.dpps_sums_country_category_reason g
     JOIN aed2007."CausesOfChange" ON (((g.reason_change)::text = ("CausesOfChange"."ChangeCODE")::text)))
  GROUP BY g.analysis_name, g.analysis_year, g.country, "CausesOfChange".display_order, "CausesOfChange"."CauseofChange"
  ORDER BY g.analysis_name, g.analysis_year, g.country, "CausesOfChange".display_order, "CausesOfChange"."CauseofChange";


--
-- Name: causes_of_change_by_country; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_by_country AS
 SELECT fractional_causes_of_change_by_country.analysis_name,
    fractional_causes_of_change_by_country.analysis_year,
    fractional_causes_of_change_by_country.country,
    fractional_causes_of_change_by_country."CauseofChange",
    round(fractional_causes_of_change_by_country.definite) AS definite,
    round(fractional_causes_of_change_by_country.probable) AS probable,
    round(fractional_causes_of_change_by_country.possible) AS possible,
    round(fractional_causes_of_change_by_country.specul) AS specul
   FROM public.fractional_causes_of_change_by_country;


--
-- Name: causes_of_change_sums_by_country; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_sums_by_country AS
 SELECT fractional_causes_of_change_by_country.analysis_name,
    fractional_causes_of_change_by_country.analysis_year,
    fractional_causes_of_change_by_country.country,
    round(sum(fractional_causes_of_change_by_country.definite)) AS definite,
    round(sum(fractional_causes_of_change_by_country.probable)) AS probable,
    round(sum(fractional_causes_of_change_by_country.possible)) AS possible,
    round(sum(fractional_causes_of_change_by_country.specul)) AS specul
   FROM public.fractional_causes_of_change_by_country
  GROUP BY fractional_causes_of_change_by_country.analysis_name, fractional_causes_of_change_by_country.analysis_year, fractional_causes_of_change_by_country.country;


--
-- Name: country_factors; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.country_factors AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.country,
    (a.actual_dif_def /
        CASE
            WHEN (c.definite = (0)::double precision) THEN (1)::double precision
            ELSE c.definite
        END) AS def_factor,
    (a.actual_dif_prob /
        CASE
            WHEN (c.probable = (0)::double precision) THEN (1)::double precision
            ELSE c.probable
        END) AS prob_factor,
    (a.actual_dif_poss /
        CASE
            WHEN (c.possible = (0)::double precision) THEN (1)::double precision
            ELSE c.possible
        END) AS poss_factor,
    (a.actual_dif_spec /
        CASE
            WHEN (c.specul = (0)::double precision) THEN (1)::double precision
            ELSE c.specul
        END) AS spec_factor
   FROM (public.causes_of_change_sums_by_country c
     JOIN public.actual_diff_country a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.country)::text = (c.country)::text))));


--
-- Name: causes_of_change_by_country_scaled; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_by_country_scaled AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.country,
    c."CauseofChange",
    round((c.definite * a.def_factor)) AS definite,
    round((c.probable * a.prob_factor)) AS probable,
    round((c.possible * a.poss_factor)) AS possible,
    round((c.specul * a.spec_factor)) AS specul
   FROM (public.fractional_causes_of_change_by_country c
     JOIN public.country_factors a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.country)::text = (c.country)::text))));


--
-- Name: dpps_sums_region_category_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dpps_sums_region_category_reason (
    analysis_name character varying,
    analysis_year integer,
    continent character varying(255),
    region character varying(255),
    category text,
    reason_change character varying(255),
    definite double precision,
    probable double precision,
    possible double precision,
    speculative double precision
);


--
-- Name: fractional_causes_of_change_by_region; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fractional_causes_of_change_by_region AS
 SELECT g.analysis_name,
    g.analysis_year,
    g.region,
    "CausesOfChange"."CauseofChange",
    sum(g.definite) AS definite,
    sum(g.probable) AS probable,
    sum(g.possible) AS possible,
    sum(g.speculative) AS specul
   FROM (public.dpps_sums_region_category_reason g
     JOIN aed2007."CausesOfChange" ON (((g.reason_change)::text = ("CausesOfChange"."ChangeCODE")::text)))
  GROUP BY g.analysis_name, g.analysis_year, g.region, "CausesOfChange".display_order, "CausesOfChange"."CauseofChange"
  ORDER BY g.analysis_name, g.analysis_year, g.region, "CausesOfChange".display_order, "CausesOfChange"."CauseofChange";


--
-- Name: causes_of_change_by_region; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_by_region AS
 SELECT fractional_causes_of_change_by_region.analysis_name,
    fractional_causes_of_change_by_region.analysis_year,
    fractional_causes_of_change_by_region.region,
    fractional_causes_of_change_by_region."CauseofChange",
    round(fractional_causes_of_change_by_region.definite) AS definite,
    round(fractional_causes_of_change_by_region.probable) AS probable,
    round(fractional_causes_of_change_by_region.possible) AS possible,
    round(fractional_causes_of_change_by_region.specul) AS specul
   FROM public.fractional_causes_of_change_by_region;


--
-- Name: causes_of_change_sums_by_region; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_sums_by_region AS
 SELECT fractional_causes_of_change_by_region.analysis_name,
    fractional_causes_of_change_by_region.analysis_year,
    fractional_causes_of_change_by_region.region,
    round(sum(fractional_causes_of_change_by_region.definite)) AS definite,
    round(sum(fractional_causes_of_change_by_region.probable)) AS probable,
    round(sum(fractional_causes_of_change_by_region.possible)) AS possible,
    round(sum(fractional_causes_of_change_by_region.specul)) AS specul
   FROM public.fractional_causes_of_change_by_region
  GROUP BY fractional_causes_of_change_by_region.analysis_name, fractional_causes_of_change_by_region.analysis_year, fractional_causes_of_change_by_region.region;


--
-- Name: region_factors; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.region_factors AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.region,
    (a.actual_dif_def /
        CASE
            WHEN (c.definite = (0)::double precision) THEN (1)::double precision
            ELSE c.definite
        END) AS def_factor,
    (a.actual_dif_prob /
        CASE
            WHEN (c.probable = (0)::double precision) THEN (1)::double precision
            ELSE c.probable
        END) AS prob_factor,
    (a.actual_dif_poss /
        CASE
            WHEN (c.possible = (0)::double precision) THEN (1)::double precision
            ELSE c.possible
        END) AS poss_factor,
    (a.actual_dif_spec /
        CASE
            WHEN (c.specul = (0)::double precision) THEN (1)::double precision
            ELSE c.specul
        END) AS spec_factor
   FROM (public.causes_of_change_sums_by_region c
     JOIN public.actual_diff_region a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.region)::text = (c.region)::text))));


--
-- Name: causes_of_change_by_region_scaled; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_by_region_scaled AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.region,
    c."CauseofChange",
    round((c.definite * a.def_factor)) AS definite,
    round((c.probable * a.prob_factor)) AS probable,
    round((c.possible * a.poss_factor)) AS possible,
    round((c.specul * a.spec_factor)) AS specul
   FROM (public.fractional_causes_of_change_by_region c
     JOIN public.region_factors a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.region)::text = (c.region)::text))));


--
-- Name: causes_of_change_sums_by_continent_scaled; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_sums_by_continent_scaled AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.continent,
    (c.definite * a.def_factor) AS definite,
    (c.probable * a.prob_factor) AS probable,
    (c.possible * a.poss_factor) AS possible,
    (c.specul * a.spec_factor) AS specul
   FROM (public.causes_of_change_sums_by_continent c
     JOIN public.continent_factors a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.continent)::text = (c.continent)::text))));


--
-- Name: causes_of_change_sums_by_country_scaled; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_sums_by_country_scaled AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.country,
    (c.definite * a.def_factor) AS definite,
    (c.probable * a.prob_factor) AS probable,
    (c.possible * a.poss_factor) AS possible,
    (c.specul * a.spec_factor) AS specul
   FROM (public.causes_of_change_sums_by_country c
     JOIN public.country_factors a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.country)::text = (c.country)::text))));


--
-- Name: causes_of_change_sums_by_region_scaled; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.causes_of_change_sums_by_region_scaled AS
 SELECT c.analysis_name,
    c.analysis_year,
    c.region,
    (c.definite * a.def_factor) AS definite,
    (c.probable * a.prob_factor) AS probable,
    (c.possible * a.poss_factor) AS possible,
    (c.specul * a.spec_factor) AS specul
   FROM (public.causes_of_change_sums_by_region c
     JOIN public.region_factors a ON ((((a.analysis_name)::text = (c.analysis_name)::text) AND (a.analysis_year = c.analysis_year) AND ((a.region)::text = (c.region)::text))));


--
-- Name: changed_strata; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.changed_strata AS
 SELECT DISTINCT w.analysis_name,
    w.reason_change,
    w.replaced_stratum,
    w.new_stratum
   FROM ( SELECT q.analysis_name,
            (
                CASE
                    WHEN (((q.reason_change)::text = '-'::text) AND (a.age > 10)) THEN 'DD'::character varying
                    ELSE q.reason_change
                END)::character varying(255) AS reason_change,
            q.replaced_stratum,
            q.new_stratum
           FROM (( SELECT DISTINCT changes.analysis_name,
                    changes.reason_change,
                    unnest(regexp_split_to_array((changes.new_strata)::text, ','::text)) AS new_stratum,
                    unnest(regexp_split_to_array((changes.replaced_strata)::text, ','::text)) AS replaced_stratum
                   FROM public.changes) q
             LEFT JOIN public.estimate_factors_analyses a ON (((q.replaced_stratum = a.input_zone_id) AND ((q.analysis_name)::text = (a.analysis_name)::text))))
          WHERE ((q.new_stratum IS NOT NULL) AND (q.new_stratum <> ''::text))
          ORDER BY q.analysis_name, q.reason_change, q.replaced_stratum, q.new_stratum) w
  WHERE ((w.reason_change)::text <> '-'::text);


--
-- Name: changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.changes_id_seq OWNED BY public.changes.id;


--
-- Name: continent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.continent (
    gid integer NOT NULL,
    continent character varying(10),
    definite integer,
    probable integer,
    possible integer,
    specul integer,
    cntryarea integer,
    rangearea integer,
    knownrange integer,
    possrange integer,
    doubtrange integer,
    pa_area integer,
    surveyarea integer,
    protrang integer,
    survrang integer,
    rangeknown double precision,
    rangeperc double precision,
    paperc double precision,
    surveyperc double precision,
    protrangpe double precision,
    survrangpe double precision,
    probfracti double precision,
    infqltyidx double precision,
    shape_leng numeric,
    shape_area numeric,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: continent_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continent_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continent_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continent_gid_seq OWNED BY public.continent.gid;


--
-- Name: continental_area_of_range_covered; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.continental_area_of_range_covered AS
 SELECT area_of_range_covered.analysis_name,
    area_of_range_covered.analysis_year,
    area_of_range_covered.surveytype,
    sum(area_of_range_covered.known) AS known,
    sum(area_of_range_covered.possible) AS possible,
    sum(area_of_range_covered.total) AS total
   FROM public.area_of_range_covered
  GROUP BY area_of_range_covered.analysis_name, area_of_range_covered.analysis_year, area_of_range_covered.surveytype
  ORDER BY area_of_range_covered.analysis_name, area_of_range_covered.analysis_year, area_of_range_covered.surveytype;


--
-- Name: continental_area_of_range_covered_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.continental_area_of_range_covered_totals AS
 SELECT area_of_range_covered_totals.analysis_name,
    area_of_range_covered_totals.analysis_year,
    sum(area_of_range_covered_totals.known) AS known,
    sum(area_of_range_covered_totals.possible) AS possible,
    sum(area_of_range_covered_totals.total) AS total
   FROM public.area_of_range_covered_totals
  GROUP BY area_of_range_covered_totals.analysis_name, area_of_range_covered_totals.analysis_year;


--
-- Name: continental_area_of_range_covered_unassessed; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.continental_area_of_range_covered_unassessed AS
 SELECT area_of_range_covered_unassessed.analysis_name,
    area_of_range_covered_unassessed.analysis_year,
    sum(area_of_range_covered_unassessed.known) AS known,
    sum(area_of_range_covered_unassessed.possible) AS possible,
    sum(area_of_range_covered_unassessed.total) AS total
   FROM public.area_of_range_covered_unassessed
  GROUP BY area_of_range_covered_unassessed.analysis_name, area_of_range_covered_unassessed.analysis_year;


--
-- Name: regional_range_metrics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.regional_range_metrics AS
 SELECT country_range_metrics.continent,
    country_range_metrics.region,
    country_range_metrics.range,
    country_range_metrics.range_quality,
    sum(country_range_metrics.area_sqkm) AS area_sqkm
   FROM public.country_range_metrics
  GROUP BY country_range_metrics.continent, country_range_metrics.region, country_range_metrics.range, country_range_metrics.range_quality;


--
-- Name: continental_range_metrics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.continental_range_metrics AS
 SELECT regional_range_metrics.continent,
    regional_range_metrics.range,
    regional_range_metrics.range_quality,
    sum(regional_range_metrics.area_sqkm) AS area_sqkm
   FROM public.regional_range_metrics
  GROUP BY regional_range_metrics.continent, regional_range_metrics.range, regional_range_metrics.range_quality;


--
-- Name: region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region (
    gid integer NOT NULL,
    regionid character varying(254),
    region character varying(20),
    continent character varying(10),
    fr_region character varying(20),
    definite integer,
    probable integer,
    possible integer,
    specul integer,
    cntryarea integer,
    rangearea integer,
    knownrange integer,
    possrange integer,
    doubtrange integer,
    pa_area integer,
    surveyarea integer,
    protrang integer,
    rangeknown double precision,
    survrang integer,
    rangeperc double precision,
    paperc double precision,
    surveyperc double precision,
    protrangpe double precision,
    survrangpe double precision,
    probfracti double precision,
    infqltyidx double precision,
    shape_leng numeric,
    shape_area numeric,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: continental_range_table; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.continental_range_table AS
 SELECT sm.analysis_name,
    sm.analysis_year,
    'Africa'::text AS continent,
    r.region,
    sum(m.area_sqkm) AS range_area,
    sum(n.area_sqkm) AS continental_range,
    ((sum(m.area_sqkm) / sum(n.area_sqkm)) * (100)::double precision) AS percent_continental_range,
    sum(sm.area_sqkm) AS range_assessed,
    ((sum(sm.area_sqkm) / sum(m.area_sqkm)) * (100)::double precision) AS percent_range_assessed
   FROM (((( SELECT regional_range_metrics.region,
            sum(regional_range_metrics.area_sqkm) AS area_sqkm
           FROM public.regional_range_metrics
          GROUP BY regional_range_metrics.region) m
     JOIN public.region r ON (((r.region)::text = (m.region)::text)))
     JOIN ( SELECT 'Africa'::text AS continent,
            sum(continental_range_metrics.area_sqkm) AS area_sqkm
           FROM public.continental_range_metrics) n ON ((n.continent = (r.continent)::text)))
     JOIN ( SELECT survey_range_intersection_metrics.analysis_name,
            survey_range_intersection_metrics.analysis_year,
            survey_range_intersection_metrics.region,
            sum(survey_range_intersection_metrics.area_sqkm) AS area_sqkm
           FROM public.survey_range_intersection_metrics
          GROUP BY survey_range_intersection_metrics.analysis_name, survey_range_intersection_metrics.analysis_year, survey_range_intersection_metrics.region) sm ON (((sm.region)::text = (m.region)::text)))
  GROUP BY sm.analysis_name, sm.analysis_year, n.continent, r.region
  ORDER BY sm.analysis_name, sm.analysis_year, n.continent, r.region;


--
-- Name: continental_range_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.continental_range_totals AS
 SELECT continental_range_table.analysis_name,
    continental_range_table.analysis_year,
    continental_range_table.continent,
    sum(continental_range_table.range_area) AS range_area,
    sum(continental_range_table.continental_range) AS continental_range,
    sum(continental_range_table.percent_continental_range) AS percent_continental_range,
    sum(continental_range_table.range_assessed) AS range_assessed,
    ((sum(continental_range_table.range_assessed) / sum(continental_range_table.range_area)) * (100)::double precision) AS percent_range_assessed
   FROM public.continental_range_table
  GROUP BY continental_range_table.analysis_name, continental_range_table.analysis_year, continental_range_table.continent
  ORDER BY continental_range_table.analysis_name, continental_range_table.analysis_year, continental_range_table.continent;


--
-- Name: continents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.continents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: continents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.continents_id_seq OWNED BY public.continents.id;


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: country_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_gid_seq OWNED BY public.country.gid;


--
-- Name: country_pa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_pa (
    country character varying(50),
    stated integer,
    protected_area public.geometry
);


--
-- Name: country_pa_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_pa_metrics (
    country character varying(50),
    stated integer,
    protected_area_sqkm double precision,
    percent_protected double precision
);


--
-- Name: country_pa_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_pa_range (
    country character varying(50),
    stated integer,
    protected_area_range public.geometry
);


--
-- Name: country_pa_range_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_pa_range_metrics (
    country character varying(50),
    stated integer,
    range_sqkm double precision,
    protected_area_range_sqkm double precision,
    percent_protected_range double precision
);


--
-- Name: country_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_range (
    country character varying(50),
    range numeric(10,0),
    range_quality character varying(10),
    range_geometry public.geometry
);


--
-- Name: country_range_by_category; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.country_range_by_category AS
 SELECT a.region,
    a.country,
    a.category,
    a.analysis_year,
    a.analysis_name,
    a."AREA" AS "ASSESSED_RANGE",
    ((a."AREA" / rt.range_area) * (100)::double precision) AS "CATEGORY_PERCENT_RANGE_ASSESSED",
    rt.range_area AS "RANGE_AREA"
   FROM (( SELECT sm.category,
            sm.region,
            sm.country,
            sm.analysis_year,
            sm.analysis_name,
            sum(sm.area_sqkm) AS "AREA"
           FROM public.survey_range_intersection_metrics sm
          GROUP BY sm.category, sm.region, sm.country, sm.analysis_year, sm.analysis_name) a
     JOIN ( SELECT country_range_metrics.country,
            sum(country_range_metrics.area_sqkm) AS range_area
           FROM public.country_range_metrics
          GROUP BY country_range_metrics.country) rt ON (((rt.country)::text = (a.country)::text)))
  ORDER BY a.country, a.category;


--
-- Name: country_range_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.country_range_totals AS
 SELECT a.region,
    a.country,
    a.analysis_year,
    a.analysis_name,
    sum(a."ASSESSED_RANGE") AS "ASSESSED_RANGE",
    sum(a."CATEGORY_PERCENT_RANGE_ASSESSED") AS "CATEGORY_PERCENT_RANGE_ASSESSED",
    a."RANGE_AREA"
   FROM public.country_range_by_category a
  GROUP BY a.region, a.country, a.analysis_year, a.analysis_name, a."RANGE_AREA"
  ORDER BY a.region, a.country, a.analysis_year, a.analysis_name, a."RANGE_AREA";


--
-- Name: country_range_union_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_range_union_metrics (
    continent text,
    region character varying(20),
    country character varying(50),
    range numeric(10,0),
    range_quality character varying(10),
    area_sqkm double precision
);


--
-- Name: country_range_unions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_range_unions (
    country character varying(50),
    range numeric(10,0),
    range_quality character varying(10),
    range_geometry public.geometry
);


--
-- Name: country_updated; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_updated (
    gid integer NOT NULL,
    __gid numeric(10,0),
    ccode character varying(254),
    cntryname character varying(254),
    fr_cntryna character varying(254),
    rangestate numeric(10,0),
    regionid character varying(254),
    faocode numeric(10,0),
    region character varying(254),
    definite numeric(10,0),
    probable numeric(10,0),
    possible numeric(10,0),
    specul numeric(10,0),
    cntryarea numeric(10,0),
    rangearea numeric(10,0),
    knownrange numeric(10,0),
    possrange numeric(10,0),
    doubtrange numeric(10,0),
    pa_area numeric(10,0),
    surveyarea numeric(10,0),
    protrang numeric(10,0),
    survrang numeric(10,0),
    rangeknown numeric,
    rangeperc numeric,
    paperc numeric,
    surveyperc numeric,
    protrangpe numeric,
    survrangpe numeric,
    probfracti numeric,
    infqltyidx numeric,
    citeshunti numeric(10,0),
    citesappen character varying(254),
    listingyr numeric(10,0),
    rainyseaso character varying(254),
    shape_leng numeric,
    shape_area numeric,
    x double precision,
    y double precision,
    rotation double precision,
    geom public.geometry(MultiPolygon)
);


--
-- Name: country_updated_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_updated_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_updated_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_updated_gid_seq OWNED BY public.country_updated.gid;


--
-- Name: data_request_forms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_request_forms (
    id integer NOT NULL,
    name character varying(255),
    title character varying(255),
    department character varying(255),
    organization character varying(255),
    telephone character varying(255),
    fax character varying(255),
    email character varying(255),
    website character varying(255),
    address text,
    town character varying(255),
    post_code character varying(255),
    state character varying(255),
    country character varying(255),
    extracts text,
    research text,
    subset_other text,
    status character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: data_request_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_request_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_request_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_request_forms_id_seq OWNED BY public.data_request_forms.id;


--
-- Name: dev_protected_area_geometries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dev_protected_area_geometries (
    gid integer,
    ptacode numeric(10,0),
    ptaname character varying(254),
    ccode character varying(254),
    year_est numeric(10,0),
    iucncat character varying(254),
    iucncatara numeric(10,0),
    designate character varying(254),
    abvdesig character varying(254),
    area_sqkm numeric(10,0),
    reported numeric(10,0),
    calculated numeric(10,0),
    source character varying(254),
    refid numeric(10,0),
    inrange numeric(10,0),
    samesurvey numeric(10,0),
    shape_leng numeric,
    shape_area numeric,
    selection numeric(10,0),
    geometry public.geometry
);


--
-- Name: ead_pa_layer_2016; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ead_pa_layer_2016 (
    gid integer NOT NULL,
    __gid numeric(10,0),
    ptacode numeric(10,0),
    ptaname character varying(254),
    ccode character varying(254),
    year_est numeric(10,0),
    iucncat character varying(254),
    iucncatara numeric(10,0),
    designate character varying(254),
    abvdesig character varying(254),
    area_sqkm numeric(10,0),
    reported numeric(10,0),
    calculated numeric(10,0),
    source character varying(254),
    refid numeric(10,0),
    inrange numeric(10,0),
    samesurvey numeric(10,0),
    shape_leng numeric,
    shape_area numeric,
    selection numeric(10,0),
    aed2016dis character varying(5),
    country character varying(100),
    geom public.geometry(MultiPolygon,102022)
);


--
-- Name: ead_pa_layer_2016_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ead_pa_layer_2016_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ead_pa_layer_2016_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ead_pa_layer_2016_gid_seq OWNED BY public.ead_pa_layer_2016.gid;


--
-- Name: estimate_dpps; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_dpps AS
 SELECT estimate_factors_analyses_categorized.analysis_name,
    estimate_factors_analyses_categorized.analysis_year,
    estimate_factors_analyses_categorized.input_zone_id,
    estimate_factors_analyses_categorized.category,
    estimate_factors_analyses_categorized.population_estimate,
    estimate_factors_analyses_categorized.population_estimate AS definite,
    0 AS probable,
    0 AS possible,
    0 AS speculative
   FROM public.estimate_factors_analyses_categorized
  WHERE (estimate_factors_analyses_categorized.category = 'A'::text)
UNION
 SELECT estimate_factors_analyses_categorized.analysis_name,
    estimate_factors_analyses_categorized.analysis_year,
    estimate_factors_analyses_categorized.input_zone_id,
    estimate_factors_analyses_categorized.category,
    estimate_factors_analyses_categorized.population_estimate,
        CASE
            WHEN (estimate_factors_analyses_categorized.lcl95 > (estimate_factors_analyses_categorized.actually_seen)::double precision) THEN estimate_factors_analyses_categorized.lcl95
            ELSE (estimate_factors_analyses_categorized.actually_seen)::double precision
        END AS definite,
        CASE
            WHEN ((estimate_factors_analyses_categorized.lcl95 > (0)::double precision) OR (estimate_factors_analyses_categorized.actually_seen > 0)) THEN GREATEST(((estimate_factors_analyses_categorized.population_estimate)::double precision -
            CASE
                WHEN (estimate_factors_analyses_categorized.lcl95 > (estimate_factors_analyses_categorized.actually_seen)::double precision) THEN estimate_factors_analyses_categorized.lcl95
                ELSE (estimate_factors_analyses_categorized.actually_seen)::double precision
            END), (0)::double precision)
            ELSE (estimate_factors_analyses_categorized.population_estimate)::double precision
        END AS probable,
    estimate_factors_analyses_categorized.population_confidence_interval AS possible,
    0 AS speculative
   FROM public.estimate_factors_analyses_categorized
  WHERE (estimate_factors_analyses_categorized.category = 'B'::text)
UNION
 SELECT estimate_factors_analyses_categorized.analysis_name,
    estimate_factors_analyses_categorized.analysis_year,
    estimate_factors_analyses_categorized.input_zone_id,
    estimate_factors_analyses_categorized.category,
    estimate_factors_analyses_categorized.population_estimate,
        CASE
            WHEN (estimate_factors_analyses_categorized.actually_seen > 0) THEN estimate_factors_analyses_categorized.actually_seen
            ELSE 0
        END AS definite,
    estimate_factors_analyses_categorized.population_estimate AS probable,
        CASE
            WHEN ((estimate_factors_analyses_categorized.lcl95 > (0)::double precision) OR (estimate_factors_analyses_categorized.actually_seen > 0)) THEN GREATEST(((estimate_factors_analyses_categorized.population_estimate)::double precision -
            CASE
                WHEN (estimate_factors_analyses_categorized.lcl95 > (estimate_factors_analyses_categorized.actually_seen)::double precision) THEN estimate_factors_analyses_categorized.lcl95
                ELSE (estimate_factors_analyses_categorized.actually_seen)::double precision
            END), (0)::double precision)
            ELSE (0)::double precision
        END AS possible,
    0 AS speculative
   FROM public.estimate_factors_analyses_categorized
  WHERE (estimate_factors_analyses_categorized.category = 'C'::text)
UNION
 SELECT estimate_factors_analyses_categorized.analysis_name,
    estimate_factors_analyses_categorized.analysis_year,
    estimate_factors_analyses_categorized.input_zone_id,
    estimate_factors_analyses_categorized.category,
    estimate_factors_analyses_categorized.population_estimate,
        CASE
            WHEN (estimate_factors_analyses_categorized.actually_seen > 0) THEN estimate_factors_analyses_categorized.actually_seen
            ELSE 0
        END AS definite,
    0 AS probable,
        CASE
            WHEN (estimate_factors_analyses_categorized.actually_seen > 0) THEN GREATEST((estimate_factors_analyses_categorized.population_estimate - estimate_factors_analyses_categorized.actually_seen), 0)
            ELSE estimate_factors_analyses_categorized.population_estimate
        END AS possible,
        CASE
            WHEN ((estimate_factors_analyses_categorized.lcl95 > (0)::double precision) AND (estimate_factors_analyses_categorized.lcl95 <> (estimate_factors_analyses_categorized.population_estimate)::double precision)) THEN GREATEST((((estimate_factors_analyses_categorized.population_estimate)::double precision - estimate_factors_analyses_categorized.lcl95) * (2)::double precision), (0)::double precision)
            WHEN (estimate_factors_analyses_categorized.population_upper_confidence_limit > 0) THEN (GREATEST((estimate_factors_analyses_categorized.population_upper_confidence_limit - estimate_factors_analyses_categorized.population_estimate), 0))::double precision
            ELSE (0)::double precision
        END AS speculative
   FROM public.estimate_factors_analyses_categorized
  WHERE (estimate_factors_analyses_categorized.category = 'D'::text)
UNION
 SELECT estimate_factors_analyses_categorized.analysis_name,
    estimate_factors_analyses_categorized.analysis_year,
    estimate_factors_analyses_categorized.input_zone_id,
    estimate_factors_analyses_categorized.category,
    estimate_factors_analyses_categorized.population_estimate,
        CASE
            WHEN (estimate_factors_analyses_categorized.actually_seen > 0) THEN estimate_factors_analyses_categorized.actually_seen
            ELSE 0
        END AS definite,
    0 AS probable,
    0 AS possible,
    GREATEST((estimate_factors_analyses_categorized.population_estimate - estimate_factors_analyses_categorized.actually_seen), 0) AS speculative
   FROM public.estimate_factors_analyses_categorized
  WHERE (estimate_factors_analyses_categorized.category = 'E'::text);


--
-- Name: estimate_factors_analyses_categorized_sums_continent_for_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized_sums_continent_for_add AS
 SELECT e.category AS "CATEGORY",
    e.surveytype AS "SURVEYTYPE",
    e.analysis_year,
    e.analysis_name,
    e.continent,
    e.phenotype,
    e.phenotype_basis,
    sum(e.best_estimate) AS "ESTIMATE",
    ((1.96)::double precision * sqrt(sum(e.population_variance))) AS "CONFIDENCE",
    sum(e.population_lower_confidence_limit) AS "GUESS_MIN",
    sum(e.population_upper_confidence_limit) AS "GUESS_MAX",
    sum(e.best_population_variance) AS population_variance
   FROM public.estimate_factors_analyses_categorized_for_add e
  WHERE (e.category <> 'C'::text)
  GROUP BY e.category, e.surveytype, e.analysis_year, e.analysis_name, e.continent, e.phenotype, e.phenotype_basis
UNION
 SELECT e.category AS "CATEGORY",
    e.surveytype AS "SURVEYTYPE",
    e.analysis_year,
    e.analysis_name,
    e.continent,
    e.phenotype,
    e.phenotype_basis,
    sum(e.best_estimate) AS "ESTIMATE",
    0 AS "CONFIDENCE",
    ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS "GUESS_MIN",
    ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS "GUESS_MAX",
    sum(e.best_population_variance) AS population_variance
   FROM public.estimate_factors_analyses_categorized_for_add e
  WHERE (e.category = 'C'::text)
  GROUP BY e.category, e.surveytype, e.analysis_year, e.analysis_name, e.continent, e.phenotype, e.phenotype_basis
  ORDER BY 1;


--
-- Name: estimate_factors_analyses_categorized_sums_country_for_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized_sums_country_for_add AS
 SELECT e.category AS "CATEGORY",
    e.surveytype AS "SURVEYTYPE",
    e.analysis_year,
    e.analysis_name,
    e.continent,
    e.region,
    e.country,
    e.phenotype,
    e.phenotype_basis,
    sum(e.best_estimate) AS "ESTIMATE",
    ((1.96)::double precision * sqrt(sum(e.best_population_variance))) AS "CONFIDENCE",
    sum(e.population_lower_confidence_limit) AS "GUESS_MIN",
    sum(e.population_upper_confidence_limit) AS "GUESS_MAX",
    sum(e.best_population_variance) AS population_variance
   FROM public.estimate_factors_analyses_categorized_for_add e
  WHERE (e.category <> 'C'::text)
  GROUP BY e.category, e.surveytype, e.analysis_year, e.analysis_name, e.continent, e.region, e.country, e.phenotype, e.phenotype_basis
UNION
 SELECT e.category AS "CATEGORY",
    e.surveytype AS "SURVEYTYPE",
    e.analysis_year,
    e.analysis_name,
    e.continent,
    e.region,
    e.country,
    e.phenotype,
    e.phenotype_basis,
    sum(e.best_estimate) AS "ESTIMATE",
    0 AS "CONFIDENCE",
    ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS "GUESS_MIN",
    ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS "GUESS_MAX",
    sum(e.best_population_variance) AS population_variance
   FROM public.estimate_factors_analyses_categorized_for_add e
  WHERE (e.category = 'C'::text)
  GROUP BY e.category, e.surveytype, e.analysis_year, e.analysis_name, e.continent, e.region, e.country, e.phenotype, e.phenotype_basis
  ORDER BY 1;


--
-- Name: estimate_factors_analyses_categorized_sums_region_for_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized_sums_region_for_add AS
 SELECT e.category AS "CATEGORY",
    e.surveytype AS "SURVEYTYPE",
    e.analysis_year,
    e.analysis_name,
    e.continent,
    e.region,
    e.phenotype,
    e.phenotype_basis,
    sum(e.best_estimate) AS "ESTIMATE",
    ((1.96)::double precision * sqrt(sum(e.best_population_variance))) AS "CONFIDENCE",
    sum(e.population_lower_confidence_limit) AS "GUESS_MIN",
    sum(e.population_upper_confidence_limit) AS "GUESS_MAX",
    sum(e.best_population_variance) AS population_variance
   FROM public.estimate_factors_analyses_categorized_for_add e
  WHERE (e.category <> 'C'::text)
  GROUP BY e.category, e.surveytype, e.analysis_year, e.analysis_name, e.continent, e.region, e.phenotype, e.phenotype_basis
UNION
 SELECT e.category AS "CATEGORY",
    e.surveytype AS "SURVEYTYPE",
    e.analysis_year,
    e.analysis_name,
    e.continent,
    e.region,
    e.phenotype,
    e.phenotype_basis,
    sum(e.best_estimate) AS "ESTIMATE",
    0 AS "CONFIDENCE",
    ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS "GUESS_MIN",
    ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS "GUESS_MAX",
    sum(e.best_population_variance) AS population_variance
   FROM public.estimate_factors_analyses_categorized_for_add e
  WHERE (e.category = 'C'::text)
  GROUP BY e.category, e.surveytype, e.analysis_year, e.analysis_name, e.continent, e.region, e.phenotype, e.phenotype_basis
  ORDER BY 1;


--
-- Name: estimate_factors_analyses_categorized_totals_continent_for_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized_totals_continent_for_add AS
 SELECT estimate_factors_analyses_categorized_sums_continent_for_add.analysis_name,
    estimate_factors_analyses_categorized_sums_continent_for_add.analysis_year,
    estimate_factors_analyses_categorized_sums_continent_for_add.continent,
    estimate_factors_analyses_categorized_sums_continent_for_add.phenotype,
    estimate_factors_analyses_categorized_sums_continent_for_add.phenotype_basis,
    sum(estimate_factors_analyses_categorized_sums_continent_for_add."ESTIMATE") AS "ESTIMATE",
    ((1.96)::double precision * sqrt(sum(estimate_factors_analyses_categorized_sums_continent_for_add.population_variance))) AS "CONFIDENCE",
    sum(estimate_factors_analyses_categorized_sums_continent_for_add."GUESS_MIN") AS "GUESS_MIN",
    sum(estimate_factors_analyses_categorized_sums_continent_for_add."GUESS_MAX") AS "GUESS_MAX"
   FROM public.estimate_factors_analyses_categorized_sums_continent_for_add
  GROUP BY estimate_factors_analyses_categorized_sums_continent_for_add.analysis_name, estimate_factors_analyses_categorized_sums_continent_for_add.analysis_year, estimate_factors_analyses_categorized_sums_continent_for_add.continent, estimate_factors_analyses_categorized_sums_continent_for_add.phenotype, estimate_factors_analyses_categorized_sums_continent_for_add.phenotype_basis;


--
-- Name: estimate_factors_analyses_categorized_totals_country_for_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized_totals_country_for_add AS
 SELECT estimate_factors_analyses_categorized_sums_country_for_add.analysis_name,
    estimate_factors_analyses_categorized_sums_country_for_add.analysis_year,
    estimate_factors_analyses_categorized_sums_country_for_add.continent,
    estimate_factors_analyses_categorized_sums_country_for_add.region,
    estimate_factors_analyses_categorized_sums_country_for_add.country,
    estimate_factors_analyses_categorized_sums_country_for_add.phenotype,
    estimate_factors_analyses_categorized_sums_country_for_add.phenotype_basis,
    sum(estimate_factors_analyses_categorized_sums_country_for_add."ESTIMATE") AS "ESTIMATE",
    ((1.96)::double precision * sqrt(sum(estimate_factors_analyses_categorized_sums_country_for_add.population_variance))) AS "CONFIDENCE",
    sum(estimate_factors_analyses_categorized_sums_country_for_add."GUESS_MIN") AS "GUESS_MIN",
    sum(estimate_factors_analyses_categorized_sums_country_for_add."GUESS_MAX") AS "GUESS_MAX"
   FROM public.estimate_factors_analyses_categorized_sums_country_for_add
  GROUP BY estimate_factors_analyses_categorized_sums_country_for_add.analysis_name, estimate_factors_analyses_categorized_sums_country_for_add.analysis_year, estimate_factors_analyses_categorized_sums_country_for_add.continent, estimate_factors_analyses_categorized_sums_country_for_add.region, estimate_factors_analyses_categorized_sums_country_for_add.country, estimate_factors_analyses_categorized_sums_country_for_add.phenotype, estimate_factors_analyses_categorized_sums_country_for_add.phenotype_basis;


--
-- Name: estimate_factors_analyses_categorized_totals_region_for_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized_totals_region_for_add AS
 SELECT estimate_factors_analyses_categorized_sums_region_for_add.analysis_name,
    estimate_factors_analyses_categorized_sums_region_for_add.analysis_year,
    estimate_factors_analyses_categorized_sums_region_for_add.continent,
    estimate_factors_analyses_categorized_sums_region_for_add.region,
    estimate_factors_analyses_categorized_sums_region_for_add.phenotype,
    estimate_factors_analyses_categorized_sums_region_for_add.phenotype_basis,
    sum(estimate_factors_analyses_categorized_sums_region_for_add."ESTIMATE") AS "ESTIMATE",
    ((1.96)::double precision * sqrt(sum(estimate_factors_analyses_categorized_sums_region_for_add.population_variance))) AS "CONFIDENCE",
    sum(estimate_factors_analyses_categorized_sums_region_for_add."GUESS_MIN") AS "GUESS_MIN",
    sum(estimate_factors_analyses_categorized_sums_region_for_add."GUESS_MAX") AS "GUESS_MAX"
   FROM public.estimate_factors_analyses_categorized_sums_region_for_add
  GROUP BY estimate_factors_analyses_categorized_sums_region_for_add.analysis_name, estimate_factors_analyses_categorized_sums_region_for_add.analysis_year, estimate_factors_analyses_categorized_sums_region_for_add.continent, estimate_factors_analyses_categorized_sums_region_for_add.region, estimate_factors_analyses_categorized_sums_region_for_add.phenotype, estimate_factors_analyses_categorized_sums_region_for_add.phenotype_basis;


--
-- Name: survey_geometries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_geometries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_geometries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_geometries (
    id integer DEFAULT nextval('public.survey_geometries_id_seq'::regclass) NOT NULL,
    geom public.geometry,
    attribution character varying
);


--
-- Name: estimate_locator_with_geometry; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_locator_with_geometry AS
 SELECT g.id,
    l.estimate_type,
    l.input_zone_id,
    l.population_submission_id,
    l.site_name,
    l.stratum_name,
    l.stratum_area,
    l.completion_year,
    l.analysis_name,
    l.analysis_year,
    l.age,
    l.replacement_name,
    l.reason_change,
    l.citation,
    l.short_citation,
    l.population_estimate,
    l.population_variance,
    l.population_standard_error,
    l.population_confidence_interval,
    l.population_lower_confidence_limit,
    l.population_upper_confidence_limit,
    l.quality_level,
    l.actually_seen,
    l.lcl95,
    l.category,
    l.country,
    l.region,
    l.continent,
    g.geom
   FROM ((public.survey_geometries g
     JOIN public.estimate_factors f ON ((f.survey_geometry_id = g.id)))
     JOIN public.estimate_locator l ON ((l.input_zone_id = f.input_zone_id)));


--
-- Name: estimate_locator_areas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_locator_areas AS
 SELECT estimate_locator_with_geometry.input_zone_id,
    estimate_locator_with_geometry.analysis_name,
    estimate_locator_with_geometry.analysis_year,
    (sum(public.st_area((estimate_locator_with_geometry.geom)::public.geography, true)) / (1000000)::double precision) AS area_sqkm
   FROM public.estimate_locator_with_geometry
  GROUP BY estimate_locator_with_geometry.input_zone_id, estimate_locator_with_geometry.analysis_name, estimate_locator_with_geometry.analysis_year
  ORDER BY estimate_locator_with_geometry.input_zone_id, estimate_locator_with_geometry.analysis_name, estimate_locator_with_geometry.analysis_year;


--
-- Name: regional_range_table; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.regional_range_table AS
 SELECT sm.analysis_name,
    sm.analysis_year,
    r.region,
    m.country,
    sum(m.area_sqkm) AS range_area,
    sum(r.area_sqkm) AS regional_range,
    ((sum(m.area_sqkm) / sum(r.area_sqkm)) * (100)::double precision) AS percent_regional_range,
    sum(sm.area_sqkm) AS range_assessed,
    ((sum(sm.area_sqkm) / sum(m.area_sqkm)) * (100)::double precision) AS percent_range_assessed
   FROM (((( SELECT country_range_metrics.country,
            sum(country_range_metrics.area_sqkm) AS area_sqkm
           FROM public.country_range_metrics
          GROUP BY country_range_metrics.country) m
     JOIN public.country c ON (((c.cntryname)::text = (m.country)::text)))
     JOIN ( SELECT regional_range_metrics.region,
            sum(regional_range_metrics.area_sqkm) AS area_sqkm
           FROM public.regional_range_metrics
          GROUP BY regional_range_metrics.region) r ON (((r.region)::text = (c.region)::text)))
     JOIN ( SELECT survey_range_intersection_metrics.analysis_name,
            survey_range_intersection_metrics.analysis_year,
            survey_range_intersection_metrics.country,
            sum(survey_range_intersection_metrics.area_sqkm) AS area_sqkm
           FROM public.survey_range_intersection_metrics
          GROUP BY survey_range_intersection_metrics.analysis_name, survey_range_intersection_metrics.analysis_year, survey_range_intersection_metrics.country) sm ON (((sm.country)::text = (m.country)::text)))
  GROUP BY sm.analysis_name, sm.analysis_year, r.region, m.country
  ORDER BY sm.analysis_name, sm.analysis_year, r.region, m.country;


--
-- Name: estimate_factors_analyses_categorized_zones_for_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_factors_analyses_categorized_zones_for_add AS
 SELECT zone.analysis_name,
    zone.analysis_year,
    el.sort_key,
    el.population,
    zone.country,
    zone.site_name,
    zone.phenotype,
    zone.phenotype_basis,
    zone.stratum_name,
    zone.replacement_name,
    zone.population_variance,
        CASE
            WHEN ((zone.reason_change)::text = 'NC'::text) THEN '-'::character varying
            ELSE zone.reason_change
        END AS "ReasonForChange",
    zone.population_submission_id,
    zone.method_and_quality,
    zone."CATEGORY",
    zone."CYEAR",
    zone."ESTIMATE",
    ((1.96)::double precision * sqrt(zone.population_variance)) AS "CONFIDENCE",
    zone."GUESS_MIN",
    zone."GUESS_MAX",
    zone."CL95",
    zone."REFERENCE",
    round(log((((1)::double precision + ((zone."ESTIMATE")::double precision / ((((zone."ESTIMATE")::double precision + ((1.96)::double precision * sqrt(zone.population_variance))) + zone."GUESS_MAX") + (0.0001)::double precision))) / (a.area_sqkm / rm.range_area)))) AS "PFS",
    rm.range_area AS "RA",
    a.area_sqkm AS "CALC_SQKM",
    zone."AREA_SQKM",
        CASE
            WHEN (population_submissions.longitude < (0)::double precision) THEN (to_char(abs(population_submissions.longitude), '999D9'::text) || 'W'::text)
            WHEN (population_submissions.longitude = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs(population_submissions.longitude), '999D9'::text) || 'E'::text)
        END AS "LON",
        CASE
            WHEN (population_submissions.latitude < (0)::double precision) THEN (to_char(abs(population_submissions.latitude), '999D9'::text) || 'S'::text)
            WHEN (population_submissions.latitude = (0)::double precision) THEN '0.0'::text
            ELSE (to_char(abs(population_submissions.latitude), '999D9'::text) || 'N'::text)
        END AS "LAT"
   FROM (((((( SELECT e.analysis_name,
            e.analysis_year,
            e.estimate_type,
            e.country,
            e.site_name,
            e.stratum_name,
            e.phenotype,
            e.phenotype_basis,
            e.replacement_name,
            e.best_population_variance AS population_variance,
            e.population_confidence_interval,
            e.reason_change,
            e.population_submission_id,
            e.input_zone_id AS method_and_quality,
            e.category AS "CATEGORY",
            e.completion_year AS "CYEAR",
            e.best_estimate AS "ESTIMATE",
            e.population_lower_confidence_limit AS "GUESS_MIN",
            e.population_upper_confidence_limit AS "GUESS_MAX",
                CASE
                    WHEN (e.population_upper_confidence_limit IS NOT NULL) THEN
                    CASE
                        WHEN (e.estimate_type = 'O'::text) THEN (to_char((e.population_upper_confidence_limit - e.best_estimate), '999,999'::text) || '*'::text)
                        ELSE to_char((e.population_upper_confidence_limit - e.best_estimate), '999,999'::text)
                    END
                    WHEN (e.population_confidence_interval IS NOT NULL) THEN to_char(round(e.population_confidence_interval), '999,999'::text)
                    ELSE ''::text
                END AS "CL95",
            e.short_citation AS "REFERENCE",
            e.stratum_area AS "AREA_SQKM"
           FROM public.estimate_factors_analyses_categorized_for_add e
          WHERE (e.category <> 'C'::text)
        UNION
         SELECT e.analysis_name,
            e.analysis_year,
            e.estimate_type,
            e.country,
            e.site_name,
            e.stratum_name,
            e.phenotype,
            e.phenotype_basis,
            e.replacement_name,
            e.best_population_variance AS population_variance,
            e.population_confidence_interval,
            e.reason_change,
            e.population_submission_id,
            e.input_zone_id AS method_and_quality,
            e.category AS "CATEGORY",
            e.completion_year AS "CYEAR",
            e.best_estimate AS "ESTIMATE",
            ((e.population_lower_confidence_limit)::double precision + ((1.96)::double precision * sqrt(e.population_variance))) AS "GUESS_MIN",
            ((e.population_upper_confidence_limit)::double precision + ((1.96)::double precision * sqrt(e.population_variance))) AS "GUESS_MAX",
            ''::text AS "CL95",
            e.short_citation AS "REFERENCE",
            e.stratum_area AS "AREA_SQKM"
           FROM public.estimate_factors_analyses_categorized_for_add e
          WHERE (e.category = 'C'::text)) zone
     JOIN public.estimate_locator el ON (((zone.method_and_quality = el.input_zone_id) AND ((zone.analysis_name)::text = (el.analysis_name)::text) AND (zone.analysis_year = el.analysis_year))))
     JOIN public.estimate_locator_areas a ON (((el.input_zone_id = a.input_zone_id) AND ((el.analysis_name)::text = (a.analysis_name)::text) AND (el.analysis_year = a.analysis_year))))
     JOIN public.surveytypes t ON (((t.category)::text = zone."CATEGORY")))
     JOIN public.population_submissions ON ((zone.population_submission_id = population_submissions.id)))
     JOIN public.regional_range_table rm ON ((((zone.country)::text = (rm.country)::text) AND ((zone.analysis_name)::text = (rm.analysis_name)::text) AND (zone.analysis_year = rm.analysis_year))))
  ORDER BY el.sort_key, zone.site_name, zone.stratum_name;


--
-- Name: estimate_locator_with_geometry_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_locator_with_geometry_add AS
 SELECT g.id,
    l.estimate_type,
    l.input_zone_id,
    l.population_submission_id,
    l.site_name,
    l.stratum_name,
    l.stratum_area,
    l.completion_year,
    l.analysis_name,
    l.analysis_year,
    l.age,
    l.replacement_name,
    l.reason_change,
    l.citation,
    l.short_citation,
    l.best_estimate AS population_estimate,
    l.best_population_variance AS population_variance,
    l.population_standard_error,
    l.population_confidence_interval,
    l.population_lower_confidence_limit,
    l.population_upper_confidence_limit,
    l.quality_level,
    l.actually_seen,
    l.lcl95,
    l.category,
    l.country,
    l.region,
    l.continent,
    g.geom
   FROM ((public.survey_geometries g
     JOIN public.estimate_factors f ON ((f.survey_geometry_id = g.id)))
     JOIN public.estimate_factors_analyses_categorized_for_add l ON ((l.input_zone_id = f.input_zone_id)));


--
-- Name: estimate_locator_areas_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimate_locator_areas_add AS
 SELECT e.input_zone_id,
    e.analysis_name,
    e.analysis_year,
    (sum(public.st_area((e.geom)::public.geography, true)) / (1000000)::double precision) AS area_sqkm
   FROM public.estimate_locator_with_geometry_add e
  GROUP BY e.input_zone_id, e.analysis_name, e.analysis_year
  ORDER BY e.input_zone_id, e.analysis_name, e.analysis_year;


--
-- Name: estimates; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.estimates AS
 SELECT ('GT'::text || survey_ground_total_count_strata.id) AS input_zone_id,
    survey_ground_total_counts.population_submission_id,
    population_submissions.site_name,
    survey_ground_total_count_strata.stratum_name,
    survey_ground_total_count_strata.stratum_area,
    population_submissions.completion_year,
    population_submissions.short_citation,
    survey_ground_total_count_strata.population_estimate,
    survey_ground_total_count_strata.population_variance,
    survey_ground_total_count_strata.population_standard_error,
    survey_ground_total_count_strata.population_confidence_interval,
        CASE
            WHEN (survey_ground_total_count_strata.population_lower_confidence_limit IS NOT NULL) THEN (survey_ground_total_count_strata.population_lower_confidence_limit)::double precision
            WHEN (survey_ground_total_count_strata.population_confidence_interval < (survey_ground_total_count_strata.population_estimate)::double precision) THEN round(((survey_ground_total_count_strata.population_estimate)::double precision - survey_ground_total_count_strata.population_confidence_interval))
            ELSE (0)::double precision
        END AS cl95,
        CASE
            WHEN (survey_ground_total_count_strata.actually_seen IS NULL) THEN 0
            ELSE survey_ground_total_count_strata.actually_seen
        END AS actually_seen,
        CASE
            WHEN (population_submissions.completion_year <= 2003) THEN 'E'::text
            ELSE 'A'::text
        END AS category
   FROM ((public.survey_ground_total_count_strata
     JOIN public.survey_ground_total_counts ON ((survey_ground_total_counts.id = survey_ground_total_count_strata.survey_ground_total_count_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_ground_total_counts.population_submission_id)))
UNION
 SELECT ('DC'::text || survey_dung_count_line_transect_strata.id) AS input_zone_id,
    survey_dung_count_line_transects.population_submission_id,
    population_submissions.site_name,
    survey_dung_count_line_transect_strata.stratum_name,
    survey_dung_count_line_transect_strata.stratum_area,
    population_submissions.completion_year,
    population_submissions.short_citation,
    survey_dung_count_line_transect_strata.population_estimate,
    survey_dung_count_line_transect_strata.population_variance,
    survey_dung_count_line_transect_strata.population_standard_error,
    survey_dung_count_line_transect_strata.population_confidence_interval,
        CASE
            WHEN (survey_dung_count_line_transect_strata.population_lower_confidence_limit IS NOT NULL) THEN (survey_dung_count_line_transect_strata.population_lower_confidence_limit)::double precision
            WHEN (survey_dung_count_line_transect_strata.population_confidence_interval < (survey_dung_count_line_transect_strata.population_estimate)::double precision) THEN round(((survey_dung_count_line_transect_strata.population_estimate)::double precision - survey_dung_count_line_transect_strata.population_confidence_interval))
            ELSE (0)::double precision
        END AS cl95,
        CASE
            WHEN (survey_dung_count_line_transect_strata.actually_seen IS NULL) THEN 0
            ELSE survey_dung_count_line_transect_strata.actually_seen
        END AS actually_seen,
        CASE
            WHEN (population_submissions.completion_year <= 2003) THEN 'E'::text
            WHEN ((survey_dung_count_line_transect_strata.dung_decay_rate_measurement_site IS NOT NULL) AND ((survey_dung_count_line_transect_strata.dung_decay_rate_measurement_site)::text <> ''::text)) THEN 'B'::text
            ELSE 'C'::text
        END AS category
   FROM ((public.survey_dung_count_line_transect_strata
     JOIN public.survey_dung_count_line_transects ON ((survey_dung_count_line_transects.id = survey_dung_count_line_transect_strata.survey_dung_count_line_transect_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_dung_count_line_transects.population_submission_id)))
UNION
 SELECT ('AT'::text || survey_aerial_total_count_strata.id) AS input_zone_id,
    survey_aerial_total_counts.population_submission_id,
    population_submissions.site_name,
    survey_aerial_total_count_strata.stratum_name,
    survey_aerial_total_count_strata.stratum_area,
    population_submissions.completion_year,
    population_submissions.short_citation,
    survey_aerial_total_count_strata.population_estimate,
    survey_aerial_total_count_strata.population_variance,
    survey_aerial_total_count_strata.population_standard_error,
    survey_aerial_total_count_strata.population_confidence_interval,
        CASE
            WHEN (survey_aerial_total_count_strata.population_lower_confidence_limit IS NOT NULL) THEN (survey_aerial_total_count_strata.population_lower_confidence_limit)::double precision
            WHEN (survey_aerial_total_count_strata.population_confidence_interval < (survey_aerial_total_count_strata.population_estimate)::double precision) THEN round(((survey_aerial_total_count_strata.population_estimate)::double precision - survey_aerial_total_count_strata.population_confidence_interval))
            ELSE (0)::double precision
        END AS cl95,
    0 AS actually_seen,
        CASE
            WHEN (population_submissions.completion_year <= 2003) THEN 'E'::text
            ELSE 'A'::text
        END AS category
   FROM ((public.survey_aerial_total_count_strata
     JOIN public.survey_aerial_total_counts ON ((survey_aerial_total_counts.id = survey_aerial_total_count_strata.survey_aerial_total_count_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_aerial_total_counts.population_submission_id)))
UNION
 SELECT ('GS'::text || survey_ground_sample_count_strata.id) AS input_zone_id,
    survey_ground_sample_counts.population_submission_id,
    population_submissions.site_name,
    survey_ground_sample_count_strata.stratum_name,
    survey_ground_sample_count_strata.stratum_area,
    population_submissions.completion_year,
    population_submissions.short_citation,
    survey_ground_sample_count_strata.population_estimate,
    survey_ground_sample_count_strata.population_variance,
    survey_ground_sample_count_strata.population_standard_error,
    survey_ground_sample_count_strata.population_confidence_interval,
        CASE
            WHEN (survey_ground_sample_count_strata.population_lower_confidence_limit IS NOT NULL) THEN (survey_ground_sample_count_strata.population_lower_confidence_limit)::double precision
            WHEN (survey_ground_sample_count_strata.population_confidence_interval < (survey_ground_sample_count_strata.population_estimate)::double precision) THEN round(((survey_ground_sample_count_strata.population_estimate)::double precision - survey_ground_sample_count_strata.population_confidence_interval))
            ELSE (0)::double precision
        END AS cl95,
    0 AS actually_seen,
        CASE
            WHEN (population_submissions.completion_year <= 2003) THEN 'E'::text
            WHEN (
            CASE
                WHEN (survey_ground_sample_count_strata.population_lower_confidence_limit IS NOT NULL) THEN (survey_ground_sample_count_strata.population_lower_confidence_limit)::double precision
                WHEN (survey_ground_sample_count_strata.population_confidence_interval < (survey_ground_sample_count_strata.population_estimate)::double precision) THEN round(((survey_ground_sample_count_strata.population_estimate)::double precision - survey_ground_sample_count_strata.population_confidence_interval))
                ELSE NULL::double precision
            END IS NOT NULL) THEN 'B'::text
            ELSE 'D'::text
        END AS category
   FROM ((public.survey_ground_sample_count_strata
     JOIN public.survey_ground_sample_counts ON ((survey_ground_sample_counts.id = survey_ground_sample_count_strata.survey_ground_sample_count_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_ground_sample_counts.population_submission_id)))
UNION
 SELECT ('AS'::text || survey_aerial_sample_count_strata.id) AS input_zone_id,
    survey_aerial_sample_counts.population_submission_id,
    population_submissions.site_name,
    survey_aerial_sample_count_strata.stratum_name,
    survey_aerial_sample_count_strata.stratum_area,
    population_submissions.completion_year,
    population_submissions.short_citation,
    survey_aerial_sample_count_strata.population_estimate,
        CASE
            WHEN (survey_aerial_sample_count_strata.population_variance IS NOT NULL) THEN survey_aerial_sample_count_strata.population_variance
            WHEN (survey_aerial_sample_count_strata.population_standard_error IS NOT NULL) THEN (survey_aerial_sample_count_strata.population_standard_error ^ (2)::double precision)
            WHEN ((survey_aerial_sample_count_strata.population_confidence_interval IS NOT NULL) AND (survey_aerial_sample_count_strata.population_t IS NOT NULL)) THEN ((survey_aerial_sample_count_strata.population_confidence_interval / survey_aerial_sample_count_strata.population_t) ^ (2)::double precision)
            WHEN (survey_aerial_sample_count_strata.population_confidence_interval IS NOT NULL) THEN ((survey_aerial_sample_count_strata.population_confidence_interval / (1.96)::double precision) ^ (2)::double precision)
            ELSE NULL::double precision
        END AS population_variance,
    survey_aerial_sample_count_strata.population_standard_error,
        CASE
            WHEN (survey_aerial_sample_count_strata.population_confidence_interval IS NOT NULL) THEN survey_aerial_sample_count_strata.population_confidence_interval
            WHEN (survey_aerial_sample_count_strata.population_standard_error IS NOT NULL) THEN round((survey_aerial_sample_count_strata.population_standard_error * (1.96)::double precision))
            WHEN ((survey_aerial_sample_count_strata.population_standard_error IS NOT NULL) AND (survey_aerial_sample_count_strata.population_t IS NOT NULL)) THEN round((survey_aerial_sample_count_strata.population_standard_error * survey_aerial_sample_count_strata.population_t))
            WHEN (survey_aerial_sample_count_strata.population_variance IS NOT NULL) THEN round((sqrt(survey_aerial_sample_count_strata.population_variance) * (1.96)::double precision))
            ELSE NULL::double precision
        END AS population_confidence_interval,
        CASE
            WHEN (survey_aerial_sample_count_strata.population_lower_confidence_limit IS NOT NULL) THEN (survey_aerial_sample_count_strata.population_lower_confidence_limit)::double precision
            WHEN (survey_aerial_sample_count_strata.population_confidence_interval < (survey_aerial_sample_count_strata.population_estimate)::double precision) THEN round(((survey_aerial_sample_count_strata.population_estimate)::double precision - survey_aerial_sample_count_strata.population_confidence_interval))
            ELSE (0)::double precision
        END AS cl95,
    0 AS actually_seen,
        CASE
            WHEN (population_submissions.completion_year <= 2003) THEN 'E'::text
            WHEN (
            CASE
                WHEN (survey_aerial_sample_count_strata.population_lower_confidence_limit IS NOT NULL) THEN (survey_aerial_sample_count_strata.population_lower_confidence_limit)::double precision
                WHEN (
                CASE
                    WHEN (survey_aerial_sample_count_strata.population_confidence_interval IS NOT NULL) THEN survey_aerial_sample_count_strata.population_confidence_interval
                    WHEN (survey_aerial_sample_count_strata.population_standard_error IS NOT NULL) THEN round((survey_aerial_sample_count_strata.population_standard_error * (1.96)::double precision))
                    WHEN ((survey_aerial_sample_count_strata.population_standard_error IS NOT NULL) AND (survey_aerial_sample_count_strata.population_t IS NOT NULL)) THEN round((survey_aerial_sample_count_strata.population_standard_error * survey_aerial_sample_count_strata.population_t))
                    WHEN (survey_aerial_sample_count_strata.population_variance IS NOT NULL) THEN round((sqrt(survey_aerial_sample_count_strata.population_variance) * (1.96)::double precision))
                    ELSE NULL::double precision
                END < (survey_aerial_sample_count_strata.population_estimate)::double precision) THEN round(((survey_aerial_sample_count_strata.population_estimate)::double precision -
                CASE
                    WHEN (survey_aerial_sample_count_strata.population_confidence_interval IS NOT NULL) THEN survey_aerial_sample_count_strata.population_confidence_interval
                    WHEN (survey_aerial_sample_count_strata.population_standard_error IS NOT NULL) THEN round((survey_aerial_sample_count_strata.population_standard_error * (1.96)::double precision))
                    WHEN ((survey_aerial_sample_count_strata.population_standard_error IS NOT NULL) AND (survey_aerial_sample_count_strata.population_t IS NOT NULL)) THEN round((survey_aerial_sample_count_strata.population_standard_error * survey_aerial_sample_count_strata.population_t))
                    WHEN (survey_aerial_sample_count_strata.population_variance IS NOT NULL) THEN round((sqrt(survey_aerial_sample_count_strata.population_variance) * (1.96)::double precision))
                    ELSE NULL::double precision
                END))
                ELSE NULL::double precision
            END IS NOT NULL) THEN 'B'::text
            ELSE 'D'::text
        END AS category
   FROM ((public.survey_aerial_sample_count_strata
     JOIN public.survey_aerial_sample_counts ON ((survey_aerial_sample_counts.id = survey_aerial_sample_count_strata.survey_aerial_sample_count_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_aerial_sample_counts.population_submission_id)))
UNION
 SELECT ('GD'::text || survey_faecal_dna_strata.id) AS input_zone_id,
    survey_faecal_dnas.population_submission_id,
    population_submissions.site_name,
    survey_faecal_dna_strata.stratum_name,
    survey_faecal_dna_strata.stratum_area,
    population_submissions.completion_year,
    population_submissions.short_citation,
    survey_faecal_dna_strata.population_estimate,
    survey_faecal_dna_strata.population_variance,
    survey_faecal_dna_strata.population_standard_error,
    survey_faecal_dna_strata.population_confidence_interval,
        CASE
            WHEN (survey_faecal_dna_strata.population_lower_confidence_limit IS NOT NULL) THEN (survey_faecal_dna_strata.population_lower_confidence_limit)::double precision
            WHEN (survey_faecal_dna_strata.population_confidence_interval < (survey_faecal_dna_strata.population_estimate)::double precision) THEN round(((survey_faecal_dna_strata.population_estimate)::double precision - survey_faecal_dna_strata.population_confidence_interval))
            ELSE (0)::double precision
        END AS cl95,
    0 AS actually_seen,
        CASE
            WHEN (population_submissions.completion_year <= 2003) THEN 'E'::text
            ELSE 'C'::text
        END AS category
   FROM ((public.survey_faecal_dna_strata
     JOIN public.survey_faecal_dnas ON ((survey_faecal_dnas.id = survey_faecal_dna_strata.survey_faecal_dna_id)))
     JOIN public.population_submissions ON ((population_submissions.id = survey_faecal_dnas.population_submission_id)))
UNION
 SELECT ('IR'::text || survey_individual_registrations.id) AS input_zone_id,
    survey_individual_registrations.population_submission_id,
    population_submissions.site_name,
    population_submissions.site_name AS stratum_name,
    population_submissions.area AS stratum_area,
    population_submissions.completion_year,
    population_submissions.short_citation,
    survey_individual_registrations.population_estimate,
    0 AS population_variance,
    0 AS population_standard_error,
    0 AS population_confidence_interval,
    0 AS cl95,
    survey_individual_registrations.population_estimate AS actually_seen,
        CASE
            WHEN (population_submissions.completion_year <= 2003) THEN 'E'::text
            ELSE 'A'::text
        END AS category
   FROM (public.survey_individual_registrations
     JOIN public.population_submissions ON ((population_submissions.id = survey_individual_registrations.population_submission_id)))
UNION
 SELECT ('O'::text || survey_others.id) AS input_zone_id,
    survey_others.population_submission_id,
    population_submissions.site_name,
    population_submissions.site_name AS stratum_name,
    population_submissions.area AS stratum_area,
    population_submissions.completion_year,
    population_submissions.short_citation,
    ((survey_others.population_estimate_min + survey_others.population_estimate_max) / 2) AS population_estimate,
    0 AS population_variance,
    0 AS population_standard_error,
    0 AS population_confidence_interval,
    0 AS cl95,
    0 AS actually_seen,
    'E'::text AS category
   FROM (public.survey_others
     JOIN public.population_submissions ON ((population_submissions.id = survey_others.population_submission_id)));


--
-- Name: ioc_add_new_continents; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ioc_add_new_continents AS
 SELECT a.analysis_name,
    a.analysis_year,
    new_1.continent,
    new_1.reason_change,
    sum(new_1.estimate) AS estimate,
    sum(new_1.population_variance) AS population_variance,
    sum(new_1.guess_min) AS guess_min,
    sum(new_1.guess_max) AS guess_max
   FROM (public.analyses a
     JOIN ( SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            sum(e.population_variance) AS population_variance,
            sum(e.population_lower_confidence_limit) AS guess_min,
            sum(e.population_upper_confidence_limit) AS guess_max
           FROM public.ioc_add_new_base e
          WHERE (e.category <> 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.phenotype, e.phenotype_basis, e.reason_change
        UNION
         SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            0 AS population_variance,
            ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_min,
            ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_max
           FROM public.ioc_add_new_base e
          WHERE (e.category = 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.phenotype, e.phenotype_basis, e.reason_change) new_1 ON ((((new_1.analysis_name)::text = (a.analysis_name)::text) AND (new_1.analysis_year = a.analysis_year))))
  GROUP BY a.analysis_name, a.analysis_year, new_1.continent, new_1.reason_change;


--
-- Name: ioc_add_replaced_continents; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ioc_add_replaced_continents AS
 SELECT a.analysis_name,
    a.analysis_year,
    old_1.continent,
    old_1.reason_change,
    (('-1'::integer)::numeric * sum(old_1.estimate)) AS estimate,
    sum(old_1.population_variance) AS population_variance,
    (('-1'::integer)::double precision * sum(old_1.guess_min)) AS guess_min,
    (('-1'::integer)::double precision * sum(old_1.guess_max)) AS guess_max
   FROM (public.analyses a
     JOIN ( SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            sum(e.population_variance) AS population_variance,
            sum(e.population_lower_confidence_limit) AS guess_min,
            sum(e.population_upper_confidence_limit) AS guess_max
           FROM public.ioc_add_replaced_base e
          WHERE (e.category <> 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.phenotype, e.phenotype_basis, e.reason_change
        UNION
         SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            0 AS population_variance,
            ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_min,
            ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_max
           FROM public.ioc_add_replaced_base e
          WHERE (e.category = 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.phenotype, e.phenotype_basis, e.reason_change) old_1 ON ((((old_1.analysis_name)::text = (a.analysis_name)::text) AND (old_1.analysis_year = a.comparison_year))))
  GROUP BY a.analysis_name, a.analysis_year, old_1.continent, old_1.reason_change;


--
-- Name: i_add_sums_continent_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_add_sums_continent_category_reason AS
 SELECT x.analysis_name,
    x.analysis_year,
    x.continent,
    x.reason_change,
    sum(x.estimate) AS estimate,
    ((1.96)::double precision * sqrt(sum(x.population_variance))) AS confidence,
    sum(x.guess_min) AS guess_min,
    sum(x.guess_max) AS guess_max,
    sum(x.population_variance) AS meta_population_variance
   FROM ( SELECT i.analysis_name,
            i.analysis_year,
            i.continent,
            i.reason_change,
            i.estimate,
            i.population_variance,
            i.guess_min,
            i.guess_max,
            c.code,
            c.name,
            c.display_order
           FROM (public.ioc_add_new_continents i
             JOIN public.cause_of_changes c ON (((i.reason_change)::text = (c.code)::text)))
        UNION ALL
         SELECT i.analysis_name,
            i.analysis_year,
            i.continent,
            i.reason_change,
            i.estimate,
            i.population_variance,
            i.guess_min,
            i.guess_max,
            c.code,
            c.name,
            c.display_order
           FROM (public.ioc_add_replaced_continents i
             JOIN public.cause_of_changes c ON (((i.reason_change)::text = (c.code)::text)))) x
  GROUP BY x.analysis_name, x.analysis_year, x.continent, x.reason_change
  ORDER BY x.analysis_name, x.analysis_year, x.continent, x.reason_change;


--
-- Name: ioc_add_new_countries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ioc_add_new_countries AS
 SELECT a.analysis_name,
    a.analysis_year,
    new_1.continent,
    new_1.region,
    new_1.country,
    new_1.reason_change,
    sum(new_1.estimate) AS estimate,
    sum(new_1.population_variance) AS population_variance,
    sum(new_1.guess_min) AS guess_min,
    sum(new_1.guess_max) AS guess_max
   FROM (public.analyses a
     JOIN ( SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.country,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            sum(e.population_variance) AS population_variance,
            sum(e.population_lower_confidence_limit) AS guess_min,
            sum(e.population_upper_confidence_limit) AS guess_max
           FROM public.ioc_add_new_base e
          WHERE (e.category <> 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.phenotype, e.phenotype_basis, e.reason_change
        UNION
         SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.country,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            0 AS population_variance,
            ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_min,
            ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_max
           FROM public.ioc_add_new_base e
          WHERE (e.category = 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.phenotype, e.phenotype_basis, e.reason_change) new_1 ON ((((new_1.analysis_name)::text = (a.analysis_name)::text) AND (new_1.analysis_year = a.analysis_year))))
  GROUP BY a.analysis_name, a.analysis_year, new_1.continent, new_1.region, new_1.country, new_1.reason_change;


--
-- Name: ioc_add_replaced_countries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ioc_add_replaced_countries AS
 SELECT a.analysis_name,
    a.analysis_year,
    old_1.continent,
    old_1.region,
    old_1.country,
    old_1.reason_change,
    (('-1'::integer)::numeric * sum(old_1.estimate)) AS estimate,
    sum(old_1.population_variance) AS population_variance,
    (('-1'::integer)::double precision * sum(old_1.guess_min)) AS guess_min,
    (('-1'::integer)::double precision * sum(old_1.guess_max)) AS guess_max
   FROM (public.analyses a
     JOIN ( SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.country,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            sum(e.population_variance) AS population_variance,
            sum(e.population_lower_confidence_limit) AS guess_min,
            sum(e.population_upper_confidence_limit) AS guess_max
           FROM public.ioc_add_replaced_base e
          WHERE (e.category <> 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.phenotype, e.phenotype_basis, e.reason_change
        UNION
         SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.country,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            0 AS population_variance,
            ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_min,
            ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_max
           FROM public.ioc_add_replaced_base e
          WHERE (e.category = 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.phenotype, e.phenotype_basis, e.reason_change) old_1 ON ((((old_1.analysis_name)::text = (a.analysis_name)::text) AND (old_1.analysis_year = a.comparison_year))))
  GROUP BY a.analysis_name, a.analysis_year, old_1.continent, old_1.region, old_1.country, old_1.reason_change;


--
-- Name: i_add_sums_country_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_add_sums_country_category_reason AS
 SELECT x.analysis_name,
    x.analysis_year,
    x.continent,
    x.region,
    x.country,
    x.reason_change,
    sum(x.estimate) AS estimate,
    ((1.96)::double precision * sqrt(sum(x.population_variance))) AS confidence,
    sum(x.guess_min) AS guess_min,
    sum(x.guess_max) AS guess_max,
    sum(x.population_variance) AS meta_population_variance
   FROM ( SELECT i.analysis_name,
            i.analysis_year,
            i.continent,
            i.region,
            i.country,
            i.reason_change,
            i.estimate,
            i.population_variance,
            i.guess_min,
            i.guess_max,
            c.code,
            c.name,
            c.display_order
           FROM (public.ioc_add_new_countries i
             JOIN public.cause_of_changes c ON (((i.reason_change)::text = (c.code)::text)))
        UNION ALL
         SELECT i.analysis_name,
            i.analysis_year,
            i.continent,
            i.region,
            i.country,
            i.reason_change,
            i.estimate,
            i.population_variance,
            i.guess_min,
            i.guess_max,
            c.code,
            c.name,
            c.display_order
           FROM (public.ioc_add_replaced_countries i
             JOIN public.cause_of_changes c ON (((i.reason_change)::text = (c.code)::text)))) x
  GROUP BY x.analysis_name, x.analysis_year, x.continent, x.region, x.country, x.reason_change
  ORDER BY x.analysis_name, x.analysis_year, x.continent, x.region, x.country, x.reason_change;


--
-- Name: ioc_add_new_regions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ioc_add_new_regions AS
 SELECT a.analysis_name,
    a.analysis_year,
    new_1.continent,
    new_1.region,
    new_1.reason_change,
    sum(new_1.estimate) AS estimate,
    sum(new_1.population_variance) AS population_variance,
    sum(new_1.guess_min) AS guess_min,
    sum(new_1.guess_max) AS guess_max
   FROM (public.analyses a
     JOIN ( SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            sum(e.population_variance) AS population_variance,
            sum(e.population_lower_confidence_limit) AS guess_min,
            sum(e.population_upper_confidence_limit) AS guess_max
           FROM public.ioc_add_new_base e
          WHERE (e.category <> 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.phenotype, e.phenotype_basis, e.reason_change
        UNION
         SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            0 AS population_variance,
            ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_min,
            ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_max
           FROM public.ioc_add_new_base e
          WHERE (e.category = 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.phenotype, e.phenotype_basis, e.reason_change) new_1 ON ((((new_1.analysis_name)::text = (a.analysis_name)::text) AND (new_1.analysis_year = a.analysis_year))))
  GROUP BY a.analysis_name, a.analysis_year, new_1.continent, new_1.region, new_1.reason_change;


--
-- Name: ioc_add_replaced_regions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ioc_add_replaced_regions AS
 SELECT a.analysis_name,
    a.analysis_year,
    old_1.continent,
    old_1.region,
    old_1.reason_change,
    (('-1'::integer)::numeric * sum(old_1.estimate)) AS estimate,
    sum(old_1.population_variance) AS population_variance,
    (('-1'::integer)::double precision * sum(old_1.guess_min)) AS guess_min,
    (('-1'::integer)::double precision * sum(old_1.guess_max)) AS guess_max
   FROM (public.analyses a
     JOIN ( SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            sum(e.population_variance) AS population_variance,
            sum(e.population_lower_confidence_limit) AS guess_min,
            sum(e.population_upper_confidence_limit) AS guess_max
           FROM public.ioc_add_replaced_base e
          WHERE (e.category <> 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.phenotype, e.phenotype_basis, e.reason_change
        UNION
         SELECT e.analysis_name,
            e.analysis_year,
            e.continent,
            e.region,
            e.phenotype,
            e.phenotype_basis,
            e.reason_change,
            sum(e.population_estimate) AS estimate,
            0 AS population_variance,
            ((sum(e.population_lower_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_min,
            ((sum(e.population_upper_confidence_limit))::double precision + ((1.96)::double precision * sqrt(sum(e.population_variance)))) AS guess_max
           FROM public.ioc_add_replaced_base e
          WHERE (e.category = 'C'::text)
          GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.phenotype, e.phenotype_basis, e.reason_change) old_1 ON ((((old_1.analysis_name)::text = (a.analysis_name)::text) AND (old_1.analysis_year = a.comparison_year))))
  GROUP BY a.analysis_name, a.analysis_year, old_1.continent, old_1.region, old_1.reason_change;


--
-- Name: i_add_sums_region_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_add_sums_region_category_reason AS
 SELECT x.analysis_name,
    x.analysis_year,
    x.continent,
    x.region,
    x.reason_change,
    sum(x.estimate) AS estimate,
    ((1.96)::double precision * sqrt(sum(x.population_variance))) AS confidence,
    sum(x.guess_min) AS guess_min,
    sum(x.guess_max) AS guess_max,
    sum(x.population_variance) AS meta_population_variance
   FROM ( SELECT i.analysis_name,
            i.analysis_year,
            i.continent,
            i.region,
            i.reason_change,
            i.estimate,
            i.population_variance,
            i.guess_min,
            i.guess_max,
            c.code,
            c.name,
            c.display_order
           FROM (public.ioc_add_new_regions i
             JOIN public.cause_of_changes c ON (((i.reason_change)::text = (c.code)::text)))
        UNION ALL
         SELECT i.analysis_name,
            i.analysis_year,
            i.continent,
            i.region,
            i.reason_change,
            i.estimate,
            i.population_variance,
            i.guess_min,
            i.guess_max,
            c.code,
            c.name,
            c.display_order
           FROM (public.ioc_add_replaced_regions i
             JOIN public.cause_of_changes c ON (((i.reason_change)::text = (c.code)::text)))) x
  GROUP BY x.analysis_name, x.analysis_year, x.continent, x.region, x.reason_change
  ORDER BY x.analysis_name, x.analysis_year, x.continent, x.region, x.reason_change;


--
-- Name: i_add_totals_continent_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_add_totals_continent_category_reason AS
 SELECT add_sums_continent_category_reason.analysis_name,
    add_sums_continent_category_reason.analysis_year,
    add_sums_continent_category_reason.continent,
    sum(add_sums_continent_category_reason.estimate) AS estimate,
    ((1.96)::double precision * sqrt(sum(add_sums_continent_category_reason.meta_population_variance))) AS confidence,
    sum(add_sums_continent_category_reason.guess_min) AS guess_min,
    sum(add_sums_continent_category_reason.guess_max) AS guess_max
   FROM public.add_sums_continent_category_reason
  GROUP BY add_sums_continent_category_reason.analysis_name, add_sums_continent_category_reason.analysis_year, add_sums_continent_category_reason.continent
  ORDER BY add_sums_continent_category_reason.analysis_name, add_sums_continent_category_reason.analysis_year, add_sums_continent_category_reason.continent;


--
-- Name: i_add_totals_country_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_add_totals_country_category_reason AS
 SELECT add_sums_country_category_reason.analysis_name,
    add_sums_country_category_reason.analysis_year,
    add_sums_country_category_reason.continent,
    add_sums_country_category_reason.region,
    add_sums_country_category_reason.country,
    sum(add_sums_country_category_reason.estimate) AS estimate,
    ((1.96)::double precision * sqrt(sum(add_sums_country_category_reason.meta_population_variance))) AS confidence,
    sum(add_sums_country_category_reason.guess_min) AS guess_min,
    sum(add_sums_country_category_reason.guess_max) AS guess_max
   FROM public.add_sums_country_category_reason
  GROUP BY add_sums_country_category_reason.analysis_name, add_sums_country_category_reason.analysis_year, add_sums_country_category_reason.continent, add_sums_country_category_reason.region, add_sums_country_category_reason.country
  ORDER BY add_sums_country_category_reason.analysis_name, add_sums_country_category_reason.analysis_year, add_sums_country_category_reason.continent, add_sums_country_category_reason.region, add_sums_country_category_reason.country;


--
-- Name: i_add_totals_region_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_add_totals_region_category_reason AS
 SELECT add_sums_region_category_reason.analysis_name,
    add_sums_region_category_reason.analysis_year,
    add_sums_region_category_reason.continent,
    add_sums_region_category_reason.region,
    sum(add_sums_region_category_reason.estimate) AS estimate,
    ((1.96)::double precision * sqrt(sum(add_sums_region_category_reason.meta_population_variance))) AS confidence,
    sum(add_sums_region_category_reason.guess_min) AS guess_min,
    sum(add_sums_region_category_reason.guess_max) AS guess_max
   FROM public.add_sums_region_category_reason
  GROUP BY add_sums_region_category_reason.analysis_name, add_sums_region_category_reason.analysis_year, add_sums_region_category_reason.continent, add_sums_region_category_reason.region
  ORDER BY add_sums_region_category_reason.analysis_name, add_sums_region_category_reason.analysis_year, add_sums_region_category_reason.continent, add_sums_region_category_reason.region;


--
-- Name: i_dpps_sums_continent_category; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_dpps_sums_continent_category AS
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'A'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.category,
        CASE
            WHEN ((sum(e.actually_seen))::double precision > ((sum(e.population_estimate))::double precision - (sqrt(sum(e.population_variance)) * (1.96)::double precision))) THEN (sum(e.actually_seen))::double precision
            ELSE round(((sum(e.population_estimate))::double precision - (sqrt(sum(e.population_variance)) * (1.96)::double precision)))
        END AS definite,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS probable,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'B'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.category,
    round(sum(d.definite)) AS definite,
    round((sum(d.probable) - sum(d.definite))) AS probable,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'C'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'D'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'E'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.category
  ORDER BY 1, 2, 3, 4;


--
-- Name: i_dpps_sums_continent_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_dpps_sums_continent_category_reason AS
 SELECT s.analysis_name,
    s.analysis_year,
    s.continent,
    s.category,
    s.reason_change,
    s.definite,
    s.probable,
    s.possible,
    s.speculative
   FROM ( SELECT d.analysis_name,
            d.analysis_year,
            e.continent,
            d.category,
            e.reason_change,
            sum(d.definite) AS definite,
            sum(d.probable) AS probable,
            sum(d.possible) AS possible,
            sum(d.speculative) AS speculative
           FROM ((public.analyses y
             JOIN public.estimate_locator e ON ((((e.analysis_name)::text = (y.analysis_name)::text) AND (e.analysis_year = y.analysis_year) AND ((e.reason_change)::text <> '-'::text))))
             JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
          GROUP BY d.analysis_name, d.analysis_year, e.continent, d.category, e.reason_change
        UNION
         SELECT s_1.analysis_name,
            s_1.analysis_year,
            s_1.continent,
            s_1.category,
            s_1.reason_change,
            sum((('-1'::integer)::double precision * s_1.definite)) AS definite,
            sum((('-1'::integer)::double precision * s_1.probable)) AS probable,
            sum((('-1'::integer)::double precision * s_1.possible)) AS possible,
            sum((('-1'::integer)::double precision * s_1.speculative)) AS speculative
           FROM ( SELECT DISTINCT d.analysis_name,
                    e.analysis_year,
                    e.continent,
                    d.category,
                    c.reason_change,
                    d.definite,
                    d.probable,
                    d.possible,
                    d.speculative
                   FROM (((public.analyses y
                     JOIN public.estimate_locator e ON ((((e.analysis_name)::text = (y.analysis_name)::text) AND (e.analysis_year = y.analysis_year) AND ((e.reason_change)::text <> '-'::text))))
                     JOIN public.changed_strata c ON (((e.input_zone_id = c.new_stratum) AND ((e.analysis_name)::text = (c.analysis_name)::text))))
                     JOIN public.estimate_dpps d ON (((d.input_zone_id = c.replaced_stratum) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (d.analysis_year = y.comparison_year))))) s_1
          GROUP BY s_1.analysis_name, s_1.analysis_year, s_1.continent, s_1.category, s_1.reason_change) s
  ORDER BY s.analysis_name, s.analysis_year, s.continent, s.category, s.reason_change;


--
-- Name: i_dpps_sums_country_category; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_dpps_sums_country_category AS
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'A'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.category,
        CASE
            WHEN ((sum(e.actually_seen))::double precision > ((sum(e.population_estimate))::double precision - (sqrt(sum(e.population_variance)) * (1.96)::double precision))) THEN (sum(e.actually_seen))::double precision
            ELSE round(((sum(e.population_estimate))::double precision - (sqrt(sum(e.population_variance)) * (1.96)::double precision)))
        END AS definite,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS probable,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'B'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.category,
    round(sum(d.definite)) AS definite,
    round((sum(d.probable) - sum(d.definite))) AS probable,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'C'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'D'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'E'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, e.category
  ORDER BY 1, 2, 3, 4, 5, 6;


--
-- Name: i_dpps_sums_country_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_dpps_sums_country_category_reason AS
 SELECT s.analysis_name,
    s.analysis_year,
    s.continent,
    s.region,
    s.country,
    s.category,
    s.reason_change,
    s.definite,
    s.probable,
    s.possible,
    s.speculative
   FROM ( SELECT d.analysis_name,
            d.analysis_year,
            e.continent,
            e.region,
            e.country,
            d.category,
            e.reason_change,
            sum(d.definite) AS definite,
            sum(d.probable) AS probable,
            sum(d.possible) AS possible,
            sum(d.speculative) AS speculative
           FROM ((public.analyses y
             JOIN public.estimate_locator e ON ((((e.analysis_name)::text = (y.analysis_name)::text) AND (e.analysis_year = y.analysis_year) AND ((e.reason_change)::text <> '-'::text))))
             JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
          GROUP BY d.analysis_name, d.analysis_year, e.continent, e.region, e.country, d.category, e.reason_change
        UNION
         SELECT s_1.analysis_name,
            s_1.analysis_year,
            s_1.continent,
            s_1.region,
            s_1.country,
            s_1.category,
            s_1.reason_change,
            sum((('-1'::integer)::double precision * s_1.definite)) AS definite,
            sum((('-1'::integer)::double precision * s_1.probable)) AS probable,
            sum((('-1'::integer)::double precision * s_1.possible)) AS possible,
            sum((('-1'::integer)::double precision * s_1.speculative)) AS speculative
           FROM ( SELECT DISTINCT d.analysis_name,
                    e.analysis_year,
                    e.continent,
                    e.region,
                    e.country,
                    d.category,
                    c.reason_change,
                    d.definite,
                    d.probable,
                    d.possible,
                    d.speculative
                   FROM (((public.analyses y
                     JOIN public.estimate_locator e ON ((((e.analysis_name)::text = (y.analysis_name)::text) AND (e.analysis_year = y.analysis_year) AND ((e.reason_change)::text <> '-'::text))))
                     JOIN public.changed_strata c ON (((e.input_zone_id = c.new_stratum) AND ((e.analysis_name)::text = (c.analysis_name)::text))))
                     JOIN public.estimate_dpps d ON (((d.input_zone_id = c.replaced_stratum) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (d.analysis_year = y.comparison_year))))) s_1
          GROUP BY s_1.analysis_name, s_1.analysis_year, s_1.continent, s_1.region, s_1.country, s_1.category, s_1.reason_change) s
  ORDER BY s.analysis_name, s.analysis_year, s.continent, s.region, s.country, s.category, s.reason_change;


--
-- Name: i_dpps_sums_region_category; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_dpps_sums_region_category AS
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'A'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.category,
        CASE
            WHEN ((sum(e.actually_seen))::double precision > ((sum(e.population_estimate))::double precision - (sqrt(sum(e.population_variance)) * (1.96)::double precision))) THEN (sum(e.actually_seen))::double precision
            ELSE round(((sum(e.population_estimate))::double precision - (sqrt(sum(e.population_variance)) * (1.96)::double precision)))
        END AS definite,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS probable,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'B'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.category,
    round(sum(d.definite)) AS definite,
    round((sum(d.probable) - sum(d.definite))) AS probable,
    round((sqrt(sum(e.population_variance)) * (1.96)::double precision)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'C'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'D'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.category
UNION
 SELECT e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.category,
    round(sum(d.definite)) AS definite,
    round(sum(d.probable)) AS probable,
    round(sum(d.possible)) AS possible,
    round(sum(d.speculative)) AS speculative
   FROM (public.estimate_locator e
     JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
  WHERE (e.category = 'E'::text)
  GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.category
  ORDER BY 1, 2, 3, 4, 5;


--
-- Name: i_dpps_sums_region_category_reason; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.i_dpps_sums_region_category_reason AS
 SELECT s.analysis_name,
    s.analysis_year,
    s.continent,
    s.region,
    s.category,
    s.reason_change,
    s.definite,
    s.probable,
    s.possible,
    s.speculative
   FROM ( SELECT d.analysis_name,
            d.analysis_year,
            e.continent,
            e.region,
            d.category,
            e.reason_change,
            sum(d.definite) AS definite,
            sum(d.probable) AS probable,
            sum(d.possible) AS possible,
            sum(d.speculative) AS speculative
           FROM ((public.analyses y
             JOIN public.estimate_locator e ON ((((e.analysis_name)::text = (y.analysis_name)::text) AND (e.analysis_year = y.analysis_year) AND ((e.reason_change)::text <> '-'::text))))
             JOIN public.estimate_dpps d ON (((e.input_zone_id = d.input_zone_id) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (e.analysis_year = d.analysis_year))))
          GROUP BY d.analysis_name, d.analysis_year, e.continent, e.region, d.category, e.reason_change
        UNION
         SELECT s_1.analysis_name,
            s_1.analysis_year,
            s_1.continent,
            s_1.region,
            s_1.category,
            s_1.reason_change,
            sum((('-1'::integer)::double precision * s_1.definite)) AS definite,
            sum((('-1'::integer)::double precision * s_1.probable)) AS probable,
            sum((('-1'::integer)::double precision * s_1.possible)) AS possible,
            sum((('-1'::integer)::double precision * s_1.speculative)) AS speculative
           FROM ( SELECT DISTINCT d.analysis_name,
                    e.analysis_year,
                    e.continent,
                    e.region,
                    d.category,
                    c.reason_change,
                    d.definite,
                    d.probable,
                    d.possible,
                    d.speculative
                   FROM (((public.analyses y
                     JOIN public.estimate_locator e ON ((((e.analysis_name)::text = (y.analysis_name)::text) AND (e.analysis_year = y.analysis_year) AND ((e.reason_change)::text <> '-'::text))))
                     JOIN public.changed_strata c ON (((e.input_zone_id = c.new_stratum) AND ((e.analysis_name)::text = (c.analysis_name)::text))))
                     JOIN public.estimate_dpps d ON (((d.input_zone_id = c.replaced_stratum) AND ((e.analysis_name)::text = (d.analysis_name)::text) AND (d.analysis_year = y.comparison_year))))) s_1
          GROUP BY s_1.analysis_name, s_1.analysis_year, s_1.continent, s_1.region, s_1.category, s_1.reason_change) s
  ORDER BY s.analysis_name, s.analysis_year, s.continent, s.region, s.category, s.reason_change;


--
-- Name: input_zone_export; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.input_zone_export AS
 SELECT l.analysis_name AS analysis,
    l.analysis_year AS ayear,
    l.continent,
    l.region,
    l.country,
    l.replacement_name AS inpzone,
    l.site_name AS site,
    l.stratum_name AS stratum,
    l.input_zone_id AS strcode,
    l.estimate_type AS est_type,
    l.category,
    l.completion_year AS year,
    l.reason_change AS rc,
    l.citation AS full_cit,
    l.short_citation AS short_cit,
    l.population_estimate AS estimate,
    l.population_variance AS variance,
    l.population_standard_error AS std_err,
    l.population_confidence_interval AS ci,
    l.population_lower_confidence_limit AS lcl,
    l.population_upper_confidence_limit AS ucl,
    l.lcl95,
    l.quality_level AS quality,
    l.actually_seen AS seen,
    l.stratum_area AS area_rep,
    (public.st_area((g.geom)::public.geography, true) / (1000000)::double precision) AS area_calc,
    g.id AS sgid
   FROM ((public.estimate_locator l
     JOIN public.estimate_factors f ON ((l.input_zone_id = f.input_zone_id)))
     JOIN public.survey_geometries g ON ((f.survey_geometry_id = g.id)))
  ORDER BY l.analysis_name, l.analysis_year, l.continent, l.region, l.country, l.replacement_name, l.site_name, l.stratum_name;


--
-- Name: input_zones; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.input_zones AS
 WITH aggregate_data AS (
         SELECT btrim((e.replacement_name)::text) AS name,
            e.analysis_year,
            e.analysis_name,
            sum(e.population_estimate) AS estimate,
            sum(e.stratum_area) AS area,
            public.st_multi(public.st_collect(public.st_setsrid(sg.geom, 4326))) AS geom,
            LEAST((5)::double precision, GREATEST((1)::double precision, round(log((((((sum(ed.definite) + sum(ed.probable)) + (0.001)::double precision) / ((((sum(ed.definite) + sum(ed.probable)) + sum(ed.possible)) + sum(ed.speculative)) + (0.001)::double precision)) + (1)::double precision) / (sum(ela.area_sqkm) / rrt.range_area)))))) AS pfs
           FROM (((((public.estimate_locator e
             JOIN public.estimate_locator_areas ela ON (((e.input_zone_id = ela.input_zone_id) AND ((e.analysis_name)::text = (ela.analysis_name)::text) AND (e.analysis_year = ela.analysis_year))))
             JOIN public.estimate_factors ef ON ((e.input_zone_id = ef.input_zone_id)))
             JOIN public.survey_geometries sg ON ((ef.survey_geometry_id = sg.id)))
             JOIN public.estimate_dpps ed ON (((e.input_zone_id = ed.input_zone_id) AND ((e.analysis_name)::text = (ed.analysis_name)::text) AND (e.analysis_year = ed.analysis_year))))
             JOIN public.regional_range_table rrt ON ((((e.country)::text = (rrt.country)::text) AND ((e.analysis_name)::text = (rrt.analysis_name)::text) AND (e.analysis_year = rrt.analysis_year))))
          GROUP BY (btrim((e.replacement_name)::text)), e.analysis_year, e.analysis_name, rrt.range_area
        ), iz_data AS (
         SELECT DISTINCT ON ((btrim((e.replacement_name)::text)), e.analysis_year, e.analysis_name) btrim((e.replacement_name)::text) AS name,
            e.analysis_year,
            e.analysis_name,
            e.population_submission_id AS population_id,
                CASE
                    WHEN ((e.reason_change)::text = 'NC'::text) THEN '-'::character varying
                    ELSE e.reason_change
                END AS cause_of_change,
            e.estimate_type AS survey_type,
            e.category AS survey_reliability,
            e.completion_year AS survey_year,
            ad.estimate AS population_estimate,
                CASE
                    WHEN (e.population_upper_confidence_limit IS NOT NULL) THEN
                    CASE
                        WHEN (e.estimate_type = 'O'::text) THEN (to_char((e.population_upper_confidence_limit - e.population_estimate), '999,999'::text) || '*'::text)
                        ELSE to_char((e.population_upper_confidence_limit - e.population_estimate), '999,999'::text)
                    END
                    WHEN (e.population_confidence_interval IS NOT NULL) THEN to_char(round(e.population_confidence_interval), '999,999'::text)
                    ELSE NULL::text
                END AS percent_cl,
            e.short_citation AS source,
            ad.pfs,
            ad.area,
                CASE
                    WHEN (ps.longitude < (0)::double precision) THEN (to_char(abs(ps.longitude), '990D9'::text) || 'W'::text)
                    WHEN (ps.longitude = (0)::double precision) THEN '0.0'::text
                    ELSE (to_char(abs(ps.longitude), '990D9'::text) || 'E'::text)
                END AS lon,
                CASE
                    WHEN (ps.latitude < (0)::double precision) THEN (to_char(abs(ps.latitude), '990D9'::text) || 'S'::text)
                    WHEN (ps.latitude = (0)::double precision) THEN '0.0'::text
                    ELSE (to_char(abs(ps.latitude), '990D9'::text) || 'N'::text)
                END AS lat,
            ad.geom
           FROM ((public.estimate_locator e
             JOIN aggregate_data ad ON (((btrim((e.replacement_name)::text) = ad.name) AND ((e.analysis_name)::text = (ad.analysis_name)::text) AND (e.analysis_year = ad.analysis_year))))
             JOIN public.population_submissions ps ON ((e.population_submission_id = ps.id)))
        )
 SELECT row_number() OVER (ORDER BY iz_data.name) AS id,
    iz_data.name,
    iz_data.analysis_year,
    iz_data.analysis_name,
    iz_data.population_id,
    iz_data.cause_of_change,
    iz_data.survey_type,
    iz_data.survey_reliability,
    iz_data.survey_year,
    iz_data.population_estimate,
    iz_data.percent_cl,
    iz_data.source,
    iz_data.pfs,
    iz_data.area,
    iz_data.lon,
    iz_data.lat,
    iz_data.geom
   FROM iz_data
  WITH NO DATA;


--
-- Name: julian_2007; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.julian_2007 (
    gid integer NOT NULL,
    inpcode character varying(6),
    ccode character varying(2),
    cntryname character varying(30),
    surveyzone character varying(80),
    cyear smallint,
    cseason character varying(10),
    method character varying(2),
    tcrate smallint,
    effsampint double precision,
    sampint double precision,
    pilenum smallint,
    drmsite smallint,
    ddcl95p double precision,
    estimate integer,
    actualseen integer,
    uprange smallint,
    stderror double precision,
    variance double precision,
    cl95 double precision,
    cl95p double precision,
    ucl95asym double precision,
    lcl95asym double precision,
    carcass12 integer,
    carcass3 integer,
    carcasst integer,
    reference character varying(100),
    refid integer,
    call_numbe character varying(30),
    quality smallint,
    category character varying(1),
    surveytype character varying(80),
    pfs integer,
    definite integer,
    probable integer,
    possible integer,
    specul integer,
    density double precision,
    cratio12 double precision,
    cratiot double precision,
    selection smallint,
    datein date,
    dateout date,
    comments character varying(254),
    designate character varying(50),
    abvdesigna character varying(10),
    area_sqkm integer,
    reported integer,
    derived integer,
    calculated integer,
    scaledenom integer,
    report smallint,
    df smallint,
    nsample smallint,
    t025 numeric,
    lon numeric,
    lat numeric,
    shape_leng numeric,
    shape_area numeric,
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: julian_2007_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.julian_2007_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: julian_2007_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.julian_2007_gid_seq OWNED BY public.julian_2007.gid;


--
-- Name: linked_citations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linked_citations (
    id integer NOT NULL,
    long_citation character varying,
    short_citation character varying,
    url character varying,
    description text,
    population_submission_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: linked_citations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.linked_citations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: linked_citations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.linked_citations_id_seq OWNED BY public.linked_citations.id;


--
-- Name: mike_sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mike_sites (
    id integer NOT NULL,
    country_id integer,
    subregion character varying(255),
    site_code character varying(255),
    site_name text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    in2015list boolean
);


--
-- Name: mike_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mike_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mike_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mike_sites_id_seq OWNED BY public.mike_sites.id;


--
-- Name: old_staging_protected_area_geometries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.old_staging_protected_area_geometries (
    gid integer,
    ptacode numeric(10,0),
    ptaname character varying(254),
    ccode character varying(254),
    year_est numeric(10,0),
    iucncat character varying(254),
    iucncatara numeric(10,0),
    designate character varying(254),
    abvdesig character varying(254),
    area_sqkm numeric(10,0),
    reported numeric(10,0),
    calculated numeric(10,0),
    source character varying(254),
    refid numeric(10,0),
    inrange numeric(10,0),
    samesurvey numeric(10,0),
    shape_leng numeric,
    shape_area numeric,
    selection numeric(10,0),
    geometry public.geometry
);


--
-- Name: population_submission_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.population_submission_attachments (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    file_file_name character varying(255),
    file_content_type character varying(255),
    file_file_size integer,
    file_updated_at timestamp without time zone,
    population_submission_id integer,
    attachment_type text,
    restrict boolean
);


--
-- Name: population_submission_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.population_submission_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: population_submission_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.population_submission_attachments_id_seq OWNED BY public.population_submission_attachments.id;


--
-- Name: population_submission_geometries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.population_submission_geometries (
    id integer NOT NULL,
    population_submission_id integer,
    geom public.geometry,
    geom_attributes text,
    population_submission_attachment_id integer,
    stratum integer
);


--
-- Name: population_submission_geometries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.population_submission_geometries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: population_submission_geometries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.population_submission_geometries_id_seq OWNED BY public.population_submission_geometries.id;


--
-- Name: population_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.population_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: population_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.population_submissions_id_seq OWNED BY public.population_submissions.id;


--
-- Name: populations; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.populations AS
 SELECT ps.id,
    ps.site_name AS name,
    s.country_id,
    public.st_multi(public.st_collect(iz.geom)) AS geom
   FROM ((public.population_submissions ps
     JOIN public.submissions s ON ((ps.submission_id = s.id)))
     JOIN public.input_zones iz ON ((iz.population_id = ps.id)))
  GROUP BY ps.id, ps.site_name, s.country_id
  WITH NO DATA;


--
-- Name: production_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.production_versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone,
    object_changes text
);


--
-- Name: production_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.production_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: production_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.production_versions_id_seq OWNED BY public.production_versions.id;


--
-- Name: protected_area_geometries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protected_area_geometries (
    gid integer,
    ptacode numeric(10,0),
    ptaname character varying(254),
    ccode character varying(254),
    year_est numeric(10,0),
    iucncat character varying(254),
    iucncatara numeric(10,0),
    designate character varying(254),
    abvdesig character varying(254),
    area_sqkm numeric(10,0),
    reported numeric(10,0),
    calculated numeric(10,0),
    source character varying(254),
    refid numeric(10,0),
    inrange numeric(10,0),
    samesurvey numeric(10,0),
    shape_leng numeric,
    shape_area numeric,
    selection numeric(10,0),
    geometry public.geometry
);


--
-- Name: range_discrepancies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.range_discrepancies (
    gid integer,
    actual integer,
    calculated double precision,
    range smallint,
    rangequali character varying(10),
    centroid text
);


--
-- Name: range_geometries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.range_geometries (
    gid integer,
    range numeric(10,0),
    rangequali character varying(10),
    geometry public.geometry(MultiPolygon,4326)
);


--
-- Name: range_geometries_old; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.range_geometries_old (
    gid integer,
    range numeric(10,0),
    rangequali character varying(10),
    geometry public.geometry(MultiPolygon,4326)
);


--
-- Name: range_previews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.range_previews (
    id integer NOT NULL,
    range_type character varying,
    original_comments character varying,
    source_year character varying,
    published_year character varying,
    comments character varying,
    status character varying,
    geom public.geometry,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: range_previews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.range_previews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: range_previews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.range_previews_id_seq OWNED BY public.range_previews.id;


--
-- Name: region_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.region_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: region_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.region_gid_seq OWNED BY public.region.gid;


--
-- Name: regional_area_of_range_covered; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.regional_area_of_range_covered AS
 SELECT area_of_range_covered.analysis_name,
    area_of_range_covered.analysis_year,
    area_of_range_covered.region,
    area_of_range_covered.surveytype,
    sum(area_of_range_covered.known) AS known,
    sum(area_of_range_covered.possible) AS possible,
    sum(area_of_range_covered.total) AS total
   FROM public.area_of_range_covered
  GROUP BY area_of_range_covered.analysis_name, area_of_range_covered.analysis_year, area_of_range_covered.region, area_of_range_covered.surveytype
  ORDER BY area_of_range_covered.analysis_name, area_of_range_covered.analysis_year, area_of_range_covered.region, area_of_range_covered.surveytype;


--
-- Name: regional_area_of_range_covered_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.regional_area_of_range_covered_totals AS
 SELECT area_of_range_covered_totals.analysis_name,
    area_of_range_covered_totals.analysis_year,
    area_of_range_covered_totals.region,
    sum(area_of_range_covered_totals.known) AS known,
    sum(area_of_range_covered_totals.possible) AS possible,
    sum(area_of_range_covered_totals.total) AS total
   FROM public.area_of_range_covered_totals
  GROUP BY area_of_range_covered_totals.analysis_name, area_of_range_covered_totals.analysis_year, area_of_range_covered_totals.region
  ORDER BY area_of_range_covered_totals.analysis_name, area_of_range_covered_totals.analysis_year, area_of_range_covered_totals.region;


--
-- Name: regional_area_of_range_covered_unassessed; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.regional_area_of_range_covered_unassessed AS
 SELECT area_of_range_covered_unassessed.analysis_name,
    area_of_range_covered_unassessed.analysis_year,
    area_of_range_covered_unassessed.region,
    sum(area_of_range_covered_unassessed.known) AS known,
    sum(area_of_range_covered_unassessed.possible) AS possible,
    sum(area_of_range_covered_unassessed.total) AS total
   FROM public.area_of_range_covered_unassessed
  GROUP BY area_of_range_covered_unassessed.analysis_name, area_of_range_covered_unassessed.analysis_year, area_of_range_covered_unassessed.region
  ORDER BY area_of_range_covered_unassessed.analysis_name, area_of_range_covered_unassessed.analysis_year, area_of_range_covered_unassessed.region;


--
-- Name: regional_range_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.regional_range_totals AS
 SELECT regional_range_table.analysis_name,
    regional_range_table.analysis_year,
    regional_range_table.region,
    sum(regional_range_table.range_area) AS range_area,
    regional_range_table.regional_range,
    sum(regional_range_table.percent_regional_range) AS percent_regional_range,
    sum(regional_range_table.range_assessed) AS range_assessed,
    ((sum(regional_range_table.range_assessed) / sum(regional_range_table.range_area)) * (100)::double precision) AS percent_range_assessed
   FROM public.regional_range_table
  GROUP BY regional_range_table.analysis_name, regional_range_table.analysis_year, regional_range_table.region, regional_range_table.regional_range
  ORDER BY regional_range_table.analysis_name, regional_range_table.analysis_year, regional_range_table.region;


--
-- Name: regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;


--
-- Name: replacement_map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.replacement_map (
    mike_site text,
    aed2007_oids text,
    current_strata text,
    reason_change text,
    id integer NOT NULL
);


--
-- Name: replacement_map_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.replacement_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_narratives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_narratives (
    id integer NOT NULL,
    uri character varying(255),
    narrative text,
    footnote text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: report_narratives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.report_narratives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_narratives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.report_narratives_id_seq OWNED BY public.report_narratives.id;


--
-- Name: review_range; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_range (
    site_name character varying(255),
    analysis_name character varying,
    analysis_year integer,
    region character varying(255),
    category text,
    reason_change character varying(255),
    population_estimate integer,
    country character varying(255),
    input_zone_id text,
    survey_geometry public.geometry(MultiPolygonZM,4326)
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: species; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.species (
    id integer NOT NULL,
    scientific_name character varying(255),
    common_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: species_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.species_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: species_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.species_id_seq OWNED BY public.species.id;


--
-- Name: species_range_state_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.species_range_state_countries (
    id integer NOT NULL,
    species_id integer,
    country_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: species_range_state_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.species_range_state_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: species_range_state_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.species_range_state_countries_id_seq OWNED BY public.species_range_state_countries.id;


--
-- Name: st_est_loc_geo_tb; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.st_est_loc_geo_tb (
    sid integer NOT NULL,
    id integer,
    estimate_type text,
    input_zone_id text,
    population_submission_id integer,
    site_name character varying(255),
    stratum_name character varying(255),
    stratum_area integer,
    completion_year integer,
    short_citation character varying(255),
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_confidence_interval double precision,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    quality_level integer,
    actually_seen integer,
    lcl95 double precision,
    category text,
    country character varying(255),
    region character varying(255),
    continent character varying(255),
    geometry public.geometry
);


--
-- Name: staging_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staging_users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    name character varying(255),
    job_title character varying(255),
    department character varying(255),
    organization character varying(255),
    phone character varying(255),
    fax character varying(255),
    address_1 character varying(255),
    address_2 character varying(255),
    address_3 character varying(255),
    city character varying(255),
    country character varying(255),
    admin boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: staging_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staging_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staging_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staging_users_id_seq OWNED BY public.staging_users.id;


--
-- Name: static_estimate_factors_with_geometry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.static_estimate_factors_with_geometry (
    gid integer NOT NULL,
    id integer,
    estimate_type text,
    input_zone_id text,
    population_submission_id integer,
    site_name character varying(255),
    stratum_name character varying(255),
    stratum_area integer,
    completion_year integer,
    citation text,
    short_citation character varying(255),
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_confidence_interval double precision,
    population_t double precision,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    quality_level integer,
    actually_seen integer,
    survey_geometry_id integer,
    geometry public.geometry
);


--
-- Name: static_estimate_factors_with_geometry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.static_estimate_factors_with_geometry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: static_estimate_locator_with_geometry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.static_estimate_locator_with_geometry (
    gid integer NOT NULL,
    id integer,
    geometry public.geometry,
    estimate_type text,
    input_zone_id text,
    population_submission_id integer,
    site_name character varying(255),
    stratum_name character varying(255),
    stratum_area integer,
    completion_year integer,
    analysis_name text,
    analysis_year integer,
    age integer,
    replacement_name character varying(255),
    reason_change character varying,
    citation text,
    short_citation character varying(255),
    population_estimate integer,
    population_variance double precision,
    population_standard_error double precision,
    population_confidence_interval double precision,
    population_lower_confidence_limit integer,
    population_upper_confidence_limit integer,
    quality_level integer,
    actually_seen integer,
    lcl95 double precision,
    category text,
    country character varying(255),
    region character varying(255),
    continent character varying(255)
);


--
-- Name: static_estimate_locator_with_geometry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.static_estimate_locator_with_geometry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: survey_aerial_sample_count_strata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_aerial_sample_count_strata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_aerial_sample_count_strata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_aerial_sample_count_strata_id_seq OWNED BY public.survey_aerial_sample_count_strata.id;


--
-- Name: survey_aerial_sample_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_aerial_sample_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_aerial_sample_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_aerial_sample_counts_id_seq OWNED BY public.survey_aerial_sample_counts.id;


--
-- Name: survey_aerial_total_count_strata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_aerial_total_count_strata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_aerial_total_count_strata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_aerial_total_count_strata_id_seq OWNED BY public.survey_aerial_total_count_strata.id;


--
-- Name: survey_aerial_total_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_aerial_total_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_aerial_total_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_aerial_total_counts_id_seq OWNED BY public.survey_aerial_total_counts.id;


--
-- Name: survey_dung_count_line_transect_strata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_dung_count_line_transect_strata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_dung_count_line_transect_strata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_dung_count_line_transect_strata_id_seq OWNED BY public.survey_dung_count_line_transect_strata.id;


--
-- Name: survey_dung_count_line_transects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_dung_count_line_transects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_dung_count_line_transects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_dung_count_line_transects_id_seq OWNED BY public.survey_dung_count_line_transects.id;


--
-- Name: survey_faecal_dna_strata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_faecal_dna_strata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_faecal_dna_strata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_faecal_dna_strata_id_seq OWNED BY public.survey_faecal_dna_strata.id;


--
-- Name: survey_faecal_dnas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_faecal_dnas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_faecal_dnas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_faecal_dnas_id_seq OWNED BY public.survey_faecal_dnas.id;


--
-- Name: survey_geometry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_geometry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_geometry_locator_buffered; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_geometry_locator_buffered (
    site_name character varying(255),
    analysis_name text,
    analysis_year integer,
    region character varying(255),
    category text,
    reason_change character varying(255),
    population_estimate integer,
    country character varying(255),
    input_zone_id text,
    survey_geometry public.geometry
);


--
-- Name: survey_ground_sample_count_strata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_ground_sample_count_strata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_ground_sample_count_strata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_ground_sample_count_strata_id_seq OWNED BY public.survey_ground_sample_count_strata.id;


--
-- Name: survey_ground_sample_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_ground_sample_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_ground_sample_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_ground_sample_counts_id_seq OWNED BY public.survey_ground_sample_counts.id;


--
-- Name: survey_ground_total_count_strata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_ground_total_count_strata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_ground_total_count_strata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_ground_total_count_strata_id_seq OWNED BY public.survey_ground_total_count_strata.id;


--
-- Name: survey_ground_total_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_ground_total_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_ground_total_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_ground_total_counts_id_seq OWNED BY public.survey_ground_total_counts.id;


--
-- Name: survey_individual_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_individual_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_individual_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_individual_registrations_id_seq OWNED BY public.survey_individual_registrations.id;


--
-- Name: survey_modeled_extrapolations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_modeled_extrapolations (
    id integer NOT NULL,
    population_submission_id integer,
    other_method_description character varying,
    population_estimate_min integer,
    population_estimate_max integer,
    mike_site_id integer,
    is_mike_site boolean,
    actually_seen integer,
    informed boolean,
    survey_geometry_id integer,
    stratum_area integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: survey_modeled_extrapolations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_modeled_extrapolations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_modeled_extrapolations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_modeled_extrapolations_id_seq OWNED BY public.survey_modeled_extrapolations.id;


--
-- Name: survey_others_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_others_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_others_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_others_id_seq OWNED BY public.survey_others.id;


--
-- Name: survey_range_equator_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_range_equator_countries (
    analysis_name character varying,
    analysis_year integer,
    region character varying(255),
    range_quality character varying(10),
    category text,
    country character varying(255),
    area_sqkm double precision
);


--
-- Name: survey_range_intersection_metrics_add; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_range_intersection_metrics_add (
    analysis_name character varying,
    analysis_year integer,
    region character varying(255),
    range_quality character varying(10),
    category text,
    reason_change character varying(255),
    country character varying(255),
    area_sqkm double precision
);


--
-- Name: survey_range_intersections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_range_intersections (
    analysis_name character varying,
    analysis_year integer,
    region character varying(255),
    category text,
    reason_change character varying(255),
    country character varying(255),
    range_quality character varying(10),
    st_intersection public.geometry
);


--
-- Name: survey_range_intersections_add; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.survey_range_intersections_add AS
 SELECT l.analysis_name,
    l.analysis_year,
    l.region,
    l.category,
    l.reason_change,
    l.country,
    c.range_quality,
    public.st_intersection(public.st_makevalid(public.st_force2d(public.st_setsrid(l.geom, 4326))), public.st_makevalid(public.st_force2d(public.st_setsrid(c.range_geometry, 4326)))) AS st_intersection
   FROM (public.estimate_locator_with_geometry_add l
     JOIN public.country_range c ON ((public.st_intersects(public.st_setsrid(l.geom, 4326), public.st_setsrid(c.range_geometry, 4326)) AND ((c.country)::text = (l.country)::text))))
  WHERE (c.range = (1)::numeric);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    name character varying(255),
    job_title character varying(255),
    department character varying(255),
    organization character varying(255),
    phone character varying(255),
    fax character varying(255),
    address_1 character varying(255),
    address_2 character varying(255),
    address_3 character varying(255),
    city character varying(255),
    country character varying(255),
    admin boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    disabled boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: version_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_associations (
    id integer NOT NULL,
    version_id integer,
    foreign_key_name character varying NOT NULL,
    foreign_key_id integer
);


--
-- Name: version_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.version_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.version_associations_id_seq OWNED BY public.version_associations.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone,
    object_changes text,
    transaction_id integer
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: 2014_range_map_edit_for_2016 gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2014_range_map_edit_for_2016" ALTER COLUMN gid SET DEFAULT nextval('public."2014_range_map_edit_for_2016_gid_seq"'::regclass);


--
-- Name: 2014_rangetypeupdates5_final gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2014_rangetypeupdates5_final" ALTER COLUMN gid SET DEFAULT nextval('public."2014_rangetypeupdates5_final_gid_seq"'::regclass);


--
-- Name: 2016_aed_pa_layer gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2016_aed_pa_layer" ALTER COLUMN gid SET DEFAULT nextval('public."2016_aed_pa_layer_gid_seq"'::regclass);


--
-- Name: 2016_range_only_fixed gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2016_range_only_fixed" ALTER COLUMN gid SET DEFAULT nextval('public."2016_range_only_fixed_gid_seq"'::regclass);


--
-- Name: aed_range_layer_2016_data_sharing gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aed_range_layer_2016_data_sharing ALTER COLUMN gid SET DEFAULT nextval('public.aed_range_layer_2016_data_sharing_gid_seq1'::regclass);


--
-- Name: aed_range_layer_2016_data_sharing_old gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aed_range_layer_2016_data_sharing_old ALTER COLUMN gid SET DEFAULT nextval('public.aed_range_layer_2016_data_sharing_gid_seq'::regclass);


--
-- Name: analyses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analyses ALTER COLUMN id SET DEFAULT nextval('public.analyses_analysis_id_seq'::regclass);


--
-- Name: changes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes ALTER COLUMN id SET DEFAULT nextval('public.changes_id_seq'::regclass);


--
-- Name: continent gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent ALTER COLUMN gid SET DEFAULT nextval('public.continent_gid_seq'::regclass);


--
-- Name: continents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continents ALTER COLUMN id SET DEFAULT nextval('public.continents_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: country gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country ALTER COLUMN gid SET DEFAULT nextval('public.country_gid_seq'::regclass);


--
-- Name: country_updated gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_updated ALTER COLUMN gid SET DEFAULT nextval('public.country_updated_gid_seq'::regclass);


--
-- Name: data_request_forms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_request_forms ALTER COLUMN id SET DEFAULT nextval('public.data_request_forms_id_seq'::regclass);


--
-- Name: ead_pa_layer_2016 gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ead_pa_layer_2016 ALTER COLUMN gid SET DEFAULT nextval('public.ead_pa_layer_2016_gid_seq'::regclass);


--
-- Name: julian_2007 gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.julian_2007 ALTER COLUMN gid SET DEFAULT nextval('public.julian_2007_gid_seq'::regclass);


--
-- Name: linked_citations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_citations ALTER COLUMN id SET DEFAULT nextval('public.linked_citations_id_seq'::regclass);


--
-- Name: mike_sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mike_sites ALTER COLUMN id SET DEFAULT nextval('public.mike_sites_id_seq'::regclass);


--
-- Name: population_submission_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.population_submission_attachments ALTER COLUMN id SET DEFAULT nextval('public.population_submission_attachments_id_seq'::regclass);


--
-- Name: population_submission_geometries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.population_submission_geometries ALTER COLUMN id SET DEFAULT nextval('public.population_submission_geometries_id_seq'::regclass);


--
-- Name: population_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.population_submissions ALTER COLUMN id SET DEFAULT nextval('public.population_submissions_id_seq'::regclass);


--
-- Name: production_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.production_versions ALTER COLUMN id SET DEFAULT nextval('public.production_versions_id_seq'::regclass);


--
-- Name: range_previews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.range_previews ALTER COLUMN id SET DEFAULT nextval('public.range_previews_id_seq'::regclass);


--
-- Name: region gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region ALTER COLUMN gid SET DEFAULT nextval('public.region_gid_seq'::regclass);


--
-- Name: regions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions ALTER COLUMN id SET DEFAULT nextval('public.regions_id_seq'::regclass);


--
-- Name: report_narratives id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_narratives ALTER COLUMN id SET DEFAULT nextval('public.report_narratives_id_seq'::regclass);


--
-- Name: species id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species ALTER COLUMN id SET DEFAULT nextval('public.species_id_seq'::regclass);


--
-- Name: species_range_state_countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_range_state_countries ALTER COLUMN id SET DEFAULT nextval('public.species_range_state_countries_id_seq'::regclass);


--
-- Name: staging_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staging_users ALTER COLUMN id SET DEFAULT nextval('public.staging_users_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: survey_aerial_sample_count_strata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_sample_count_strata ALTER COLUMN id SET DEFAULT nextval('public.survey_aerial_sample_count_strata_id_seq'::regclass);


--
-- Name: survey_aerial_sample_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_sample_counts ALTER COLUMN id SET DEFAULT nextval('public.survey_aerial_sample_counts_id_seq'::regclass);


--
-- Name: survey_aerial_total_count_strata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_total_count_strata ALTER COLUMN id SET DEFAULT nextval('public.survey_aerial_total_count_strata_id_seq'::regclass);


--
-- Name: survey_aerial_total_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_total_counts ALTER COLUMN id SET DEFAULT nextval('public.survey_aerial_total_counts_id_seq'::regclass);


--
-- Name: survey_dung_count_line_transect_strata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_dung_count_line_transect_strata ALTER COLUMN id SET DEFAULT nextval('public.survey_dung_count_line_transect_strata_id_seq'::regclass);


--
-- Name: survey_dung_count_line_transects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_dung_count_line_transects ALTER COLUMN id SET DEFAULT nextval('public.survey_dung_count_line_transects_id_seq'::regclass);


--
-- Name: survey_faecal_dna_strata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_faecal_dna_strata ALTER COLUMN id SET DEFAULT nextval('public.survey_faecal_dna_strata_id_seq'::regclass);


--
-- Name: survey_faecal_dnas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_faecal_dnas ALTER COLUMN id SET DEFAULT nextval('public.survey_faecal_dnas_id_seq'::regclass);


--
-- Name: survey_ground_sample_count_strata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_count_strata ALTER COLUMN id SET DEFAULT nextval('public.survey_ground_sample_count_strata_id_seq'::regclass);


--
-- Name: survey_ground_sample_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_counts ALTER COLUMN id SET DEFAULT nextval('public.survey_ground_sample_counts_id_seq'::regclass);


--
-- Name: survey_ground_total_count_strata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_total_count_strata ALTER COLUMN id SET DEFAULT nextval('public.survey_ground_total_count_strata_id_seq'::regclass);


--
-- Name: survey_ground_total_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_total_counts ALTER COLUMN id SET DEFAULT nextval('public.survey_ground_total_counts_id_seq'::regclass);


--
-- Name: survey_individual_registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_individual_registrations ALTER COLUMN id SET DEFAULT nextval('public.survey_individual_registrations_id_seq'::regclass);


--
-- Name: survey_modeled_extrapolations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_modeled_extrapolations ALTER COLUMN id SET DEFAULT nextval('public.survey_modeled_extrapolations_id_seq'::regclass);


--
-- Name: survey_others id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_others ALTER COLUMN id SET DEFAULT nextval('public.survey_others_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: version_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_associations ALTER COLUMN id SET DEFAULT nextval('public.version_associations_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: 2014_range_map_edit_for_2016 2014_range_map_edit_for_2016_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2014_range_map_edit_for_2016"
    ADD CONSTRAINT "2014_range_map_edit_for_2016_pkey" PRIMARY KEY (gid);


--
-- Name: 2014_rangetypeupdates5_final 2014_rangetypeupdates5_final_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2014_rangetypeupdates5_final"
    ADD CONSTRAINT "2014_rangetypeupdates5_final_pkey" PRIMARY KEY (gid);


--
-- Name: 2016_aed_pa_layer 2016_aed_pa_layer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2016_aed_pa_layer"
    ADD CONSTRAINT "2016_aed_pa_layer_pkey" PRIMARY KEY (gid);


--
-- Name: 2016_range_only_fixed 2016_range_only_fixed_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."2016_range_only_fixed"
    ADD CONSTRAINT "2016_range_only_fixed_pkey" PRIMARY KEY (gid);


--
-- Name: aed_range_layer_2016_data_sharing_old aed_range_layer_2016_data_sharing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aed_range_layer_2016_data_sharing_old
    ADD CONSTRAINT aed_range_layer_2016_data_sharing_pkey PRIMARY KEY (gid);


--
-- Name: aed_range_layer_2016_data_sharing aed_range_layer_2016_data_sharing_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aed_range_layer_2016_data_sharing
    ADD CONSTRAINT aed_range_layer_2016_data_sharing_pkey1 PRIMARY KEY (gid);


--
-- Name: changes changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes
    ADD CONSTRAINT changes_pkey PRIMARY KEY (id);


--
-- Name: continent continent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continent
    ADD CONSTRAINT continent_pkey PRIMARY KEY (gid);


--
-- Name: continents continents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.continents
    ADD CONSTRAINT continents_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (gid);


--
-- Name: country_updated country_updated_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_updated
    ADD CONSTRAINT country_updated_pkey PRIMARY KEY (gid);


--
-- Name: data_request_forms data_request_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_request_forms
    ADD CONSTRAINT data_request_forms_pkey PRIMARY KEY (id);


--
-- Name: ead_pa_layer_2016 ead_pa_layer_2016_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ead_pa_layer_2016
    ADD CONSTRAINT ead_pa_layer_2016_pkey PRIMARY KEY (gid);


--
-- Name: julian_2007 julian_2007_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.julian_2007
    ADD CONSTRAINT julian_2007_pkey PRIMARY KEY (gid);


--
-- Name: linked_citations linked_citations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_citations
    ADD CONSTRAINT linked_citations_pkey PRIMARY KEY (id);


--
-- Name: mike_sites mike_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mike_sites
    ADD CONSTRAINT mike_sites_pkey PRIMARY KEY (id);


--
-- Name: analyses pk_analysis; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analyses
    ADD CONSTRAINT pk_analysis PRIMARY KEY (id);


--
-- Name: population_submission_attachments population_submission_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.population_submission_attachments
    ADD CONSTRAINT population_submission_attachments_pkey PRIMARY KEY (id);


--
-- Name: population_submission_geometries population_submission_geometries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.population_submission_geometries
    ADD CONSTRAINT population_submission_geometries_pkey PRIMARY KEY (id);


--
-- Name: population_submissions population_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.population_submissions
    ADD CONSTRAINT population_submissions_pkey PRIMARY KEY (id);


--
-- Name: range_previews range_previews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.range_previews
    ADD CONSTRAINT range_previews_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (gid);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: replacement_map replacement_map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.replacement_map
    ADD CONSTRAINT replacement_map_pkey PRIMARY KEY (id);


--
-- Name: report_narratives report_narratives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_narratives
    ADD CONSTRAINT report_narratives_pkey PRIMARY KEY (id);


--
-- Name: survey_geometries sg_id_primary_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_geometries
    ADD CONSTRAINT sg_id_primary_key PRIMARY KEY (id);


--
-- Name: species species_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_pkey PRIMARY KEY (id);


--
-- Name: species_range_state_countries species_range_state_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_range_state_countries
    ADD CONSTRAINT species_range_state_countries_pkey PRIMARY KEY (id);


--
-- Name: st_est_loc_geo_tb st_est_loc_geo_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.st_est_loc_geo_tb
    ADD CONSTRAINT st_est_loc_geo_tb_pkey PRIMARY KEY (sid);


--
-- Name: static_estimate_factors_with_geometry static_estimate_factors_with_geometry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_estimate_factors_with_geometry
    ADD CONSTRAINT static_estimate_factors_with_geometry_pkey PRIMARY KEY (gid);


--
-- Name: static_estimate_locator_with_geometry static_estimate_locator_with_geometry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_estimate_locator_with_geometry
    ADD CONSTRAINT static_estimate_locator_with_geometry_pkey PRIMARY KEY (gid);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: survey_aerial_sample_count_strata survey_aerial_sample_count_strata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_sample_count_strata
    ADD CONSTRAINT survey_aerial_sample_count_strata_pkey PRIMARY KEY (id);


--
-- Name: survey_aerial_sample_counts survey_aerial_sample_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_sample_counts
    ADD CONSTRAINT survey_aerial_sample_counts_pkey PRIMARY KEY (id);


--
-- Name: survey_aerial_total_count_strata survey_aerial_total_count_strata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_total_count_strata
    ADD CONSTRAINT survey_aerial_total_count_strata_pkey PRIMARY KEY (id);


--
-- Name: survey_aerial_total_counts survey_aerial_total_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_total_counts
    ADD CONSTRAINT survey_aerial_total_counts_pkey PRIMARY KEY (id);


--
-- Name: survey_dung_count_line_transect_strata survey_dung_count_line_transect_strata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_dung_count_line_transect_strata
    ADD CONSTRAINT survey_dung_count_line_transect_strata_pkey PRIMARY KEY (id);


--
-- Name: survey_dung_count_line_transects survey_dung_count_line_transects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_dung_count_line_transects
    ADD CONSTRAINT survey_dung_count_line_transects_pkey PRIMARY KEY (id);


--
-- Name: survey_faecal_dna_strata survey_faecal_dna_strata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_faecal_dna_strata
    ADD CONSTRAINT survey_faecal_dna_strata_pkey PRIMARY KEY (id);


--
-- Name: survey_faecal_dnas survey_faecal_dnas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_faecal_dnas
    ADD CONSTRAINT survey_faecal_dnas_pkey PRIMARY KEY (id);


--
-- Name: survey_ground_sample_count_strata survey_ground_sample_count_strata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_count_strata
    ADD CONSTRAINT survey_ground_sample_count_strata_pkey PRIMARY KEY (id);


--
-- Name: survey_ground_sample_counts survey_ground_sample_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_counts
    ADD CONSTRAINT survey_ground_sample_counts_pkey PRIMARY KEY (id);


--
-- Name: survey_ground_total_count_strata survey_ground_total_count_strata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_total_count_strata
    ADD CONSTRAINT survey_ground_total_count_strata_pkey PRIMARY KEY (id);


--
-- Name: survey_ground_total_counts survey_ground_total_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_total_counts
    ADD CONSTRAINT survey_ground_total_counts_pkey PRIMARY KEY (id);


--
-- Name: survey_individual_registrations survey_individual_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_individual_registrations
    ADD CONSTRAINT survey_individual_registrations_pkey PRIMARY KEY (id);


--
-- Name: survey_modeled_extrapolations survey_modeled_extrapolations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_modeled_extrapolations
    ADD CONSTRAINT survey_modeled_extrapolations_pkey PRIMARY KEY (id);


--
-- Name: survey_others survey_others_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_others
    ADD CONSTRAINT survey_others_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: version_associations version_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_associations
    ADD CONSTRAINT version_associations_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_version_associations_on_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_associations_on_foreign_key ON public.version_associations USING btree (foreign_key_name, foreign_key_id);


--
-- Name: index_version_associations_on_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_associations_on_version_id ON public.version_associations USING btree (version_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_versions_on_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_transaction_id ON public.versions USING btree (transaction_id);


--
-- Name: input_zones_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX input_zones_pk ON public.input_zones USING btree (id);


--
-- Name: input_zones_populations_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX input_zones_populations_fk ON public.input_zones USING btree (population_id);


--
-- Name: populations_countries_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX populations_countries_fk ON public.populations USING btree (country_id);


--
-- Name: populations_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX populations_pk ON public.populations USING btree (id);


--
-- Name: si_country_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX si_country_geom ON public.country USING gist (geom);


--
-- Name: si_country_range; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX si_country_range ON public.country_range USING gist (range_geometry);


--
-- Name: si_range_geometry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX si_range_geometry ON public.range_geometries USING gist (geometry);


--
-- Name: si_survey_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX si_survey_geom ON public.survey_geometries USING gist (geom);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: survey_aerial_sample_count_strata as_webid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER as_webid BEFORE INSERT OR UPDATE ON public.survey_aerial_sample_count_strata FOR EACH ROW EXECUTE PROCEDURE public.create_webid();


--
-- Name: survey_aerial_total_count_strata at_webid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER at_webid BEFORE INSERT OR UPDATE ON public.survey_aerial_total_count_strata FOR EACH ROW EXECUTE PROCEDURE public.create_webid();


--
-- Name: survey_dung_count_line_transect_strata dc_webid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dc_webid BEFORE INSERT OR UPDATE ON public.survey_dung_count_line_transect_strata FOR EACH ROW EXECUTE PROCEDURE public.create_webid();


--
-- Name: survey_faecal_dna_strata dna_webid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER dna_webid BEFORE INSERT OR UPDATE ON public.survey_faecal_dna_strata FOR EACH ROW EXECUTE PROCEDURE public.create_webid();


--
-- Name: survey_ground_sample_count_strata gs_webid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gs_webid BEFORE INSERT OR UPDATE ON public.survey_ground_sample_count_strata FOR EACH ROW EXECUTE PROCEDURE public.create_webid();


--
-- Name: survey_ground_total_count_strata gt_webid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER gt_webid BEFORE INSERT OR UPDATE ON public.survey_ground_total_count_strata FOR EACH ROW EXECUTE PROCEDURE public.create_webid();


--
-- Name: survey_individual_registrations ir_webid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ir_webid BEFORE INSERT OR UPDATE ON public.survey_individual_registrations FOR EACH ROW EXECUTE PROCEDURE public.create_webid();


--
-- Name: survey_others o_webid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER o_webid BEFORE INSERT OR UPDATE ON public.survey_others FOR EACH ROW EXECUTE PROCEDURE public.create_webid();


--
-- Name: survey_ground_total_count_strata fk1_geom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_total_count_strata
    ADD CONSTRAINT fk1_geom FOREIGN KEY (survey_geometry_id) REFERENCES public.survey_geometries(id);


--
-- Name: submissions fk1_mike_site; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT fk1_mike_site FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: population_submission_attachments fk1_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.population_submission_attachments
    ADD CONSTRAINT fk1_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: submissions fk1_species; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT fk1_species FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: submissions fk1_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT fk1_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: survey_ground_sample_count_strata fk2_geom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_count_strata
    ADD CONSTRAINT fk2_geom FOREIGN KEY (survey_geometry_id) REFERENCES public.survey_geometries(id);


--
-- Name: survey_aerial_sample_counts fk2_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_sample_counts
    ADD CONSTRAINT fk2_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: survey_faecal_dna_strata fk3_geom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_faecal_dna_strata
    ADD CONSTRAINT fk3_geom FOREIGN KEY (survey_geometry_id) REFERENCES public.survey_geometries(id);


--
-- Name: survey_aerial_total_counts fk3_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_total_counts
    ADD CONSTRAINT fk3_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: survey_dung_count_line_transect_strata fk4_geom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_dung_count_line_transect_strata
    ADD CONSTRAINT fk4_geom FOREIGN KEY (survey_geometry_id) REFERENCES public.survey_geometries(id);


--
-- Name: survey_dung_count_line_transects fk4_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_dung_count_line_transects
    ADD CONSTRAINT fk4_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: survey_aerial_total_count_strata fk5_geom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_total_count_strata
    ADD CONSTRAINT fk5_geom FOREIGN KEY (survey_geometry_id) REFERENCES public.survey_geometries(id);


--
-- Name: survey_faecal_dnas fk5_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_faecal_dnas
    ADD CONSTRAINT fk5_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: survey_aerial_sample_count_strata fk6_geom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_sample_count_strata
    ADD CONSTRAINT fk6_geom FOREIGN KEY (survey_geometry_id) REFERENCES public.survey_geometries(id);


--
-- Name: survey_ground_sample_counts fk6_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_counts
    ADD CONSTRAINT fk6_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: survey_ground_sample_counts fk7_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_counts
    ADD CONSTRAINT fk7_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: survey_individual_registrations fk8_geom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_individual_registrations
    ADD CONSTRAINT fk8_geom FOREIGN KEY (survey_geometry_id) REFERENCES public.survey_geometries(id);


--
-- Name: survey_individual_registrations fk8_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_individual_registrations
    ADD CONSTRAINT fk8_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: survey_others fk9_geom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_others
    ADD CONSTRAINT fk9_geom FOREIGN KEY (survey_geometry_id) REFERENCES public.survey_geometries(id);


--
-- Name: survey_others fk9_pop_submission; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_others
    ADD CONSTRAINT fk9_pop_submission FOREIGN KEY (population_submission_id) REFERENCES public.population_submissions(id);


--
-- Name: changes fk_analysis; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes
    ADD CONSTRAINT fk_analysis FOREIGN KEY (analysis_id) REFERENCES public.analyses(id);


--
-- Name: survey_aerial_sample_count_strata fk_as; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_sample_count_strata
    ADD CONSTRAINT fk_as FOREIGN KEY (survey_aerial_sample_count_id) REFERENCES public.survey_aerial_sample_counts(id);


--
-- Name: survey_aerial_total_count_strata fk_at; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_total_count_strata
    ADD CONSTRAINT fk_at FOREIGN KEY (survey_aerial_total_count_id) REFERENCES public.survey_aerial_total_counts(id);


--
-- Name: survey_dung_count_line_transect_strata fk_dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_dung_count_line_transect_strata
    ADD CONSTRAINT fk_dc FOREIGN KEY (survey_dung_count_line_transect_id) REFERENCES public.survey_dung_count_line_transects(id);


--
-- Name: survey_faecal_dna_strata fk_dna; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_faecal_dna_strata
    ADD CONSTRAINT fk_dna FOREIGN KEY (survey_faecal_dna_id) REFERENCES public.survey_faecal_dnas(id);


--
-- Name: survey_ground_sample_count_strata fk_gs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_count_strata
    ADD CONSTRAINT fk_gs FOREIGN KEY (survey_ground_sample_count_id) REFERENCES public.survey_ground_sample_counts(id);


--
-- Name: survey_ground_total_count_strata fk_gt; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_total_count_strata
    ADD CONSTRAINT fk_gt FOREIGN KEY (survey_ground_total_count_id) REFERENCES public.survey_ground_total_counts(id);


--
-- Name: survey_aerial_sample_count_strata fk_mike1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_sample_count_strata
    ADD CONSTRAINT fk_mike1 FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: survey_aerial_total_count_strata fk_mike2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_aerial_total_count_strata
    ADD CONSTRAINT fk_mike2 FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: survey_dung_count_line_transect_strata fk_mike3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_dung_count_line_transect_strata
    ADD CONSTRAINT fk_mike3 FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: survey_faecal_dna_strata fk_mike4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_faecal_dna_strata
    ADD CONSTRAINT fk_mike4 FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: survey_ground_total_count_strata fk_mike5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_total_count_strata
    ADD CONSTRAINT fk_mike5 FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: survey_others fk_mike5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_others
    ADD CONSTRAINT fk_mike5 FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: survey_ground_sample_count_strata fk_mike6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_ground_sample_count_strata
    ADD CONSTRAINT fk_mike6 FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: survey_individual_registrations fk_mike8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_individual_registrations
    ADD CONSTRAINT fk_mike8 FOREIGN KEY (mike_site_id) REFERENCES public.mike_sites(id);


--
-- Name: species_range_state_countries fk_species; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species_range_state_countries
    ADD CONSTRAINT fk_species FOREIGN KEY (species_id) REFERENCES public.species(id);


--
-- Name: population_submissions submission_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.population_submissions
    ADD CONSTRAINT submission_fk FOREIGN KEY (submission_id) REFERENCES public.submissions(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20111011191017');

INSERT INTO schema_migrations (version) VALUES ('20111011191136');

INSERT INTO schema_migrations (version) VALUES ('20111011194025');

INSERT INTO schema_migrations (version) VALUES ('20111011194031');

INSERT INTO schema_migrations (version) VALUES ('20111011194037');

INSERT INTO schema_migrations (version) VALUES ('20111011194046');

INSERT INTO schema_migrations (version) VALUES ('20111011194052');

INSERT INTO schema_migrations (version) VALUES ('20111011194058');

INSERT INTO schema_migrations (version) VALUES ('20111011194104');

INSERT INTO schema_migrations (version) VALUES ('20111011194110');

INSERT INTO schema_migrations (version) VALUES ('20111011194117');

INSERT INTO schema_migrations (version) VALUES ('20111011194123');

INSERT INTO schema_migrations (version) VALUES ('20111011194129');

INSERT INTO schema_migrations (version) VALUES ('20111011194136');

INSERT INTO schema_migrations (version) VALUES ('20111011194142');

INSERT INTO schema_migrations (version) VALUES ('20111011194149');

INSERT INTO schema_migrations (version) VALUES ('20111011194155');

INSERT INTO schema_migrations (version) VALUES ('20111011194201');

INSERT INTO schema_migrations (version) VALUES ('20111201192232');

INSERT INTO schema_migrations (version) VALUES ('20111201194525');

INSERT INTO schema_migrations (version) VALUES ('20111201195952');

INSERT INTO schema_migrations (version) VALUES ('20111202031756');

INSERT INTO schema_migrations (version) VALUES ('20111202032517');

INSERT INTO schema_migrations (version) VALUES ('20111202033137');

INSERT INTO schema_migrations (version) VALUES ('20111202200027');

INSERT INTO schema_migrations (version) VALUES ('20120206082544');

INSERT INTO schema_migrations (version) VALUES ('20120211051510');

INSERT INTO schema_migrations (version) VALUES ('20120211054546');

INSERT INTO schema_migrations (version) VALUES ('20120211054624');

INSERT INTO schema_migrations (version) VALUES ('20120211055235');

INSERT INTO schema_migrations (version) VALUES ('20120216001347');

INSERT INTO schema_migrations (version) VALUES ('20120221062558');

INSERT INTO schema_migrations (version) VALUES ('20120223014050');

INSERT INTO schema_migrations (version) VALUES ('20120223190436');

INSERT INTO schema_migrations (version) VALUES ('20120308014115');

INSERT INTO schema_migrations (version) VALUES ('20120308020028');

INSERT INTO schema_migrations (version) VALUES ('20120312011810');

INSERT INTO schema_migrations (version) VALUES ('20120312011811');

INSERT INTO schema_migrations (version) VALUES ('20120312110156');

INSERT INTO schema_migrations (version) VALUES ('20120325021120');

INSERT INTO schema_migrations (version) VALUES ('20120325030413');

INSERT INTO schema_migrations (version) VALUES ('20120416174639');

INSERT INTO schema_migrations (version) VALUES ('20120419004507');

INSERT INTO schema_migrations (version) VALUES ('20120419005451');

INSERT INTO schema_migrations (version) VALUES ('20120419005827');

INSERT INTO schema_migrations (version) VALUES ('20120424114909');

INSERT INTO schema_migrations (version) VALUES ('20120424115021');

INSERT INTO schema_migrations (version) VALUES ('20120510060541');

INSERT INTO schema_migrations (version) VALUES ('20120627084351');

INSERT INTO schema_migrations (version) VALUES ('20120627084543');

INSERT INTO schema_migrations (version) VALUES ('20120831090228');

INSERT INTO schema_migrations (version) VALUES ('20121012112418');

INSERT INTO schema_migrations (version) VALUES ('20150401012229');

INSERT INTO schema_migrations (version) VALUES ('20150821111743');

INSERT INTO schema_migrations (version) VALUES ('20150821111744');

INSERT INTO schema_migrations (version) VALUES ('20151120221735');

INSERT INTO schema_migrations (version) VALUES ('20151122032652');

INSERT INTO schema_migrations (version) VALUES ('20151123204038');

INSERT INTO schema_migrations (version) VALUES ('20151123213012');

INSERT INTO schema_migrations (version) VALUES ('20151124041257');

INSERT INTO schema_migrations (version) VALUES ('20151124062712');

INSERT INTO schema_migrations (version) VALUES ('20151124083100');

INSERT INTO schema_migrations (version) VALUES ('20151130171930');

INSERT INTO schema_migrations (version) VALUES ('20151130175516');

INSERT INTO schema_migrations (version) VALUES ('20151210171432');

INSERT INTO schema_migrations (version) VALUES ('20160108064142');

INSERT INTO schema_migrations (version) VALUES ('20160108092640');

INSERT INTO schema_migrations (version) VALUES ('20160109011528');

INSERT INTO schema_migrations (version) VALUES ('20160109011529');

INSERT INTO schema_migrations (version) VALUES ('20160110191217');

INSERT INTO schema_migrations (version) VALUES ('20160112233542');

INSERT INTO schema_migrations (version) VALUES ('20160119002041');

INSERT INTO schema_migrations (version) VALUES ('20160125063910');

INSERT INTO schema_migrations (version) VALUES ('20160125085404');

INSERT INTO schema_migrations (version) VALUES ('20160125090447');

INSERT INTO schema_migrations (version) VALUES ('20160131211655');

INSERT INTO schema_migrations (version) VALUES ('20160201001116');

INSERT INTO schema_migrations (version) VALUES ('20160203150811');

INSERT INTO schema_migrations (version) VALUES ('20160208033619');

INSERT INTO schema_migrations (version) VALUES ('20160211021325');

INSERT INTO schema_migrations (version) VALUES ('20160304023719');

INSERT INTO schema_migrations (version) VALUES ('20160305022222');

INSERT INTO schema_migrations (version) VALUES ('20160305025639');

INSERT INTO schema_migrations (version) VALUES ('20160330091819');

INSERT INTO schema_migrations (version) VALUES ('20160413154836');

INSERT INTO schema_migrations (version) VALUES ('20160415022317');

INSERT INTO schema_migrations (version) VALUES ('20160419101317');

INSERT INTO schema_migrations (version) VALUES ('20160423200938');

INSERT INTO schema_migrations (version) VALUES ('20160423200939');

INSERT INTO schema_migrations (version) VALUES ('20160423223422');

INSERT INTO schema_migrations (version) VALUES ('20160423223620');

INSERT INTO schema_migrations (version) VALUES ('20160424162905');

INSERT INTO schema_migrations (version) VALUES ('20160427225620');

INSERT INTO schema_migrations (version) VALUES ('20160504211059');

INSERT INTO schema_migrations (version) VALUES ('20160504212857');

INSERT INTO schema_migrations (version) VALUES ('20160509154639');

INSERT INTO schema_migrations (version) VALUES ('20160510222736');

INSERT INTO schema_migrations (version) VALUES ('20160511053451');

INSERT INTO schema_migrations (version) VALUES ('20160511181514');

INSERT INTO schema_migrations (version) VALUES ('20160516152207');

INSERT INTO schema_migrations (version) VALUES ('20160517151710');

INSERT INTO schema_migrations (version) VALUES ('20160518014444');

INSERT INTO schema_migrations (version) VALUES ('20160518220547');

INSERT INTO schema_migrations (version) VALUES ('20160524173759');

INSERT INTO schema_migrations (version) VALUES ('20160524175628');

INSERT INTO schema_migrations (version) VALUES ('20160524214735');

INSERT INTO schema_migrations (version) VALUES ('20160525023543');

INSERT INTO schema_migrations (version) VALUES ('20160526043430');

INSERT INTO schema_migrations (version) VALUES ('20160526050858');

INSERT INTO schema_migrations (version) VALUES ('20160531062918');

INSERT INTO schema_migrations (version) VALUES ('20160531135031');

INSERT INTO schema_migrations (version) VALUES ('20160602172601');

INSERT INTO schema_migrations (version) VALUES ('20160604225027');

INSERT INTO schema_migrations (version) VALUES ('20160606070742');

INSERT INTO schema_migrations (version) VALUES ('20160607160851');

INSERT INTO schema_migrations (version) VALUES ('20160609173657');

INSERT INTO schema_migrations (version) VALUES ('20160611033626');

INSERT INTO schema_migrations (version) VALUES ('20160714201415');

INSERT INTO schema_migrations (version) VALUES ('20160722171715');

INSERT INTO schema_migrations (version) VALUES ('20160722210725');

INSERT INTO schema_migrations (version) VALUES ('20160729004601');

INSERT INTO schema_migrations (version) VALUES ('20160803165841');

INSERT INTO schema_migrations (version) VALUES ('20160809204525');

INSERT INTO schema_migrations (version) VALUES ('20160811202109');

INSERT INTO schema_migrations (version) VALUES ('20160819023141');

INSERT INTO schema_migrations (version) VALUES ('20160822035755');

INSERT INTO schema_migrations (version) VALUES ('20160825220444');

INSERT INTO schema_migrations (version) VALUES ('20160826015001');

INSERT INTO schema_migrations (version) VALUES ('20160826015351');

INSERT INTO schema_migrations (version) VALUES ('20190116142519');

INSERT INTO schema_migrations (version) VALUES ('20190116205115');

INSERT INTO schema_migrations (version) VALUES ('20190117182408');

INSERT INTO schema_migrations (version) VALUES ('20190225140735');

INSERT INTO schema_migrations (version) VALUES ('20220221233424');

