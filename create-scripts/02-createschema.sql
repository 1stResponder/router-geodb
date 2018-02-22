DROP ROLE IF EXISTS "freshdbuser";
CREATE ROLE "freshdbuser" LOGIN PASSWORD 'mypass';
GRANT ALL PRIVILEGES on DATABASE "freshgeo" to "freshdbuser";

ALTER DATABASE "freshgeo"
  SET search_path = "$user", public, topology;

CREATE EXTENSION postgis;
CREATE SCHEMA "em_data";

CREATE TABLE "em_data"."edxlcache"
(
  "dehash" integer NOT NULL,
  "distributionid" text NOT NULL,
  "senderid" text NOT NULL,
  "datetimesent" timestamp with time zone NOT NULL,
  "edxlde" xml NOT NULL,
  "delete" boolean NOT NULL DEFAULT false,
  CONSTRAINT "dehashPkey" PRIMARY key ("dehash")
)
WITH (
  OIDS=FALSE
);

  CREATE TABLE "em_data"."contentcache"
(
  "contenthash" integer NOT NULL,
  "dehash" integer NOT NULL,
  "expirestime" timestamp with time zone NOT NULL,
  "contentobject" xml NOT NULL,
  "feedhashes" integer[],
  CONSTRAINT "contenthashPkey" PRIMARY key ("contenthash"),
  CONSTRAINT "contentcache__dehash_Fkey" FOREIGN key ("dehash")
      REFERENCES "em_data"."edxlcache" ("dehash")
)
WITH (
  OIDS=FALSE
);

CREATE TABLE "em_data"."feedcontent"
(
  "contenthash" integer NOT NULL,
  "expirestime" timestamp with time zone NOT NULL,
  "feedgeo" geometry(Point,4326),
  "description" text,
  "friendlyname" text,
  "title" text,
  "iconurl" text,
  "imageurl" text,
  "dehash" integer NOT NULL,
  CONSTRAINT "feedcontent__contenthash_Fkey" FOREIGN key ("contenthash")
      REFERENCES "em_data"."contentcache" ("contenthash"),
  CONSTRAINT "feedcontent__dehash_Fkey" FOREIGN key ("dehash")
      REFERENCES "em_data"."edxlcache" ("dehash")
)
WITH (
  OIDS=FALSE
);
  
CREATE TABLE "em_data"."feeds"
(
  "feedhash" integer NOT NULL,
  "contenthashes" integer[] NOT NULL,
  "sourceid" text NOT NULL,
  "sourcevalue" text NOT NULL,
  "viewname" text,  
  CONSTRAINT "feedsPkey" PRIMARY key ("feedhash")
)
WITH (
  OIDS=FALSE
);
  
CREATE TABLE "em_data"."rules"
(
  "deelement" text NOT NULL,
  "rulehash" integer NOT NULL,
  "ruleid" text NOT NULL,
  "rulevalue" text NOT NULL,
  "feedhashes" integer[],
  "federationuri" text[],
  CONSTRAINT "rulePkey" PRIMARY key ("rulehash")
)
WITH (
  OIDS=FALSE
);

CREATE TABLE "em_data"."sourcevalues"
(
  "sourcehash" integer NOT NULL,
  "id" text NOT NULL,
  "value" text NOT NULL,
  "feedhash" integer NOT NULL,
  CONSTRAINT "valueListPkey" PRIMARY key ("feedhash")
)
WITH (
  OIDS=FALSE
);

CREATE INDEX Feed_Geom_IDX
  ON "em_data"."feedcontent"
  USING gist
  ("feedgeo");
  
CREATE OR REPLACE VIEW em_data.test_view AS
 SELECT fc.contenthash,
    fc.feedgeo,
    fc.expirestime,
    fc.description,
    fc.friendlyname,
    fc.title,
    fc.iconurl,
    fc.imageurl,
	fc.dehash,
	ec.datetimesent
   FROM em_data.feedcontent fc
     JOIN em_data.contentcache cc ON fc.contenthash = cc.contenthash
     JOIN em_data.edxlcache ec ON cc.dehash = ec.dehash; 
  
CREATE OR REPLACE VIEW em_data.active_feeds AS 
 SELECT fc.contenthash,
    fc.feedgeo,
    fc.expirestime,
    fc.description,
    fc.friendlyname,
    fc.title,
    fc.iconurl,
    fc.imageurl,
	fc.dehash
   FROM em_data.feedcontent fc
  WHERE fc.expirestime >= now(); 

CREATE OR REPLACE VIEW em_data.feeds_by_datetimesent AS 
 SELECT fc.contenthash,
    fc.feedgeo,
    fc.expirestime,
    fc.description,
    fc.friendlyname,
    fc.title,
    fc.iconurl,
    fc.imageurl,
	fc.dehash,
    ec.datetimesent
   FROM em_data.feedcontent fc
     JOIN em_data.contentcache cc ON fc.contenthash = cc.contenthash
     JOIN em_data.edxlcache ec ON cc.dehash = ec.dehash;  

GRANT USAGE ON SCHEMA em_data TO "freshdbuser";
GRANT ALL ON ALL TABLES IN SCHEMA em_data TO "freshdbuser";
GRANT ALL ON ALL SEQUENCES IN SCHEMA em_data TO "freshdbuser";