--
-- PostgreSQL database dump
--

-- Dumped from database version 10.7
-- Dumped by pg_dump version 12.0

-- Started on 2020-01-14 08:32:17

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
-- TOC entry 528 (class 2615 OID 45323349)
-- Name: surv_dev; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA surv_dev;


ALTER SCHEMA surv_dev OWNER TO postgres;

--
-- TOC entry 2018 (class 1259 OID 53476510)
-- Name: dv_surv_dev_av_allocated_cross; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_av_allocated_cross AS
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


ALTER TABLE surv_dev.dv_surv_dev_av_allocated_cross OWNER TO postgres;

--
-- TOC entry 1934 (class 1259 OID 45323478)
-- Name: fv_surv_dev_allocated_volume_calcs; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.fv_surv_dev_allocated_volume_calcs AS
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
    (((date_part('month'::text, vol.prod_inj_date) - date_part('month'::text, min(vol.prod_inj_date) OVER (PARTITION BY vol.api_no14))) + ((date_part('year'::text, vol.prod_inj_date) - date_part('year'::text, min(vol.prod_inj_date) OVER (PARTITION BY vol.api_no14))) * (12)::double precision)))::numeric AS month_norm,
    min(ac.full_date) OVER (PARTITION BY ac.api_no14) AS firstproddate,
    max(ac.full_date) OVER (PARTITION BY ac.api_no14) AS lastproddate
   FROM (crc.mv_bi_monthly_volumes vol
     RIGHT JOIN surv_dev.dv_surv_dev_av_allocated_cross ac ON (((vol.api_no14 = ac.api_no14) AND (vol.prod_inj_date = ac.full_date))));


ALTER TABLE surv_dev.fv_surv_dev_allocated_volume_calcs OWNER TO postgres;

--
-- TOC entry 1936 (class 1259 OID 45323488)
-- Name: dv_surv_dev_exc_allocated_volume_var; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_exc_allocated_volume_var WITH (security_barrier='false') AS
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
   FROM (surv_dev.fv_surv_dev_allocated_volume_calcs avc
     RIGHT JOIN surv_dev.dv_surv_dev_av_allocated_cross ac ON (((avc.api_no14 = ac.api_no14) AND (avc.allocated_date = ac.full_date))))
  WHERE (ac.full_date > (now() - '365 days'::interval));


ALTER TABLE surv_dev.dv_surv_dev_exc_allocated_volume_var OWNER TO postgres;

--
-- TOC entry 2143 (class 1259 OID 75839103)
-- Name: dv_surv_dev_exc_analog_data; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_exc_analog_data AS
 SELECT wigd.api_no14,
    t1.date,
    upper(t1.nodeid) AS well_auto_name,
    t1.value,
    t2.addressname,
    t2.paramname,
    t2.facilitytag,
    t2.pocname,
    t2.controllermop,
    'XSPOC'::text AS source
   FROM ((( SELECT mv_u_tbldatahistory.date,
            mv_u_tbldatahistory.nodeid,
            mv_u_tbldatahistory.address,
            mv_u_tbldatahistory.value
           FROM crc_xspoc.mv_u_tbldatahistory) t1
     JOIN ( SELECT mv_well_analog_detail_reference.well_auto_name,
            mv_well_analog_detail_reference.pocname,
            mv_well_analog_detail_reference.address,
            mv_well_analog_detail_reference.addressname,
            mv_well_analog_detail_reference.paramname,
            mv_well_analog_detail_reference.controllermop,
            mv_well_analog_detail_reference.facilitytag
           FROM prod_ops.mv_well_analog_detail_reference) t2 ON (((t1.nodeid = t2.well_auto_name) AND (t1.address = t2.address))))
     LEFT JOIN bda.well_info_general_detail wigd ON ((wigd.well_auto_name = t1.nodeid)))
  WHERE (t2.paramname = ANY (ARRAY['Yesterdays Inferred Production'::text, 'Yesterdays Gas Volume'::text, 'Casing Pressure'::text, 'Differential Pressure'::text, 'Injection Pressure'::text, 'Yesterdays Runtime'::text, 'Pump Efficiency'::text, 'Flowline Pressure'::text, 'Well Test Oil'::text, 'Well Test Gross'::text, 'Water Rate'::text]));


ALTER TABLE surv_dev.dv_surv_dev_exc_analog_data OWNER TO postgres;

--
-- TOC entry 2311 (class 1259 OID 86429278)
-- Name: dv_surv_dev_exc_analog_data_2; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_exc_analog_data_2 AS
 SELECT wigd.api_no14,
    t1.date,
    upper(t1.nodeid) AS well_auto_name,
    t1.value,
    t2.addressname,
    t2.paramname,
    t2.facilitytag,
    t2.pocname,
    t2.controllermop,
    'XSPOC'::text AS source
   FROM ((( SELECT t.date,
            t.nodeid,
            t.address,
            t.value
           FROM ( SELECT mv_u_tbldatahistory.date,
                    mv_u_tbldatahistory.nodeid,
                    mv_u_tbldatahistory.address,
                    mv_u_tbldatahistory.value
                   FROM crc_xspoc.mv_u_tbldatahistory
                UNION ALL
                 SELECT mv_u_tbldatahistoryarchive.date,
                    mv_u_tbldatahistoryarchive.nodeid,
                    mv_u_tbldatahistoryarchive.address,
                    mv_u_tbldatahistoryarchive.value
                   FROM crc_xspoc.mv_u_tbldatahistoryarchive
                  WHERE ((mv_u_tbldatahistoryarchive.date < ( SELECT min(mv_u_tbldatahistory.date) AS min_d
                           FROM crc_xspoc.mv_u_tbldatahistory)) AND (mv_u_tbldatahistoryarchive.date > (now() - '1 year'::interval)))) t) t1
     JOIN ( SELECT mv_well_analog_detail_reference.well_auto_name,
            mv_well_analog_detail_reference.pocname,
            mv_well_analog_detail_reference.address,
            mv_well_analog_detail_reference.addressname,
            mv_well_analog_detail_reference.paramname,
            mv_well_analog_detail_reference.controllermop,
            mv_well_analog_detail_reference.facilitytag
           FROM prod_ops.mv_well_analog_detail_reference) t2 ON (((t1.nodeid = t2.well_auto_name) AND (t1.address = t2.address))))
     LEFT JOIN crc.mv_bi_wellcomp_v wigd ON ((wigd.automation_name = t1.nodeid)));


ALTER TABLE surv_dev.dv_surv_dev_exc_analog_data_2 OWNER TO postgres;

SET default_tablespace = '';

--
-- TOC entry 2144 (class 1259 OID 75839108)
-- Name: mv_dv_surv_dev_exc_analog_data; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_exc_analog_data AS
 SELECT dv_surv_dev_exc_analog_data.api_no14,
    dv_surv_dev_exc_analog_data.date,
    dv_surv_dev_exc_analog_data.well_auto_name,
    dv_surv_dev_exc_analog_data.value,
    dv_surv_dev_exc_analog_data.addressname,
    dv_surv_dev_exc_analog_data.paramname,
    dv_surv_dev_exc_analog_data.facilitytag,
    dv_surv_dev_exc_analog_data.pocname,
    dv_surv_dev_exc_analog_data.controllermop,
    dv_surv_dev_exc_analog_data.source
   FROM surv_dev.dv_surv_dev_exc_analog_data
  WITH NO DATA;


ALTER TABLE surv_dev.mv_dv_surv_dev_exc_analog_data OWNER TO postgres;

