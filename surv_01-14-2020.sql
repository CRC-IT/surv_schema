--
-- PostgreSQL database dump
--

-- Dumped from database version 10.7
-- Dumped by pg_dump version 12.0

-- Started on 2020-01-14 08:58:27

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
-- TOC entry 454 (class 2615 OID 24854624)
-- Name: surv; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA surv;


ALTER SCHEMA surv OWNER TO postgres;

--
-- TOC entry 4032 (class 1255 OID 36958238)
-- Name: create_surv_mvs(); Type: FUNCTION; Schema: surv; Owner: postgres
--

CREATE FUNCTION surv.create_surv_mvs() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volume_calcs AS SELECT * FROM surv.fv_surv_allocated_volume_calcs;
CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volume_cums AS SELECT * FROM surv.fv_surv_allocated_volume_cums;
CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volumes_var AS SELECT * FROM surv.fv_surv_allocated_volume_var;
CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_daily_injection AS SELECT * FROM surv.fv_surv_daily_injection;
CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_well_events AS SELECT * FROM surv.fv_surv_well_events;
CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_well_notes AS SELECT * FROM surv.fv_surv_well_notes;
CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_well_test AS SELECT * FROM surv.fv_surv_well_test;
RETURN 1;
END;
$$;


ALTER FUNCTION surv.create_surv_mvs() OWNER TO postgres;

--
-- TOC entry 2017 (class 1259 OID 53476461)
-- Name: dv_surv_av_allocated_cross; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.dv_surv_av_allocated_cross AS
 SELECT DISTINCT well_list.api_no14,
    last_dates.full_date
   FROM (( SELECT dd.last_day_of_month AS full_date
           FROM utility.date_dimension dd
          GROUP BY dd.last_day_of_month) last_dates
     CROSS JOIN ( SELECT DISTINCT mv_bi_monthly_volumes.api_no14,
            max(mv_bi_monthly_volumes.prod_inj_date) AS max_date,
            min(mv_bi_monthly_volumes.prod_inj_date) AS min_date
           FROM crc.mv_bi_monthly_volumes
          GROUP BY mv_bi_monthly_volumes.api_no14) well_list)
  WHERE ((last_dates.full_date <= well_list.max_date) AND (last_dates.full_date >= well_list.min_date))
  ORDER BY well_list.api_no14, last_dates.full_date;


ALTER TABLE surv.dv_surv_av_allocated_cross OWNER TO postgres;

--
-- TOC entry 1823 (class 1259 OID 34012682)
-- Name: dv_wd_org_units; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.dv_wd_org_units WITH (security_barrier='false') AS
 WITH kpi_sub AS (
         SELECT DISTINCT wc.api_no14,
            wc.wellcomp_name AS name,
            wc.org_seqno,
            wc.field_name,
            wc.reg_name,
            ou.at_name,
            ou.subat_name,
                CASE
                    WHEN (upper(wc.reg_name) = 'ELK HILLS'::text) THEN upper(wn.kpi_group)
                    ELSE
                    CASE
                        WHEN (wc.org_seqno = (1901030000)::numeric) THEN 'PICO'::text
                        ELSE
                        CASE
                            WHEN (wc.org_seqno = (1901000000)::numeric) THEN 'LONG BEACH UNIT'::text
                            ELSE
                            CASE
                                WHEN (upper(wc.orglev4_name) = ANY (ARRAY['NPR2E'::text, 'NPR2W'::text, 'SPRB'::text, 'NPR1'::text, 'SPRA'::text])) THEN 'TIDELANDS'::text
                                ELSE
                                CASE
                                    WHEN (upper(wc.at_name) = 'TIDELANDS'::text) THEN 'TIDELANDS'::text
                                    ELSE
                                    CASE
WHEN (upper(wc.orglev4_name) = 'GENERAL'::text) THEN
CASE
 WHEN (upper(ou.subat_name) = 'GENERAL'::text) THEN
 CASE
  WHEN (upper(ou.at_name) = 'GENERAL'::text) THEN upper(wc.reg_name)
  ELSE upper(ou.at_name)
 END
 ELSE upper(ou.subat_name)
END
ELSE upper(ou.orglev4_name)
                                    END
                                END
                            END
                        END
                    END
                END AS orglev4_name,
            wn.kpi_group,
            wc.reservoir_cd
           FROM ((crc.mv_bi_wellcomp_v wc
             LEFT JOIN ds_ekpspp.dss_wn_team wn ON (((wc.reservoir_cd = wn.reservoir_cd) AND (wc.cost_center = wn.cost_center))))
             LEFT JOIN ds_ekpspp.mast_organization_unit ou ON ((wc.org_seqno = ou.org_seqno)))
          WHERE ((wc.curr_comp_status !~~ 'CANCEL'::text) AND (wc.curr_comp_status !~~ 'APPROVED'::text))
        )
 SELECT DISTINCT kk.api_no14,
    kk.name,
    kk.org_seqno,
    kk.field_name,
    kk.reg_name,
    kk.at_name,
    kk.subat_name,
    kk.orglev4_name,
    oo.op_area,
    oo.subsurf_name
   FROM (kpi_sub kk
     LEFT JOIN ( SELECT crcplan_tborg_xref.field,
            crcplan_tborg_xref.op_area,
            crcplan_tborg_xref.subsurf_name
           FROM ds_usoxybip.crcplan_tborg_xref
          WHERE (crcplan_tborg_xref.op_area <> 'Exploration'::text)) oo ON ((upper(kk.orglev4_name) = upper(oo.field))));


ALTER TABLE surv.dv_wd_org_units OWNER TO postgres;

--
-- TOC entry 1890 (class 1259 OID 36944173)
-- Name: dv_wd_org_units2; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.dv_wd_org_units2 AS
 SELECT DISTINCT wc.api_no14,
    wc.wellcomp_name AS name,
    wc.org_seqno,
    wc.field AS field_name,
    wc.op_area AS reg_name,
    wc.op_sub_area AS at_name,
    wc.subsurf_name AS subat_name
   FROM crc.mv_bi_wellcomp_v2 wc
  WHERE ((wc.curr_comp_status !~~ 'CANCEL'::text) AND (wc.curr_comp_status !~~ 'APPROVED'::text));


ALTER TABLE surv.dv_wd_org_units2 OWNER TO postgres;

--
-- TOC entry 1835 (class 1259 OID 34013063)
-- Name: dv_wd_untransformed_well_locations; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.dv_wd_untransformed_well_locations AS
 SELECT DISTINCT cc.api_no14,
    COALESCE(ww.top_bore_latitude, ww.btm_bore_latitude, (0)::double precision) AS top_bore_latitude,
    COALESCE(ww.top_bore_longitude, ww.btm_bore_longitude, (0)::double precision) AS top_bore_longitude,
    COALESCE(ww.btm_bore_latitude, ww.top_bore_latitude, (0)::double precision) AS btm_bore_latitude,
    COALESCE(ww.btm_bore_longitude, ww.btm_bore_longitude, (0)::double precision) AS btm_bore_longitude,
    pp.geo_zone_id,
    pp.geo_datum_id
   FROM (((crc.mv_bi_wellcomp_v cc
     JOIN crc.mv_bi_wellbore ww ON (("substring"(cc.api_no14, 1, 12) = ww.api_no12)))
     JOIN crc_edm.mv_dv_well_proj_sys ee ON ((ww.well_id = ee.well_id)))
     LEFT JOIN crc_edm.mv_u_cd_project pp ON (((ee.policy_id = pp.policy_id) AND (ee.project_id = pp.project_id))));


ALTER TABLE surv.dv_wd_untransformed_well_locations OWNER TO postgres;

--
-- TOC entry 1891 (class 1259 OID 36944178)
-- Name: dv_wd_untransformed_well_locations2; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.dv_wd_untransformed_well_locations2 AS
 SELECT DISTINCT cc.api_no14,
        CASE
            WHEN (ww.top_bore_latitude = (0)::double precision) THEN NULL::double precision
            ELSE ww.top_bore_latitude
        END AS top_bore_latitude,
        CASE
            WHEN (ww.top_bore_longitude = (0)::double precision) THEN NULL::double precision
            ELSE ww.top_bore_longitude
        END AS top_bore_longitude,
        CASE
            WHEN (ww.btm_bore_latitude = (0)::double precision) THEN NULL::double precision
            ELSE ww.btm_bore_latitude
        END AS btm_bore_latitude,
        CASE
            WHEN (ww.btm_bore_longitude = (0)::double precision) THEN NULL::double precision
            ELSE ww.btm_bore_longitude
        END AS btm_bore_longitude,
    pp.geo_zone_id,
    pp.geo_datum_id
   FROM (((crc.mv_bi_wellcomp_v2 cc
     JOIN crc.mv_bi_wellbore ww ON (("substring"(cc.api_no14, 1, 12) = ww.api_no12)))
     JOIN crc_edm.mv_dv_well_proj_sys ee ON ((ww.well_id = ee.well_id)))
     LEFT JOIN crc_edm.mv_u_cd_project pp ON (((ee.policy_id = pp.policy_id) AND (ee.project_id = pp.project_id))))
  WHERE (((ww.top_bore_latitude IS NOT NULL) AND (ww.top_bore_latitude <> (0)::double precision) AND (ww.top_bore_longitude IS NOT NULL) AND (ww.top_bore_longitude <> (0)::double precision)) OR ((ww.btm_bore_latitude IS NOT NULL) AND (ww.btm_bore_latitude <> (0)::double precision) AND (ww.btm_bore_longitude IS NOT NULL) AND (ww.btm_bore_longitude <> (0)::double precision)));


ALTER TABLE surv.dv_wd_untransformed_well_locations2 OWNER TO postgres;

SET default_tablespace = '';

--
-- TOC entry 1836 (class 1259 OID 34013069)
-- Name: mv_dv_wd_untransformed_well_locations; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_dv_wd_untransformed_well_locations AS
 SELECT dv_wd_untransformed_well_locations.api_no14,
    dv_wd_untransformed_well_locations.top_bore_latitude,
    dv_wd_untransformed_well_locations.top_bore_longitude,
    dv_wd_untransformed_well_locations.btm_bore_latitude,
    dv_wd_untransformed_well_locations.btm_bore_longitude,
    dv_wd_untransformed_well_locations.geo_zone_id,
    dv_wd_untransformed_well_locations.geo_datum_id
   FROM surv.dv_wd_untransformed_well_locations
  WITH NO DATA;


ALTER TABLE surv.mv_dv_wd_untransformed_well_locations OWNER TO postgres;

--
-- TOC entry 1821 (class 1259 OID 34012672)
-- Name: dv_wd_well_locations; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.dv_wd_well_locations AS
 SELECT DISTINCT wc.api_no14,
        CASE
            WHEN (wc.geo_datum_id = 'NAD27'::text) THEN public.st_y(public.st_transform(public.st_setsrid(public.st_makepoint(wc.btm_bore_longitude, wc.btm_bore_latitude), 4267), 4152))
            ELSE wc.btm_bore_latitude
        END AS bh_latitude,
        CASE
            WHEN (wc.geo_datum_id = 'NAD27'::text) THEN public.st_x(public.st_transform(public.st_setsrid(public.st_makepoint(wc.btm_bore_longitude, wc.btm_bore_latitude), 4267), 4152))
            ELSE wc.btm_bore_longitude
        END AS bh_longitude,
        CASE
            WHEN (wc.geo_datum_id = 'NAD27'::text) THEN public.st_y(public.st_transform(public.st_setsrid(public.st_makepoint(wc.top_bore_longitude, wc.top_bore_latitude), 4267), 4152))
            ELSE wc.top_bore_latitude
        END AS surface_latitude,
        CASE
            WHEN (wc.geo_datum_id = 'NAD27'::text) THEN public.st_x(public.st_transform(public.st_setsrid(public.st_makepoint(wc.top_bore_longitude, wc.top_bore_latitude), 4267), 4152))
            ELSE wc.top_bore_longitude
        END AS surface_longitude
   FROM surv.mv_dv_wd_untransformed_well_locations wc;


ALTER TABLE surv.dv_wd_well_locations OWNER TO postgres;

--
-- TOC entry 1824 (class 1259 OID 34012687)
-- Name: dv_wd_well_dictionary; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.dv_wd_well_dictionary WITH (security_barrier='false') AS
 SELECT DISTINCT wc.api_no14,
    wc.completion_id,
    ou.op_area,
    ou.field_name,
    ou.reg_name,
    ou.at_name,
    ou.subat_name,
    ou.orglev4_name,
    first_value(wn.kpi_group) OVER (PARTITION BY wc.api_no14) AS kpi_group,
    wc.legacy_well_seq_no,
    wc.legacy_zone_seq_no,
    wc.well_id,
    NULL::text AS wellbore_id,
    wc.wellbore_name,
    wc.wellcomp_name AS well_name,
    NULL::text AS ptype,
    wc.curr_comp_type AS currenttype,
        CASE
            WHEN (wc.curr_comp_status ~~ 'D & A'::text) THEN 'P & A'::text
            WHEN (wc.curr_comp_status ~~ 'SHUT-IN'::text) THEN 'INACTIVE'::text
            WHEN (wc.curr_comp_status ~~ 'DRY'::text) THEN 'P & A'::text
            ELSE wc.curr_comp_status
        END AS currentstatus,
    wc.status_eff_date,
    wc.country_cd,
    wc.state_no,
    wc.county_no,
    (wc.oper_no)::numeric AS operatingcompany,
    wc.field_no,
    wc.reservoir_cd,
    wc.org_seqno,
    wc.cost_center,
    wc.legacy_zone_id,
    (wc.unit_no)::numeric AS unit_no,
    wc.unit_tract_cd,
        CASE
            WHEN (wc.bottom_hole_tmd > (100000)::numeric) THEN NULL::numeric
            ELSE wc.bottom_hole_tmd
        END AS bottom_hole_tmd,
    wc.top_interval_tvd,
    wc.btm_interval_tvd,
    (wc.top_interval_tmd)::numeric AS topmd,
    (wc.btm_interval_tmd)::numeric AS bottommd,
    wc.type_interval,
    wc.well_spud_date,
    wc.completion_date,
    wc.connection_date,
    wc.first_prod_date,
    wc.property_name,
    wc.curr_method_prod,
    wc.legacy_zone_seqno_char,
    wc.automation_name,
    wc.battery_name,
    xy.surface_latitude AS surf_latitude,
    xy.surface_longitude AS surf_longitude,
    xy.bh_latitude,
    xy.bh_longitude,
    wc.comp_sk,
    wc.interest_type,
    concat(wc.curr_comp_type, '-', wc.curr_comp_status) AS map_symbol,
    wc.parentpid,
    NULL::text AS top_x,
    NULL::text AS top_y,
    (wb.btm_bore_coord_x)::numeric AS bottomx,
    (wb.btm_bore_coord_y)::numeric AS bottomy,
    wb.kickoff_date,
    w.section,
    w.pf_no,
    w.township,
    w.township_direction,
    (w.range_no)::numeric AS range_no,
    w.range_direction,
    (w.def_elevation)::numeric AS ground_elevation,
    w.test_facility,
    NULL::text AS well_legal_name,
    cc.structure_code,
    cc.fault_block,
    cc.sector,
    cc.team,
    cc.remark
   FROM ((((((crc.mv_bi_wellcomp_v wc
     LEFT JOIN crc.mv_bi_wellbore wb ON (("substring"(wc.api_no14, 0, 12) = wb.api_no12)))
     LEFT JOIN crc.mv_bi_well w ON (("substring"(wc.api_no14, 0, 10) = w.api_no10)))
     LEFT JOIN ds_ekpspp.dss_wn_team wn ON (((wc.reservoir_cd = wn.reservoir_cd) AND (wc.cost_center = wn.cost_center))))
     LEFT JOIN surv.dv_wd_well_locations xy ON (("substring"(wc.api_no14, 1, 12) = "substring"(xy.api_no14, 1, 12))))
     LEFT JOIN surv.dv_wd_org_units ou ON ((wc.api_no14 = ou.api_no14)))
     LEFT JOIN crc_dss.u_dss_compmaster cc ON ((wc.api_no14 = cc.pid)))
  WHERE (ou.op_area <> 'EXPLORATION'::text);


ALTER TABLE surv.dv_wd_well_dictionary OWNER TO postgres;

