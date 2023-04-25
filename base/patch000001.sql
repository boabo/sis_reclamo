/***********************************I-SCP-FEA-REC-1-07/01/2017****************************************/
CREATE TABLE rec.tcliente (
  id_cliente SERIAL,
  ci VARCHAR(40) NOT NULL,
  lugar_expedicion VARCHAR(10),
  nombre VARCHAR(100),
  apellido_paterno VARCHAR(30),
  apellido_materno VARCHAR(30),
  genero VARCHAR(10),
  nacionalidad VARCHAR(30),
  email VARCHAR(100),
  celular INTEGER,
  telefono VARCHAR(70),
  id_pais_residencia INTEGER,
  ciudad_residencia VARCHAR(70),
  barrio_zona VARCHAR(200),
  direccion VARCHAR(200),
  CONSTRAINT tcliente_pkey PRIMARY KEY(id_cliente),
  CONSTRAINT cliente_lugar_fk FOREIGN KEY (id_pais_residencia)
    REFERENCES param.tlugar(id_lugar)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) INHERITS (pxp.tbase)

WITH (oids = false);

CREATE TABLE rec.tcompensacion (
  id_compensacion SERIAL,
  nombre VARCHAR(100) NOT NULL,
  codigo VARCHAR(100) NOT NULL,
  orden NUMERIC(4,2) DEFAULT 1 NOT NULL,
  CONSTRAINT tcompensacion_pkey PRIMARY KEY(id_compensacion)
) INHERITS (pxp.tbase)

WITH (oids = false);


CREATE TABLE rec.tmedio_reclamo (
  id_medio_reclamo SERIAL,
  codigo VARCHAR(20),
  nombre_medio VARCHAR(100),
  orden NUMERIC(4,2) DEFAULT 1 NOT NULL,
  CONSTRAINT tmedio_reclamo_codigo_key UNIQUE(codigo),
  CONSTRAINT tmedio_reclamo_pkey PRIMARY KEY(id_medio_reclamo)
) INHERITS (pxp.tbase)

WITH (oids = false);

CREATE TABLE rec.tmotivo_anulado (
  id_motivo_anulado SERIAL,
  motivo VARCHAR(1000),
  orden NUMERIC(4,2) DEFAULT 1,
  CONSTRAINT tmotivo_anulado_pkey PRIMARY KEY(id_motivo_anulado)
) INHERITS (pxp.tbase)

WITH (oids = false);

CREATE TABLE rec.ttipo_incidente (
  id_tipo_incidente SERIAL,
  nombre_incidente VARCHAR(50) NOT NULL,
  fk_tipo_incidente INTEGER,
  tiempo_respuesta VARCHAR(5),
  nivel INTEGER,
  CONSTRAINT ttipo_incidente_pkey PRIMARY KEY(id_tipo_incidente),
  CONSTRAINT ttipo_incidente_fk FOREIGN KEY (fk_tipo_incidente)
  REFERENCES rec.ttipo_incidente(id_tipo_incidente)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
  NOT DEFERRABLE
) INHERITS (pxp.tbase)

WITH (oids = false);