--
-- TOC entry 2151 (class 1259 OID 76418808)
-- Name: dv_surv_dev_exc_analog_data_pivot; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_exc_analog_data_pivot AS
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
   FROM ( SELECT mv_dv_surv_dev_exc_analog_data.api_no14,
            date_trunc('day'::text, mv_dv_surv_dev_exc_analog_data.date) AS analog_date,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Yesterdays Inferred Production'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS yesterdays_inferred_production,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Yesterdays Gas Volume'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS yesterdays_gas_volume,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Casing Pressure'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS casing_pressure,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Differential Pressure'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS differential_pressure,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Injection Pressure'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS injection_pressure,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Yesterdays Runtime'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS yesterdays_runtime,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Flowline Pressure'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS flowline_pressure,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Well Test Oil'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS well_test_oil,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Well Test Gross'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS well_test_gross,
                CASE
                    WHEN (mv_dv_surv_dev_exc_analog_data.paramname = 'Water Rate'::text) THEN avg(mv_dv_surv_dev_exc_analog_data.value)
                    ELSE NULL::double precision
                END AS water_rate
           FROM surv_dev.mv_dv_surv_dev_exc_analog_data
          GROUP BY mv_dv_surv_dev_exc_analog_data.api_no14, (date_trunc('day'::text, mv_dv_surv_dev_exc_analog_data.date)), mv_dv_surv_dev_exc_analog_data.paramname
          ORDER BY mv_dv_surv_dev_exc_analog_data.api_no14, (date_trunc('day'::text, mv_dv_surv_dev_exc_analog_data.date))) ad
  GROUP BY ad.api_no14, ad.analog_date;


ALTER TABLE surv_dev.dv_surv_dev_exc_analog_data_pivot OWNER TO postgres;

--
-- TOC entry 2186 (class 1259 OID 77044455)
-- Name: mv_dv_surv_dev_exc_analog_data_pivot; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_exc_analog_data_pivot AS
 SELECT dv_surv_dev_exc_analog_data_pivot.api_no14,
    dv_surv_dev_exc_analog_data_pivot.analog_date,
    dv_surv_dev_exc_analog_data_pivot.yesterdays_inferred_production,
    dv_surv_dev_exc_analog_data_pivot.yesterdays_gas_volume,
    dv_surv_dev_exc_analog_data_pivot.casing_pressure,
    dv_surv_dev_exc_analog_data_pivot.differential_pressure,
    dv_surv_dev_exc_analog_data_pivot.injection_pressure,
    dv_surv_dev_exc_analog_data_pivot.yesterdays_runtime,
    dv_surv_dev_exc_analog_data_pivot.flowline_pressure,
    dv_surv_dev_exc_analog_data_pivot.well_test_oil,
    dv_surv_dev_exc_analog_data_pivot.well_test_gross,
    dv_surv_dev_exc_analog_data_pivot.water_rate
   FROM surv_dev.dv_surv_dev_exc_analog_data_pivot
  WITH NO DATA;


ALTER TABLE surv_dev.mv_dv_surv_dev_exc_analog_data_pivot OWNER TO postgres;

--
-- TOC entry 2155 (class 1259 OID 76419942)
-- Name: dv_surv_dev_exc_analog_var; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_exc_analog_var AS
 SELECT mv_dv_surv_dev_exc_analog_data_pivot.api_no14,
    mv_dv_surv_dev_exc_analog_data_pivot.analog_date,
    (mv_dv_surv_dev_exc_analog_data_pivot.yesterdays_inferred_production - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.yesterdays_inferred_production) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS yesterdays_inferred_production_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.yesterdays_gas_volume - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.yesterdays_gas_volume) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS yesterdays_gas_volume_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.casing_pressure - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.casing_pressure) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS casing_pressure_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.differential_pressure - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.differential_pressure) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS differential_pressure_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.injection_pressure - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.injection_pressure) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS injection_pressure_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.yesterdays_runtime - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.yesterdays_runtime) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS yesterdays_runtime_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.flowline_pressure - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.flowline_pressure) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS flowline_pressure_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.well_test_oil - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.well_test_oil) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS well_test_oil_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.well_test_gross - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.well_test_gross) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS well_test_gross_var,
    (mv_dv_surv_dev_exc_analog_data_pivot.water_rate - COALESCE(lag(mv_dv_surv_dev_exc_analog_data_pivot.water_rate) OVER (PARTITION BY mv_dv_surv_dev_exc_analog_data_pivot.api_no14 ORDER BY mv_dv_surv_dev_exc_analog_data_pivot.analog_date), (0)::double precision)) AS water_rate_var
   FROM surv_dev.mv_dv_surv_dev_exc_analog_data_pivot;


ALTER TABLE surv_dev.dv_surv_dev_exc_analog_var OWNER TO postgres;

--
-- TOC entry 2118 (class 1259 OID 75576141)
-- Name: dv_surv_dev_exc_well_downtime; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_exc_well_downtime AS
 SELECT dv_dt_downtime_details.api_no14,
    (dv_dt_downtime_details.downtime_date - dv_dt_downtime_details.downtime_start_date) AS days_down,
    dv_dt_downtime_details.downtime_date,
    dv_dt_downtime_details.downtime_start_date,
    dv_dt_downtime_details.downtime_comments,
    dv_dt_downtime_details.lost_oil_vol,
    dv_dt_downtime_details.lost_gas_vol,
    dv_dt_downtime_details.lost_water_vol
   FROM bi.dv_dt_downtime_details;


ALTER TABLE surv_dev.dv_surv_dev_exc_well_downtime OWNER TO postgres;

--
-- TOC entry 2254 (class 1259 OID 81976418)
-- Name: dv_surv_dev_wd_org_units; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_wd_org_units AS
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


ALTER TABLE surv_dev.dv_surv_dev_wd_org_units OWNER TO postgres;

--
-- TOC entry 2260 (class 1259 OID 82009228)
-- Name: dv_surv_dev_wd_untransformed_well_locations; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_wd_untransformed_well_locations AS
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


ALTER TABLE surv_dev.dv_surv_dev_wd_untransformed_well_locations OWNER TO postgres;

--
-- TOC entry 2264 (class 1259 OID 82506512)
-- Name: mv_dv_surv_dev_wd_untransformed_well_locations; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations AS
 SELECT dv_surv_dev_wd_untransformed_well_locations.api_no14,
    dv_surv_dev_wd_untransformed_well_locations.top_bore_latitude,
    dv_surv_dev_wd_untransformed_well_locations.top_bore_longitude,
    dv_surv_dev_wd_untransformed_well_locations.btm_bore_latitude,
    dv_surv_dev_wd_untransformed_well_locations.btm_bore_longitude,
    dv_surv_dev_wd_untransformed_well_locations.geo_zone_id,
    dv_surv_dev_wd_untransformed_well_locations.geo_datum_id
   FROM surv_dev.dv_surv_dev_wd_untransformed_well_locations
  WITH NO DATA;


ALTER TABLE surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations OWNER TO postgres;

--
-- TOC entry 2265 (class 1259 OID 82515267)
-- Name: dv_surv_dev_wd_well_locations; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_wd_well_locations AS
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
   FROM surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations wc;


ALTER TABLE surv_dev.dv_surv_dev_wd_well_locations OWNER TO postgres;