--
-- TOC entry 1892 (class 1259 OID 36944183)
-- Name: dv_wd_well_dictionary2; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.dv_wd_well_dictionary2 AS
 SELECT DISTINCT wc.api_no14,
    wc.completion_id,
    wc.op_area,
    wc.field_name,
    wc.reg_name,
    wc.at_name,
    wc.subat_name,
    wc.orglev4_name,
    first_value(wn.kpi_group) OVER (PARTITION BY wc.api_no14) AS kpi_group,
    wc.legacy_well_seq_no,
    wc.legacy_zone_seq_no,
    wc.well_id,
    NULL::text AS wellbore_id,
    wc.wellbore_name,
    wc.wellcomp_name AS well_name,
    NULL::text AS ptype,
    wc.curr_comp_type AS currenttype,
        CASE
            WHEN (wc.curr_comp_status ~~ 'D & A'::text) THEN 'P & A'::text
            WHEN (wc.curr_comp_status ~~ 'SHUT-IN'::text) THEN 'INACTIVE'::text
            WHEN (wc.curr_comp_status ~~ 'DRY'::text) THEN 'P & A'::text
            ELSE wc.curr_comp_status
        END AS currentstatus,
    wc.status_eff_date,
    wc.country_cd,
    wc.state_no,
    wc.county_no,
    (wc.oper_no)::numeric AS operatingcompany,
    wc.field_no,
    wc.reservoir_cd,
    wc.org_seqno,
    wc.cost_center,
    wc.legacy_zone_id,
    (wc.unit_no)::numeric AS unit_no,
    wc.unit_tract_cd,
        CASE
            WHEN (wc.bottom_hole_tmd > (100000)::numeric) THEN NULL::numeric
            ELSE wc.bottom_hole_tmd
        END AS bottom_hole_tmd,
    wc.top_interval_tvd,
    wc.btm_interval_tvd,
    (wc.top_interval_tmd)::numeric AS topmd,
    (wc.btm_interval_tmd)::numeric AS bottommd,
    wc.type_interval,
    wc.well_spud_date,
    wc.completion_date,
    wc.connection_date,
    wc.first_prod_date,
    wc.property_name,
    wc.curr_method_prod,
    wc.legacy_zone_seqno_char,
    wc.automation_name,
    wc.battery_name,
    xy.surface_latitude AS surf_latitude,
    xy.surface_longitude AS surf_longitude,
    xy.bh_latitude,
    xy.bh_longitude,
    wc.comp_sk,
    wc.interest_type,
    concat(wc.curr_comp_type, '-', wc.curr_comp_status) AS map_symbol,
    wc.parentpid,
    NULL::text AS top_x,
    NULL::text AS top_y,
    (wb.btm_bore_coord_x)::numeric AS bottomx,
    (wb.btm_bore_coord_y)::numeric AS bottomy,
    wb.kickoff_date,
    w.section,
    w.pf_no,
    w.township,
    w.township_direction,
    (w.range_no)::numeric AS range_no,
    w.range_direction,
    (w.def_elevation)::numeric AS ground_elevation,
    w.test_facility,
    NULL::text AS well_legal_name,
    cc.structure_code,
    cc.fault_block,
    cc.sector,
    cc.team,
    cc.remark
   FROM (((((crc.mv_bi_wellcomp_v2 wc
     LEFT JOIN crc.mv_bi_wellbore wb ON (("substring"(wc.api_no14, 0, 12) = wb.api_no12)))
     LEFT JOIN crc.mv_bi_well w ON (("substring"(wc.api_no14, 0, 10) = w.api_no10)))
     LEFT JOIN ds_ekpspp.dss_wn_team wn ON (((wc.reservoir_cd = wn.reservoir_cd) AND (wc.cost_center = wn.cost_center))))
     LEFT JOIN surv.dv_wd_well_locations xy ON (("substring"(wc.api_no14, 1, 12) = "substring"(xy.api_no14, 1, 12))))
     LEFT JOIN crc_dss.u_dss_compmaster cc ON ((wc.api_no14 = cc.pid)))
  WHERE ((wc.curr_comp_status !~~ 'CANCEL'::text) AND (wc.curr_comp_status !~~ 'APPROVED'::text));


ALTER TABLE surv.dv_wd_well_dictionary2 OWNER TO postgres;

