<?php
/**
 * @package pXP
 * @file ACTRespuesta.php
 * @author  (admin)
 * @date 11-08-2016 16:01:08
 * @description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
 */

require_once(dirname(__FILE__).'/../reportes/RRespuestaFinal.php');
require_once(dirname(__FILE__).'/../reportes/RConstanciaEnvioPDF.php');
require_once(dirname(__FILE__).'/../reportes/RRespuesta.php');



class ACTRespuesta extends ACTbase
{

    function listarRespuesta()
    {

        $this->objParam->defecto('ordenacion', 'id_respuesta');
        $this->objParam->defecto('dir_ordenacion', 'asc');


        if ($this->objParam->getParametro('id_reclamo') != '') {
            $this->objParam->addFiltro(" res.id_reclamo = " . $this->objParam->getParametro('id_reclamo'));
        }


        if ($this->objParam->getParametro('pes_estado') == 'revision_legal') {
            $this->objParam->addFiltro("res.estado in (''revision_legal'')");
        } else if ($this->objParam->getParametro('pes_estado') == 'vobo_respuesta') {
            $this->objParam->addFiltro("res.estado in (''vobo_respuesta'')");
        }

        if ($this->objParam->getParametro('tipoReporte') == 'excel_grid' || $this->objParam->getParametro('tipoReporte') == 'pdf_grid') {
            $this->objReporte = new Reporte($this->objParam, $this);
            $this->res = $this->objReporte->generarReporteListado('MODRespuesta', 'listarRespuesta');
        } else {
            $this->objFunc = $this->create('MODRespuesta');

            $this->res = $this->objFunc->listarRespuesta($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function insertarRespuesta()
    {
        $this->objFunc = $this->create('MODRespuesta');
        if ($this->objParam->insertar('id_respuesta')) {
            $this->res = $this->objFunc->insertarRespuesta($this->objParam);
        } else {
            $this->res = $this->objFunc->modificarRespuesta($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function eliminarRespuesta()
    {
        $this->objFunc = $this->create('MODRespuesta');
        $this->res = $this->objFunc->eliminarRespuesta($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function getCite()
    {
        $this->objFunc = $this->create('MODRespuesta');
        $this->res = $this->objFunc->getCite($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function siguienteEstadoRespuesta()
    {
        $this->objFunc = $this->create('MODRespuesta');

        $this->objParam->addParametro('id_funcionario_usu', $_SESSION["id_usuario_reg"]);

        $this->res = $this->objFunc->siguienteEstadoRespuesta($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function anteriorEstadoRespuesta()
    {
        $this->objFunc = $this->create('MODRespuesta');
        $this->objParam->addParametro('id_funcionario_usu', $_SESSION["ss_id_funcionario"]);
        $this->res = $this->objFunc->anteriorEstadoRespuesta($this->objParam);

        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function reporteRespuestaPDF()
    {

        $this->objFunc = $this->create('MODRespuesta');
        $this->res = $this->objFunc->reportesRespuesta($this->objParam);

        $this->objFunc = $this->create('MODRespuesta');

        $this->res2 = $this->objFunc->listarDatosQRRespuesta($this->objParam);
        //obtener titulo del reporte
        $titulo = 'Informe de Reclamo';
        //Genera el nombre del archivo (aleatorio + titulo)
        $nombreArchivo = uniqid(md5(session_id()) . $titulo);
        $nombreArchivo .= '.pdf';
        $this->objParam->addParametro('orientacion', 'P');
        $this->objParam->addParametro('tamano', 'LETTER');
        $this->objParam->addParametro('nombre_archivo', $nombreArchivo);
        //Instancia la clase de pdf

        $this->objReporteFormato = new RRespuestaFinal($this->objParam);
        $this->objReporteFormato->setDatos($this->res->datos, $this->res2->datos);
        $this->objReporteFormato->generarReporte();
        $this->objReporteFormato->output($this->objReporteFormato->url_archivo, 'F');


        $this->mensajeExito = new Mensaje();
        $this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado',
            'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    function reporteRespuestaWORD()
    {

        $this->objFunc = $this->create('MODRespuesta');
        $dataSource = $this->objFunc->reportesRespuesta();
        $this->dataSource = $dataSource->getDatos();
        $nombreArchivo = uniqid(md5(session_id()) . '[Respuesta-' . $this->dataSource[0]['nro_tramite'] . ']') . '.docx';

        $reporte = new RRespuesta($this->objParam);

        $reporte->datosHeader($this->dataSource);
        $reporte->write(dirname(__FILE__) . '/../../reportes_generados/' . $nombreArchivo);


        $this->mensajeExito = new Mensaje();
        $this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    function validarCite()
    {
        $this->objFunc = $this->create('MODRespuesta');
        $this->res = $this->objFunc->validarCite($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function listarConsulta()
    {

//        $this->objParam->defecto('ordenacion', 'id_respuesta');
//        $this->objParam->defecto('dir_ordenacion', 'asc');


//        if ($this->objParam->getParametro('id_reclamo') != '') {
//            $this->objParam->addFiltro(" res.id_reclamo = " . $this->objParam->getParametro('id_reclamo'));
//        }
       
        if ($this->objParam->getParametro('id_gestion') != '') {
            $this->objParam->addFiltro(" tr.id_gestion = " . $this->objParam->getParametro('id_gestion'));
        }
//        if ($this->objParam->getParametro('id_respuesta') != '') {
//            $this->objParam->addFiltro(" res.id_respuesta = " . $this->objParam->getParametro('id_respuesta'));
//        }


        if ($this->objParam->getParametro('tipoReporte') == 'excel_grid' || $this->objParam->getParametro('tipoReporte') == 'pdf_grid') {
            $this->objReporte = new Reporte($this->objParam, $this);
            $this->res = $this->objReporte->generarReporteListado('MODRespuesta', 'listarConsulta');
            //$this->res = $this->objReporte->generarReporteListado('MODRespuesta', 'listarRespuesta');
        } else {
            $this->objFunc = $this->create('MODRespuesta');
            $this->res = $this->objFunc->listarConsulta($this->objParam);
            //$this->res = $this->objFunc->listarRespuesta($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

	function reporteConstanciaEnvioPDF(){
        $this->objFunc=$this->create('MODRespuesta');
        $this->res=$this->objFunc->reporteConstanciaEnvio($this->objParam);


        $this->objFunc=$this->create('MODRespuesta');

        $this->res2=$this->objFunc->listarDatosQRRespuesta($this->objParam);
        //obtener titulo del reporte
        $titulo = 'Constancia Envio Reclamo';
        //Genera el nombre del archivo (aleatorio + titulo)
        $nombreArchivo=uniqid(md5(session_id()).$titulo);
        $nombreArchivo.='.pdf';
        $this->objParam->addParametro('orientacion','P');
        $this->objParam->addParametro('tamano','LETTER');
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);
        //Instancia la clase de pdf
        
        $this->objReporteFormato=new RConstanciaEnvioPDF($this->objParam);
        $this->objReporteFormato->setDatos($this->res->datos, $this->res2->datos);
        $this->objReporteFormato->generarReporte();
        $this->objReporteFormato->output($this->objReporteFormato->url_archivo,'F');


        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado',
            'Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());		
		
	}

    function getAnswersList()
    {
        $current_year = date('Y');

        if($this->objParam->getParametro('estado')!='') {
            $this->objParam->addFiltro("res.estado = ''".$this->objParam->getParametro('estado')."'' and res.fecha_reg::date between ''01/01/$current_year''::date and ''31/12/$current_year''::date ");
        }

        $this->objFunc = $this->create('MODRespuesta');
        $this->res = $this->objFunc->getAnswersList($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

}

?>