--
-- TOC entry 2261 (class 1259 OID 82127368)
-- Name: dv_surv_dev_wd_well_dictionary; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.dv_surv_dev_wd_well_dictionary AS
 SELECT DISTINCT wc.api_no14,
    ou.op_area,
    ou.orglev4_name,
    wc.wellcomp_name AS well_name,
    wc.curr_comp_type AS currenttype,
        CASE
            WHEN (wc.curr_comp_status ~~ 'D & A'::text) THEN 'P & A'::text
            WHEN (wc.curr_comp_status ~~ 'SHUT-IN'::text) THEN 'INACTIVE'::text
            WHEN (wc.curr_comp_status ~~ 'DRY'::text) THEN 'P & A'::text
            ELSE wc.curr_comp_status
        END AS currentstatus,
    wc.status_eff_date,
    wc.reservoir_cd,
    wc.top_interval_tvd,
    wc.btm_interval_tvd,
    (wc.top_interval_tmd)::numeric AS topmd,
    (wc.btm_interval_tmd)::numeric AS bottommd,
    wc.type_interval,
    wc.well_spud_date,
    wc.completion_date,
    wc.first_prod_date,
    wc.curr_method_prod,
    wc.battery_name,
    xy.surface_latitude AS surf_latitude,
    xy.surface_longitude AS surf_longitude,
    xy.bh_latitude,
    xy.bh_longitude,
    wc.interest_type,
    wb.kickoff_date,
    w.section,
    w.township,
    (w.range_no)::numeric AS range_no,
    w.test_facility,
    cc.structure_code,
    cc.fault_block,
    cc.sector
   FROM (((((crc.mv_bi_wellcomp_v wc
     LEFT JOIN crc.mv_bi_wellbore wb ON (("substring"(wc.api_no14, 0, 12) = wb.api_no12)))
     LEFT JOIN crc.mv_bi_well w ON (("substring"(wc.api_no14, 0, 10) = w.api_no10)))
     LEFT JOIN surv_dev.dv_surv_dev_wd_well_locations xy ON (("substring"(wc.api_no14, 1, 12) = "substring"(xy.api_no14, 1, 12))))
     LEFT JOIN surv_dev.dv_surv_dev_wd_org_units ou ON ((wc.api_no14 = ou.api_no14)))
     LEFT JOIN crc_dss.u_dss_compmaster cc ON ((wc.api_no14 = cc.pid)))
  WHERE (ou.op_area <> 'EXPLORATION'::text);


ALTER TABLE surv_dev.dv_surv_dev_wd_well_dictionary OWNER TO postgres;

--
-- TOC entry 1935 (class 1259 OID 45323483)
-- Name: fv_surv_dev_allocated_volume_cums; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.fv_surv_dev_allocated_volume_cums AS
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
    sum(mv_bi_monthly_volumes.disp_water_inj) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14 ORDER BY mv_bi_monthly_volumes.prod_inj_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS disp_water_inj_cum,
    max(mv_bi_monthly_volumes.prod_inj_date) OVER (PARTITION BY mv_bi_monthly_volumes.api_no14) AS lastproddate
   FROM crc.mv_bi_monthly_volumes;


ALTER TABLE surv_dev.fv_surv_dev_allocated_volume_cums OWNER TO postgres;

--
-- TOC entry 2221 (class 1259 OID 77954295)
-- Name: fv_surv_dev_daily_injection; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.fv_surv_dev_daily_injection AS
 SELECT cc.api_no14,
    ii.test_date AS inj_date,
    ii.inj_fluid_type,
    ii.inj_rate,
    ii.inj_casing_press,
    ii.inj_tubing_press,
    ii.avg_inj_press,
    ii.pressure_setpoint
   FROM (( SELECT ods_oxy_injection_data.api_no14,
            ods_oxy_injection_data.daily_inj_date AS test_date,
            ods_oxy_injection_data.inj_fluid_type,
            ods_oxy_injection_data.inj_rate,
            ods_oxy_injection_data.inj_casing_press,
            ods_oxy_injection_data.inj_tubing_press,
            ods_oxy_injection_data.avg_inj_press,
            ods_oxy_injection_data.pressure_setpoint
           FROM ds_ekpspp.ods_oxy_injection_data
        UNION
         SELECT fv_ingres_daily_inj_la_basin.api_no14,
            fv_ingres_daily_inj_la_basin.daily_inj_date AS test_date,
            fv_ingres_daily_inj_la_basin.inj_fluid_type,
            fv_ingres_daily_inj_la_basin.inj_rate,
            fv_ingres_daily_inj_la_basin.inj_casing_press,
            fv_ingres_daily_inj_la_basin.inj_tubing_press,
            fv_ingres_daily_inj_la_basin.avg_inj_press,
            fv_ingres_daily_inj_la_basin.pressure_setpoint
           FROM ingres.mv_fv_daily_inj_ingres fv_ingres_daily_inj_la_basin) ii
     JOIN crc.mv_bi_wellcomp_v cc ON ((ii.api_no14 = cc.api_no14)));


ALTER TABLE surv_dev.fv_surv_dev_daily_injection OWNER TO postgres;

--
-- TOC entry 2021 (class 1259 OID 53476745)
-- Name: mv_dv_surv_dev_exc_allocated_volume_var; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_exc_allocated_volume_var AS
 SELECT dv_surv_dev_exc_allocated_volume_var.api_no14,
    dv_surv_dev_exc_allocated_volume_var.allocated_date,
    dv_surv_dev_exc_allocated_volume_var.cdoil_prod_var,
    dv_surv_dev_exc_allocated_volume_var.cdgas_prod_var,
    dv_surv_dev_exc_allocated_volume_var.cdwat_prod_var,
    dv_surv_dev_exc_allocated_volume_var.cdgross_liq_prod_var,
    dv_surv_dev_exc_allocated_volume_var.cdwat_inj_var,
    dv_surv_dev_exc_allocated_volume_var.cdgas_inj_var,
    dv_surv_dev_exc_allocated_volume_var.cdsteam_inj_var,
    dv_surv_dev_exc_allocated_volume_var.cdsteamc_inj_var
   FROM surv_dev.dv_surv_dev_exc_allocated_volume_var
  WITH NO DATA;


ALTER TABLE surv_dev.mv_dv_surv_dev_exc_allocated_volume_var OWNER TO postgres;

--
-- TOC entry 2187 (class 1259 OID 77046318)
-- Name: mv_dv_surv_dev_exc_analog_var; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_exc_analog_var AS
 SELECT dv_surv_dev_exc_analog_var.api_no14,
    dv_surv_dev_exc_analog_var.analog_date,
    dv_surv_dev_exc_analog_var.yesterdays_inferred_production_var,
    dv_surv_dev_exc_analog_var.yesterdays_gas_volume_var,
    dv_surv_dev_exc_analog_var.casing_pressure_var,
    dv_surv_dev_exc_analog_var.differential_pressure_var,
    dv_surv_dev_exc_analog_var.injection_pressure_var,
    dv_surv_dev_exc_analog_var.yesterdays_runtime_var,
    dv_surv_dev_exc_analog_var.flowline_pressure_var,
    dv_surv_dev_exc_analog_var.well_test_oil_var,
    dv_surv_dev_exc_analog_var.well_test_gross_var,
    dv_surv_dev_exc_analog_var.water_rate_var
   FROM surv_dev.dv_surv_dev_exc_analog_var
  WITH NO DATA;


ALTER TABLE surv_dev.mv_dv_surv_dev_exc_analog_var OWNER TO postgres;

