CREATE OR REPLACE FUNCTION rec.ft_reclamo_ime (
    p_administrador integer,
    p_id_usuario integer,
    p_tabla varchar,
    p_transaccion varchar
)
    RETURNS varchar AS
$body$
    /**************************************************************************
   SISTEMA:		Sistema de Reclamos
   FUNCION: 		rec.ft_reclamo_ime
   DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'rec.treclamo'
   AUTOR: 		 (admin)
   FECHA:	        10-08-2016 18:32:59
   COMENTARIOS:
  ***************************************************************************
   HISTORIAL DE MODIFICACIONES:

   DESCRIPCION:
   AUTOR:
   FECHA:
  ***************************************************************************/

DECLARE

    v_nro_requerimiento    	integer;
    v_parametros           	record;
    v_id_requerimiento     	integer;
    v_resp		            varchar;
    v_nombre_funcion        text;
    v_mensaje_error         text;
    v_id_reclamo			integer;
    v_nro_tramite			varchar;
    v_id_proceso_wf			integer;
    v_id_estado_wf			integer;
    v_codigo_estado 		varchar;

    v_codigo_tipo_proceso 	varchar;
    v_id_proceso_macro    	integer;
    v_num_reclamo			varchar;

    v_reclamo				record;
    v_id_tipo_estado		integer;
    v_pedir_obs		    	varchar;
    v_codigo_estado_siguiente varchar;
    v_acceso_directo  	varchar;
    v_clase   			varchar;
    v_parametros_ad   	varchar;
    v_tipo_noti  		varchar;
    v_titulo   			varchar;
    v_id_estado_actual	integer;
    v_id_depto				integer;
    v_obs					text;
    v_registros_proc	record;
    v_codigo_tipo_pro	varchar;
    v_codigo_llave		varchar;
    v_funcionario   	integer;
    v_gestion 			integer;
    v_registros_rec		record;


    v_id_funcionario    integer;
    v_id_usuario_reg	integer;
    v_id_estado_wf_ant  integer;
    v_operacion			varchar;

    v_record			record;
    v_nombre			varchar;
    v_revisado			varchar;

    v_fecha_limite			date;
    v_dias				integer;

    v_fecha_mod 		timestamp;
    v_fecha_mod_r		timestamp;
    v_anulado			integer=null;
    v_motivo_anulado	varchar;
    v_id_medio_reclamo	integer;
    v_cont_resp			integer;

    v_estado_wf			varchar;

    v_record_gestion	record;
    v_siguiente_estado 	varchar;


    --STADISTICA BEGIN
    v_stadistica	record;
    v_hombres			integer=0;
    v_mujeres			integer=0;
    v_noEspecifica 		integer=0;
    v_criterio			varchar;

    v_boleto			INTEGER=0;
    v_vuelo				INTEGER=0;
    v_equipaje			INTEGER=0;
    v_carga				INTEGER=0;
    v_catering			INTEGER=0;
    v_sac				INTEGER=0;
    v_otros				INTEGER=0;

    borrador	integer=0;
    pendiente_revision	integer=0;
    registrado_ripat	integer=0;
    pendiente_informacion	integer=0;
    anulado	integer=0;
    derivado	integer=0;
    pendiente_respuesta	integer=0;
    archivo_con_respuesta	integer=0;
    archivado_concluido	integer=0;
    en_avenimiento	integer=0;
    formulacion_cargos	integer=0;
    resolucion_administrativa	integer=0;
    recurso_revocatorio	integer=0;
    recurso_jerarquico	integer=0;
    contencioso_administrativo integer=0;
    pendiente_asignacion	integer=0;
    respuesta_registro_ripat	integer=0;

    v_lim	INTEGER=0;
    v_bue	INTEGER=0;
    v_sla	INTEGER=0;
    v_sao	INTEGER=0;
    v_mad	INTEGER=0;
    v_viru	INTEGER=0;
    v_uyu	INTEGER=0;
    v_oru	INTEGER=0;
    v_poi	INTEGER=0;
    v_cij	INTEGER=0;
    v_tdd	INTEGER=0;
    v_tja	INTEGER=0;
    v_sre	INTEGER=0;
    v_srz	INTEGER=0;
    v_lpb	INTEGER=0;
    v_cbb	INTEGER=0;
    v_acft  INTEGER=0;
    v_mia	INTEGER=0;

    v_ato INTEGER=0;
    v_cto INTEGER=0;
    v_cga INTEGER=0;
    v_canalizado INTEGER=0;
    v_web INTEGER=0;

    v_call INTEGER=0;
    v_att INTEGER=0;

    v_fecha_hasta record;
    --END
    v_frd varchar;
    v_contador integer;
    v_fecha_limite_mod date;
    v_valid varchar;

    --Variables para cambiar a estado archivado_concluido
    v_fecha				date;
    v_id_usuario		integer;
    --
    v_id_incidente		integer;
    v_band_incidente	boolean = false;

    --control de frds fatantes
    v_max				integer;
    v_min				integer;
    v_frd_faltantes		varchar[];
    v_frds				integer[];
    v_frds_aux			INTEGER[];
    v_cont				integer;
    v_index				integer;
    v_cad_frds			varchar;
    v_band_frds			varchar;

    v_id_logs_reclamo		integer;

    v_cont_rec				integer;
    v_fecha_aux				integer;
    v_id_rol                integer;
