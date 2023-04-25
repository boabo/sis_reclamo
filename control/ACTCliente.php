<?php
/**
*@package pXP
*@file gen-ACTCliente.php
*@author  (admin)
*@date 12-08-2016 14:29:16
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/
require_once(dirname(__FILE__).'/../reportes/RLibroReclamoPDF.php');


class ACTCliente extends ACTbase{    
			
	function listarCliente(){
		$this->objParam->defecto('ordenacion','id_cliente');


		
		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODCliente','listarCliente');
		} else{
			$this->objFunc=$this->create('MODCliente');
			
			$this->res=$this->objFunc->listarCliente($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarCliente(){
		$this->objFunc=$this->create('MODCliente');
		//var_dump($this->objFunc);exit;
		if($this->objParam->insertar('id_cliente')){
			$this->res=$this->objFunc->insertarCliente($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarCliente($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarCliente(){
			$this->objFunc=$this->create('MODCliente');	
		$this->res=$this->objFunc->eliminarCliente($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}


	function getNombreCliente(){
		$this->objFunc=$this->create('MODCliente');
		$this->res=$this->objFunc->getNombreCliente($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

    function libroReclamo(){

        if ( $this->objParam->getParametro('id_oficina_registro_incidente') == '' && $this->objParam->getParametro('id_oficina_registro_incidente') != 0 ) {
            $this->objParam->addParametro('id_oficina_registro_incidente','-1');
            //$this->objParam->addParametro('id_oficina_registro_incidente','TODOS');
        }

        if ( $this->objParam->getParametro('tipo') != 'listado' ) {
            $this->objParam->getParametro('fecha_ini');
            $this->objParam->getParametro('fecha_fin');

            $this->objFunc = $this->create('MODCliente');
            $this->res = $this->objFunc->listarClienteLibro($this->objParam);
            //obtener titulo del reporte

            $titulo = 'Libro De Reclamo';
            //Genera el nombre del archivo (aleatorio + titulo)
            $nombreArchivo = uniqid(md5(session_id()) . $titulo);
            $nombreArchivo .= '.pdf';
            $this->objParam->addParametro('orientacion', 'L');
            $this->objParam->addParametro('tamano', 'LETTER');
            $this->objParam->addParametro('nombre_archivo', $nombreArchivo);
            //Instancia la clase de pdf

            $this->objReporteFormato = new RLibroReclamoPDF ($this->objParam);
            $this->objReporteFormato->setDatos($this->res->datos);
            $this->objReporteFormato->generarReporte();
            $this->objReporteFormato->output($this->objReporteFormato->url_archivo, 'F');


            $this->mensajeExito = new Mensaje();
            $this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado',
                'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
            $this->mensajeExito->setArchivoGenerado($nombreArchivo);
            $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
        }else{

            if ($this->objParam->getParametro('id_oficina_registro_incidente') == 0) {
                $this->objParam->addFiltro("re.id_oficina_registro_incidente != " . $this->objParam->getParametro('id_oficina_registro_incidente'));
            }else{
                $this->objParam->addFiltro("re.id_oficina_registro_incidente = " . $this->objParam->getParametro('id_oficina_registro_incidente'));
            }
            $this->objFunc = $this->create('MODCliente');
            $this->res = $this->objFunc->listarClienteLibro($this->objParam);

            $this->res->imprimirRespuesta($this->res->generarJson());
        }
    }

    function validarCliente(){
        $this->objFunc=$this->create('MODCliente');
        $this->res=$this->objFunc->validarCliente($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function listarPais(){
        $this->objFunc=$this->create('MODCliente');
        $this->res=$this->objFunc->listarPais();
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function loadClienteForm(){

        if ($this->objParam->getParametro('id_cliente') != '') {
            $this->objParam->addFiltro("cli.id_cliente = ". $this->objParam->getParametro('id_cliente'));
        }
        $this->objFunc=$this->create('MODCliente');
        $this->res=$this->objFunc->loadClienteForm();
        $this->res->imprimirRespuesta($this->res->generarJson());
    }
	
}

?>