--
-- TOC entry 2160 (class 1259 OID 76422580)
-- Name: fv_surv_dev_exceptions; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.fv_surv_dev_exceptions AS
 SELECT COALESCE(an.api_no14, al.api_no14) AS api_no14,
    COALESCE(an.analog_date, al.allocated_date) AS var_date,
    al.cdoil_prod_var,
    al.cdgas_prod_var,
    al.cdwat_prod_var,
    al.cdgross_liq_prod_var,
    al.cdwat_inj_var,
    al.cdgas_inj_var,
    al.cdsteam_inj_var,
    al.cdsteamc_inj_var,
    an.yesterdays_inferred_production_var,
    an.yesterdays_gas_volume_var,
    an.casing_pressure_var,
    an.differential_pressure_var,
    an.injection_pressure_var,
    an.yesterdays_runtime_var,
    an.flowline_pressure_var,
    an.well_test_oil_var,
    an.well_test_gross_var,
    an.water_rate_var
   FROM (surv_dev.mv_dv_surv_dev_exc_analog_var an
     FULL JOIN surv_dev.mv_dv_surv_dev_exc_allocated_volume_var al ON (((an.api_no14 = al.api_no14) AND (date_trunc('day'::text, an.analog_date) = date_trunc('day'::text, al.allocated_date)))));


ALTER TABLE surv_dev.fv_surv_dev_exceptions OWNER TO postgres;

--
-- TOC entry 1937 (class 1259 OID 45323498)
-- Name: fv_surv_dev_well_events; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.fv_surv_dev_well_events WITH (security_barrier='false') AS
 SELECT DISTINCT ww.api_no14,
    ee.date_ops_end AS event_date,
    'OpenWells Events'::text AS source,
    concat(COALESCE(upper(ee.event_type), ''::text), ' -- ', COALESCE(upper(ee.event_objective_1), ''::text), ' ', COALESCE(upper(ee.event_objective_2), ''::text)) AS comments
   FROM (bi.fv_wellcomp ww
     JOIN crc_edm.u_dm_event_t ee ON ((ww.well_id = ee.well_id)))
  WHERE ((ee.date_ops_end IS NOT NULL) AND (ee.event_type IS NOT NULL));


ALTER TABLE surv_dev.fv_surv_dev_well_events OWNER TO postgres;

--
-- TOC entry 1938 (class 1259 OID 45323503)
-- Name: fv_surv_dev_well_notes; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.fv_surv_dev_well_notes WITH (security_barrier='false') AS
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


ALTER TABLE surv_dev.fv_surv_dev_well_notes OWNER TO postgres;

--
-- TOC entry 1940 (class 1259 OID 45323524)
-- Name: fv_surv_dev_well_test; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.fv_surv_dev_well_test AS
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


ALTER TABLE surv_dev.fv_surv_dev_well_test OWNER TO postgres;

--
-- TOC entry 2266 (class 1259 OID 82662393)
-- Name: mv_dv_surv_dev_wd_well_dictionary; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_wd_well_dictionary AS
 SELECT dv_surv_dev_wd_well_dictionary.api_no14,
    dv_surv_dev_wd_well_dictionary.op_area,
    dv_surv_dev_wd_well_dictionary.orglev4_name,
    dv_surv_dev_wd_well_dictionary.well_name,
    dv_surv_dev_wd_well_dictionary.currenttype,
    dv_surv_dev_wd_well_dictionary.currentstatus,
    dv_surv_dev_wd_well_dictionary.status_eff_date,
    dv_surv_dev_wd_well_dictionary.reservoir_cd,
    dv_surv_dev_wd_well_dictionary.top_interval_tvd,
    dv_surv_dev_wd_well_dictionary.btm_interval_tvd,
    dv_surv_dev_wd_well_dictionary.topmd,
    dv_surv_dev_wd_well_dictionary.bottommd,
    dv_surv_dev_wd_well_dictionary.type_interval,
    dv_surv_dev_wd_well_dictionary.well_spud_date,
    dv_surv_dev_wd_well_dictionary.completion_date,
    dv_surv_dev_wd_well_dictionary.first_prod_date,
    dv_surv_dev_wd_well_dictionary.curr_method_prod,
    dv_surv_dev_wd_well_dictionary.battery_name,
    dv_surv_dev_wd_well_dictionary.surf_latitude,
    dv_surv_dev_wd_well_dictionary.surf_longitude,
    dv_surv_dev_wd_well_dictionary.bh_latitude,
    dv_surv_dev_wd_well_dictionary.bh_longitude,
    dv_surv_dev_wd_well_dictionary.interest_type,
    dv_surv_dev_wd_well_dictionary.kickoff_date,
    dv_surv_dev_wd_well_dictionary.section,
    dv_surv_dev_wd_well_dictionary.township,
    dv_surv_dev_wd_well_dictionary.range_no,
    dv_surv_dev_wd_well_dictionary.test_facility,
    dv_surv_dev_wd_well_dictionary.structure_code,
    dv_surv_dev_wd_well_dictionary.fault_block,
    dv_surv_dev_wd_well_dictionary.sector
   FROM surv_dev.dv_surv_dev_wd_well_dictionary
  WITH NO DATA;


ALTER TABLE surv_dev.mv_dv_surv_dev_wd_well_dictionary OWNER TO postgres;

--
-- TOC entry 2257 (class 1259 OID 81991014)
-- Name: mv_fv_surv_dev_allocated_volume_calcs; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_allocated_volume_calcs AS
 SELECT fv_surv_dev_allocated_volume_calcs.api_no14,
    fv_surv_dev_allocated_volume_calcs.allocated_date,
    fv_surv_dev_allocated_volume_calcs.days_prod,
    fv_surv_dev_allocated_volume_calcs.days_inject,
    fv_surv_dev_allocated_volume_calcs.oil_prod,
    fv_surv_dev_allocated_volume_calcs.gas_prod,
    fv_surv_dev_allocated_volume_calcs.cond_prod,
    fv_surv_dev_allocated_volume_calcs.water_prod,
    fv_surv_dev_allocated_volume_calcs.gross_liq_prod,
    fv_surv_dev_allocated_volume_calcs.water_inj,
    fv_surv_dev_allocated_volume_calcs.gas_inj,
    fv_surv_dev_allocated_volume_calcs.disp_water_inj,
    fv_surv_dev_allocated_volume_calcs.cyclic_steam_inj,
    fv_surv_dev_allocated_volume_calcs.steam_inj,
    fv_surv_dev_allocated_volume_calcs.hrs_prod,
    fv_surv_dev_allocated_volume_calcs.hrs_inject,
    fv_surv_dev_allocated_volume_calcs.cdoil_prod,
    fv_surv_dev_allocated_volume_calcs.cdgross_liq_prod,
    fv_surv_dev_allocated_volume_calcs.cdcond_prod,
    fv_surv_dev_allocated_volume_calcs.cdgas_prod,
    fv_surv_dev_allocated_volume_calcs.cdwater_prod,
    fv_surv_dev_allocated_volume_calcs.cdgas_inj,
    fv_surv_dev_allocated_volume_calcs.cdwater_inj,
    fv_surv_dev_allocated_volume_calcs.cdsteamc_inj,
    fv_surv_dev_allocated_volume_calcs.cdsteam_inj,
    fv_surv_dev_allocated_volume_calcs.cddispwat_inj,
    fv_surv_dev_allocated_volume_calcs.ogr_prod,
    fv_surv_dev_allocated_volume_calcs.ocut_prod,
    fv_surv_dev_allocated_volume_calcs.glr_prod,
    fv_surv_dev_allocated_volume_calcs.gor_prod,
    fv_surv_dev_allocated_volume_calcs.wor_prod,
    fv_surv_dev_allocated_volume_calcs.wgr_prod,
    fv_surv_dev_allocated_volume_calcs.water_cut_prod,
    fv_surv_dev_allocated_volume_calcs.month_norm,
    fv_surv_dev_allocated_volume_calcs.firstproddate,
    fv_surv_dev_allocated_volume_calcs.lastproddate
   FROM surv_dev.fv_surv_dev_allocated_volume_calcs
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_allocated_volume_calcs OWNER TO postgres;