CREATE TABLE rec.treclamo (
  id_reclamo SERIAL,
  id_tipo_incidente INTEGER NOT NULL,
  id_subtipo_incidente INTEGER,
  nro_tramite VARCHAR(20) NOT NULL,
  id_medio_reclamo INTEGER NOT NULL,
  id_funcionario_recepcion INTEGER NOT NULL,
  fecha_hora_incidente TIMESTAMP WITHOUT TIME ZONE,
  fecha_hora_recepcion TIMESTAMP WITHOUT TIME ZONE,
  id_cliente INTEGER,
  pnr VARCHAR(30),
  nro_vuelo VARCHAR(25),
  origen VARCHAR(25),
  destino VARCHAR(25),
  id_oficina_incidente INTEGER,
  id_oficina_registro_incidente INTEGER NOT NULL,
  nro_frd VARCHAR(25),
  nro_frsa INTEGER,
  nro_pir INTEGER,
  nro_att_canalizado INTEGER,
  nro_ripat_att INTEGER,
  nro_hoja_ruta INTEGER,
  id_funcionario_denunciado INTEGER,
  detalle_incidente TEXT,
  observaciones_incidente TEXT,
  id_proceso_wf INTEGER NOT NULL,
  id_estado_wf INTEGER NOT NULL,
  estado VARCHAR(100) NOT NULL,
  correlativo_preimpreso_frd INTEGER DEFAULT 0 NOT NULL,
  fecha_limite_respuesta DATE,
  fecha_hora_vuelo TIMESTAMP WITHOUT TIME ZONE,
  id_gestion INTEGER,
  id_motivo_anulado INTEGER,
  fecha_recepcion_sac DATE,
  transito VARCHAR(15),
  nro_guia_aerea VARCHAR,
  revisado VARCHAR(5) DEFAULT 'no'::character varying NOT NULL,
  CONSTRAINT treclamo_pkey PRIMARY KEY(id_reclamo),
  CONSTRAINT id_estado_wf_fk FOREIGN KEY (id_estado_wf)
    REFERENCES wf.testado_wf(id_estado_wf)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT id_funcionario_denunciado_fk FOREIGN KEY (id_funcionario_denunciado)
    REFERENCES orga.tfuncionario(id_funcionario)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT id_funcionario_recepcion_fk FOREIGN KEY (id_funcionario_recepcion)
    REFERENCES orga.tfuncionario(id_funcionario)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT id_medio_reclamo_fk FOREIGN KEY (id_medio_reclamo)
    REFERENCES rec.tmedio_reclamo(id_medio_reclamo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT id_oficina_incidente_fk FOREIGN KEY (id_oficina_incidente)
    REFERENCES orga.toficina(id_oficina)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT id_oficina_registro_incidente_fk FOREIGN KEY (id_oficina_registro_incidente)
    REFERENCES orga.toficina(id_oficina)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT id_proceso_wf_fk FOREIGN KEY (id_proceso_wf)
    REFERENCES wf.tproceso_wf(id_proceso_wf)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT id_subtipo_incidente_fk FOREIGN KEY (id_subtipo_incidente)
    REFERENCES rec.ttipo_incidente(id_tipo_incidente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT movito_anulado_fk FOREIGN KEY (id_motivo_anulado)
    REFERENCES rec.tmotivo_anulado(id_motivo_anulado)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT treclamo_id_tipo_incidente_fkey FOREIGN KEY (id_tipo_incidente)
    REFERENCES rec.ttipo_incidente(id_tipo_incidente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) INHERITS (pxp.tbase)

WITH (oids = false);

CREATE TABLE rec.tinforme (
  id_informe SERIAL,
  id_reclamo INTEGER NOT NULL,
  nro_informe VARCHAR NOT NULL,
  fecha_informe DATE,
  id_funcionario INTEGER NOT NULL,
  lista_compensacion VARCHAR(500),
  antecedentes_informe VARCHAR(1000),
  analisis_tecnico VARCHAR(1000),
  sugerencia_respuesta VARCHAR(1000),
  conclusion_recomendacion VARCHAR(1000),
  CONSTRAINT tinforme_pkey PRIMARY KEY(id_informe),
  CONSTRAINT fk_tinforme__id_reclamo FOREIGN KEY (id_reclamo)
  REFERENCES rec.treclamo(id_reclamo)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
  NOT DEFERRABLE,
  CONSTRAINT tinforme_id_funcionario_fkey FOREIGN KEY (id_funcionario)
  REFERENCES orga.tfuncionario(id_funcionario)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
  NOT DEFERRABLE
) INHERITS (pxp.tbase)

WITH (oids = false);

CREATE TABLE rec.trespuesta (
  id_respuesta SERIAL,
  id_reclamo INTEGER NOT NULL,
  nro_cite VARCHAR(50),
  fecha_respuesta DATE,
  respuesta VARCHAR(1000000),
  procedente VARCHAR(5) NOT NULL,
  recomendaciones VARCHAR(1000000) NOT NULL,
  fecha_notificacion DATE,
  tipo_respuesta VARCHAR(50) DEFAULT 'respuesta_final'::character varying NOT NULL,
  asunto VARCHAR(100000),
  id_proceso_wf INTEGER NOT NULL,
  id_estado_wf INTEGER NOT NULL,
  estado VARCHAR(100) NOT NULL,
  nro_respuesta VARCHAR(50) NOT NULL,
  CONSTRAINT trespuesta_pkey PRIMARY KEY(id_respuesta),
  CONSTRAINT trespuesta_fk FOREIGN KEY (id_proceso_wf)
    REFERENCES wf.tproceso_wf(id_proceso_wf)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT trespuesta_fk1 FOREIGN KEY (id_estado_wf)
    REFERENCES wf.testado_wf(id_estado_wf)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE,
  CONSTRAINT trespuesta_fk2 FOREIGN KEY (id_reclamo)
    REFERENCES rec.treclamo(id_reclamo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) INHERITS (pxp.tbase)

WITH (oids = false);



/***********************************F-SCP-FEA-REC-1-07/01/2017****************************************/


/***********************************I-SCP-FEA-REC-2-20/06/2017****************************************/

CREATE TABLE rec.tlogs_reclamo (
  id_logs_reclamo SERIAL,
  descripcion TEXT,
  id_reclamo INTEGER,
  id_funcionario INTEGER,
  CONSTRAINT tlogs_reclamo_pkey PRIMARY KEY(id_logs_reclamo)
) INHERITS (pxp.tbase)

WITH (oids = false);

ALTER TABLE rec.tlogs_reclamo
  ALTER COLUMN id_logs_reclamo SET STATISTICS 0;

ALTER TABLE rec.tlogs_reclamo
  ALTER COLUMN descripcion SET STATISTICS 0;

/***********************************F-SCP-FEA-REC-2-20/06/2017****************************************/

/***********************************I-SCP-MAY-REC-0-10/05/2018****************************************/

ALTER TABLE rec.tcliente
  ADD COLUMN email2 VARCHAR(100);

/***********************************F-SCP-MAY-REC-0-10/05/2018****************************************/

/***********************************I-SCP-FEA-REC-0-07/11/2018****************************************/

CREATE TABLE rec.tferiado (
  id_feriado SERIAL,
  dia VARCHAR(5),
  mes VARCHAR(15),
  CONSTRAINT tferiado_pkey PRIMARY KEY(id_feriado)
) INHERITS (pxp.tbase)

WITH (oids = false);

ALTER TABLE rec.tferiado
  ALTER COLUMN id_feriado SET STATISTICS 0;


CREATE TABLE rec.tferiados (
  id_origen INTEGER,
  id_lugar INTEGER,
  tipo INTEGER,
  fecha DATE,
  descripcion VARCHAR(250) NOT NULL,
  estado VARCHAR(2),
  id_feriado SERIAL,
  CONSTRAINT tferiados_pkey PRIMARY KEY(id_feriado)
) INHERITS (pxp.tbase)

WITH (oids = false);

CREATE TABLE rec.tnumero_frd (
  id_numero_frd INTEGER DEFAULT nextval('rec.toficinas_aux_id_oficina_aux_seq'::regclass) NOT NULL,
  id_oficina INTEGER NOT NULL,
  id_gestion INTEGER NOT NULL,
  numero INTEGER,
  CONSTRAINT toficinas_aux_pkey PRIMARY KEY(id_numero_frd)
) INHERITS (pxp.tbase)

WITH (oids = false);

ALTER TABLE rec.tnumero_frd
  ALTER COLUMN id_numero_frd SET STATISTICS 0;

ALTER TABLE rec.tnumero_frd
  ALTER COLUMN id_oficina SET STATISTICS 0;


CREATE TABLE rec.toficina (
  id_oficina INTEGER DEFAULT nextval('rec.toficinas_id_oficina_seq'::regclass) NOT NULL,
  codigo VARCHAR(20) NOT NULL,
  nombre VARCHAR(200) NOT NULL,
  id_lugar INTEGER NOT NULL,
  aeropuerto VARCHAR(2) NOT NULL,
  zona_franca VARCHAR(2),
  frontera VARCHAR(2),
  correo_oficina VARCHAR(200),
  direccion VARCHAR(255),
  CONSTRAINT toficinas_pkey PRIMARY KEY(id_oficina),
  CONSTRAINT chk__toficina__aeropuerto CHECK (((aeropuerto)::text = 'si'::text) OR ((aeropuerto)::text = 'no'::text)),
  CONSTRAINT fk__toficina__id_lugar FOREIGN KEY (id_lugar)
    REFERENCES param.tlugar(id_lugar)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE
) INHERITS (pxp.tbase)

WITH (oids = false);

CREATE TABLE rec.treclamo_informe (
  id_reclamo INTEGER NOT NULL,
  id_informe INTEGER NOT NULL
) INHERITS (pxp.tbase)

WITH (oids = false);

ALTER TABLE rec.treclamo_informe
  ALTER COLUMN id_informe SET STATISTICS 0;


CREATE TABLE rec.trol (
    id_rol SERIAL,
    json_rol JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT trol_pkey PRIMARY KEY(id_rol)
) INHERITS (pxp.tbase)
  WITH (oids = false);

COMMENT ON COLUMN rec.trol.json_rol
    IS 'Almacena los roles del sistema reclamos.';

ALTER TABLE rec.trol
    OWNER TO postgres;

/***********************************F-SCP-FEA-REC-0-07/11/2018****************************************/