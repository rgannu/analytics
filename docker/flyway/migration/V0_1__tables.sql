--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

-- SET search_path = public, pg_catalog;
-- SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE school (
  id bigint NOT NULL,
  name character varying(255)
);

ALTER TABLE school OWNER TO ${db.owner};
ALTER TABLE ONLY school
    ADD CONSTRAINT school_pkey PRIMARY KEY (id);

CREATE TABLE staff (
  id bigint NOT NULL,
  first_name character varying(255),
  last_name character varying(255),
  mobile character varying(255),
  school_id bigint,
  FOREIGN KEY (school_id) REFERENCES school (id)
);

ALTER TABLE staff OWNER TO ${db.owner};
ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);

CREATE TABLE class (
  id bigint NOT NULL,
  code character varying(255),
  name character varying(255),
  staff_id bigint,
  FOREIGN KEY (staff_id) REFERENCES staff (id)
);

ALTER TABLE class OWNER TO ${db.owner};
ALTER TABLE ONLY class
    ADD CONSTRAINT class_pkey PRIMARY KEY (id);

CREATE table address (
  id bigint NOT NULL,
  street_name character varying(255),
  line_1 character varying(255),
  line_2 character varying(255),
  postcode integer,
  city character varying(255),
  country character varying(255)
);

ALTER TABLE address OWNER TO ${db.owner};
ALTER TABLE ONLY address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id);

CREATE table student (
  id bigint NOT NULL,
  first_name character varying(255),
  last_name character varying(255),
  mobile character varying(255),
  class_id bigint,
  address_id bigint,
  FOREIGN KEY (class_id) REFERENCES class (id),
  FOREIGN KEY (address_id) REFERENCES address (id)
);

ALTER TABLE student OWNER TO ${db.owner};
ALTER TABLE ONLY student
    ADD CONSTRAINT student_pkey PRIMARY KEY (id);
--
-- Name: public; Type: ACL; Schema: -; Owner: ${db.owner}
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM ${db.owner};
GRANT ALL ON SCHEMA public TO ${db.owner};
GRANT ALL ON SCHEMA public TO PUBLIC;

REVOKE ALL ON TABLE student FROM PUBLIC;
REVOKE ALL ON TABLE student FROM ${db.owner};
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE student TO ${db.user};
GRANT ALL ON TABLE student TO ${db.owner};

REVOKE ALL ON TABLE class FROM PUBLIC;
REVOKE ALL ON TABLE class FROM ${db.owner};
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE class TO ${db.user};
GRANT ALL ON TABLE class TO ${db.owner};

REVOKE ALL ON TABLE staff FROM PUBLIC;
REVOKE ALL ON TABLE staff FROM ${db.owner};
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE staff TO ${db.user};
GRANT ALL ON TABLE staff TO ${db.owner};

REVOKE ALL ON TABLE school FROM PUBLIC;
REVOKE ALL ON TABLE school FROM ${db.owner};
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE school TO ${db.user};
GRANT ALL ON TABLE school TO ${db.owner};

REVOKE ALL ON TABLE address FROM PUBLIC;
REVOKE ALL ON TABLE address FROM ${db.owner};
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE address TO ${db.user};
GRANT ALL ON TABLE address TO ${db.owner};

--
-- INSERT data
--
INSERT INTO school(id, name) values(1, 'TVS');

INSERT INTO staff(id, first_name, last_name, mobile, school_id) values(1, 'John', 'Doe', '+32-111-1111', 1);
INSERT INTO staff(id, first_name, last_name, mobile, school_id) values(2, 'Batsleer', 'Claudine', '+32-111-2222', 1);
INSERT INTO staff(id, first_name, last_name, mobile, school_id) values(3, 'Braem', 'Martin', '+32-111-3333', 1);

INSERT INTO class(id, code, name, staff_id) values(1, 'L1A', 'Level 1 A', 1);
INSERT INTO class(id, code, name, staff_id) values(2, 'L1B', 'Level 1 B', 2);
INSERT INTO class(id, code, name, staff_id) values(3, 'L1C', 'Level 1 C', 3);

INSERT INTO address(id, street_name, line_1, postcode, city, country) values(1, 'Belgielei', '1', 2610, 'Antwerpen', 'Belgium');
INSERT INTO address(id, street_name, line_1, postcode, city, country) values(2, 'Molenstraat', '2', 9000, 'Gent', 'Belgium');
INSERT INTO address(id, street_name, line_1, postcode, city, country) values(3, 'Boekstraat', '1', 1000, 'Brussels', 'Belgium');
INSERT INTO address(id, street_name, line_1, postcode, city, country) values(4, 'Moerelei', '1', 2620, 'Berchem', 'Belgium');
INSERT INTO address(id, street_name, line_1, postcode, city, country) values(5, 'Jules Moretuslei', '1', 2610, 'Wilrijk', 'Belgium');
INSERT INTO address(id, street_name, line_1, postcode, city, country) values(6, 'Anselmontstraat', '1', 2018, 'Antwerpen', 'Belgium');

INSERT INTO student(id, first_name, last_name, mobile, class_id, address_id) values(1, 'Ganesh', 'Ramasubramanian', '+32-111-1111', 1, 1);
INSERT INTO student(id, first_name, last_name, mobile, class_id, address_id) values(2, 'Steven', 'Noels', '+32-111-1111', 1, 2);
INSERT INTO student(id, first_name, last_name, mobile, class_id, address_id) values(3, 'Youri', 'De Bhont', '+32-111-1111', 2, 3);
INSERT INTO student(id, first_name, last_name, mobile, class_id, address_id) values(4, 'Tom', 'Stork', '+32-111-1111', 2, 4);
INSERT INTO student(id, first_name, last_name, mobile, class_id, address_id) values(5, 'Dennis', 'Van Bollen', '+32-111-1111', 3, 5);
INSERT INTO student(id, first_name, last_name, mobile, class_id, address_id) values(6, 'Kristof', 'Van Dyck', '+32-111-1111', 3, 6);