--
-- TOC entry 2042 (class 1259 OID 56269266)
-- Name: fv_surv_allocated_volume_calcs; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_surv_allocated_volume_calcs WITH (security_barrier='false') AS
 SELECT ac.api_no14,
    ac.full_date AS allocated_date,
    (COALESCE((((vol.days_prod)::numeric)::smallint)::integer, 0))::smallint AS days_prod,
    (COALESCE((((vol.days_inject)::numeric)::smallint)::integer, 0))::smallint AS days_inject,
    COALESCE(vol.oil_prod, (0)::real) AS oil_prod,
    ((COALESCE(vol.gwg_prod, (0)::real) + COALESCE(vol.owg_prod, (0)::real)) + COALESCE(vol.nitrogen_prod, (0)::real)) AS gas_prod,
    COALESCE(vol.cond_prod, (0)::real) AS cond_prod,
    COALESCE(vol.water_prod, (0)::real) AS water_prod,
    (COALESCE(vol.oil_prod, ((0)::numeric)::real) + COALESCE(vol.water_prod, ((0)::numeric)::real)) AS gross_liq_prod,
    COALESCE(vol.water_inj, (0)::real) AS water_inj,
    COALESCE(vol.gas_inj, (0)::real) AS gas_inj,
    COALESCE(vol.disp_water_inj, (0)::real) AS disp_water_inj,
    COALESCE(vol.cyclic_steam_inj, (0)::real) AS cyclic_steam_inj,
    COALESCE(vol.steam_inj, (0)::real) AS steam_inj,
    COALESCE((vol.hrs_prod)::real, (0)::real) AS hrs_prod,
    COALESCE((vol.hrs_inject)::real, (0)::real) AS hrs_inject,
    COALESCE((((vol.oil_prod / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdoil_prod,
    COALESCE(((((COALESCE(vol.oil_prod, (0)::real) + COALESCE(vol.water_prod, (0)::real)) / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdgross_liq_prod,
    COALESCE((((vol.cond_prod / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdcond_prod,
    COALESCE((((((COALESCE(vol.gwg_prod, (0)::real) + COALESCE(vol.owg_prod, (0)::real)) + COALESCE(vol.nitrogen_prod, (0)::real)) / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdgas_prod,
    COALESCE((((vol.water_prod / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdwater_prod,
    COALESCE((((vol.gas_inj / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdgas_inj,
    COALESCE((((vol.water_inj / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdwater_inj,
    COALESCE((((vol.cyclic_steam_inj / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdsteamc_inj,
    COALESCE((((vol.steam_inj / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cdsteam_inj,
    COALESCE((((vol.disp_water_inj / (((date_part('day'::text, vol.prod_inj_date))::numeric)::smallint)::double precision))::numeric)::real, (0)::real) AS cddispwat_inj,
    ((
        CASE
            WHEN (((COALESCE(vol.gwg_prod, ((0)::numeric)::real) + COALESCE(vol.owg_prod, ((0)::numeric)::real)) + COALESCE(vol.nitrogen_prod, ((0)::numeric)::real)) = (0)::double precision) THEN (0)::double precision
            ELSE (((vol.oil_prod)::numeric)::double precision / ((COALESCE(vol.gwg_prod, ((0)::numeric)::real) + COALESCE(vol.owg_prod, ((0)::numeric)::real)) + COALESCE(vol.nitrogen_prod, ((0)::numeric)::real)))
        END)::numeric)::real AS ogr_prod,
    ((
        CASE
            WHEN ((COALESCE(vol.oil_prod, ((0)::numeric)::real) + COALESCE(vol.water_prod, ((0)::numeric)::real)) = (0)::double precision) THEN (0)::double precision
            ELSE (((vol.oil_prod)::numeric)::double precision / (COALESCE(vol.oil_prod, ((0)::numeric)::real) + COALESCE(vol.water_prod, ((0)::numeric)::real)))
        END)::numeric)::real AS ocut_prod,
    ((
        CASE
            WHEN ((COALESCE(vol.oil_prod, ((0)::numeric)::real) + COALESCE(vol.water_prod, ((0)::numeric)::real)) = (0)::double precision) THEN (0)::real
            ELSE (((COALESCE(vol.gwg_prod, ((0)::numeric)::real) + COALESCE(vol.owg_prod, ((0)::numeric)::real)) + COALESCE(vol.nitrogen_prod, ((0)::numeric)::real)) / (COALESCE(vol.oil_prod, ((0)::numeric)::real) + COALESCE(vol.water_prod, ((0)::numeric)::real)))
        END)::numeric)::real AS glr_prod,
    ((
        CASE
            WHEN (COALESCE(vol.oil_prod, ((0)::numeric)::real) = (0)::double precision) THEN (0)::real
            ELSE (((COALESCE(vol.gwg_prod, ((0)::numeric)::real) + COALESCE(vol.owg_prod, ((0)::numeric)::real)) + COALESCE(vol.nitrogen_prod, ((0)::numeric)::real)) / vol.oil_prod)
        END)::numeric)::real AS gor_prod,
    ((
        CASE
            WHEN (COALESCE(vol.oil_prod, ((0)::numeric)::real) = (0)::double precision) THEN (0)::real
            ELSE (vol.water_prod / vol.oil_prod)
        END)::numeric)::real AS wor_prod,
    ((
        CASE
            WHEN (((COALESCE(vol.gwg_prod, ((0)::numeric)::real) + COALESCE(vol.owg_prod, ((0)::numeric)::real)) + COALESCE(vol.nitrogen_prod, ((0)::numeric)::real)) = (0)::double precision) THEN (0)::real
            ELSE (vol.water_prod / ((COALESCE(vol.gwg_prod, ((0)::numeric)::real) + COALESCE(vol.owg_prod, ((0)::numeric)::real)) + COALESCE(vol.nitrogen_prod, ((0)::numeric)::real)))
        END)::numeric)::real AS wgr_prod,
    ((
        CASE
            WHEN ((COALESCE(vol.oil_prod, ((0)::numeric)::real) + COALESCE(vol.water_prod, ((0)::numeric)::real)) = (0)::double precision) THEN (0)::real
            ELSE (COALESCE(vol.water_prod, ((0)::numeric)::real) / (COALESCE(vol.oil_prod, ((0)::numeric)::real) + COALESCE(vol.water_prod, ((0)::numeric)::real)))
        END)::numeric)::real AS water_cut_prod,
    (((date_part('month'::text, vol.prod_inj_date) - date_part('month'::text, min(vol.prod_inj_date) OVER (PARTITION BY vol.api_no14))) + ((date_part('year'::text, vol.prod_inj_date) - date_part('year'::text, min(vol.prod_inj_date) OVER (PARTITION BY vol.api_no14))) * (12)::double precision)))::numeric AS month_norm
   FROM (crc.mv_bi_monthly_volumes vol
     RIGHT JOIN surv.dv_surv_av_allocated_cross ac ON (((vol.api_no14 = ac.api_no14) AND (vol.prod_inj_date = ac.full_date))));


ALTER TABLE surv.fv_surv_allocated_volume_calcs OWNER TO postgres;

--
-- TOC entry 2041 (class 1259 OID 56269261)
-- Name: fv_surv_allocated_volume_cums; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_surv_allocated_volume_cums AS
 SELECT mv_bi_monthly_volumes.api_no14,
    mv_bi_monthly_volumes.prod_inj_date AS allocated_date,
    sum(mv_bi_monthly_volumes.oil_prod) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS oil_cum,
    sum(((COALESCE(mv_bi_monthly_volumes.gwg_prod, ((0)::numeric)::real) + COALESCE(mv_bi_monthly_volumes.owg_prod, ((0)::numeric)::real)) + COALESCE(mv_bi_monthly_volumes.nitrogen_prod, ((0)::numeric)::real))) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gas_cum,
    sum((mv_bi_monthly_volumes.water_prod + mv_bi_monthly_volumes.oil_prod)) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gross_cum,
    sum(mv_bi_monthly_volumes.water_prod) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS water_cum,
    sum(mv_bi_monthly_volumes.water_inj) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS water_inj_cum,
    sum(mv_bi_monthly_volumes.gas_inj) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gas_inj_cum,
    sum(mv_bi_monthly_volumes.steam_inj) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS steam_inj_cum,
    sum(mv_bi_monthly_volumes.cyclic_steam_inj) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS steamc_inj_cum,
    sum(mv_bi_monthly_volumes.disp_water_inj) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS disp_water_inj_cum
   FROM crc.mv_bi_monthly_volumes;


ALTER TABLE surv.fv_surv_allocated_volume_cums OWNER TO postgres;

--
-- TOC entry 2049 (class 1259 OID 61856899)
-- Name: mv_new_fv_surv_allocated_volume_calcs; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volume_calcs AS
 SELECT fv_surv_allocated_volume_calcs.api_no14,
    fv_surv_allocated_volume_calcs.allocated_date,
    fv_surv_allocated_volume_calcs.days_prod,
    fv_surv_allocated_volume_calcs.days_inject,
    fv_surv_allocated_volume_calcs.oil_prod,
    fv_surv_allocated_volume_calcs.gas_prod,
    fv_surv_allocated_volume_calcs.cond_prod,
    fv_surv_allocated_volume_calcs.water_prod,
    fv_surv_allocated_volume_calcs.gross_liq_prod,
    fv_surv_allocated_volume_calcs.water_inj,
    fv_surv_allocated_volume_calcs.gas_inj,
    fv_surv_allocated_volume_calcs.disp_water_inj,
    fv_surv_allocated_volume_calcs.cyclic_steam_inj,
    fv_surv_allocated_volume_calcs.steam_inj,
    fv_surv_allocated_volume_calcs.hrs_prod,
    fv_surv_allocated_volume_calcs.hrs_inject,
    fv_surv_allocated_volume_calcs.cdoil_prod,
    fv_surv_allocated_volume_calcs.cdgross_liq_prod,
    fv_surv_allocated_volume_calcs.cdcond_prod,
    fv_surv_allocated_volume_calcs.cdgas_prod,
    fv_surv_allocated_volume_calcs.cdwater_prod,
    fv_surv_allocated_volume_calcs.cdgas_inj,
    fv_surv_allocated_volume_calcs.cdwater_inj,
    fv_surv_allocated_volume_calcs.cdsteamc_inj,
    fv_surv_allocated_volume_calcs.cdsteam_inj,
    fv_surv_allocated_volume_calcs.cddispwat_inj,
    fv_surv_allocated_volume_calcs.ogr_prod,
    fv_surv_allocated_volume_calcs.ocut_prod,
    fv_surv_allocated_volume_calcs.glr_prod,
    fv_surv_allocated_volume_calcs.gor_prod,
    fv_surv_allocated_volume_calcs.wor_prod,
    fv_surv_allocated_volume_calcs.wgr_prod,
    fv_surv_allocated_volume_calcs.water_cut_prod,
    fv_surv_allocated_volume_calcs.month_norm
   FROM surv.fv_surv_allocated_volume_calcs
  WITH NO DATA;


ALTER TABLE surv.mv_new_fv_surv_allocated_volume_calcs OWNER TO postgres;

--
-- TOC entry 2040 (class 1259 OID 56269256)
-- Name: fv_surv_allocated_volume_var; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_surv_allocated_volume_var WITH (security_barrier='false') AS
 SELECT avc.api_no14,
    ac.full_date AS allocated_date,
    (avc.cdoil_prod - COALESCE((lag(avc.cdoil_prod) OVER (PARTITION BY avc.api_no14 ORDER BY ac.full_date))::double precision, ((0)::numeric)::double precision)) AS cdoil_prod_var,
    (avc.cdgas_prod - COALESCE((lag(avc.cdgas_prod) OVER (PARTITION BY avc.api_no14 ORDER BY ac.full_date))::double precision, ((0)::numeric)::double precision)) AS cdgas_prod_var,
    (avc.cdwater_prod - COALESCE((lag(avc.cdwater_prod) OVER (PARTITION BY avc.api_no14 ORDER BY ac.full_date))::double precision, ((0)::numeric)::double precision)) AS cdwat_prod_var,
    (avc.cdgross_liq_prod - COALESCE((lag(avc.cdgross_liq_prod) OVER (PARTITION BY avc.api_no14 ORDER BY ac.full_date))::double precision, ((0)::numeric)::double precision)) AS cdgross_liq_prod_var,
    (avc.cdwater_inj - COALESCE((lag(avc.cdwater_inj) OVER (PARTITION BY avc.api_no14 ORDER BY ac.full_date))::double precision, ((0)::numeric)::double precision)) AS cdwat_inj_var,
    (avc.cdgas_inj - COALESCE((lag(avc.cdgas_inj) OVER (PARTITION BY avc.api_no14 ORDER BY ac.full_date))::double precision, ((0)::numeric)::double precision)) AS cdgas_inj_var,
    (avc.cdsteam_inj - COALESCE((lag(avc.cdsteam_inj) OVER (PARTITION BY avc.api_no14 ORDER BY ac.full_date))::double precision, ((0)::numeric)::double precision)) AS cdsteam_inj_var,
    (avc.cdsteamc_inj - COALESCE((lag(avc.cdsteamc_inj) OVER (PARTITION BY avc.api_no14 ORDER BY ac.full_date))::double precision, ((0)::numeric)::double precision)) AS cdsteamc_inj_var
   FROM (surv.mv_new_fv_surv_allocated_volume_calcs avc
     RIGHT JOIN surv.dv_surv_av_allocated_cross ac ON (((avc.api_no14 = ac.api_no14) AND (avc.allocated_date = ac.full_date))))
  WHERE (ac.full_date > (now() - '365 days'::interval));


ALTER TABLE surv.fv_surv_allocated_volume_var OWNER TO postgres;

--
-- TOC entry 2039 (class 1259 OID 56269251)
-- Name: fv_surv_daily_injection; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_surv_daily_injection AS
 SELECT cc.api_no14,
    ii.test_date AS inj_date,
    ii.inj_fluid_type,
    ii.inj_rate
   FROM (( SELECT ods_oxy_injection_data.api_no14,
            ods_oxy_injection_data.daily_inj_date AS test_date,
            ods_oxy_injection_data.inj_fluid_type,
            ods_oxy_injection_data.inj_rate
           FROM ds_ekpspp.ods_oxy_injection_data
        UNION
         SELECT fv_ingres_daily_inj_la_basin.api_no14,
            fv_ingres_daily_inj_la_basin.daily_inj_date AS test_date,
            fv_ingres_daily_inj_la_basin.inj_fluid_type,
            fv_ingres_daily_inj_la_basin.inj_rate
           FROM ingres.mv_fv_daily_inj_ingres fv_ingres_daily_inj_la_basin) ii
     JOIN crc.mv_bi_wellcomp_v cc ON ((ii.api_no14 = cc.api_no14)));


ALTER TABLE surv.fv_surv_daily_injection OWNER TO postgres;

--
-- TOC entry 2038 (class 1259 OID 56269246)
-- Name: fv_surv_well_events; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_surv_well_events WITH (security_barrier='false') AS
 SELECT DISTINCT ww.api_no14,
    ee.date_ops_end AS event_date,
    'OpenWells Events'::text AS source,
    concat(COALESCE(upper(ee.event_type), ''::text), ' -- ', COALESCE(upper(ee.event_objective_1), ''::text), ' ', COALESCE(upper(ee.event_objective_2), ''::text)) AS comments
   FROM (bi.fv_wellcomp ww
     JOIN crc_edm.u_dm_event_t ee ON ((ww.well_id = ee.well_id)))
  WHERE ((ee.date_ops_end IS NOT NULL) AND (ee.event_type IS NOT NULL));


ALTER TABLE surv.fv_surv_well_events OWNER TO postgres;

--
-- TOC entry 2037 (class 1259 OID 56269241)
-- Name: fv_surv_well_notes; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_surv_well_notes WITH (security_barrier='false') AS
 SELECT DISTINCT
        CASE
            WHEN (wn.api_no14 IS NULL) THEN
            CASE
                WHEN (wc.api_no14 IS NULL) THEN wc2.api_no14
                ELSE wc.api_no14
            END
            ELSE wn.api_no14
        END AS api_no14,
    wn.comment_date,
    wn.comment_by,
    wn.source,
    wn.comments,
    md.mindate,
    md.maxdate
   FROM (((crc.mv_bi_well_notes wn
     LEFT JOIN crc.mv_bi_wellcomp wc ON ((wc.automation_name = wn.well_name)))
     LEFT JOIN crc.mv_bi_wellcomp wc2 ON ((wn.well_name = wc2.wellcomp_name)))
     LEFT JOIN ( SELECT mv_bi_monthly_volumes.api_no14,
            min(mv_bi_monthly_volumes.prod_inj_date) AS mindate,
            max(mv_bi_monthly_volumes.prod_inj_date) AS maxdate
           FROM crc.mv_bi_monthly_volumes
          GROUP BY mv_bi_monthly_volumes.api_no14) md ON ((md.api_no14 = wn.api_no14)))
  WHERE ((wn.api_no14 IS NOT NULL) AND (wn.comment_date IS NOT NULL) AND (md.mindate IS NOT NULL) AND (md.maxdate IS NOT NULL) AND (wn.comment_date >= md.mindate) AND (wn.comment_date <= md.maxdate));


ALTER TABLE surv.fv_surv_well_notes OWNER TO postgres;

--
-- TOC entry 2036 (class 1259 OID 56269236)
-- Name: fv_surv_well_test; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_surv_well_test AS
 SELECT DISTINCT ii.api_no14,
    ii.well_test_date AS test_date,
    mm.last_test_date,
    ii.test_type,
    ii.oil_rate,
    ii.gas_rate,
    ii.water_rate,
    ii.gas_lift_rate,
    ii.gas_oil_ratio,
    ii.tubing_press,
    ii.casing_press,
    ii.line_press,
    ii.allocatable,
    ii.oil_gravity,
    ii.choke_size,
    ii.pump_eff,
    ii.water_cut,
    ii.stroke_length,
    ii.strokes_minute,
    ii.pump_bore_size,
    ii.prod_hours,
    ii.test_hours,
    ii.hertz,
    ii.amps,
    ii.fluid_level,
    ii.pump_intake_press,
    ii.wellhead_temp,
    ii.salinity,
    ii.bsw
   FROM ((crc.mv_bi_well_test ii
     JOIN crc.bi_wellcomp_v cc ON ((ii.api_no14 = cc.api_no14)))
     JOIN ( SELECT mv_bi_well_test.api_no14,
            max(mv_bi_well_test.well_test_date) AS last_test_date
           FROM crc.mv_bi_well_test
          GROUP BY mv_bi_well_test.api_no14) mm ON ((ii.api_no14 = mm.api_no14)));


ALTER TABLE surv.fv_surv_well_test OWNER TO postgres;

--
-- TOC entry 1822 (class 1259 OID 34012677)
-- Name: fv_surv_wellbore_openings; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_surv_wellbore_openings AS
 WITH last_stat AS (
         SELECT u_cd_opening_status_t.well_id,
            u_cd_opening_status_t.wellbore_id,
            u_cd_opening_status_t.wellbore_opening_id,
            max(u_cd_opening_status_t.effective_date) AS max_status_date
           FROM crc_edm.u_cd_opening_status_t
          GROUP BY u_cd_opening_status_t.well_id, u_cd_opening_status_t.wellbore_id, u_cd_opening_status_t.wellbore_opening_id
        )
 SELECT DISTINCT ow.policy_id,
    ow.project_id,
    ow.site_id,
    ow.well_id,
    ow.tight_group_id,
    ow.datum_id,
    ow.wellbore_id,
    ols.wellbore_opening_id,
    wo.master_id,
    wo.detail_id,
    ow.business_unit,
    ow.field_name,
    ow.site_name,
    ow.well_common_name,
    ow.api_no10,
    ow.well_seq_no,
    ow.wellbore_no,
    ow.wellbore_name,
    ow.wellbore_label,
    ow.api_no12,
    (ow.top_md)::numeric AS wellbore_top_md,
    (ow.top_tvd)::numeric AS wellbore_top_tvd,
    (ow.btm_md)::numeric AS wellbore_btm_md,
    (ow.btm_tvd)::numeric AS wellbore_btm_tvd,
    wo.opening_type,
    ((ow.default_datum_elev + wo.md_top))::numeric AS opening_top_md,
    ((ow.default_datum_elev + wo.md_base))::numeric AS opening_btm_md,
    ((wo.md_base - wo.md_top))::numeric AS opening_length,
    wo.effective_date,
    wo.opening_reason,
    pi.date_interval_shot AS date_perfs_shot,
    (pi.shot_density)::numeric AS shot_density,
    (pi.charge_phasing)::numeric AS shot_phasing,
    (pi.gun_diam_max)::numeric AS shot_diam,
    os.status AS current_status,
    ols.max_status_date AS current_status_date
   FROM ((((crc_edm.u_cd_opening_status_t os
     RIGHT JOIN last_stat ols ON (((os.effective_date = ols.max_status_date) AND (os.well_id = ols.well_id) AND (os.wellbore_id = ols.wellbore_id) AND (os.wellbore_opening_id = ols.wellbore_opening_id))))
     JOIN crc_edm.u_cd_wellbore_opening_t wo ON (((ols.wellbore_opening_id = wo.wellbore_opening_id) AND (ols.wellbore_id = wo.wellbore_id) AND (ols.well_id = wo.well_id))))
     RIGHT JOIN crc_edm.dv_well_proj_sys ow ON (((ow.well_id = wo.well_id) AND (ow.wellbore_id = wo.wellbore_id))))
     LEFT JOIN crc_edm.u_cd_perf_interval_t pi ON (((wo.well_id = pi.well_id) AND (wo.wellbore_id = pi.wellbore_id) AND (wo.master_id = pi.perf_id) AND (wo.detail_id = pi.perf_interval_id))));


ALTER TABLE surv.fv_surv_wellbore_openings OWNER TO postgres;

--
-- TOC entry 1884 (class 1259 OID 36944033)
-- Name: old_dv_av_allocated_cross; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.old_dv_av_allocated_cross AS
 WITH last_dates AS (
         SELECT DISTINCT ((date_trunc('MONTH'::text, site_specific_elk_hills_daily_dates.full_date) + '1 mon'::interval) - '1 day'::interval) AS full_date
           FROM ds_ekpspp.site_specific_elk_hills_daily_dates
        ), well_list AS (
         SELECT DISTINCT mv_bi_monthly_volumes.api_no14,
            max(mv_bi_monthly_volumes.prod_inj_date) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14) AS max_date,
            min(mv_bi_monthly_volumes.prod_inj_date) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14) AS min_date
           FROM crc.mv_bi_monthly_volumes
        )
 SELECT DISTINCT well_list.api_no14,
    last_dates.full_date
   FROM (last_dates
     CROSS JOIN well_list)
  WHERE ((last_dates.full_date <= well_list.max_date) AND (last_dates.full_date >= well_list.min_date));


ALTER TABLE surv.old_dv_av_allocated_cross OWNER TO postgres;

--
-- TOC entry 1885 (class 1259 OID 36944038)
-- Name: mv_dv_av_allocated_cross; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_dv_av_allocated_cross AS
 SELECT old_dv_av_allocated_cross.api_no14,
    old_dv_av_allocated_cross.full_date
   FROM surv.old_dv_av_allocated_cross
  WITH NO DATA;


ALTER TABLE surv.mv_dv_av_allocated_cross OWNER TO postgres;

--
-- TOC entry 1827 (class 1259 OID 34012721)
-- Name: old_dv_av_allocated_zeros; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.old_dv_av_allocated_zeros AS
 SELECT aa.api_no14,
    aa.full_date AS prod_inj_date,
        CASE
            WHEN (vv.days_prod IS NULL) THEN (0)::double precision
            ELSE vv.days_prod
        END AS days_prod,
        CASE
            WHEN (vv.days_inject IS NULL) THEN (0)::double precision
            ELSE vv.days_inject
        END AS days_inject,
        CASE
            WHEN (vv.oil_prod IS NULL) THEN ((0)::numeric)::real
            ELSE vv.oil_prod
        END AS oil_prod,
        CASE
            WHEN (vv.owg_prod IS NULL) THEN ((0)::numeric)::real
            ELSE vv.owg_prod
        END AS owg_prod,
        CASE
            WHEN (vv.gwg_prod IS NULL) THEN ((0)::numeric)::real
            ELSE vv.gwg_prod
        END AS gwg_prod,
        CASE
            WHEN (vv.cond_prod IS NULL) THEN ((0)::numeric)::real
            ELSE vv.cond_prod
        END AS cond_prod,
        CASE
            WHEN (vv.water_prod IS NULL) THEN ((0)::numeric)::real
            ELSE vv.water_prod
        END AS water_prod,
        CASE
            WHEN (vv.nitrogen_prod IS NULL) THEN ((0)::numeric)::real
            ELSE vv.nitrogen_prod
        END AS nitrogen_prod,
        CASE
            WHEN (vv.water_inj IS NULL) THEN ((0)::numeric)::real
            ELSE vv.water_inj
        END AS water_inj,
        CASE
            WHEN (vv.gas_inj IS NULL) THEN ((0)::numeric)::real
            ELSE vv.gas_inj
        END AS gas_inj,
        CASE
            WHEN (vv.disp_water_inj IS NULL) THEN ((0)::numeric)::real
            ELSE vv.disp_water_inj
        END AS disp_water_inj,
        CASE
            WHEN (vv.cyclic_steam_inj IS NULL) THEN ((0)::numeric)::real
            ELSE vv.cyclic_steam_inj
        END AS cyclic_steam_inj,
        CASE
            WHEN (vv.steam_inj IS NULL) THEN ((0)::numeric)::real
            ELSE vv.steam_inj
        END AS steam_inj,
        CASE
            WHEN (vv.hrs_prod IS NULL) THEN (0)::numeric
            ELSE vv.hrs_prod
        END AS hrs_prod,
        CASE
            WHEN (vv.hrs_inject IS NULL) THEN (0)::numeric
            ELSE vv.hrs_inject
        END AS hrs_inject
   FROM (surv.mv_dv_av_allocated_cross aa
     LEFT JOIN crc.mv_bi_monthly_volumes vv ON (((aa.api_no14 = vv.api_no14) AND (date_trunc('day'::text, aa.full_date) = date_trunc('day'::text, ((date_trunc('MONTH'::text, vv.prod_inj_date) + '1 mon'::interval) - '1 day'::interval))))));


ALTER TABLE surv.old_dv_av_allocated_zeros OWNER TO postgres;

--
-- TOC entry 1828 (class 1259 OID 34012726)
-- Name: mv_dv_av_allocated_volume_zeros; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_dv_av_allocated_volume_zeros AS
 SELECT old_dv_av_allocated_zeros.api_no14,
    old_dv_av_allocated_zeros.prod_inj_date,
    old_dv_av_allocated_zeros.days_prod,
    old_dv_av_allocated_zeros.days_inject,
    old_dv_av_allocated_zeros.oil_prod,
    old_dv_av_allocated_zeros.owg_prod,
    old_dv_av_allocated_zeros.gwg_prod,
    old_dv_av_allocated_zeros.cond_prod,
    old_dv_av_allocated_zeros.water_prod,
    old_dv_av_allocated_zeros.nitrogen_prod,
    old_dv_av_allocated_zeros.water_inj,
    old_dv_av_allocated_zeros.gas_inj,
    old_dv_av_allocated_zeros.disp_water_inj,
    old_dv_av_allocated_zeros.cyclic_steam_inj,
    old_dv_av_allocated_zeros.steam_inj,
    old_dv_av_allocated_zeros.hrs_prod,
    old_dv_av_allocated_zeros.hrs_inject
   FROM surv.old_dv_av_allocated_zeros
  WITH NO DATA;


ALTER TABLE surv.mv_dv_av_allocated_volume_zeros OWNER TO postgres;

--
-- TOC entry 1825 (class 1259 OID 34012692)
-- Name: mv_dv_wd_well_dictionary; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_dv_wd_well_dictionary AS
 SELECT dv_wd_well_dictionary.api_no14,
    dv_wd_well_dictionary.completion_id,
    dv_wd_well_dictionary.op_area,
    dv_wd_well_dictionary.field_name,
    dv_wd_well_dictionary.reg_name,
    dv_wd_well_dictionary.at_name,
    dv_wd_well_dictionary.subat_name,
    dv_wd_well_dictionary.orglev4_name,
    dv_wd_well_dictionary.kpi_group,
    dv_wd_well_dictionary.legacy_well_seq_no,
    dv_wd_well_dictionary.legacy_zone_seq_no,
    dv_wd_well_dictionary.well_id,
    dv_wd_well_dictionary.wellbore_id,
    dv_wd_well_dictionary.wellbore_name,
    dv_wd_well_dictionary.well_name,
    dv_wd_well_dictionary.ptype,
    dv_wd_well_dictionary.currenttype,
    dv_wd_well_dictionary.currentstatus,
    dv_wd_well_dictionary.status_eff_date,
    dv_wd_well_dictionary.country_cd,
    dv_wd_well_dictionary.state_no,
    dv_wd_well_dictionary.county_no,
    dv_wd_well_dictionary.operatingcompany,
    dv_wd_well_dictionary.field_no,
    dv_wd_well_dictionary.reservoir_cd,
    dv_wd_well_dictionary.org_seqno,
    dv_wd_well_dictionary.cost_center,
    dv_wd_well_dictionary.legacy_zone_id,
    dv_wd_well_dictionary.unit_no,
    dv_wd_well_dictionary.unit_tract_cd,
    dv_wd_well_dictionary.bottom_hole_tmd,
    dv_wd_well_dictionary.top_interval_tvd,
    dv_wd_well_dictionary.btm_interval_tvd,
    dv_wd_well_dictionary.topmd,
    dv_wd_well_dictionary.bottommd,
    dv_wd_well_dictionary.type_interval,
    dv_wd_well_dictionary.well_spud_date,
    dv_wd_well_dictionary.completion_date,
    dv_wd_well_dictionary.connection_date,
    dv_wd_well_dictionary.first_prod_date,
    dv_wd_well_dictionary.property_name,
    dv_wd_well_dictionary.curr_method_prod,
    dv_wd_well_dictionary.legacy_zone_seqno_char,
    dv_wd_well_dictionary.automation_name,
    dv_wd_well_dictionary.battery_name,
    dv_wd_well_dictionary.surf_latitude,
    dv_wd_well_dictionary.surf_longitude,
    dv_wd_well_dictionary.bh_latitude,
    dv_wd_well_dictionary.bh_longitude,
    dv_wd_well_dictionary.comp_sk,
    dv_wd_well_dictionary.interest_type,
    dv_wd_well_dictionary.map_symbol,
    dv_wd_well_dictionary.parentpid,
    dv_wd_well_dictionary.top_x,
    dv_wd_well_dictionary.top_y,
    dv_wd_well_dictionary.bottomx,
    dv_wd_well_dictionary.bottomy,
    dv_wd_well_dictionary.kickoff_date,
    dv_wd_well_dictionary.section,
    dv_wd_well_dictionary.pf_no,
    dv_wd_well_dictionary.township,
    dv_wd_well_dictionary.township_direction,
    dv_wd_well_dictionary.range_no,
    dv_wd_well_dictionary.range_direction,
    dv_wd_well_dictionary.ground_elevation,
    dv_wd_well_dictionary.test_facility,
    dv_wd_well_dictionary.well_legal_name,
    dv_wd_well_dictionary.structure_code,
    dv_wd_well_dictionary.fault_block,
    dv_wd_well_dictionary.sector,
    dv_wd_well_dictionary.team,
    dv_wd_well_dictionary.remark
   FROM surv.dv_wd_well_dictionary
  WITH NO DATA;


ALTER TABLE surv.mv_dv_wd_well_dictionary OWNER TO postgres;

--
-- TOC entry 1888 (class 1259 OID 36944163)
-- Name: old_dv_av_allocated_cals; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.old_dv_av_allocated_cals AS
 SELECT DISTINCT cc.api_no14,
    cc.well_name,
    pt.prod_inj_date AS allocated_date,
    cc.op_area,
    cc.reg_name,
    cc.at_name,
    cc.orglev4_name,
    cc.currenttype,
    cc.currentstatus,
    pt.days_prod,
    pt.days_inject,
    pt.oil_prod,
    ((COALESCE(pt.gwg_prod, ((0)::numeric)::real) + COALESCE(pt.owg_prod, ((0)::numeric)::real)) + COALESCE(pt.nitrogen_prod, ((0)::numeric)::real)) AS gas_prod,
    pt.cond_prod,
    pt.water_prod,
    (COALESCE(pt.oil_prod, ((0)::numeric)::real) + COALESCE(pt.water_prod, ((0)::numeric)::real)) AS gross_liq_prod,
    pt.water_inj,
    pt.gas_inj,
    pt.disp_water_inj,
    pt.cyclic_steam_inj,
    pt.steam_inj,
    pt.hrs_prod,
    pt.hrs_inject,
        CASE
            WHEN ((pt.oil_prod = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (pt.oil_prod / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdoil_prod,
        CASE
            WHEN (((COALESCE(pt.oil_prod, ((0)::numeric)::real) + COALESCE(pt.water_prod, ((0)::numeric)::real)) = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE ((COALESCE(pt.oil_prod, ((0)::numeric)::real) + COALESCE(pt.water_prod, ((0)::numeric)::real)) / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdgross_liq_prod,
        CASE
            WHEN ((pt.cond_prod = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (pt.cond_prod / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdcond_prod,
        CASE
            WHEN ((((pt.gwg_prod + pt.owg_prod) + pt.nitrogen_prod) = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (((pt.gwg_prod + pt.owg_prod) + pt.nitrogen_prod) / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdgas_prod,
        CASE
            WHEN ((pt.water_prod = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (pt.water_prod / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdwat_prod,
        CASE
            WHEN ((pt.gas_inj = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (pt.gas_inj / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdgas_inj,
        CASE
            WHEN ((pt.water_inj = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (pt.water_inj / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdwat_inj,
        CASE
            WHEN ((pt.cyclic_steam_inj = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (pt.cyclic_steam_inj / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdsteam_inj,
        CASE
            WHEN ((pt.steam_inj = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (pt.steam_inj / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cdsteamc_inj,
        CASE
            WHEN ((pt.disp_water_inj = ((0)::numeric)::double precision) OR ((date_part('day'::text, pt.prod_inj_date))::numeric = (0)::numeric)) THEN ((0)::numeric)::double precision
            ELSE (pt.disp_water_inj / ((date_part('day'::text, pt.prod_inj_date))::numeric)::double precision)
        END AS cddispwat_inj,
        CASE
            WHEN (((COALESCE(pt.gwg_prod, ((0)::numeric)::real) + COALESCE(pt.owg_prod, ((0)::numeric)::real)) + COALESCE(pt.nitrogen_prod, ((0)::numeric)::real)) = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE COALESCE(round(((pt.oil_prod)::numeric / ((COALESCE((pt.gwg_prod)::numeric, (0)::numeric) + COALESCE((pt.owg_prod)::numeric, (0)::numeric)) + COALESCE((pt.nitrogen_prod)::numeric, (0)::numeric))), 3), (0)::numeric)
        END AS ogr_prod,
        CASE
            WHEN ((pt.oil_prod + pt.water_prod) = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE COALESCE(round((((pt.oil_prod)::numeric / ((pt.oil_prod)::numeric + (pt.water_prod)::numeric)) * (100)::numeric), 3), (0)::numeric)
        END AS ocut_prod,
        CASE
            WHEN ((pt.oil_prod + pt.water_prod) = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE COALESCE(round((((COALESCE((pt.gwg_prod)::numeric, (0)::numeric) + COALESCE((pt.owg_prod)::numeric, (0)::numeric)) + COALESCE((pt.nitrogen_prod)::numeric, (0)::numeric)) / ((pt.oil_prod)::numeric + (pt.water_prod)::numeric)), 3), (0)::numeric)
        END AS glr_prod,
        CASE
            WHEN (pt.oil_prod = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE COALESCE(round((((COALESCE((pt.gwg_prod)::numeric, (0)::numeric) + COALESCE((pt.owg_prod)::numeric, (0)::numeric)) + COALESCE((pt.nitrogen_prod)::numeric, (0)::numeric)) / (pt.oil_prod)::numeric), 3), (0)::numeric)
        END AS gor_prod,
        CASE
            WHEN (pt.oil_prod = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE COALESCE(round(((pt.water_prod)::numeric / (pt.oil_prod)::numeric), 3), (0)::numeric)
        END AS wor_prod,
        CASE
            WHEN (((COALESCE(pt.gwg_prod, ((0)::numeric)::real) + COALESCE(pt.owg_prod, ((0)::numeric)::real)) + COALESCE(pt.nitrogen_prod, ((0)::numeric)::real)) = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE COALESCE(round(((pt.water_prod)::numeric / ((COALESCE((pt.gwg_prod)::numeric, (0)::numeric) + COALESCE((pt.owg_prod)::numeric, (0)::numeric)) + COALESCE((pt.nitrogen_prod)::numeric, (0)::numeric))), 3), (0)::numeric)
        END AS wgr_prod,
        CASE
            WHEN ((pt.oil_prod + pt.water_prod) = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE COALESCE(round((((pt.water_prod)::numeric / ((pt.oil_prod)::numeric + (pt.water_prod)::numeric)) * (100)::numeric), 3), (0)::numeric)
        END AS water_cut_prod,
        CASE
            WHEN ((((((pt.oil_prod + pt.water_prod) + pt.gwg_prod) + pt.owg_prod) + pt.cond_prod) + pt.nitrogen_prod) = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE (1)::numeric
        END AS active_prod,
        CASE
            WHEN (pt.water_inj = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE (1)::numeric
        END AS active_winj,
        CASE
            WHEN (pt.gas_inj = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE (1)::numeric
        END AS active_ginj,
        CASE
            WHEN (pt.steam_inj = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE (1)::numeric
        END AS active_steam_inj,
        CASE
            WHEN (pt.cyclic_steam_inj = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE (1)::numeric
        END AS active_steamc_inj,
        CASE
            WHEN (pt.disp_water_inj = ((0)::numeric)::double precision) THEN (0)::numeric
            ELSE (1)::numeric
        END AS active_wd,
    sum(pt.oil_prod) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS oil_cum,
    sum(((COALESCE(pt.gwg_prod, ((0)::numeric)::real) + COALESCE(pt.owg_prod, ((0)::numeric)::real)) + COALESCE(pt.nitrogen_prod, ((0)::numeric)::real))) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gas_cum,
    sum((pt.water_prod + pt.oil_prod)) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gross_cum,
    sum(pt.water_prod) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS water_cum,
    sum(pt.water_inj) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS water_inj_cum,
    sum(pt.gas_inj) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gas_inj_cum,
    sum(pt.steam_inj) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS steam_inj_cum,
    sum(pt.cyclic_steam_inj) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS steamc_inj_cum,
    sum(pt.disp_water_inj) OVER (PARTITION BY pt.api_no14 ORDER BY pt.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS disp_water_inj_cum
   FROM (surv.mv_dv_av_allocated_volume_zeros pt
     JOIN surv.mv_dv_wd_well_dictionary cc ON ((cc.api_no14 = pt.api_no14)));


ALTER TABLE surv.old_dv_av_allocated_cals OWNER TO postgres;

--
-- TOC entry 1893 (class 1259 OID 36944192)
-- Name: mv_dv_av_allocated_cals; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_dv_av_allocated_cals AS
 SELECT old_dv_av_allocated_cals.api_no14,
    old_dv_av_allocated_cals.well_name,
    old_dv_av_allocated_cals.allocated_date,
    old_dv_av_allocated_cals.op_area,
    old_dv_av_allocated_cals.reg_name,
    old_dv_av_allocated_cals.at_name,
    old_dv_av_allocated_cals.orglev4_name,
    old_dv_av_allocated_cals.currenttype,
    old_dv_av_allocated_cals.currentstatus,
    old_dv_av_allocated_cals.days_prod,
    old_dv_av_allocated_cals.days_inject,
    old_dv_av_allocated_cals.oil_prod,
    old_dv_av_allocated_cals.gas_prod,
    old_dv_av_allocated_cals.cond_prod,
    old_dv_av_allocated_cals.water_prod,
    old_dv_av_allocated_cals.gross_liq_prod,
    old_dv_av_allocated_cals.water_inj,
    old_dv_av_allocated_cals.gas_inj,
    old_dv_av_allocated_cals.disp_water_inj,
    old_dv_av_allocated_cals.cyclic_steam_inj,
    old_dv_av_allocated_cals.steam_inj,
    old_dv_av_allocated_cals.hrs_prod,
    old_dv_av_allocated_cals.hrs_inject,
    old_dv_av_allocated_cals.cdoil_prod,
    old_dv_av_allocated_cals.cdgross_liq_prod,
    old_dv_av_allocated_cals.cdcond_prod,
    old_dv_av_allocated_cals.cdgas_prod,
    old_dv_av_allocated_cals.cdwat_prod,
    old_dv_av_allocated_cals.cdgas_inj,
    old_dv_av_allocated_cals.cdwat_inj,
    old_dv_av_allocated_cals.cdsteam_inj,
    old_dv_av_allocated_cals.cdsteamc_inj,
    old_dv_av_allocated_cals.cddispwat_inj,
    old_dv_av_allocated_cals.ogr_prod,
    old_dv_av_allocated_cals.ocut_prod,
    old_dv_av_allocated_cals.glr_prod,
    old_dv_av_allocated_cals.gor_prod,
    old_dv_av_allocated_cals.wor_prod,
    old_dv_av_allocated_cals.wgr_prod,
    old_dv_av_allocated_cals.water_cut_prod,
    old_dv_av_allocated_cals.active_prod,
    old_dv_av_allocated_cals.active_winj,
    old_dv_av_allocated_cals.active_ginj,
    old_dv_av_allocated_cals.active_steam_inj,
    old_dv_av_allocated_cals.active_steamc_inj,
    old_dv_av_allocated_cals.active_wd,
    old_dv_av_allocated_cals.oil_cum,
    old_dv_av_allocated_cals.gas_cum,
    old_dv_av_allocated_cals.gross_cum,
    old_dv_av_allocated_cals.water_cum,
    old_dv_av_allocated_cals.water_inj_cum,
    old_dv_av_allocated_cals.gas_inj_cum,
    old_dv_av_allocated_cals.steam_inj_cum,
    old_dv_av_allocated_cals.steamc_inj_cum,
    old_dv_av_allocated_cals.disp_water_inj_cum
   FROM surv.old_dv_av_allocated_cals
  WITH NO DATA;


ALTER TABLE surv.mv_dv_av_allocated_cals OWNER TO postgres;

--
-- TOC entry 1829 (class 1259 OID 34012733)
-- Name: old_fv_allocated_volumes; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.old_fv_allocated_volumes AS
 SELECT DISTINCT mv_dv_av_allocated_cals.api_no14,
    mv_dv_av_allocated_cals.well_name,
    mv_dv_av_allocated_cals.allocated_date,
    mv_dv_av_allocated_cals.op_area,
    mv_dv_av_allocated_cals.reg_name,
    mv_dv_av_allocated_cals.at_name,
    mv_dv_av_allocated_cals.orglev4_name,
    mv_dv_av_allocated_cals.currenttype,
    mv_dv_av_allocated_cals.currentstatus,
    mv_dv_av_allocated_cals.days_prod,
    mv_dv_av_allocated_cals.days_inject,
    mv_dv_av_allocated_cals.oil_prod,
    mv_dv_av_allocated_cals.gas_prod,
    mv_dv_av_allocated_cals.cond_prod,
    mv_dv_av_allocated_cals.water_prod,
    mv_dv_av_allocated_cals.gross_liq_prod,
    mv_dv_av_allocated_cals.water_inj,
    mv_dv_av_allocated_cals.gas_inj,
    mv_dv_av_allocated_cals.disp_water_inj,
    mv_dv_av_allocated_cals.cyclic_steam_inj,
    mv_dv_av_allocated_cals.steam_inj,
    mv_dv_av_allocated_cals.hrs_prod,
    mv_dv_av_allocated_cals.hrs_inject,
    mv_dv_av_allocated_cals.cdoil_prod,
    mv_dv_av_allocated_cals.cdgross_liq_prod,
    mv_dv_av_allocated_cals.cdcond_prod,
    mv_dv_av_allocated_cals.cdgas_prod,
    mv_dv_av_allocated_cals.cdwat_prod,
    mv_dv_av_allocated_cals.cdgas_inj,
    mv_dv_av_allocated_cals.cdwat_inj,
    mv_dv_av_allocated_cals.cdsteam_inj,
    mv_dv_av_allocated_cals.cdsteamc_inj,
    mv_dv_av_allocated_cals.cddispwat_inj,
    mv_dv_av_allocated_cals.ogr_prod,
    mv_dv_av_allocated_cals.ocut_prod,
    mv_dv_av_allocated_cals.glr_prod,
    mv_dv_av_allocated_cals.gor_prod,
    mv_dv_av_allocated_cals.wor_prod,
    mv_dv_av_allocated_cals.wgr_prod,
    mv_dv_av_allocated_cals.water_cut_prod,
    mv_dv_av_allocated_cals.active_prod,
    mv_dv_av_allocated_cals.active_winj,
    mv_dv_av_allocated_cals.active_ginj,
    mv_dv_av_allocated_cals.active_steam_inj,
    mv_dv_av_allocated_cals.active_steamc_inj,
    mv_dv_av_allocated_cals.active_wd,
    mv_dv_av_allocated_cals.oil_cum,
    mv_dv_av_allocated_cals.gas_cum,
    mv_dv_av_allocated_cals.water_cum,
    mv_dv_av_allocated_cals.gross_cum,
    mv_dv_av_allocated_cals.water_inj_cum,
    mv_dv_av_allocated_cals.gas_inj_cum,
    mv_dv_av_allocated_cals.steam_inj_cum,
    mv_dv_av_allocated_cals.steamc_inj_cum,
    mv_dv_av_allocated_cals.disp_water_inj_cum,
    min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14) AS firstproddate,
    max(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14) AS lastproddate,
    (((date_part('month'::text, mv_dv_av_allocated_cals.allocated_date) - date_part('month'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) + ((date_part('year'::text, mv_dv_av_allocated_cals.allocated_date) - date_part('year'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) * (12)::double precision)))::numeric AS month_norm,
    (floor(date_part('year'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date))))::numeric AS startyear,
    ((floor((date_part('year'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date)) / (10)::double precision)) * (10)::double precision))::numeric AS startdecade,
        CASE
            WHEN (((date_part('month'::text, mv_dv_av_allocated_cals.allocated_date) - date_part('month'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) + ((date_part('year'::text, mv_dv_av_allocated_cals.allocated_date) - date_part('year'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) * (12)::double precision)) <= (6)::double precision) THEN max(mv_dv_av_allocated_cals.cdoil_prod) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14, mv_dv_av_allocated_cals.allocated_date, mv_dv_av_allocated_cals.cdoil_prod)
            ELSE (NULL::numeric)::double precision
        END AS oil_ip,
        CASE
            WHEN (((date_part('month'::text, mv_dv_av_allocated_cals.allocated_date) - date_part('month'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) + ((date_part('year'::text, mv_dv_av_allocated_cals.allocated_date) - date_part('year'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) * (12)::double precision)) <= (6)::double precision) THEN max(mv_dv_av_allocated_cals.cdgas_prod) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14, mv_dv_av_allocated_cals.allocated_date, mv_dv_av_allocated_cals.cdgas_prod)
            ELSE (NULL::numeric)::double precision
        END AS gas_ip,
        CASE
            WHEN (((date_part('month'::text, mv_dv_av_allocated_cals.allocated_date) - date_part('month'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) + ((date_part('year'::text, mv_dv_av_allocated_cals.allocated_date) - date_part('year'::text, min(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) * (12)::double precision)) <= (6)::double precision) THEN max(mv_dv_av_allocated_cals.cdwat_prod) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14, mv_dv_av_allocated_cals.allocated_date, mv_dv_av_allocated_cals.cdwat_prod)
            ELSE (NULL::numeric)::double precision
        END AS water_ip,
    (ceil(((date_part('year'::text, now()) - date_part('year'::text, max(mv_dv_av_allocated_cals.allocated_date) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14))) + (0.00001)::double precision)))::numeric AS inactive_since_y,
    (mv_dv_av_allocated_cals.cdoil_prod - COALESCE(lag(mv_dv_av_allocated_cals.cdoil_prod) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date), ((0)::numeric)::double precision)) AS cdoil_prod_var,
    (mv_dv_av_allocated_cals.cdgas_prod - COALESCE(lag(mv_dv_av_allocated_cals.cdgas_prod) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date), ((0)::numeric)::double precision)) AS cdgas_prod_var,
    (mv_dv_av_allocated_cals.cdwat_prod - COALESCE(lag(mv_dv_av_allocated_cals.cdwat_prod) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date), ((0)::numeric)::double precision)) AS cdwat_prod_var,
    (mv_dv_av_allocated_cals.cdgross_liq_prod - COALESCE(lag(mv_dv_av_allocated_cals.cdgross_liq_prod) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date), ((0)::numeric)::double precision)) AS cdgross_liq_prod_var,
    (mv_dv_av_allocated_cals.cdwat_inj - COALESCE(lag(mv_dv_av_allocated_cals.cdwat_inj) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date), ((0)::numeric)::double precision)) AS cdwat_inj_var,
    (mv_dv_av_allocated_cals.cdgas_inj - COALESCE(lag(mv_dv_av_allocated_cals.cdgas_inj) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date), ((0)::numeric)::double precision)) AS cdgas_inj_var,
    (mv_dv_av_allocated_cals.cdsteam_inj - COALESCE(lag(mv_dv_av_allocated_cals.cdsteam_inj) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date), ((0)::numeric)::double precision)) AS cdsteam_inj_var,
    (mv_dv_av_allocated_cals.cdsteamc_inj - COALESCE(lag(mv_dv_av_allocated_cals.cdsteamc_inj) OVER (PARTITION BY mv_dv_av_allocated_cals.api_no14 ORDER BY mv_dv_av_allocated_cals.allocated_date), ((0)::numeric)::double precision)) AS cdsteamc_inj_var,
        CASE
            WHEN (strpos(mv_dv_av_allocated_cals.currenttype, 'INJ'::text) > 0) THEN NULL::numeric
            ELSE round(log(
            CASE
                WHEN ((mv_dv_av_allocated_cals.cdoil_prod)::numeric <= (0)::numeric) THEN NULL::numeric
                ELSE (mv_dv_av_allocated_cals.cdoil_prod)::numeric
            END), 2)
        END AS log_cdoil_prod,
        CASE
            WHEN (strpos(mv_dv_av_allocated_cals.currenttype, 'INJ'::text) > 0) THEN NULL::numeric
            ELSE round(log(
            CASE
                WHEN ((mv_dv_av_allocated_cals.cdgas_prod)::numeric <= (0)::numeric) THEN NULL::numeric
                ELSE (mv_dv_av_allocated_cals.cdgas_prod)::numeric
            END), 2)
        END AS log_cdgas_prod,
        CASE
            WHEN (strpos(mv_dv_av_allocated_cals.currenttype, 'INJ'::text) > 0) THEN NULL::numeric
            ELSE round(log(
            CASE
                WHEN ((mv_dv_av_allocated_cals.cdwat_prod)::numeric <= (0)::numeric) THEN NULL::numeric
                ELSE (mv_dv_av_allocated_cals.cdwat_prod)::numeric
            END), 2)
        END AS log_cdwat_prod,
        CASE
            WHEN (strpos(mv_dv_av_allocated_cals.currenttype, 'INJ'::text) > 0) THEN NULL::numeric
            ELSE round(log(
            CASE
                WHEN ((mv_dv_av_allocated_cals.cdgross_liq_prod)::numeric <= (0)::numeric) THEN NULL::numeric
                ELSE (mv_dv_av_allocated_cals.cdgross_liq_prod)::numeric
            END), 2)
        END AS log_cdgross_liq_prod,
        CASE
            WHEN (strpos(mv_dv_av_allocated_cals.currenttype, 'PROD'::text) > 0) THEN NULL::numeric
            ELSE round(log(
            CASE
                WHEN ((mv_dv_av_allocated_cals.cdwat_inj)::numeric <= (0)::numeric) THEN NULL::numeric
                ELSE (mv_dv_av_allocated_cals.cdwat_inj)::numeric
            END), 2)
        END AS log_cdwat_inj,
        CASE
            WHEN (strpos(mv_dv_av_allocated_cals.currenttype, 'PROD'::text) > 0) THEN NULL::numeric
            ELSE round(log(
            CASE
                WHEN ((mv_dv_av_allocated_cals.cdgas_inj)::numeric <= (0)::numeric) THEN NULL::numeric
                ELSE (mv_dv_av_allocated_cals.cdgas_inj)::numeric
            END), 2)
        END AS log_cdgas_inj,
        CASE
            WHEN (strpos(mv_dv_av_allocated_cals.currenttype, 'PROD'::text) > 0) THEN NULL::numeric
            ELSE round(log(
            CASE
                WHEN ((mv_dv_av_allocated_cals.cdsteam_inj)::numeric <= (0)::numeric) THEN NULL::numeric
                ELSE (mv_dv_av_allocated_cals.cdsteam_inj)::numeric
            END), 2)
        END AS log_cdseam_inj,
        CASE
            WHEN (strpos(mv_dv_av_allocated_cals.currenttype, 'PROD'::text) > 0) THEN NULL::numeric
            ELSE round(log(
            CASE
                WHEN ((mv_dv_av_allocated_cals.cdsteamc_inj)::numeric <= (0)::numeric) THEN NULL::numeric
                ELSE (mv_dv_av_allocated_cals.cdsteamc_inj)::numeric
            END), 2)
        END AS log_cdseamc_inj,
    concat(round((mv_dv_av_allocated_cals.cdoil_prod)::numeric, 0), '/', round((mv_dv_av_allocated_cals.cdwat_prod)::numeric, 0), '/', round((mv_dv_av_allocated_cals.cdgas_prod)::numeric, 0)) AS owg_lable
   FROM surv.mv_dv_av_allocated_cals;


ALTER TABLE surv.old_fv_allocated_volumes OWNER TO postgres;

--
-- TOC entry 1830 (class 1259 OID 34012738)
-- Name: mv_fv_allocated_volumes; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_fv_allocated_volumes AS
 SELECT old_fv_allocated_volumes.api_no14,
    old_fv_allocated_volumes.well_name,
    old_fv_allocated_volumes.allocated_date,
    old_fv_allocated_volumes.op_area,
    old_fv_allocated_volumes.reg_name,
    old_fv_allocated_volumes.at_name,
    old_fv_allocated_volumes.orglev4_name,
    old_fv_allocated_volumes.currenttype,
    old_fv_allocated_volumes.currentstatus,
    old_fv_allocated_volumes.days_prod,
    old_fv_allocated_volumes.days_inject,
    old_fv_allocated_volumes.oil_prod,
    old_fv_allocated_volumes.gas_prod,
    old_fv_allocated_volumes.cond_prod,
    old_fv_allocated_volumes.water_prod,
    old_fv_allocated_volumes.gross_liq_prod,
    old_fv_allocated_volumes.water_inj,
    old_fv_allocated_volumes.gas_inj,
    old_fv_allocated_volumes.disp_water_inj,
    old_fv_allocated_volumes.cyclic_steam_inj,
    old_fv_allocated_volumes.steam_inj,
    old_fv_allocated_volumes.hrs_prod,
    old_fv_allocated_volumes.hrs_inject,
    old_fv_allocated_volumes.cdoil_prod,
    old_fv_allocated_volumes.cdgross_liq_prod,
    old_fv_allocated_volumes.cdcond_prod,
    old_fv_allocated_volumes.cdgas_prod,
    old_fv_allocated_volumes.cdwat_prod,
    old_fv_allocated_volumes.cdgas_inj,
    old_fv_allocated_volumes.cdwat_inj,
    old_fv_allocated_volumes.cdsteam_inj,
    old_fv_allocated_volumes.cdsteamc_inj,
    old_fv_allocated_volumes.cddispwat_inj,
    old_fv_allocated_volumes.ogr_prod,
    old_fv_allocated_volumes.ocut_prod,
    old_fv_allocated_volumes.glr_prod,
    old_fv_allocated_volumes.gor_prod,
    old_fv_allocated_volumes.wor_prod,
    old_fv_allocated_volumes.wgr_prod,
    old_fv_allocated_volumes.water_cut_prod,
    old_fv_allocated_volumes.active_prod,
    old_fv_allocated_volumes.active_winj,
    old_fv_allocated_volumes.active_ginj,
    old_fv_allocated_volumes.active_steam_inj,
    old_fv_allocated_volumes.active_steamc_inj,
    old_fv_allocated_volumes.active_wd,
    old_fv_allocated_volumes.oil_cum,
    old_fv_allocated_volumes.gas_cum,
    old_fv_allocated_volumes.water_cum,
    old_fv_allocated_volumes.gross_cum,
    old_fv_allocated_volumes.water_inj_cum,
    old_fv_allocated_volumes.gas_inj_cum,
    old_fv_allocated_volumes.steam_inj_cum,
    old_fv_allocated_volumes.steamc_inj_cum,
    old_fv_allocated_volumes.disp_water_inj_cum,
    old_fv_allocated_volumes.firstproddate,
    old_fv_allocated_volumes.lastproddate,
    old_fv_allocated_volumes.month_norm,
    old_fv_allocated_volumes.startyear,
    old_fv_allocated_volumes.startdecade,
    old_fv_allocated_volumes.oil_ip,
    old_fv_allocated_volumes.gas_ip,
    old_fv_allocated_volumes.water_ip,
    old_fv_allocated_volumes.inactive_since_y,
    old_fv_allocated_volumes.cdoil_prod_var,
    old_fv_allocated_volumes.cdgas_prod_var,
    old_fv_allocated_volumes.cdwat_prod_var,
    old_fv_allocated_volumes.cdgross_liq_prod_var,
    old_fv_allocated_volumes.cdwat_inj_var,
    old_fv_allocated_volumes.cdgas_inj_var,
    old_fv_allocated_volumes.cdsteam_inj_var,
    old_fv_allocated_volumes.cdsteamc_inj_var,
    old_fv_allocated_volumes.log_cdoil_prod,
    old_fv_allocated_volumes.log_cdgas_prod,
    old_fv_allocated_volumes.log_cdwat_prod,
    old_fv_allocated_volumes.log_cdgross_liq_prod,
    old_fv_allocated_volumes.log_cdwat_inj,
    old_fv_allocated_volumes.log_cdgas_inj,
    old_fv_allocated_volumes.log_cdseam_inj,
    old_fv_allocated_volumes.log_cdseamc_inj,
    old_fv_allocated_volumes.owg_lable
   FROM surv.old_fv_allocated_volumes
  WITH NO DATA;


ALTER TABLE surv.mv_fv_allocated_volumes OWNER TO postgres;

--
-- TOC entry 1831 (class 1259 OID 34012751)
-- Name: old_fv_surv_well_test; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.old_fv_surv_well_test WITH (security_barrier='false') AS
 SELECT DISTINCT cc.api_no14,
    cc.well_name,
    ii.well_test_date AS test_date,
    max(ii.well_test_date) OVER (PARTITION BY cc.api_no14) AS last_test_date,
    cc.op_area,
    cc.reg_name,
    cc.at_name,
    cc.orglev4_name,
    cc.currenttype,
    cc.currentstatus,
    ii.test_type,
    ii.oil_rate,
    ii.gas_rate,
    ii.water_rate,
    ii.gas_lift_rate,
    ii.gas_oil_ratio,
    ii.tubing_press,
    ii.casing_press,
    ii.line_press,
    ii.allocatable,
    ii.oil_gravity,
    ii.choke_size,
    ii.pump_eff,
    ii.water_cut,
    ii.stroke_length,
    ii.strokes_minute,
    ii.pump_bore_size,
    ii.prod_hours,
    ii.test_hours,
    ii.hertz,
    ii.amps,
    ii.fluid_level,
    ii.pump_intake_press,
    ii.wellhead_temp,
    ii.salinity,
    ii.bsw
   FROM (crc.mv_bi_well_test ii
     JOIN surv.mv_dv_wd_well_dictionary cc ON ((ii.api_no14 = cc.api_no14)));


ALTER TABLE surv.old_fv_surv_well_test OWNER TO postgres;

--
-- TOC entry 1832 (class 1259 OID 34012756)
-- Name: mv_fv_surv_well_test; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_fv_surv_well_test AS
 SELECT old_fv_surv_well_test.api_no14,
    old_fv_surv_well_test.well_name,
    old_fv_surv_well_test.test_date,
    old_fv_surv_well_test.last_test_date,
    old_fv_surv_well_test.op_area,
    old_fv_surv_well_test.reg_name,
    old_fv_surv_well_test.at_name,
    old_fv_surv_well_test.orglev4_name,
    old_fv_surv_well_test.currenttype,
    old_fv_surv_well_test.currentstatus,
    old_fv_surv_well_test.test_type,
    old_fv_surv_well_test.oil_rate,
    old_fv_surv_well_test.gas_rate,
    old_fv_surv_well_test.water_rate,
    old_fv_surv_well_test.gas_lift_rate,
    old_fv_surv_well_test.gas_oil_ratio,
    old_fv_surv_well_test.tubing_press,
    old_fv_surv_well_test.casing_press,
    old_fv_surv_well_test.line_press,
    old_fv_surv_well_test.allocatable,
    old_fv_surv_well_test.oil_gravity,
    old_fv_surv_well_test.choke_size,
    old_fv_surv_well_test.pump_eff,
    old_fv_surv_well_test.water_cut,
    old_fv_surv_well_test.stroke_length,
    old_fv_surv_well_test.strokes_minute,
    old_fv_surv_well_test.pump_bore_size,
    old_fv_surv_well_test.prod_hours,
    old_fv_surv_well_test.test_hours,
    old_fv_surv_well_test.hertz,
    old_fv_surv_well_test.amps,
    old_fv_surv_well_test.fluid_level,
    old_fv_surv_well_test.pump_intake_press,
    old_fv_surv_well_test.wellhead_temp,
    old_fv_surv_well_test.salinity,
    old_fv_surv_well_test.bsw
   FROM surv.old_fv_surv_well_test
  WITH NO DATA;


ALTER TABLE surv.mv_fv_surv_well_test OWNER TO postgres;

--
-- TOC entry 1837 (class 1259 OID 34013178)
-- Name: fv_well_summary; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.fv_well_summary AS
 WITH allocated_prod_summary AS (
         SELECT av.api_no14,
            av.well_name,
            av.allocated_date,
            av.lastproddate,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cdoil_prod
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_oil,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cdwat_prod
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_water,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cdgas_prod
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_gas,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cdgross_liq_prod
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_gross,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cdwat_inj
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_water_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cdgas_inj
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_gas_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cdsteam_inj
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_steam_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cdsteamc_inj
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_cyc_steam_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.cddispwat_inj
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_wat_disp_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.gor_prod
                    ELSE NULL::numeric
                END AS last_allocated_gor,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.wor_prod
                    ELSE NULL::numeric
                END AS last_allocated_wor,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.water_cut_prod
                    ELSE NULL::numeric
                END AS last_allocated_water_cut,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.oil_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_oil,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.water_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_water,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.gas_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_gas,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.gross_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_gross,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.water_inj_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_water_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.gas_inj_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_gas_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.steam_inj_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_steam_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.steamc_inj_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_cyc_steam_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.disp_water_inj_cum
                    ELSE (NULL::numeric)::real
                END AS cum_allocated_wat_disp_inj
           FROM surv.mv_fv_allocated_volumes av
          WHERE (av.allocated_date = av.lastproddate)
        ), test_summary AS (
         SELECT wt.api_no14,
            wt.well_name,
            wt.test_date,
            wt.last_test_date,
                CASE
                    WHEN (wt.test_date = wt.last_test_date) THEN wt.tubing_press
                    ELSE (NULL::numeric)::real
                END AS last_tubing_press,
                CASE
                    WHEN (wt.test_date = wt.last_test_date) THEN wt.casing_press
                    ELSE (NULL::numeric)::real
                END AS last_casing_press,
                CASE
                    WHEN (wt.test_date = wt.last_test_date) THEN wt.pump_eff
                    ELSE NULL::double precision
                END AS last_pump_eff,
                CASE
                    WHEN (wt.test_date = wt.last_test_date) THEN wt.pump_intake_press
                    ELSE (NULL::numeric)::real
                END AS last_pump_intake_press,
                CASE
                    WHEN (wt.test_date = wt.last_test_date) THEN wt.stroke_length
                    ELSE (NULL::numeric)::real
                END AS last_stroke_length,
                CASE
                    WHEN (wt.test_date = wt.last_test_date) THEN wt.strokes_minute
                    ELSE (NULL::numeric)::real
                END AS last_strokes_minute,
                CASE
                    WHEN (wt.test_date = wt.last_test_date) THEN wt.fluid_level
                    ELSE (NULL::numeric)::real
                END AS last_fluid_level,
                CASE
                    WHEN (wt.test_date = wt.last_test_date) THEN wt.water_cut
                    ELSE (NULL::numeric)::real
                END AS last_test_water_cut
           FROM surv.mv_fv_surv_well_test wt
          WHERE (wt.test_date = wt.last_test_date)
        )
 SELECT DISTINCT vv.api_no14,
    vv.completion_id,
    vv.field_name,
    vv.reg_name,
    vv.at_name,
    vv.subat_name,
    vv.orglev4_name,
    vv.op_area,
    vv.legacy_well_seq_no,
    vv.legacy_zone_seq_no,
    vv.well_id,
    vv.wellbore_id,
    vv.wellbore_name,
    vv.well_name,
    vv.currenttype,
    vv.currentstatus,
    vv.status_eff_date,
    vv.state_no,
    vv.county_no,
    vv.operatingcompany,
    vv.field_no,
    vv.reservoir_cd,
    vv.org_seqno,
    vv.cost_center,
    vv.legacy_zone_id,
    vv.bottom_hole_tmd,
    vv.top_interval_tvd,
    vv.btm_interval_tvd,
    vv.topmd,
    vv.bottommd,
    vv.completion_date,
    vv.property_name,
    vv.curr_method_prod,
    vv.legacy_zone_seqno_char,
    vv.automation_name,
    vv.battery_name,
    vv.surf_latitude,
    vv.surf_longitude,
    vv.bh_latitude,
    vv.bh_longitude,
    vv.comp_sk,
    vv.interest_type,
    vv.parentpid,
    vv.top_x,
    vv.top_y,
    vv.bottomx,
    vv.bottomy,
    vv.kickoff_date,
    vv.section,
    vv.pf_no,
    vv.township,
    vv.township_direction,
    vv.range_no,
    vv.range_direction,
    vv.ground_elevation,
    vv.test_facility,
    vv.well_legal_name,
    vv.structure_code,
    vv.fault_block,
    vv.sector,
    vv.team,
    vv.remark,
    aps.lastproddate AS last_prod_date,
    ts.last_test_date,
    aps.last_allocated_oil,
    aps.last_allocated_water,
    aps.last_allocated_gas,
    aps.last_allocated_gross,
    aps.last_allocated_water_inj,
    aps.last_allocated_gas_inj,
    aps.last_allocated_steam_inj,
    aps.last_allocated_cyc_steam_inj,
    aps.last_allocated_wat_disp_inj,
    aps.last_allocated_gor,
    aps.last_allocated_wor,
    aps.last_allocated_water_cut,
    aps.cum_allocated_oil,
    aps.cum_allocated_water,
    aps.cum_allocated_gas,
    aps.cum_allocated_gross,
    aps.cum_allocated_water_inj,
    aps.cum_allocated_gas_inj,
    aps.cum_allocated_steam_inj,
    aps.cum_allocated_cyc_steam_inj,
    aps.cum_allocated_wat_disp_inj,
    ts.last_tubing_press,
    ts.last_casing_press,
    ts.last_pump_eff,
    ts.last_pump_intake_press,
    ts.last_stroke_length,
    ts.last_strokes_minute,
    ts.last_fluid_level,
    ts.last_test_water_cut
   FROM ((surv.mv_dv_wd_well_dictionary vv
     LEFT JOIN allocated_prod_summary aps ON ((vv.api_no14 = aps.api_no14)))
     LEFT JOIN test_summary ts ON ((vv.api_no14 = ts.api_no14)));


ALTER TABLE surv.fv_well_summary OWNER TO postgres;

--
-- TOC entry 2091 (class 1259 OID 75575635)
-- Name: mv_fv_surv_wellbore_openings; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_fv_surv_wellbore_openings AS
 SELECT fv_surv_wellbore_openings.policy_id,
    fv_surv_wellbore_openings.project_id,
    fv_surv_wellbore_openings.site_id,
    fv_surv_wellbore_openings.well_id,
    fv_surv_wellbore_openings.tight_group_id,
    fv_surv_wellbore_openings.datum_id,
    fv_surv_wellbore_openings.wellbore_id,
    fv_surv_wellbore_openings.wellbore_opening_id,
    fv_surv_wellbore_openings.master_id,
    fv_surv_wellbore_openings.detail_id,
    fv_surv_wellbore_openings.business_unit,
    fv_surv_wellbore_openings.field_name,
    fv_surv_wellbore_openings.site_name,
    fv_surv_wellbore_openings.well_common_name,
    fv_surv_wellbore_openings.api_no10,
    fv_surv_wellbore_openings.well_seq_no,
    fv_surv_wellbore_openings.wellbore_no,
    fv_surv_wellbore_openings.wellbore_name,
    fv_surv_wellbore_openings.wellbore_label,
    fv_surv_wellbore_openings.api_no12,
    fv_surv_wellbore_openings.wellbore_top_md,
    fv_surv_wellbore_openings.wellbore_top_tvd,
    fv_surv_wellbore_openings.wellbore_btm_md,
    fv_surv_wellbore_openings.wellbore_btm_tvd,
    fv_surv_wellbore_openings.opening_type,
    fv_surv_wellbore_openings.opening_top_md,
    fv_surv_wellbore_openings.opening_btm_md,
    fv_surv_wellbore_openings.opening_length,
    fv_surv_wellbore_openings.effective_date,
    fv_surv_wellbore_openings.opening_reason,
    fv_surv_wellbore_openings.date_perfs_shot,
    fv_surv_wellbore_openings.shot_density,
    fv_surv_wellbore_openings.shot_phasing,
    fv_surv_wellbore_openings.shot_diam,
    fv_surv_wellbore_openings.current_status,
    fv_surv_wellbore_openings.current_status_date
   FROM surv.fv_surv_wellbore_openings
  WITH NO DATA;


ALTER TABLE surv.mv_fv_surv_wellbore_openings OWNER TO postgres;

--
-- TOC entry 2047 (class 1259 OID 56269339)
-- Name: mv_new_dv_surv_av_allocated_cross; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_new_dv_surv_av_allocated_cross AS
 SELECT dv_surv_av_allocated_cross.api_no14,
    dv_surv_av_allocated_cross.full_date
   FROM surv.dv_surv_av_allocated_cross
  WITH NO DATA;


ALTER TABLE surv.mv_new_dv_surv_av_allocated_cross OWNER TO postgres;

--
-- TOC entry 2048 (class 1259 OID 61856888)
-- Name: mv_new_fv_surv_allocated_volume_cums; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volume_cums AS
 SELECT fv_surv_allocated_volume_cums.api_no14,
    fv_surv_allocated_volume_cums.allocated_date,
    fv_surv_allocated_volume_cums.oil_cum,
    fv_surv_allocated_volume_cums.gas_cum,
    fv_surv_allocated_volume_cums.gross_cum,
    fv_surv_allocated_volume_cums.water_cum,
    fv_surv_allocated_volume_cums.water_inj_cum,
    fv_surv_allocated_volume_cums.gas_inj_cum,
    fv_surv_allocated_volume_cums.steam_inj_cum,
    fv_surv_allocated_volume_cums.steamc_inj_cum,
    fv_surv_allocated_volume_cums.disp_water_inj_cum
   FROM surv.fv_surv_allocated_volume_cums
  WITH NO DATA;


ALTER TABLE surv.mv_new_fv_surv_allocated_volume_cums OWNER TO postgres;

--
-- TOC entry 2050 (class 1259 OID 61856907)
-- Name: mv_new_fv_surv_allocated_volumes_var; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volumes_var AS
 SELECT fv_surv_allocated_volume_var.api_no14,
    fv_surv_allocated_volume_var.allocated_date,
    fv_surv_allocated_volume_var.cdoil_prod_var,
    fv_surv_allocated_volume_var.cdgas_prod_var,
    fv_surv_allocated_volume_var.cdwat_prod_var,
    fv_surv_allocated_volume_var.cdgross_liq_prod_var,
    fv_surv_allocated_volume_var.cdwat_inj_var,
    fv_surv_allocated_volume_var.cdgas_inj_var,
    fv_surv_allocated_volume_var.cdsteam_inj_var,
    fv_surv_allocated_volume_var.cdsteamc_inj_var
   FROM surv.fv_surv_allocated_volume_var
  WITH NO DATA;


ALTER TABLE surv.mv_new_fv_surv_allocated_volumes_var OWNER TO postgres;

--
-- TOC entry 2046 (class 1259 OID 56269331)
-- Name: mv_new_fv_surv_daily_injection; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_daily_injection AS
 SELECT fv_surv_daily_injection.api_no14,
    fv_surv_daily_injection.inj_date,
    fv_surv_daily_injection.inj_fluid_type,
    fv_surv_daily_injection.inj_rate
   FROM surv.fv_surv_daily_injection
  WITH NO DATA;


ALTER TABLE surv.mv_new_fv_surv_daily_injection OWNER TO postgres;

--
-- TOC entry 2045 (class 1259 OID 56269322)
-- Name: mv_new_fv_surv_well_events; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_well_events AS
 SELECT fv_surv_well_events.api_no14,
    fv_surv_well_events.event_date,
    fv_surv_well_events.source,
    fv_surv_well_events.comments
   FROM surv.fv_surv_well_events
  WITH NO DATA;


ALTER TABLE surv.mv_new_fv_surv_well_events OWNER TO postgres;

--
-- TOC entry 2044 (class 1259 OID 56269312)
-- Name: mv_new_fv_surv_well_notes; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_well_notes AS
 SELECT fv_surv_well_notes.api_no14,
    fv_surv_well_notes.comment_date,
    fv_surv_well_notes.comment_by,
    fv_surv_well_notes.source,
    fv_surv_well_notes.comments
   FROM surv.fv_surv_well_notes
  WITH NO DATA;


ALTER TABLE surv.mv_new_fv_surv_well_notes OWNER TO postgres;

--
-- TOC entry 2043 (class 1259 OID 56269303)
-- Name: mv_new_fv_surv_well_test; Type: MATERIALIZED VIEW; Schema: surv; Owner: postgres
--

CREATE MATERIALIZED VIEW surv.mv_new_fv_surv_well_test AS
 SELECT fv_surv_well_test.api_no14,
    fv_surv_well_test.test_date,
    fv_surv_well_test.last_test_date,
    fv_surv_well_test.test_type,
    fv_surv_well_test.oil_rate,
    fv_surv_well_test.gas_rate,
    fv_surv_well_test.water_rate,
    fv_surv_well_test.gas_lift_rate,
    fv_surv_well_test.gas_oil_ratio,
    fv_surv_well_test.tubing_press,
    fv_surv_well_test.casing_press,
    fv_surv_well_test.line_press,
    fv_surv_well_test.allocatable,
    fv_surv_well_test.oil_gravity,
    fv_surv_well_test.choke_size,
    fv_surv_well_test.pump_eff,
    fv_surv_well_test.water_cut,
    fv_surv_well_test.stroke_length,
    fv_surv_well_test.strokes_minute,
    fv_surv_well_test.pump_bore_size,
    fv_surv_well_test.prod_hours,
    fv_surv_well_test.test_hours,
    fv_surv_well_test.hertz,
    fv_surv_well_test.amps,
    fv_surv_well_test.fluid_level,
    fv_surv_well_test.pump_intake_press,
    fv_surv_well_test.wellhead_temp,
    fv_surv_well_test.salinity,
    fv_surv_well_test.bsw
   FROM surv.fv_surv_well_test
  WITH NO DATA;


ALTER TABLE surv.mv_new_fv_surv_well_test OWNER TO postgres;

--
-- TOC entry 1840 (class 1259 OID 34013302)
-- Name: old_fv_surv_well_notes; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.old_fv_surv_well_notes WITH (security_barrier='false') AS
 WITH notes AS (
         SELECT
                CASE
                    WHEN (wn.api_no14 IS NULL) THEN
                    CASE
                        WHEN (wc.api_no14 IS NULL) THEN wc2.api_no14
                        ELSE wc.api_no14
                    END
                    ELSE wn.api_no14
                END AS api_no14,
            wn.well_name,
            wn.comment_date,
            wn.comment_by,
            wn.source,
            wn.comments
           FROM ((bi.fv_well_notes wn
             LEFT JOIN crc.mv_bi_wellcomp wc ON ((wc.automation_name = wn.well_name)))
             LEFT JOIN crc.mv_bi_wellcomp wc2 ON ((wn.well_name = wc2.wellcomp_name)))
        )
 SELECT cc.api_no14,
    cc.well_name,
    ii.comment_date,
    cc.op_area,
    cc.reg_name,
    cc.at_name,
    cc.orglev4_name,
    cc.currenttype,
    cc.currentstatus,
    ii.comment_by,
    ii.source,
    ii.comments,
    (1)::numeric AS marker_notes
   FROM (notes ii
     JOIN surv.mv_dv_wd_well_dictionary cc ON ((ii.api_no14 = cc.api_no14)));


ALTER TABLE surv.old_fv_surv_well_notes OWNER TO postgres;

--
-- TOC entry 1826 (class 1259 OID 34012705)
-- Name: old_fv_well_event; Type: VIEW; Schema: surv; Owner: postgres
--

CREATE VIEW surv.old_fv_well_event WITH (security_barrier='false') AS
 SELECT cc.api_no14,
    cc.api_no14 AS pid,
    ww.wellcomp_name AS well_name,
    ee.date_ops_end AS event_date,
    cc.op_area,
    cc.reg_name,
    cc.at_name,
    cc.orglev4_name,
    cc.currenttype,
    cc.currentstatus,
    'OpenWells Events'::text AS source,
    concat(COALESCE(upper(ee.event_type), ''::text), ' -- ', COALESCE(upper(ee.event_objective_1), ''::text), ' ', COALESCE(upper(ee.event_objective_2), ''::text)) AS comments,
    1 AS marker_event
   FROM ((bi.fv_wellcomp ww
     JOIN crc_edm.u_dm_event_t ee ON ((ww.well_id = ee.well_id)))
     JOIN surv.mv_dv_wd_well_dictionary cc ON ((ww.api_no14 = cc.api_no14)))
  WHERE ((ee.date_ops_end IS NOT NULL) AND (ee.event_type IS NOT NULL));


ALTER TABLE surv.old_fv_well_event OWNER TO postgres;

--
-- TOC entry 12860 (class 1259 OID 36950556)
-- Name: av_api_adt; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX av_api_adt ON surv.mv_fv_allocated_volumes USING btree (api_no14, allocated_date);


--
-- TOC entry 12865 (class 1259 OID 36950542)
-- Name: av_cross_api_fdt; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE UNIQUE INDEX av_cross_api_fdt ON surv.mv_dv_av_allocated_cross USING btree (api_no14, full_date);


--
-- TOC entry 12874 (class 1259 OID 75575650)
-- Name: fv_surv_wellbore_openings_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX fv_surv_wellbore_openings_index ON surv.mv_fv_surv_wellbore_openings USING btree (api_no12, effective_date);


--
-- TOC entry 12866 (class 1259 OID 36944051)
-- Name: mv_dv_av_allocated_cross_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_dv_av_allocated_cross_index ON surv.mv_dv_av_allocated_cross USING btree (api_no14, full_date);


--
-- TOC entry 12859 (class 1259 OID 34013170)
-- Name: mv_dv_av_allocated_volume_zeros_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_dv_av_allocated_volume_zeros_index ON surv.mv_dv_av_allocated_volume_zeros USING btree (api_no14, prod_inj_date);


--
-- TOC entry 12858 (class 1259 OID 34013169)
-- Name: mv_dv_wd_well_dictionary_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_dv_wd_well_dictionary_index ON surv.mv_dv_wd_well_dictionary USING btree (api_no14);


--
-- TOC entry 12861 (class 1259 OID 34013293)
-- Name: mv_fv_well_allocations_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_fv_well_allocations_index ON surv.mv_fv_allocated_volumes USING btree (api_no14, allocated_date, op_area, orglev4_name, currenttype, currentstatus);


--
-- TOC entry 12862 (class 1259 OID 34013294)
-- Name: mv_fv_well_test_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_fv_well_test_index ON surv.mv_fv_surv_well_test USING btree (api_no14, test_date, op_area, orglev4_name, currenttype, currentstatus);


--
-- TOC entry 12872 (class 1259 OID 75575612)
-- Name: mv_new_fv_surv_allocated_volume_calcs_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_new_fv_surv_allocated_volume_calcs_index ON surv.mv_new_fv_surv_allocated_volume_calcs USING btree (api_no14, allocated_date);


--
-- TOC entry 12871 (class 1259 OID 75575613)
-- Name: mv_new_fv_surv_allocated_volume_cums_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_new_fv_surv_allocated_volume_cums_index ON surv.mv_new_fv_surv_allocated_volume_cums USING btree (api_no14, allocated_date);


--
-- TOC entry 12873 (class 1259 OID 75575614)
-- Name: mv_new_fv_surv_allocated_volumes_var_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_new_fv_surv_allocated_volumes_var_index ON surv.mv_new_fv_surv_allocated_volumes_var USING btree (api_no14, allocated_date);


--
-- TOC entry 12870 (class 1259 OID 75575615)
-- Name: mv_new_fv_surv_daily_injection_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_new_fv_surv_daily_injection_index ON surv.mv_new_fv_surv_daily_injection USING btree (api_no14, inj_date);


--
-- TOC entry 12869 (class 1259 OID 75575616)
-- Name: mv_new_fv_surv_well_events_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_new_fv_surv_well_events_index ON surv.mv_new_fv_surv_well_events USING btree (api_no14, event_date);


--
-- TOC entry 12868 (class 1259 OID 75575617)
-- Name: mv_new_fv_surv_well_notes_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_new_fv_surv_well_notes_index ON surv.mv_new_fv_surv_well_notes USING btree (api_no14, comment_date);


--
-- TOC entry 12867 (class 1259 OID 75575618)
-- Name: mv_new_fv_surv_well_test_index; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX mv_new_fv_surv_well_test_index ON surv.mv_new_fv_surv_well_test USING btree (api_no14, test_date);


--
-- TOC entry 12864 (class 1259 OID 36950324)
-- Name: wd_ut_well_loc_api; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX wd_ut_well_loc_api ON surv.mv_dv_wd_untransformed_well_locations USING btree (api_no14);


--
-- TOC entry 12863 (class 1259 OID 36950548)
-- Name: wt_api_tdt; Type: INDEX; Schema: surv; Owner: postgres
--

CREATE INDEX wt_api_tdt ON surv.mv_fv_surv_well_test USING btree (api_no14, test_date);


--
-- TOC entry 13717 (class 0 OID 0)
-- Dependencies: 454
-- Name: SCHEMA surv; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA surv TO data_quality;
GRANT ALL ON SCHEMA surv TO data_analytics;
GRANT USAGE ON SCHEMA surv TO read_only;
GRANT USAGE ON SCHEMA surv TO data_science;
GRANT USAGE ON SCHEMA surv TO web_anon;


--
-- TOC entry 13718 (class 0 OID 0)
-- Dependencies: 2017
-- Name: TABLE dv_surv_av_allocated_cross; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.dv_surv_av_allocated_cross TO data_quality;
GRANT ALL ON TABLE surv.dv_surv_av_allocated_cross TO data_analytics;
GRANT SELECT ON TABLE surv.dv_surv_av_allocated_cross TO read_only;
GRANT SELECT ON TABLE surv.dv_surv_av_allocated_cross TO data_science;
GRANT ALL ON TABLE surv.dv_surv_av_allocated_cross TO web_anon;


--
-- TOC entry 13719 (class 0 OID 0)
-- Dependencies: 1823
-- Name: TABLE dv_wd_org_units; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.dv_wd_org_units TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.dv_wd_org_units TO data_quality;
GRANT ALL ON TABLE surv.dv_wd_org_units TO data_analytics;
GRANT SELECT ON TABLE surv.dv_wd_org_units TO read_only;
GRANT SELECT ON TABLE surv.dv_wd_org_units TO data_science;


--
-- TOC entry 13720 (class 0 OID 0)
-- Dependencies: 1890
-- Name: TABLE dv_wd_org_units2; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.dv_wd_org_units2 TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.dv_wd_org_units2 TO data_quality;
GRANT ALL ON TABLE surv.dv_wd_org_units2 TO data_analytics;
GRANT SELECT ON TABLE surv.dv_wd_org_units2 TO read_only;
GRANT SELECT ON TABLE surv.dv_wd_org_units2 TO data_science;


--
-- TOC entry 13721 (class 0 OID 0)
-- Dependencies: 1835
-- Name: TABLE dv_wd_untransformed_well_locations; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.dv_wd_untransformed_well_locations TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.dv_wd_untransformed_well_locations TO data_quality;
GRANT ALL ON TABLE surv.dv_wd_untransformed_well_locations TO data_analytics;
GRANT SELECT ON TABLE surv.dv_wd_untransformed_well_locations TO read_only;
GRANT SELECT ON TABLE surv.dv_wd_untransformed_well_locations TO data_science;


--
-- TOC entry 13722 (class 0 OID 0)
-- Dependencies: 1891
-- Name: TABLE dv_wd_untransformed_well_locations2; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.dv_wd_untransformed_well_locations2 TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.dv_wd_untransformed_well_locations2 TO data_quality;
GRANT ALL ON TABLE surv.dv_wd_untransformed_well_locations2 TO data_analytics;
GRANT SELECT ON TABLE surv.dv_wd_untransformed_well_locations2 TO read_only;
GRANT SELECT ON TABLE surv.dv_wd_untransformed_well_locations2 TO data_science;


--
-- TOC entry 13723 (class 0 OID 0)
-- Dependencies: 1836
-- Name: TABLE mv_dv_wd_untransformed_well_locations; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.mv_dv_wd_untransformed_well_locations TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_dv_wd_untransformed_well_locations TO data_quality;
GRANT ALL ON TABLE surv.mv_dv_wd_untransformed_well_locations TO data_analytics;
GRANT SELECT ON TABLE surv.mv_dv_wd_untransformed_well_locations TO read_only;
GRANT SELECT ON TABLE surv.mv_dv_wd_untransformed_well_locations TO data_science;


--
-- TOC entry 13724 (class 0 OID 0)
-- Dependencies: 1821
-- Name: TABLE dv_wd_well_locations; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.dv_wd_well_locations TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.dv_wd_well_locations TO data_quality;
GRANT ALL ON TABLE surv.dv_wd_well_locations TO data_analytics;
GRANT SELECT ON TABLE surv.dv_wd_well_locations TO read_only;
GRANT SELECT ON TABLE surv.dv_wd_well_locations TO data_science;


--
-- TOC entry 13725 (class 0 OID 0)
-- Dependencies: 1824
-- Name: TABLE dv_wd_well_dictionary; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.dv_wd_well_dictionary TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.dv_wd_well_dictionary TO data_quality;
GRANT ALL ON TABLE surv.dv_wd_well_dictionary TO data_analytics;
GRANT SELECT ON TABLE surv.dv_wd_well_dictionary TO read_only;
GRANT SELECT ON TABLE surv.dv_wd_well_dictionary TO data_science;


--
-- TOC entry 13726 (class 0 OID 0)
-- Dependencies: 1892
-- Name: TABLE dv_wd_well_dictionary2; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.dv_wd_well_dictionary2 TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.dv_wd_well_dictionary2 TO data_quality;
GRANT ALL ON TABLE surv.dv_wd_well_dictionary2 TO data_analytics;
GRANT SELECT ON TABLE surv.dv_wd_well_dictionary2 TO read_only;
GRANT SELECT ON TABLE surv.dv_wd_well_dictionary2 TO data_science;


--
-- TOC entry 13727 (class 0 OID 0)
-- Dependencies: 2042
-- Name: TABLE fv_surv_allocated_volume_calcs; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_surv_allocated_volume_calcs TO data_quality;
GRANT ALL ON TABLE surv.fv_surv_allocated_volume_calcs TO data_analytics;
GRANT SELECT ON TABLE surv.fv_surv_allocated_volume_calcs TO read_only;
GRANT SELECT ON TABLE surv.fv_surv_allocated_volume_calcs TO data_science;
GRANT ALL ON TABLE surv.fv_surv_allocated_volume_calcs TO web_anon;


--
-- TOC entry 13728 (class 0 OID 0)
-- Dependencies: 2041
-- Name: TABLE fv_surv_allocated_volume_cums; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_surv_allocated_volume_cums TO data_quality;
GRANT ALL ON TABLE surv.fv_surv_allocated_volume_cums TO data_analytics;
GRANT SELECT ON TABLE surv.fv_surv_allocated_volume_cums TO read_only;
GRANT SELECT ON TABLE surv.fv_surv_allocated_volume_cums TO data_science;
GRANT ALL ON TABLE surv.fv_surv_allocated_volume_cums TO web_anon;


--
-- TOC entry 13729 (class 0 OID 0)
-- Dependencies: 2049
-- Name: TABLE mv_new_fv_surv_allocated_volume_calcs; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_new_fv_surv_allocated_volume_calcs TO data_quality;
GRANT ALL ON TABLE surv.mv_new_fv_surv_allocated_volume_calcs TO data_analytics;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_allocated_volume_calcs TO read_only;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_allocated_volume_calcs TO data_science;
GRANT ALL ON TABLE surv.mv_new_fv_surv_allocated_volume_calcs TO web_anon;


--
-- TOC entry 13730 (class 0 OID 0)
-- Dependencies: 2040
-- Name: TABLE fv_surv_allocated_volume_var; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_surv_allocated_volume_var TO data_quality;
GRANT ALL ON TABLE surv.fv_surv_allocated_volume_var TO data_analytics;
GRANT SELECT ON TABLE surv.fv_surv_allocated_volume_var TO read_only;
GRANT SELECT ON TABLE surv.fv_surv_allocated_volume_var TO data_science;
GRANT ALL ON TABLE surv.fv_surv_allocated_volume_var TO web_anon;


--
-- TOC entry 13731 (class 0 OID 0)
-- Dependencies: 2039
-- Name: TABLE fv_surv_daily_injection; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_surv_daily_injection TO data_quality;
GRANT ALL ON TABLE surv.fv_surv_daily_injection TO data_analytics;
GRANT SELECT ON TABLE surv.fv_surv_daily_injection TO read_only;
GRANT SELECT ON TABLE surv.fv_surv_daily_injection TO data_science;
GRANT ALL ON TABLE surv.fv_surv_daily_injection TO web_anon;


--
-- TOC entry 13732 (class 0 OID 0)
-- Dependencies: 2038
-- Name: TABLE fv_surv_well_events; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_surv_well_events TO data_quality;
GRANT ALL ON TABLE surv.fv_surv_well_events TO data_analytics;
GRANT SELECT ON TABLE surv.fv_surv_well_events TO read_only;
GRANT SELECT ON TABLE surv.fv_surv_well_events TO data_science;
GRANT ALL ON TABLE surv.fv_surv_well_events TO web_anon;


--
-- TOC entry 13733 (class 0 OID 0)
-- Dependencies: 2037
-- Name: TABLE fv_surv_well_notes; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_surv_well_notes TO data_quality;
GRANT ALL ON TABLE surv.fv_surv_well_notes TO data_analytics;
GRANT SELECT ON TABLE surv.fv_surv_well_notes TO read_only;
GRANT SELECT ON TABLE surv.fv_surv_well_notes TO data_science;
GRANT ALL ON TABLE surv.fv_surv_well_notes TO web_anon;


--
-- TOC entry 13734 (class 0 OID 0)
-- Dependencies: 2036
-- Name: TABLE fv_surv_well_test; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_surv_well_test TO data_quality;
GRANT ALL ON TABLE surv.fv_surv_well_test TO data_analytics;
GRANT SELECT ON TABLE surv.fv_surv_well_test TO read_only;
GRANT SELECT ON TABLE surv.fv_surv_well_test TO data_science;
GRANT ALL ON TABLE surv.fv_surv_well_test TO web_anon;


--
-- TOC entry 13735 (class 0 OID 0)
-- Dependencies: 1822
-- Name: TABLE fv_surv_wellbore_openings; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.fv_surv_wellbore_openings TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_surv_wellbore_openings TO data_quality;
GRANT ALL ON TABLE surv.fv_surv_wellbore_openings TO data_analytics;
GRANT SELECT ON TABLE surv.fv_surv_wellbore_openings TO read_only;
GRANT SELECT ON TABLE surv.fv_surv_wellbore_openings TO data_science;


--
-- TOC entry 13736 (class 0 OID 0)
-- Dependencies: 1884
-- Name: TABLE old_dv_av_allocated_cross; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.old_dv_av_allocated_cross TO data_quality;
GRANT ALL ON TABLE surv.old_dv_av_allocated_cross TO data_analytics;
GRANT SELECT ON TABLE surv.old_dv_av_allocated_cross TO read_only;
GRANT SELECT ON TABLE surv.old_dv_av_allocated_cross TO data_science;
GRANT ALL ON TABLE surv.old_dv_av_allocated_cross TO web_anon;


--
-- TOC entry 13737 (class 0 OID 0)
-- Dependencies: 1885
-- Name: TABLE mv_dv_av_allocated_cross; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_dv_av_allocated_cross TO data_quality;
GRANT ALL ON TABLE surv.mv_dv_av_allocated_cross TO data_analytics;
GRANT SELECT ON TABLE surv.mv_dv_av_allocated_cross TO read_only;
GRANT SELECT ON TABLE surv.mv_dv_av_allocated_cross TO data_science;
GRANT ALL ON TABLE surv.mv_dv_av_allocated_cross TO web_anon;


--
-- TOC entry 13738 (class 0 OID 0)
-- Dependencies: 1827
-- Name: TABLE old_dv_av_allocated_zeros; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.old_dv_av_allocated_zeros TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.old_dv_av_allocated_zeros TO data_quality;
GRANT ALL ON TABLE surv.old_dv_av_allocated_zeros TO data_analytics;
GRANT SELECT ON TABLE surv.old_dv_av_allocated_zeros TO read_only;
GRANT SELECT ON TABLE surv.old_dv_av_allocated_zeros TO data_science;


--
-- TOC entry 13739 (class 0 OID 0)
-- Dependencies: 1828
-- Name: TABLE mv_dv_av_allocated_volume_zeros; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.mv_dv_av_allocated_volume_zeros TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_dv_av_allocated_volume_zeros TO data_quality;
GRANT ALL ON TABLE surv.mv_dv_av_allocated_volume_zeros TO data_analytics;
GRANT SELECT ON TABLE surv.mv_dv_av_allocated_volume_zeros TO read_only;
GRANT SELECT ON TABLE surv.mv_dv_av_allocated_volume_zeros TO data_science;


--
-- TOC entry 13740 (class 0 OID 0)
-- Dependencies: 1825
-- Name: TABLE mv_dv_wd_well_dictionary; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.mv_dv_wd_well_dictionary TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_dv_wd_well_dictionary TO data_quality;
GRANT ALL ON TABLE surv.mv_dv_wd_well_dictionary TO data_analytics;
GRANT SELECT ON TABLE surv.mv_dv_wd_well_dictionary TO read_only;
GRANT SELECT ON TABLE surv.mv_dv_wd_well_dictionary TO data_science;


--
-- TOC entry 13741 (class 0 OID 0)
-- Dependencies: 1888
-- Name: TABLE old_dv_av_allocated_cals; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.old_dv_av_allocated_cals TO data_quality;
GRANT ALL ON TABLE surv.old_dv_av_allocated_cals TO data_analytics;
GRANT SELECT ON TABLE surv.old_dv_av_allocated_cals TO read_only;
GRANT SELECT ON TABLE surv.old_dv_av_allocated_cals TO data_science;
GRANT ALL ON TABLE surv.old_dv_av_allocated_cals TO web_anon;


--
-- TOC entry 13742 (class 0 OID 0)
-- Dependencies: 1893
-- Name: TABLE mv_dv_av_allocated_cals; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_dv_av_allocated_cals TO data_quality;
GRANT ALL ON TABLE surv.mv_dv_av_allocated_cals TO data_analytics;
GRANT SELECT ON TABLE surv.mv_dv_av_allocated_cals TO read_only;
GRANT SELECT ON TABLE surv.mv_dv_av_allocated_cals TO data_science;
GRANT ALL ON TABLE surv.mv_dv_av_allocated_cals TO web_anon;


--
-- TOC entry 13743 (class 0 OID 0)
-- Dependencies: 1829
-- Name: TABLE old_fv_allocated_volumes; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.old_fv_allocated_volumes TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.old_fv_allocated_volumes TO data_quality;
GRANT ALL ON TABLE surv.old_fv_allocated_volumes TO data_analytics;
GRANT SELECT ON TABLE surv.old_fv_allocated_volumes TO read_only;
GRANT SELECT ON TABLE surv.old_fv_allocated_volumes TO data_science;


--
-- TOC entry 13744 (class 0 OID 0)
-- Dependencies: 1830
-- Name: TABLE mv_fv_allocated_volumes; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.mv_fv_allocated_volumes TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_fv_allocated_volumes TO data_quality;
GRANT ALL ON TABLE surv.mv_fv_allocated_volumes TO data_analytics;
GRANT SELECT ON TABLE surv.mv_fv_allocated_volumes TO read_only;
GRANT SELECT ON TABLE surv.mv_fv_allocated_volumes TO data_science;


--
-- TOC entry 13745 (class 0 OID 0)
-- Dependencies: 1831
-- Name: TABLE old_fv_surv_well_test; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.old_fv_surv_well_test TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.old_fv_surv_well_test TO data_quality;
GRANT ALL ON TABLE surv.old_fv_surv_well_test TO data_analytics;
GRANT SELECT ON TABLE surv.old_fv_surv_well_test TO read_only;
GRANT SELECT ON TABLE surv.old_fv_surv_well_test TO data_science;


--
-- TOC entry 13746 (class 0 OID 0)
-- Dependencies: 1832
-- Name: TABLE mv_fv_surv_well_test; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.mv_fv_surv_well_test TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_fv_surv_well_test TO data_quality;
GRANT ALL ON TABLE surv.mv_fv_surv_well_test TO data_analytics;
GRANT SELECT ON TABLE surv.mv_fv_surv_well_test TO read_only;
GRANT SELECT ON TABLE surv.mv_fv_surv_well_test TO data_science;


--
-- TOC entry 13747 (class 0 OID 0)
-- Dependencies: 1837
-- Name: TABLE fv_well_summary; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.fv_well_summary TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.fv_well_summary TO data_quality;
GRANT ALL ON TABLE surv.fv_well_summary TO data_analytics;
GRANT SELECT ON TABLE surv.fv_well_summary TO read_only;
GRANT SELECT ON TABLE surv.fv_well_summary TO data_science;


--
-- TOC entry 13748 (class 0 OID 0)
-- Dependencies: 2091
-- Name: TABLE mv_fv_surv_wellbore_openings; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_fv_surv_wellbore_openings TO data_quality;
GRANT ALL ON TABLE surv.mv_fv_surv_wellbore_openings TO data_analytics;
GRANT SELECT ON TABLE surv.mv_fv_surv_wellbore_openings TO read_only;
GRANT SELECT ON TABLE surv.mv_fv_surv_wellbore_openings TO data_science;
GRANT ALL ON TABLE surv.mv_fv_surv_wellbore_openings TO web_anon;


--
-- TOC entry 13749 (class 0 OID 0)
-- Dependencies: 2047
-- Name: TABLE mv_new_dv_surv_av_allocated_cross; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_new_dv_surv_av_allocated_cross TO data_quality;
GRANT ALL ON TABLE surv.mv_new_dv_surv_av_allocated_cross TO data_analytics;
GRANT SELECT ON TABLE surv.mv_new_dv_surv_av_allocated_cross TO read_only;
GRANT SELECT ON TABLE surv.mv_new_dv_surv_av_allocated_cross TO data_science;
GRANT ALL ON TABLE surv.mv_new_dv_surv_av_allocated_cross TO web_anon;


--
-- TOC entry 13750 (class 0 OID 0)
-- Dependencies: 2048
-- Name: TABLE mv_new_fv_surv_allocated_volume_cums; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_new_fv_surv_allocated_volume_cums TO data_quality;
GRANT ALL ON TABLE surv.mv_new_fv_surv_allocated_volume_cums TO data_analytics;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_allocated_volume_cums TO read_only;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_allocated_volume_cums TO data_science;
GRANT ALL ON TABLE surv.mv_new_fv_surv_allocated_volume_cums TO web_anon;


--
-- TOC entry 13751 (class 0 OID 0)
-- Dependencies: 2050
-- Name: TABLE mv_new_fv_surv_allocated_volumes_var; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_new_fv_surv_allocated_volumes_var TO data_quality;
GRANT ALL ON TABLE surv.mv_new_fv_surv_allocated_volumes_var TO data_analytics;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_allocated_volumes_var TO read_only;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_allocated_volumes_var TO data_science;
GRANT ALL ON TABLE surv.mv_new_fv_surv_allocated_volumes_var TO web_anon;


--
-- TOC entry 13752 (class 0 OID 0)
-- Dependencies: 2046
-- Name: TABLE mv_new_fv_surv_daily_injection; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_new_fv_surv_daily_injection TO data_quality;
GRANT ALL ON TABLE surv.mv_new_fv_surv_daily_injection TO data_analytics;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_daily_injection TO read_only;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_daily_injection TO data_science;
GRANT ALL ON TABLE surv.mv_new_fv_surv_daily_injection TO web_anon;


--
-- TOC entry 13753 (class 0 OID 0)
-- Dependencies: 2045
-- Name: TABLE mv_new_fv_surv_well_events; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_new_fv_surv_well_events TO data_quality;
GRANT ALL ON TABLE surv.mv_new_fv_surv_well_events TO data_analytics;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_well_events TO read_only;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_well_events TO data_science;
GRANT ALL ON TABLE surv.mv_new_fv_surv_well_events TO web_anon;


--
-- TOC entry 13754 (class 0 OID 0)
-- Dependencies: 2044
-- Name: TABLE mv_new_fv_surv_well_notes; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_new_fv_surv_well_notes TO data_quality;
GRANT ALL ON TABLE surv.mv_new_fv_surv_well_notes TO data_analytics;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_well_notes TO read_only;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_well_notes TO data_science;
GRANT ALL ON TABLE surv.mv_new_fv_surv_well_notes TO web_anon;


--
-- TOC entry 13755 (class 0 OID 0)
-- Dependencies: 2043
-- Name: TABLE mv_new_fv_surv_well_test; Type: ACL; Schema: surv; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.mv_new_fv_surv_well_test TO data_quality;
GRANT ALL ON TABLE surv.mv_new_fv_surv_well_test TO data_analytics;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_well_test TO read_only;
GRANT SELECT ON TABLE surv.mv_new_fv_surv_well_test TO data_science;
GRANT ALL ON TABLE surv.mv_new_fv_surv_well_test TO web_anon;


--
-- TOC entry 13756 (class 0 OID 0)
-- Dependencies: 1840
-- Name: TABLE old_fv_surv_well_notes; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.old_fv_surv_well_notes TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.old_fv_surv_well_notes TO data_quality;
GRANT ALL ON TABLE surv.old_fv_surv_well_notes TO data_analytics;
GRANT SELECT ON TABLE surv.old_fv_surv_well_notes TO read_only;
GRANT SELECT ON TABLE surv.old_fv_surv_well_notes TO data_science;


--
-- TOC entry 13757 (class 0 OID 0)
-- Dependencies: 1826
-- Name: TABLE old_fv_well_event; Type: ACL; Schema: surv; Owner: postgres
--

GRANT ALL ON TABLE surv.old_fv_well_event TO web_anon;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv.old_fv_well_event TO data_quality;
GRANT ALL ON TABLE surv.old_fv_well_event TO data_analytics;
GRANT SELECT ON TABLE surv.old_fv_well_event TO read_only;
GRANT SELECT ON TABLE surv.old_fv_well_event TO data_science;


--
-- TOC entry 10825 (class 826 OID 56268922)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: surv; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv GRANT USAGE ON SEQUENCES  TO data_quality;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv GRANT USAGE ON SEQUENCES  TO data_analytics;


--
-- TOC entry 10792 (class 826 OID 56268921)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: surv; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO data_quality;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv GRANT ALL ON TABLES  TO data_analytics;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv GRANT SELECT ON TABLES  TO read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv GRANT SELECT ON TABLES  TO data_science;


--
-- TOC entry 13701 (class 0 OID 36944038)
-- Dependencies: 1885 13713
-- Name: mv_dv_av_allocated_cross; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_dv_av_allocated_cross;


--
-- TOC entry 13697 (class 0 OID 34012726)
-- Dependencies: 1828 13701 13713
-- Name: mv_dv_av_allocated_volume_zeros; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_dv_av_allocated_volume_zeros;


--
-- TOC entry 13700 (class 0 OID 34013069)
-- Dependencies: 1836 13713
-- Name: mv_dv_wd_untransformed_well_locations; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_dv_wd_untransformed_well_locations;


--
-- TOC entry 13696 (class 0 OID 34012692)
-- Dependencies: 1825 13700 13713
-- Name: mv_dv_wd_well_dictionary; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_dv_wd_well_dictionary;


--
-- TOC entry 13702 (class 0 OID 36944192)
-- Dependencies: 1893 13696 13697 13701 13700 13713
-- Name: mv_dv_av_allocated_cals; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_dv_av_allocated_cals;


--
-- TOC entry 13698 (class 0 OID 34012738)
-- Dependencies: 1830 13702 13696 13697 13701 13700 13713
-- Name: mv_fv_allocated_volumes; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_fv_allocated_volumes;


--
-- TOC entry 13699 (class 0 OID 34012756)
-- Dependencies: 1832 13696 13700 13713
-- Name: mv_fv_surv_well_test; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_fv_surv_well_test;


--
-- TOC entry 13711 (class 0 OID 75575635)
-- Dependencies: 2091 13713
-- Name: mv_fv_surv_wellbore_openings; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_fv_surv_wellbore_openings;


--
-- TOC entry 13707 (class 0 OID 56269339)
-- Dependencies: 2047 13713
-- Name: mv_new_dv_surv_av_allocated_cross; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_new_dv_surv_av_allocated_cross;


--
-- TOC entry 13709 (class 0 OID 61856899)
-- Dependencies: 2049 13713
-- Name: mv_new_fv_surv_allocated_volume_calcs; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volume_calcs;


--
-- TOC entry 13708 (class 0 OID 61856888)
-- Dependencies: 2048 13713
-- Name: mv_new_fv_surv_allocated_volume_cums; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volume_cums;


--
-- TOC entry 13710 (class 0 OID 61856907)
-- Dependencies: 2050 13709 13713
-- Name: mv_new_fv_surv_allocated_volumes_var; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_new_fv_surv_allocated_volumes_var;


--
-- TOC entry 13706 (class 0 OID 56269331)
-- Dependencies: 2046 13713
-- Name: mv_new_fv_surv_daily_injection; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_new_fv_surv_daily_injection;


--
-- TOC entry 13705 (class 0 OID 56269322)
-- Dependencies: 2045 13713
-- Name: mv_new_fv_surv_well_events; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_new_fv_surv_well_events;


--
-- TOC entry 13704 (class 0 OID 56269312)
-- Dependencies: 2044 13713
-- Name: mv_new_fv_surv_well_notes; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_new_fv_surv_well_notes;


--
-- TOC entry 13703 (class 0 OID 56269303)
-- Dependencies: 2043 13713
-- Name: mv_new_fv_surv_well_test; Type: MATERIALIZED VIEW DATA; Schema: surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv.mv_new_fv_surv_well_test;


-- Completed on 2020-01-14 08:58:40

--
-- PostgreSQL database dump complete
--

