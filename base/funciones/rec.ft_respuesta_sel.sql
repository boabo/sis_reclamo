CREATE OR REPLACE FUNCTION rec.ft_respuesta_sel (
    p_administrador integer,
    p_id_usuario integer,
    p_tabla varchar,
    p_transaccion varchar
)
    RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Gestion de Reclamos
 FUNCION: 		rec.ft_respuesta_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'rec.trespuesta'
 AUTOR: 		 (admin)
 FECHA:	        11-08-2016 16:01:08
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
    v_gaf				varchar;

    v_record			record;

    v_filtro 			varchar;

    v_respuesta			record;

    v_elaboracion 		text;
    v_vobo 				text;

BEGIN

    v_nombre_funcion = 'rec.ft_respuesta_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'REC_RES_SEL'
     #DESCRIPCION:	Consulta de datos
     #AUTOR:		admin
     #FECHA:		11-08-2016 16:01:08
    ***********************************/

    if(p_transaccion='REC_RES_SEL')then

        begin



            SELECT vfcl.id_oficina, vfcl.nombre_cargo,  vfcl.oficina_nombre,
                   tf.id_funcionario, vfcl.desc_funcionario1/*, tr.id_reclamo*/ INTO v_record
            FROM segu.tusuario tu
                     INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
                     INNER JOIN orga.vfuncionario_cargo_lugar vfcl on vfcl.id_funcionario = tf.id_funcionario
                 --INNER JOIN rec.treclamo tr on tr.id_usuario_reg = tu.id_usuario
            WHERE tu.id_usuario = p_id_usuario ;

            --raise exception 'v_record.id_funcionario: %',p_id_usuario;
            /*SELECT *
            INTO v_respuesta
            FROM rec.trespuesta res
            where	res.id_reclamo = v_record.id_reclamo;*/
            IF (p_administrador) THEN
                v_filtro= '0 = 0 AND ';
                /*ELSIF (v_record.nombre_cargo='Especialista Atención al Cliente')THEN
                        v_filtro = '(vfc.id_oficina = '||v_record.id_oficina||' OR tew.id_funcionario = '||v_record.id_funcionario||') AND';
                 -- AND res.estado in (''archivo_con_respuesta'',''respuesta_registrado_ripat'')*/

            ELSIF (v_parametros.tipo_interfaz= 'RespuestaDetalle') THEN
                --raise exception 'entra';
                v_filtro = '(tew.id_funcionario = '||v_record.id_funcionario||' OR res.id_usuario_reg = '||p_id_usuario||') AND ';
            ELSE
                v_filtro = 'tew.id_funcionario = '||v_record.id_funcionario||' AND ';
            END IF;
            --Sentencia de la consulta
            v_consulta:='select
						res.id_respuesta,
						res.id_reclamo,
						res.recomendaciones,
						res.nro_cite,
						res.respuesta,
						res.fecha_respuesta,
						res.estado_reg,
						res.procedente,
						res.fecha_notificacion,
						res.id_usuario_ai,
						res.id_usuario_reg,
						res.usuario_ai,
						res.fecha_reg,
						res.fecha_mod,
						res.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        res.tipo_respuesta,
                        res.asunto,
                        res.id_proceso_wf,
						res.id_estado_wf,
                        res.estado,
                        res.nro_respuesta,
                        vc.email,
                        '||p_administrador||'::integer AS admin,
                        tmr.codigo as codigo_medio,
                        tr.nro_att_canalizado as nro_att
						from rec.trespuesta res
						inner join segu.tusuario usu1 on usu1.id_usuario = res.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = res.id_usuario_mod
                        inner join rec.treclamo tr on tr.id_reclamo = res.id_reclamo
                        inner join rec.vcliente vc on vc.id_cliente = tr.id_cliente
                        left join wf.testado_wf tew on tew.id_estado_wf = res.id_estado_wf
                        left join rec.tmedio_reclamo tmr on tmr.id_medio_reclamo = tr.id_medio_reclamo
                        LEFT JOIN orga.vfuncionario_cargo_lugar vfc on vfc.id_funcionario =  tew.id_funcionario
				        where '||v_filtro;

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            raise notice '%',v_consulta;
            --Devuelve la respuesta
            return v_consulta;

        end;

        /*********************************
         #TRANSACCION:  'REC_RES_CONT'
         #DESCRIPCION:	Conteo de registros
         #AUTOR:		admin
         #FECHA:		11-08-2016 16:01:08
        ***********************************/

    elsif(p_transaccion='REC_RES_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(id_respuesta)
					    from rec.trespuesta res
						inner join segu.tusuario usu1 on usu1.id_usuario = res.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = res.id_usuario_mod
                        inner join rec.treclamo tr on tr.id_reclamo = res.id_reclamo
                        inner join rec.vcliente vc on vc.id_cliente = tr.id_cliente
                        left join wf.testado_wf tew on tew.id_estado_wf = res.id_estado_wf
                        left join rec.tmedio_reclamo tmr on tmr.id_medio_reclamo = tr.id_medio_reclamo
                        LEFT JOIN orga.vfuncionario_cargo_lugar vfc on vfc.id_funcionario =  tew.id_funcionario
					    where ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_REPORDOC_SEL'
         #DESCRIPCION:	Reportes en word
         #AUTOR:		admin
         #FECHA:		11-08-2016 16:01:08
        ***********************************/
    elsif(p_transaccion='REC_REPORDOC_SEL')then

        begin


            --Sentencia de la consulta
            v_consulta:='select
						res.id_respuesta,
						res.id_reclamo,
						res.recomendaciones,
                        case when res.fecha_respuesta > ''2021-12-31''::date then  (''OB.CX.NE.''||lpad(res.nro_cite::text, 4, ''0'')||''.''||date_part(''year'',current_date ))::text
                        else (''OB.GC.NE.''||lpad(res.nro_cite::text, 4, ''0'')||''.''||date_part(''year'',current_date ))::text end as num_cite,
						--res.nro_cite,
						res.respuesta,
                        pxp.f_fecha_literal(res.fecha_respuesta) as fecha_respuesta,
						res.fecha_notificacion,
						res.tipo_respuesta,
                        res.asunto,
                        re.nro_tramite,
                      	re.estado,
                        initcap(cl.nombre_completo1) as nombre_completo1,
                          CASE
           			 			WHEN c.genero::text = ANY (ARRAY[''varon''::character varying,''VARON''::character varying, ''Varon''::character varying]::text[]) THEN ''Señor''::text
            					WHEN c.genero::text = ANY (ARRAY[''mujer''::character varying,''MUJER''::character varying, ''Mujer''::character varying]::text[]) THEN ''Señora''::text
           					ELSE'' ''::text
        					END::character varying AS genero,
                        --pa.gestion,
                        CASE
                        	 WHEN res.procedente::text =ANY(ARRAY[''si''::CHARACTER VARYING,''SI''::character varying, ''si''::character varying]::text[]) THEN ''procedente''::text
                        	 WHEN res.procedente::text =ANY(ARRAY[''no''::CHARACTER VARYING,''NO''::character varying, ''no''::character varying]::text[]) THEN ''improcedente''::text
                        ELSE ''ninguno''::text
                        END::character varying as prodedente,
                        tip.nombre_estado,
                        case when res.fecha_respuesta < ''2021-12-31''::date then ''Atención al Cliente BoA''::varchar else ''Satisfacción al Consumidor''::varchar end firma
                        from rec.trespuesta res
						inner join segu.tusuario usu1 on usu1.id_usuario = res.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = res.id_usuario_mod
				        inner join rec.treclamo re on re.id_reclamo = res.id_reclamo
                        inner join rec.tcliente c on c.id_cliente = re.id_cliente
                        inner join rec.vcliente cl on cl.id_cliente = re.id_cliente
                        left join orga.vfuncionario funapro on funapro.id_funcionario = re.id_funcionario_recepcion
                        inner join param.tgestion pa on pa.id_gestion = re.id_gestion
                        inner join wf.testado_wf eswf on eswf.id_estado_wf = res.id_estado_wf
                        inner join wf.ttipo_estado tip on tip.id_tipo_estado = eswf.id_tipo_estado
                    	where res.id_proceso_wf ='||v_parametros.id_proceso_wf;

            raise notice '%', v_consulta;

            return v_consulta;

        end;
        /*********************************
         #TRANSACCION:  'REC_BUSQ_RES_SEL'
         #DESCRIPCION:	Consulta PARA LA VISTA CONSULTA RESPUESTA
         #AUTOR:		admin
         #FECHA:		09-05-2018 12:00:59
        ***********************************/

    elsif(p_transaccion='REC_BUSQ_RES_SEL')then

        begin
            --RAISE EXCEPTION 'v_filtro: %', v_filtro;
            v_consulta:='select
						res.id_respuesta,
						res.id_reclamo,
						res.recomendaciones,
						res.nro_cite,
						res.respuesta,
						res.fecha_respuesta,
						res.estado_reg,
						res.procedente,
						res.fecha_notificacion,
						res.id_usuario_ai,
						res.id_usuario_reg,
						res.usuario_ai,
						res.fecha_reg,
						res.fecha_mod,
						res.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        res.tipo_respuesta,
                        res.asunto,
                        res.id_proceso_wf,
						res.id_estado_wf,
                        res.estado,
                        res.nro_respuesta,
                        tr.correlativo_preimpreso_frd,
                        tr.nro_frd,
                        tr.detalle_incidente,
                        vc.nombre_completo1::varchar

						from rec.trespuesta res
						inner join segu.tusuario usu1 on usu1.id_usuario = res.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = res.id_usuario_mod
                        inner join rec.treclamo tr on tr.id_reclamo = res.id_reclamo
                        inner join rec.vcliente vc on vc.id_cliente = tr.id_cliente
                        left join wf.testado_wf tew on tew.id_estado_wf = res.id_estado_wf
                        left join rec.tmedio_reclamo tmr on tmr.id_medio_reclamo = tr.id_medio_reclamo

				        where ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            --raise notice '%',v_consulta;
            --Devuelve la respuesta
            return v_consulta;
        end;
/*********************************
 	#TRANSACCION:  'REC_BUSQ_RES_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin
 	#FECHA:		10-08-2016 18:32:59
	***********************************/

    elseif(p_transaccion='REC_BUSQ_RES_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(res.id_reclamo)
			   			from rec.trespuesta res
						inner join segu.tusuario usu1 on usu1.id_usuario = res.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = res.id_usuario_mod
                        inner join rec.treclamo tr on tr.id_reclamo = res.id_reclamo
                        inner join rec.vcliente vc on vc.id_cliente = tr.id_cliente
                        left join wf.testado_wf tew on tew.id_estado_wf = res.id_estado_wf
                        left join rec.tmedio_reclamo tmr on tmr.id_medio_reclamo = tr.id_medio_reclamo

				        where ';



            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;


            raise notice '%',v_consulta;
            --raise EXCEPTION 'miexceppppcion';

            --Devuelve la respuesta
            return v_consulta;

        end;

        /*********************************
         #TRANSACCION:  'REC_RES_QR_SEL'
         #DESCRIPCION:  Generarar codigo QR doc
         #AUTOR:		MAM
         #FECHA:		11-08-2016 16:01:08
        ***********************************/

    elsif(p_transaccion='REC_RES_QR_SEL')then
        begin
            --Sentencia de la consulta

            SELECT left(vf.nombre, 1)||'.'||left(vf.ap_paterno, 1)||'.'||left(vf.ap_materno, 1)||'.'
            INTO v_elaboracion
            FROM wf.ttipo_estado te
                     INNER JOIN wf.testado_wf tef ON tef.id_tipo_estado = te.id_tipo_estado
                     INNER JOIN orga.vfuncionario_personareporte vf ON vf.id_funcionario = tef.id_funcionario
            WHERE tef.id_proceso_wf = v_parametros.id_proceso_wf AND te.codigo = 'elaboracion_respuesta';

            SELECT left(vf.nombre, 1)||'.'||left(vf.ap_paterno, 1)||'.'||left(vf.ap_materno, 1)||'.'
            INTO v_vobo
            FROM wf.ttipo_estado te
                     INNER JOIN wf.testado_wf tef ON tef.id_tipo_estado = te.id_tipo_estado
                     INNER JOIN orga.vfuncionario_personareporte vf ON vf.id_funcionario = tef.id_funcionario
            WHERE tef.id_proceso_wf = v_parametros.id_proceso_wf AND te.codigo = 'vobo_respuesta';


            /*v_consulta:=' SELECT  resp.id_proceso_wf,
                                    resp.id_respuesta,
                                    ''OB.GC.NE.''||resp.nro_cite||''.''||ge.gestion::text as num_cite,
                                    recl.nro_frd,
                                    of.nombre as  oficina,
                                    resp.estado,
                                    (left(pe.nombre, 1)||''.''||left(pe.apellido_paterno, 1)||''.''||left(pe.apellido_materno, 1)||''.''::text)::varchar as  iniciales_fun_reg,
                                    (left(fu.nombre,1)||''.''||left(fu.ap_paterno,1)||''.''||left(fu.ap_materno,1)||''.''::text)::varchar as iniciales_fun_vis
                                  FROM rec.treclamo recl
                                  inner join rec.trespuesta resp on resp.id_reclamo = recl.id_reclamo
                                  inner join rec.toficina  of on of.id_oficina = recl.id_oficina_registro_incidente
                                  inner join segu.tusuario usu1 on usu1.id_usuario = resp.id_usuario_reg
                                  inner join segu.tpersona pe on pe.id_persona = usu1.id_persona
                                  inner join param.tgestion ge on ge.id_gestion = recl.id_gestion
                                  inner join wf.testado_wf wfs on wfs.id_estado_wf = resp.id_estado_wf
                                  inner join orga.vfuncionario_personareporte fu on fu.id_funcionario = wfs.id_funcionario
                                  where resp.id_proceso_wf='||v_parametros.id_proceso_wf;*/



            v_consulta = 'SELECT
            				  tres.id_proceso_wf,
                              tres.id_respuesta,
                              case when tres.fecha_respuesta > ''2021-12-31''::date then ''OB.CX.NE.''||tres.nro_cite||''.''||tg.gestion::text else ''OB.GC.NE.''||tres.nro_cite||''.''||tg.gestion::text end as num_cite,
                              trec.nro_frd,
                              tof.nombre as oficina,
                              tres.estado,
                              '''||v_elaboracion||'''::TEXT AS iniciales_fun_reg,
                              '''||v_vobo||'''::TEXT AS iniciales_fun_vis
							FROM rec.trespuesta tres
                            INNER JOIN rec.treclamo trec ON trec.id_reclamo = tres.id_reclamo
                            INNER JOIN param.tgestion tg ON tg.id_gestion = trec.id_gestion
                            INNER JOIN rec.toficina tof ON tof.id_oficina = trec.id_oficina_registro_incidente
                            where tres.id_proceso_wf = '||v_parametros.id_proceso_wf;

            raise notice 'que esta pasando: %', v_consulta;

            return v_consulta;

        end;
        /*********************************
          #TRANSACCION:  'REC_RECONENV_SEL'
          #DESCRIPCION:	Reporte Constancia de Envio
          #AUTOR:		BVP
          #FECHA:		11-05-2018 16:01:08
          ***********************************/
    elsif(p_transaccion='RES_RECONENV_SEL')then
        begin
            --raise notice '%',v_parametros.id_proceso_wf;
            v_consulta ='
              select
                 res.email,
                 res.nombre_cliente,
                 al.titulo_correo,
                 pxp.f_fecha_literal(res.fecha_respuesta) as fecha_respuesta,
                 to_char(al.fecha_reg,''HH24:MI'') as hora,
                 rec.f_dia_literal(res.fecha_respuesta) dia,
                 res.estado,
                 res.asunto,
                 res.correos_extras,
                 al.descripcion,
                 plan.cc,
                 plan.bcc,
                 res.tipo_respuesta ,
                 res.procedente,
                 al.correos
          from rec.vrespuesta res
               inner join wf.testado_wf tes on tes.id_estado_wf = res.id_estado_wf
               inner join wf.tplantilla_correo plan on plan.id_tipo_estado =tes.id_tipo_estado
               inner join rec.treclamo re on re.id_reclamo = res.id_reclamo
               inner join rec.trespuesta respu on respu.id_respuesta = res.id_respuesta
               inner join param.talarma al on al.id_proceso_wf = res.id_proceso_wf
               where res.id_proceso_wf ='||v_parametros.id_proceso_wf;

            --raise notice '%',v_consulta;
            return v_consulta;
        end;
        /*********************************
         #TRANSACCION:   'REC_ANSWER_LIST'
         #DESCRIPCION:	Consulta de listado de respuestas
         #AUTOR:		    franklin.espinoza
         #FECHA:		    11-01-2023 16:01:08
        ***********************************/
    elsif(p_transaccion='REC_ANSWER_LIST')then

        begin

            SELECT vfcl.id_oficina, vfcl.nombre_cargo,  vfcl.oficina_nombre,
                   tf.id_funcionario, vfcl.desc_funcionario1 INTO v_record
            FROM segu.tusuario tu
                     INNER JOIN orga.tfuncionario tf on tf.id_persona = tu.id_persona
                     INNER JOIN orga.vfuncionario_cargo_lugar vfcl on vfcl.id_funcionario = tf.id_funcionario
            WHERE tu.id_usuario = p_id_usuario ;

            IF (p_administrador) THEN
                v_filtro= '0 = 0 AND ';
            ELSE
                v_filtro = '(tew.id_funcionario = '||v_record.id_funcionario||' OR res.id_usuario_reg = '||p_id_usuario||') AND ';
            END IF;

            --raise notice 'v_filtro: %',v_filtro;
            --raise 'v_record: %',v_record;
            --Sentencia de la consulta
            v_consulta:='select ROW_TO_JSON(listAnswer)
                        from (
                            select (
                                    select coalesce(ARRAY_TO_JSON(ARRAY_AGG(answer)), ''[]''::json)
                                    from (select
                                        res.id_respuesta,
                                        res.id_reclamo,
                                        res.recomendaciones,
                                        res.nro_cite,
                                        res.respuesta,
                                        res.fecha_respuesta,
                                        res.estado_reg,
                                        res.procedente,
                                        res.fecha_notificacion,
                                        res.id_usuario_ai,
                                        res.id_usuario_reg,
                                        res.usuario_ai,
                                        res.fecha_reg,
                                        res.fecha_mod,
                                        res.id_usuario_mod,
                                        usu1.cuenta as usr_reg,
                                        usu2.cuenta as usr_mod,
                                        res.tipo_respuesta,
                                        res.asunto,
                                        res.id_proceso_wf,
                                        res.id_estado_wf,
                                        res.estado,
                                        res.nro_respuesta,
                                        vc.email,
                                        '||p_administrador||'::integer AS admin,
                                        tmr.codigo as codigo_medio,
                                        tr.nro_att_canalizado as nro_att,
                                        vc.nombre_completo2::varchar as nom_cliente,
                                        (select count(ti.id_informe) from rec.tinforme ti where ti.id_reclamo = tr.id_reclamo)::integer cantidad_informe,
                                        rec.f_dias_respuesta(now()::date, tr.fecha_hora_recepcion::date, ''DIAS_INF'')::varchar as dias_informe,
                                        rec.f_verificar_dias(CURRENT_DATE, tr.fecha_limite_respuesta)::varchar as dias_respuesta,
                                        tr.fecha_limite_respuesta
                                        from rec.trespuesta res
                                        inner join segu.tusuario usu1 on usu1.id_usuario = res.id_usuario_reg
                                        left join segu.tusuario usu2 on usu2.id_usuario = res.id_usuario_mod
                                        inner join rec.treclamo tr on tr.id_reclamo = res.id_reclamo
                                        inner join rec.vcliente vc on vc.id_cliente = tr.id_cliente
                                        left join wf.testado_wf tew on tew.id_estado_wf = res.id_estado_wf
                                        left join rec.tmedio_reclamo tmr on tmr.id_medio_reclamo = tr.id_medio_reclamo
                                        LEFT JOIN orga.vfuncionario_cargo_lugar vfc on vfc.id_funcionario =  tew.id_funcionario
                                        where '||v_filtro;

            --Definicion de la respuesta
            v_consulta = v_consulta || v_parametros.filtro;
            v_consulta = v_consulta || ' order by res.id_respuesta asc limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            v_consulta = v_consulta || ') answer
                                ) answers,
                                (
                                    select count(res.id_respuesta)
                                    from rec.trespuesta res
                                    inner join segu.tusuario usu1 on usu1.id_usuario = res.id_usuario_reg
                                    left join segu.tusuario usu2 on usu2.id_usuario = res.id_usuario_mod
                                    inner join rec.treclamo tr on tr.id_reclamo = res.id_reclamo
                                    inner join rec.vcliente vc on vc.id_cliente = tr.id_cliente
                                    left join wf.testado_wf tew on tew.id_estado_wf = res.id_estado_wf
                                    left join rec.tmedio_reclamo tmr on tmr.id_medio_reclamo = tr.id_medio_reclamo
                                    LEFT JOIN orga.vfuncionario_cargo_lugar vfc on vfc.id_funcionario = tew.id_funcionario
                                    where '||v_filtro||v_parametros.filtro||'
                                    ) total
                         ) listAnswer';
            --Devuelve la respuesta
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

ALTER FUNCTION rec.ft_respuesta_sel (p_administrador integer, p_id_usuario integer, p_tabla varchar, p_transaccion varchar)
    OWNER TO postgres;