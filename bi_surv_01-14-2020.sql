--
-- PostgreSQL database dump
--

-- Dumped from database version 10.7
-- Dumped by pg_dump version 12.0

-- Started on 2020-01-14 09:02:50

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
-- TOC entry 540 (class 2615 OID 86810747)
-- Name: bi_surv; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bi_surv;


ALTER SCHEMA bi_surv OWNER TO postgres;

--
-- TOC entry 2464 (class 1259 OID 86810893)
-- Name: dv_surv_av_allocated_cross; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.dv_surv_av_allocated_cross AS
 WITH mvd AS (
         SELECT mv.api_no14,
            max(mv.prod_inj_date) AS max_date,
            min(mv.prod_inj_date) AS min_date
           FROM crc.mv_bi_monthly_volumes mv
          GROUP BY mv.api_no14
        )
 SELECT mvd.api_no14,
    dates.full_date
   FROM (( SELECT DISTINCT dd.last_day_of_month AS full_date
           FROM utility.date_dimension dd) dates
     CROSS JOIN mvd)
  WHERE ((dates.full_date <= mvd.max_date) AND (dates.full_date >= mvd.min_date));


ALTER TABLE bi_surv.dv_surv_av_allocated_cross OWNER TO postgres;

--
-- TOC entry 2465 (class 1259 OID 86810899)
-- Name: fv_surv_allocated_volume_calcs; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.fv_surv_allocated_volume_calcs AS
 SELECT ac.api_no14,
    ac.full_date AS allocated_date,
    (COALESCE(mv.days_prod, (0)::double precision))::smallint AS days_prod,
    (COALESCE(mv.days_inject, (0)::double precision))::smallint AS days_inject,
    COALESCE(mv.oil_prod, (0)::real) AS oil_prod,
    COALESCE((mv.gwg_prod + mv.owg_prod), (0)::real) AS gas_prod,
    COALESCE(mv.nitrogen_prod, (0)::real) AS n2_prod,
    COALESCE(mv.cond_prod, (0)::real) AS cond_prod,
    COALESCE(mv.water_prod, (0)::real) AS water_prod,
    COALESCE((mv.oil_prod + mv.water_prod), (0)::real) AS gross_liq_prod,
    COALESCE(mv.water_inj, (0)::real) AS water_inj,
    COALESCE(mv.gas_inj, (0)::real) AS gas_inj,
    COALESCE(mv.disp_water_inj, (0)::real) AS disp_water_inj,
    COALESCE(mv.cyclic_steam_inj, (0)::real) AS cyclic_steam_inj,
    COALESCE(mv.steam_inj, (0)::real) AS steam_inj,
    (COALESCE(mv.hrs_prod, (0)::numeric))::smallint AS hrs_prod,
    (COALESCE(mv.hrs_inject, (0)::numeric))::smallint AS hrs_inject,
    (COALESCE((mv.oil_prod / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdoil_prod,
    (COALESCE((COALESCE((mv.oil_prod + mv.water_prod), (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdgross_liq_prod,
    (COALESCE((COALESCE(mv.cond_prod, (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdcond_prod,
    (COALESCE((COALESCE((mv.gwg_prod + mv.owg_prod), (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdgas_prod,
    (COALESCE((COALESCE(mv.nitrogen_prod, (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdn2_prod,
    (COALESCE((COALESCE(mv.water_prod, (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdwater_prod,
    (COALESCE((COALESCE(mv.gas_inj, (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdgas_inj,
    (COALESCE((COALESCE(mv.water_inj, (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdwater_inj,
    (COALESCE((COALESCE(mv.cyclic_steam_inj, (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdsteamc_inj,
    (COALESCE((COALESCE(mv.steam_inj, (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cdsteam_inj,
    (COALESCE((COALESCE(mv.disp_water_inj, (0)::real) / date_part('day'::text, mv.prod_inj_date)), (0)::double precision))::real AS cddispwat_inj,
        CASE
            WHEN (COALESCE((mv.gwg_prod + mv.owg_prod), (0)::real) = (0)::double precision) THEN (0)::real
            ELSE (COALESCE(mv.oil_prod, (0)::real) / COALESCE((mv.gwg_prod + mv.owg_prod), (0)::real))
        END AS ogr_prod,
        CASE
            WHEN (COALESCE((mv.oil_prod + mv.water_prod), (0)::real) = (0)::double precision) THEN (0)::real
            ELSE (COALESCE(mv.oil_prod, (0)::real) / COALESCE((mv.oil_prod + mv.water_prod), (0)::real))
        END AS ocut_prod,
        CASE
            WHEN (COALESCE((mv.oil_prod + mv.water_prod), (0)::real) = (0)::double precision) THEN (0)::real
            ELSE (COALESCE((mv.gwg_prod + mv.owg_prod), (0)::real) / COALESCE((mv.oil_prod + mv.water_prod), (0)::real))
        END AS glr_prod,
        CASE
            WHEN (COALESCE(mv.oil_prod, (0)::real) = (0)::double precision) THEN (0)::real
            ELSE (COALESCE((mv.gwg_prod + mv.owg_prod), (0)::real) / mv.oil_prod)
        END AS gor_prod,
        CASE
            WHEN (COALESCE(mv.oil_prod, (0)::real) = (0)::double precision) THEN (0)::real
            ELSE (COALESCE(mv.water_prod, (0)::real) / mv.oil_prod)
        END AS wor_prod,
        CASE
            WHEN (COALESCE((mv.gwg_prod + mv.owg_prod), (0)::real) = (0)::double precision) THEN (0)::real
            ELSE (COALESCE(mv.water_prod, (0)::real) / COALESCE((mv.gwg_prod + mv.owg_prod), (0)::real))
        END AS wgr_prod,
        CASE
            WHEN (COALESCE((mv.oil_prod + mv.water_prod), (0)::real) = (0)::double precision) THEN (0)::real
            ELSE (COALESCE(mv.water_prod, (0)::real) / COALESCE((mv.oil_prod + mv.water_prod), (0)::real))
        END AS water_cut_prod,
    (((date_part('month'::text, mv.prod_inj_date) - date_part('month'::text, min(mv.prod_inj_date) OVER (PARTITION BY mv.api_no14))) + ((date_part('year'::text, mv.prod_inj_date) - date_part('year'::text, min(mv.prod_inj_date) OVER (PARTITION BY mv.api_no14))) * (12)::double precision)))::real AS month_norm,
    min(ac.full_date) OVER (PARTITION BY ac.api_no14) AS firstproddate,
    max(ac.full_date) OVER (PARTITION BY ac.api_no14) AS lastproddate
   FROM (bi_surv.dv_surv_av_allocated_cross ac
     LEFT JOIN crc.mv_bi_monthly_volumes mv ON (((ac.api_no14 = mv.api_no14) AND (ac.full_date = mv.prod_inj_date))));


ALTER TABLE bi_surv.fv_surv_allocated_volume_calcs OWNER TO postgres;

SET default_tablespace = '';

--
-- TOC entry 2466 (class 1259 OID 86810906)
-- Name: mv_fv_surv_allocated_volume_calcs; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_fv_surv_allocated_volume_calcs AS
 SELECT mvc.api_no14,
    mvc.allocated_date,
    mvc.days_prod,
    mvc.days_inject,
    mvc.oil_prod,
    mvc.gas_prod,
    mvc.n2_prod,
    mvc.cond_prod,
    mvc.water_prod,
    mvc.gross_liq_prod,
    mvc.water_inj,
    mvc.gas_inj,
    mvc.disp_water_inj,
    mvc.cyclic_steam_inj,
    mvc.steam_inj,
    mvc.hrs_prod,
    mvc.hrs_inject,
    mvc.cdoil_prod,
    mvc.cdgross_liq_prod,
    mvc.cdcond_prod,
    mvc.cdgas_prod,
    mvc.cdn2_prod,
    mvc.cdwater_prod,
    mvc.cdgas_inj,
    mvc.cdwater_inj,
    mvc.cdsteamc_inj,
    mvc.cdsteam_inj,
    mvc.cddispwat_inj,
    mvc.ogr_prod,
    mvc.ocut_prod,
    mvc.glr_prod,
    mvc.gor_prod,
    mvc.wor_prod,
    mvc.wgr_prod,
    mvc.water_cut_prod,
    mvc.month_norm,
    mvc.firstproddate,
    mvc.lastproddate
   FROM bi_surv.fv_surv_allocated_volume_calcs mvc
  WITH NO DATA;


ALTER TABLE bi_surv.mv_fv_surv_allocated_volume_calcs OWNER TO postgres;

--
-- TOC entry 2467 (class 1259 OID 86810916)
-- Name: dv_surv_exc_allocated_volume_var; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.dv_surv_exc_allocated_volume_var WITH (security_barrier='false') AS
 SELECT avc.api_no14,
    avc.allocated_date,
    (avc.cdoil_prod - COALESCE((lag(avc.cdoil_prod) OVER (PARTITION BY avc.api_no14 ORDER BY avc.allocated_date))::double precision, ((0)::numeric)::double precision)) AS cdoil_prod_var,
    (avc.cdgas_prod - COALESCE((lag(avc.cdgas_prod) OVER (PARTITION BY avc.api_no14 ORDER BY avc.allocated_date))::double precision, ((0)::numeric)::double precision)) AS cdgas_prod_var,
    (avc.cdwater_prod - COALESCE((lag(avc.cdwater_prod) OVER (PARTITION BY avc.api_no14 ORDER BY avc.allocated_date))::double precision, ((0)::numeric)::double precision)) AS cdwat_prod_var,
    (avc.cdgross_liq_prod - COALESCE((lag(avc.cdgross_liq_prod) OVER (PARTITION BY avc.api_no14 ORDER BY avc.allocated_date))::double precision, ((0)::numeric)::double precision)) AS cdgross_liq_prod_var,
    (avc.cdwater_inj - COALESCE((lag(avc.cdwater_inj) OVER (PARTITION BY avc.api_no14 ORDER BY avc.allocated_date))::double precision, ((0)::numeric)::double precision)) AS cdwat_inj_var,
    (avc.cdgas_inj - COALESCE((lag(avc.cdgas_inj) OVER (PARTITION BY avc.api_no14 ORDER BY avc.allocated_date))::double precision, ((0)::numeric)::double precision)) AS cdgas_inj_var,
    (avc.cdsteam_inj - COALESCE((lag(avc.cdsteam_inj) OVER (PARTITION BY avc.api_no14 ORDER BY avc.allocated_date))::double precision, ((0)::numeric)::double precision)) AS cdsteam_inj_var,
    (avc.cdsteamc_inj - COALESCE((lag(avc.cdsteamc_inj) OVER (PARTITION BY avc.api_no14 ORDER BY avc.allocated_date))::double precision, ((0)::numeric)::double precision)) AS cdsteamc_inj_var
   FROM bi_surv.mv_fv_surv_allocated_volume_calcs avc
  WHERE (avc.allocated_date > (CURRENT_DATE - '365 days'::interval));


ALTER TABLE bi_surv.dv_surv_exc_allocated_volume_var OWNER TO postgres;

--
-- TOC entry 2460 (class 1259 OID 86810858)
-- Name: dv_surv_exc_analog_data; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.dv_surv_exc_analog_data WITH (security_barrier='false') AS
 SELECT ad.api_no14,
    ad.analog_date,
    avg(ad.yesterdays_inferred_production) AS yesterdays_inferred_production,
    avg(ad.yesterdays_gas_volume) AS yesterdays_gas_volume,
    avg(ad.casing_pressure) AS casing_pressure,
    avg(ad.differential_pressure) AS differential_pressure,
    avg(ad.injection_pressure) AS injection_pressure,
    avg(ad.yesterdays_runtime) AS yesterdays_runtime,
    avg(ad.flowline_pressure) AS flowline_pressure,
    avg(ad.well_test_oil) AS well_test_oil,
    avg(ad.well_test_gross) AS well_test_gross,
    avg(ad.water_rate) AS water_rate
   FROM ( SELECT wc.api_no14,
            dhag.tdate AS analog_date,
                CASE
                    WHEN (dhag.param = 203) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS yesterdays_inferred_production,
                CASE
                    WHEN (dhag.param = 197) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS yesterdays_gas_volume,
                CASE
                    WHEN (dhag.param = 10) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS casing_pressure,
                CASE
                    WHEN (dhag.param = 70) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS differential_pressure,
                CASE
                    WHEN (dhag.param = 196) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS injection_pressure,
                CASE
                    WHEN (dhag.param = 178) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS yesterdays_runtime,
                CASE
                    WHEN (dhag.param = 185) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS flowline_pressure,
                CASE
                    WHEN (dhag.param = 234) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS well_test_oil,
                CASE
                    WHEN (dhag.param = 233) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS well_test_gross,
                CASE
                    WHEN (dhag.param = 218) THEN dhag.avgval
                    ELSE NULL::double precision
                END AS water_rate
           FROM (crc_xspoc.mv_dv_datahistory_all_group dhag
             JOIN crc.mv_bi_wellcomp wc ON ((dhag.nodeid = wc.automation_name)))) ad
  GROUP BY ad.api_no14, ad.analog_date;


ALTER TABLE bi_surv.dv_surv_exc_analog_data OWNER TO postgres;

--
-- TOC entry 2461 (class 1259 OID 86810863)
-- Name: mv_dv_surv_exc_analog_data; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_dv_surv_exc_analog_data AS
 SELECT ad.api_no14,
    ad.analog_date,
    ad.yesterdays_inferred_production,
    ad.yesterdays_gas_volume,
    ad.casing_pressure,
    ad.differential_pressure,
    ad.injection_pressure,
    ad.yesterdays_runtime,
    ad.flowline_pressure,
    ad.well_test_oil,
    ad.well_test_gross,
    ad.water_rate
   FROM bi_surv.dv_surv_exc_analog_data ad
  WITH NO DATA;


ALTER TABLE bi_surv.mv_dv_surv_exc_analog_data OWNER TO postgres;

--
-- TOC entry 2462 (class 1259 OID 86810873)
-- Name: dv_surv_exc_analog_var; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.dv_surv_exc_analog_var WITH (security_barrier='false') AS
 SELECT ad.api_no14,
    ad.analog_date,
    (ad.yesterdays_inferred_production - COALESCE(lag(ad.yesterdays_inferred_production) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS yesterdays_inferred_production_var,
    (ad.yesterdays_gas_volume - COALESCE(lag(ad.yesterdays_gas_volume) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS yesterdays_gas_volume_var,
    (ad.casing_pressure - COALESCE(lag(ad.casing_pressure) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS casing_pressure_var,
    (ad.differential_pressure - COALESCE(lag(ad.differential_pressure) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS differential_pressure_var,
    (ad.injection_pressure - COALESCE(lag(ad.injection_pressure) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS injection_pressure_var,
    (ad.yesterdays_runtime - COALESCE(lag(ad.yesterdays_runtime) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS yesterdays_runtime_var,
    (ad.flowline_pressure - COALESCE(lag(ad.flowline_pressure) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS flowline_pressure_var,
    (ad.well_test_oil - COALESCE(lag(ad.well_test_oil) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS well_test_oil_var,
    (ad.well_test_gross - COALESCE(lag(ad.well_test_gross) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS well_test_gross_var,
    (ad.water_rate - COALESCE(lag(ad.water_rate) OVER (PARTITION BY ad.api_no14 ORDER BY ad.analog_date), (0)::double precision)) AS water_rate_var
   FROM bi_surv.mv_dv_surv_exc_analog_data ad
  WHERE (ad.analog_date > (CURRENT_DATE - '366 days'::interval));


ALTER TABLE bi_surv.dv_surv_exc_analog_var OWNER TO postgres;

--
-- TOC entry 2477 (class 1259 OID 86811001)
-- Name: dv_surv_ws_org_units; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.dv_surv_ws_org_units WITH (security_barrier='false') AS
 SELECT DISTINCT kpi.api_no14,
    kpi.name,
    kpi.org_seqno,
    kpi.field_name,
    kpi.reg_name,
    kpi.at_name,
    kpi.subat_name,
    kpi.orglev4_name,
    po.op_area,
    po.subsurf_name
   FROM (( SELECT DISTINCT wc.api_no14,
            wc.wellcomp_name AS name,
            wc.org_seqno,
            wc.field_name,
            wc.reg_name,
            wc.at_name,
            wc.subat_name,
                CASE
                    WHEN (upper(wc.reg_name) = 'ELK HILLS'::text) THEN COALESCE(upper(wn.kpi_group), upper(wc.orglev4_name))
                    WHEN (wc.org_seqno = (1901030000)::numeric) THEN 'PICO'::text
                    WHEN (wc.org_seqno = (1901000000)::numeric) THEN 'LONG BEACH UNIT'::text
                    WHEN ((upper(wc.orglev4_name) = ANY (ARRAY['NPR2E'::text, 'NPR2W'::text, 'SPRB'::text, 'NPR1'::text, 'SPRA'::text])) OR (upper(wc.at_name) = 'TIDELANDS'::text)) THEN 'TIDELANDS'::text
                    WHEN (upper(wc.orglev4_name) = 'GENERAL'::text) THEN
                    CASE
                        WHEN (upper(wc.subat_name) = 'GENERAL'::text) THEN
                        CASE
                            WHEN (upper(wc.at_name) = 'GENERAL'::text) THEN upper(wc.reg_name)
                            ELSE upper(wc.at_name)
                        END
                        ELSE upper(wc.subat_name)
                    END
                    ELSE COALESCE(upper(wc.orglev4_name), upper(wc.subat_name), upper(wc.at_name), upper(wc.reg_name))
                END AS orglev4_name,
            wn.kpi_group,
            wc.reservoir_cd
           FROM (crc.mv_bi_wellcomp_v wc
             LEFT JOIN ds_ekpspp.dss_wn_team wn ON (((wc.reservoir_cd = wn.reservoir_cd) AND (wc.cost_center = wn.cost_center))))
          WHERE (wc.curr_comp_status !~~ 'CANCEL'::text)) kpi
     LEFT JOIN ( SELECT ox.field,
            ox.op_area,
            ox.subsurf_name
           FROM ds_usoxybip.crcplan_tborg_xref ox
          WHERE (upper(ox.op_area) <> 'EXPLORATION'::text)) po ON ((upper(kpi.orglev4_name) = upper(po.field))));


ALTER TABLE bi_surv.dv_surv_ws_org_units OWNER TO postgres;

--
-- TOC entry 2475 (class 1259 OID 86810977)
-- Name: dv_surv_ws_untransformed_well_locations; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.dv_surv_ws_untransformed_well_locations WITH (security_barrier='false') AS
 SELECT DISTINCT wc.api_no14,
    COALESCE(wb.top_bore_latitude, wb.btm_bore_latitude, (0)::double precision) AS top_bore_latitude,
    COALESCE(wb.top_bore_longitude, wb.btm_bore_longitude, (0)::double precision) AS top_bore_longitude,
    COALESCE(wb.btm_bore_latitude, wb.top_bore_latitude, (0)::double precision) AS btm_bore_latitude,
    COALESCE(wb.btm_bore_longitude, wb.btm_bore_longitude, (0)::double precision) AS btm_bore_longitude,
    p.geo_zone_id,
    p.geo_datum_id
   FROM ((((crc.mv_bi_wellcomp wc
     JOIN crc.mv_bi_wellbore wb ON (("substring"(wc.api_no14, 1, 12) = wb.api_no12)))
     JOIN crc_edm.mv_u_cd_well_source w ON ((wb.well_id = w.well_id)))
     JOIN crc_edm.mv_u_cd_site_source ss ON ((w.site_id = ss.site_id)))
     JOIN crc_edm.mv_u_cd_project p ON ((ss.project_id = p.project_id)));


ALTER TABLE bi_surv.dv_surv_ws_untransformed_well_locations OWNER TO postgres;

--
-- TOC entry 2476 (class 1259 OID 86810992)
-- Name: mv_dv_surv_ws_untransformed_well_locations; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_dv_surv_ws_untransformed_well_locations AS
 SELECT uwl.api_no14,
    uwl.top_bore_latitude,
    uwl.top_bore_longitude,
    uwl.btm_bore_latitude,
    uwl.btm_bore_longitude,
    uwl.geo_zone_id,
    uwl.geo_datum_id
   FROM bi_surv.dv_surv_ws_untransformed_well_locations uwl
  WITH NO DATA;


ALTER TABLE bi_surv.mv_dv_surv_ws_untransformed_well_locations OWNER TO postgres;

--
-- TOC entry 2478 (class 1259 OID 86811015)
-- Name: dv_surv_ws_well_locations; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.dv_surv_ws_well_locations AS
 SELECT DISTINCT uwl.api_no14,
        CASE
            WHEN (uwl.geo_datum_id = 'NAD27'::text) THEN public.st_y(public.st_transform(public.st_setsrid(public.st_makepoint(uwl.btm_bore_longitude, uwl.btm_bore_latitude), 4267), 4152))
            ELSE uwl.btm_bore_latitude
        END AS bh_latitude,
        CASE
            WHEN (uwl.geo_datum_id = 'NAD27'::text) THEN public.st_x(public.st_transform(public.st_setsrid(public.st_makepoint(uwl.btm_bore_longitude, uwl.btm_bore_latitude), 4267), 4152))
            ELSE uwl.btm_bore_longitude
        END AS bh_longitude,
        CASE
            WHEN (uwl.geo_datum_id = 'NAD27'::text) THEN public.st_y(public.st_transform(public.st_setsrid(public.st_makepoint(uwl.top_bore_longitude, uwl.top_bore_latitude), 4267), 4152))
            ELSE uwl.top_bore_latitude
        END AS surface_latitude,
        CASE
            WHEN (uwl.geo_datum_id = 'NAD27'::text) THEN public.st_x(public.st_transform(public.st_setsrid(public.st_makepoint(uwl.top_bore_longitude, uwl.top_bore_latitude), 4267), 4152))
            ELSE uwl.top_bore_longitude
        END AS surface_longitude
   FROM bi_surv.mv_dv_surv_ws_untransformed_well_locations uwl;


ALTER TABLE bi_surv.dv_surv_ws_well_locations OWNER TO postgres;

--
-- TOC entry 2479 (class 1259 OID 86811020)
-- Name: dv_surv_ws_well_dictionary; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.dv_surv_ws_well_dictionary AS
 SELECT DISTINCT wcv.api_no14,
    ou.op_area,
    ou.orglev4_name,
    wcv.wellcomp_name AS well_name,
    wcv.curr_comp_type AS currenttype,
        CASE
            WHEN (wcv.curr_comp_status ~~ 'D & A'::text) THEN 'P & A'::text
            WHEN (wcv.curr_comp_status ~~ 'SHUT-IN'::text) THEN 'INACTIVE'::text
            WHEN (wcv.curr_comp_status ~~ 'DRY'::text) THEN 'P & A'::text
            ELSE wcv.curr_comp_status
        END AS currentstatus,
    wcv.status_eff_date,
    wcv.reservoir_cd,
    wcv.top_interval_tvd,
    wcv.btm_interval_tvd,
    (wcv.top_interval_tmd)::numeric AS topmd,
    (wcv.btm_interval_tmd)::numeric AS bottommd,
    wcv.type_interval,
    wcv.well_spud_date,
    wcv.completion_date,
    wcv.first_prod_date,
    wcv.curr_method_prod,
    wcv.battery_name,
    wl.surface_latitude AS surf_latitude,
    wl.surface_longitude AS surf_longitude,
    wl.bh_latitude,
    wl.bh_longitude,
    wcv.interest_type,
    wb.kickoff_date,
    w.section,
    w.township,
    (w.range_no)::numeric AS range_no,
    w.test_facility,
    cm.structure_code,
    cm.fault_block,
    cm.sector
   FROM (((((crc.mv_bi_wellcomp_v wcv
     LEFT JOIN crc.mv_bi_wellbore wb ON (("substring"(wcv.api_no14, 0, 12) = wb.api_no12)))
     LEFT JOIN crc.mv_bi_well w ON (("substring"(wcv.api_no14, 0, 10) = w.api_no10)))
     LEFT JOIN bi_surv.dv_surv_ws_well_locations wl ON ((wcv.api_no14 = wl.api_no14)))
     LEFT JOIN bi_surv.dv_surv_ws_org_units ou ON ((wcv.api_no14 = ou.api_no14)))
     LEFT JOIN crc_dss.u_dss_compmaster cm ON ((wcv.api_no14 = cm.pid)));


ALTER TABLE bi_surv.dv_surv_ws_well_dictionary OWNER TO postgres;

--
-- TOC entry 2473 (class 1259 OID 86810962)
-- Name: fv_surv_allocated_volume_cums; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.fv_surv_allocated_volume_cums AS
 SELECT mv.api_no14,
    mv.prod_inj_date AS allocated_date,
    sum(mv.oil_prod) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS oil_cum,
    sum(((COALESCE(mv.gwg_prod, ((0)::numeric)::real) + COALESCE(mv.owg_prod, ((0)::numeric)::real)) + COALESCE(mv.nitrogen_prod, ((0)::numeric)::real))) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gas_cum,
    sum((mv.water_prod + mv.oil_prod)) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gross_cum,
    sum(mv.water_prod) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS water_cum,
    sum(mv.water_inj) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS water_inj_cum,
    sum(mv.gas_inj) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS gas_inj_cum,
    sum(mv.steam_inj) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS steam_inj_cum,
    sum(mv.cyclic_steam_inj) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS steamc_inj_cum,
    sum(mv.disp_water_inj) OVER (PARTITION BY mv.api_no14 ORDER BY mv.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS disp_water_inj_cum,
    max(mv.prod_inj_date) OVER (PARTITION BY mv.api_no14) AS lastproddate
   FROM crc.mv_bi_monthly_volumes mv;


ALTER TABLE bi_surv.fv_surv_allocated_volume_cums OWNER TO postgres;

--
-- TOC entry 2471 (class 1259 OID 86810949)
-- Name: fv_surv_daily_injection; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.fv_surv_daily_injection WITH (security_barrier='false') AS
 SELECT wc.api_no14,
    inj.test_date AS inj_date,
    inj.inj_fluid_type,
    inj.inj_rate,
    inj.inj_casing_press,
    inj.inj_tubing_press,
    inj.avg_inj_press,
    inj.pressure_setpoint
   FROM (( SELECT eid.api_no14,
            eid.daily_inj_date AS test_date,
            eid.inj_fluid_type,
            eid.inj_rate,
            eid.inj_casing_press,
            eid.inj_tubing_press,
            eid.avg_inj_press,
            eid.pressure_setpoint
           FROM ds_ekpspp.ods_oxy_injection_data eid
        UNION
         SELECT iid.api_no14,
            iid.daily_inj_date AS test_date,
            iid.inj_fluid_type,
            iid.inj_rate,
            iid.inj_casing_press,
            iid.inj_tubing_press,
            iid.avg_inj_press,
            iid.pressure_setpoint
           FROM ingres.mv_fv_daily_inj_ingres iid) inj
     JOIN crc.mv_bi_wellcomp wc ON ((inj.api_no14 = wc.api_no14)));


ALTER TABLE bi_surv.fv_surv_daily_injection OWNER TO postgres;

--
-- TOC entry 2468 (class 1259 OID 86810925)
-- Name: mv_dv_surv_exc_allocated_volume_var; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_dv_surv_exc_allocated_volume_var AS
 SELECT av.api_no14,
    av.allocated_date,
    av.cdoil_prod_var,
    av.cdgas_prod_var,
    av.cdwat_prod_var,
    av.cdgross_liq_prod_var,
    av.cdwat_inj_var,
    av.cdgas_inj_var,
    av.cdsteam_inj_var,
    av.cdsteamc_inj_var
   FROM bi_surv.dv_surv_exc_allocated_volume_var av
  WITH NO DATA;


ALTER TABLE bi_surv.mv_dv_surv_exc_allocated_volume_var OWNER TO postgres;

--
-- TOC entry 2463 (class 1259 OID 86810879)
-- Name: mv_dv_surv_exc_analog_var; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_dv_surv_exc_analog_var AS
 SELECT av.api_no14,
    av.analog_date,
    av.yesterdays_inferred_production_var,
    av.yesterdays_gas_volume_var,
    av.casing_pressure_var,
    av.differential_pressure_var,
    av.injection_pressure_var,
    av.yesterdays_runtime_var,
    av.flowline_pressure_var,
    av.well_test_oil_var,
    av.well_test_gross_var,
    av.water_rate_var
   FROM bi_surv.dv_surv_exc_analog_var av
  WITH NO DATA;


ALTER TABLE bi_surv.mv_dv_surv_exc_analog_var OWNER TO postgres;

--
-- TOC entry 2469 (class 1259 OID 86810933)
-- Name: fv_surv_exceptions; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.fv_surv_exceptions AS
 SELECT COALESCE(anv.api_no14, alv.api_no14) AS api_no14,
    COALESCE(anv.analog_date, alv.allocated_date) AS var_date,
    alv.cdoil_prod_var,
    alv.cdgas_prod_var,
    alv.cdwat_prod_var,
    alv.cdgross_liq_prod_var,
    alv.cdwat_inj_var,
    alv.cdgas_inj_var,
    alv.cdsteam_inj_var,
    alv.cdsteamc_inj_var,
    anv.yesterdays_inferred_production_var,
    anv.yesterdays_gas_volume_var,
    anv.casing_pressure_var,
    anv.differential_pressure_var,
    anv.injection_pressure_var,
    anv.yesterdays_runtime_var,
    anv.flowline_pressure_var,
    anv.well_test_oil_var,
    anv.well_test_gross_var,
    anv.water_rate_var
   FROM (bi_surv.mv_dv_surv_exc_analog_var anv
     FULL JOIN bi_surv.mv_dv_surv_exc_allocated_volume_var alv ON (((anv.api_no14 = alv.api_no14) AND (anv.analog_date = alv.allocated_date))));


ALTER TABLE bi_surv.fv_surv_exceptions OWNER TO postgres;

--
-- TOC entry 2458 (class 1259 OID 86810798)
-- Name: fv_surv_well_events; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.fv_surv_well_events WITH (security_barrier='false') AS
 SELECT DISTINCT wc.api_no14,
    e.date_ops_end AS event_date,
    'OpenWells Events'::text AS source,
    concat(COALESCE(upper(e.event_type), ''::text), ' -- ', COALESCE(upper(e.event_objective_1), ''::text), ' ', COALESCE(upper(e.event_objective_2), ''::text)) AS comments
   FROM (crc.mv_bi_wellcomp wc
     JOIN crc_edm.u_dm_event_t e ON ((wc.well_id = e.well_id)))
  WHERE ((e.date_ops_end IS NOT NULL) AND (e.event_type IS NOT NULL));


ALTER TABLE bi_surv.fv_surv_well_events OWNER TO postgres;

--
-- TOC entry 2456 (class 1259 OID 86810780)
-- Name: fv_surv_well_notes; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.fv_surv_well_notes WITH (security_barrier='false') AS
 SELECT note.api_no14,
    note.comment_date,
    note.comment_by,
    note.source,
    note.comments,
    mvd.mindate,
    mvd.maxdate
   FROM (( SELECT DISTINCT COALESCE(wn.api_no14, wc.api_no14, wc2.api_no14) AS api_no14,
            wn.comment_date,
            wn.comment_by,
            wn.source,
            wn.comments
           FROM ((crc.mv_bi_well_notes wn
             LEFT JOIN crc.mv_bi_wellcomp wc ON ((wn.well_name = wc.automation_name)))
             LEFT JOIN crc.mv_bi_wellcomp wc2 ON ((wn.well_name = wc2.wellcomp_name)))) note
     LEFT JOIN ( SELECT mv.api_no14,
            min(mv.book_date) AS mindate,
            max(mv.prod_inj_date) AS maxdate
           FROM crc.mv_bi_monthly_volumes mv
          GROUP BY mv.api_no14) mvd ON ((note.api_no14 = mvd.api_no14)))
  WHERE ((note.api_no14 IS NOT NULL) AND (note.comment_date IS NOT NULL) AND (mvd.mindate IS NOT NULL) AND (mvd.maxdate IS NOT NULL) AND (note.comment_date >= mvd.mindate) AND (note.comment_date <= mvd.maxdate));


ALTER TABLE bi_surv.fv_surv_well_notes OWNER TO postgres;

--
-- TOC entry 2454 (class 1259 OID 86810748)
-- Name: fv_surv_well_test; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.fv_surv_well_test WITH (security_barrier='false') AS
 SELECT DISTINCT wt.api_no14,
    wt.well_test_date AS test_date,
    wtdate.last_test_date,
    wt.test_type,
    wt.oil_rate,
    wt.gas_rate,
    wt.water_rate,
    wt.gas_lift_rate,
    wt.gas_oil_ratio,
    wt.tubing_press,
    wt.casing_press,
    wt.line_press,
    wt.allocatable,
    wt.oil_gravity,
    wt.choke_size,
    wt.pump_eff,
    wt.water_cut,
    wt.stroke_length,
    wt.strokes_minute,
    wt.pump_bore_size,
    wt.prod_hours,
    wt.test_hours,
    wt.hertz,
    wt.amps,
    wt.fluid_level,
    wt.pump_intake_press,
    wt.wellhead_temp,
    wt.salinity,
    wt.bsw
   FROM ((crc.mv_bi_well_test wt
     JOIN crc.mv_bi_wellcomp wc ON ((wt.api_no14 = wc.api_no14)))
     JOIN ( SELECT wt2.api_no14,
            max(wt2.well_test_date) AS last_test_date
           FROM crc.mv_bi_well_test wt2
          GROUP BY wt2.api_no14) wtdate ON ((wt.api_no14 = wtdate.api_no14)));


ALTER TABLE bi_surv.fv_surv_well_test OWNER TO postgres;

--
-- TOC entry 2480 (class 1259 OID 86811038)
-- Name: mv_dv_surv_ws_well_dictionary; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_dv_surv_ws_well_dictionary AS
 SELECT wd.api_no14,
    wd.op_area,
    wd.orglev4_name,
    wd.well_name,
    wd.currenttype,
    wd.currentstatus,
    wd.status_eff_date,
    wd.reservoir_cd,
    wd.top_interval_tvd,
    wd.btm_interval_tvd,
    wd.topmd,
    wd.bottommd,
    wd.type_interval,
    wd.well_spud_date,
    wd.completion_date,
    wd.first_prod_date,
    wd.curr_method_prod,
    wd.battery_name,
    wd.surf_latitude,
    wd.surf_longitude,
    wd.bh_latitude,
    wd.bh_longitude,
    wd.interest_type,
    wd.kickoff_date,
    wd.section,
    wd.township,
    wd.range_no,
    wd.test_facility,
    wd.structure_code,
    wd.fault_block,
    wd.sector
   FROM bi_surv.dv_surv_ws_well_dictionary wd
  WITH NO DATA;


ALTER TABLE bi_surv.mv_dv_surv_ws_well_dictionary OWNER TO postgres;

--
-- TOC entry 2474 (class 1259 OID 86810968)
-- Name: mv_fv_surv_allocated_volume_cums; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_fv_surv_allocated_volume_cums AS
 SELECT avc.api_no14,
    avc.allocated_date,
    avc.oil_cum,
    avc.gas_cum,
    avc.gross_cum,
    avc.water_cum,
    avc.water_inj_cum,
    avc.gas_inj_cum,
    avc.steam_inj_cum,
    avc.steamc_inj_cum,
    avc.disp_water_inj_cum,
    avc.lastproddate
   FROM bi_surv.fv_surv_allocated_volume_cums avc
  WITH NO DATA;


ALTER TABLE bi_surv.mv_fv_surv_allocated_volume_cums OWNER TO postgres;

--
-- TOC entry 2455 (class 1259 OID 86810762)
-- Name: mv_fv_surv_well_test; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_fv_surv_well_test AS
 SELECT wt.api_no14,
    wt.test_date,
    wt.last_test_date,
    wt.test_type,
    wt.oil_rate,
    wt.gas_rate,
    wt.water_rate,
    wt.gas_lift_rate,
    wt.gas_oil_ratio,
    wt.tubing_press,
    wt.casing_press,
    wt.line_press,
    wt.allocatable,
    wt.oil_gravity,
    wt.choke_size,
    wt.pump_eff,
    wt.water_cut,
    wt.stroke_length,
    wt.strokes_minute,
    wt.pump_bore_size,
    wt.prod_hours,
    wt.test_hours,
    wt.hertz,
    wt.amps,
    wt.fluid_level,
    wt.pump_intake_press,
    wt.wellhead_temp,
    wt.salinity,
    wt.bsw
   FROM bi_surv.fv_surv_well_test wt
  WITH NO DATA;


ALTER TABLE bi_surv.mv_fv_surv_well_test OWNER TO postgres;

--
-- TOC entry 2481 (class 1259 OID 86811047)
-- Name: fv_surv_well_summary; Type: VIEW; Schema: bi_surv; Owner: postgres
--

CREATE VIEW bi_surv.fv_surv_well_summary AS
 SELECT DISTINCT wd.api_no14,
    wd.orglev4_name,
    wd.op_area,
    wd.well_name,
    wd.currenttype,
    wd.currentstatus,
    wd.status_eff_date,
    wd.reservoir_cd,
    wd.top_interval_tvd,
    wd.btm_interval_tvd,
    wd.topmd,
    wd.bottommd,
    wd.completion_date,
    wd.curr_method_prod,
    wd.battery_name,
    wd.surf_latitude,
    wd.surf_longitude,
    wd.bh_latitude,
    wd.bh_longitude,
    wd.interest_type,
    wd.kickoff_date,
    wd.section,
    wd.township,
    wd.range_no,
    wd.test_facility,
    wd.structure_code,
    wd.fault_block,
    wd.sector,
    prod.lastproddate AS last_prod_date,
    test.last_test_date,
    prod.last_allocated_oil,
    prod.last_allocated_water,
    prod.last_allocated_gas,
    prod.last_allocated_gross,
    prod.last_allocated_water_inj,
    prod.last_allocated_gas_inj,
    prod.last_allocated_steam_inj,
    prod.last_allocated_cyc_steam_inj,
    prod.last_allocated_wat_disp_inj,
    prod.last_allocated_gor,
    prod.last_allocated_wor,
    prod.last_allocated_water_cut,
    cums.cum_allocated_oil,
    cums.cum_allocated_water,
    cums.cum_allocated_gas,
    cums.cum_allocated_gross,
    cums.cum_allocated_water_inj,
    cums.cum_allocated_gas_inj,
    cums.cum_allocated_steam_inj,
    cums.cum_allocated_cyc_steam_inj,
    cums.cum_allocated_wat_disp_inj,
    test.last_tubing_press,
    test.last_casing_press,
    test.last_pump_eff,
    test.last_pump_intake_press,
    test.last_stroke_length,
    test.last_strokes_minute,
    test.last_fluid_level,
    test.last_test_water_cut,
    prod.firstproddate AS first_prod_date
   FROM (((bi_surv.mv_dv_surv_ws_well_dictionary wd
     LEFT JOIN ( SELECT av.api_no14,
            av.lastproddate,
            av.firstproddate,
            av.cdoil_prod AS last_allocated_oil,
            av.cdwater_prod AS last_allocated_water,
            av.cdgas_prod AS last_allocated_gas,
            av.cdgross_liq_prod AS last_allocated_gross,
            av.cdwater_inj AS last_allocated_water_inj,
            av.cdgas_inj AS last_allocated_gas_inj,
            av.cdsteam_inj AS last_allocated_steam_inj,
            av.cdsteamc_inj AS last_allocated_cyc_steam_inj,
            av.cddispwat_inj AS last_allocated_wat_disp_inj,
            av.gor_prod AS last_allocated_gor,
            av.wor_prod AS last_allocated_wor,
            av.water_cut_prod AS last_allocated_water_cut
           FROM bi_surv.mv_fv_surv_allocated_volume_calcs av
          WHERE (av.allocated_date = av.lastproddate)) prod ON ((wd.api_no14 = prod.api_no14)))
     LEFT JOIN ( SELECT wt.api_no14,
            wt.last_test_date,
            wt.tubing_press AS last_tubing_press,
            wt.casing_press AS last_casing_press,
            (wt.pump_eff)::real AS last_pump_eff,
            wt.pump_intake_press AS last_pump_intake_press,
            wt.stroke_length AS last_stroke_length,
            wt.strokes_minute AS last_strokes_minute,
            wt.fluid_level AS last_fluid_level,
            wt.water_cut AS last_test_water_cut
           FROM bi_surv.mv_fv_surv_well_test wt
          WHERE (wt.test_date = wt.last_test_date)) test ON ((wd.api_no14 = test.api_no14)))
     LEFT JOIN ( SELECT avcu.api_no14,
            avcu.lastproddate,
            avcu.oil_cum AS cum_allocated_oil,
            avcu.water_cum AS cum_allocated_water,
            avcu.gas_cum AS cum_allocated_gas,
            avcu.gross_cum AS cum_allocated_gross,
            avcu.water_inj_cum AS cum_allocated_water_inj,
            avcu.gas_inj_cum AS cum_allocated_gas_inj,
            avcu.steam_inj_cum AS cum_allocated_steam_inj,
            avcu.steamc_inj_cum AS cum_allocated_cyc_steam_inj,
            avcu.disp_water_inj_cum AS cum_allocated_wat_disp_inj
           FROM bi_surv.mv_fv_surv_allocated_volume_cums avcu
          WHERE (avcu.allocated_date = avcu.lastproddate)) cums ON ((wd.api_no14 = cums.api_no14)));


ALTER TABLE bi_surv.fv_surv_well_summary OWNER TO postgres;

--
-- TOC entry 2472 (class 1259 OID 86810954)
-- Name: mv_fv_surv_daily_injection; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_fv_surv_daily_injection AS
 SELECT di.api_no14,
    di.inj_date,
    di.inj_fluid_type,
    di.inj_rate,
    di.inj_casing_press,
    di.inj_tubing_press,
    di.avg_inj_press,
    di.pressure_setpoint
   FROM bi_surv.fv_surv_daily_injection di
  WITH NO DATA;


ALTER TABLE bi_surv.mv_fv_surv_daily_injection OWNER TO postgres;

--
-- TOC entry 2470 (class 1259 OID 86810940)
-- Name: mv_fv_surv_exceptions; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_fv_surv_exceptions AS
 SELECT e.api_no14,
    e.var_date,
    e.cdoil_prod_var,
    e.cdgas_prod_var,
    e.cdwat_prod_var,
    e.cdgross_liq_prod_var,
    e.cdwat_inj_var,
    e.cdgas_inj_var,
    e.cdsteam_inj_var,
    e.cdsteamc_inj_var,
    e.yesterdays_inferred_production_var,
    e.yesterdays_gas_volume_var,
    e.casing_pressure_var,
    e.differential_pressure_var,
    e.injection_pressure_var,
    e.yesterdays_runtime_var,
    e.flowline_pressure_var,
    e.well_test_oil_var,
    e.well_test_gross_var,
    e.water_rate_var
   FROM bi_surv.fv_surv_exceptions e
  WITH NO DATA;


ALTER TABLE bi_surv.mv_fv_surv_exceptions OWNER TO postgres;

--
-- TOC entry 2459 (class 1259 OID 86810837)
-- Name: mv_fv_surv_well_events; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_fv_surv_well_events AS
 SELECT we.api_no14,
    we.event_date,
    we.source,
    we.comments
   FROM bi_surv.fv_surv_well_events we
  WITH NO DATA;


ALTER TABLE bi_surv.mv_fv_surv_well_events OWNER TO postgres;

--
-- TOC entry 2457 (class 1259 OID 86810790)
-- Name: mv_fv_surv_well_notes; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_fv_surv_well_notes AS
 SELECT wn.api_no14,
    wn.comment_date,
    wn.comment_by,
    wn.source,
    wn.comments,
    wn.mindate,
    wn.maxdate
   FROM bi_surv.fv_surv_well_notes wn
  WITH NO DATA;


ALTER TABLE bi_surv.mv_fv_surv_well_notes OWNER TO postgres;

--
-- TOC entry 2482 (class 1259 OID 86811052)
-- Name: mv_fv_surv_well_summary; Type: MATERIALIZED VIEW; Schema: bi_surv; Owner: postgres
--

CREATE MATERIALIZED VIEW bi_surv.mv_fv_surv_well_summary AS
 SELECT ws.api_no14,
    ws.orglev4_name,
    ws.op_area,
    ws.well_name,
    ws.currenttype,
    ws.currentstatus,
    ws.status_eff_date,
    ws.reservoir_cd,
    ws.top_interval_tvd,
    ws.btm_interval_tvd,
    ws.topmd,
    ws.bottommd,
    ws.completion_date,
    ws.curr_method_prod,
    ws.battery_name,
    ws.surf_latitude,
    ws.surf_longitude,
    ws.bh_latitude,
    ws.bh_longitude,
    ws.interest_type,
    ws.kickoff_date,
    ws.section,
    ws.township,
    ws.range_no,
    ws.test_facility,
    ws.structure_code,
    ws.fault_block,
    ws.sector,
    ws.last_prod_date,
    ws.last_test_date,
    ws.last_allocated_oil,
    ws.last_allocated_water,
    ws.last_allocated_gas,
    ws.last_allocated_gross,
    ws.last_allocated_water_inj,
    ws.last_allocated_gas_inj,
    ws.last_allocated_steam_inj,
    ws.last_allocated_cyc_steam_inj,
    ws.last_allocated_wat_disp_inj,
    ws.last_allocated_gor,
    ws.last_allocated_wor,
    ws.last_allocated_water_cut,
    ws.cum_allocated_oil,
    ws.cum_allocated_water,
    ws.cum_allocated_gas,
    ws.cum_allocated_gross,
    ws.cum_allocated_water_inj,
    ws.cum_allocated_gas_inj,
    ws.cum_allocated_steam_inj,
    ws.cum_allocated_cyc_steam_inj,
    ws.cum_allocated_wat_disp_inj,
    ws.last_tubing_press,
    ws.last_casing_press,
    ws.last_pump_eff,
    ws.last_pump_intake_press,
    ws.last_stroke_length,
    ws.last_strokes_minute,
    ws.last_fluid_level,
    ws.last_test_water_cut,
    ws.first_prod_date
   FROM bi_surv.fv_surv_well_summary ws
  WITH NO DATA;


ALTER TABLE bi_surv.mv_fv_surv_well_summary OWNER TO postgres;

--
-- TOC entry 12853 (class 1259 OID 86810914)
-- Name: surv_avc_api14_adate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_avc_api14_adate ON bi_surv.mv_fv_surv_allocated_volume_calcs USING btree (api_no14, allocated_date);


--
-- TOC entry 12854 (class 1259 OID 86810915)
-- Name: surv_avc_api14_adate_lpdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_avc_api14_adate_lpdate ON bi_surv.mv_fv_surv_allocated_volume_calcs USING btree (api_no14, allocated_date, lastproddate);


--
-- TOC entry 12858 (class 1259 OID 86810975)
-- Name: surv_avcu_api14_adate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_avcu_api14_adate ON bi_surv.mv_fv_surv_allocated_volume_cums USING btree (api_no14, allocated_date);


--
-- TOC entry 12859 (class 1259 OID 86810976)
-- Name: surv_avcu_api14_adate_lpdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_avcu_api14_adate_lpdate ON bi_surv.mv_fv_surv_allocated_volume_cums USING btree (api_no14, allocated_date, lastproddate);


--
-- TOC entry 12857 (class 1259 OID 86810961)
-- Name: surv_dinj_api14_idate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_dinj_api14_idate ON bi_surv.mv_fv_surv_daily_injection USING btree (api_no14, inj_date);


--
-- TOC entry 12851 (class 1259 OID 86810870)
-- Name: surv_exc_anda_api14_adate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_exc_anda_api14_adate ON bi_surv.mv_dv_surv_exc_analog_data USING btree (api_no14, analog_date);


--
-- TOC entry 12852 (class 1259 OID 86810886)
-- Name: surv_exc_anv_api14_andate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_exc_anv_api14_andate ON bi_surv.mv_dv_surv_exc_analog_var USING btree (api_no14, analog_date);


--
-- TOC entry 12856 (class 1259 OID 86810947)
-- Name: surv_exc_api14_vdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_exc_api14_vdate ON bi_surv.mv_fv_surv_exceptions USING btree (api_no14, var_date);


--
-- TOC entry 12855 (class 1259 OID 86810932)
-- Name: surv_exc_avv_api14_adate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_exc_avv_api14_adate ON bi_surv.mv_dv_surv_exc_allocated_volume_var USING btree (api_no14, allocated_date);


--
-- TOC entry 12850 (class 1259 OID 86810844)
-- Name: surv_we_api14_edate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_we_api14_edate ON bi_surv.mv_fv_surv_well_events USING btree (api_no14, event_date);


--
-- TOC entry 12849 (class 1259 OID 86810797)
-- Name: surv_wn_api14_cdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_wn_api14_cdate ON bi_surv.mv_fv_surv_well_notes USING btree (api_no14, comment_date);


--
-- TOC entry 12863 (class 1259 OID 86811060)
-- Name: surv_ws_api14; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_ws_api14 ON bi_surv.mv_fv_surv_well_summary USING btree (api_no14);


--
-- TOC entry 12864 (class 1259 OID 86811061)
-- Name: surv_ws_api14_fpdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_ws_api14_fpdate ON bi_surv.mv_fv_surv_well_summary USING btree (api_no14, first_prod_date);


--
-- TOC entry 12865 (class 1259 OID 86811062)
-- Name: surv_ws_api14_lpdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_ws_api14_lpdate ON bi_surv.mv_fv_surv_well_summary USING btree (api_no14, last_prod_date);


--
-- TOC entry 12866 (class 1259 OID 86811063)
-- Name: surv_ws_api14_ltdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_ws_api14_ltdate ON bi_surv.mv_fv_surv_well_summary USING btree (api_no14, last_test_date);


--
-- TOC entry 12860 (class 1259 OID 86810999)
-- Name: surv_ws_uwl_api14; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_ws_uwl_api14 ON bi_surv.mv_dv_surv_ws_untransformed_well_locations USING btree (api_no14);


--
-- TOC entry 12861 (class 1259 OID 86811000)
-- Name: surv_ws_uwl_api14_gdid; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_ws_uwl_api14_gdid ON bi_surv.mv_dv_surv_ws_untransformed_well_locations USING btree (api_no14, geo_datum_id);


--
-- TOC entry 12862 (class 1259 OID 86811046)
-- Name: surv_ws_wd_api14; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_ws_wd_api14 ON bi_surv.mv_dv_surv_ws_well_dictionary USING btree (api_no14);


--
-- TOC entry 12847 (class 1259 OID 86810770)
-- Name: surv_wt_api14_tdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_wt_api14_tdate ON bi_surv.mv_fv_surv_well_test USING btree (api_no14, test_date);


--
-- TOC entry 12848 (class 1259 OID 86810771)
-- Name: surv_wt_api14_tdate_ltdate; Type: INDEX; Schema: bi_surv; Owner: postgres
--

CREATE INDEX surv_wt_api14_tdate_ltdate ON bi_surv.mv_fv_surv_well_test USING btree (api_no14, test_date, last_test_date);


--
-- TOC entry 13706 (class 0 OID 0)
-- Dependencies: 540
-- Name: SCHEMA bi_surv; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA bi_surv TO data_quality;
GRANT ALL ON SCHEMA bi_surv TO data_analytics;
GRANT USAGE ON SCHEMA bi_surv TO read_only;
GRANT USAGE ON SCHEMA bi_surv TO data_science;
GRANT USAGE ON SCHEMA bi_surv TO web_anon;


--
-- TOC entry 13707 (class 0 OID 0)
-- Dependencies: 2464
-- Name: TABLE dv_surv_av_allocated_cross; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.dv_surv_av_allocated_cross TO data_quality;
GRANT ALL ON TABLE bi_surv.dv_surv_av_allocated_cross TO data_analytics;
GRANT SELECT ON TABLE bi_surv.dv_surv_av_allocated_cross TO read_only;
GRANT SELECT ON TABLE bi_surv.dv_surv_av_allocated_cross TO data_science;
GRANT ALL ON TABLE bi_surv.dv_surv_av_allocated_cross TO web_anon;


--
-- TOC entry 13708 (class 0 OID 0)
-- Dependencies: 2465
-- Name: TABLE fv_surv_allocated_volume_calcs; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.fv_surv_allocated_volume_calcs TO data_quality;
GRANT ALL ON TABLE bi_surv.fv_surv_allocated_volume_calcs TO data_analytics;
GRANT SELECT ON TABLE bi_surv.fv_surv_allocated_volume_calcs TO read_only;
GRANT SELECT ON TABLE bi_surv.fv_surv_allocated_volume_calcs TO data_science;
GRANT ALL ON TABLE bi_surv.fv_surv_allocated_volume_calcs TO web_anon;


--
-- TOC entry 13709 (class 0 OID 0)
-- Dependencies: 2466
-- Name: TABLE mv_fv_surv_allocated_volume_calcs; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_fv_surv_allocated_volume_calcs TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_allocated_volume_calcs TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_allocated_volume_calcs TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_allocated_volume_calcs TO data_science;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_allocated_volume_calcs TO web_anon;


--
-- TOC entry 13710 (class 0 OID 0)
-- Dependencies: 2467
-- Name: TABLE dv_surv_exc_allocated_volume_var; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.dv_surv_exc_allocated_volume_var TO data_quality;
GRANT ALL ON TABLE bi_surv.dv_surv_exc_allocated_volume_var TO data_analytics;
GRANT SELECT ON TABLE bi_surv.dv_surv_exc_allocated_volume_var TO read_only;
GRANT SELECT ON TABLE bi_surv.dv_surv_exc_allocated_volume_var TO data_science;
GRANT ALL ON TABLE bi_surv.dv_surv_exc_allocated_volume_var TO web_anon;


--
-- TOC entry 13711 (class 0 OID 0)
-- Dependencies: 2460
-- Name: TABLE dv_surv_exc_analog_data; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.dv_surv_exc_analog_data TO data_quality;
GRANT ALL ON TABLE bi_surv.dv_surv_exc_analog_data TO data_analytics;
GRANT SELECT ON TABLE bi_surv.dv_surv_exc_analog_data TO read_only;
GRANT SELECT ON TABLE bi_surv.dv_surv_exc_analog_data TO data_science;
GRANT ALL ON TABLE bi_surv.dv_surv_exc_analog_data TO web_anon;


--
-- TOC entry 13712 (class 0 OID 0)
-- Dependencies: 2461
-- Name: TABLE mv_dv_surv_exc_analog_data; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_analog_data TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_exc_analog_data TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_analog_data TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_analog_data TO data_science;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_exc_analog_data TO web_anon;


--
-- TOC entry 13713 (class 0 OID 0)
-- Dependencies: 2462
-- Name: TABLE dv_surv_exc_analog_var; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.dv_surv_exc_analog_var TO data_quality;
GRANT ALL ON TABLE bi_surv.dv_surv_exc_analog_var TO data_analytics;
GRANT SELECT ON TABLE bi_surv.dv_surv_exc_analog_var TO read_only;
GRANT SELECT ON TABLE bi_surv.dv_surv_exc_analog_var TO data_science;
GRANT ALL ON TABLE bi_surv.dv_surv_exc_analog_var TO web_anon;


--
-- TOC entry 13714 (class 0 OID 0)
-- Dependencies: 2477
-- Name: TABLE dv_surv_ws_org_units; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.dv_surv_ws_org_units TO data_quality;
GRANT ALL ON TABLE bi_surv.dv_surv_ws_org_units TO data_analytics;
GRANT SELECT ON TABLE bi_surv.dv_surv_ws_org_units TO read_only;
GRANT SELECT ON TABLE bi_surv.dv_surv_ws_org_units TO data_science;
GRANT ALL ON TABLE bi_surv.dv_surv_ws_org_units TO web_anon;


--
-- TOC entry 13715 (class 0 OID 0)
-- Dependencies: 2475
-- Name: TABLE dv_surv_ws_untransformed_well_locations; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.dv_surv_ws_untransformed_well_locations TO data_quality;
GRANT ALL ON TABLE bi_surv.dv_surv_ws_untransformed_well_locations TO data_analytics;
GRANT SELECT ON TABLE bi_surv.dv_surv_ws_untransformed_well_locations TO read_only;
GRANT SELECT ON TABLE bi_surv.dv_surv_ws_untransformed_well_locations TO data_science;
GRANT ALL ON TABLE bi_surv.dv_surv_ws_untransformed_well_locations TO web_anon;


--
-- TOC entry 13716 (class 0 OID 0)
-- Dependencies: 2476
-- Name: TABLE mv_dv_surv_ws_untransformed_well_locations; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_dv_surv_ws_untransformed_well_locations TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_ws_untransformed_well_locations TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_ws_untransformed_well_locations TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_ws_untransformed_well_locations TO data_science;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_ws_untransformed_well_locations TO web_anon;


--
-- TOC entry 13717 (class 0 OID 0)
-- Dependencies: 2478
-- Name: TABLE dv_surv_ws_well_locations; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.dv_surv_ws_well_locations TO data_quality;
GRANT ALL ON TABLE bi_surv.dv_surv_ws_well_locations TO data_analytics;
GRANT SELECT ON TABLE bi_surv.dv_surv_ws_well_locations TO read_only;
GRANT SELECT ON TABLE bi_surv.dv_surv_ws_well_locations TO data_science;
GRANT ALL ON TABLE bi_surv.dv_surv_ws_well_locations TO web_anon;


--
-- TOC entry 13718 (class 0 OID 0)
-- Dependencies: 2479
-- Name: TABLE dv_surv_ws_well_dictionary; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.dv_surv_ws_well_dictionary TO data_quality;
GRANT ALL ON TABLE bi_surv.dv_surv_ws_well_dictionary TO data_analytics;
GRANT SELECT ON TABLE bi_surv.dv_surv_ws_well_dictionary TO read_only;
GRANT SELECT ON TABLE bi_surv.dv_surv_ws_well_dictionary TO data_science;
GRANT ALL ON TABLE bi_surv.dv_surv_ws_well_dictionary TO web_anon;


--
-- TOC entry 13719 (class 0 OID 0)
-- Dependencies: 2473
-- Name: TABLE fv_surv_allocated_volume_cums; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.fv_surv_allocated_volume_cums TO data_quality;
GRANT ALL ON TABLE bi_surv.fv_surv_allocated_volume_cums TO data_analytics;
GRANT SELECT ON TABLE bi_surv.fv_surv_allocated_volume_cums TO read_only;
GRANT SELECT ON TABLE bi_surv.fv_surv_allocated_volume_cums TO data_science;
GRANT ALL ON TABLE bi_surv.fv_surv_allocated_volume_cums TO web_anon;


--
-- TOC entry 13720 (class 0 OID 0)
-- Dependencies: 2471
-- Name: TABLE fv_surv_daily_injection; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.fv_surv_daily_injection TO data_quality;
GRANT ALL ON TABLE bi_surv.fv_surv_daily_injection TO data_analytics;
GRANT SELECT ON TABLE bi_surv.fv_surv_daily_injection TO read_only;
GRANT SELECT ON TABLE bi_surv.fv_surv_daily_injection TO data_science;
GRANT ALL ON TABLE bi_surv.fv_surv_daily_injection TO web_anon;


--
-- TOC entry 13721 (class 0 OID 0)
-- Dependencies: 2468
-- Name: TABLE mv_dv_surv_exc_allocated_volume_var; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_allocated_volume_var TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_exc_allocated_volume_var TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_allocated_volume_var TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_allocated_volume_var TO data_science;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_exc_allocated_volume_var TO web_anon;


--
-- TOC entry 13722 (class 0 OID 0)
-- Dependencies: 2463
-- Name: TABLE mv_dv_surv_exc_analog_var; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_analog_var TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_exc_analog_var TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_analog_var TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_exc_analog_var TO data_science;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_exc_analog_var TO web_anon;


--
-- TOC entry 13723 (class 0 OID 0)
-- Dependencies: 2469
-- Name: TABLE fv_surv_exceptions; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.fv_surv_exceptions TO data_quality;
GRANT ALL ON TABLE bi_surv.fv_surv_exceptions TO data_analytics;
GRANT SELECT ON TABLE bi_surv.fv_surv_exceptions TO read_only;
GRANT SELECT ON TABLE bi_surv.fv_surv_exceptions TO data_science;
GRANT ALL ON TABLE bi_surv.fv_surv_exceptions TO web_anon;


--
-- TOC entry 13724 (class 0 OID 0)
-- Dependencies: 2458
-- Name: TABLE fv_surv_well_events; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.fv_surv_well_events TO data_quality;
GRANT ALL ON TABLE bi_surv.fv_surv_well_events TO data_analytics;
GRANT SELECT ON TABLE bi_surv.fv_surv_well_events TO read_only;
GRANT SELECT ON TABLE bi_surv.fv_surv_well_events TO data_science;
GRANT ALL ON TABLE bi_surv.fv_surv_well_events TO web_anon;


--
-- TOC entry 13725 (class 0 OID 0)
-- Dependencies: 2456
-- Name: TABLE fv_surv_well_notes; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.fv_surv_well_notes TO data_quality;
GRANT ALL ON TABLE bi_surv.fv_surv_well_notes TO data_analytics;
GRANT SELECT ON TABLE bi_surv.fv_surv_well_notes TO read_only;
GRANT SELECT ON TABLE bi_surv.fv_surv_well_notes TO data_science;
GRANT ALL ON TABLE bi_surv.fv_surv_well_notes TO web_anon;


--
-- TOC entry 13726 (class 0 OID 0)
-- Dependencies: 2454
-- Name: TABLE fv_surv_well_test; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.fv_surv_well_test TO data_quality;
GRANT ALL ON TABLE bi_surv.fv_surv_well_test TO data_analytics;
GRANT SELECT ON TABLE bi_surv.fv_surv_well_test TO read_only;
GRANT SELECT ON TABLE bi_surv.fv_surv_well_test TO data_science;
GRANT ALL ON TABLE bi_surv.fv_surv_well_test TO web_anon;


--
-- TOC entry 13727 (class 0 OID 0)
-- Dependencies: 2480
-- Name: TABLE mv_dv_surv_ws_well_dictionary; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_dv_surv_ws_well_dictionary TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_ws_well_dictionary TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_ws_well_dictionary TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_dv_surv_ws_well_dictionary TO data_science;
GRANT ALL ON TABLE bi_surv.mv_dv_surv_ws_well_dictionary TO web_anon;


--
-- TOC entry 13728 (class 0 OID 0)
-- Dependencies: 2474
-- Name: TABLE mv_fv_surv_allocated_volume_cums; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_fv_surv_allocated_volume_cums TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_allocated_volume_cums TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_allocated_volume_cums TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_allocated_volume_cums TO data_science;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_allocated_volume_cums TO web_anon;


--
-- TOC entry 13729 (class 0 OID 0)
-- Dependencies: 2455
-- Name: TABLE mv_fv_surv_well_test; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_test TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_well_test TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_test TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_test TO data_science;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_well_test TO web_anon;


--
-- TOC entry 13730 (class 0 OID 0)
-- Dependencies: 2481
-- Name: TABLE fv_surv_well_summary; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.fv_surv_well_summary TO data_quality;
GRANT ALL ON TABLE bi_surv.fv_surv_well_summary TO data_analytics;
GRANT SELECT ON TABLE bi_surv.fv_surv_well_summary TO read_only;
GRANT SELECT ON TABLE bi_surv.fv_surv_well_summary TO data_science;
GRANT ALL ON TABLE bi_surv.fv_surv_well_summary TO web_anon;


--
-- TOC entry 13731 (class 0 OID 0)
-- Dependencies: 2472
-- Name: TABLE mv_fv_surv_daily_injection; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_fv_surv_daily_injection TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_daily_injection TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_daily_injection TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_daily_injection TO data_science;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_daily_injection TO web_anon;


--
-- TOC entry 13732 (class 0 OID 0)
-- Dependencies: 2470
-- Name: TABLE mv_fv_surv_exceptions; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_fv_surv_exceptions TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_exceptions TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_exceptions TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_exceptions TO data_science;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_exceptions TO web_anon;


--
-- TOC entry 13733 (class 0 OID 0)
-- Dependencies: 2459
-- Name: TABLE mv_fv_surv_well_events; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_events TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_well_events TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_events TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_events TO data_science;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_well_events TO web_anon;


--
-- TOC entry 13734 (class 0 OID 0)
-- Dependencies: 2457
-- Name: TABLE mv_fv_surv_well_notes; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_notes TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_well_notes TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_notes TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_notes TO data_science;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_well_notes TO web_anon;


--
-- TOC entry 13735 (class 0 OID 0)
-- Dependencies: 2482
-- Name: TABLE mv_fv_surv_well_summary; Type: ACL; Schema: bi_surv; Owner: postgres
--

GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_summary TO data_quality;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_well_summary TO data_analytics;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_summary TO read_only;
GRANT SELECT ON TABLE bi_surv.mv_fv_surv_well_summary TO data_science;
GRANT ALL ON TABLE bi_surv.mv_fv_surv_well_summary TO web_anon;


--
-- TOC entry 10786 (class 826 OID 90448735)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: bi_surv; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA bi_surv REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA bi_surv GRANT USAGE ON SEQUENCES  TO data_analytics;


--
-- TOC entry 10789 (class 826 OID 90433145)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: bi_surv; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA bi_surv REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA bi_surv GRANT SELECT ON TABLES  TO data_quality;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA bi_surv GRANT ALL ON TABLES  TO data_analytics;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA bi_surv GRANT SELECT ON TABLES  TO read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA bi_surv GRANT SELECT ON TABLES  TO data_science;


--
-- TOC entry 13693 (class 0 OID 86810906)
-- Dependencies: 2466 13702
-- Name: mv_fv_surv_allocated_volume_calcs; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_fv_surv_allocated_volume_calcs;


--
-- TOC entry 13694 (class 0 OID 86810925)
-- Dependencies: 2468 13693 13702
-- Name: mv_dv_surv_exc_allocated_volume_var; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_dv_surv_exc_allocated_volume_var;


--
-- TOC entry 13691 (class 0 OID 86810863)
-- Dependencies: 2461 13702
-- Name: mv_dv_surv_exc_analog_data; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_dv_surv_exc_analog_data;


--
-- TOC entry 13692 (class 0 OID 86810879)
-- Dependencies: 2463 13691 13702
-- Name: mv_dv_surv_exc_analog_var; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_dv_surv_exc_analog_var;


--
-- TOC entry 13698 (class 0 OID 86810992)
-- Dependencies: 2476 13702
-- Name: mv_dv_surv_ws_untransformed_well_locations; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_dv_surv_ws_untransformed_well_locations;


--
-- TOC entry 13699 (class 0 OID 86811038)
-- Dependencies: 2480 13698 13702
-- Name: mv_dv_surv_ws_well_dictionary; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_dv_surv_ws_well_dictionary;


--
-- TOC entry 13697 (class 0 OID 86810968)
-- Dependencies: 2474 13702
-- Name: mv_fv_surv_allocated_volume_cums; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_fv_surv_allocated_volume_cums;


--
-- TOC entry 13696 (class 0 OID 86810954)
-- Dependencies: 2472 13702
-- Name: mv_fv_surv_daily_injection; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_fv_surv_daily_injection;


--
-- TOC entry 13695 (class 0 OID 86810940)
-- Dependencies: 2470 13692 13694 13691 13693 13702
-- Name: mv_fv_surv_exceptions; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_fv_surv_exceptions;


--
-- TOC entry 13690 (class 0 OID 86810837)
-- Dependencies: 2459 13702
-- Name: mv_fv_surv_well_events; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_fv_surv_well_events;


--
-- TOC entry 13689 (class 0 OID 86810790)
-- Dependencies: 2457 13702
-- Name: mv_fv_surv_well_notes; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_fv_surv_well_notes;


--
-- TOC entry 13688 (class 0 OID 86810762)
-- Dependencies: 2455 13702
-- Name: mv_fv_surv_well_test; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_fv_surv_well_test;


--
-- TOC entry 13700 (class 0 OID 86811052)
-- Dependencies: 2482 13688 13693 13697 13699 13698 13702
-- Name: mv_fv_surv_well_summary; Type: MATERIALIZED VIEW DATA; Schema: bi_surv; Owner: postgres
--

REFRESH MATERIALIZED VIEW bi_surv.mv_fv_surv_well_summary;


-- Completed on 2020-01-14 09:03:01

--
-- PostgreSQL database dump complete
--