--
-- TOC entry 2258 (class 1259 OID 81991527)
-- Name: mv_fv_surv_dev_allocated_volume_cums; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_allocated_volume_cums AS
 SELECT fv_surv_dev_allocated_volume_cums.api_no14,
    fv_surv_dev_allocated_volume_cums.allocated_date,
    fv_surv_dev_allocated_volume_cums.oil_cum,
    fv_surv_dev_allocated_volume_cums.gas_cum,
    fv_surv_dev_allocated_volume_cums.gross_cum,
    fv_surv_dev_allocated_volume_cums.water_cum,
    fv_surv_dev_allocated_volume_cums.water_inj_cum,
    fv_surv_dev_allocated_volume_cums.gas_inj_cum,
    fv_surv_dev_allocated_volume_cums.steam_inj_cum,
    fv_surv_dev_allocated_volume_cums.steamc_inj_cum,
    fv_surv_dev_allocated_volume_cums.disp_water_inj_cum,
    fv_surv_dev_allocated_volume_cums.lastproddate
   FROM surv_dev.fv_surv_dev_allocated_volume_cums
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_allocated_volume_cums OWNER TO postgres;

--
-- TOC entry 2022 (class 1259 OID 53476768)
-- Name: mv_fv_surv_dev_well_test; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_well_test AS
 SELECT fv_surv_dev_well_test.api_no14,
    fv_surv_dev_well_test.test_date,
    fv_surv_dev_well_test.last_test_date,
    fv_surv_dev_well_test.test_type,
    fv_surv_dev_well_test.oil_rate,
    fv_surv_dev_well_test.gas_rate,
    fv_surv_dev_well_test.water_rate,
    fv_surv_dev_well_test.gas_lift_rate,
    fv_surv_dev_well_test.gas_oil_ratio,
    fv_surv_dev_well_test.tubing_press,
    fv_surv_dev_well_test.casing_press,
    fv_surv_dev_well_test.line_press,
    fv_surv_dev_well_test.allocatable,
    fv_surv_dev_well_test.oil_gravity,
    fv_surv_dev_well_test.choke_size,
    fv_surv_dev_well_test.pump_eff,
    fv_surv_dev_well_test.water_cut,
    fv_surv_dev_well_test.stroke_length,
    fv_surv_dev_well_test.strokes_minute,
    fv_surv_dev_well_test.pump_bore_size,
    fv_surv_dev_well_test.prod_hours,
    fv_surv_dev_well_test.test_hours,
    fv_surv_dev_well_test.hertz,
    fv_surv_dev_well_test.amps,
    fv_surv_dev_well_test.fluid_level,
    fv_surv_dev_well_test.pump_intake_press,
    fv_surv_dev_well_test.wellhead_temp,
    fv_surv_dev_well_test.salinity,
    fv_surv_dev_well_test.bsw
   FROM surv_dev.fv_surv_dev_well_test
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_well_test OWNER TO postgres;

--
-- TOC entry 2262 (class 1259 OID 82271648)
-- Name: fv_surv_dev_well_summary; Type: VIEW; Schema: surv_dev; Owner: postgres
--

CREATE VIEW surv_dev.fv_surv_dev_well_summary AS
 WITH allocated_prod_summary AS (
         SELECT av.api_no14,
            av.lastproddate,
            av.firstproddate,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cdoil_prod)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_oil,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cdwater_prod)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_water,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cdgas_prod)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_gas,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cdgross_liq_prod)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_gross,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cdwater_inj)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_water_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cdgas_inj)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_gas_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cdsteam_inj)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_steam_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cdsteamc_inj)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_cyc_steam_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN (av.cddispwat_inj)::double precision
                    ELSE (NULL::numeric)::double precision
                END AS last_allocated_wat_disp_inj,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.gor_prod
                    ELSE (NULL::numeric)::real
                END AS last_allocated_gor,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.wor_prod
                    ELSE (NULL::numeric)::real
                END AS last_allocated_wor,
                CASE
                    WHEN (av.allocated_date = av.lastproddate) THEN av.water_cut_prod
                    ELSE (NULL::numeric)::real
                END AS last_allocated_water_cut
           FROM surv_dev.mv_fv_surv_dev_allocated_volume_calcs av
          WHERE (av.allocated_date = av.lastproddate)
        ), test_summary AS (
         SELECT wt.api_no14,
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
           FROM surv_dev.mv_fv_surv_dev_well_test wt
          WHERE (wt.test_date = wt.last_test_date)
        ), cum_summary AS (
         SELECT av.api_no14,
            av.lastproddate,
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
           FROM surv_dev.mv_fv_surv_dev_allocated_volume_cums av
          WHERE (av.allocated_date = av.lastproddate)
        )
 SELECT DISTINCT vv.api_no14,
    vv.orglev4_name,
    vv.op_area,
    vv.well_name,
    vv.currenttype,
    vv.currentstatus,
    vv.status_eff_date,
    vv.reservoir_cd,
    vv.top_interval_tvd,
    vv.btm_interval_tvd,
    vv.topmd,
    vv.bottommd,
    vv.completion_date,
    vv.curr_method_prod,
    vv.battery_name,
    vv.surf_latitude,
    vv.surf_longitude,
    vv.bh_latitude,
    vv.bh_longitude,
    vv.interest_type,
    vv.kickoff_date,
    vv.section,
    vv.township,
    vv.range_no,
    vv.test_facility,
    vv.structure_code,
    vv.fault_block,
    vv.sector,
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
    (aps.last_allocated_gor)::numeric AS last_allocated_gor,
    (aps.last_allocated_wor)::numeric AS last_allocated_wor,
    (aps.last_allocated_water_cut)::numeric AS last_allocated_water_cut,
    cs.cum_allocated_oil,
    cs.cum_allocated_water,
    cs.cum_allocated_gas,
    cs.cum_allocated_gross,
    cs.cum_allocated_water_inj,
    cs.cum_allocated_gas_inj,
    cs.cum_allocated_steam_inj,
    cs.cum_allocated_cyc_steam_inj,
    cs.cum_allocated_wat_disp_inj,
    ts.last_tubing_press,
    ts.last_casing_press,
    ts.last_pump_eff,
    ts.last_pump_intake_press,
    ts.last_stroke_length,
    ts.last_strokes_minute,
    ts.last_fluid_level,
    ts.last_test_water_cut,
    aps.firstproddate AS first_prod_date
   FROM (((surv_dev.mv_dv_surv_dev_wd_well_dictionary vv
     LEFT JOIN allocated_prod_summary aps ON ((vv.api_no14 = aps.api_no14)))
     LEFT JOIN test_summary ts ON ((vv.api_no14 = ts.api_no14)))
     LEFT JOIN cum_summary cs ON ((vv.api_no14 = cs.api_no14)));


ALTER TABLE surv_dev.fv_surv_dev_well_summary OWNER TO postgres;

--
-- TOC entry 2019 (class 1259 OID 53476528)
-- Name: mv_fv_surv_dev_av_allocated_cross; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_av_allocated_cross AS
 SELECT dv_surv_dev_av_allocated_cross.api_no14,
    dv_surv_dev_av_allocated_cross.full_date
   FROM surv_dev.dv_surv_dev_av_allocated_cross
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_av_allocated_cross OWNER TO postgres;

