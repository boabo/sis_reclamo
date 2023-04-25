<?php
/**
 *@package pXP
 *@file gen-MODRespuesta.php
 *@author  (admin)
 *@date 11-08-2016 16:01:08
 *@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
 */

class MODRespuesta extends MODbase{

    function __construct(CTParametro $pParam){
        parent::__construct($pParam);
    }

    function listarRespuesta(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_respuesta_sel';
        $this->transaccion='REC_RES_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        //Definicion de la lista del resultado del query
        $this->captura('id_respuesta','int4');
        $this->captura('id_reclamo','int4');
        $this->captura('recomendaciones','varchar');
        $this->captura('nro_cite','varchar');
        $this->captura('respuesta','varchar');
        $this->captura('fecha_respuesta','date');
        $this->captura('estado_reg','varchar');
        $this->captura('procedente','varchar');
        $this->captura('fecha_notificacion','date');
        $this->captura('id_usuario_ai','int4');
        $this->captura('id_usuario_reg','int4');
        $this->captura('usuario_ai','varchar');
        $this->captura('fecha_reg','timestamp');
        $this->captura('fecha_mod','timestamp');
        $this->captura('id_usuario_mod','int4');
        $this->captura('usr_reg','varchar');
        $this->captura('usr_mod','varchar');

        $this->captura('tipo_respuesta','varchar');
        $this->captura('asunto','varchar');
        $this->captura('id_proceso_wf','int4');
        $this->captura('id_estado_wf','int4');
        $this->captura('estado','varchar');
        $this->captura('nro_respuesta','varchar');
        $this->captura('email', 'varchar');
        //$this->captura('email2', 'varchar');
        $this->captura('admin', 'int4');
        $this->captura('codigo_medio', 'varchar');
        $this->captura('nro_att', 'int4');
        //$this->captura('correlativo_preimpreso_frd', 'int4');


        $this->setParametro('tipo_interfaz', 'tipo_interfaz', 'varchar');


        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function insertarRespuesta(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='rec.ft_respuesta_ime';
        $this->transaccion='REC_RES_INS';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_reclamo','id_reclamo','int4');
        $this->setParametro('recomendaciones','recomendaciones','varchar');
        $this->setParametro('nro_cite','nro_cite','varchar');
        $this->setParametro('respuesta','respuesta','codigo_html');
        $this->setParametro('fecha_respuesta','fecha_respuesta','date');
        $this->setParametro('estado_reg','estado_reg','varchar');
        $this->setParametro('procedente','procedente','varchar');
        $this->setParametro('fecha_notificacion','fecha_notificacion','date');

        $this->setParametro('tipo_respuesta','tipo_respuesta','varchar');
        $this->setParametro('asunto','asunto','varchar');
        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function modificarRespuesta(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='rec.ft_respuesta_ime';
        $this->transaccion='REC_RES_MOD';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_respuesta','id_respuesta','int4');
        $this->setParametro('id_reclamo','id_reclamo','int4');
        $this->setParametro('recomendaciones','recomendaciones','varchar');
        $this->setParametro('nro_cite','nro_cite','varchar');
        $this->setParametro('respuesta','respuesta','codigo_html');
        $this->setParametro('fecha_respuesta','fecha_respuesta','date');
        $this->setParametro('estado_reg','estado_reg','varchar');
        $this->setParametro('procedente','procedente','varchar');
        $this->setParametro('fecha_notificacion','fecha_notificacion','date');

        $this->setParametro('tipo_respuesta','tipo_respuesta','varchar');
        $this->setParametro('asunto','asunto','varchar');
        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function eliminarRespuesta(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='rec.ft_respuesta_ime';
        $this->transaccion='REC_RES_ELI';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_respuesta','id_respuesta','int4');
        $this->setParametro('id_reclamo','id_reclamo','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function siguienteEstadoRespuesta(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='rec.ft_respuesta_ime';
        $this->transaccion='REC_SIGERES_IME';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_proceso_wf_act','id_proceso_wf_act','int4');
        $this->setParametro('id_estado_wf_act','id_estado_wf_act','int4');
        //$this->setParametro('id_funcionario_usu','id_funcionario_usu','int4');
        $this->setParametro('id_tipo_estado','id_tipo_estado','int4');
        $this->setParametro('id_funcionario_wf','id_funcionario_wf','int4');
        $this->setParametro('id_depto_wf','id_depto_wf','int4');
        $this->setParametro('obs','obs','text');
        $this->setParametro('json_procesos','json_procesos','text');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function anteriorEstadoRespuesta(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='rec.ft_respuesta_ime';
        $this->transaccion='REC_ANTERES_IME';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_reclamo','id_reclamo','int4');
        $this->setParametro('id_proceso_wf','id_proceso_wf','int4');
        $this->setParametro('id_funcionario_usu','id_funcionario_usu','int4');
        $this->setParametro('operacion','operacion','varchar');

        $this->setParametro('id_funcionario','id_funcionario','int4');
        $this->setParametro('id_tipo_estado','id_tipo_estado','int4');
        $this->setParametro('id_estado_wf','id_estado_wf','int4');
        $this->setParametro('obs','obs','text');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function getCite(){
        $this->procedimiento='rec.ft_respuesta_ime';
        $this->transaccion='REC_CITE_GET';
        $this->tipo_procedimiento='IME';

        $this->setParametro('num_cite','num_cite','varchar');
        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function reportesRespuesta(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_respuesta_sel';
        $this->transaccion='REC_REPORDOC_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        //Definicion de la lista del resultado del query
        $this->setCount(false);
        $this->setParametro('id_proceso_wf','id_proceso_wf','int4');

        $this->captura('id_respuesta','int4');
        $this->captura('id_reclamo','int4');
        $this->captura('recomendaciones','varchar');
        $this->captura('num_cite','text');
        $this->captura('respuesta','varchar');
        $this->captura('fecha_respuesta','text');
        $this->captura('fecha_notificacion','date');
        $this->captura('tipo_respuesta','varchar');
        $this->captura('asunto','varchar');
        $this->captura('nro_tramite','varchar');
        $this->captura('estado','varchar');
        $this->captura('nombre_completo1','text');
        $this->captura('genero','varchar');
        // $this->captura('gestion','int4');
        $this->captura('prodedente','varchar');
        $this->captura('nombre_estado','varchar');
        $this->captura('firma','varchar');
        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();
        //var_dump($this->respuesta); exit;
        //Devuelve la respuesta
        return $this->respuesta;

    }
    function listarDatosQRRespuesta(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_respuesta_sel';
        $this->transaccion='REC_RES_QR_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        //Definicion de la lista del resultado del query
        $this->setCount(false);
        $this->setParametro('id_proceso_wf','id_proceso_wf','int4');

        $this->captura('id_proceso_wf','int4');
        $this->captura('id_respuesta','int4');
        $this->captura('num_cite','text');
        $this->captura('nro_frd','varchar');
        $this->captura('oficina','varchar');
        $this->captura('estado','varchar');
        $this->captura('iniciales_fun_reg','text');
        $this->captura('iniciales_fun_vis','text');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();
        //var_dump($this->respuesta); exit;
        //Devuelve la respuesta
        return $this->respuesta;
    }


    function validarCite(){

        $this->procedimiento = 'rec.ft_respuesta_ime';
        $this->transaccion = 'RES_VALIDAR_CITE';
        $this->tipo_procedimiento = 'IME';

        $this->setParametro('nro_cite','nro_cite','varchar');
        //  $this->setParametro('momento','momento','varchar');

        $this->armarConsulta();
        $this->ejecutarConsulta();
        //Devuelve la respuesta
        return $this->respuesta;
    }


    function listarConsulta()
    {
//Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_respuesta_sel';
        $this->transaccion='REC_BUSQ_RES_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion
        //$this->setParametro('tipo_interfaz', 'tipo_interfaz', 'varchar');
        //Definicion de la lista del resultado del query
        $this->captura('id_respuesta','int4');
        $this->captura('id_reclamo','int4');
        $this->captura('recomendaciones','varchar');
        $this->captura('nro_cite','varchar');
        $this->captura('respuesta','varchar');
        $this->captura('fecha_respuesta','date');
        $this->captura('estado_reg','varchar');
        $this->captura('procedente','varchar');
        $this->captura('fecha_notificacion','date');
        $this->captura('id_usuario_ai','int4');
        $this->captura('id_usuario_reg','int4');
        $this->captura('usuario_ai','varchar');
        $this->captura('fecha_reg','timestamp');
        $this->captura('fecha_mod','timestamp');
        $this->captura('id_usuario_mod','int4');
        $this->captura('usr_reg','varchar');
        $this->captura('usr_mod','varchar');

        $this->captura('tipo_respuesta','varchar');
        $this->captura('asunto','varchar');
        $this->captura('id_proceso_wf','int4');
        $this->captura('id_estado_wf','int4');
        $this->captura('estado','varchar');
        $this->captura('nro_respuesta','varchar');
        //$this->captura('email', 'varchar');
        //$this->captura('admin', 'int4');
        //$this->captura('codigo_medio', 'varchar');
        //$this->captura('nro_att', 'int4');
        $this->captura('correlativo_preimpreso_frd', 'int4');
        $this->captura('nro_frd', 'varchar');
        $this->captura('detalle_incidente', 'text');

        $this->captura('nombre_completo1', 'varchar');




        //Ejecuta la instruccion
        $this->armarConsulta();
        //var_dump($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }


    function reporteConstanciaEnvio(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='rec.ft_respuesta_sel';
        $this->transaccion='RES_RECONENV_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        //Definicion de la lista del resultado del query
        //$this->setCount(false);
        $this->setParametro('id_proceso_wf','id_proceso_wf','int4');
	 
		$this->captura('email','varchar');
		$this->captura('nombre_cliente','text');
		$this->captura('titulo_correo','varchar');
		$this->captura('fecha_respuesta','text');
		$this->captura('hora','text');
		$this->captura('dia','text');		
		$this->captura('estado','varchar');
		$this->captura('asunto','varchar');
		$this->captura('correos_extras','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('cc','varchar[]');
		$this->captura('bcc','varchar[]');
		$this->captura('tipo_respuesta','varchar');
		$this->captura('procedente','varchar');
		$this->captura('correos','text');
        //Ejecuta la instruccion            

        $this->armarConsulta();
        $this->ejecutarConsulta();
        //echo($this->consulta); exit;
        //Devuelve la respuesta
        return $this->respuesta;
    }

    function getAnswersList(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento = 'rec.ft_respuesta_sel';
        $this->transaccion = 'REC_ANSWER_LIST';
        $this->tipo_procedimiento = 'SEL';//tipo de transaccion

        $this->setCount(false);

        //Definicion de la lista del resultado del query
        $this->captura('listAnswer', 'json');

        //Ejecuta la instruccion
        $this->armarConsulta();
        //echo($this->consulta);exit;
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }


}
