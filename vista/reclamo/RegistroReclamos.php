<?php
/**
 *@package pXP
 *@file RegistroReclamos.php
 *@author  (Franklin Espinoza)
 *@date 13-10-2016 14:45
 *@Interface para el inicio de solicitudes de compra
 */
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
    Phx.vista.RegistroReclamos = {
        require:'../../../sis_reclamo/vista/reclamo/Reclamo.php',
        requireclase:'Phx.vista.Reclamo',
        title:'Reclamo',
        nombreVista: 'RegistroReclamos',
        fwidth: '65%',
        fheight : '80%',
    constructor: function(config){
        this.maestro=config.maestro;

        this.tbarItems = ['-',
            this.cmbGestion,'-'

        ];
        this.Atributos.splice(5,0,{
             config: {
             name: 'dias_informe',
             fieldLabel: 'Dias Para Adjuntar Inf.',
             allowBlank: true,
             anchor: '100%',
             gwidth: 125,
             maxLength: 100,
             renderer: function(value, p, record) {
             var dias = record.data.dias_informe;
             if(record.data.revisado == 'con_informe')
                 return  String.format('{0}',"<div style='text-align:center'><img title='El Reclamo ya tiene Informe'  src = '../../../sis_reclamo/media/respondido.png' align='center' width='24' height='24'/></div>");
             else if (dias == 3) {
                 return  String.format('{0}',"<div style='text-align:center'><img title='Tiene 72 Horas Para adjuntar Informe'  src = '../../../sis_reclamo/media/three.png' align='center' width='24' height='24'/></div>");
             }else if (dias == 2) {
                 return  String.format('{0}',"<div style='text-align:center'><img title='Tiene 48 Horas Para adjuntar Informe'  src = '../../../sis_reclamo/media/two.png' align='center' width='24' height='24'/></div>");
             } else if(dias>=0 && dias<=1){
                 return  String.format('{0}',"<div style='text-align:center'><img title='Tiene 24 Horas Para adjuntar Informe'  src = '../../../sis_reclamo/media/cero.png' align='center' width='24' height='24'/></div>");
             }else if(dias = -1 && record.data.revisado != 'con_informe'){
                 return  String.format('{0}',"<div style='text-align:center'><img title='Ha vencido el Plazo para poder adjuntar Informe'  src = '../../../sis_reclamo/media/bomb.png' align='center' width='24' height='24'/></div>");
             }
             }
             },
             type: 'Checkbox',
             grid: true,
             form: false
         });
        this.Atributos.unshift({
            //configuracion del componente
            config: {
                labelSeparator: '',
                inputType: 'hidden',
                name: 'interfaz',
                value:'registrado'
            },
            type: 'Field',
            form: true,
            id_grupo:1
        });
        aux = this.Atributos[16]
        this.Atributos[16] = this.Atributos[31];
        this.Atributos[31] = aux;

        Phx.vista.RegistroReclamos.superclass.constructor.call(this,config);
        this.store.baseParams.tipo_interfaz=this.nombreVista;

        //Cargamos gestion del que se mostraran los registros.
        Ext.Ajax.request({
            url:'../../sis_reclamo/control/Reclamo/getDatosOficina',
            params:{id_usuario:0},
            success:function(resp){
                var reg =  Ext.decode(Ext.util.Format.trim(resp.responseText));

                this.cmbGestion.setValue(reg.ROOT.datos.id_gestion);
                this.cmbGestion.setRawValue(reg.ROOT.datos.gestion);
                console.log(reg.ROOT.datos.id_gestion);
                this.store.baseParams.id_gestion = reg.ROOT.datos.id_gestion;
                this.load({params:{start:0, limit:this.tam_pag}});

            },
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        });

        this.addButton('control_frds',{
            grupo:[0,1,2,3,4,5],
            text :'Control FRDS',
            iconCls : 'bfolder',
            disabled: false,
            handler : this.winFRD,
            tooltip : '<b>Control FRDS</b><br/>Nos permite llevar un seguimiento de los frd que no se registran.'
        });

        this.cmbGestion.on('select',this.capturarEventos, this);
        this.getBoton('ant_estado').setVisible(false);

        this.plazo = new Ext.form.Label({
            name: 'fecha_limite_reg',
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

    winFRD: function (){
        var rec=this.sm.getSelected();


        if(rec == undefined){
            rec = {data:{nombreVista:'RegistroReclamos'}}
        }else{
            rec.data.nombreVista = 'RegistroReclamos';
        }
        Phx.CP.loadWindows(
            '../../../sis_reclamo/vista/reclamo/ControlFRD.php',
            'Control de FRDS',
            {
                width:'80%',
                height:'80%'
            },
            rec.data,
            this.idContenedor,
            'ControlFRD'
        );
    },

    cmbGestion: new Ext.form.ComboBox({
        name: 'gestion',
        id: 'gestion_reg',
        fieldLabel: 'Gestion',
        allowBlank: true,
        emptyText:'Gestion...',
        blankText: 'Año',
        store:new Ext.data.JsonStore(
            {
                url: '../../sis_parametros/control/Gestion/listarGestion',
                id: 'id_gestion',
                root: 'datos',
                sortInfo:{
                    field: 'gestion',
                    direction: 'DESC'
                },
                totalProperty: 'total',
                fields: ['id_gestion','gestion'],
                // turn on remote sorting
                remoteSort: true,
                baseParams:{par_filtro:'gestion'}
            }),
        valueField: 'id_gestion',
        triggerAction: 'all',
        displayField: 'gestion',
        hiddenName: 'id_gestion',
        mode:'remote',
        pageSize:50,
        queryDelay:500,
        listWidth:'280',
        hidden:false,
        width:80
    }),
    gruposBarraTareas:[
        {name:'borrador',title:'<H1 align="center"><i class="fa fa-list-ul"></i> Borradores</h1>',grupo:0,height:0, width: 100},
        {name:'pendiente_revision',title:'<H1 align="center"><i class="fa fa-list-ul"></i>Adjuntar Informe</h1>',grupo:2,height:0, width: 100},
        {name:'pendiente_informacion',title:'<H1 align="center"><i class="fa fa-files-o"></i> Pendientes Inf.</h1>',grupo:1,height:0},
        {name:'en_proceso',title:'<H1 align="center"><i class="fa fa-gear"></i> En Proceso </h1>',grupo:3,height:0},
        {name:'concluidos',title:'<H1 align="center"><i class="fa fa-power-off"></i> Concluidos </h1>',grupo:4,height:0}
    ],
    tam_pag:50,
    actualizarSegunTab: function(name, indice){

        if(this.finCons){
            this.plazo.setText('');
            if(name == 'borrador'){
                this.getBoton('ant_estado').setVisible(false);
                this.store.baseParams.pes_estado = name;
                this.load({params:{start:0, limit:this.tam_pag}});
            }else if(name == 'en_proceso' || name == 'concluidos'){
                this.getBoton('sig_estado').setVisible(false);
                this.getBoton('ant_estado').setVisible(false);
                this.store.baseParams.pes_estado = name;
                this.load({params:{start:0, limit:this.tam_pag}});
            }else if(name == 'pendiente_revision'){
                this.getBoton('sig_estado').setVisible(false);
                this.getBoton('ant_estado').setVisible(false);
                this.store.baseParams.pes_estado = 'pendiente_informe';
                this.load({params:{start:0, limit:this.tam_pag}});
            }else{
                this.store.baseParams.pes_estado = name;
                this.load({params:{start:0, limit:this.tam_pag}});
            }
            
        }
    },
    beditGroups: [0],
    bdelGroups:  [0],
    bactGroups:  [0,1,2,3,4],
    bexcelGroups: [0,1,2,3,4],
    tabsouth :[
        {
            url:'../../../sis_reclamo/vista/informe/Informe.php',
            title:'Informe',
            height:'50%',
            cls:'Informe'
        }
    ],

    enableTabRespuesta:function(){
        if(this.TabPanelSouth.get(0)){
            //console.debug('uno: '+this.TabPanelSouth.get(0));
            this.TabPanelSouth.get(0).enable();
            this.TabPanelSouth.setActiveTab(0);
        }
    },

    disableTabRespuesta:function(){
        if(this.TabPanelSouth.get(0)){
            //console.log('dos: '+Ext.util.JSON.decode(this.TabPanelSouth.get(0)));
            this.TabPanelSouth.get(0).disable();
            //this.TabPanelSouth.setActiveTab(0)
        }
    },
    preparaMenu:function(n){
        var data = this.getSelectedData();
        var tb =this.tbar;
        //console.log('registro_1:'+data);
        //console.log('registro_2:'+JSON.stringify(data));
        Phx.vista.RegistroReclamos.superclass.preparaMenu.call(this,n);
        //habilitar reporte de colicitud de comrpa y preorden de compra
        //var dataPadre = Phx.CP.getPagina(this.idContenedorPadre).getSelectedData();

        //this.getBoton('control_frds').enable();
        //console.log('papa: '+this.padre);
        if(data['estado'] ==  'borrador'){
            this.getBoton('sig_estado').setVisible(true);
            //this.getBoton('ant_estado').setVisible(false);
            this.getBoton('btnObs').setVisible(true);
            this.getBoton('sig_estado').enable();
            this.disableTabRespuesta();

        }else if(data['estado'] ==  'pendiente_revision' || data['estado'] ==  'registrado_ripat'){

            this.getBoton('btnObs').setVisible(true);
            this.getBoton('sig_estado').disable();
            this.getBoton('ant_estado').disable();
            this.enableTabRespuesta();
        }
        else if(data['estado'] ==  'pendiente_informacion'){
            this.getBoton('sig_estado').setVisible(true);
            this.getBoton('ant_estado').setVisible(true);
            this.getBoton('btnObs').setVisible(true);
            this.getBoton('sig_estado').enable();
            this.getBoton('ant_estado').enable();
            this.enableTabRespuesta();

        }else {
            this.getBoton('sig_estado').setVisible(false);
            this.getBoton('ant_estado').setVisible(false);
            this.getBoton('btnObs').setVisible(false);
        }

        return tb;
    },

    liberaMenu:function(){
        var tb = Phx.vista.RegistroReclamos.superclass.liberaMenu.call(this);
        //var data = this.getSelectedData();
        if(tb){
            //this.getBoton('control_frds').disable();
            this.getBoton('sig_estado').disable();
            this.getBoton('sig_estado').disable();
            /*estados = 'pendiente_asignacion, pendiente_respuesta, en_avenimiento, archivo_con_respuesta, respuesta_registrado_ripatt, archivado_concluido';
            estados = estados.split(',');
            console.log(estados,data);*/
        }

        return tb;
    },

    onButtonEdit: function() {
        Phx.vista.RegistroReclamos.superclass.onButtonEdit.call(this);
    },

    capturarEventos: function () {
        //if(this.validarFiltros()){
        //this.capturaFiltros();
        //}
        this.store.baseParams.id_gestion=this.cmbGestion.getValue();
        this.load({params:{start:0, limit:this.tam_pag}});
    }

    /*,

    actualizarFRD:function () {

        Ext.Ajax.request({
            url:'../../sis_reclamo/control/Reclamo/getFRD',
            params:{
                oficina:this.Cmp.id_oficina_registro_incidente.getValue()
            },
            success: function(resp){
                var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));
                //this.Cmp.nro_frd.setValue(reg.ROOT.datos.v_frd);
                console.log('FRD',reg.ROOT.datos.v_frd);
            },
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        });

    },

    onSubmit:function(o){
        Phx.vista.RegistroReclamos.superclass.onSubmit.call(this,o);
        this.actualizarFRD();
    }*/

    };
</script>