--
-- TOC entry 2259 (class 1259 OID 81991960)
-- Name: mv_fv_surv_dev_daily_injection; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_daily_injection AS
 SELECT fv_surv_dev_daily_injection.api_no14,
    fv_surv_dev_daily_injection.inj_date,
    fv_surv_dev_daily_injection.inj_fluid_type,
    fv_surv_dev_daily_injection.inj_rate,
    fv_surv_dev_daily_injection.inj_casing_press,
    fv_surv_dev_daily_injection.inj_tubing_press,
    fv_surv_dev_daily_injection.avg_inj_press,
    fv_surv_dev_daily_injection.pressure_setpoint
   FROM surv_dev.fv_surv_dev_daily_injection
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_daily_injection OWNER TO postgres;

--
-- TOC entry 2188 (class 1259 OID 77046429)
-- Name: mv_fv_surv_dev_exceptions; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_exceptions AS
 SELECT fv_surv_dev_exceptions.api_no14,
    fv_surv_dev_exceptions.var_date,
    fv_surv_dev_exceptions.cdoil_prod_var,
    fv_surv_dev_exceptions.cdgas_prod_var,
    fv_surv_dev_exceptions.cdwat_prod_var,
    fv_surv_dev_exceptions.cdgross_liq_prod_var,
    fv_surv_dev_exceptions.cdwat_inj_var,
    fv_surv_dev_exceptions.cdgas_inj_var,
    fv_surv_dev_exceptions.cdsteam_inj_var,
    fv_surv_dev_exceptions.cdsteamc_inj_var,
    fv_surv_dev_exceptions.yesterdays_inferred_production_var,
    fv_surv_dev_exceptions.yesterdays_gas_volume_var,
    fv_surv_dev_exceptions.casing_pressure_var,
    fv_surv_dev_exceptions.differential_pressure_var,
    fv_surv_dev_exceptions.injection_pressure_var,
    fv_surv_dev_exceptions.yesterdays_runtime_var,
    fv_surv_dev_exceptions.flowline_pressure_var,
    fv_surv_dev_exceptions.well_test_oil_var,
    fv_surv_dev_exceptions.well_test_gross_var,
    fv_surv_dev_exceptions.water_rate_var
   FROM surv_dev.fv_surv_dev_exceptions
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_exceptions OWNER TO postgres;

--
-- TOC entry 2024 (class 1259 OID 53476800)
-- Name: mv_fv_surv_dev_well_events; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_well_events AS
 SELECT fv_surv_dev_well_events.api_no14,
    fv_surv_dev_well_events.event_date,
    fv_surv_dev_well_events.source,
    fv_surv_dev_well_events.comments
   FROM surv_dev.fv_surv_dev_well_events
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_well_events OWNER TO postgres;

--
-- TOC entry 2023 (class 1259 OID 53476790)
-- Name: mv_fv_surv_dev_well_notes; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_well_notes AS
 SELECT fv_surv_dev_well_notes.api_no14,
    fv_surv_dev_well_notes.comment_date,
    fv_surv_dev_well_notes.comment_by,
    fv_surv_dev_well_notes.source,
    fv_surv_dev_well_notes.comments,
    fv_surv_dev_well_notes.mindate,
    fv_surv_dev_well_notes.maxdate
   FROM surv_dev.fv_surv_dev_well_notes
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_well_notes OWNER TO postgres;

--
-- TOC entry 2263 (class 1259 OID 82339406)
-- Name: mv_fv_surv_dev_well_summary; Type: MATERIALIZED VIEW; Schema: surv_dev; Owner: postgres
--

CREATE MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_well_summary AS
 SELECT fv_surv_dev_well_summary.api_no14,
    fv_surv_dev_well_summary.orglev4_name,
    fv_surv_dev_well_summary.op_area,
    fv_surv_dev_well_summary.well_name,
    fv_surv_dev_well_summary.currenttype,
    fv_surv_dev_well_summary.currentstatus,
    fv_surv_dev_well_summary.status_eff_date,
    fv_surv_dev_well_summary.reservoir_cd,
    fv_surv_dev_well_summary.top_interval_tvd,
    fv_surv_dev_well_summary.btm_interval_tvd,
    fv_surv_dev_well_summary.topmd,
    fv_surv_dev_well_summary.bottommd,
    fv_surv_dev_well_summary.completion_date,
    fv_surv_dev_well_summary.curr_method_prod,
    fv_surv_dev_well_summary.battery_name,
    fv_surv_dev_well_summary.surf_latitude,
    fv_surv_dev_well_summary.surf_longitude,
    fv_surv_dev_well_summary.bh_latitude,
    fv_surv_dev_well_summary.bh_longitude,
    fv_surv_dev_well_summary.interest_type,
    fv_surv_dev_well_summary.kickoff_date,
    fv_surv_dev_well_summary.section,
    fv_surv_dev_well_summary.township,
    fv_surv_dev_well_summary.range_no,
    fv_surv_dev_well_summary.test_facility,
    fv_surv_dev_well_summary.structure_code,
    fv_surv_dev_well_summary.fault_block,
    fv_surv_dev_well_summary.sector,
    fv_surv_dev_well_summary.last_prod_date,
    fv_surv_dev_well_summary.last_test_date,
    fv_surv_dev_well_summary.last_allocated_oil,
    fv_surv_dev_well_summary.last_allocated_water,
    fv_surv_dev_well_summary.last_allocated_gas,
    fv_surv_dev_well_summary.last_allocated_gross,
    fv_surv_dev_well_summary.last_allocated_water_inj,
    fv_surv_dev_well_summary.last_allocated_gas_inj,
    fv_surv_dev_well_summary.last_allocated_steam_inj,
    fv_surv_dev_well_summary.last_allocated_cyc_steam_inj,
    fv_surv_dev_well_summary.last_allocated_wat_disp_inj,
    fv_surv_dev_well_summary.last_allocated_gor,
    fv_surv_dev_well_summary.last_allocated_wor,
    fv_surv_dev_well_summary.last_allocated_water_cut,
    fv_surv_dev_well_summary.cum_allocated_oil,
    fv_surv_dev_well_summary.cum_allocated_water,
    fv_surv_dev_well_summary.cum_allocated_gas,
    fv_surv_dev_well_summary.cum_allocated_gross,
    fv_surv_dev_well_summary.cum_allocated_water_inj,
    fv_surv_dev_well_summary.cum_allocated_gas_inj,
    fv_surv_dev_well_summary.cum_allocated_steam_inj,
    fv_surv_dev_well_summary.cum_allocated_cyc_steam_inj,
    fv_surv_dev_well_summary.cum_allocated_wat_disp_inj,
    fv_surv_dev_well_summary.last_tubing_press,
    fv_surv_dev_well_summary.last_casing_press,
    fv_surv_dev_well_summary.last_pump_eff,
    fv_surv_dev_well_summary.last_pump_intake_press,
    fv_surv_dev_well_summary.last_stroke_length,
    fv_surv_dev_well_summary.last_strokes_minute,
    fv_surv_dev_well_summary.last_fluid_level,
    fv_surv_dev_well_summary.last_test_water_cut,
    fv_surv_dev_well_summary.first_prod_date
   FROM surv_dev.fv_surv_dev_well_summary
  WITH NO DATA;


ALTER TABLE surv_dev.mv_fv_surv_dev_well_summary OWNER TO postgres;

--
-- TOC entry 13693 (class 0 OID 0)
-- Dependencies: 528
-- Name: SCHEMA surv_dev; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA surv_dev TO data_quality;
GRANT ALL ON SCHEMA surv_dev TO data_analytics;
GRANT USAGE ON SCHEMA surv_dev TO read_only;
GRANT USAGE ON SCHEMA surv_dev TO data_science;
GRANT USAGE ON SCHEMA surv_dev TO web_anon;


