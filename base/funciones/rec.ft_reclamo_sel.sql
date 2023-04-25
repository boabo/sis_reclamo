CREATE OR REPLACE FUNCTION rec.ft_reclamo_sel (
    p_administrador integer,
    p_id_usuario integer,
    p_tabla varchar,
    p_transaccion varchar
)
    RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Reclamos
 FUNCION: 		rec.ft_reclamo_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'rec.treclamo'
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

    v_consulta    		varchar;
    v_parametros  		record;
    v_nombre_funcion   	text;
    v_resp				varchar;
    v_filtro			varchar;
    v_id_oficina		integer;

    v_dias_respuesta  	varchar;
    v_record 			record;

    v_id_usuario_rev	record;
    v_id_usuario_pen	integer;

    va_id_depto 		integer[];
    v_gestion			integer;

    --Modifica las alarmas que fallaron
    v_ids_alarma		INTEGER[];
    v_index				integer = 1;
    v_nro_tramites		varchar[];
    v_titulo_correo		varchar[];
    v_correo			varchar[];
    v_fecha_reg			TIMESTAMP[];
    v_cadena			varchar;
    v_cont				integer;

    --reportes de frds fatantes
    v_max				integer;
    v_min				integer;
    v_frd_faltantes		integer[];
    v_frds				integer[];

    v_id_procesos       varchar;
    v_id_funcionario    integer;

