<?php

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
    Phx.vista.RegistroReclamoAnulado = {
    	momento: '',
        require:'../../../sis_reclamo/vista/reclamo/Reclamo.php',
        requireclase:'Phx.vista.Reclamo',
        title:'Reclamo',
        nombreVista: 'RegistroReclamoAnulado',
        fwidth: '65%',
        fheight : '80%',        
    constructor: function(config){
        this.maestro=config.maestro;                       
        Phx.vista.RegistroReclamoAnulado.superclass.constructor.call(this,config);
        this.getBoton('ant_estado').setVisible(false);
        this.getBoton('btnObs').setVisible(false);                    
        this.store.baseParams.tipo_interfaz=this.nombreVista;

        this.plazo = new Ext.form.Label({
            name: 'fecha_limite_sel',
            grupo: [0,1,2,3,4],
            fieldLabel: 'Fecha',
            allowBlank: false,
            anchor: '60%',
            gwidth: 100,
            format: 'd/m/Y',
            hidden : false,
            readOnly:true,
            style: 'font-size: 25pt; font-weight: bold; background-image: none; color: #ff4040;'
        });

        this.tbar.addField(this.plazo);
    },
    
 tabsouth :null,//desabilita la vista hija
    
    gruposBarraTareas:[
        {name:'borrador',title:'<H1 align="center"><i class="fa fa-list-ul"></i> Borradores </h1>',grupo:0,height:0, width: 100},
        {name:'pendiente_revision',title:'<H1 align="center"><i class="fa fa-list-ul"></i> Revisiones </h1>',grupo:2,height:0, width: 100},        
        {name:'anulado',title:'<H1 align="center"><i class="fa fa-folder"></i> Anulados</h1>',grupo:3,height:0}
    ],    
    tam_pag:50,
    actualizarSegunTab: function(name, indice){
        if(this.finCons){
            this.plazo.setText('');
            if(name == 'borrador'){
                this.getBoton('ant_estado').setVisible(false);
                this.getBoton('btnObs').setVisible(false);
                this.store.baseParams.pes_estado = name;
            }else if(name == 'pendiente_revision'){
                this.getBoton('ant_estado').setVisible(false);
                this.getBoton('sig_estado').setVisible(false);
                this.getBoton('btnObs').setVisible(false);                
                this.store.baseParams.pes_estado = 'pendiente_revision';
            }else{
                this.store.baseParams.pes_estado = name;
                this.getBoton('ant_estado').setVisible(false);
                this.getBoton('sig_estado').setVisible(false);
                this.getBoton('btnObs').setVisible(false);
            }
            this.load({params:{start:0, limit:this.tam_pag}});
            
        }
    },
    beditGroups: [0],
    bdelGroups:  [0],
    bactGroups:  [0,1,2,3,4],
    bexcelGroups: [0,1,2,3,4],

    enableTabRespuesta:function(){
        if(this.TabPanelSouth.get(0)){            
            this.TabPanelSouth.get(0).enable();
            this.TabPanelSouth.setActiveTab(0);
        }
    },

    /*disableTabRespuesta:function(){
        if(this.TabPanelSouth.get(0)){
            this.TabPanelSouth.get(0).disable();
            //this.TabPanelSouth.setActiveTab(0)
        }
    },*/
    preparaMenu:function(n){
        var data = this.getSelectedData();
        var tb =this.tbar;
        Phx.vista.RegistroReclamoAnulado.superclass.preparaMenu.call(this,n);

        if(data['estado'] ==  'borrador'){        	
            this.getBoton('sig_estado').setVisible(true);                                    
            this.getBoton('sig_estado').enable();
            //this.disableTabRespuesta();

        }/*else if(data['estado'] ==  'pendiente_revision'){        	
            this.getBoton('sig_estado').setVisible(false);                        
            this.getBoton('sig_estado').enable();            
            this.enableTabRespuesta();

        }*/else if(data['estado']=='anulado') {        	
            this.getBoton('sig_estado').setVisible(false);                        
        }

        return tb;
    },

    liberaMenu:function(){
        var tb = Phx.vista.RegistroReclamoAnulado.superclass.liberaMenu.call(this);

        if(tb){        
            this.getBoton('sig_estado').disable();
            this.getBoton('ant_estado').setVisible(false);
			this.getBoton('btnObs').setVisible(false);
        }

        return tb;
    },
Grupos:false,    
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
	},
	fwidth: '30%',
	fheight : '55%',
	saveCampos: function(resp){
		Phx.CP.loadingHide();
		var objRes = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));		
		Phx.vista.Reclamo.superclass.onButtonNew.call(this);
        this.momento = 'new';
		this.armarFormularioFromArray(objRes.datos);
			
		var fecha = new Date(); 
		
		this.Cmp.nro_vuelo.setVisible(false);
		this.Cmp.origen.setVisible(false);
        this.Cmp.destino.setVisible(false);        
        this.Cmp.fecha_hora_vuelo.setVisible(false);
        this.Cmp.fecha_hora_incidente.setVisible(false);
        this.Cmp.transito.setVisible(false);
        this.Cmp.id_subtipo_incidente.disable();
        this.Cmp.detalle_incidente.setVisible(false);
        this.Cmp.observaciones_incidente.setVisible(false);			
       /* this.Cmp.nro_vuelo.disable();        
        this.Cmp.destino.disable();
        this.Cmp.origen.disable();
        this.Cmp.fecha_hora_vuelo.disable();
        this.Cmp.fecha_hora_incidente.disable();
        this.Cmp.transito.disable();
        this.Cmp.id_subtipo_incidente.disable();
        this.Cmp.detalle_incidente.disable();
        this.Cmp.observaciones_incidente.disable();*/
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
			},
			failure: this.conexionFailure,
			timeout:this.timeout,
			scope:this
		});
	},


   /* sigEstado: function(){
        var rec = this.sm.getSelected();
        if(rec.data.estado=='pendiente_revision' && rec.data.nro_ripat_att==null){           
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



        this.reload();
    },*/
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
		this.armarFormularioFromArray(objRes.datos);
		
		var u = this.Cmp.id_oficina_registro_incidente.value;
		
		//this.Cmp.correlativo_preimpreso_frd.setVisible(false);
		//this.Cmp.nro_frd.setVisible(false);
		this.Cmp.nro_att_canalizado.setVisible(false);
		this.Cmp.nro_vuelo.setVisible(false);
		this.Cmp.origen.setVisible(false);
        this.Cmp.destino.setVisible(false);        
        this.Cmp.fecha_hora_vuelo.setVisible(false);
        this.Cmp.fecha_hora_incidente.setVisible(false);
        this.Cmp.transito.setVisible(false);
        this.Cmp.id_subtipo_incidente.disable();
        this.Cmp.detalle_incidente.setVisible(false);
        this.Cmp.observaciones_incidente.setVisible(false);	
        this.Cmp.id_funcionario_denunciado.setVisible(false);
        
        //this.Cmp.id_oficina_incidente.setValue(u);
        
	}, 	
	fwidth: '65%',
	fheight : '50%',
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
                            items: [],
                            id_grupo: 0
                        },
                    	{
							xtype: 'fieldset',
							title: 'DATOS DEL INCIDENTE',
							autoHeight: true,
							items: [],
							id_grupo: 3
						},                        
                    ]
                }
                ,
                {
                    bodyStyle: 'padding-right:10px;',
                    items: [

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
                 
};
</script>