--
-- TOC entry 13694 (class 0 OID 0)
-- Dependencies: 2018
-- Name: TABLE dv_surv_dev_av_allocated_cross; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_av_allocated_cross TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_av_allocated_cross TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_av_allocated_cross TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_av_allocated_cross TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_av_allocated_cross TO web_anon;


--
-- TOC entry 13695 (class 0 OID 0)
-- Dependencies: 1934
-- Name: TABLE fv_surv_dev_allocated_volume_calcs; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.fv_surv_dev_allocated_volume_calcs TO data_quality;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_allocated_volume_calcs TO data_analytics;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_allocated_volume_calcs TO read_only;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_allocated_volume_calcs TO data_science;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_allocated_volume_calcs TO web_anon;


--
-- TOC entry 13696 (class 0 OID 0)
-- Dependencies: 1936
-- Name: TABLE dv_surv_dev_exc_allocated_volume_var; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_exc_allocated_volume_var TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_allocated_volume_var TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_allocated_volume_var TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_allocated_volume_var TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_allocated_volume_var TO web_anon;


--
-- TOC entry 13697 (class 0 OID 0)
-- Dependencies: 2143
-- Name: TABLE dv_surv_dev_exc_analog_data; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_exc_analog_data TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_analog_data TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_analog_data TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_analog_data TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_analog_data TO web_anon;


--
-- TOC entry 13698 (class 0 OID 0)
-- Dependencies: 2311
-- Name: TABLE dv_surv_dev_exc_analog_data_2; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_exc_analog_data_2 TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_analog_data_2 TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_analog_data_2 TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_analog_data_2 TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_analog_data_2 TO web_anon;


--
-- TOC entry 13699 (class 0 OID 0)
-- Dependencies: 2144
-- Name: TABLE mv_dv_surv_dev_exc_analog_data; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data TO data_science;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data TO web_anon;


--
-- TOC entry 13700 (class 0 OID 0)
-- Dependencies: 2151
-- Name: TABLE dv_surv_dev_exc_analog_data_pivot; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_exc_analog_data_pivot TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_analog_data_pivot TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_analog_data_pivot TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_analog_data_pivot TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_analog_data_pivot TO web_anon;


--
-- TOC entry 13701 (class 0 OID 0)
-- Dependencies: 2186
-- Name: TABLE mv_dv_surv_dev_exc_analog_data_pivot; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data_pivot TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data_pivot TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data_pivot TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data_pivot TO data_science;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_data_pivot TO web_anon;


--
-- TOC entry 13702 (class 0 OID 0)
-- Dependencies: 2155
-- Name: TABLE dv_surv_dev_exc_analog_var; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_exc_analog_var TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_analog_var TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_analog_var TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_analog_var TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_analog_var TO web_anon;


--
-- TOC entry 13703 (class 0 OID 0)
-- Dependencies: 2118
-- Name: TABLE dv_surv_dev_exc_well_downtime; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_exc_well_downtime TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_well_downtime TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_well_downtime TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_exc_well_downtime TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_exc_well_downtime TO web_anon;


--
-- TOC entry 13704 (class 0 OID 0)
-- Dependencies: 2254
-- Name: TABLE dv_surv_dev_wd_org_units; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_wd_org_units TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_wd_org_units TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_wd_org_units TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_wd_org_units TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_wd_org_units TO web_anon;


--
-- TOC entry 13705 (class 0 OID 0)
-- Dependencies: 2260
-- Name: TABLE dv_surv_dev_wd_untransformed_well_locations; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_wd_untransformed_well_locations TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_wd_untransformed_well_locations TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_wd_untransformed_well_locations TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_wd_untransformed_well_locations TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_wd_untransformed_well_locations TO web_anon;


--
-- TOC entry 13706 (class 0 OID 0)
-- Dependencies: 2264
-- Name: TABLE mv_dv_surv_dev_wd_untransformed_well_locations; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations TO data_science;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations TO web_anon;


--
-- TOC entry 13707 (class 0 OID 0)
-- Dependencies: 2265
-- Name: TABLE dv_surv_dev_wd_well_locations; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_wd_well_locations TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_wd_well_locations TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_wd_well_locations TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_wd_well_locations TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_wd_well_locations TO web_anon;


--
-- TOC entry 13708 (class 0 OID 0)
-- Dependencies: 2261
-- Name: TABLE dv_surv_dev_wd_well_dictionary; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.dv_surv_dev_wd_well_dictionary TO data_quality;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_wd_well_dictionary TO data_analytics;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_wd_well_dictionary TO read_only;
GRANT SELECT ON TABLE surv_dev.dv_surv_dev_wd_well_dictionary TO data_science;
GRANT ALL ON TABLE surv_dev.dv_surv_dev_wd_well_dictionary TO web_anon;


--
-- TOC entry 13709 (class 0 OID 0)
-- Dependencies: 1935
-- Name: TABLE fv_surv_dev_allocated_volume_cums; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.fv_surv_dev_allocated_volume_cums TO data_quality;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_allocated_volume_cums TO data_analytics;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_allocated_volume_cums TO read_only;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_allocated_volume_cums TO data_science;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_allocated_volume_cums TO web_anon;


--
-- TOC entry 13710 (class 0 OID 0)
-- Dependencies: 2221
-- Name: TABLE fv_surv_dev_daily_injection; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.fv_surv_dev_daily_injection TO data_quality;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_daily_injection TO data_analytics;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_daily_injection TO read_only;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_daily_injection TO data_science;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_daily_injection TO web_anon;


--
-- TOC entry 13711 (class 0 OID 0)
-- Dependencies: 2021
-- Name: TABLE mv_dv_surv_dev_exc_allocated_volume_var; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_dv_surv_dev_exc_allocated_volume_var TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_exc_allocated_volume_var TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_exc_allocated_volume_var TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_exc_allocated_volume_var TO data_science;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_exc_allocated_volume_var TO web_anon;


--
-- TOC entry 13712 (class 0 OID 0)
-- Dependencies: 2187
-- Name: TABLE mv_dv_surv_dev_exc_analog_var; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_var TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_var TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_var TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_var TO data_science;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_exc_analog_var TO web_anon;


--
-- TOC entry 13713 (class 0 OID 0)
-- Dependencies: 2160
-- Name: TABLE fv_surv_dev_exceptions; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.fv_surv_dev_exceptions TO data_quality;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_exceptions TO data_analytics;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_exceptions TO read_only;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_exceptions TO data_science;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_exceptions TO web_anon;


--
-- TOC entry 13714 (class 0 OID 0)
-- Dependencies: 1937
-- Name: TABLE fv_surv_dev_well_events; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.fv_surv_dev_well_events TO data_quality;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_well_events TO data_analytics;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_well_events TO read_only;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_well_events TO data_science;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_well_events TO web_anon;


--
-- TOC entry 13715 (class 0 OID 0)
-- Dependencies: 1938
-- Name: TABLE fv_surv_dev_well_notes; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.fv_surv_dev_well_notes TO data_quality;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_well_notes TO data_analytics;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_well_notes TO read_only;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_well_notes TO data_science;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_well_notes TO web_anon;


--
-- TOC entry 13716 (class 0 OID 0)
-- Dependencies: 1940
-- Name: TABLE fv_surv_dev_well_test; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.fv_surv_dev_well_test TO data_quality;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_well_test TO data_analytics;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_well_test TO read_only;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_well_test TO data_science;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_well_test TO web_anon;