BEGIN

    v_nombre_funcion = 'rec.ft_reclamo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'REC_REC_SEL'
     #DESCRIPCION:	Consulta de datos
     #AUTOR:		admin
     #FECHA:		10-08-2016 18:32:59
    ***********************************/
    if(p_transaccion='REC_REC_SEL')then

        begin

            --SELECT
            --CRITERIOS DE FILTRADO
            SELECT vfcl.id_oficina, vfcl.nombre_cargo,  vfcl.oficina_nombre,
                   tf.id_funcionario, vfcl.desc_funcionario1 INTO v_record
            FROM segu.tusuario tu
                     INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
                     INNER JOIN orga.vfuncionario_cargo_lugar vfcl on vfcl.id_funcionario = tf.id_funcionario
            WHERE tu.id_usuario = p_id_usuario ;


            IF (p_administrador=1 OR v_parametros.tipo_interfaz='ConsultaReclamo' OR v_parametros.tipo_interfaz='filtros') THEN
                v_filtro= '0 = 0 AND ';
            ELSE
                IF (v_parametros.tipo_interfaz='RevisionReclamo')THEN

                    SELECT tu.id_usuario, count(tu.id_usuario)::varchar as cant_reg
                    INTO v_id_usuario_rev
                    FROM segu.tusuario tu
                             INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
                    WHERE tf.id_funcionario = (SELECT tew.id_funcionario
                                               FROM wf.testado_wf tew
                                                        LEFT JOIN wf.testado_wf te ON te.id_estado_anterior = tew.id_estado_wf
                                                        LEFT JOIN rec.treclamo  tr ON tr.id_estado_wf = te.id_estado_wf
                                               WHERE tr.estado =  'pendiente_revision' LIMIT 1)
                    GROUP BY tu.id_usuario;

                    select
                        pxp.aggarray(depu.id_depto)
                    into
                        va_id_depto
                    from param.tdepto_usuario depu
                    where depu.id_usuario =  p_id_usuario;

                    IF(v_id_usuario_rev.cant_reg IS NULL)THEN
                        v_filtro = 'tew.id_funcionario = '||v_record.id_funcionario||' AND rec.estado_reg <> ''inactivo'' AND ';
                    ELSE
                        v_filtro = '( rec.id_usuario_mod = '||p_id_usuario||' OR tew.id_depto in ('|| COALESCE(array_to_string(va_id_depto,','),'0')||') OR tew.id_funcionario = '||v_record.id_funcionario||') AND rec.estado_reg <> ''inactivo'' AND ';
                    END IF;

                    --v_filtro = '(tew.id_funcionario = '||v_record.id_funcionario||' OR rec.id_usuario_mod = '|| p_id_usuario||') AND rec.estado_reg <> ''inactivo'' AND ';

                ELSIF (v_parametros.tipo_interfaz::varchar = 'PendienteRespuesta' OR v_parametros.tipo_interfaz='ReclamoAdministrativo')THEN
                    --Consulta que muestra el id_usuario del anterior estado
                    SELECT tu.id_usuario, count(tu.id_usuario)::varchar as cant_reg
                    INTO v_id_usuario_rev
                    FROM segu.tusuario tu
                             INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
                    WHERE tf.id_funcionario = (SELECT tew.id_funcionario
                                               FROM wf.testado_wf tew
                                                        LEFT JOIN wf.testado_wf te ON te.id_estado_anterior = tew.id_estado_wf
                                                        LEFT JOIN rec.treclamo  tr ON tr.id_estado_wf = te.id_estado_wf
                                               WHERE tr.estado =  'pendiente_asignacion' LIMIT 1)
                    GROUP BY tu.id_usuario;

                    select
                        pxp.aggarray(depu.id_depto)
                    into
                        va_id_depto
                    from param.tdepto_usuario depu
                    where depu.id_usuario =  p_id_usuario;

                    IF(v_id_usuario_rev.cant_reg IS NULL)THEN
                        v_filtro = 'tew.id_funcionario = '||v_record.id_funcionario||' AND rec.estado_reg <> ''inactivo'' AND ';
                    ELSE
                        v_filtro = '( rec.id_usuario_mod = '||p_id_usuario||' OR tew.id_depto in ('|| COALESCE(array_to_string(va_id_depto,','),'0')||') OR tew.id_funcionario = '||v_record.id_funcionario||') AND rec.estado_reg <> ''inactivo'' AND ';
                    END IF;

                    if(v_record.id_funcionario = 152)then
                        v_filtro= '0 = 0 AND ';
                    end if;
                    --END IF;
                ELSIF v_parametros.tipo_interfaz='RegistroReclamos' THEN
                    v_filtro = '(rec.id_usuario_reg = '||p_id_usuario||
                               ' OR rec.id_oficina_registro_incidente = '||v_record.id_oficina||') AND ';
                    /*ELSE
                        v_filtro= '0 = 0 AND ';
                    END IF;*/
                ELSIF v_parametros.tipo_interfaz='RegistroReclamoAnulado' THEN
                    v_filtro = '(rec.id_usuario_reg = '||p_id_usuario||
                               ' OR rec.id_oficina_registro_incidente = '||v_record.id_oficina||') AND ';
                ELSE
                    v_filtro= '0 = 0 AND ';
                END IF;
            END IF;

            --Sentencia de la consulta
            v_consulta:='select
						rec.id_reclamo,
						rec.id_tipo_incidente,
						rec.id_subtipo_incidente,
						rec.id_medio_reclamo,
						rec.id_funcionario_recepcion,
						rec.id_funcionario_denunciado,
						rec.id_oficina_incidente,
						rec.id_oficina_registro_incidente,
						rec.id_proceso_wf,
						rec.id_estado_wf,
						rec.id_cliente,
						rec.estado,
						rec.fecha_hora_incidente,
						rec.nro_ripat_att,
						rec.nro_hoja_ruta,
						rec.fecha_hora_recepcion,
						rec.estado_reg,
						rec.fecha_hora_vuelo,
						rec.origen,
						rec.nro_frd,
                        rec.correlativo_preimpreso_frd,
                        rec.fecha_limite_respuesta,
						rec.observaciones_incidente,
						rec.destino,
						rec.nro_pir,
						rec.nro_frsa,
						rec.nro_att_canalizado,
						rec.nro_tramite,
						rec.detalle_incidente,
						rec.pnr,
						rec.nro_vuelo,
						rec.id_usuario_reg,
						rec.fecha_reg,
						rec.usuario_ai,
						rec.id_usuario_ai,
						rec.fecha_mod,
						rec.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        	rec.id_gestion,
                            rec.id_motivo_anulado,
                        med.nombre_medio as desc_nombre_medio,
                        	c.nombre_completo2 as desc_nom_cliente,
                        tip.nombre_incidente as desc_nombre_incidente,
                        of.nombre as desc_nombre_oficina,
                        ofi.nombre as desc_oficina_registro_incidente,
                        t.nombre_incidente as desc_sudnom_incidente,
                        fun.desc_funcionario1 as desc_nombre_funcionario,
                        fu.desc_funcionario1 as desc_nombre_fun_denun,
                        	tip.tiempo_respuesta,
                            rec.revisado,
                            rec.transito,
                            --rec.f_dias_respuesta(now()::date, rec.fecha_limite_respuesta, ''DIAS_RESP'')::varchar as dias_respuesta,
                            rec.f_verificar_dias(CURRENT_DATE, rec.fecha_limite_respuesta)::varchar as dias_respuesta,
                            --7::varchar as dias_respuesta,
                            rec.f_dias_respuesta(now()::date, rec.fecha_hora_recepcion::date, ''DIAS_INF'')::varchar as dias_informe,
                            ma.motivo as motivo_anulado,
                            res.nro_cite,
                            infor.conclusion_recomendacion ,
							res.recomendaciones,
                            c.genero,
                            c.ci,
                            c.telefono,
                            c.email,
                            cli.email2,
                            c.ciudad_residencia,
                            rec.nro_guia_aerea,

                            c.nombre_completo2 as desc_nom_cliente,
							'||p_administrador||'::integer AS administrador,
							tri.id_informe
						from rec.treclamo rec
						inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod

                        INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                        LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
                        inner join rec.tcliente cli on c.id_cliente = cli.id_cliente
                        INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                        left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                        left join param.tlugar lug ON lug.id_lugar = of.id_lugar
                      	INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                        LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
                        inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
                        inner join orga.vfuncionario fun on fun.id_funcionario = rec.id_funcionario_recepcion
                        left join orga.vfuncionario fu on fu.id_funcionario = rec.id_funcionario_denunciado
                        	INNER join param.tgestion gest on gest.id_gestion = rec.id_gestion
                            left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado
                            LEFT join wf.testado_wf tew on tew.id_estado_wf = rec.id_estado_wf

                            LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo --and res.tipo_respuesta = ''respuesta_final''
							LEFT JOIN rec.tinforme infor ON infor.id_reclamo =  rec.id_reclamo
                            LEFT JOIN rec.treclamo_informe tri ON tri.id_reclamo = rec.id_reclamo

				        where rec.estado_reg !=''inactivo'' and '||v_filtro;

            --raise exception 'ordenacion: %',v_consulta;
            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            --Devuelve la respuesta
            raise notice 'que esta pasando: %',v_consulta;

            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_REC_CONT'
         #DESCRIPCION:	Conteo de registros
         #AUTOR:		admin
         #FECHA:		10-08-2016 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_REC_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(rec.id_reclamo)
			   			from rec.treclamo rec
						inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod

                        INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                        LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
                        inner join rec.tcliente cli on c.id_cliente = cli.id_cliente
                        INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                        left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                        left join param.tlugar lug ON lug.id_lugar = of.id_lugar
                      	INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                        LEFT join param.tlugar tlug ON tlug.id_lugar = of.id_lugar
                        inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
                        inner join orga.vfuncionario fun on fun.id_funcionario = rec.id_funcionario_recepcion
                        left join orga.vfuncionario fu on fu.id_funcionario = rec.id_funcionario_denunciado
                        	INNER join param.tgestion gest on gest.id_gestion = rec.id_gestion
                            left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado
                            LEFT join wf.testado_wf tew on tew.id_estado_wf = rec.id_estado_wf

                            LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo --and res.tipo_respuesta = ''respuesta_final''
							LEFT JOIN rec.tinforme infor ON infor.id_reclamo =  rec.id_reclamo
                            LEFT JOIN rec.treclamo_informe tri ON tri.id_reclamo = rec.id_reclamo
					    where rec.estado_reg !=''inactivo'' and ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_CRMG_SEL'
         #DESCRIPCION:	Consulta de RMCGlobal
         #AUTOR:		admin
         #FECHA:		05-10-2016 12:00:59
        ***********************************/
    elsif(p_transaccion='REC_CRMG_SEL')then

        begin
            --SELECT
            --Sentencia de la consulta
            v_consulta:='select distinct on (rec.id_reclamo)
						rec.id_reclamo,
						rec.id_tipo_incidente,
						rec.id_subtipo_incidente,
						rec.id_medio_reclamo,
						rec.id_funcionario_recepcion,
						rec.id_funcionario_denunciado,
						rec.id_oficina_incidente,
						rec.id_oficina_registro_incidente,
						rec.id_proceso_wf,
						rec.id_estado_wf,
						rec.id_cliente,
						rec.estado,
						rec.fecha_hora_incidente,
						rec.nro_ripat_att,
						rec.nro_hoja_ruta,
						rec.fecha_hora_recepcion,
						rec.estado_reg,
						rec.fecha_hora_vuelo,
						rec.origen,
						rec.nro_frd,
                        rec.correlativo_preimpreso_frd,
                        rec.fecha_limite_respuesta,
						rec.observaciones_incidente,
						rec.destino,
						rec.nro_pir,
						rec.nro_frsa,
						rec.nro_att_canalizado,
						rec.nro_tramite,
						rec.detalle_incidente,
						rec.pnr,
						rec.nro_vuelo,
						rec.id_usuario_reg,
						to_char(rec.fecha_reg, ''DD/MM/YYYY HH24:MI:SS'')::timestamp as fecha_reg,
						rec.usuario_ai,
						rec.id_usuario_ai,
						rec.fecha_mod,
						rec.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        	rec.id_gestion,
                            rec.id_motivo_anulado,
                        med.nombre_medio as desc_nombre_medio,
                        	c.nombre_completo2 as desc_nom_cliente,
                        tip.nombre_incidente as desc_nombre_incidente,
                        of.nombre as desc_nombre_oficina,
                        ofi.nombre as desc_oficina_registro_incidente,
                        t.nombre_incidente as desc_sudnom_incidente,
                        fun.desc_funcionario1 as desc_nombre_funcionario,
                        fu.desc_funcionario1 as desc_nombre_fun_denun,
                        	tip.tiempo_respuesta,
                            rec.revisado,
                            rec.transito,
                            rec.f_dias_respuesta(now()::date, rec.fecha_limite_respuesta, ''DIAS_RESP'')::varchar as dias_respuesta,
                            rec.f_dias_respuesta(now()::date, rec.fecha_hora_recepcion::date, ''DIAS_INF'')::varchar as dias_informe,
                            ma.motivo as motivo_anulado,
                            res.nro_cite,
                            infor.conclusion_recomendacion ,
							res.recomendaciones,
                            c.genero,
                            c.ci,
                            c.telefono,
                            c.email,
                            c.ciudad_residencia,
                            rec.nro_guia_aerea,
                            fun.nombre_cargo,
                            to_char(coalesce(tw.fecha_reg, tew.fecha_reg), ''DD/MM/YYYY HH24:MI:SS'')::timestamp as ult_fecha,
                            coalesce(tp.nombre_estado, tpw.nombre_estado) as ult_estado,
                            case when rec.estado != ''anulado'' then
                                case when coalesce(tw.fecha_reg::date, tew.fecha_reg::date) = rec.fecha_reg::date then
                                      ''''::varchar
                                 else
                                      case when (rec.f_verificar_dias(rec.fecha_reg::date, coalesce(tw.fecha_reg::date, tew.fecha_reg::date))*24)<10 then
                                          (rec.f_verificar_dias(rec.fecha_reg::date, coalesce(tw.fecha_reg::date, tew.fecha_reg::date)) * 24)||'' Hora''::varchar
                                      else
                                          (rec.f_verificar_dias(rec.fecha_reg::date, coalesce(tw.fecha_reg::date, tew.fecha_reg::date)) * 24)||'' Horas''::varchar
                                      end
                                end
                            else
                            	''''::varchar
                            end as  tiempo_resolucion_rec
						from rec.treclamo rec
						inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod
						left join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                        inner join rec.vcliente c on c.id_cliente = rec.id_cliente
                        inner join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                        left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                      	inner join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                        inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
                        left join orga.vfuncionario_cargo_lugar fun on fun.id_funcionario = rec.id_funcionario_recepcion
                        left join orga.vfuncionario_cargo_lugar fu on fu.id_funcionario = rec.id_funcionario_denunciado
                        left join param.tgestion gest on gest.id_gestion = rec.id_gestion
                        left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado
                        left join wf.testado_wf tew on tew.id_estado_wf = rec.id_estado_wf
                        left join wf.ttipo_estado tpw on tpw.id_tipo_estado = tew.id_tipo_estado

                        --{dev:bvasquez, date: 10/08/2021, desc:recuperar datos del fluoj}
                        left join wf.tproceso_wf pw on pw.nro_tramite = rec.nro_tramite and pw.id_estado_wf_prev is not null
                        left join wf.testado_wf tw on tw.id_proceso_wf = pw.id_proceso_wf and tw.estado_reg = ''activo''
                        left join wf.ttipo_estado tp on tp.id_tipo_estado = tw.id_tipo_estado

                        LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo
						LEFT JOIN rec.tinforme infor ON infor.id_reclamo =  rec.id_reclamo
				        WHERE rec.estado_reg != ''inactivo'' and ';
            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by id_reclamo, ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            raise notice 'v_consulta: %',v_consulta;
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_CRMG_CONT'
         #DESCRIPCION:	Conteo de registros
         #AUTOR:		admin
         #FECHA:		10-08-2016 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_CRMG_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(distinct rec.id_reclamo)
			   			from rec.treclamo rec
						inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod
						left join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                        inner join rec.vcliente c on c.id_cliente = rec.id_cliente
                        inner join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                        left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                      	inner join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                        inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
                        left join orga.vfuncionario_cargo_lugar fun on fun.id_funcionario = rec.id_funcionario_recepcion
                        left join orga.vfuncionario_cargo_lugar fu on fu.id_funcionario = rec.id_funcionario_denunciado
                        left join param.tgestion gest on gest.id_gestion = rec.id_gestion
                        left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado
                        left join wf.testado_wf tew on tew.id_estado_wf = rec.id_estado_wf
                        left join wf.ttipo_estado tpw on tpw.id_tipo_estado = tew.id_tipo_estado

                        --{dev:bvasquez, date: 10/08/2021, desc:recuperar datos del fluoj}
                        left join wf.tproceso_wf pw on pw.nro_tramite = rec.nro_tramite and pw.id_estado_wf_prev is not null
                        left join wf.testado_wf tw on tw.id_proceso_wf = pw.id_proceso_wf and tw.estado_reg = ''activo''
                        left join wf.ttipo_estado tp on tp.id_tipo_estado = tw.id_tipo_estado

                        LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo
						LEFT JOIN rec.tinforme infor ON infor.id_reclamo =  rec.id_reclamo
					    where rec.estado_reg != ''inactivo'' and ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            --raise notice 'v_consulta: %',v_consulta;
            --Devuelve la respuesta
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_CONSULTA_SEL'
         #DESCRIPCION:	Consulta PARA LA VISTA CONSULTA RECLAMO
         #AUTOR:		admin
         #FECHA:		01-02-2017 12:00:59
        ***********************************/

    elsif(p_transaccion='REC_CONSULTA_SEL')then

        begin

            --Sentencia de la consulta
            v_consulta:='select
							rec.id_reclamo,
							rec.id_tipo_incidente,
							rec.id_subtipo_incidente,
							rec.id_medio_reclamo,
							rec.id_funcionario_recepcion,
							rec.id_funcionario_denunciado,
							rec.id_oficina_incidente,
							rec.id_oficina_registro_incidente,
							rec.id_proceso_wf,
							rec.id_estado_wf,
							rec.id_cliente,
							rec.estado,
							rec.fecha_hora_incidente,
							rec.nro_ripat_att,
							rec.nro_hoja_ruta,
							rec.fecha_hora_recepcion,
							rec.estado_reg,
							rec.fecha_hora_vuelo,
							rec.origen,
							rec.nro_frd,
        					rec.correlativo_preimpreso_frd,
        					rec.fecha_limite_respuesta,
							rec.observaciones_incidente,
							rec.destino,
							rec.nro_pir,
							rec.nro_frsa,
							rec.nro_att_canalizado,
							rec.nro_tramite,
							rec.detalle_incidente,
							rec.pnr,
							rec.nro_vuelo,
							rec.id_usuario_reg,
							rec.fecha_reg,
							rec.usuario_ai,
							rec.id_usuario_ai,
							rec.fecha_mod,
							rec.id_usuario_mod,
							usu1.cuenta as usr_reg,
							usu2.cuenta as usr_mod,
        					rec.id_gestion,
        					rec.id_motivo_anulado,
        					med.nombre_medio as desc_nombre_medio,
        					c.nombre_completo2 as desc_nom_cliente,
        					tip.nombre_incidente as desc_nombre_incidente,
        					of.nombre as desc_nombre_oficina,
        					ofi.nombre as desc_oficina_registro_incidente,
        					t.nombre_incidente as desc_sudnom_incidente,
        					fun.desc_funcionario1 as desc_nombre_funcionario,
        					fu.desc_funcionario1 as desc_nombre_fun_denun,
        					rec.revisado,
        					rec.transito,
        					ma.motivo as motivo_anulado,
        					rec.nro_guia_aerea,
                            c.nombre_completo2,
                            res.nro_cite
						from rec.treclamo rec
						inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
                        INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                        INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                        INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                        INNER join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
						INNER join orga.vfuncionario fun on fun.id_funcionario = rec.id_funcionario_recepcion
                        inner join param.tgestion gest on gest.id_gestion = rec.id_gestion

						left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod
						LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
						left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                        left join param.tlugar lug ON lug.id_lugar = of.id_lugar
                        left join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
						left join orga.vfuncionario fu on fu.id_funcionario = rec.id_funcionario_denunciado

						left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado

						LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo
				        WHERE rec.estado_reg = ''activo'' and ';


            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            raise notice 'que esta pasando: %',v_consulta;
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_CONSULTA_CONT'
         #DESCRIPCION:	Conteo de registros
         #AUTOR:		admin
         #FECHA:		10-08-2016 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_CONSULTA_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(rec.id_reclamo)
			   			from rec.treclamo rec
						inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
                        INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                        INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                        INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                        INNER join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
						INNER join orga.vfuncionario fun on fun.id_funcionario = rec.id_funcionario_recepcion
                        inner join param.tgestion gest on gest.id_gestion = rec.id_gestion

						left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod
						LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
						left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                        left join param.tlugar lug ON lug.id_lugar = of.id_lugar
                        left join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
						left join orga.vfuncionario fu on fu.id_funcionario = rec.id_funcionario_denunciado

						left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado

						LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo
					    where rec.estado_reg = ''activo'' and ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_REPOR_SEL'
         #DESCRIPCION:	Reporte reclamo doc
         #AUTOR:		MMV
         #FECHA:		27-10-2016 18:32:59
        ***********************************/
    elsif(p_transaccion='REC_REPOR_SEL')then

        begin
            --Sentencia de la consulta
            v_consulta:='select
						rec.id_reclamo,
						rec.id_proceso_wf,
						rec.id_estado_wf,
						rec.estado,
						rec.fecha_hora_incidente,
						rec.fecha_hora_recepcion,
						rec.estado_reg,
						rec.fecha_hora_vuelo,
						rec.origen,
						rec.nro_frd,
                        rec.correlativo_preimpreso_frd,
                        rec.fecha_limite_respuesta,
						rec.observaciones_incidente,
						rec.destino,
						rec.nro_att_canalizado,
                        rec.nro_tramite,
						rec.detalle_incidente,
						rec.nro_vuelo,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        med.nombre_medio as desc_nombre_medio,
                        cli.nombre_completo1 as desc_nom_cliente,
                        tip.nombre_incidente as desc_incidente,
                        t.nombre_incidente as desc_sudnom_incidente,
                        of.nombre as desc_oficina,
                        ofi.nombre as desc_oficina_registro_incidente,
                        fun.desc_funcionario1 as desc_nombre_funcionario,
                        fu.desc_funcionario1 as desc_nombre_fun_denun,
                        cl.nombre as nombre_cliente,
                        cli.apellidos,
                        cl.ci,
                        cl.celular,
                        cl.email,
                        lu.nombre as pais,
                        cl.ciudad_residencia as ciudad,
                        cl.direccion,
                        cl.barrio_zona,
                        cl.lugar_expedicion,
                        usu1.fecha_reg
                        from rec.treclamo rec
						inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod
						join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                        inner join rec.vcliente cli on cli.id_cliente = rec.id_cliente
                        inner join rec.tcliente cl on cl.id_cliente =rec.id_cliente
                        join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                        left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                      	inner join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                        inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
                        inner join orga.vfuncionario fun on fun.id_funcionario = rec.id_funcionario_recepcion
                        left outer join orga.vfuncionario fu on fu.id_funcionario = rec.id_funcionario_denunciado
                        left join param.tlugar lu on lu.id_lugar =cl.id_pais_residencia
           				where rec.id_proceso_wf ='||v_parametros.id_proceso_wf;

            raise notice '%', v_consulta;

            return v_consulta;
        END;

    ELSIF(p_transaccion = 'REC_LIBRESP_SEL')THEN
        BEGIN

            v_consulta = 'SELECT DISTINCT ON (correlativo)
          trp.fecha_respuesta::date AS fecha,
          (SUBSTRING(trc.nro_tramite FROM 5 FOR 6))::varchar AS correlativo,
          ti.nombre_incidente::varchar AS tipo,
          sti.nombre_incidente::varchar AS subtipo,
          vfcl.oficina_nombre::varchar AS oficina,
          vc.nombre_completo1::varchar AS cliente
          FROM rec.treclamo trc
          INNER JOIN rec.trespuesta trp ON trp.id_reclamo = trc.id_reclamo
          INNER JOIN rec.ttipo_incidente 	ti ON ti.id_tipo_incidente = trc.id_tipo_incidente
          INNER JOIN rec.ttipo_incidente sti ON sti.id_tipo_incidente = trc.id_subtipo_incidente
          INNER JOIN orga.vfuncionario_cargo_lugar vfcl ON vfcl.id_oficina = trc.id_oficina_incidente
          INNER JOIN rec.vcliente vc ON vc.id_cliente = trc.id_cliente
          WHERE trp.fecha_respuesta >= '''|| to_char(v_parametros.fecha_ini,'DD-MM-YYYY')||''' AND trp.fecha_respuesta <= '''||to_char(v_parametros.fecha_fin,'DD-MM-YYYY')||'''';


            RETURN v_consulta;

        END;
        /*********************************
          #TRANSACCION:  'REC_OFICINAS_SEL'
          #DESCRIPCION:	Permite recuperar las oficinas para la situacion de Ambiente del incidente y oficina de registro
          #AUTOR:		FEA
          #FECHA:		27-10-2016 18:32:59
         ***********************************/
    ELSIF(p_transaccion = 'REC_OFICINAS_SEL')THEN
        BEGIN
            v_consulta = 'select
						ofi.id_oficina,
						ofi.aeropuerto,
						ofi.id_lugar,
						ofi.nombre,
						ofi.codigo,
						ofi.estado_reg,
						ofi.fecha_reg,
						ofi.id_usuario_reg,
						ofi.fecha_mod,
						ofi.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						lug.nombre as nombre_lugar,
						ofi.zona_franca,
						ofi.frontera
						from rec.toficina ofi
						inner join segu.tusuario usu1 on usu1.id_usuario = ofi.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = ofi.id_usuario_mod
						inner join param.tlugar lug on lug.id_lugar = ofi.id_lugar
				        where  (ofi.estado_reg = ''activo'' OR ofi.estado_reg = ''inactivo'') AND ';

            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            RETURN v_consulta;
        END;
        /*********************************
         #TRANSACCION:  'REC_OFICINAS_CONT'
         #DESCRIPCION:	Conteo de registros
         #AUTOR:		admin
         #FECHA:		15-01-2014 16:05:34
        ***********************************/

    elsif(p_transaccion='REC_OFICINAS_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(id_oficina)
					   from rec.toficina ofi
						inner join segu.tusuario usu1 on usu1.id_usuario = ofi.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = ofi.id_usuario_mod
						inner join param.tlugar lug on lug.id_lugar = ofi.id_lugar
				        where  (ofi.estado_reg = ''activo'' OR ofi.estado_reg = ''inactivo'') AND ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;
    elsif(p_transaccion='REC_REG_RIP')then

        begin
            v_consulta:='select
						rec.id_reclamo,
						rec.id_tipo_incidente,
						rec.id_subtipo_incidente,
						rec.id_medio_reclamo,
						rec.id_funcionario_recepcion,
						rec.id_funcionario_denunciado,
						rec.id_oficina_incidente,
						rec.id_oficina_registro_incidente,
						rec.id_proceso_wf,
						rec.id_estado_wf,
						rec.id_cliente,
						rec.estado,
						rec.fecha_hora_incidente,
						rec.nro_ripat_att,
						rec.nro_hoja_ruta,
						rec.fecha_hora_recepcion,
						rec.estado_reg,
						rec.fecha_hora_vuelo,
						rec.origen,
						rec.nro_frd,
                        rec.correlativo_preimpreso_frd,
                        rec.fecha_limite_respuesta,
						rec.observaciones_incidente,
						rec.destino,
						rec.nro_pir,
						rec.nro_frsa,
						rec.nro_att_canalizado,
						rec.nro_tramite,
						rec.detalle_incidente,
						rec.pnr,
						rec.nro_vuelo,
						rec.id_usuario_reg,
						rec.fecha_reg,
						rec.usuario_ai,
						rec.id_usuario_ai,
						rec.fecha_mod,
						rec.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        	rec.id_gestion,
                            rec.id_motivo_anulado,
                        med.nombre_medio as desc_nombre_medio,
                        	c.nombre_completo2 as desc_nom_cliente,
                        tip.nombre_incidente as desc_nombre_incidente,
                        of.nombre as desc_nombre_oficina,
                        ofi.nombre as desc_oficina_registro_incidente,
                        t.nombre_incidente as desc_sudnom_incidente,
                        fun.desc_funcionario1 as desc_nombre_funcionario,
                        fu.desc_funcionario1 as desc_nombre_fun_denun,
                        	tip.tiempo_respuesta,
                            rec.revisado,
                            rec.transito,
                            rec.f_dias_respuesta(now()::date, rec.fecha_limite_respuesta, ''DIAS_RESP'')::varchar as dias_respuesta,
                            rec.f_dias_respuesta(now()::date, rec.fecha_hora_recepcion::date, ''DIAS_INF'')::varchar as dias_informe,
                            ma.motivo as motivo_anulado,
                            res.nro_cite,
                            infor.conclusion_recomendacion ,
							res.recomendaciones,
                            c.genero,
                            c.ci,
                            c.telefono,
                            c.email,
                            c.ciudad_residencia,
                            rec.nro_guia_aerea,

                            c.nombre_completo2 as desc_nom_cliente,
							'||p_administrador||'::integer AS administrador

						from rec.treclamo rec
						inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod
						left join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                        left join rec.vcliente c on c.id_cliente = rec.id_cliente
                        inner join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                        left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                      	inner join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                        inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
                        inner join orga.vfuncionario fun on fun.id_funcionario = rec.id_funcionario_recepcion
                        left join orga.vfuncionario fu on fu.id_funcionario = rec.id_funcionario_denunciado
                        	left join param.tgestion gest on gest.id_gestion = rec.id_gestion
                            left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado
                            left join wf.testado_wf tew on tew.id_estado_wf = rec.id_estado_wf

                            LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo
							LEFT JOIN rec.tinforme infor ON infor.id_reclamo =  rec.id_reclamo

				        where  rec.estado=''registrado_ripat'' AND ';

            --raise exception 'ordenacion: %',v_consulta;
            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            --Devuelve la respuesta
            raise notice 'que esta pasando: %',v_consulta;

            return v_consulta;

        end;
        /*********************************
          #TRANSACCION:  'REC_FAILS_SEL'
          #DESCRIPCION:	Permite recuperar las alarmas que fallaron al momento de enviar la respuesta de un reclamo.
          #AUTOR:		FEA
          #FECHA:		27-04-2017 18:32:59
          ***********************************/
    ELSIF(p_transaccion = 'REC_FAILS_SEL')THEN
        BEGIN
            v_consulta = 'select
          				trec.id_reclamo,
          				trec.nro_tramite,
                        trec.id_cliente,
                        ta.desc_falla::varchar as falla,
                        vc.nombre_completo2::varchar as desc_funcionario
						from rec.trespuesta tr
						inner join param.talarma ta on ta.id_proceso_wf = tr.id_proceso_wf
						inner join rec.treclamo trec on trec.id_reclamo = tr.id_reclamo
						inner join rec.vcliente vc on vc.id_cliente = trec.id_cliente
						where (ta.estado_envio = ''falla'' or ta.pendiente <> ''no'' ) and (ta.fecha_reg::date between now()::date-5 and now()::date+2) and ';

            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            raise notice 'v_consulta %',v_consulta;
            return v_consulta;
        END;
        /*********************************
        #TRANSACCION:  'REC_NUM_FRD_SEL'
        #DESCRIPCION:	Recupera los nros frds de una oficina en especifico.
        #AUTOR:		FEA
        #FECHA:		01-06-2017 18:32:59
        ***********************************/
    ELSIF(p_transaccion = 'REC_NUM_FRD_SEL')THEN
        BEGIN

            v_consulta = 'SELECT
                        tr.id_reclamo,
                        tr.nro_tramite,
                        tr.nro_frd,
                        tr.correlativo_preimpreso_frd AS nro_correlativo,
                        tof.nombre as oficina,
                        tof.id_oficina,
                        tr.id_gestion,
                        vc.nombre_completo1::varchar as nombre_cliente,
                        vf.desc_funcionario1::varchar as nombre_funcionario
                        FROM rec.treclamo tr
                        INNER JOIN rec.toficina tof ON tof.id_oficina = tr.id_oficina_registro_incidente
                        INNER JOIN rec.vcliente vc ON vc.id_cliente = tr.id_cliente
                        INNER JOIN orga.vfuncionario vf ON vf.id_funcionario = tr.id_funcionario_recepcion
                        WHERE ';

            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            raise notice 'v_consulta: %',v_consulta;
            RETURN v_consulta;
        END;
        /*********************************
         #TRANSACCION:  'REC_NUM_FRD_CONT'
         #DESCRIPCION:	Conteo de registros reporte FRDS.
         #AUTOR:		admin
         #FECHA:		10-08-2016 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_NUM_FRD_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='SELECT count(tr.id_reclamo)
			   			FROM rec.treclamo tr
                        INNER JOIN rec.toficina tof ON tof.id_oficina = tr.id_oficina_registro_incidente
                        INNER JOIN rec.vcliente vc ON vc.id_cliente = tr.id_cliente
                        INNER JOIN orga.vfuncionario vf ON vf.id_funcionario = tr.id_funcionario_recepcion
                        WHERE ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;
        /*********************************
        #TRANSACCION:  'REC_REP_FRD_SEL'
        #DESCRIPCION:	REPORTE DE LOS FRDS FALTANTES EN UNA OFICINA
        #AUTOR:		Franklin Espinoza
        #FECHA:		12-06-2017 14:58:16
        ***********************************/
    elsif(p_transaccion='REC_REP_FRD_SEL')then

        BEGIN

            create temp table tnro_frds(
                nro_frd numeric
            )on commit drop;

            insert into tnro_frds(
                SELECT to_number(tr.nro_frd,'9999999')
                FROM rec.treclamo tr
                         INNER JOIN rec.toficina tof ON tof.id_oficina = tr.id_oficina_registro_incidente
                WHERE tr.id_oficina_registro_incidente = v_parametros.id_oficina and tr.id_gestion = v_parametros.id_gestion
            );


            SELECT max(nro_frd),min(nro_frd)
            INTO v_max, v_min
            FROM tnro_frds ;

            v_cont = 0;
            FOR v_index IN (SELECT nro_frd FROM tnro_frds)LOOP
                v_frds[v_cont] = v_index;
                v_cont = v_cont + 1;
            END LOOP;

            v_cont = 0;
            FOR v_index IN 1..v_max LOOP
                IF v_index = ANY (v_frds) THEN
                ELSE
                    v_frd_faltantes[v_cont] = v_index;
                    v_cont = v_cont + 1;
                END IF;
            END LOOP;
            --Definicion de la respuesta
            v_consulta = 'SELECT
                                tof.nombre,
                                '''||array_to_string(v_frds,',')||'''::varchar as frds,
            					'''||case when array_length(v_frd_faltantes, 1) >= 1 then array_to_string(v_frd_faltantes,',') else '' end||'''::varchar as frd_faltantes
			   				FROM rec.toficina tof
                            WHERE tof.id_oficina = '||v_parametros.id_oficina;
            raise notice 'v_consulta %',v_consulta;
            --Devuelve la respuesta
            return v_consulta;
        END;
        /*********************************
         #TRANSACCION:  'REC_LOGS_FAL_SEL'
         #DESCRIPCION:	Listar faltas de los funcionarios de los funcionarios que hacen caso omiso de las advertencias.
         #AUTOR:		f.e.a
         #FECHA:		16-06-2017 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_LOGS_FAL_SEL')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='SELECT
            			tlr.id_logs_reclamo,
                        tlr.descripcion,
                        tlr.id_reclamo,
                        tlr.id_funcionario,
                        vf.desc_funcionario1 as nombre_funcionario,
                        tr.nro_tramite
			   			FROM rec.tlogs_reclamo tlr
                        INNER JOIN rec.treclamo tr ON tr.id_reclamo = tlr.id_reclamo
                        INNER JOIN orga.vfuncionario vf ON vf.id_funcionario = tlr.id_funcionario
                        WHERE ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_LOGS_FAL_CONT'
         #DESCRIPCION:	Conteo de registros Log Reclamo.
         #AUTOR:		admin
         #FECHA:		10-08-2016 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_LOGS_FAL_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='SELECT count(tlr.id_logs_reclamo)
			   			FROM rec.tlogs_reclamo tlr
                        INNER JOIN rec.treclamo tr ON tr.id_reclamo = tlr.id_reclamo
                        INNER JOIN orga.vfuncionario vf ON vf.id_funcionario = tlr.id_funcionario
                        WHERE ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_STADISTICAS_SEL'
         #DESCRIPCION:	Estadisticas Reclamos.
         #AUTOR:		f.e.a
         #FECHA:		20/2/2018 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_STADISTICAS_SEL')then

        begin
            create temp table tt_rec_informacion (
                                                     tipo_tabla 		varchar,
                                                     nombre_detalle 	varchar,
                                                     cantidad 		integer
            ) on commit drop;

            v_consulta = 'insert into tt_rec_informacion
            select
            ''tipo_incidente'',
            tip.nombre_incidente,
            count(tip.id_tipo_incidente)
            from rec.treclamo rec
            INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
            INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
            left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
            left join param.tlugar lug ON lug.id_lugar = of.id_lugar
            INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
            LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
            inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
            where rec.estado_reg != ''inactivo'' and '||v_parametros.filtro||'
            group by tip.nombre_incidente';
            execute(v_consulta);

            v_consulta = 'insert into tt_rec_informacion
            select
            ''oficina_reclamo'',
            ofi.nombre,
            count(ofi.id_lugar)
            from rec.treclamo rec
            INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
            INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
            left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
            left join param.tlugar lug ON lug.id_lugar = of.id_lugar
            INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
            LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
            inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
            where rec.estado_reg != ''inactivo'' and '||v_parametros.filtro||'
            group by ofi.nombre';
            execute(v_consulta);

            v_consulta = 'insert into tt_rec_informacion
            select
            ''oficina_incidente'',
            coalesce( of.nombre, ''Oficina Desconocido''),
            count(coalesce(of.id_lugar,1))
            from rec.treclamo rec
            INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
            INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
            left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
            left join param.tlugar lug ON lug.id_lugar = of.id_lugar
            INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
            LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
            inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
            where rec.estado_reg != ''inactivo'' and '||v_parametros.filtro||'
            group by of.nombre';
            execute(v_consulta);

            v_consulta = 'insert into tt_rec_informacion
            select
            ''genero_cliente'',
            CASE WHEN c.genero = '''' THEN ''No Especifica'' ELSE coalesce(c.genero, ''No Especifica'') END,
            count(c.genero)
            from rec.treclamo rec
            INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
            INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
            left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
            left join param.tlugar lug ON lug.id_lugar = of.id_lugar
            INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
            LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
            inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
            LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
            where rec.estado_reg != ''inactivo'' and '||v_parametros.filtro||'
            group by c.genero';
            execute(v_consulta);

            v_consulta = 'insert into tt_rec_informacion
            select
            ''estado_reclamo'',
            coalesce(rec.estado, ''No Especifica''),
            count(rec.estado)
            from rec.treclamo rec
            INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
            INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
            left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
            left join param.tlugar lug ON lug.id_lugar = of.id_lugar
            INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
            LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
            inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
            LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
            where rec.estado_reg != ''inactivo'' and '||v_parametros.filtro||'
            group by rec.estado';
            execute(v_consulta);

            v_consulta = 'insert into tt_rec_informacion
            select
            ''medio_reclamo'',
            coalesce(med.nombre_medio, ''No Especifica''),
            count(med.nombre_medio)
            from rec.treclamo rec
            INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
            INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
            left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
            left join param.tlugar lug ON lug.id_lugar = of.id_lugar
            INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
            LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
            inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
            LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
            where rec.estado_reg != ''inactivo'' and '||v_parametros.filtro||'
            group by med.nombre_medio';


            --Sentencia de la consulta de conteo de registros
            v_consulta = 'select
            			  tri.tipo_tabla,
                          tri.nombre_detalle,
                          tri.cantidad
            			  from tt_rec_informacion tri
                          order by tri.tipo_tabla, tri.nombre_detalle
            ';

            --Devuelve la respuesta
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_DET_RES_CLAIMS'
         #DESCRIPCION:	Resumen de reclamos por estado de toda la gestion o periodo.
         #AUTOR:		    franklin.espinoza
         #FECHA:		    15-08-2022 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_DET_RES_CLAIMS')then

        begin
            --Sentencia de la consulta de registros

            v_consulta = '
			            SELECT TO_JSON(ROW_TO_JSON(jsonD) :: TEXT) #>> ''{}'' as jsonData
                        FROM (
                                 SELECT (select coalesce(ARRAY_TO_JSON(ARRAY_AGG(resumen)), ''[]'') summary
                                         from (select rec.estado, count(rec.id_reclamo) cantidad
                                               from rec.treclamo rec
                                               where rec.fecha_reg::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date
                                               group by rec.estado
                                               order by rec.estado asc) resumen
                                        ),
                                        (select coalesce(array_to_json(string_to_array(pxp.list(distinct r.fecha_reg::date::text), '','')), ''[]'') labels
                                               from rec.treclamo r
                                               where r.fecha_reg::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date
                                        ),
			                            (select coalesce(ARRAY_TO_JSON(ARRAY_AGG(detalle)), ''[]'') detail
                                         from (select rec.estado, rec.fecha_reg::date, count(rec.id_reclamo) cantidad
                                         from rec.treclamo rec
                                         where rec.fecha_reg::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date
                                         group by rec.estado, rec.fecha_reg::date
                                         order by rec.estado asc) detalle
			                            ),
			                            (select count(rec.id_reclamo) totalrec
                                         from rec.treclamo rec
                                         where rec.fecha_reg::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date
                                        ),
                                        (select count(res.id_respuesta) totalres
                                         from rec.trespuesta res
                                         where res.fecha_reg::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date
                                        ),
			                            (select coalesce(ARRAY_TO_JSON(ARRAY_AGG(graphic)), ''[]'') reclamo
                                         from (select rec.fecha_reg::date::varchar x, count(rec.id_reclamo) y
                                               from rec.treclamo rec
                                               where rec.fecha_reg::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date
                                               group by rec.fecha_reg::date
                                               order by rec.fecha_reg::date asc) graphic
			                            ),
			                            (select coalesce(ARRAY_TO_JSON(ARRAY_AGG(graphicR)), ''[]'') respuesta
                                         from (select res.fecha_reg::date::varchar x, count(res.id_respuesta) y
                                               from rec.trespuesta res
                                               where res.fecha_reg::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date
                                               group by res.fecha_reg::date
                                               order by res.fecha_reg::date asc) graphicR
                                        ),
			                            (select coalesce(ARRAY_TO_JSON(ARRAY_AGG(sexo)), ''[]'') generos
			                             from(select cli.genero, count(rec.id_cliente) cantidad
                                              from rec.treclamo rec
                                              inner join rec.tcliente cli on cli.id_cliente = rec.id_cliente
                                              where rec.fecha_reg::date between '''||v_parametros.fecha_ini||'''::date and '''||v_parametros.fecha_fin||'''::date
                                              group by cli.genero
                                              order by cli.genero desc) sexo
                                        )
                             ) jsonD
			             ';
            --Devuelve la respuesta
            return v_consulta;

        end;

        /*********************************
         #TRANSACCION:  'REC_GANTT_CLAIM'
         #DESCRIPCION:	Devuelve la estructura del gantt de un reclamo.
         #AUTOR:		    franklin.espinoza
         #FECHA:		    15-01-2023 18:32:59
        ***********************************/

    elsif(p_transaccion='REC_GANTT_CLAIM')then
        begin

            select tpw.nro_tramite
            into v_id_procesos
            from wf.tproceso_wf tpw
            where tpw.id_proceso_wf = v_parametros.id_proceso_wf;

            select pxp.list(tp.id_proceso_wf::varchar)
            into v_id_procesos
            from  wf.tproceso_wf tp
            where tp.nro_tramite = v_id_procesos;

            --Sentencia de la consulta de registros

            v_consulta = '
                with  procesos as (select
                pwf.id_proceso_wf,
                0 id_estado_wf,
                ''proceso'' tipo,
                tp.nombre,
                null::timestamp fecha_ini,
                null::timestamp fecha_fin,
                pwf.descripcion,
                pwf.nro_tramite,
                tp.codigo,
                0 id_funcionario,
                '''' funcionario,
                0 id_usuario,
                '''' cuenta,
                0 id_depto,
                '''' departamento,
                te.etapa,
                pwf.estado_reg,
                te.disparador,
                te.fin,
                pwf.usuario_ai,
                '''' image_url,
                ''proceso''::varchar image_type
                from wf.tproceso_wf pwf
                inner join wf.testado_wf ewfp on ewfp.id_proceso_wf = pwf.id_proceso_wf and ewfp.estado_reg = ''activo''
                inner join wf.ttipo_estado te on te.id_tipo_estado = ewfp.id_tipo_estado
                inner join wf.ttipo_proceso tp on tp.id_tipo_proceso = pwf.id_tipo_proceso
                where pwf.id_proceso_wf in ('||v_id_procesos||')

                union all

                SELECT
                pwf.id_proceso_wf,
                ewfh.id_estado_wf,
                ''estado'' tipo,
                te.nombre_estado nombre,
                ewfh.fecha_reg fecha_ini,
                null::timestamp fecha_fin,
                ewfh.obs descripcion,
                pwf.nro_tramite,
                tp.codigo,
                coalesce(fun.id_funcionario,0),
                fun.desc_funcionario1 as funcionario,
                usu.id_usuario,
                usu.cuenta,
                depto.id_depto,
                depto.codigo          as departamento,
                te.etapa,
                ewfh.estado_reg,
                te.disparador,
                te.fin,
                ewfh.usuario_ai,
                (select (''https://erp.obairlines.bo''||substr(tar.folder,11)||tar.nombre_archivo||''.''||tar.extension)::varchar
                 from orga.tfuncionario tf
                 inner join param.tarchivo tar on tar.id_tabla = tf.id_funcionario and tar.id_tipo_archivo = 10 and tar.id_archivo_fk  is null
                 where tf.id_funcionario = fun.id_funcionario and tar.estado_reg = ''activo'') image_url,
                 (case when coalesce(fun.id_funcionario,0) != 0 then ''funcionario'' else ''departamento'' end)::varchar image_type
                FROM wf.testado_wf ewfh
                INNER JOIN wf.ttipo_estado te on ewfh.id_tipo_estado = te.id_tipo_estado
                inner join wf.tproceso_wf pwf on pwf.id_proceso_wf = ewfh.id_proceso_wf
                inner join wf.ttipo_proceso tp on tp.id_tipo_proceso = pwf.id_tipo_proceso
                LEFT JOIN segu.tusuario usu on usu.id_usuario = ewfh.id_usuario_reg
                LEFT JOIN orga.vfuncionario fun on fun.id_funcionario = ewfh.id_funcionario
                LEFT JOIN param.tdepto depto on depto.id_depto = ewfh.id_depto
                WHERE ewfh.id_proceso_wf in ('||v_id_procesos||')

                union all

                SELECT
                pro.id_proceso_wf,
                pro.id_estado_wf,
                ''obs'' tipo,
                o.titulo nombre,
                o.fecha_reg as fecha_ini,
                COALESCE(o.fecha_fin, now()) fecha_fin,
                COALESCE(o.descripcion,'''')||'' [''||o.estado||'']'' descripcion,
                o.num_tramite,
                ''obs'' codigo,
                coalesce(fun.id_funcionario,0),
                fun.desc_funcionario1  as funcionario,
                o.id_usuario_reg id_usuario,
                usu.cuenta,
                null id_depto,
                null departamento,
                null etapa,
                o.estado_reg,
                null disparador,
                null fin,
                o.usuario_ai,
                (select (''https://erp.obairlines.bo''||substr(tar.folder,11)||tar.nombre_archivo||''.''||tar.extension)::varchar
                 from orga.tfuncionario tf
                 inner join param.tarchivo tar on tar.id_tabla = tf.id_funcionario and tar.id_tipo_archivo = 10 and tar.id_archivo_fk  is null
                 where tf.id_funcionario = fun.id_funcionario and tar.estado_reg = ''activo'') image_url,
                 (case when coalesce(fun.id_funcionario,0) != 0 then ''funcionario'' else ''departamento'' end)::varchar image_type
                FROM  wf.tobs o
                INNER JOIN  orga.vfuncionario fun on fun.id_funcionario = o.id_funcionario_resp
                INNER JOIN  segu.tusuario usu on usu.id_usuario = o.id_usuario_reg
                inner join wf.testado_wf pro on pro.id_estado_wf = o.id_estado_wf
                WHERE  pro.id_proceso_wf in ('||v_id_procesos||') AND  o.estado_reg = ''activo''
                    )
                select
			        proc.id_proceso_wf::integer,
			        proc.id_estado_wf::integer,
                    proc.tipo::varchar,
                    proc.nombre::varchar,
                    proc.fecha_ini::timestamp,
                    proc.fecha_fin::timestamp,
                    proc.descripcion::text,
                    proc.nro_tramite::varchar,
                    proc.codigo::varchar,
                    proc.id_funcionario::integer,
                    proc.funcionario::varchar,
                    proc.id_usuario::integer,
                    proc.cuenta::varchar,
                    proc.id_depto::integer,
                    proc.departamento::varchar,
                    proc.etapa::varchar,
                    proc.estado_reg::varchar,
                    proc.disparador::varchar,
                    proc.fin::varchar,
                    proc.usuario_ai::varchar,
                    proc.image_url,
                    proc.image_type
                from procesos proc
                order by proc.id_proceso_wf, proc.id_estado_wf asc
			    limit '|| v_parametros.cantidad ||' offset '|| v_parametros.puntero;
            --Devuelve la respuesta
            return v_consulta;

        end;

        /*********************************
         #TRANSACCION:  'REC_CLAIMS_LIST'
         #DESCRIPCION:	Consulta de datos de los reclamos
         #AUTOR:		franklin.espinoza
         #FECHA:		10-01-2023 18:32:59
        ***********************************/
    elsif(p_transaccion='REC_CLAIMS_LIST')then
        begin

            --CRITERIOS DE FILTRADO
            SELECT vfcl.id_oficina, vfcl.nombre_cargo,  vfcl.oficina_nombre,
                   tf.id_funcionario, vfcl.desc_funcionario1 INTO v_record
            FROM segu.tusuario tu
                     INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
                     INNER JOIN orga.vfuncionario_cargo_lugar vfcl on vfcl.id_funcionario = tf.id_funcionario
            WHERE tu.id_usuario = p_id_usuario ;

            if p_administrador = 1 then
                v_filtro= '0 = 0 and ';
            else
                select pxp.aggarray(depu.id_depto)
                into va_id_depto
                from param.tdepto_usuario depu
                where depu.id_usuario =  p_id_usuario;

                v_filtro = '( rec.id_usuario_reg = '||p_id_usuario||' or rec.id_usuario_mod = '||p_id_usuario||' or tew.id_depto in ('|| COALESCE(array_to_string(va_id_depto,','),'0')||') or rec.id_oficina_registro_incidente = '||v_record.id_oficina||' or tew.id_funcionario = '||v_record.id_funcionario||') and rec.estado_reg != ''inactivo'' and ';
            end if;

            --Sentencia de la consulta
            v_consulta ='select ROW_TO_JSON(listClaims)
                        from(
                            select (
                                    select coalesce(ARRAY_TO_JSON(ARRAY_AGG(claim)),''[]''::json)
                                    from (
                                            select
                                            rec.id_reclamo,
                                            rec.id_tipo_incidente,
                                            rec.id_subtipo_incidente,
                                            rec.id_medio_reclamo,
                                            rec.id_funcionario_recepcion,
                                            rec.id_funcionario_denunciado,
                                            rec.id_oficina_incidente,
                                            rec.id_oficina_registro_incidente,
                                            rec.id_proceso_wf,
                                            rec.id_estado_wf,
                                            rec.id_cliente,
                                            rec.estado,
                                            rec.fecha_hora_incidente,
                                            rec.nro_ripat_att,
                                            rec.nro_hoja_ruta,
                                            rec.fecha_hora_recepcion,
                                            rec.estado_reg,
                                            rec.fecha_hora_vuelo,
                                            rec.origen,
                                            rec.nro_frd,
                                            rec.correlativo_preimpreso_frd,
                                            rec.fecha_limite_respuesta,
                                            rec.observaciones_incidente,
                                            rec.destino,
                                            rec.nro_pir,
                                            rec.nro_frsa,
                                            rec.nro_att_canalizado,
                                            rec.nro_tramite,
                                            rec.detalle_incidente,
                                            rec.pnr,
                                            rec.nro_vuelo,
                                            rec.id_usuario_reg,
                                            rec.fecha_reg,
                                            rec.usuario_ai,
                                            rec.id_usuario_ai,
                                            rec.fecha_mod,
                                            rec.id_usuario_mod,
                                            usu1.cuenta as usr_reg,
                                            usu2.cuenta as usr_mod,
                                            rec.id_gestion,
                                            rec.id_motivo_anulado,
                                            med.nombre_medio as desc_nombre_medio,
                                            c.nombre_completo2 as desc_nom_cliente,
                                            tip.nombre_incidente as desc_nombre_incidente,
                                            of.nombre as desc_nombre_oficina,
                                            ofi.nombre as desc_oficina_registro_incidente,
                                            t.nombre_incidente as desc_sudnom_incidente,
                                            fun.desc_funcionario1 as desc_nombre_funcionario,
                                            fu.desc_funcionario1 as desc_nombre_fun_denun,
                                            tip.tiempo_respuesta,
                                            rec.revisado,
                                            rec.transito,
                                            rec.f_verificar_dias(CURRENT_DATE, rec.fecha_limite_respuesta)::varchar as dias_respuesta,
                                            rec.f_dias_respuesta(now()::date, rec.fecha_hora_recepcion::date, ''DIAS_INF'')::varchar as dias_informe,
                                            ma.motivo as motivo_anulado,
                                            res.nro_cite,
                                            infor.conclusion_recomendacion ,
                                            res.recomendaciones,
                                            c.genero,
                                            c.ci,
                                            c.telefono,
                                            c.email,
                                            cli.email2,
                                            c.ciudad_residencia,
                                            rec.nro_guia_aerea,
                                            c.nombre_completo2 as desc_nom_cliente,
                                            '||p_administrador||'::integer AS administrador,
                                            infor.id_informe,
                                            res.id_respuesta

                                            from rec.treclamo rec
                                            inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
                                            left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod
                                            INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                                            LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
                                            inner join rec.tcliente cli on c.id_cliente = cli.id_cliente
                                            INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                                            left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                                            left join param.tlugar lug ON lug.id_lugar = of.id_lugar
                                            INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                                            LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
                                            inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
                                            inner join orga.vfuncionario fun on fun.id_funcionario = rec.id_funcionario_recepcion
                                            left join orga.vfuncionario fu on fu.id_funcionario = rec.id_funcionario_denunciado
                                            INNER join param.tgestion gest on gest.id_gestion = rec.id_gestion
                                            left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado
                                            LEFT join wf.testado_wf tew on tew.id_estado_wf = rec.id_estado_wf

                                            LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo
                                            LEFT JOIN rec.tinforme infor ON infor.id_reclamo =  rec.id_reclamo
                                            LEFT JOIN rec.treclamo_informe tri ON tri.id_reclamo = rec.id_reclamo

                                            where '||v_filtro;

            --Definicion de la respuesta
            v_consulta = v_consulta || v_parametros.filtro;
            v_consulta = v_consulta || ' order by rec.id_reclamo desc limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            v_consulta = v_consulta || ') claim
                            ) claims ,
                            (
                                select count(rec.id_reclamo)
                                from rec.treclamo rec
                                inner join segu.tusuario usu1 on usu1.id_usuario = rec.id_usuario_reg
                                left join segu.tusuario usu2 on usu2.id_usuario = rec.id_usuario_mod
                                INNER join rec.tmedio_reclamo med on med.id_medio_reclamo = rec.id_medio_reclamo
                                LEFT join rec.vcliente c on c.id_cliente = rec.id_cliente
                                inner join rec.tcliente cli on c.id_cliente = cli.id_cliente
                                INNER join rec.ttipo_incidente tip on tip.id_tipo_incidente = rec.id_tipo_incidente
                                left join rec.toficina of on of.id_oficina = rec.id_oficina_incidente
                                left join param.tlugar lug ON lug.id_lugar = of.id_lugar
                                INNER join rec.toficina ofi on ofi.id_oficina = rec.id_oficina_registro_incidente
                                LEFT join param.tlugar tlug ON tlug.id_lugar = ofi.id_lugar
                                inner join rec.ttipo_incidente t on t.id_tipo_incidente = rec.id_subtipo_incidente
                                inner join orga.vfuncionario fun on fun.id_funcionario = rec.id_funcionario_recepcion
                                left join orga.vfuncionario fu on fu.id_funcionario = rec.id_funcionario_denunciado
                                INNER join param.tgestion gest on gest.id_gestion = rec.id_gestion
                                left join rec.tmotivo_anulado ma on ma.id_motivo_anulado = rec.id_motivo_anulado
                                LEFT join wf.testado_wf tew on tew.id_estado_wf = rec.id_estado_wf
                                LEFT JOIN rec.trespuesta res ON res.id_reclamo = rec.id_reclamo
                                LEFT JOIN rec.tinforme infor ON infor.id_reclamo = rec.id_reclamo
                                LEFT JOIN rec.treclamo_informe tri ON tri.id_reclamo = rec.id_reclamo
                                where '||v_filtro||v_parametros.filtro||'
                            ) total
                    ) listClaims';
            --Devuelve la respuesta
            raise notice 'que esta pasando: %',v_consulta;
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_STATUS_LIST'
         #DESCRIPCION:	Consulta de estados
         #AUTOR:		franklin.espinoza
         #FECHA:		10-01-2023 18:32:59
        ***********************************/
    elsif(p_transaccion='REC_STATUS_LIST')then
        begin

            v_consulta = '
                select coalesce(ARRAY_TO_JSON(ARRAY_AGG(status)),''[]''::json) status_list
                from (select tte.id_tipo_estado, tte.codigo, tte.nombre_estado
                from wf.ttipo_proceso ttp
                inner join wf.ttipo_estado tte on tte.id_tipo_proceso = ttp.id_tipo_proceso
                where ttp.codigo = '''||v_parametros.codigo||''' and tte.estado_reg = ''activo'' and ttp.estado_reg = ''activo''
                order by tte.codigo asc) status';

            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_ROLES_LIST'
         #DESCRIPCION:	Consulta de roles parametrizados
         #AUTOR:		franklin.espinoza
         #FECHA:		10-01-2023 18:32:59
        ***********************************/
    elsif(p_transaccion='REC_ROLES_LIST')then
        begin

            v_consulta = '
                select coalesce(ARRAY_TO_JSON(ARRAY_AGG(tr.json_rol)),''[]''::json) roles_list
                from rec.trol tr
                where tr.estado_reg =''activo''
                ';

            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_ROLES_BY_OFF'
         #DESCRIPCION:	Consulta de roles por funcionario
         #AUTOR:		franklin.espinoza
         #FECHA:		10-01-2023 18:32:59
        ***********************************/
    elsif(p_transaccion='REC_ROLES_BY_OFF')then

        begin

            select vf.id_funcionario
            into v_id_funcionario
            from segu.tusuario usu
                     inner join orga.tfuncionario vf on vf.id_persona = usu.id_persona
            where usu.id_usuario = p_id_usuario;

            v_consulta = '
                select tr.json_rol::json
                from rec.trol tr
                where (tr.json_rol->>''officials'')::jsonb @> (''[{"id_funcionario":"'||v_id_funcionario||'"}]'')::jsonb';

            return v_consulta;

        end;

    else

        raise exception 'Transaccion inexistente';

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

ALTER FUNCTION rec.ft_reclamo_sel (p_administrador integer, p_id_usuario integer, p_tabla varchar, p_transaccion varchar)
    OWNER TO postgres;