BEGIN

    v_nombre_funcion = 'rec.ft_reclamo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'REC_REC_INS'
     #DESCRIPCION:	Insercion de registros
     #AUTOR:		admin
     #FECHA:		10-08-2016 18:32:59
    ***********************************/

    if(p_transaccion='REC_REC_INS')then
        begin
            --raise exception  'Estimado Usuario Temporalmente no podra registrar reclamos, cualquier consulta contactarse con Responsables SAC. <br> Por Regularización, el servicio estara disponible a partir de las 13:30 pm.';
            -- obtener el codigo del tipo_proceso
            select   tp.codigo, pm.id_proceso_macro
            into v_codigo_tipo_proceso, v_id_proceso_macro
            from  wf.tproceso_macro pm, wf.ttipo_proceso tp
            where pm.codigo='REC' and tp.tabla='rec.vreclamo' and tp.estado_reg = 'activo' and tp.inicio = 'si';

            --Obtenemos la gestion


            v_fecha_aux =  EXTRACT(YEAR FROM v_parametros.fecha_hora_recepcion::date);
            --v_fecha_aux =  EXTRACT(YEAR FROM v_parametros.fecha_hora_recepcion::date);
            if v_fecha_aux = 2018 then
                --if( v_fecha_aux > 2017) then
                select g.id_gestion
                into v_gestion
                from param.tgestion g
                where g.gestion = v_fecha_aux;
            else
                select g.id_gestion
                into v_gestion
                from param.tgestion g
                where g.gestion = v_fecha_aux;
            end if;
            /*else
                 raise exception 'Estimado usuario no puede hacer registros de gestiones pasadas, comuniquese con los responsables SAC.';
              --v_gestion = 15;
            end if;*/


            --Control de fecha_limite de una respuesta, mas uno porque se cuenta a partir del dia siguiente habil.
            v_fecha_mod = v_parametros.fecha_hora_recepcion::date;
            IF 	(v_parametros.id_tipo_incidente IN (4,6,37,38,48,50))THEN
                v_fecha_limite = param.f_sumar_dias_habiles(v_fecha_mod::date, 10);
            ELSIF v_parametros.id_tipo_incidente=36 THEN
                v_fecha_limite = param.f_sumar_dias_habiles(v_fecha_mod::date, 7);
            END IF;
            --raise exception 'v_fecha_limite: %', v_fecha_limite;
            -- inciar el tramite en el sistema de WF
            SELECT
                ps_num_tramite ,
                ps_id_proceso_wf ,
                ps_id_estado_wf ,
                ps_codigo_estado
            into
                v_nro_tramite,
                v_id_proceso_wf,
                v_id_estado_wf,
                v_codigo_estado

            FROM wf.f_inicia_tramite(
                         p_id_usuario,
                         v_parametros._id_usuario_ai,
                         v_parametros._nombre_usuario_ai,
                         v_gestion,
                         v_codigo_tipo_proceso,
                         v_parametros.id_funcionario_recepcion,
                         null,
                         'RECLAMO',
                         'SAC-REC'
                     );

            SELECT tmr.id_medio_reclamo into v_id_medio_reclamo
            FROM rec.tmedio_reclamo tmr
            WHERE tmr.codigo='FRD';

            select coalesce(count(tr.id_reclamo), 0)
            into v_cont_rec
            from rec.treclamo tr
            where tr.nro_frd = v_parametros.nro_frd::varchar and tr.id_cliente = v_parametros.id_cliente and
                    tr.correlativo_preimpreso_frd = v_parametros.correlativo_preimpreso_frd;

            if(v_cont_rec = 0)then
                --raise exception 'por favor espere unos minutos';
                --Sentencia de la insercion
                insert into rec.treclamo(
                    id_tipo_incidente,
                    id_subtipo_incidente,
                    id_medio_reclamo,
                    id_funcionario_recepcion,
                    id_funcionario_denunciado,
                    id_oficina_incidente,
                    id_oficina_registro_incidente,
                    id_proceso_wf,
                    id_estado_wf,
                    id_cliente,
                    estado,
                    fecha_hora_incidente,
                    nro_ripat_att,
                    nro_hoja_ruta,
                    fecha_hora_recepcion,
                    estado_reg,
                    fecha_hora_vuelo,
                    origen,
                    nro_frd,
                    correlativo_preimpreso_frd,
                    transito,
                    fecha_limite_respuesta,
                    observaciones_incidente,
                    destino,
                    nro_pir,
                    nro_frsa,
                    nro_att_canalizado,
                    nro_tramite,
                    detalle_incidente,
                    pnr,
                    nro_vuelo,
                    id_usuario_reg,
                    fecha_reg,
                    usuario_ai,
                    id_usuario_ai,
                    fecha_mod,
                    id_usuario_mod,
                    id_gestion,
                    id_motivo_anulado
                ) values(
                            v_parametros.id_tipo_incidente,
                            v_parametros.id_subtipo_incidente,
                            v_id_medio_reclamo,
                            v_parametros.id_funcionario_recepcion,
                            v_parametros.id_funcionario_denunciado,
                            v_parametros.id_oficina_registro_incidente,
                            v_parametros.id_oficina_registro_incidente,
                            v_id_proceso_wf,
                            v_id_estado_wf,
                            v_parametros.id_cliente,
                            v_codigo_estado,
                            v_parametros.fecha_hora_incidente,
                            v_parametros.nro_ripat_att,
                            v_parametros.nro_hoja_ruta,
                            v_parametros.fecha_hora_recepcion,
                            'activo',
                            v_parametros.fecha_hora_vuelo,
                            upper(v_parametros.origen),
                            v_parametros.nro_frd,
                            v_parametros.correlativo_preimpreso_frd,
                            upper(v_parametros.transito),
                            v_fecha_limite,
                            v_parametros.observaciones_incidente,
                            upper(v_parametros.destino),
                            v_parametros.nro_pir,
                            v_parametros.nro_frsa,
                            v_parametros.nro_att_canalizado,
                            v_nro_tramite,
                            v_parametros.detalle_incidente,
                            v_parametros.pnr,
                            v_parametros.nro_vuelo,
                            p_id_usuario,
                            now(),
                            v_parametros._nombre_usuario_ai,
                            v_parametros._id_usuario_ai,
                            null,
                            null,
                            v_gestion,
                            v_anulado

                        )RETURNING id_reclamo into v_id_reclamo;
                v_frd = rec.f_get_numero_frd(v_parametros.id_oficina_registro_incidente::integer,v_gestion,p_id_usuario);
            else
                raise exception 'El reclamo que intenta registrar ya se encuentra en el ERP2';
            end if;
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Reclamos almacenado(a) con exito (id_reclamo'||v_id_reclamo||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_reclamo',v_id_reclamo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'v_id_estado_wf',v_id_estado_wf::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'v_id_proceso_wf',v_id_proceso_wf::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'v_momento', 'new');

            --Devuelve la respuesta
            return v_resp;

        end;

        /*********************************
         #TRANSACCION:  'REC_REC_MOD'
         #DESCRIPCION:	Modificacion de registros
         #AUTOR:		admin
         #FECHA:		10-08-2016 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_REC_MOD')then

        begin
            --Sentencia de la modificacion


            IF (v_parametros.id_medio_reclamo is null)THEN
                SELECT tmr.id_medio_reclamo into v_id_medio_reclamo
                FROM rec.tmedio_reclamo tmr
                WHERE tmr.codigo='FRD';
            ELSE
                v_id_medio_reclamo = v_parametros.id_medio_reclamo;
            END IF;

            --Control de fecha_limite de una respuesta, mas uno porque se cuenta a partir del dia siguiente habil.
            --begin


            SELECT r.fecha_hora_recepcion, r.id_tipo_incidente
            INTO v_fecha_mod_r, v_id_incidente
            FROM rec.treclamo r
            WHERE r.id_reclamo = v_parametros.id_reclamo;

            IF(v_id_incidente<>v_parametros.id_tipo_incidente)THEN
                v_band_incidente = TRUE;
            END IF;

            IF ((v_fecha_mod_r::date != v_parametros.fecha_hora_recepcion::date) OR v_band_incidente or v_fecha_mod_r::date = v_parametros.fecha_hora_recepcion::date) THEN
                v_fecha_mod = v_parametros.fecha_hora_recepcion::date; --raise exception 'v_fecha_mod: %',v_fecha_mod;
                IF 	(select v_parametros.id_tipo_incidente IN (4,6,37,38,48,50))THEN
                    v_fecha_limite = param.f_sumar_dias_habiles(v_fecha_mod::date, 10);--raise exception 'v_fecha_limite: %', v_fecha_limite;
                ELSIF v_parametros.id_tipo_incidente=36 THEN
                    v_fecha_limite = param.f_sumar_dias_habiles(v_fecha_mod::date, 7);
                END IF;
            ELSE
                SELECT r.fecha_limite_respuesta
                INTO v_fecha_limite_mod
                FROM rec.treclamo r
                WHERE r.id_reclamo = v_parametros.id_reclamo;

            END IF;
            --raise exception 'v_fecha_limite: %, %', v_fecha_limite,v_fecha_limite_mod;
            --end
            -- Para cuando id_motivo_anulado es NULL
            --begin

            IF (v_parametros.id_motivo_anulado IS NULL) THEN
                v_anulado = NULL;
            ELSE
                v_anulado =  v_parametros.id_motivo_anulado;
            END IF;
            --end
            --Control para el Nro. de dias de Respuesta si se cambia el tipo de incidente.

            update rec.treclamo set
                                    id_tipo_incidente = v_parametros.id_tipo_incidente,
                                    id_subtipo_incidente = v_parametros.id_subtipo_incidente,
                                    id_medio_reclamo = v_id_medio_reclamo,
                                    id_funcionario_recepcion = v_parametros.id_funcionario_recepcion,
                                    id_funcionario_denunciado = v_parametros.id_funcionario_denunciado,
                                    id_oficina_incidente = v_parametros.id_oficina_incidente,
                                    id_oficina_registro_incidente = v_parametros.id_oficina_registro_incidente,
                                    id_cliente = v_parametros.id_cliente,
                                    fecha_hora_incidente = v_parametros.fecha_hora_incidente,
                                    nro_ripat_att = v_parametros.nro_ripat_att,
                                    nro_hoja_ruta = v_parametros.nro_hoja_ruta,
                                    fecha_hora_recepcion = v_parametros.fecha_hora_recepcion,
                                    fecha_hora_vuelo = v_parametros.fecha_hora_vuelo,
                                    origen = upper(v_parametros.origen),
                                    nro_frd = v_parametros.nro_frd,
                                    correlativo_preimpreso_frd = v_parametros.correlativo_preimpreso_frd,
                                    fecha_limite_respuesta = CASE WHEN ((v_fecha_mod_r::date <> v_parametros.fecha_hora_recepcion::date) OR v_band_incidente or (v_fecha_mod_r::date = v_parametros.fecha_hora_recepcion::date)) THEN v_fecha_limite ELSE v_fecha_limite_mod END ,
                                    observaciones_incidente = v_parametros.observaciones_incidente,
                                    destino = upper(v_parametros.destino),
                                    nro_pir = v_parametros.nro_pir,
                                    nro_frsa = v_parametros.nro_frsa,
                                    nro_att_canalizado = v_parametros.nro_att_canalizado,
                                    transito = upper(v_parametros.transito),
                                    detalle_incidente = v_parametros.detalle_incidente,
                                    pnr = v_parametros.pnr,
                                    nro_vuelo = upper(v_parametros.nro_vuelo),
                                    fecha_mod = now(),
                                    id_usuario_mod = p_id_usuario,
                                    id_usuario_ai = v_parametros._id_usuario_ai,
                                    usuario_ai = v_parametros._nombre_usuario_ai,
                                    id_motivo_anulado =  v_anulado

            where id_reclamo=v_parametros.id_reclamo;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Reclamos modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_reclamo',v_parametros.id_reclamo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'v_momento', 'edit');

            --Devuelve la respuesta
            return v_resp;

        end;

        /*********************************
         #TRANSACCION:  'REC_REC_ELI'
         #DESCRIPCION:	Eliminacion de registros
         #AUTOR:		admin
         #FECHA:		10-08-2016 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_REC_ELI')then

        begin

            select
                tr.id_estado_wf,
                tr.id_proceso_wf,
                tr.estado,
                tr.id_reclamo,
                tr.nro_tramite,
                tr.id_funcionario_recepcion,
                tr.nro_tramite
            into
                v_id_estado_wf,
                v_id_proceso_wf,
                v_codigo_estado,
                v_id_reclamo,
                v_nro_tramite,
                v_funcionario,
                v_nro_tramite
            from rec.treclamo tr
            where tr.id_reclamo = v_parametros.id_reclamo;

            IF (p_administrador = 1)THEN
                if v_codigo_estado != 'borrador' then
                    raise exception 'Solo pueden anularce reclamos del estado borrador';
                end if;

                -- obtenemos el tipo del estado anulado
                /*select
                    te.id_tipo_estado
                into
                    v_id_tipo_estado
                from wf.tproceso_wf pw
                inner join wf.ttipo_proceso tp on pw.id_tipo_proceso = tp.id_tipo_proceso
                inner join wf.ttipo_estado te on te.id_tipo_proceso = tp.id_tipo_proceso and te.codigo = 'anulado'
                where pw.id_proceso_wf = v_id_proceso_wf;


                if v_id_tipo_estado is null  then
                    raise exception 'No se parametrizo el estado "anulado" para reclamos';
                end if;


                -- pasamos el reclamo  al siguiente anulado
                v_id_estado_actual =  wf.f_registra_estado_wf(
                    v_id_tipo_estado,
                    v_funcionario,
                    v_id_estado_wf,
                    v_id_proceso_wf,
                    p_id_usuario,
                    v_parametros._id_usuario_ai,
                    v_parametros._nombre_usuario_ai,
                    v_id_depto,
                    'Eliminacion de Reclamo'|| COALESCE(v_nro_tramite,'--')
                );*/

                -- actualiza estado en el reclamo

                update rec.treclamo set
                    --id_estado_wf =  v_id_estado_actual,
                    --estado = 'anulado',
                    --id_usuario_mod=p_id_usuario,
                    --fecha_mod=now()
                    estado_reg = 'inactivo'
                where id_reclamo  = v_parametros.id_reclamo;
            ELSE
                RAISE EXCEPTION 'No es posible eliminar el reclamo %, dirijase a su bandeja, ubique el reclamo creado y haga los cambios necesarios haciendo click en el bóton Editar.',v_nro_tramite;
            END IF;
            --Sentencia de la eliminacion
            /*delete from rec.treclamo
            where id_reclamo=v_parametros.id_reclamo;*/

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Reclamos eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_reclamo',v_parametros.id_reclamo::varchar);

            --Devuelve la respuesta
            return v_resp;

        end;
        /*********************************
         #TRANSACCION:  'REC_ANTEREC_IME'
         #DESCRIPCION:	Anterior estado de un Reclamo
         #AUTOR:		admin
         #FECHA:		21-09-2016 11:32:59
        ***********************************/
    elseif(p_transaccion='REC_ANTEREC_IME') then
        begin

            v_operacion = 'anterior';

            IF  pxp.f_existe_parametro(p_tabla , 'estado_destino')  THEN
                v_operacion = v_parametros.estado_destino;
            END IF;

            --obtenermos datos basicos de reclamo
            select
                rec.id_reclamo,
                rec.id_proceso_wf,
                rec.estado,
                pwf.id_tipo_proceso
            into v_registros_rec
            from rec.treclamo  rec
                     inner  join wf.tproceso_wf pwf  on  pwf.id_proceso_wf = rec.id_proceso_wf
            where rec.id_proceso_wf  = v_parametros.id_proceso_wf;

            v_id_proceso_wf = v_registros_rec.id_proceso_wf;

            select r.nro_tramite, r.id_motivo_anulado, r.id_estado_wf
            into v_reclamo
            from rec.treclamo r
            where	r.id_reclamo = v_registros_rec.id_reclamo;

            SELECT count(*)
            INTO v_cont_resp
            FROM rec.trespuesta
            WHERE id_reclamo = v_registros_rec.id_reclamo;

            IF( v_cont_resp = 0 OR p_administrador=1 )	THEN
                IF  v_operacion = 'anterior' THEN
                    --------------------------------------------------
                    --Retrocede al estado inmediatamente anterior
                    -------------------------------------------------
                    --recuperaq estado anterior segun Log del WF
                    --raise exception 'v_parametros.id_estado_wf: %',v_parametros.id_estado_wf;
                    SELECT

                        ps_id_tipo_estado,
                        ps_id_funcionario,
                        ps_id_usuario_reg,
                        ps_id_depto,
                        ps_codigo_estado,
                        ps_id_estado_wf_ant
                    into
                        v_id_tipo_estado,
                        v_id_funcionario,
                        v_id_usuario_reg,
                        v_id_depto,
                        v_codigo_estado,
                        v_id_estado_wf_ant
                    FROM wf.f_obtener_estado_ant_log_wf(v_parametros.id_estado_wf);

                    --Verificar si el estado actual es anulado y el anterior estado registro ripat
                    --para poner el id_motivo_anulado en NULL
                    --begin


                    SELECT tte.codigo INTO v_motivo_anulado
                    FROM wf.testado_wf tew
                             INNER JOIN wf.ttipo_estado tte ON tte.id_tipo_estado = tew.id_tipo_estado
                    WHERE tew.id_estado_wf = v_reclamo.id_estado_wf;

                    IF(v_motivo_anulado = 'anulado')THEN
                        UPDATE rec.treclamo  SET id_motivo_anulado = NULL
                        WHERE id_reclamo = v_registros_rec.id_reclamo;
                    END IF;


                    --end;

                    --raise exception 'v_id_tipo_estado: % + v_id_funcionario: % + v_id_usuario_reg: % + v_id_depto: % +v_codigo_estado: % +v_id_estado_wf_ant: % ', v_id_tipo_estado, v_id_funcionario,v_id_usuario_reg,v_id_depto, v_codigo_estado, v_id_estado_wf_ant;

                    select
                        ew.id_proceso_wf
                    into
                        v_id_proceso_wf
                    from wf.testado_wf ew
                    where ew.id_estado_wf= v_id_estado_wf_ant;
                END IF;



                --configurar acceso directo para la alarma
                v_acceso_directo = '';
                v_clase = '';
                v_parametros_ad = '';
                v_tipo_noti = 'notificacion';
                v_titulo  = 'Visto Bueno';


                IF   v_codigo_estado_siguiente not in('borrador','pendiente_revision','pendiente_respuesta','derivado','anulado')   THEN
                    v_acceso_directo = '../../../sis_reclamo/vista/Reclamo/RegistroReclamos.php';
                    v_clase = 'RegistroReclamos';
                    v_parametros_ad = '{filtro_directo:{campo:"rec.id_proceso_wf",valor:"'||v_id_proceso_wf::varchar||'"}}';
                    v_tipo_noti = 'notificacion';
                    v_titulo  = 'Visto Bueno';

                END IF;


                -- registra nuevo estado

                v_id_estado_actual = wf.f_registra_estado_wf(
                        v_id_tipo_estado,                --  id_tipo_estado al que retrocede
                        v_id_funcionario,                --  funcionario del estado anterior
                        v_parametros.id_estado_wf,       --  estado actual ...
                        v_id_proceso_wf,                 --  id del proceso actual
                        p_id_usuario,                    -- usuario que registra
                        v_parametros._id_usuario_ai,
                        v_parametros._nombre_usuario_ai,
                        v_id_depto,                       --depto del estado anterior
                        '[RETROCESO] '|| v_parametros.obs,
                        v_acceso_directo,
                        v_clase,
                        v_parametros_ad,
                        v_tipo_noti,
                        v_titulo);

                IF  not rec.f_ant_estado_reclamo_wf(p_id_usuario,
                                                    v_parametros._id_usuario_ai,
                                                    v_parametros._nombre_usuario_ai,
                                                    v_id_estado_actual,
                                                    v_parametros.id_proceso_wf,
                                                    v_codigo_estado) THEN

                    raise exception 'Error al retroceder estado';

                END IF;


                -- si hay mas de un estado disponible  preguntamos al usuario
                v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Se realizo el cambio de estado)');
                v_resp = pxp.f_agrega_clave(v_resp,'operacion','cambio_exitoso');

                --Devuelve la respu	esta
                return v_resp;
            ELSIF (v_registros_rec.estado IN
                   ('en_avenimiento', 'formulacion_cargos', 'resolucion_administrativa',
                    'recurso_revocatorio','recurso_jerarquico', 'contencioso_administrativo')) THEN
                IF  v_operacion = 'anterior' THEN
                    --------------------------------------------------
                    --Retrocede al estado inmediatamente anterior
                    -------------------------------------------------
                    --recuperaq estado anterior segun Log del WF
                    --raise exception 'v_parametros.id_estado_wf: %',v_parametros.id_estado_wf;
                    SELECT

                        ps_id_tipo_estado,
                        ps_id_funcionario,
                        ps_id_usuario_reg,
                        ps_id_depto,
                        ps_codigo_estado,
                        ps_id_estado_wf_ant
                    into
                        v_id_tipo_estado,
                        v_id_funcionario,
                        v_id_usuario_reg,
                        v_id_depto,
                        v_codigo_estado,
                        v_id_estado_wf_ant
                    FROM wf.f_obtener_estado_ant_log_wf(v_parametros.id_estado_wf);

                    --Verificar si el estado actual es anulado y el anterior estado registro ripat
                    --para poner el id_motivo_anulado en NULL
                    --begin


                    SELECT tte.codigo INTO v_motivo_anulado
                    FROM wf.testado_wf tew
                             INNER JOIN wf.ttipo_estado tte ON tte.id_tipo_estado = tew.id_tipo_estado
                    WHERE tew.id_estado_wf = v_reclamo.id_estado_wf;

                    IF(v_motivo_anulado = 'anulado')THEN
                        UPDATE rec.treclamo  SET id_motivo_anulado = NULL
                        WHERE id_reclamo = v_registros_rec.id_reclamo;
                    END IF;


                    --end;

                    --raise exception 'v_id_tipo_estado: % + v_id_funcionario: % + v_id_usuario_reg: % + v_id_depto: % +v_codigo_estado: % +v_id_estado_wf_ant: % ', v_id_tipo_estado, v_id_funcionario,v_id_usuario_reg,v_id_depto, v_codigo_estado, v_id_estado_wf_ant;

                    select
                        ew.id_proceso_wf
                    into
                        v_id_proceso_wf
                    from wf.testado_wf ew
                    where ew.id_estado_wf= v_id_estado_wf_ant;
                END IF;



                --configurar acceso directo para la alarma
                v_acceso_directo = '';
                v_clase = '';
                v_parametros_ad = '';
                v_tipo_noti = 'notificacion';
                v_titulo  = 'Visto Bueno';


                IF   v_codigo_estado_siguiente not in('borrador','pendiente_revision','pendiente_respuesta','derivado','anulado')   THEN
                    v_acceso_directo = '../../../sis_reclamo/vista/Reclamo/RegistroReclamos.php';
                    v_clase = 'RegistroReclamos';
                    v_parametros_ad = '{filtro_directo:{campo:"rec.id_proceso_wf",valor:"'||v_id_proceso_wf::varchar||'"}}';
                    v_tipo_noti = 'notificacion';
                    v_titulo  = 'Visto Bueno';

                END IF;


                -- registra nuevo estado

                v_id_estado_actual = wf.f_registra_estado_wf(
                        v_id_tipo_estado,                --  id_tipo_estado al que retrocede
                        v_id_funcionario,                --  funcionario del estado anterior
                        v_parametros.id_estado_wf,       --  estado actual ...
                        v_id_proceso_wf,                 --  id del proceso actual
                        p_id_usuario,                    -- usuario que registra
                        v_parametros._id_usuario_ai,
                        v_parametros._nombre_usuario_ai,
                        v_id_depto,                       --depto del estado anterior
                        '[RETROCESO] '|| v_parametros.obs,
                        v_acceso_directo,
                        v_clase,
                        v_parametros_ad,
                        v_tipo_noti,
                        v_titulo);

                IF  not rec.f_ant_estado_reclamo_wf(p_id_usuario,
                                                    v_parametros._id_usuario_ai,
                                                    v_parametros._nombre_usuario_ai,
                                                    v_id_estado_actual,
                                                    v_parametros.id_proceso_wf,
                                                    v_codigo_estado) THEN

                    raise exception 'Error al retroceder estado';

                END IF;


                -- si hay mas de un estado disponible  preguntamos al usuario
                v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Se realizo el cambio de estado)');
                v_resp = pxp.f_agrega_clave(v_resp,'operacion','cambio_exitoso');

                --Devuelve la respu	esta
                return v_resp;
            ELSE
                RAISE EXCEPTION 'Tiene respuestas pendientes en proceso para, %', v_reclamo.nro_tramite::varchar;
            END IF;
        end;

        /*********************************
         #TRANSACCION:  'REC_SIGEREC_IME'
         #DESCRIPCION:	Siguiente estado de un Reclamo
         #AUTOR:		admin
         #FECHA:		21-09-2016 11:32:59
        ***********************************/
    elseif(p_transaccion='REC_SIGEREC_IME') then
        begin

            /*   PARAMETROS
            $this->setParametro('id_proceso_wf_act','id_proceso_wf_act','int4');
            $this->setParametro('id_tipo_estado','id_tipo_estado','int4');
            $this->setParametro('id_funcionario_wf','id_funcionario_wf','int4');
            $this->setParametro('id_depto_wf','id_depto_wf','int4');
            $this->setParametro('obs','obs','text');
            $this->setParametro('json_procesos','json_procesos','text');
            */
            --recupera toda la tabla reclamos
            select recl.*
            into v_reclamo
            from rec.treclamo recl
            where id_proceso_wf = v_parametros.id_proceso_wf_act;

            select
                ew.id_tipo_estado ,
                te.pedir_obs,
                ew.id_estado_wf
            into
                v_id_tipo_estado,
                v_pedir_obs,
                v_id_estado_wf

            from wf.testado_wf ew
                     inner join wf.ttipo_estado te on te.id_tipo_estado = ew.id_tipo_estado
            where ew.id_estado_wf =  v_parametros.id_estado_wf_act;



            -- obtener datos tipo estado siguiente //codigo=borrador
            select te.codigo into
                v_codigo_estado_siguiente
            from wf.ttipo_estado te
            where te.id_tipo_estado = v_parametros.id_tipo_estado;


            IF  pxp.f_existe_parametro(p_tabla,'id_depto_wf') THEN
                v_id_depto = v_parametros.id_depto_wf;
            END IF;

            IF  pxp.f_existe_parametro(p_tabla,'obs') THEN
                v_obs = v_parametros.obs;
            ELSE
                v_obs='---';
            END IF;

            --configurar acceso directo para la alarma
            v_acceso_directo = '';
            v_clase = '';
            v_parametros_ad = '';
            v_tipo_noti = 'notificacion';
            v_titulo  = 'Visto Bueno';


            IF   v_codigo_estado_siguiente not in('borrador','pendiente_revision','registrado_ripat','pendiente_informacion','anulado')   THEN

                v_acceso_directo = '../../../sis_reclamo/vista/Reclamo/Reclamo.php';
                v_clase = 'Reclamo';
                v_parametros_ad = '{filtro_directo:{campo:"rec.id_proceso_wf",valor:"'||
                                  v_parametros.id_proceso_wf_act::varchar||'"}}';
                v_tipo_noti = 'notificacion';
                v_titulo  = 'Notificacion';
            END IF;
            --RAISE EXCEPTION 'v_id_depto: %, %',v_id_depto, v_parametros.id_funcionario_wf;
            -- hay que recuperar el supervidor que seria el estado inmediato...
            v_id_estado_actual =  wf.f_registra_estado_wf(v_parametros.id_tipo_estado,
                                                          v_parametros.id_funcionario_wf,
                                                          v_parametros.id_estado_wf_act,
                                                          v_parametros.id_proceso_wf_act,
                                                          p_id_usuario,
                                                          v_parametros._id_usuario_ai,
                                                          v_parametros._nombre_usuario_ai,
                                                          v_id_depto,
                                                          COALESCE(v_reclamo.nro_tramite,'--')||' Obs:'||v_obs,
                                                          v_acceso_directo ,
                                                          v_clase,
                                                          v_parametros_ad,
                                                          v_tipo_noti,
                                                          v_titulo);


            IF rec.f_procesar_estados_reclamo(p_id_usuario,
                                              v_parametros._id_usuario_ai,
                                              v_parametros._nombre_usuario_ai,
                                              v_id_estado_actual,
                                              v_parametros.id_proceso_wf_act,
                                              v_codigo_estado_siguiente,
                                              p_administrador) THEN

                RAISE NOTICE 'PASANDO DE ESTADO';

            END IF;


            --------------------------------------
            -- registra los procesos disparados
            --------------------------------------

            FOR v_registros_proc in ( select * from json_populate_recordset(null::wf.proceso_disparado_wf, v_parametros.json_procesos::json)) LOOP

                --get cdigo tipo proceso
                select
                    tp.codigo,
                    tp.codigo_llave
                into
                    v_codigo_tipo_pro,
                    v_codigo_llave
                from wf.ttipo_proceso tp
                where  tp.id_tipo_proceso =  v_registros_proc.id_tipo_proceso_pro;


                -- disparar creacion de procesos seleccionados

                SELECT
                    ps_id_proceso_wf,
                    ps_id_estado_wf,
                    ps_codigo_estado
                into
                    v_id_proceso_wf,
                    v_id_estado_wf,
                    v_codigo_estado
                FROM wf.f_registra_proceso_disparado_wf(
                             p_id_usuario,
                             v_parametros._id_usuario_ai,
                             v_parametros._nombre_usuario_ai,
                             v_id_estado_actual,
                             v_registros_proc.id_funcionario_wf_pro,
                             v_registros_proc.id_depto_wf_pro,
                             v_registros_proc.obs_pro,
                             v_codigo_tipo_pro,
                             v_codigo_tipo_pro);

            END LOOP;

            -- si hay mas de un estado disponible  preguntamos al usuario
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Se realizo el cambio de estado del Reclamo)');
            v_resp = pxp.f_agrega_clave(v_resp,'operacion','cambio_exitoso');
            v_resp = pxp.f_agrega_clave(v_resp,'v_codigo_estado_siguiente',v_codigo_estado_siguiente);

            -- Devuelve la respuesta
            return v_resp;
        end;

        /*********************************
       #TRANSACCION:  'REC_STADISTICA_GET'
        #DESCRIPCION:	Obtiene el numero de dias de respuesta
        #AUTOR:		Franklin Espinoza Alvarez
        #FECHA:		20-10-2016 10:01:08
       ***********************************/
    elsif(p_transaccion='REC_STADISTICA_GET')then

        begin

            /*IF()THEN

            ELSIF()THEN
            ELSIF()THEN
            ELSIF()THEN
            ELSIF()THEN
            ELSIF()THEN
            ELSIF()THEN
            END IF;*/

            /*SELECT tr.nro_tramite
            FROM rec.treclamo tr
            WHERE (tr.fecha_hora_recepcion::date BETWEEN date('01-04-2017') AND date('01-05-2017')) OR
            tr.id_gestion = '' OR tr.id_oficina_registro_incidente = 15*/
            --raise exception 'tipo % gestion % desde % hast % oficina %',v_parametros.p_tipo,v_parametros.id_gestion,v_parametros.p_desde, v_parametros.p_hasta, v_parametros.id_oficina;

            /*select p.fecha_fin, p.fecha_ini
            into v_fecha_hasta
            from param.tperiodo p
            where p.id_gestion = v_parametros.p_gestion::integer AND p.periodo = v_parametros.p_periodo::integer;


			FOR v_stadistica IN (SELECT * FROM rec.treclamo  WHERE fecha_hora_incidente::date BETWEEN v_fecha_hasta.fecha_ini AND v_fecha_hasta.fecha_fin) LOOP

            	IF (v_parametros.tipo='tipo_incidente')THEN

                	SELECT nombre_incidente INTO v_criterio
                    FROM rec.ttipo_incidente
                    WHERE id_tipo_incidente=v_stadistica.id_tipo_incidente;

                    IF (v_criterio='Pasaje/Boleto')THEN
                    	v_boleto = v_boleto + 1;
                    END IF;
                    IF (v_criterio='Vuelo')THEN
                    	v_vuelo=v_vuelo+1;
                    END IF;
                    IF (v_criterio='Equipaje')THEN
                    	v_equipaje=v_equipaje+1;
                    END IF;
                    IF (v_criterio='Carga/Encomienda')THEN
                    	v_carga=v_carga+1;
                    END IF;
                    IF (v_criterio='Catering')THEN
                    	v_catering=v_catering+1;
                    END IF;
                    IF (v_criterio='Atencion al Usuario')THEN
                    	v_sac=v_sac+1;
                    END IF;
                    IF (v_criterio='No Especifica')THEN
                    	v_otros=v_otros+1;
                    END IF;
                END IF;
                --CIUDAD
                IF (v_parametros.tipo='ciudad')THEN

                	SELECT DISTINCT ON (tl.codigo) tl.codigo INTO v_criterio
                    FROM param.tlugar tl
                    INNER JOIN rec.toficina tof ON tof.id_lugar = tl.id_lugar
                    INNER JOIN rec.treclamo tr ON tr.id_oficina_registro_incidente = tof.id_oficina
                    WHERE tr.id_oficina_registro_incidente=v_stadistica.id_oficina_registro_incidente;

                    IF (v_criterio='CBB')THEN
                    	v_cbb = v_cbb + 1;
                    END IF;
                    IF (v_criterio='LPB')THEN
                    	v_lpb = v_lpb + 1;
                    END IF;
                    IF (v_criterio='SRZ')THEN
                    	v_srz=v_srz + 1;
                    END IF;
                    IF (v_criterio='SRE')THEN
                    	v_sre=v_sre + 1;
                    END IF;
                    IF (v_criterio='TJA')THEN
                    	v_tja = v_tja + 1;
                    END IF;
                    IF (v_criterio='TDD')THEN
                    	v_tdd=v_tdd+1;
                    END IF;
                    IF (v_criterio='CIJ')THEN
                    	v_cij=v_cij+1;
                    END IF;
                    IF (v_criterio='POI')THEN
                    	v_poi=v_poi+1;
                    END IF;
                    IF (v_criterio='ORU')THEN
                    	v_oru=v_oru+1;
                    END IF;
                    IF (v_criterio='UYU')THEN
                    	v_uyu=v_uyu+1;
                    END IF;
                    IF (v_criterio='OTROS')THEN
                    	v_otros=v_otros+1;
                    END IF;
                    IF (v_criterio='VIRU VIRU')THEN
                    	v_viru=v_viru+1;
                    END IF;
                    IF (v_criterio='MAD')THEN
                    	v_mad=v_mad+1;
                    END IF;
                    IF (v_criterio='SAO')THEN
                    	v_sao=v_sao+1;
                    END IF;
                    IF (v_criterio='SLA')THEN
                    	v_sla=v_sla+1;
                    END IF;
                    IF (v_criterio='BUE')THEN
                    	v_bue=v_bue+1;
                    END IF;
                    IF (v_criterio='MIA')THEN
                    	v_mia=v_mia+1;
                    END IF;
                    IF (v_criterio='LIM')THEN
                    	v_lim=v_lim+1;
                    END IF;
                    IF (v_criterio='ACFT')THEN
                    	v_acft=v_acft+1;
                    END IF;
                END IF;



                IF v_parametros.tipo='lugar' THEN

                	SELECT  DISTINCT ON (tol.codigo) tol.codigo INTO v_criterio
                    FROM rec.toficina tol
                    INNER JOIN rec.treclamo tr ON tr.id_oficina_registro_incidente = tol.id_oficina
                    WHERE tr.id_oficina_registro_incidente=v_stadistica.id_oficina_registro_incidente;

            		IF v_criterio % 'ATO%' THEN
                    	 	v_ato = v_ato+1;
                	END IF;
                    IF v_criterio  % 'CTO%' /*OR v_criterio % 'OCC'*/  THEN
                         	v_cto = v_cto+1;
                    END IF;
                    IF v_criterio % 'OCC%' THEN
                         	v_cga = v_cga+1;
                    END IF;
                    IF v_criterio % 'CANALIZADO' THEN
            	 			v_canalizado = v_canalizado+1;
                    END IF;
                    IF v_criterio % 'WEB' THEN
            	 			v_web = v_web+1;
                    END IF;
                    IF v_criterio % 'CC' THEN
            	 			v_call = v_call+1;
                    END IF;
                    IF v_criterio % 'ATT' THEN
            	 			v_att = v_att+1;
                    END IF;

                    IF v_criterio % 'ACFT' THEN
                    	 	v_acft = v_acft+1;
                    END IF;

                END IF;

                --GENERO
                IF (v_parametros.tipo='genero')THEN
                  SELECT c.genero INTO v_criterio
                  FROM rec.tcliente c
                  WHERE c.id_cliente=v_stadistica.id_cliente;

                  IF v_criterio = 'VARON' THEN
                  	v_hombres = v_hombres+1;
                  ELSIF v_criterio = 'MUJER'THEN
                  	v_mujeres = v_mujeres+1;
                  ELSE
                  	v_noEspecifica = v_noEspecifica+1;
                  END IF;
                END IF;

                IF v_parametros.tipo='ambiente' THEN

                	SELECT  DISTINCT ON (tol.codigo) tol.codigo INTO v_criterio
                    FROM rec.toficina tol
                    INNER JOIN rec.treclamo tr ON tr.id_oficina_registro_incidente = tol.id_oficina
                    WHERE tr.id_oficina_incidente=v_stadistica.id_oficina_incidente;

            		IF v_criterio % 'ATO%' THEN
                    	 	v_ato = v_ato+1;
                	END IF;
                    IF v_criterio  % 'CTO%' /*OR v_criterio % 'OCC'*/  THEN
                         	v_cto = v_cto+1;
                    END IF;
                    IF v_criterio % 'OCC%' THEN
                         	v_cga = v_cga+1;
                    END IF;

                    IF v_criterio % 'CC' THEN
            	 			v_call = v_call+1;
                    END IF;

                    IF v_criterio % 'ACFT' THEN
                    	 	v_acft = v_acft+1;
                    END IF;

                    IF v_criterio % 'WEB' THEN
            	 			v_web = v_web+1;
                    END IF;
                END IF;

            	IF (v_parametros.tipo='estado')THEN
                	SELECT estado INTO v_criterio
                    FROM rec.treclamo
                    WHERE estado=v_stadistica.estado;

                    IF (v_criterio='borrador')THEN
                    	borrador = borrador + 1;
                    END IF;
                    IF (v_criterio='pendiente_revision')THEN
                    	pendiente_revision=pendiente_revision+1;
                    END IF;
                    IF (v_criterio='registrado_ripat')THEN
                    	registrado_ripat=registrado_ripat+1;
                    END IF;
                    IF (v_criterio='pendiente_informacion')THEN
                    	pendiente_informacion=pendiente_informacion+1;
                    END IF;
                    IF (v_criterio='anulado')THEN
                    	anulado=anulado+1;
                    END IF;
                    IF (v_criterio='derivado')THEN
                    	derivado=derivado+1;
                    END IF;
                    IF (v_criterio='pendiente_respuesta')THEN
                    	pendiente_respuesta=pendiente_respuesta+1;
                    END IF;
                    IF (v_criterio='archivo_con_respuesta')THEN
                    	archivo_con_respuesta=archivo_con_respuesta+1;
                    END IF;
                    IF (v_criterio='archivado_concluido')THEN
                    	archivado_concluido=archivado_concluido+1;
                    END IF;
                    IF (v_criterio='en_avenimiento')THEN
                    	en_avenimiento=en_avenimiento+1;
                    END IF;
                    IF (v_criterio='formulacion_cargos')THEN
                    	formulacion_cargos=formulacion_cargos+1;
                    END IF;
                    IF (v_criterio='resolucion_administrativa')THEN
                    	resolucion_administrativa=resolucion_administrativa+1;
                    END IF;
                    IF (v_criterio='recurso_revocatorio')THEN
                    	recurso_revocatorio=recurso_revocatorio+1;
                    END IF;
                    IF (v_criterio='recurso_jerarquico')THEN
                    	recurso_jerarquico=recurso_jerarquico+1;
                    END IF;
                    IF (v_criterio='contencioso_administrativo')THEN
                    	contencioso_administrativo=contencioso_administrativo+1;
                    END IF;
                    IF (v_criterio='pendiente_asignacion')THEN
                    	pendiente_asignacion=pendiente_asignacion+1;
                    END IF;
                    IF (v_criterio='respuesta_registro_ripat')THEN
                    	respuesta_registro_ripat=respuesta_registro_ripat+1;
                    END IF;
                END IF;
            END LOOP;

            --Definicion de la respuesta
            IF (v_parametros.tipo='tipo_incidente')THEN
            	v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Transaccion Exitosa');
            	v_resp = pxp.f_agrega_clave(v_resp,'v_boleto',v_boleto::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_vuelo',v_vuelo::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_equipaje',v_equipaje::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_carga',v_carga::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_catering',v_catering::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_sac',v_sac::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_otros',v_otros::varchar);
            END IF;

            IF (v_parametros.tipo='ciudad')THEN
            	v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Transaccion Exitosa');
                v_resp = pxp.f_agrega_clave(v_resp,'v_otros',v_otros::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_lim',v_lim::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_bue',v_bue::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_sla',v_sla::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_sao',v_sao::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_mad',v_mad::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_viru',v_viru::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_uyu',v_uyu::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_oru',v_oru::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_poi',v_poi::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_cij',v_cij::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_tdd',v_tdd::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_tja',v_tja::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_sre',v_sre::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_srz',v_srz::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_lpb',v_lpb::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_cbb',v_cbb::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_mia',v_mia::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_acft',v_acft::varchar);
            END IF;

            IF (v_parametros.tipo='lugar')THEN
            	v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Transaccion Exitosa');
                v_resp = pxp.f_agrega_clave(v_resp,'v_ato',v_ato::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_cto',v_cto::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_cga',v_cga::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_canalizado',v_canalizado::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_web',v_web::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_acft',v_acft::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_call',v_call::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_att',v_att::varchar);


            END IF;

            IF (v_parametros.tipo='genero')THEN
            	v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Transaccion Exitosa');
            	v_resp = pxp.f_agrega_clave(v_resp,'v_hombres',v_hombres::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_mujeres',v_mujeres::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_noEspecifica',v_noEspecifica::varchar);
            END IF;

            IF (v_parametros.tipo='ambiente')THEN
            	v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Transaccion Exitosa');
                v_resp = pxp.f_agrega_clave(v_resp,'v_ato',v_ato::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_cto',v_cto::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_cga',v_cga::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_call',v_call::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_acft',v_acft::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_web',v_web::varchar);
            END IF;

			IF (v_parametros.tipo='estado')THEN
            	v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Transaccion Exitosa');
            	v_resp = pxp.f_agrega_clave(v_resp,'borrador',borrador::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'pendiente_revision',pendiente_revision::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'registrado_ripat',registrado_ripat::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'pendiente_informacion',pendiente_informacion::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'anulado',anulado::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'derivado',derivado::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'pendiente_respuesta',pendiente_respuesta::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'archivo_con_respuesta',archivo_con_respuesta::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'archivado_concluido',archivado_concluido::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'en_avenimiento',en_avenimiento::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'formulacion_cargos',formulacion_cargos::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'resolucion_administrativa',resolucion_administrativa::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'recurso_revocatorio',recurso_revocatorio::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'recurso_jerarquico',recurso_jerarquico::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'contencioso_administrativo',contencioso_administrativo::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'pendiente_asignacion',pendiente_asignacion::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'respuesta_registro_ripat',respuesta_registro_ripat::varchar);
            END IF;*/

            /*IF (v_parametros.tipo='tipo_incidente')THEN
            	v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Transaccion Exitosa');
            	v_resp = pxp.f_agrega_clave(v_resp,'v_boleto',v_boleto::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_vuelo',v_vuelo::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_equipaje',v_equipaje::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_carga',v_carga::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_catering',v_catering::varchar);
            	v_resp = pxp.f_agrega_clave(v_resp,'v_sac',v_sac::varchar);
                v_resp = pxp.f_agrega_clave(v_resp,'v_otros',v_otros::varchar);
            END IF;*/

            --Devuelve la respuesta
            return v_resp;

        end;
    elseif (p_transaccion='REC_FUNNOM_GET')then
        begin

            select tf.desc_funcionario1 into v_nombre
            from orga.vfuncionario tf
            where tf.id_funcionario = v_parametros.id_funcionario;
            --raise exception 'fun:%',v_nombre;
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Nombre Funcionario');
            v_resp = pxp.f_agrega_clave(v_resp,'id_funcionario',v_nombre);


            --Devuelve la respuesta
            return v_resp;

        end;
    elseif (p_transaccion='REC_DATOFI_GET')then
        begin

            SELECT vfcl.id_oficina, vfcl.oficina_nombre, tf.id_funcionario, vfcl.desc_funcionario1, vfcl.nombre_cargo
            INTO v_record
            FROM segu.tusuario tu
                     INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
                     INNER JOIN orga.vfuncionario_cargo_lugar vfcl on vfcl.id_funcionario = tf.id_funcionario
            WHERE tu.id_usuario = p_id_usuario;

            SELECT tr.estado INTO v_estado_wf
            FROM rec.treclamo tr
            WHERE tr.id_estado_wf = v_parametros.id_usuario;

            SELECT g.id_gestion, g.gestion
            INTO v_record_gestion
            FROM param.tgestion g
            WHERE g.gestion = EXTRACT(YEAR FROM current_date);

            SELECT  tnf.numero
            INTO v_frd
            FROM rec.tnumero_frd tnf
            WHERE tnf.id_oficina = v_record.id_oficina;


            IF(v_frd = '' OR v_frd IS NULL)THEN
                v_frd = 1;
            END IF;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Datos de Oficina y Funcionario que registra Reclamos');
            v_resp = pxp.f_agrega_clave(v_resp,'id_oficina',v_record.id_oficina::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'oficina_nombre',v_record.oficina_nombre);
            v_resp = pxp.f_agrega_clave(v_resp,'id_funcionario',v_record.id_funcionario::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'desc_funcionario1',v_record.desc_funcionario1);
            v_resp = pxp.f_agrega_clave(v_resp,'nombre_cargo',v_record.nombre_cargo);
            v_resp = pxp.f_agrega_clave(v_resp,'estado',v_estado_wf);
            v_resp = pxp.f_agrega_clave(v_resp,'id_gestion',v_record_gestion.id_gestion::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'gestion',v_record_gestion.gestion::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'v_frd',v_frd::varchar);
            --Devuelve la respuesta de petición
            return v_resp;

        end;
    elsif (p_transaccion='REC_REV_IME')then

        begin

            select
                tr.revisado,
                tr.id_proceso_wf
            into
                v_registros_rec
            from rec.treclamo tr
            where tr.id_reclamo = v_parametros.id_reclamo;

            IF (v_registros_rec.revisado = 'si') THEN
                v_revisado = 'no';
            ELSE
                v_revisado = 'si';
            END IF;

            update rec.treclamo  tr set
                                        revisado = v_revisado,
                                        id_usuario_mod=p_id_usuario,
                                        fecha_mod=now(),
                                        id_usuario_ai = v_parametros._id_usuario_ai,
                                        usuario_ai = v_parametros._nombre_usuario_ai
            where tr.id_reclamo  = v_parametros.id_reclamo;

            --modifica el proeso wf para actulizar el mismo campo
            update wf.tproceso_wf  set
                revisado_asistente = v_revisado
            where id_proceso_wf  = v_registros_rec.id_proceso_wf;


            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','el reclamo fue marcado como revisado');
            v_resp = pxp.f_agrega_clave(v_resp,'id_reclamo',v_parametros.id_reclamo::varchar);

            --Devuelve la respuesta
            return v_resp;
        end;
        /*********************************
        #TRANSACCION:  'REC_FRD_GET'
         #DESCRIPCION:	Obtiene el numero frd de una oficina en especifico.
         #AUTOR:		Franklin Espinoza Alvarez
         #FECHA:		20-10-2016 10:01:08
        ***********************************/
    elseif (p_transaccion='REC_FRD_GET')then
        begin
            select g.id_gestion
            into v_gestion
            from param.tgestion g
            where g.gestion = EXTRACT(YEAR FROM current_date);

            v_frd = rec.f_get_numero_frd(v_parametros.oficina::integer,v_gestion,p_id_usuario);
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Numero FRD Generado');
            v_resp = pxp.f_agrega_clave(v_resp,'v_frd',v_frd);


            --Devuelve la respuesta
            return v_resp;

        end;
    elsif(p_transaccion='REC_REST_SEL')then

        BEGIN
            SELECT
                count(trr.id_respuesta)
            INTO v_contador
            FROM rec.treclamo tr
                     INNER JOIN rec.trespuesta trr ON trr.id_reclamo = tr.id_reclamo
            WHERE tr.id_reclamo = v_parametros.id_reclamo;

            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Numero de Respuestas de un Reclamo');
            v_resp = pxp.f_agrega_clave(v_resp,'v_contador',v_contador::varchar);

            --Devuelve la respuesta
            return v_resp;
        END;
        /*********************************
        #TRANSACCION:  'REC_VALIDAR_GET'
        #DESCRIPCION:	VERIFICA LA DUPLICIDAD DE RECLAMOS
        #AUTOR:		Franklin Espinoza
        #FECHA:		18-04-2017 14:58:16
        ***********************************/
    elsif(p_transaccion='REC_VALIDAR_GET')then

        BEGIN
            --RAISE EXCEPTION 'v_parametros.oficina %',v_parametros.oficina;
            select g.id_gestion
            into v_gestion
            from param.tgestion g
            where g.gestion = EXTRACT(YEAR FROM current_date);

            --encontramos la lista de frd faltantes
            --begin
            create temp table tnro_frds(
                nro_frd numeric
            )on commit drop;

            insert into tnro_frds(
                SELECT to_number(tr.nro_frd,'9999999')
                FROM rec.treclamo tr
                         INNER JOIN rec.toficina tof ON tof.id_oficina = tr.id_oficina_registro_incidente
                WHERE tr.id_oficina_registro_incidente = v_parametros.oficina and tr.id_gestion = v_gestion
            );
            SELECT max(nro_frd),min(nro_frd),count(nro_frd)
            INTO v_max, v_min, v_cont
            FROM tnro_frds ;

            IF (v_cont >= 1) THEN
                v_cont = 1;
                FOR v_index IN (SELECT nro_frd FROM tnro_frds)LOOP
                    v_frds[v_cont] = v_index;
                    v_cont = v_cont + 1;
                END LOOP;

                v_cont = 1;
                FOR v_index IN 1..v_max LOOP
                    IF v_index = ANY (v_frds) THEN

                    ELSE
                        v_frds_aux[v_cont] = v_index;
                        IF(v_cont::integer % 10 = 0)THEN
                            v_frd_faltantes[v_cont] = v_index::varchar||'<br>';
                        ELSE
                            v_frd_faltantes[v_cont] = v_index;
                        END IF;
                        v_cont = v_cont + 1;
                    END IF;
                END LOOP;
                v_cad_frds = case when array_length(v_frd_faltantes, 1) >= 1 then array_to_string(v_frd_faltantes,',') else '' end;

                IF NOT(v_parametros.frd % '0/%') THEN
                    IF (v_parametros.frd = ANY(SELECT ltrim(tr.nro_frd,'0')
                                               FROM rec.treclamo tr
                                                        INNER JOIN rec.toficina tof ON tof.id_oficina = tr.id_oficina_registro_incidente
                                               WHERE tr.id_oficina_registro_incidente = v_parametros.oficina and tr.id_gestion = v_gestion))THEN
                        v_band_frds = 'duplicado';
                    ELSIF (v_parametros.frd <> ALL(SELECT ltrim(tr.nro_frd,'0')
                                                   FROM rec.treclamo tr
                                                            INNER JOIN rec.toficina tof ON tof.id_oficina = tr.id_oficina_registro_incidente
                                                   WHERE tr.id_oficina_registro_incidente = v_parametros.oficina and tr.id_gestion = v_gestion))THEN
                        v_band_frds = 'nuevo';
                    END IF;

                    IF (v_band_frds = 'nuevo' AND to_number(v_parametros.frd,'9999999')::integer > rec.f_procesar_frds(v_parametros.oficina,'0','FRD_MAX')::INTEGER + 1)THEN
                        v_band_frds = 'mayor';
                    END IF;
                ELSE
                    v_band_frds = 'nuevo';
                END IF;
                --end
            ELSE
                v_band_frds = 'nuevo';
            END IF;
            --validar reclamo
            select count(tr.id_reclamo)
            INTO v_contador
            from rec.treclamo tr
            where (tr.correlativo_preimpreso_frd = trim(both ' ' from v_parametros.correlativo)::integer AND tr.nro_frd = trim(both ' ' from v_parametros.frd)) AND tr.id_oficina_registro_incidente = v_parametros.oficina::integer AND tr.id_gestion = v_gestion;
            IF(v_contador>=1)THEN
                v_valid = 'true';
            ELSE
                v_valid = 'false';
            END IF;
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Existe el Reclamo');
            v_resp = pxp.f_agrega_clave(v_resp,'v_valid',v_valid);
            v_resp = pxp.f_agrega_clave(v_resp,'v_cad_frds',v_cad_frds);
            v_resp = pxp.f_agrega_clave(v_resp,'v_band_frds',v_band_frds::varchar);
            --Devuelve la respuesta
            return v_resp;
        END;
        /*********************************
       #TRANSACCION:  'REC_LOG_FAL_IME'
        #DESCRIPCION:	Registro de faltas.
        #AUTOR:		Franklin Espinoza Alvarez
        #FECHA:		16-6-2017 10:01:08
       ***********************************/
    elseif (p_transaccion='REC_LOG_FAL_IME')then
        begin

            --Sentencia de la insercion
            insert into rec.tlogs_reclamo(
                descripcion,
                id_reclamo,
                id_funcionario,
                estado_reg,
                fecha_reg,
                usuario_ai,
                id_usuario_reg,
                id_usuario_ai,
                id_usuario_mod,
                fecha_mod
            ) values(
                        v_parametros.descripcion,
                        v_parametros.id_reclamo,
                        v_parametros.id_funcionario,
                        'activo',
                        now(),
                        v_parametros._nombre_usuario_ai,
                        p_id_usuario,
                        v_parametros._id_usuario_ai,
                        null,
                        null
                    )RETURNING id_logs_reclamo into v_id_logs_reclamo;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Registro de Logs de Faltas Exitoso');
            v_resp = pxp.f_agrega_clave(v_resp,'id_logs_reclamo	',v_id_logs_reclamo::varchar);


            --Devuelve la respuesta
            return v_resp;

        end;
        /*********************************
        #TRANSACCION:  'REC_ARCH_CONCL'
        #DESCRIPCION:	ENVIA LOS RECLAMOS DES ESTADO respuesta_registrado_rippat a archivado_concluido
        #AUTOR:		Franklin Espinoza
        #FECHA:		01-02-2017 14:58:16
        ***********************************/
    elsif(p_transaccion='REC_ARCH_CONCL')then
        BEGIN
            --Procesamos todos los reclamos que tiene estado respuesta_registrado_ripat
            v_acceso_directo = '';
            v_clase = '';
            v_parametros_ad = '';
            v_tipo_noti = 'notificacion';
            v_titulo  = 'Archivo Concluido';

            IF ((SELECT count(*) FROM rec.treclamo r WHERE  r.estado = 'respuesta_registrado_ripat')>0)THEN

                FOR	v_record IN
                    SELECT r.*
                    FROM rec.treclamo r
                    WHERE  r.estado = 'respuesta_registrado_ripat' LOOP

                    SELECT tr.fecha_mod INTO v_fecha
                    FROM rec.trespuesta tr
                    WHERE tr.tipo_respuesta='respuesta_final' AND tr.id_reclamo=v_record.id_reclamo;

                    IF (rec.f_dias_respuesta(now()::date, v_fecha,'CONT_DIAS')>=15) THEN

                        SELECT 	te.id_funcionario
                        INTO v_id_funcionario
                        FROM wf.testado_wf te
                        WHERE te.id_estado_wf=v_record.id_estado_wf;

                        --id tipo_estado
                        SELECT te.id_tipo_estado
                        INTO v_codigo_estado
                        FROM wf.ttipo_estado te
                        WHERE te.codigo = 'archivado_concluido';

                        SELECT tu.id_usuario INTO v_id_usuario
                        FROM wf.testado_wf te
                                 inner join orga.tfuncionario tf on tf.id_funcionario = te.id_funcionario
                                 inner join segu.tpersona tp on tp.id_persona = tf.id_persona
                                 inner join segu.tusuario tu on tu.id_persona = tp.id_persona
                        WHERE te.id_estado_wf=v_record.id_estado_wf;
                        v_id_estado_actual =  wf.f_registra_estado_wf(
                                v_codigo_estado,
                                v_id_funcionario,
                                v_record.id_estado_wf,
                                v_record.id_proceso_wf,
                                v_id_usuario,
                                v_record.id_usuario_ai,
                                v_record.usuario_ai,
                                NULL,
                                COALESCE(v_record.nro_tramite,'--')||' Obs:'||'ARCHIVADO DESPUES DE 15 DIAS',
                                v_acceso_directo,
                                v_clase,
                                v_parametros_ad,
                                v_tipo_noti,
                                v_titulo);

                        update rec.treclamo r set
                                                  revisado = 'concluido',
                                                  id_estado_wf =  v_id_estado_actual,
                                                  estado = 'archivado_concluido',
                                                  id_usuario_mod=v_id_usuario,
                                                  id_usuario_ai = v_record.id_usuario_ai,
                                                  usuario_ai = v_record.usuario_ai,
                                                  fecha_mod=now()
                        where id_proceso_wf = v_record.id_proceso_wf;

                    END IF;
                END LOOP;
            END IF;
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Transacción Exitosa, se cambio a estado archivado_concluido');
            --Devuelve la respuesta
            return v_resp;
        END;
        /*********************************
        #TRANSACCION:  'REC_INSERT_ROLE'
         #DESCRIPCION:	Registro de faltas.
         #AUTOR:		Franklin Espinoza Alvarez
         #FECHA:		16-1-2023 10:01:08
        ***********************************/
    elseif (p_transaccion='REC_INSERT_ROLE') then
        begin

            --Sentencia de la insercion
            insert into rec.trol(
                estado_reg,
                fecha_reg,
                usuario_ai,
                id_usuario_reg,
                id_usuario_ai,
                id_usuario_mod,
                fecha_mod,
                json_rol
            ) values(
                        'activo',
                        now(),
                        v_parametros._nombre_usuario_ai,
                        p_id_usuario,
                        v_parametros._id_usuario_ai,
                        null,
                        null,
                        v_parametros.rol::jsonb
                    )RETURNING id_rol into v_id_rol;

            update rec.trol set
                json_rol = json_rol || ('{"id_rol":'||v_id_rol||'}')::jsonb
            where id_rol = v_id_rol;
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Registro de Rol Exitoso');
            v_resp = pxp.f_agrega_clave(v_resp,'v_mensaje','Registro de Rol Exitoso');
            v_resp = pxp.f_agrega_clave(v_resp,'v_id_rol	',v_id_rol::varchar);


            --Devuelve la respuesta
            return v_resp;

        end;
        /*********************************
     #TRANSACCION:  'REC_UPDATE_ROLE'
      #DESCRIPCION:	Actualizacion de rol.
      #AUTOR:		Franklin Espinoza Alvarez
      #FECHA:		16-1-2023 10:01:08
     ***********************************/
    elseif (p_transaccion='REC_UPDATE_ROLE')then
        begin
            --Sentencia de la insercion
            update rec.trol set
                json_rol = v_parametros.rol::jsonb
            where id_rol = v_parametros.id_rol;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Actualización de Rol Exitoso');
            v_resp = pxp.f_agrega_clave(v_resp,'v_mensaje','Actualización de Rol Exitoso');
            v_resp = pxp.f_agrega_clave(v_resp,'v_id_rol	',v_parametros.id_rol::varchar);
            --Devuelve la respuesta
            return v_resp;

        end;

        /*********************************
     #TRANSACCION:  'REC_DELETE_ROLE'
      #DESCRIPCION:	Eliminación de rol.
      #AUTOR:		Franklin Espinoza Alvarez
      #FECHA:		16-1-2023 10:01:08
     ***********************************/
    elseif (p_transaccion='REC_DELETE_ROLE')then
        begin

            /*delete from rec.treclamo
            where id_reclamo=v_parametros.id_reclamo;*/

            update rec.trol set
                estado_reg = 'inactivo'
            where id_rol = v_parametros.id_rol;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Eliminación de Rol Exitoso');
            v_resp = pxp.f_agrega_clave(v_resp,'v_mensaje','Eliminación de Rol Exitoso');
            v_resp = pxp.f_agrega_clave(v_resp,'v_id_rol	',v_parametros.id_rol::varchar);
            --Devuelve la respuesta
            return v_resp;
        end;

    else

        raise exception 'Transaccion inexistente: %',p_transaccion;

    end if;

EXCEPTION

    WHEN OTHERS THEN
        v_resp='';
        v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
        v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
        v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
        raise exception '%',v_resp;

END;
$body$
    LANGUAGE 'plpgsql'
    VOLATILE
    CALLED ON NULL INPUT
    SECURITY INVOKER
    COST 100;

ALTER FUNCTION rec.ft_reclamo_ime (p_administrador integer, p_id_usuario integer, p_tabla varchar, p_transaccion varchar)
    OWNER TO postgres;