CREATE OR REPLACE FUNCTION "rec"."ft_cliente_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Gestion de Reclamos
 FUNCION: 		rec.ft_cliente_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'rec.tcliente'
 AUTOR: 		 (admin)
 FECHA:	        12-08-2016 14:29:16
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
	v_id_cliente	integer;
			    
BEGIN

    v_nombre_funcion = 'rec.ft_cliente_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'REC_CLI_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		12-08-2016 14:29:16
	***********************************/

	if(p_transaccion='REC_CLI_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into rec.tcliente(
			genero,
			ci,
			email,
			direccion,
			celular,
			nombre,
			lugar_expedicion,
			apellido_paterno,
			telefono,
			ciudad_residencia,
			pais_residencia,
			nacionalidad,
			barrio_zona,
			estado_reg,
			apellido_materno,
			id_usuario_ai,
			fecha_reg,
			usuario_ai,
			id_usuario_reg,
			fecha_mod,
			id_usuario_mod
          	) values(
			v_parametros.genero,
			v_parametros.ci,
			v_parametros.email,
			v_parametros.direccion,
			v_parametros.celular,
			v_parametros.nombre,
			v_parametros.lugar_expedicion,
			v_parametros.apellido_paterno,
			v_parametros.telefono,
			v_parametros.ciudad_residencia,
			v_parametros.pais_residencia,
			v_parametros.nacionalidad,
			v_parametros.barrio_zona,
			'activo',
			v_parametros.apellido_materno,
			v_parametros._id_usuario_ai,
			now(),
			v_parametros._nombre_usuario_ai,
			p_id_usuario,
			null,
			null
							
			
			
			)RETURNING id_cliente into v_id_cliente;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','cliente almacenado(a) con exito (id_cliente'||v_id_cliente||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_cliente',v_id_cliente::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'REC_CLI_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		12-08-2016 14:29:16
	***********************************/

	elsif(p_transaccion='REC_CLI_MOD')then

		begin
			--Sentencia de la modificacion
			update rec.tcliente set
			genero = v_parametros.genero,
			ci = v_parametros.ci,
			email = v_parametros.email,
			direccion = v_parametros.direccion,
			celular = v_parametros.celular,
			nombre = v_parametros.nombre,
			lugar_expedicion = v_parametros.lugar_expedicion,
			apellido_paterno = v_parametros.apellido_paterno,
			telefono = v_parametros.telefono,
			ciudad_residencia = v_parametros.ciudad_residencia,
			pais_residencia = v_parametros.pais_residencia,
			nacionalidad = v_parametros.nacionalidad,
			barrio_zona = v_parametros.barrio_zona,
			apellido_materno = v_parametros.apellido_materno,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_cliente=v_parametros.id_cliente;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','cliente modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_cliente',v_parametros.id_cliente::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'REC_CLI_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		12-08-2016 14:29:16
	***********************************/

	elsif(p_transaccion='REC_CLI_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from rec.tcliente
            where id_cliente=v_parametros.id_cliente;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','cliente eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_cliente',v_parametros.id_cliente::varchar);
              
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
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "rec"."ft_cliente_ime"(integer, integer, character varying, character varying) OWNER TO postgres;