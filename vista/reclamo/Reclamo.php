<?php
/**
 *@package pXP
 *@file gReclamo.php
 *@author  Franklin Espinoza Alvarez
 *@date 10-08-2016 17:32:59
 *@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema Reclamos
 */
//Hola
header("content-type: text/javascript; charset=UTF-8");
?>
<style type="text/css">
    .uno{
        background-color: #00FF00 !important;
    }
    .dos{
        background-color: #FF0000 !important;
    }

</style>

<script>
	Phx.vista.Reclamo=Ext.extend(Phx.gridInterfaz, {
    momento: '',
	nombreVista: 'Reclamo',
	val_oficina: '',
	val_funcionario: '',
	constructor: function (config) {
		this.idContenedor = config.idContenedor;
		this.maestro = config.maestro;
		//llama al constructor de la clase padre

		Phx.vista.Reclamo.superclass.constructor.call(this, config);

		this.init();
		this.Cmp.id_cliente.pid = this.idContenedor;
		this.iniciarEvento();
		this.store.baseParams = {tipo_interfaz:this.nombreVista};
		this.store.baseParams.pes_estado = 'borrador';
		this.load({params: {start: 0, limit: this.tam_pag}});
		this.finCons = true;
        this.bandera_log = false;//bandera para controlar las faltas de un funcionario
        this.titulo = '';
        this.mensaje = '';
		this.addButton('ant_estado',{
				grupo: [0,1,2,3,4,5],
				argument: {estado: 'anterior'},
				text: 'Anterior',
				iconCls: 'batras',
				disabled: true,
				/*hidden:true,*/
				handler: this.antEstado,
				tooltip: '<b>Volver al Anterior Estado</b>'
		});

		this.addButton('sig_estado',{
			grupo:[0,1,2,3,4,5],
			text:'Siguiente',
			iconCls: 'badelante',
			disabled:true,
			handler:this.sigEstado,
			tooltip: '<b>Pasar al Siguiente Estado</b>'
		});

		this.addButton('btnChequeoDocumentosWf',{
				text: 'Documentos',
				grupo: [0,1,2,3,4,5],
				iconCls: 'bchecklist',
				disabled: true,
				handler: this.loadCheckDocumentosRecWf,
				tooltip: '<b>Documentos del Reclamo</b><br/>Subir los documetos requeridos en el Reclamo seleccionado.'
		});

		this.addButton('btnObs',{
			grupo:[0,1,2,3,4,5],
			text :'Obs Wf.',
			iconCls : 'bchecklist',
			disabled: true,
			handler : this.onOpenObs,
			tooltip : '<b>Observaciones</b><br/><b>Observaciones del WF</b>'
		});

		this.addButton('diagrama_gantt',{
				grupo:[0,1,2,3,4,5],
				text:'Gant',
				iconCls: 'bgantt',
				disabled:true,
				handler:diagramGantt,
				tooltip: '<b>Diagrama Gantt de proceso macro</b>'
		});

		function diagramGantt(){
			var data=this.sm.getSelected().data.id_proceso_wf;
			Phx.CP.loadingShow();
			Ext.Ajax.request({
				url:'../../sis_workflow/control/ProcesoWf/diagramaGanttTramite',
				params:{'id_proceso_wf':data},
				success:this.successExport,
				failure: this.conexionFailure,
				timeout:this.timeout,
				scope:this
			});
		}

        this.sm.on('rowselect', this.getPlazoSelect,this);
        this.sm.on('rowdeselect', this.getPlazoDeselect,this);
	},

    getPlazoSelect : function(grid, rowIndex, rec) {
        let limite = rec.data.fecha_limite_respuesta;//rec.data.fecha_limite_respuesta.toLocaleDateString()
        limite = limite.getDate() + '/' + (limite.getMonth()+1) + '/' + limite.getFullYear();
        this.plazo.setText('PLAZO: '+ limite) ;
    },

    getPlazoDeselect : function(grid, rowIndex, rec) {
        this.plazo.setText('');
    },

	compositeFields : function(){  //step 1
		return{
			xtype	        : "compositefield", //step 2
			fieldLabel	: "Phone",
			defaults	: {allowBlank: false},
			border	      : false,
			items	        : [
				{xtype : "displayfield", value:"("},  //step 3
				{xtype : "textfield", name : "phoneNum1", width: 30},  //step 4
				{xtype : "displayfield", value:") - "},
				{xtype : "textfield", name : "phoneNum2", width: 50},
				{xtype : "displayfield", value:" - "},
				{xtype : "textfield", name : "phoneNum3", width: 50}
			]
			};
	},
	Atributos: [
		{
			//configuracion del componente
			config: {
				labelSeparator: '',
				inputType: 'hidden',
				name: 'id_reclamo'
			},
			type: 'Field',
			form: true,
			id_grupo:1
		},
		{
			//configuracion del componente
			config: {
				labelSeparator: '',
				inputType: 'hidden',
				name: 'id_estado_wf'
			},
			type: 'Field',
			form: false,
			id_grupo:1
		},
		{
			//configuracion del componente
			config: {
				labelSeparator: '',
				inputType: 'hidden',
				name: 'id_proceso_wf'
			},
			type: 'Field',
			form: false,
			id_grupo:1
		},
		{
			config:{
				name: 'revisado',
				fieldLabel: 'Revisado',
				allowBlank: true,
				anchor: '50%',
				gwidth: 60,
				renderer:function (value, p, record){

					if(record.data['revisado'] == 'si') {
                        return String.format('{0}', "<div style='text-align:center'><img title='Reclamo con Respuesta'  src = '../../../lib/imagenes/ball_green.png' align='center' width='24' height='24'/></div>");
                    }else {
                        return String.format('{0}', "<div style='text-align:center'><img title='Reclamo Pendiente de Respuesta'  src = '../../../lib/imagenes/ball_blue.png' align='center' width='24' height='24'/></div>");
                    }//else {
                        //return String.format('{0}', "<div style='text-align:center'><img title='Pendiente de Asignación'  src = '../../../lib/imagenes/ball_white.png' align='center' width='24' height='24'/></div>");
                    //}
				}
			},
			type:'Checkbox',
			filters:{pfiltro:'rec.revisado',type:'string'},
			id_grupo:1,
			grid:false,
			form:false
		},
		{
			config:{
				name: 'nro_tramite',
				fieldLabel: 'No. Tramite',
				allowBlank: false,
				anchor: '50%',
				gwidth: 120,
				maxLength:100,
				renderer: function(value, p, record) {
				    //p.style = "background-color:#EAA8A8";
					var fecha_actual = new Date();
					var dias = record.data.dias_respuesta;
					var diasDif = record.data.fecha_limite_respuesta - fecha_actual;
					diasDif = Math.round(diasDif / (1000 * 60 * 60 * 24));

					var ids = new Array(4, 6, 37, 38, 48, 50);
					var id_tipo = parseInt(record.data.id_tipo_incidente);

					if(ids.indexOf(id_tipo) >= 0) {
                        if(record.data.revisado == 'res_ripat' || record.data.revisado == 'con_respuesta' || record.data.revisado == 'concluido'){
                            return String.format('<div ext:qtip="Con Respuesta"><b><font color="black">{0}</font></b><br></div>', value);
                        }else if (dias >= 1 && dias <= 10) {
							return String.format('<div ext:qtip="Optimo"><b><font color="green">{0}</font></b><br></div>', value);
						}else if(dias==0) {
							return String.format('<div ext:qtip="Malo"><b><font color="orange">{0}</font></b><br></div>', value);
						}else if(dias <= -1) {
                            return String.format('<div ext:qtip="Con Respuesta"><b><font color="red">{0}</font></b><br></div>', value);
                        }

					}else if(record.data.id_tipo_incidente==36){
						console.log('tipo:', record.data.id_tipo_incidente, 'dias',record.data.dias_respuesta, 'value', value);
                        if(record.data.revisado == 'res_ripat' || record.data.revisado == 'con_respuesta' || record.data.revisado == 'concluido'){
                            return String.format('<div ext:qtip="Con Respuesta"><b><font color="black">{0}</font></b><br></div>', value);
                        }else if (dias >=1  && dias <= 7) {
							return String.format('<div ext:qtip="Optimo"><b><font color="green">{0}</font></b><br></div>', value);
						}else if(dias == 0){
							return String.format('<div ext:qtip="Critico"><b><font color="orange">{0}</font></b><br></div>', value);
						}else if(dias <= -1) {
                            return String.format('<div ext:qtip="Con Respuesta"><b><font color="red">{0}</font></b><br></div>', value);
                        }
					}
					/*if(record.data.revisado == 'res_ripat' || record.data.revisado == 'con_respuesta' || record.data.revisado == 'concluido'){
                        return String.format('<div ext:qtip="Con Respuesta"><b><font color="black">{0}</font></b><br></div>', value);
                    }*/
				}
			},
			type:'TextField',
			filters:{pfiltro:'rec.nro_tramite',type:'string'},
			grid:true,
			form:false,
			bottom_filter : true
		},/*{
			config: {
				name: 'dias_respuesta',
				fieldLabel: 'Dias Para Responder',
				allowBlank: true,
				anchor: '100%',
				gwidth: 150,
				maxLength: 100,
				renderer: function(value, p, record) {
					var dias = record.data.dias_respuesta;
					var ids = new Array(4, 6, 37, 38, 48, 50);
					var id_tipo = parseInt(record.data.id_tipo_incidente);
					if(ids.indexOf(id_tipo) >= 0) {
						if (dias >= 7 && dias <= 10) {
							return String.format('<div ext:qtip="Optimo"><b><font color="green">Faltan {0} Días</font></b><br></div>', value);
						}
						else if(dias >=3  && dias <= 6){
							return String.format('<div ext:qtip="Critico"><b><font color="orange">Faltan {0} Días</font></b><br></div>', value);
						}else if(dias>=0 && dias<=2) {
							if(dias == 1)
								return String.format('<div ext:qtip="Malo"><b><font color="red">Falta {0} Día</font></b><br></div>', value);
							else if(dias == 0 || dias ==2)
								return String.format('<div ext:qtip="Malo"><b><font color="red">Faltan {0} Días</font></b><br></div>', value);
						}else if(dias = -1){
							return String.format('<div ext:qtip="Con Respuesta"><b><font color="blue">Con Respuesta o Vencido</font></b><br></div>', value);
						}
					}else if(record.data.id_tipo_incidente==36){
						if (dias >=5  && dias <= 7) {
							return String.format('<div ext:qtip="Optimo"><b><font color="green">Faltan {0} Días</font></b><br></div>', value);
						}
						else if(dias >=2  && dias <= 4){
							return String.format('<div ext:qtip="Critico"><b><font color="orange">Faltan {0} Días</font></b><br></div>', value);
						}else if(dias>=0 && dias<=1) {
							if(dias == 1)
								return String.format('<div ext:qtip="Malo"><b><font color="red">Falta {0} Día</font></b><br></div>', value);
							else if(dias == 0)
								return String.format('<div ext:qtip="Malo"><b><font color="red">Faltan {0} Días</font></b><br></div>', value);
						}else if(dias = -1){
							return String.format('<div ext:qtip="Con Respuesta"><b><font color="blue">Con Respuesta o Vencido</font></b><br></div>', value);
						}
					}
				}
			},
			type: 'TextField',
			grid: true,
			form: false
		},
		{
			config: {
				name: 'fecha_limite_respuesta',
				fieldLabel: 'Fecha Limite de Respuesta',
				allowBlank: true,
				anchor: '80%',
				gwidth: 150,
				maxLength: 15,
				format: 'd/m/Y',
				renderer:function (value,p,record){
					return value?value.dateFormat('d/m/Y'):''
				}
			},
			type: 'DateField',
			filters: {pfiltro: 'rec.fecha_limite_respuesta', type: 'date'},
			id_grupo: 4,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'dias_informe',
				fieldLabel: 'Dias Para Adjuntar Inf.',
				allowBlank: true,
				anchor: '100%',
				gwidth: 300,
				maxLength: 100,
				renderer: function(value, p, record) {
					var dias = record.data.dias_informe;
					console.log('dias: '+record.data.dias_informe);
					//console.log('dias_informe: '+JSON.stringify(record.data));
					if (dias == 2) {
						return String.format('<div ext:qtip="Bueno"><b><font color="green">Le Quedan 48 Horas</font></b><br></div>', value);
					}
					else if(dias>=0 && dias<=1){
						return String.format('<div ext:qtip="Malo"><b><font color="orange">Le Quedan 24 Horas</font></b><br></div>', value);
					}else if(dias = -1){
						return String.format('<div ext:qtip="Vencido"><b><font color="blue">Vencido</font></b><br></div>', value);
					}
				}
			},
			type: 'TextField',
			grid: true,
			form: false
		},*/

		{
			config: {
				name: 'correlativo_preimpreso_frd',
				fieldLabel: 'Nro. Preimpreso FRD',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				maxLength: 25
			},
			type: 'NumberField',
			filters: {pfiltro: 'rec.correlativo_preimpreso_frd', type: 'numeric'},
			id_grupo: 0,
			bottom_filter:true,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'nro_frd',
				fieldLabel: 'Nro. FRD',
				allowBlank: true,
				anchor: '80%',
				gwidth: 70,
				maxLength: 25
			},
			type: 'TextField',
			filters: {pfiltro: 'rec.nro_frd', type: 'string'},
			id_grupo: 0,
			bottom_filter:true,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'estado',
				fieldLabel: 'Estado',
				allowBlank: true,
				anchor: '100%',
				gwidth: 150,
				maxLength: 100
			},
			type: 'TextField',
			filters: {pfiltro: 'rec.estado', type: 'string'},
			/*id_grupo: 1,*/
			grid: true,
			form: false
		},
		{
			config: {
				name: 'nro_frsa',
				fieldLabel: 'Nro. FRSA',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25
			},
			type: 'NumberField',
			filters: {pfiltro: 'rec.nro_frsa', type: 'numeric'},
			id_grupo: 0,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'nro_pir',
				fieldLabel: 'Nro. PIR',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25
			},
			type: 'NumberField',
			filters: {pfiltro: 'rec.nro_pir', type: 'numeric'},
			id_grupo: 0,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'nro_att_canalizado',
				fieldLabel: 'Nro. FRD Att Canalizado',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25
			},
			type: 'TextField',
			filters: {pfiltro: 'rec.nro_att_canalizado', type: 'numeric'},
			id_grupo: 0,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'nro_ripat_att',
				fieldLabel: 'Nro. RIPAT Att',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25
			},
			type: 'NumberField',
			bottom_filter:true,
			filters: {pfiltro: 'rec.nro_ripat_att', type: 'numeric'},
			id_grupo: 0,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'nro_hoja_ruta',
				fieldLabel: 'Nro. Hoja Ruta',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25
			},
			type: 'NumberField',
			filters: {pfiltro: 'rec.nro_hoja_ruta', type: 'numeric'},
			id_grupo: 0,
			grid: true,
			form: true
		},
		{
			config:{

				name:'id_cliente',
				fieldLabel:'Cliente',
				allowBlank:false,
				emptyText:'Elija una opción...',
				dato: 'reclamo',
                qtip:'Ingrese el Nombre del Cliente, Si se encuentra en la BD seleccionelo, Sino Registre Nuevo con el boton de Lupa.',
				store: new Ext.data.JsonStore({
					url: '../../sis_reclamo/control/Cliente/listarCliente',
					id: 'id_cliente',
					root: 'datos',
					sortInfo:{
						field: 'nombre_completo2',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_cliente','nombre_completo2','nombre_completo1','ci','email','email2'],
					// turn on remote sorting
					remoteSort: true,
					baseParams:{par_filtro:'c.nombre_completo2#c.ci#c.email'}
				}),
				valueField: 'id_cliente',
				displayField: 'nombre_completo2',
				gdisplayField:'nombre_completo2',//mapea al store del grid
				tpl:'<tpl for="."><div class="x-combo-list-item"><p>{nombre_completo2}</p><p>CI:{ci}</p><p style= "color : green;" >Email:{email}</p><p style= "color : green;" >Email 2:{email2}</p></div></tpl>',
				hiddenName: 'id_cliente',
				forceSelection:true,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender:true,
				mode:'remote',
				pageSize:10,
				queryDelay:1000,
				width:250,
				gwidth:250,
				minChars:1,
				turl:'../../../sis_reclamo/vista/cliente/FormCliente.php',
				ttitle:'Clientes',
				tconfig:{width: '35%' ,height:'90%'},
				tdata:{},
				tcls:'FormCliente',
				pid:this.idContenedor,

				renderer:function (value, p, record){return String.format('{0}', record.data['desc_nom_cliente']);}
			},
			type:'TrigguerCombo',
			bottom_filter:true,
			id_grupo:1,
			filters:{
				pfiltro:'c.nombre_completo2',
				type:'string'
			},
			grid:true,
			form:true
		},
		{
			config: {
				name: 'nro_vuelo',
				fieldLabel: 'Nro. Vuelo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25,
				style:'text-transform:uppercase;'
			},
			type: 'TextField',
			filters: {pfiltro: 'rec.nro_vuelo', type: 'string'},
			bottom_filter: true,
			id_grupo: 2,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'origen',
				fieldLabel: 'Origen',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25,
                typeAhead:true,
                forceSelection: true,
                triggerAction:'all',
                mode:'local',
                store:[ 'BCN', 'BUE', 'BYC', 'CBB', 'CCA',  'LPB', 'CIJ', 'MAD', 'MIA', 'ORU', 'POI', 'RIB', 'RBQ', 'SAO', 'SLA', 'S.RE', 'SRZ', 'TDD', 'TJA', 'UYU', 'LIM'],
				style:'text-transform:uppercase;'
			},
			type: 'ComboBox',
			filters: {pfiltro: 'rec.origen', type: 'string'},
			id_grupo: 2,
			grid: true,
			form: true
		},{
			config: {
				name: 'transito',
				fieldLabel: 'TTO',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25,
                typeAhead:true,
                forceSelection: true,
                triggerAction:'all',
                mode:'local',
                store:['BCN', 'BUE', 'BYC', 'CBB', 'CCA',  'LPB', 'CIJ', 'MAD', 'MIA', 'ORU', 'POI', 'RIB', 'RBQ', 'SAO', 'SLA', 'S.RE', 'SRZ', 'TDD', 'TJA', 'UYU', 'LIM'],
				style:'text-transform:uppercase;'
			},
			type: 'ComboBox',
			filters: {pfiltro: 'rec.transito', type: 'string'},
			id_grupo: 2,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'destino',
				fieldLabel: 'Destino',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 25,
                typeAhead:true,
                forceSelection: true,
                triggerAction:'all',
                mode:'local',
                store:['BCN', 'BUE', 'BYC', 'CBB', 'CCA',  'LPB', 'CIJ', 'MAD', 'MIA', 'ORU', 'POI', 'RIB', 'RBQ', 'SAO', 'SLA', 'S.RE', 'SRZ', 'TDD', 'TJA', 'UYU', 'LIM'],
                style:'text-transform:uppercase;'

			},
			type: 'ComboBox',
			filters: {pfiltro: 'rec.destino', type: 'string'},
			id_grupo: 2,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'fecha_hora_vuelo',
				fieldLabel: 'Fecha, Hora de Vuelo',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y H:i',
				renderer: function (value, p, record) {
					return value ? value.dateFormat('d/m/Y H:i A') : ''
				}
			},
			type: 'DateField',
			filters: {pfiltro: 'rec.fecha_hora_vuelo', type: 'date'},
			id_grupo: 2,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'pnr',
				fieldLabel: 'P.N.R.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 50,
				maxLength: 25
			},
			type: 'TextField',
			filters: {pfiltro: 'rec.pnr', type: 'string'},
			id_grupo: 0,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_tipo_incidente',
				fieldLabel: 'Tipo de Incidente',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_reclamo/control/TipoIncidente/listarTipoIncidente',
					id: 'id_tipo_incidente',
					root: 'datos',
					sortInfo: {
						field: 'nombre_incidente',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_tipo_incidente', 'nombre_incidente','fk_tipo_incidente'],
					remoteSort: true,
					baseParams: {par_filtro: 'tip.nombre_incidente', nivel:'1', fk_tipo_incidente:'1'}
				}),
				valueField: 'id_tipo_incidente',
				displayField: 'nombre_incidente',
				gdisplayField: 'desc_nombre_incidente',
				hiddenName: 'id_tipo_incidente',
				forceSelection: true,
				typeAhead: false,
				editable: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				/*width: 200,*/
				gwidth: 150,
				minChars: 2,
				resizable:true,
				listWidth:'240',
				renderer: function (value, p, record) {
					return String.format('{0}', record.data['desc_nombre_incidente']);
				}
			},
			type: 'ComboBox',
			bottom_filter:true,
			id_grupo: 3,
			filters: {pfiltro: 'tip.nombre_incidente', type: 'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_subtipo_incidente',
				fieldLabel: 'Subtipo de Incidente',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_reclamo/control/TipoIncidente/listarTipoIncidente',
					id: 'id_tipo_incidente',
					root: 'datos',
					sortInfo: {
						field: 'nombre_incidente',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_tipo_incidente', 'nombre_incidente'],
					remoteSort: true/*,
					 baseParams: {par_filtro: 'rti.nombre_incidente',  fk_tipo_incidente:'id_tipo_incidente'}*/

				}),
				valueField: 'id_tipo_incidente',
				displayField: 'nombre_incidente',
				gdisplayField: 'desc_sudnom_incidente',
				hiddenName: 'id_subtipo_incidente',
				forceSelection: true,
				typeAhead: false,
				editable: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 150,
				minChars: 2,
				resizable:true,
				listWidth:'240',
				renderer: function (value, p, record) {
					return String.format('{0}', record.data['desc_sudnom_incidente']);
				}
			},
			type: 'ComboBox',
			bottom_filter:true,
			id_grupo: 3,
			filters: {pfiltro: 't.nombre_incidente', type: 'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'fecha_hora_incidente',
				fieldLabel: 'Fecha, Hora del Incidente',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y H:i',
				renderer: function (value, p, record) {
					return value ? value.dateFormat('d/m/Y H:i A') : ''
				}
			},
			type: 'DateField',
			filters: {pfiltro: 'rec.fecha_hora_incidente', type: 'date'},
			id_grupo: 2,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_oficina_incidente',
				fieldLabel: 'Ambiente del Incidente',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					//url: '../../sis_reclamo/control/Reclamo/listarOficinas',
					url: '../../sis_reclamo/control/OficinaReclamo/listarOficina',
					id: 'id_oficina',
					root: 'datos',
					sortInfo: {
						field: 'nombre',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_oficina', 'nombre', 'codigo','nombre_lugar'],
					remoteSort: true,
					baseParams: {par_filtro: 'ofi.nombre#ofi.codigo#lug.nombre'}
				}),
				valueField: 'id_oficina',
				displayField: 'nombre',
				gdisplayField: 'desc_nombre_oficina',
				hiddenName: 'id_oficina_incidente',
				forceSelection: true,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 10,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 150,
				minChars: 2,
				resizable:true,
				listWidth:'263',
				renderer: function (value, p, record) {

					return String.format('{0}', record.data['desc_nombre_oficina']);
				}
			},
			type: 'ComboBox',
			id_grupo: 3,
			filters: {pfiltro: 'ofi.nombre#ofi.codigo#lug.nombre', type: 'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'detalle_incidente',
				fieldLabel: 'Detalle Incidente',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100,
				maxLength: 100000
			},
			type: 'TextArea',
			bottom_filter:true,
			filters: {pfiltro: 'rec.detalle_incidente', type: 'string'},
			id_grupo: 3,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'observaciones_incidente',
				fieldLabel: 'Observaciones Incidente',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100,
				maxLength: 100000
			},
			type: 'TextArea',
			bottom_filter:true,
			filters: {pfiltro: 'rec.observaciones_incidente', type: 'string'},
			id_grupo: 3,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_funcionario_denunciado',
				fieldLabel: 'Funcionario Denunciado',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_organigrama/control/Funcionario/listarFuncionarioCargo',
					id: 'id_funcionario',
					root: 'datos',
					sortInfo: {
						field: 'desc_funcionario1',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_funcionario','desc_funcionario1','email_empresa','nombre_cargo','lugar_nombre','oficina_nombre'],
					remoteSort: true,
					baseParams: {par_filtro: 'FUNCAR.desc_funcionario1'}
				}),
				valueField: 'id_funcionario',
				displayField: 'desc_funcionario1',
				gdisplayField: 'desc_nombre_fun_denun',
				tpl:'<tpl for="."><div class="x-combo-list-item"><p>{desc_funcionario1}</p><p style="color: green">{nombre_cargo}<br>{email_empresa}</p><p style="color:green">{oficina_nombre} - {lugar_nombre}</p></div></tpl>',
				hiddenName: 'id_funcionario_denunciado',
				forceSelection: true,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				width: 260,
				gwidth: 150,
				minChars: 2,
				resizable:true,
				listWidth:'260',
				renderer: function (value, p, record) {
					return String.format('{0}', record.data['desc_nombre_fun_denun']);
				}
			},
			type: 'TrigguerCombo',
			id_grupo:3,
			filters:{
				pfiltro:'fu.desc_funcionario1',
				type:'string'
			},
			bottom_filter:true,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_oficina_registro_incidente',
				fieldLabel: 'Oficina Reclamo',
				allowBlank: false,
				emptyText: 'Elija una opción...',
                qtip: 'Oficina Fisica donde se hace el registro en el ERP, de un Reclamo,se rellena por Defecto.',
				store: new Ext.data.JsonStore({
					url: '../../sis_reclamo/control/OficinaReclamo/listarOficina',// ../../sis_organigrama/control/Oficina/listarOficina
					id: 'id_oficina',
					root: 'datos',
					sortInfo: {
						field: 'nombre',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_oficina', 'nombre', 'codigo','nombre_lugar'],
					remoteSort: true,
					baseParams: {par_filtro: 'ofi.nombre#ofi.codigo#lug.nombre'}
				}),
				valueField: 'id_oficina',
				displayField: 'nombre',
				gdisplayField: 'desc_oficina_registro_incidente',
				hiddenName: 'id_oficina',
				forceSelection: true,
				typeAhead: true,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 10,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 150,
				minChars: 2,
				resizable:true,
				listWidth:'259',
				renderer: function (value, p, record) {
					return String.format('{0}', record.data['desc_oficina_registro_incidente']);
				}
			},
			type: 'ComboBox',
			id_grupo: 4,
			filters: {pfiltro: 'ofi.nombre#ofi.codigo#tlug.nombre', type: 'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'fecha_hora_recepcion',
				fieldLabel: 'Fecha, Hora de Recepcion',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				disabled: false,
				gdisplayField: 'fecha_hora_recepcion',
				format: 'd/m/Y H:i',
				renderer: function (value, p, record) {
					return value ? value.dateFormat('d/m/Y H:i A') : ''
				}
			},
			type: 'DateField',
			filters: {pfiltro: 'rec.fecha_hora_recepcion', type: 'date'},
			id_grupo: 4,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_funcionario_recepcion',
				fieldLabel: 'Funcionario que recibe Reclamo',
				allowBlank: false,
				emptyText: 'Elija una opción...',
                qtip:'Funcionario que registra el Reclamo en el ERP, se rellena por Defecto.',
				store: new Ext.data.JsonStore({
					url: '../../sis_organigrama/control/Funcionario/listarFuncionarioCargo',
					id: 'id_funcionario',
					root: 'datos',
					sortInfo: {
						field: 'desc_funcionario1',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_funcionario','desc_funcionario1','email_empresa','nombre_cargo','lugar_nombre','oficina_nombre'],
					remoteSort: true,
					baseParams: {par_filtro: 'FUNCAR.desc_funcionario1'}//#FUNCAR.nombre_cargo
				}),
				valueField: 'id_funcionario',
				displayField: 'desc_funcionario1',
				gdisplayField: 'desc_nombre_funcionario',
				tpl:'<tpl for="."><div class="x-combo-list-item"><p>{desc_funcionario1}</p><p style="color: green">{nombre_cargo}<br>{email_empresa}</p><p style="color:green">{oficina_nombre} - {lugar_nombre}</p></div></tpl>',
				hiddenName: 'id_funcionario_recepcion',
				forceSelection: true,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 10,
				queryDelay: 1000,
				anchor: '100%',
				width: 260,
				gwidth: 250,
				minChars: 2,
				resizable:true,
				listWidth:'240',
				renderer: function (value, p, record) {
					return String.format('{0}', record.data['desc_nombre_funcionario']);
				}
			},
			type: 'ComboBox',
			bottom_filter:true,
			id_grupo: 4,
			filters:{
				pfiltro:'fun.desc_funcionario1',//#fun.nombre_cargo
				type:'string'
			},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_medio_reclamo',
				fieldLabel: 'Medio Reclamo',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_reclamo/control/MedioReclamo/listarMedioReclamo',
					id: 'id_medio_reclamo',
					root: 'datos',
					sortInfo: {
						field: 'orden',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_medio_reclamo', 'nombre_medio'],
					remoteSort: true,
					baseParams: {par_filtro: 'med.nombre_medio'}
				}),
				valueField: 'id_medio_reclamo',
				displayField: 'nombre_medio',
				gdisplayField: 'desc_nombre_medio',
				hiddenName: 'id_medio_reclamo',
				forceSelection: true,
				typeAhead: false,
				editable: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 150,
				minChars: 2,
				resizable:true,
				listWidth:'240',
				renderer: function (value, p, record) {
					return String.format('{0}', record.data['desc_nombre_medio']);
				}
			},
			type: 'ComboBox',
			id_grupo: 4,
			filters: {pfiltro: 'med.nombre_medio', type: 'string'},
			grid: true,
			form: true
		},
        {
            config: {
                name: 'fecha_limite_respuesta',
                fieldLabel: 'Fecha Limite de Respuesta',
                allowBlank: true,
                readOnly: true,
                anchor: '80%',
                gwidth: 150,
                maxLength: 15,
                format: 'd/m/Y',
                style: 'background: #EAA8A8',
                labelStyle: 'background: #EAA8A8',
                renderer:function (value,p,record){
                    return value?value.dateFormat('d/m/Y'):''
                }
            },
            type: 'DateField',
            filters: {pfiltro: 'rec.fecha_limite_respuesta', type: 'date'},
            id_grupo: 4,
            grid: true,
            form: true
        },
        {
			config: {
				name: 'id_motivo_anulado',
				fieldLabel: 'Motivo Anulado',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_reclamo/control/MotivoAnulado/listarMotivoAnulado',
					id: 'id_motivo_anulado',
					root: 'datos',
					sortInfo: {
						field: 'motivo',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_motivo_anulado','motivo'],
					remoteSort: true,
					baseParams: {par_filtro: 'ma.motivo'}
				}),
				valueField: 'id_motivo_anulado',
				displayField: 'motivo',
				gdisplayField: 'motivo_anulado',
				hiddenName: 'id_motivo_anulado',
				forceSelection: true,
				typeAhead: false,
				editable: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 150,
				minChars: 2,
				resizable:true,
				listWidth:'240',

				renderer: function (value, p, record) {
					return String.format('{0}', record.data['motivo_anulado']);
				}
			},
			type: 'ComboBox',
			id_grupo: 5,
			filters: {pfiltro: 'ma.motivo', type: 'string'},
			grid: true,
			form: true
		},{
			config: {
				name: 'estado_reg',
				fieldLabel: 'Estado Reg.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 10
			},
			type: 'TextField',
			filters: {pfiltro: 'rec.estado_reg', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: false
		},

		{
			config: {
				name: 'usr_reg',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 4
			},
			type: 'Field',
			filters: {pfiltro: 'usu1.cuenta', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: false
		},
		{
			config: {
				name: 'fecha_reg',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer: function (value, p, record) {
					return value ? value.dateFormat('d/m/Y H:i:s') : ''
				}
			},
			type: 'DateField',
			filters: {pfiltro: 'rec.fecha_reg', type: 'date'},
			id_grupo: 1,
			grid: true,
			form: false
		},
		{
			config: {
				name: 'usuario_ai',
				fieldLabel: 'Funcionaro AI',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 300
			},
			type: 'TextField',
			filters: {pfiltro: 'rec.usuario_ai', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: false
		},
		{
			config: {
				name: 'id_usuario_ai',
				fieldLabel: 'Funcionaro AI',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 4
			},
			type: 'Field',
			filters: {pfiltro: 'rec.id_usuario_ai', type: 'numeric'},
			id_grupo: 1,
			grid: false,
			form: false
		},
		{
			config: {
				name: 'fecha_mod',
				fieldLabel: 'Fecha Modif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer: function (value, p, record) {
					return value ? value.dateFormat('d/m/Y H:i:s') : ''
				}
			},
			type: 'DateField',
			filters: {pfiltro: 'rec.fecha_mod', type: 'date'},
			id_grupo: 1,
			grid: true,
			form: false
		},
		{
			config: {
				name: 'usr_mod',
				fieldLabel: 'Modificado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 4
			},
			type: 'Field',
			filters: {pfiltro: 'usu2.cuenta', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: false
		}
	],
	tam_pag: 50,
	title: 'Reclamo',
	ActSave: '../../sis_reclamo/control/Reclamo/insertarReclamo',
	ActDel: '../../sis_reclamo/control/Reclamo/eliminarReclamo',
	ActList: '../../sis_reclamo/control/Reclamo/listarReclamo',
	id_store: 'id_reclamo',
	fields: [
		{name: 'id_reclamo', type: 'numeric'},
		{name: 'id_tipo_incidente', type: 'numeric'},
		{name: 'id_subtipo_incidente', type: 'numeric'},
		{name: 'id_medio_reclamo', type: 'numeric'},
		{name: 'id_funcionario_recepcion', type: 'numeric'},
		{name: 'id_funcionario_denunciado', type: 'numeric'},
		{name: 'id_oficina_incidente', type: 'numeric'},
		{name: 'id_oficina_registro_incidente', type: 'numeric'},
		{name: 'id_proceso_wf', type: 'numeric'},
		{name: 'id_estado_wf', type: 'numeric'},
		{name: 'id_cliente', type: 'string'},
		{name: 'estado', type: 'string', dataIndex:'estado'},
		{name: 'fecha_hora_incidente', type: 'date', dateFormat: 'Y-m-d H:i:s'},
		{name: 'nro_ripat_att', type: 'numeric'},
		{name: 'nro_hoja_ruta', type: 'numeric'},
		{name: 'fecha_hora_recepcion', type: 'date', dateFormat: 'Y-m-d H:i:s'},
		{name: 'estado_reg', type: 'string'},
		{name: 'fecha_hora_vuelo', type: 'date', dateFormat: 'Y-m-d H:i:s'},
		{name: 'origen', type: 'string'},
		{name: 'nro_frd', type: 'string'},
		{name: 'correlativo_preimpreso_frd', type: 'numeric'},
		{name: 'fecha_limite_respuesta', type: 'date', dateFormat: 'Y-m-d'},
		{name: 'observaciones_incidente', type: 'string'},
		{name: 'destino', type: 'string'},
		{name: 'nro_pir', type: 'numeric'},
		{name: 'nro_frsa', type: 'numeric'},
		{name: 'nro_att_canalizado', type: 'numeric'},
		{name: 'nro_tramite', type: 'numeric'},
		{name: 'detalle_incidente', type: 'string'},
		{name: 'pnr', type: 'string'},
		{name: 'nro_vuelo', type: 'string'},
		{name: 'id_usuario_reg', type: 'numeric'},
		{name: 'fecha_reg', type: 'date', dateFormat: 'Y-m-d H:i:s.u'},
		{name: 'usuario_ai', type: 'string'},
		{name: 'id_usuario_ai', type: 'numeric'},
		{name: 'fecha_mod', type: 'date', dateFormat: 'Y-m-d H:i:s.u'},
		{name: 'id_usuario_mod', type: 'numeric'},
		{name: 'usr_reg', type: 'string'},
		{name: 'usr_mod', type: 'string'},


		/*{name: 'correlativo', type: 'numeric'},*/

		{name: 'desc_nom_cliente', type: 'string'},
		{name: 'desc_nombre_incidente', type: 'string'},
		{name: 'desc_sudnom_incidente', type: 'string'},
		{name: 'desc_nombre_medio', type: 'string'},
		{name: 'desc_nombre_funcionario', type: 'string'},
		{name: 'desc_nombre_fun_denun', type: 'string'},
		{name: 'desc_nombre_oficina', type: 'string'},
		{name: 'desc_oficina_registro_incidente', type: 'string'},
		{name: 'id_gestion', type: 'int4'},
		{name: 'tiempo_respuesta', type: 'string'},
		{name: 'revisado', type: 'string'},/*,
		{name: 'desc_funcionario1', type: 'string'},*/

		{name: 'transito', type: 'string'},
		{name: 'dias_respuesta', type: 'string'},
		{name: 'dias_informe', type: 'string'},
		{name: 'motivo', type: 'string'},
		{name: 'motivo_anulado', type: 'string'},
		{name: 'id_motivo_anulado', type: 'numeric'},
		{name: 'nombre_cargo', type: 'string'},
		{name: 'cargo', type: 'string'},
		{name: 'email', type: 'string'},
		{name: 'email2', type: 'string'},
		{name: 'nombre_completo2', type: 'string'},
		{name: 'administrador', type: 'numeric'},
		{name: 'id_informe', type: 'numeric'},
		{name: 'nro_cite', type: 'string'}


	],
	sortInfo: {
		field: 'fecha_limite_respuesta',
		direction: 'ASC'
	},
	bdel: true,
	bedit: true,
	btest: false,
	fwidth: '75%',
	fheight : '95%',
	bodyStyle: 'padding:0 10px 0;',
	Grupos: [
		{
			layout: 'column',
			border: false,
			defaults: {
				border: false
			},

			items: [
				{
					bodyStyle: 'padding-right:10px;',
					items: [

						{
							xtype: 'fieldset',
							title: 'DATOS TECNICOS',
							autoHeight: true,
							items: [/*this.compositeFields()*/],
							id_grupo: 0
						},
						{
							xtype: 'fieldset',
							title: 'DATOS DEL CLIENTE',
							autoHeight: true,
							items: [],
							id_grupo: 1
						},
						{
							xtype: 'fieldset',
							title: 'DATOS DEL SERVICIO QUE ORIGINA EL RECLAMO',
							autoHeight: true,
							items: [],
							id_grupo: 2
						}
					]
				}
				,
				{
					bodyStyle: 'padding-right:10px;',
					items: [
						{
							xtype: 'fieldset',
							title: 'DATOS DEL INCIDENTE',
							autoHeight: true,
							items: [],
							id_grupo: 3
						},
						{
							bodyStyle: 'padding-left:5px;',
							xtype: 'fieldset',
							title: 'DATOS DE RECEPCION',
							autoHeight: true,
							items: [],
							id_grupo: 4
						}
					]
				}
			]
		}
	],
	arrayDefaultColumHidden:[
		'nro_frsa','nro_pir','nro_att_canalizado','nro_ripat_att',
		'nro_hoja_ruta','origen','destino'
	],
	tabsouth :[
		{
			url:'../../../sis_reclamo/vista/informe/Informe.php',
			title:'Informe',
			height:'50%',
			cls:'Informe'
		},
		{
			url:'../../../sis_reclamo/vista/respuesta/RespuestaDetalle.php',
			title:'RespuestaDetalle',
			height:'50%',
			cls:'RespuestaDetalle'
		}
	],

	preparaMenu: function(n)
	{	var rec = this.getSelectedData();
		var tb =this.tbar;

		this.getBoton('btnChequeoDocumentosWf').setDisabled(false);
		Phx.vista.Reclamo.superclass.preparaMenu.call(this,n);
		this.getBoton('diagrama_gantt').enable();
		this.getBoton('btnObs').enable();
		//this.getBoton('reportes').enable();


		//return tb;
	},

	liberaMenu:function(){
		var tb = Phx.vista.Reclamo.superclass.liberaMenu.call(this);
		if(tb){
			this.getBoton('ant_estado').disable();
			this.getBoton('sig_estado').disable();
			this.getBoton('btnChequeoDocumentosWf').setDisabled(true);
			this.getBoton('diagrama_gantt').disable();
			this.getBoton('btnObs').disable();
			//this.getBoton('reportes').disable();
		}
		return tb
	},

	loadCheckDocumentosRecWf:function() {
		var rec=this.sm.getSelected();
		rec.data.nombreVista = this.nombreVista;
		Phx.CP.loadWindows('../../../sis_workflow/vista/documento_wf/DocumentoWf.php',
			'Chequear documento del WF',
			{
				width:'90%',
				height:500
			},
			rec.data,
			this.idContenedor,
			'DocumentoWf'
		)
	},

	onOpenObs:function() {
		var rec=this.sm.getSelected();
		var data = {
			id_proceso_wf: rec.data.id_proceso_wf,
			id_estado_wf: rec.data.id_estado_wf,
			num_tramite: rec.data.nro_tramite
		}
		Phx.CP.loadWindows('../../../sis_workflow/vista/obs/Obs.php',
			'Observaciones del WF',
			{
				width:'80%',
				height:'70%'
			},
			data,
			this.idContenedor,
			'Obs'
		)
	},

	antEstado:function(res){
		var rec=this.sm.getSelected();
		Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/AntFormEstadoWf.php',
			'Estado de Wf',
			{
				modal:true,
				width:450,
				height:250
			}, {
		        data:rec.data,
                estado_destino: res.argument.estado
		    },
            this.idContenedor,'AntFormEstadoWf',
			{
				config:[{
					event:'beforesave',
					delegate: this.onAntEstado,
				}
				],
				scope:this
			})
	},

	onAntEstado: function(wizard,resp){

		Phx.CP.loadingShow();
		Ext.Ajax.request({
			url:'../../sis_reclamo/control/Reclamo/anteriorEstadoReclamo',
			params:{
				id_proceso_wf: resp.id_proceso_wf,
				id_estado_wf:  resp.id_estado_wf,
				obs: resp.obs,
				estado_destino: resp.estado_destino
			},
			argument:{wizard:wizard},
			success:this.successEstadoSinc,
			failure: this.conexionFailure,
			timeout:this.timeout,
			scope:this
		});
	},

	successEstadoSinc:function(resp){
		Phx.CP.loadingHide();
		resp.argument.wizard.panel.destroy();
		this.reload();
	},

	sigEstado: function(){
		var rec = this.sm.getSelected();
		/*Ext.Ajax.request({
			url:'../../sis_reclamo/control/Reclamo/getDatosOficina',
			params:{id_usuario:0},
			success:function(resp){
				var reg =  Ext.decode(Ext.util.Format.trim(resp.responseText));
				console.log(reg);
			},
			failure: this.conexionFailure,
			timeout:this.timeout,
			scope:this
		});*/

		if(rec.data.estado=='pendiente_revision' && rec.data.nro_ripat_att==null){
			//Ext.Msg.alert('ATENCION !!!','<b>Olvido N° Ripatt, verifique si asigno numero  de Registro Ripatt al Reclamo</b>');
			this.onButtonEdit();
		}else {
			console.log('funcion--> estado:' + rec.data.id_estado_wf + 'proceso:' + rec.data.id_proceso_wf);
			this.objWizard = Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/FormEstadoWf.php',
				'Estado de Wf',
				{
					modal: true,
					width: 700,
					height: 450
				},
				{
					data: {
						id_estado_wf: rec.data.id_estado_wf,
						id_proceso_wf: rec.data.id_proceso_wf
					}
				}, this.idContenedor, 'FormEstadoWf',
				{
					config: [{
						event: 'beforesave',
						delegate: this.onSaveWizard,
					}],
					scope: this
				}
			);

		}
	},

	onSaveWizard:function(wizard,resp){
		var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));

		Phx.CP.loadingShow();
		Ext.Ajax.request({
			url:'../../sis_reclamo/control/Reclamo/siguienteEstadoReclamo',
			params:{
				id_proceso_wf_act:  resp.id_proceso_wf_act,
				id_estado_wf_act:   resp.id_estado_wf_act,
				id_tipo_estado:     resp.id_tipo_estado,
				id_funcionario_wf:  resp.id_funcionario_wf,
				id_depto_wf:        resp.id_depto_wf,
				obs:                resp.obs,
				json_procesos:      Ext.util.JSON.encode(resp.procesos)
			},
			success:this.successWizard,
			failure: this.conexionFailure,
			argument:{wizard:wizard},
			timeout:this.timeout,
			scope:this
		});
	},

	successWizard:function(resp){
		var rec = this.sm.getSelected();

		var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));

		Phx.CP.loadingHide();
		resp.argument.wizard.panel.destroy();

		var estado = reg.ROOT.datos.v_codigo_estado_siguiente;

		if(estado=='pendiente_revision' ){
            Ext.Msg.show({
                title: 'Información',
                msg: '<b>A partir de este momento usted tiene '+'\n'+' <span style="color: red">72 horas</span> para registrar el informe correspondiente y Adjuntar Documentacion de Respaldo.</b>',
                buttons: Ext.Msg.OK,
                width: 512,
                icon: Ext.Msg.INFO
            });
		}

		//Elegir el motivo de anulacion.
		if(estado=='anulado'){
			this.onButtonEdit();
		}

		this.reload();
	},


	iniciarEvento:function() {

		this.Cmp.id_tipo_incidente.on('select', function (cmb, record, index) {
			this.Cmp.id_subtipo_incidente.reset();
			this.Cmp.id_subtipo_incidente.modificado = true;
			this.Cmp.id_subtipo_incidente.setDisabled(false);
			this.Cmp.id_subtipo_incidente.store.setBaseParam('fk_tipo_incidente', record.data.id_tipo_incidente);

		}, this);

        
		this.Cmp.id_oficina_registro_incidente.on('focus', function () {
			this.val_oficina = this.Cmp.id_oficina_registro_incidente.getRawValue();
		},this);
		this.Cmp.id_funcionario_recepcion.on('focus', function () {
			this.val_funcionario = this.Cmp.id_funcionario_recepcion.getRawValue();
		},this);

		this.Cmp.id_oficina_registro_incidente.on('select', function () {
			this.val_oficina = this.Cmp.id_oficina_registro_incidente.getRawValue();
		},this);
		this.Cmp.id_funcionario_recepcion.on('select', function () {
			this.val_funcionario = this.Cmp.id_funcionario_recepcion.getRawValue();
		},this);


		this.Cmp.id_oficina_registro_incidente.on('blur', function () {
			this.Cmp.id_oficina_registro_incidente.setRawValue(this.val_oficina);
		},this);
		this.Cmp.id_funcionario_recepcion.on('blur', function () {
			this.Cmp.id_funcionario_recepcion.setRawValue(this.val_funcionario);
		},this);

		/*that = this;
		setInterval(function(){ that.reload();},30000);*/
	},

	/*onButtonAct : function(){
		Phx.vista.Reclamo.superclass.onButtonAct.call(this);
	},*/

	onButtonNew : function () {

		Phx.CP.loadingShow();
		Ext.Ajax.request({
			url:'../../sis_workflow/control/TipoColumna/listarColumnasFormulario',
			params:{
				codigo_proceso:  'REC',
				proceso_macro:   'REC'
			},
			success:this.saveCampos,
			failure: this.conexionFailure,
			timeout:this.timeout,
			scope:this
		});


		//Phx.vista.Reclamo.superclass.onButtonNew.call(this);
	},

	saveCampos: function(resp){
		Phx.CP.loadingHide();
		var objRes = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));

		Phx.vista.Reclamo.superclass.onButtonNew.call(this);
        this.momento = 'new';

        var fecha = new Date();
		this.armarFormularioFromArray(objRes.datos);

		this.Cmp.id_subtipo_incidente.disable();
		this.Cmp.observaciones_incidente.setValue('Ninguna.');
		this.Cmp.fecha_hora_vuelo.setValue(new Date((fecha.getMonth()+1)+'/'+fecha.getDate()+'/'+fecha.getFullYear()));
		this.Cmp.fecha_hora_incidente.setValue(new Date((fecha.getMonth()+1)+'/'+fecha.getDate()+'/'+fecha.getFullYear()));
		this.Cmp.fecha_hora_recepcion.setValue(fecha);



		Ext.Ajax.request({
			url:'../../sis_reclamo/control/Reclamo/getDatosOficina',
			params:{
			    id_usuario: 0
			},
			success:function(resp){
				var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));

				this.Cmp.id_oficina_registro_incidente.setValue(reg.ROOT.datos.id_oficina);
				this.Cmp.id_oficina_registro_incidente.setRawValue(reg.ROOT.datos.oficina_nombre);

				this.Cmp.id_funcionario_recepcion.setValue(reg.ROOT.datos.id_funcionario);
				this.Cmp.id_funcionario_recepcion.setRawValue(reg.ROOT.datos.desc_funcionario1);

                this.Cmp.nro_frd.setValue(reg.ROOT.datos.v_frd);

                /*this.Cmp.id_oficina_registro_incidente.reset();
                this.Cmp.id_oficina_registro_incidente.modificado = true;
                this.Cmp.id_oficina_registro_incidente.store.setBaseParam('id_funcionario', reg.ROOT.datos.id_funcionario);*/
			},
			failure: this.conexionFailure,
			timeout:this.timeout,
			scope:this
		});




	},

	/*actualizarFRD:function () {

		Ext.Ajax.request({
			url:'../../sis_reclamo/control/Reclamo/getFRD',
			params:{
				oficina:this.Cmp.id_oficina_registro_incidente.getValue()
			},
			success: function(resp){
				var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));
				//this.Cmp.nro_frd.setValue(reg.ROOT.datos.v_frd);
			},
			failure: this.conexionFailure,
			timeout:this.timeout,
			scope:this
		});

	},
    onSubmit:function(o){
        Phx.vista.Reclamo.superclass.onSubmit.call(this,o);
        this.actualizarFRD();
    },*/
    onSubmit: function (o,x, force) {
        //Phx.vista.Cliente.superclass.onSubmit.call(this, o);
		console.log('tres',this.Cmp.id_oficina_registro_incidente.getValue(),
			this.Cmp.id_oficina_registro_incidente.getRawValue(),

			this.Cmp.id_funcionario_recepcion.getValue(),
			this.Cmp.id_funcionario_recepcion.getRawValue());
        if(this.momento == 'edit'){
            Phx.vista.Reclamo.superclass.onSubmit.call(this, o);
        }else if(this.momento == 'new') {
            Ext.Ajax.request({
                url: '../../sis_reclamo/control/Reclamo/validarReclamo',
                params: {
                    correlativo: this.Cmp.correlativo_preimpreso_frd.getValue(),
                    frd: this.Cmp.nro_frd.getValue(),
					oficina: this.Cmp.id_oficina_registro_incidente.getValue()
                },
                success: function (resp) {
                    var reg = Ext.decode(Ext.util.Format.trim(resp.responseText));

                    var bandera = reg.ROOT.datos.v_band_frds;

                    var cad_aux = reg.ROOT.datos.v_cad_frds.replace(/<br>/gi,'');

                    if (reg.ROOT.datos.v_valid == 'true') {
                        //Ext.Msg.alert('','El Reclamo con Correlativo Preimpreso  Nro. <b>' + this.Cmp.correlativo_preimpreso_frd.getValue()+ '</b> y F.R.D. Nro.<b>' + this.Cmp.nro_frd.getValue() + '</b> ya fue registrado en la <b>'+this.Cmp.id_oficina_registro_incidente.getRawValue()+'</b>, verifique los reclamos registrados en esta oficina.');
                        Ext.Msg.show({
                            title: 'Alerta',
                            msg: '<div>El Reclamo con Correlativo Preimpreso  Nro. <b>' + this.Cmp.correlativo_preimpreso_frd.getValue()+ '</b> y F.R.D. Nro.<b>' + this.Cmp.nro_frd.getValue() + '</b> ya fue registrado en la <b>'+this.Cmp.id_oficina_registro_incidente.getRawValue()+'</b>, verifique los reclamos registrados en esta oficina.</div>',
                            buttons: Ext.Msg.OK,
                            width: 600,
							maxWidth:1024,
                            icon: Ext.Msg.WARNING
                        });
                    }else if(bandera == 'duplicado'){

                        this.titulo = 'Duplicidad de Numero FRD';
                        this.mensaje = 'Estimado usuario, esta tratando de insertar un numero de FRD que ya fue registrado anteriormente en el sistema, favor verificar los numeros FRDS de su oficina mediante la opcion Control de FRDS.<br><br> ' +
                            'Haga click en <b>Aceptar</b> para pasar por alto la alerta o <b>Cancelar</b> para revisar y correguir el Numero de FRD.<br>'+
                            '<br><div><b>Advertencia:</b> Al pasar por alto esta alerta, se guardara un registro de omision de revision. Esta seguro de continuar?.</div>';

                        if(reg.ROOT.datos.v_cad_frds != ''){
                            this.mensaje = '<br><div> Estimado usuario, esta tratando de insertar un numero de FRD que ya fue registrado anteriormente en el sistema, a continuación le mostramos la lista de FRDS que no se utilizaron: <br><br>'+reg.ROOT.datos.v_cad_frds+'</div>' +
                                ' Le suguerimos usar algun numero de frd de esta lista para el registro que esta realizando, la finalidad es tener un control correlativo de los FRDS de su oficina.'+
                                '<br><br> Haga click en <b>Aceptar</b> para pasar por alto esta alerta o <b>Cancelar</b> para poder revisar y correguir el Numero de FRD.<br>' +
                                '<br><div><b>Advertencia:</b> Al pasar por alto esta alerta, se guardara un registro de su omision. Esta seguro de continuar?.</div>'
                        }

                        Ext.Msg.show({
                            title: this.titulo,
                            msg: this.mensaje,
                            fn: function (btn){
                                if(btn == 'ok'){
                                    Phx.vista.Reclamo.superclass.onSubmit.call(this, o);
                                    this.bandera_log = true;
                                }
                            },
                            buttons: Ext.Msg.OKCANCEL,
                            width: 800,
                            maxWidth:1024,
                            icon: Ext.Msg.WARNING,
                            scope:this
                        });
                    }else if(bandera == 'nuevo'){

                        if(reg.ROOT.datos.v_cad_frds != ''){

                            if(cad_aux.indexOf(parseInt(this.Cmp.nro_frd.getValue()))>=0){
                                Phx.vista.Reclamo.superclass.onSubmit.call(this, o);
                            }else{
                                this.titulo = 'Disponibilidad';
                                this.mensaje = 'Señor usuario esta tratando de insertar un numero de frd que no existe en su oficina,pero tenga en conocimiento que tiene numeros de frds que no se utilizaron en su oficina'+
                                    ' le suguerimos usar algun numero de frd de esta lista para el registro que esta realizando, la finalidad es tener un control correlativo de los reclamos de su oficina.<br><br>'+reg.ROOT.datos.v_cad_frds+'</div><br>'+
                                    ' <br>Haga click en <b>Aceptar</b> para pasar por alto la sugerencia,o <b>Cancelar</b> para poder correguir o cambiar lo suguerido.<br>' +
                                    '<br><div><b>Advertencia:</b>Señor usuario tenga en conocimiento que al pasar por alto estas sugerencias, se guardara un registro de sus faltas, esta seguro de registrar el reclamo.</div>';
                                Ext.Msg.show({
                                    title: this.titulo,
                                    msg: this.mensaje,
                                    fn: function (btn) {
                                        if(btn == 'ok'){
                                            Phx.vista.Reclamo.superclass.onSubmit.call(this, o);
                                            this.bandera_log = true;
                                        }
                                    },
                                    buttons: Ext.Msg.OKCANCEL,
                                    width: 800,
                                    maxWidth:1024,
                                    icon: Ext.Msg.WARNING,
                                    scope:this
                                });
                            }

                        }else{
                            Phx.vista.Reclamo.superclass.onSubmit.call(this, o);
                        }
                    }else if(bandera == 'mayor'){
                        this.titulo = 'Excediendo';
                        this.mensaje = 'Señor usuario el sistema le genera automaticamente el numero frd correspondiente, efectivamente el numero de frd que esta utilizando  no existe en su oficina,pero tenga en conocimiento que el numero es excesivamente mayor a lo sugerido.'+
                            '<br> Para cualquier consulta sobre los numeros de frds haga click en el boton "Control FRDS".'+
                            ' <br><br>Haga click en <b>Aceptar</b> para pasar por alto la sugerencia,o <b>Cancelar</b> para poder correguir o cambiar lo suguerido.<br>' +
                            '<br><div><b>Advertencia:</b>Señor usuario tenga en conocimiento que al pasar por alto estas sugerencias, se guardara un registro de sus faltas, esta seguro de registrar el reclamo.</div>';
                        Ext.Msg.show({
                            title: this.titulo,
                            msg: this.mensaje,
                            fn: function (btn) {
                                if(btn == 'ok'){
                                    Phx.vista.Reclamo.superclass.onSubmit.call(this, o);
                                    this.bandera_log = true;
                                }
                            },
                            buttons: Ext.Msg.OKCANCEL,
                            width: 800,
                            maxWidth:1024,
                            icon: Ext.Msg.WARNING,
                            scope:this
                        });
                    }
                    else
                        Phx.vista.Reclamo.superclass.onSubmit.call(this, o);

                },
                failure: this.conexionFailure,
                timeout: this.timeout,
                scope: this
            });
        }

    },
	successSave:function(resp){
		Phx.vista.Reclamo.superclass.successSave.call(this,resp);

		var objRes = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));
        //console.log('objRes',objRes);
        if(this.bandera_log){
            var fecha_hora = new Date();
            Ext.Ajax.request({
                url: '../../sis_reclamo/control/Reclamo/insertarLog',
                params: {
                    descripcion: 'En fecha <b>'+fecha_hora.getDate() + '/' + (fecha_hora.getMonth() + 1) + '/' + fecha_hora.getFullYear()+' '+fecha_hora.getHours() + ':' + fecha_hora.getMinutes() + ':' + fecha_hora.getSeconds()+'</b> el funcionario <b>'+this.Cmp.id_funcionario_recepcion.getRawValue()+'</b> hizo caso omiso a los mensajes de sugerencia. <br>Detalle: <br> Titulo: <b>'+this.titulo+'</b>, <br> Mensaje: <br>'+this.mensaje,
                    id_reclamo: objRes.ROOT.datos.id_reclamo,
                    id_funcionario: this.Cmp.id_funcionario_recepcion.getValue()
                },
                success:function (resp) {
                    var objRes = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));
                    //Phx.vista.Reclamo.superclass.onSubmit.call(this, o);
                    console.log('se Guardo con exito el log: ',objRes.ROOT.datos.id_logs_reclamo)
                },
                failure: this.conexionFailure,
                timeout: this.timeout,
                scope: this
            });
        }

		if(objRes.ROOT.datos.v_momento == 'new'){
			this.sigEstado2(objRes.ROOT.datos.v_id_estado_wf, objRes.ROOT.datos.v_id_proceso_wf);
		}else{
			console.log('momento: '+objRes.ROOT.datos.v_momento);
		}
	},

	sigEstado2: function(estado, proceso) {
		this.objWizard = Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/FormEstadoWf.php',
			'Estado de Wf',
			{
				modal: true,
				width: 700,
				height: 450
			},
			{
				data: {
					id_estado_wf: estado,
					id_proceso_wf: proceso
				}
			}, this.idContenedor, 'FormEstadoWf',
			{
				config: [{
					event: 'beforesave',
					delegate: this.onSaveWizard2,
				}],
				scope: this
			}
		);
	},

	onSaveWizard2:function(wizard,resp){
		var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));

		Phx.CP.loadingShow();
		Ext.Ajax.request({
			url:'../../sis_reclamo/control/Reclamo/siguienteEstadoReclamo',
			params:{

				id_proceso_wf_act:  resp.id_proceso_wf_act,
				id_estado_wf_act:   resp.id_estado_wf_act,
				id_tipo_estado:     resp.id_tipo_estado,
				id_funcionario_wf:  resp.id_funcionario_wf,
				id_depto_wf:        resp.id_depto_wf,
				obs:                resp.obs,
				json_procesos:      Ext.util.JSON.encode(resp.procesos)
			},
			success:this.successWizard2,
			failure: this.conexionFailure,
			argument:{wizard:wizard},
			timeout:this.timeout,
			scope:this
		});
	},

	successWizard2:function(resp){
		var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));

		var estado = reg.ROOT.datos.v_codigo_estado_siguiente;

		Phx.CP.loadingHide();
		resp.argument.wizard.panel.destroy();

		if(estado=='pendiente_revision'){
            Ext.Msg.show({
                title: 'Información',
                msg: '<b>A partir de este momento usted tiene '+'\n'+' <span style="color: red">72 horas</span> para registrar el informe correspondiente y Adjuntar Documentacion de Respaldo.</b>',
                buttons: Ext.Msg.OK,
                width: 512,
                icon: Ext.Msg.INFO
            });
			//Ext.Msg.alert('ATENCION !!!','<b>A partir de este momento usted tiene '+'\n'+' <span style="color: red">48 horas</span> para registrar el informe correspondiente y Adjuntar Documentacion de Respaldo.</b>');

		}

		if(estado=='registrado_ripat' && rec.data.nro_ripat_att==null){
			this.onButtonEdit();
		}

		console.log('v_codigo_estado_siguiente: '+reg.ROOT.datos.v_codigo_estado_siguiente);

		//Elegir el motivo de anulacion.
		if(estado=='anulado'){
			this.onButtonEdit();
		}

		this.reload();
	},

	onButtonEdit: function(){

		var rec = this.sm.getSelected();
		console.log('onButtonEdit: '+rec);
		this.Cmp.id_subtipo_incidente.store.setBaseParam('fk_tipo_incidente', rec.data.id_tipo_incidente);
		Phx.CP.loadingShow();
		Ext.Ajax.request({
			url:'../../sis_workflow/control/TipoColumna/listarColumnasFormulario',
			params:{

				id_estado_wf: rec.data['id_estado_wf']
			},
			success:this.editCampos,
			failure: this.conexionFailure,
			timeout:this.timeout,
			scope:this
		});
		Phx.vista.Reclamo.superclass.onButtonEdit.call(this);
        this.momento = 'edit';
        console.log(this.momento);
	},

	editCampos: function(resp){
		Phx.CP.loadingHide();
		var objRes = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));
		//console.log('campos Edit: '+JSON.stringify(objRes));
		this.armarFormularioFromArray(objRes.datos);
	},

	cargarCliente : function (id_cliente, nombre_cliente) {
		this.Cmp.id_cliente.setValue(id_cliente);
		this.Cmp.id_cliente.setRawValue(nombre_cliente.toUpperCase());
	}
});
</script>