--
-- TOC entry 13717 (class 0 OID 0)
-- Dependencies: 2266
-- Name: TABLE mv_dv_surv_dev_wd_well_dictionary; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_dv_surv_dev_wd_well_dictionary TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_wd_well_dictionary TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_wd_well_dictionary TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_dv_surv_dev_wd_well_dictionary TO data_science;
GRANT ALL ON TABLE surv_dev.mv_dv_surv_dev_wd_well_dictionary TO web_anon;


--
-- TOC entry 13718 (class 0 OID 0)
-- Dependencies: 2257
-- Name: TABLE mv_fv_surv_dev_allocated_volume_calcs; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_calcs TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_calcs TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_calcs TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_calcs TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_calcs TO web_anon;


--
-- TOC entry 13719 (class 0 OID 0)
-- Dependencies: 2258
-- Name: TABLE mv_fv_surv_dev_allocated_volume_cums; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_cums TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_cums TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_cums TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_cums TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_allocated_volume_cums TO web_anon;


--
-- TOC entry 13720 (class 0 OID 0)
-- Dependencies: 2022
-- Name: TABLE mv_fv_surv_dev_well_test; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_well_test TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_well_test TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_well_test TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_well_test TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_well_test TO web_anon;


--
-- TOC entry 13721 (class 0 OID 0)
-- Dependencies: 2262
-- Name: TABLE fv_surv_dev_well_summary; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.fv_surv_dev_well_summary TO data_quality;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_well_summary TO data_analytics;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_well_summary TO read_only;
GRANT SELECT ON TABLE surv_dev.fv_surv_dev_well_summary TO data_science;
GRANT ALL ON TABLE surv_dev.fv_surv_dev_well_summary TO web_anon;


--
-- TOC entry 13722 (class 0 OID 0)
-- Dependencies: 2019
-- Name: TABLE mv_fv_surv_dev_av_allocated_cross; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_av_allocated_cross TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_av_allocated_cross TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_av_allocated_cross TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_av_allocated_cross TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_av_allocated_cross TO web_anon;


--
-- TOC entry 13723 (class 0 OID 0)
-- Dependencies: 2259
-- Name: TABLE mv_fv_surv_dev_daily_injection; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_daily_injection TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_daily_injection TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_daily_injection TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_daily_injection TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_daily_injection TO web_anon;


--
-- TOC entry 13724 (class 0 OID 0)
-- Dependencies: 2188
-- Name: TABLE mv_fv_surv_dev_exceptions; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_exceptions TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_exceptions TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_exceptions TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_exceptions TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_exceptions TO web_anon;


--
-- TOC entry 13725 (class 0 OID 0)
-- Dependencies: 2024
-- Name: TABLE mv_fv_surv_dev_well_events; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_well_events TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_well_events TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_well_events TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_well_events TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_well_events TO web_anon;


--
-- TOC entry 13726 (class 0 OID 0)
-- Dependencies: 2023
-- Name: TABLE mv_fv_surv_dev_well_notes; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_well_notes TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_well_notes TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_well_notes TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_well_notes TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_well_notes TO web_anon;


--
-- TOC entry 13727 (class 0 OID 0)
-- Dependencies: 2263
-- Name: TABLE mv_fv_surv_dev_well_summary; Type: ACL; Schema: surv_dev; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE surv_dev.mv_fv_surv_dev_well_summary TO data_quality;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_well_summary TO data_analytics;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_well_summary TO read_only;
GRANT SELECT ON TABLE surv_dev.mv_fv_surv_dev_well_summary TO data_science;
GRANT ALL ON TABLE surv_dev.mv_fv_surv_dev_well_summary TO web_anon;


--
-- TOC entry 10821 (class 826 OID 56268924)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: surv_dev; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv_dev REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv_dev GRANT USAGE ON SEQUENCES  TO data_quality;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv_dev GRANT USAGE ON SEQUENCES  TO data_analytics;


--
-- TOC entry 10820 (class 826 OID 56268923)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: surv_dev; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv_dev REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv_dev GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO data_quality;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv_dev GRANT ALL ON TABLES  TO data_analytics;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv_dev GRANT SELECT ON TABLES  TO read_only;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA surv_dev GRANT SELECT ON TABLES  TO data_science;


--
-- TOC entry 13674 (class 0 OID 53476745)
-- Dependencies: 2021 13689
-- Name: mv_dv_surv_dev_exc_allocated_volume_var; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_exc_allocated_volume_var;


--
-- TOC entry 13678 (class 0 OID 75839108)
-- Dependencies: 2144 13689
-- Name: mv_dv_surv_dev_exc_analog_data; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_exc_analog_data;


--
-- TOC entry 13679 (class 0 OID 77044455)
-- Dependencies: 2186 13678 13689
-- Name: mv_dv_surv_dev_exc_analog_data_pivot; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_exc_analog_data_pivot;


--
-- TOC entry 13680 (class 0 OID 77046318)
-- Dependencies: 2187 13679 13678 13689
-- Name: mv_dv_surv_dev_exc_analog_var; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_exc_analog_var;


--
-- TOC entry 13686 (class 0 OID 82506512)
-- Dependencies: 2264 13689
-- Name: mv_dv_surv_dev_wd_untransformed_well_locations; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_wd_untransformed_well_locations;


--
-- TOC entry 13687 (class 0 OID 82662393)
-- Dependencies: 2266 13686 13689
-- Name: mv_dv_surv_dev_wd_well_dictionary; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_dv_surv_dev_wd_well_dictionary;


--
-- TOC entry 13682 (class 0 OID 81991014)
-- Dependencies: 2257 13689
-- Name: mv_fv_surv_dev_allocated_volume_calcs; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_allocated_volume_calcs;


--
-- TOC entry 13683 (class 0 OID 81991527)
-- Dependencies: 2258 13689
-- Name: mv_fv_surv_dev_allocated_volume_cums; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_allocated_volume_cums;


--
-- TOC entry 13673 (class 0 OID 53476528)
-- Dependencies: 2019 13689
-- Name: mv_fv_surv_dev_av_allocated_cross; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_av_allocated_cross;


--
-- TOC entry 13684 (class 0 OID 81991960)
-- Dependencies: 2259 13689
-- Name: mv_fv_surv_dev_daily_injection; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_daily_injection;


--
-- TOC entry 13681 (class 0 OID 77046429)
-- Dependencies: 2188 13674 13680 13679 13678 13689
-- Name: mv_fv_surv_dev_exceptions; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_exceptions;


--
-- TOC entry 13677 (class 0 OID 53476800)
-- Dependencies: 2024 13689
-- Name: mv_fv_surv_dev_well_events; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_well_events;


--
-- TOC entry 13676 (class 0 OID 53476790)
-- Dependencies: 2023 13689
-- Name: mv_fv_surv_dev_well_notes; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_well_notes;


--
-- TOC entry 13675 (class 0 OID 53476768)
-- Dependencies: 2022 13689
-- Name: mv_fv_surv_dev_well_test; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_well_test;


--
-- TOC entry 13685 (class 0 OID 82339406)
-- Dependencies: 2263 13675 13682 13683 13687 13686 13689
-- Name: mv_fv_surv_dev_well_summary; Type: MATERIALIZED VIEW DATA; Schema: surv_dev; Owner: postgres
--

REFRESH MATERIALIZED VIEW surv_dev.mv_fv_surv_dev_well_summary;


-- Completed on 2020-01-14 08:32:28

--
-- PostgreSQL database dump complete
--

