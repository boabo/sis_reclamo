<?php
/**
*@package pXP
*@file gen-MODReclamo.php
*@author  (admin)
*@date 10-08-2016 18:32:59
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODReclamo extends MODbase
{

	function __construct(CTParametro $pParam)
	{
		parent::__construct($pParam);
	}

	function listarReclamo()
	{
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'rec.ft_reclamo_sel';
		$this->transaccion = 'REC_REC_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_reclamo', 'int4');
		$this->captura('id_tipo_incidente', 'int4');
		$this->captura('id_subtipo_incidente', 'int4');
		$this->captura('id_medio_reclamo', 'int4');
		$this->captura('id_funcionario_recepcion', 'int4');
		$this->captura('id_funcionario_denunciado', 'int4');
		$this->captura('id_oficina_incidente', 'int4');
		$this->captura('id_oficina_registro_incidente', 'int4');
		$this->captura('id_proceso_wf', 'int4');
		$this->captura('id_estado_wf', 'int4');
		$this->captura('id_cliente', 'int4');
		$this->captura('estado', 'varchar');
		$this->captura('fecha_hora_incidente', 'timestamp');
		$this->captura('nro_ripat_att', 'int4');
		$this->captura('nro_hoja_ruta', 'int4');
		$this->captura('fecha_hora_recepcion', 'timestamp');
		$this->captura('estado_reg', 'varchar');
		$this->captura('fecha_hora_vuelo', 'timestamp');
		$this->captura('origen', 'varchar');
		$this->captura('nro_frd', 'varchar');
		$this->captura('correlativo_preimpreso_frd', 'int4');
		$this->captura('fecha_limite_respuesta', 'date');
		$this->captura('observaciones_incidente', 'text');
		$this->captura('destino', 'varchar');
		$this->captura('nro_pir', 'int4');
		$this->captura('nro_frsa', 'int4');
		$this->captura('nro_att_canalizado', 'int4');
		$this->captura('nro_tramite', 'varchar');
		$this->captura('detalle_incidente', 'text');
		$this->captura('pnr', 'varchar');
		$this->captura('nro_vuelo', 'varchar');
		$this->captura('id_usuario_reg', 'int4');
		$this->captura('fecha_reg', 'timestamp');
		$this->captura('usuario_ai', 'varchar');
		$this->captura('id_usuario_ai', 'int4');
		$this->captura('fecha_mod', 'timestamp');
		$this->captura('id_usuario_mod', 'int4');
		$this->captura('usr_reg', 'varchar');
		$this->captura('usr_mod', 'varchar');
		$this->captura('id_gestion', 'int4');
		$this->captura('id_motivo_anulado', 'int4');

		//$this->captura('id_motivo_anulado','int4');

		$this->captura('desc_nombre_medio', 'varchar');
		$this->captura('desc_nom_cliente', 'text');
		$this->captura('desc_nombre_incidente', 'varchar');
		$this->captura('desc_nombre_oficina', 'varchar');
		$this->captura('desc_oficina_registro_incidente', 'varchar');
		$this->captura('desc_sudnom_incidente', 'varchar');
		$this->captura('desc_nombre_funcionario', 'text');
		$this->captura('desc_nombre_fun_denun', 'text');

		$this->captura('tiempo_respuesta', 'varchar');
		$this->captura('revisado', 'varchar');
		$this->captura('transito', 'varchar');
		$this->captura('dias_respuesta', 'varchar');
		$this->captura('dias_informe', 'varchar');

		$this->captura('motivo_anulado', 'varchar');
		$this->captura('nro_cite', 'varchar');//
		$this->captura('conclusion_recomendacion', 'varchar');
		$this->captura('recomendaciones', 'varchar');
		$this->captura('genero', 'varchar');//
		$this->captura('ci', 'varchar');//
		$this->captura('telefono', 'varchar');//
		$this->captura('email', 'varchar');//
		$this->captura('email2', 'varchar');//
		$this->captura('ciudad_residencia', 'varchar');//
		$this->captura('nro_guia_aerea', 'varchar');//

		//$this->captura('nombre_cargo', 'varchar');

		//$this->captura('cargo', 'varchar');

		$this->captura('nombre_completo2', 'text');
		$this->captura('administrador', 'int4');
		$this->captura('id_informe', 'int4');

		//$this->captura('nombre', 'varchar');



		$this->setParametro('id_usuario', 'id_usuario', 'int4');
		$this->setParametro('tipo_interfaz', 'tipo_interfaz', 'varchar');


		//Ejecuta la instruccion
		$this->armarConsulta();
        //var_dump($this->consulta);exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarCRMGlobal()
	{
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'rec.ft_reclamo_sel';
		$this->transaccion = 'REC_CRMG_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion
		//$this->setCount(false);
		//Definicion de la lista del resultado del query
		$this->captura('id_reclamo', 'int4');
		$this->captura('id_tipo_incidente', 'int4');
		$this->captura('id_subtipo_incidente', 'int4');
		$this->captura('id_medio_reclamo', 'int4');
		$this->captura('id_funcionario_recepcion', 'int4');
		$this->captura('id_funcionario_denunciado', 'int4');
		$this->captura('id_oficina_incidente', 'int4');
		$this->captura('id_oficina_registro_incidente', 'int4');
		$this->captura('id_proceso_wf', 'int4');
		$this->captura('id_estado_wf', 'int4');
		$this->captura('id_cliente', 'int4');
		$this->captura('estado', 'varchar');
		$this->captura('fecha_hora_incidente', 'timestamp');
		$this->captura('nro_ripat_att', 'int4');
		$this->captura('nro_hoja_ruta', 'int4');
		$this->captura('fecha_hora_recepcion', 'timestamp');
		$this->captura('estado_reg', 'varchar');
		$this->captura('fecha_hora_vuelo', 'timestamp');
		$this->captura('origen', 'varchar');
		$this->captura('nro_frd', 'varchar');
		$this->captura('correlativo_preimpreso_frd', 'int4');
		$this->captura('fecha_limite_respuesta', 'date');
		$this->captura('observaciones_incidente', 'text');
		$this->captura('destino', 'varchar');
		$this->captura('nro_pir', 'int4');
		$this->captura('nro_frsa', 'int4');
		$this->captura('nro_att_canalizado', 'int4');
		$this->captura('nro_tramite', 'varchar');
		$this->captura('detalle_incidente', 'text');
		$this->captura('pnr', 'varchar');
		$this->captura('nro_vuelo', 'varchar');
		$this->captura('id_usuario_reg', 'int4');
		$this->captura('fecha_reg', 'timestamp');
		$this->captura('usuario_ai', 'varchar');
		$this->captura('id_usuario_ai', 'int4');
		$this->captura('fecha_mod', 'timestamp');
		$this->captura('id_usuario_mod', 'int4');
		$this->captura('usr_reg', 'varchar');
		$this->captura('usr_mod', 'varchar');
		$this->captura('id_gestion', 'int4');
		$this->captura('id_motivo_anulado', 'int4');

		//$this->captura('id_motivo_anulado','int4');

		$this->captura('desc_nombre_medio', 'varchar');
		$this->captura('desc_nom_cliente', 'text');
		$this->captura('desc_nombre_incidente', 'varchar');
		$this->captura('desc_nombre_oficina', 'varchar');
		$this->captura('desc_oficina_registro_incidente', 'varchar');
		$this->captura('desc_sudnom_incidente', 'varchar');
		$this->captura('desc_nombre_funcionario', 'text');
		$this->captura('desc_nombre_fun_denun', 'text');

		$this->captura('tiempo_respuesta', 'varchar');
		$this->captura('revisado', 'varchar');
		$this->captura('transito', 'varchar');
		$this->captura('dias_respuesta', 'varchar');
		$this->captura('dias_informe', 'varchar');

		$this->captura('motivo_anulado', 'varchar');
		$this->captura('nro_cite', 'varchar');//
		$this->captura('conclusion_recomendacion', 'varchar');
		$this->captura('recomendaciones', 'varchar');
		$this->captura('genero', 'varchar');//
		$this->captura('ci', 'varchar');//
		$this->captura('telefono', 'varchar');//
		$this->captura('email', 'varchar');//
		$this->captura('ciudad_residencia', 'varchar');//
		$this->captura('nro_guia_aerea', 'varchar');//
		$this->captura('nombre_cargo', 'varchar');
		$this->captura('ult_fecha', 'timestamp');
		$this->captura('ult_estado', 'varchar');
		$this->captura('tiempo_resolucion_rec', 'varchar');

		$this->setParametro('id_usuario', 'id_usuario', 'int4');


		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

    function listarConsulta()
    {
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_CONSULTA_SEL';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion
        //$this->setCount(false);
        //Definicion de la lista del resultado del query
        $this->captura('id_reclamo', 'int4');
        $this->captura('id_tipo_incidente', 'int4');
        $this->captura('id_subtipo_incidente', 'int4');
        $this->captura('id_medio_reclamo', 'int4');
        $this->captura('id_funcionario_recepcion', 'int4');
        $this->captura('id_funcionario_denunciado', 'int4');
        $this->captura('id_oficina_incidente', 'int4');
        $this->captura('id_oficina_registro_incidente', 'int4');
        $this->captura('id_proceso_wf', 'int4');
        $this->captura('id_estado_wf', 'int4');
        $this->captura('id_cliente', 'int4');
        $this->captura('estado', 'varchar');
        $this->captura('fecha_hora_incidente', 'timestamp');
        $this->captura('nro_ripat_att', 'int4');
        $this->captura('nro_hoja_ruta', 'int4');
        $this->captura('fecha_hora_recepcion', 'timestamp');
        $this->captura('estado_reg', 'varchar');
        $this->captura('fecha_hora_vuelo', 'timestamp');
        $this->captura('origen', 'varchar');
        $this->captura('nro_frd', 'varchar');
        $this->captura('correlativo_preimpreso_frd', 'int4');
        $this->captura('fecha_limite_respuesta', 'date');
        $this->captura('observaciones_incidente', 'text');
        $this->captura('destino', 'varchar');
        $this->captura('nro_pir', 'int4');
        $this->captura('nro_frsa', 'int4');
        $this->captura('nro_att_canalizado', 'int4');
        $this->captura('nro_tramite', 'varchar');
        $this->captura('detalle_incidente', 'text');
        $this->captura('pnr', 'varchar');
        $this->captura('nro_vuelo', 'varchar');
        $this->captura('id_usuario_reg', 'int4');
        $this->captura('fecha_reg', 'timestamp');
        $this->captura('usuario_ai', 'varchar');
        $this->captura('id_usuario_ai', 'int4');
        $this->captura('fecha_mod', 'timestamp');
        $this->captura('id_usuario_mod', 'int4');
        $this->captura('usr_reg', 'varchar');
        $this->captura('usr_mod', 'varchar');
        $this->captura('id_gestion', 'int4');
        $this->captura('id_motivo_anulado', 'int4');
        $this->captura('desc_nombre_medio', 'varchar');
        $this->captura('desc_nom_cliente', 'text');
        $this->captura('desc_nombre_incidente', 'varchar');
        $this->captura('desc_nombre_oficina', 'varchar');
        $this->captura('desc_oficina_registro_incidente', 'varchar');
        $this->captura('desc_sudnom_incidente', 'varchar');
        $this->captura('desc_nombre_funcionario', 'text');
        $this->captura('desc_nombre_fun_denun', 'text');
        $this->captura('revisado', 'varchar');
        $this->captura('transito', 'varchar');
        $this->captura('motivo_anulado', 'varchar');
        $this->captura('nro_guia_aerea', 'varchar');//
        //$this->captura('nombre_cargo', 'varchar');
        $this->captura('nombre_completo2', 'text');
        $this->captura('nro_cite', 'varchar');

        $this->setParametro('id_usuario', 'id_usuario', 'int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo $this->consulta;exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

	function insertarReclamo()
	{
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_REC_INS';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_tipo_incidente', 'id_tipo_incidente', 'int4');
		$this->setParametro('id_subtipo_incidente', 'id_subtipo_incidente', 'int4');
		$this->setParametro('id_medio_reclamo', 'id_medio_reclamo', 'int4');
		$this->setParametro('id_funcionario_recepcion', 'id_funcionario_recepcion', 'int4');
		$this->setParametro('id_funcionario_denunciado', 'id_funcionario_denunciado', 'int4');
		$this->setParametro('id_oficina_incidente', 'id_oficina_incidente', 'int4');
		$this->setParametro('id_oficina_registro_incidente', 'id_oficina_registro_incidente', 'int4');
		$this->setParametro('id_proceso_wf', 'id_proceso_wf', 'int4');
		$this->setParametro('id_estado_wf', 'id_estado_wf', 'int4');
		$this->setParametro('id_proceso_macro', 'id_proceso_macro', 'int4');
		$this->setParametro('id_cliente', 'id_cliente', 'int4');
		$this->setParametro('estado', 'estado', 'varchar');
		$this->setParametro('fecha_hora_incidente', 'fecha_hora_incidente', 'timestamp');
		$this->setParametro('nro_ripat_att', 'nro_ripat_att', 'int4');
		$this->setParametro('nro_hoja_ruta', 'nro_hoja_ruta', 'int4');
		$this->setParametro('fecha_hora_recepcion', 'fecha_hora_recepcion', 'timestamp');
		$this->setParametro('estado_reg', 'estado_reg', 'varchar');
		$this->setParametro('fecha_hora_vuelo', 'fecha_hora_vuelo', 'timestamp');
		$this->setParametro('origen', 'origen', 'varchar');
		$this->setParametro('nro_frd', 'nro_frd', 'varchar');
		$this->setParametro('correlativo_preimpreso_frd', 'correlativo_preimpreso_frd', 'int4');
		//$this->setParametro('fecha_limite_respuesta', 'fecha_limite_respuesta', 'date');
		$this->setParametro('observaciones_incidente', 'observaciones_incidente', 'text');
		$this->setParametro('destino', 'destino', 'varchar');
		$this->setParametro('nro_pir', 'nro_pir', 'int4');
		$this->setParametro('nro_frsa', 'nro_frsa', 'int4');
		$this->setParametro('nro_att_canalizado', 'nro_att_canalizado', 'int4');
		$this->setParametro('nro_tramite', 'nro_tramite', 'varchar');
		$this->setParametro('detalle_incidente', 'detalle_incidente', 'text');
		$this->setParametro('pnr', 'pnr', 'varchar');
		$this->setParametro('nro_vuelo', 'nro_vuelo', 'varchar');
		$this->setParametro('id_gestion', 'id_gestion', 'int4');
		$this->setParametro('id_motivo_anulado', 'id_motivo_anulado', 'int4');

		$this->setParametro('transito', 'transito', 'varchar');

		//$this->setParametro('correlativo','correlativo',  'int4');
		//Ejecuta la instruccion
		$this->armarConsulta(); //echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarReclamo()
	{
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_REC_MOD';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_reclamo', 'id_reclamo', 'int4');
		$this->setParametro('id_tipo_incidente', 'id_tipo_incidente', 'int4');
		$this->setParametro('id_subtipo_incidente', 'id_subtipo_incidente', 'int4');
		$this->setParametro('id_medio_reclamo', 'id_medio_reclamo', 'int4');
		$this->setParametro('id_funcionario_recepcion', 'id_funcionario_recepcion', 'int4');
		$this->setParametro('id_funcionario_denunciado', 'id_funcionario_denunciado', 'int4');
		$this->setParametro('id_oficina_incidente', 'id_oficina_incidente', 'int4');
		$this->setParametro('id_oficina_registro_incidente', 'id_oficina_registro_incidente', 'int4');
		$this->setParametro('id_proceso_wf', 'id_proceso_wf', 'int4');
		$this->setParametro('id_estado_wf', 'id_estado_wf', 'int4');
		$this->setParametro('id_proceso_macro', 'id_proceso_macro', 'int4');
		$this->setParametro('id_cliente', 'id_cliente', 'int4');
		$this->setParametro('estado', 'estado', 'varchar');
		$this->setParametro('fecha_hora_incidente', 'fecha_hora_incidente', 'timestamp');
		$this->setParametro('nro_ripat_att', 'nro_ripat_att', 'int4');
		$this->setParametro('nro_hoja_ruta', 'nro_hoja_ruta', 'int4');
		$this->setParametro('fecha_hora_recepcion', 'fecha_hora_recepcion', 'timestamp');
		$this->setParametro('estado_reg', 'estado_reg', 'varchar');
		$this->setParametro('fecha_hora_vuelo', 'fecha_hora_vuelo', 'timestamp');
		$this->setParametro('origen', 'origen', 'varchar');
		$this->setParametro('nro_frd', 'nro_frd', 'varchar');
		$this->setParametro('correlativo_preimpreso_frd', 'correlativo_preimpreso_frd', 'int4');
		//$this->setParametro('fecha_limite_respuesta', 'fecha_limite_respuesta', 'date');
		$this->setParametro('observaciones_incidente', 'observaciones_incidente', 'text');
		$this->setParametro('destino', 'destino', 'varchar');
		$this->setParametro('nro_pir', 'nro_pir', 'int4');
		$this->setParametro('nro_frsa', 'nro_frsa', 'int4');
		$this->setParametro('nro_att_canalizado', 'nro_att_canalizado', 'int4');
		$this->setParametro('nro_tramite', 'nro_tramite', 'varchar');
		$this->setParametro('detalle_incidente', 'detalle_incidente', 'text');
		$this->setParametro('pnr', 'pnr', 'varchar');
		$this->setParametro('nro_vuelo', 'nro_vuelo', 'varchar');
		//$this->captura('id_gestion','id_gestion','int4');
		$this->setParametro('id_motivo_anulado', 'id_motivo_anulado', 'int4');
		$this->setParametro('transito', 'transito', 'varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		/*var_dump($this->respuesta);
		exit;*/
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarReclamo()
	{
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_REC_ELI';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_reclamo', 'id_reclamo', 'int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}


	function siguienteEstadoReclamo()
	{
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_SIGEREC_IME';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_proceso_wf_act', 'id_proceso_wf_act', 'int4');
		$this->setParametro('id_estado_wf_act', 'id_estado_wf_act', 'int4');
		$this->setParametro('id_funcionario_usu', 'id_funcionario_usu', 'int4');
		$this->setParametro('id_tipo_estado', 'id_tipo_estado', 'int4');
		$this->setParametro('id_funcionario_wf', 'id_funcionario_wf', 'int4');
		$this->setParametro('id_depto_wf', 'id_depto_wf', 'int4');
		$this->setParametro('obs', 'obs', 'text');
		$this->setParametro('json_procesos', 'json_procesos', 'text');

		$this->setParametro('f_actual', 'f_actual', 'timestamp');
		$this->setParametro('nombreVista', 'nombreVista', 'varchar');


		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function stadistica()
	{
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_STADISTICA_GET';
		$this->tipo_procedimiento = 'IME';


		$this->setParametro('p_tipo', 'p_tipo', 'varchar');
		$this->setParametro('id_gestion', 'id_gestion', 'varchar');
		$this->setParametro('p_desde', 'p_desde', 'varchar');
		$this->setParametro('p_hasta', 'p_hasta', 'varchar');
		$this->setParametro('id_oficina', 'id_oficina', 'varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();

		//var_dump($this->consulta);exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function anteriorEstadoReclamo()
	{
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_ANTEREC_IME';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_reclamo', 'id_reclamo', 'int4');
		$this->setParametro('id_proceso_wf', 'id_proceso_wf', 'int4');
		$this->setParametro('id_funcionario_usu', 'id_funcionario_usu', 'int4');
		$this->setParametro('operacion', 'operacion', 'varchar');

		$this->setParametro('id_funcionario', 'id_funcionario', 'int4');
		$this->setParametro('id_tipo_estado', 'id_tipo_estado', 'int4');
		$this->setParametro('id_estado_wf', 'id_estado_wf', 'int4');
		$this->setParametro('obs', 'obs', 'text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function getNombreFun()
	{
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_FUNNOM_GET';
		$this->tipo_procedimiento = 'IME';

		$this->setParametro('id_funcionario', 'id_funcionario', 'int4');
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function getDatosOficina()
	{
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_DATOFI_GET';
		$this->tipo_procedimiento = 'IME';

		$this->setParametro('id_usuario', 'id_usuario', 'integer');
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarRest()
	{
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_REST_SEL';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_reclamo', 'id_reclamo', 'int4');

		/*$this->captura('tramite', 'varchar');
		$this->captura('id_estado', 'int4');
		$this->captura('id_proceso', 'int4');
		$this->captura('nro_respuestas', 'int4');*/

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function reportesReclamo()
	{
		$this->procedimiento = 'rec.ft_reclamo_sel';
		$this->transaccion = 'REC_REPOR_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion

		$this->setCount(false);
		$this->setParametro('id_proceso_wf', 'id_proceso_wf', 'int4');

		$this->captura('id_reclamo', 'int4');
		$this->captura('id_proceso_wf', 'int4');
		$this->captura('id_estado_wf', 'int4');
		$this->captura('estado', 'varchar');
		$this->captura('fecha_hora_incidente', 'timestamp');
		$this->captura('fecha_hora_recepcion', 'timestamp');
		$this->captura('estado_reg', 'varchar');
		$this->captura('fecha_hora_vuelo', 'timestamp');
		$this->captura('origen', 'varchar');
		$this->captura('nro_frd', 'varchar');
		$this->captura('correlativo_preimpreso_frd', 'int4');
		$this->captura('fecha_limite_respuesta', 'date');
		$this->captura('observaciones_incidente', 'text');
		$this->captura('destino', 'varchar');
		$this->captura('nro_att_canalizado', 'int4');
		$this->captura('nro_tramite', 'varchar');
		$this->captura('detalle_incidente', 'text');
		$this->captura('nro_vuelo', 'varchar');
		$this->captura('usr_reg', 'varchar');
		$this->captura('usr_mod', 'varchar');
		$this->captura('desc_nombre_medio', 'varchar');
		$this->captura('desc_nom_cliente', 'text');
		$this->captura('desc_incidente', 'varchar');
		$this->captura('desc_sudnom_incidente', 'varchar');
		$this->captura('desc_oficina', 'varchar');
		$this->captura('desc_oficina_registro_incidente', 'varchar');
		$this->captura('desc_nombre_funcionario', 'text');
		$this->captura('desc_nombre_fun_denun', 'text');

		$this->captura('nombre_cliente', 'varchar');
		$this->captura('apellidos', 'text');
		$this->captura('ci', 'varchar');
		$this->captura('celular', 'varchar');
		$this->captura('email', 'varchar');
		$this->captura('pais', 'varchar');
		$this->captura('ciudad', 'varchar');
		$this->captura('direccion', 'varchar');
		$this->captura('barrio_zona', 'varchar');
		$this->captura('lugar_expedicion', 'varchar');
		$this->captura('fecha_reg', 'date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		//var_dump($this->respuesta); exit;
		//Devuelve la respuesta
		return $this->respuesta;

	}

	function listarResp()
	{
		$this->setCount(false);
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='rec.ft_reclamo_sel';
		$this->transaccion='REC_LIBRESP_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		//echo 'llega2';exit;
		$this->setParametro('id_oficina_registro_incidente','id_oficina_registro_incidente','integer');
		$this->setParametro('fecha_ini','fecha_ini','date');
		$this->setParametro('fecha_fin','fecha_fin','date');


		$this->captura('fecha','date');
		$this->captura('correlativo','varchar');
		$this->captura('tipo','varchar');
		$this->captura('subtipo','varchar');
		$this->captura('oficina','varchar');
		$this->captura('cliente','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//var_dump( $this->consulta); exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarOficinas(){
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_OFICINAS_SEL';
        $this->tipo_procedimiento = 'SEL';
        //$this->setCount(false);

        $this->captura('id_oficina','int4');
        $this->captura('aeropuerto','varchar');
        $this->captura('id_lugar','int4');
        $this->captura('nombre','varchar');
        $this->captura('codigo','varchar');
        $this->captura('estado_reg','varchar');
        $this->captura('fecha_reg','timestamp');
        $this->captura('id_usuario_reg','int4');
        $this->captura('fecha_mod','timestamp');
        $this->captura('id_usuario_mod','int4');
        $this->captura('usr_reg','varchar');
        $this->captura('usr_mod','varchar');
        $this->captura('nombre_lugar','varchar');
        $this->captura('zona_franca','varchar');
        $this->captura('frontera','varchar');

        $this->armarConsulta();
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }

	function getFRD(){
		$this->procedimiento = 'rec.ft_reclamo_ime';
		$this->transaccion = 'REC_FRD_GET';
		$this->tipo_procedimiento = 'IME';

		$this->setParametro('oficina','oficina','varchar');

		$this->armarConsulta();
		$this->ejecutarConsulta();
		//Devuelve la respuesta
		return $this->respuesta;
	}

    function generarReporteGrafico(){
        //var_dump('puriskiri');exit;
    }

    function listarRegRipat(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_REG_RIP';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion
        $this->setCount(false);
        //Definicion de la lista del resultado del query
        $this->captura('id_reclamo', 'int4');
        $this->captura('id_tipo_incidente', 'int4');
        $this->captura('id_subtipo_incidente', 'int4');
        $this->captura('id_medio_reclamo', 'int4');
        $this->captura('id_funcionario_recepcion', 'int4');
        $this->captura('id_funcionario_denunciado', 'int4');
        $this->captura('id_oficina_incidente', 'int4');
        $this->captura('id_oficina_registro_incidente', 'int4');
        $this->captura('id_proceso_wf', 'int4');
        $this->captura('id_estado_wf', 'int4');
        $this->captura('id_cliente', 'int4');
        $this->captura('estado', 'varchar');
        $this->captura('fecha_hora_incidente', 'timestamp');
        $this->captura('nro_ripat_att', 'int4');
        $this->captura('nro_hoja_ruta', 'int4');
        $this->captura('fecha_hora_recepcion', 'timestamp');
        $this->captura('estado_reg', 'varchar');
        $this->captura('fecha_hora_vuelo', 'timestamp');
        $this->captura('origen', 'varchar');
        $this->captura('nro_frd', 'varchar');
        $this->captura('correlativo_preimpreso_frd', 'int4');
        $this->captura('fecha_limite_respuesta', 'date');
        $this->captura('observaciones_incidente', 'text');
        $this->captura('destino', 'varchar');
        $this->captura('nro_pir', 'int4');
        $this->captura('nro_frsa', 'int4');
        $this->captura('nro_att_canalizado', 'int4');
        $this->captura('nro_tramite', 'varchar');
        $this->captura('detalle_incidente', 'text');
        $this->captura('pnr', 'varchar');
        $this->captura('nro_vuelo', 'varchar');
        $this->captura('id_usuario_reg', 'int4');
        $this->captura('fecha_reg', 'timestamp');
        $this->captura('usuario_ai', 'varchar');
        $this->captura('id_usuario_ai', 'int4');
        $this->captura('fecha_mod', 'timestamp');
        $this->captura('id_usuario_mod', 'int4');
        $this->captura('usr_reg', 'varchar');
        $this->captura('usr_mod', 'varchar');
        $this->captura('id_gestion', 'int4');
        $this->captura('id_motivo_anulado', 'int4');

        $this->captura('desc_nombre_medio', 'varchar');
        $this->captura('desc_nom_cliente', 'text');
        $this->captura('desc_nombre_incidente', 'varchar');
        $this->captura('desc_nombre_oficina', 'varchar');
        $this->captura('desc_oficina_registro_incidente', 'varchar');
        $this->captura('desc_sudnom_incidente', 'varchar');
        $this->captura('desc_nombre_funcionario', 'text');
        $this->captura('desc_nombre_fun_denun', 'text');

        $this->captura('tiempo_respuesta', 'varchar');
        $this->captura('revisado', 'varchar');
        $this->captura('transito', 'varchar');
        $this->captura('dias_respuesta', 'varchar');
        $this->captura('dias_informe', 'varchar');

        $this->captura('motivo_anulado', 'varchar');
        $this->captura('nro_cite', 'varchar');//
        $this->captura('conclusion_recomendacion', 'varchar');
        $this->captura('recomendaciones', 'varchar');
        $this->captura('genero', 'varchar');//
        $this->captura('ci', 'varchar');//
        $this->captura('telefono', 'varchar');//
        $this->captura('email', 'varchar');//
        $this->captura('ciudad_residencia', 'varchar');//
        $this->captura('nro_guia_aerea', 'varchar');//



        $this->captura('nombre_completo2', 'text');
        $this->captura('administrador', 'int4');


        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }

    function validarReclamo(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_reclamo_ime';
        $this->transaccion='REC_VALIDAR_GET';
        $this->tipo_procedimiento='IME';//tipo de transaccion
        $this->setCount(false);

        $this->setParametro('correlativo','correlativo','varchar');
        $this->setParametro('frd','frd','varchar');
        $this->setParametro('oficina','oficina','int4');


        $this->captura('v_valid','varchar');


        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->respuesta); exit;
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }

	function listarFails(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='rec.ft_reclamo_sel';
		$this->transaccion='REC_FAILS_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		$this->captura('id_reclamo', 'int4');
		$this->captura('nro_tramite','varchar');
		$this->captura('id_cliente','int4');
		$this->captura('falla','varchar');
		$this->captura('desc_funcionario','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//var_dump($this->respuesta); exit;
		$this->ejecutarConsulta();
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function cambiarArchivadoConcluido(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='rec.ft_reclamo_ime.sql';
		$this->transaccion='REC_ARCH_CONCL';
		$this->tipo_procedimiento='IME';
		//definicion de variables
		$this->tipo_conexion = 'seguridad';
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

    function listarControlFRD(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_reclamo_sel';
        $this->transaccion='REC_NUM_FRD_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion
        //$this->setCount(true);

        $this->captura('id_reclamo', 'int4');
        $this->captura('nro_tramite','varchar');
        $this->captura('nro_frd','varchar');
        $this->captura('nro_correlativo','integer');
        $this->captura('oficina','varchar');
        $this->captura('id_oficina','int4');
        $this->captura('id_gestion','int4');
        $this->captura('nombre_cliente','varchar');
        $this->captura('nombre_funcionario','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->consulta); exit;
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }

    function reporteFRDFaltantes(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_reclamo_sel';
        $this->transaccion='REC_REP_FRD_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion
        $this->setCount(true);

        $this->setParametro('id_oficina','id_oficina','int4');
        $this->setParametro('id_gestion','id_gestion','int4');


        $this->captura('nombre','varchar');
        $this->captura('frds','varchar');
        $this->captura('frd_faltantes','varchar');


        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->consulta); exit;
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }

    function insertarLog(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_reclamo_ime';
        $this->transaccion='REC_LOG_FAL_IME';
        $this->tipo_procedimiento='IME';//tipo de transaccion
        //$this->setCount(true);

        $this->setParametro('descripcion','descripcion','codigo_html');
        $this->setParametro('id_reclamo','id_reclamo','int4');
        $this->setParametro('id_funcionario','id_funcionario','int4');



        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->consulta); exit;
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }

    function listarLogsFaltas()
    {
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_LOGS_FAL_SEL';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion
        //$this->setCount(false);


        //Definicion de la lista del resultado del query
        $this->captura('id_logs_reclamo', 'int4');
        $this->captura('descripcion', 'text');
        $this->captura('id_reclamo', 'int4');
        $this->captura('id_funcionario', 'int4');
        $this->captura('nombre_funcionario', 'text');
        $this->captura('nro_tramite', 'varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo $this->consulta;exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

	function reenviarCorreos(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'rec.f_verificar_alerta_falla';
		$this->transaccion = 'FAILED_MAILS';
		$this->tipo_procedimiento = 'IME';//tipo de transaccion

		$this->setParametro('id_usuario','id_usuario','int4');
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function reporteEstadistico(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_STADISTICAS_SEL';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion
        $this->setCount(false);

        /*$this->setParametro('id_gestion','id_gestion','integer');
        $this->setParametro('desde','desde','date');
        $this->setParametro('hasta','hasta','date');
        $this->setParametro('id_oficina_registro_incidente','id_oficina_registro_incidente','varchar');
        $this->setParametro('oficina','oficina','varchar');
        $this->setParametro('id_oficina_incidente','id_oficina_incidente','varchar');
        $this->setParametro('id_medio_reclamo','id_medio_reclamo','varchar');
        $this->setParametro('id_tipo_incidente','id_tipo_incidente','varchar');
        $this->setParametro('id_subtipo_incidente','id_subtipo_incidente','varchar');
        $this->setParametro('origen','origen','varchar');
        $this->setParametro('transito','transito','varchar');
        $this->setParametro('destino','destino','varchar');*/

        //Definicion de la lista del resultado del query
        $this->captura('tipo_tabla', 'varchar');
        //$this->captura('ciudad_reclamo', 'text');
        $this->captura('nombre_detalle', 'varchar');
        $this->captura('cantidad', 'integer');
        //$this->captura('medio_reclamo', 'text');
        //$this->captura('estado_reclamo', 'text');
        //$this->captura('genero_cliente', 'text');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo $this->consulta;exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function uploadArchivo(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'wf.ft_documento_wf_ime';
        $this->transaccion = 'WF_DOCWFAR_MOD';
        $this->tipo_procedimiento = 'IME';//tipo de transaccion


        $upload_folder =  './../../../uploaded_files/sis_workflow/DocumentoWf/';
        $image_parts = explode(";base64,", $this->aParam->getParametro('archivo'));
        $image_type_aux = explode("application/", $image_parts[0]);
        $image_base64 = base64_decode($image_parts[1]);
        $file_name = md5($this->aParam->getParametro('id_documento_wf') . $_SESSION["_SEMILLA"]);
        $file = $upload_folder . $file_name . '.' . $this->aParam->getParametro('extension');
        file_put_contents($file, $image_base64);

        $this->arreglo['file_name'] = $file;
        $this->arreglo['folder'] = $upload_folder;
        $this->arreglo['only_file'] = $file_name;

        //Define los parametros para la funcion
        $this->setParametro('id_documento_wf','id_documento_wf','integer');
        $this->setParametro('extension','extension','varchar');
        $this->setParametro('file_name','file_name','varchar');
        $this->setParametro('folder','folder','varchar');
        $this->setParametro('only_file','only_file','varchar');

        //Definicion de la lista del resultado del query
        //$this->captura('jsonData', 'text');
        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo $this->consulta;exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function getDetalleResumen(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_DET_RES_CLAIMS';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion
        $this->setCount(false);

        //Define los parametros para la funcion
        $this->setParametro('fecha_ini','fecha_ini','date');
        $this->setParametro('fecha_fin','fecha_fin','date');

        //Definicion de la lista del resultado del query
        $this->captura('jsonData', 'text');
        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo $this->consulta;exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function getEstructuraGantt(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_GANTT_CLAIM';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion
        $this->setCount(false);

        //Define los parametros para la funcion
        $this->setParametro('id_proceso_wf','id_proceso_wf','integer');


        //Definicion de la lista del resultado del query
        //$this->captura('jsonData', 'text');

        $this->captura('id_proceso_wf', 'integer');
        $this->captura('id_estado_wf','integer');
        $this->captura('tipo','varchar');
        $this->captura('nombre','varchar');
        $this->captura('fecha_ini','timestamp');
        $this->captura('fecha_fin','timestamp');
        $this->captura('descripcion','text');
        $this->captura('nro_tramite','varchar');
        $this->captura('codigo','varchar');
        $this->captura('id_funcionario','integer');
        $this->captura('funcionario','varchar');
        $this->captura('id_usuario','integer');
        $this->captura('cuenta','varchar');
        $this->captura('id_depto','integer');
        $this->captura('departamento','varchar');
        $this->captura('etapa','varchar');
        $this->captura('estado_reg','varchar');
        $this->captura('disparador','varchar');
        $this->captura('fin','varchar');
        $this->captura('usuario_ai','varchar');
        $this->captura('image_url','varchar');
        $this->captura('image_type','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo $this->consulta;exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function getClaimsList(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_CLAIMS_LIST';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion

        $this->setCount(false);

        //Definicion de la lista del resultado del query
        $this->captura('listClaims', 'json');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function getStatusList(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_STATUS_LIST';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion

        $this->setCount(false);

        $this->setParametro('codigo','codigo','varchar');
        //Definicion de la lista del resultado del query
        $this->captura('status_list', 'json');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function getRolesList(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_ROLES_LIST';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion

        $this->setCount(false);

        //Definicion de la lista del resultado del query
        $this->captura('roles_list', 'json');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function insertRole(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_reclamo_ime';
        $this->transaccion='REC_INSERT_ROLE';
        $this->tipo_procedimiento='IME';//tipo de transaccion
        //$this->setCount(true);

        $this->setParametro('rol','rol','text');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta); exit;
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }

    function updateRole(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_reclamo_ime';
        $this->transaccion='REC_UPDATE_ROLE';
        $this->tipo_procedimiento='IME';//tipo de transaccion
        //$this->setCount(true);

        $this->setParametro('id_rol','id_rol','integer');
        $this->setParametro('rol','rol','text');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta); exit;
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }

    function getRolesByOfficial(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_reclamo_sel';
        $this->transaccion = 'REC_ROLES_BY_OFF';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion

        $this->setCount(false);

        //Definicion de la lista del resultado del query
        $this->captura('json_rol', 'json');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function deleteRole()
    {
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento = 'rec.ft_reclamo_ime';
        $this->transaccion = 'REC_DELETE_ROLE';
        $this->tipo_procedimiento = 'IME';

        //Define los parametros para la funcion
        $this->setParametro('id_rol', 'id_rol', 'int4');

        //Ejecuta la instruccion
        $this->armarConsulta();//echo $this->consulta;exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }
}
