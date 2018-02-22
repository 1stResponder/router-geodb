-- SCHEMA: freshwarehouse

-- DROP SCHEMA freshwarehouse ;

GRANT ALL ON DATABASE "fresharchive" TO freshadmin;

GRANT CONNECT ON DATABASE "fresharchive" TO freshdbuser;

CREATE SCHEMA freshwarehouse
    AUTHORIZATION freshadmin;

GRANT ALL ON SCHEMA freshwarehouse TO freshadmin;
GRANT USAGE ON SCHEMA freshwarehouse TO freshdbuser;

CREATE SEQUENCE freshwarehouse."MessageArchive_id_seq"
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE freshwarehouse."MessageArchive_id_seq"
    OWNER TO freshadmin;

GRANT ALL ON SEQUENCE freshwarehouse."MessageArchive_id_seq" TO freshadmin;

GRANT ALL ON SEQUENCE freshwarehouse."MessageArchive_id_seq" TO freshdbuser;

-- Table: freshwarehouse.messagearch

-- DROP TABLE freshwarehouse.messagearch;

CREATE TABLE freshwarehouse.messagearch
(
    id integer NOT NULL DEFAULT nextval('freshwarehouse."MessageArchive_id_seq"'::regclass),
    dehash integer NOT NULL,
    distributionid text COLLATE pg_catalog."default" NOT NULL,
    senderid text COLLATE pg_catalog."default" NOT NULL,
    datetimesent timestamp with time zone NOT NULL,
    senderip text COLLATE pg_catalog."default",
    datetimelogged timestamp with time zone,
    message xml,
    CONSTRAINT "MessageArchive_pkey" PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE freshwarehouse.messagearch
    OWNER to freshadmin;

GRANT ALL ON ALL TABLES IN SCHEMA freshwarehouse TO "freshdbuser";
GRANT ALL ON ALL SEQUENCES IN SCHEMA freshwarehouse TO "freshdbuser";