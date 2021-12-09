<template>
  <div>
    <div class="col-md-12">
      <div id="spinner-front">
        <div class="spinner-image"></div>
      </div>
      <div id="spinner-back"></div>

      <h3 class="h3">
        <template v-if="tipo == 'detalle'">
          Inventario General de Almacenes Físico Valorado
        </template>
        <template v-else>
          Resumen Inventario de Almacenes Físico Valorado
        </template>
        <template v-if="mostrar_cabecera">
          <span class="text-muted">desde</span>
          <span><b>{{this.fecha_inicio}} 00:00:00</b></span>
          <span class="text-muted">hasta</span>
          <span><b> {{this.fecha_fin}} 23:59:59</b></span>
        </template>
      </h3>
      <div class="form-inline">
        <div class="form-group">
          <label for="cuenta_contable">Cuenta contable:</label>
          <div class="hidden-sm hidden-md hidden-lg"></div>
            <select id="cuenta-contable" class="form-control" multiple="multiple">
              <option v-for="(item) in this.cuentas" v-bind:key="item.id" v-bind:value="item.id">{{item.code}} - {{item.description}}</option>
            </select>
        </div>
      <div class="form-group">
        <label for="fecha-desde">Desde:</label>
        <input type="text" id="fecha-desde" v-model='fecha_inicio' class="form-control fecha-buscador date" placeholder="Desde fecha (DD-MM-AAAA)" autocomplete="off">
      </div>

      <div class="form-group">
        <label for="fecha-hasta">Hasta:</label>
        <input type="text" id="fecha-hasta" v-model='fecha_fin' class="form-control fecha-buscador date" placeholder="Hasta fecha (DD-MM-AAAA)" autocomplete="off">
      </div>

      <div class="form-group">
        <input type="checkbox" id="mostrar-cero-existencias" v-model='ceros'>
        <label for="mostrar-cero-existencias">Sin registros cero</label>
      </div>

      <div class="form-group">
        <button class="btn btn-primary" @click="generarReporte">
          <span class="glyphicon glyphicon-search"></span>
          Generar
        </button>
      </div>
      <div class="form-group">
        <div class="dropdown">
          <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown" :disabled="disabled_descargable">
            <span class="glyphicon glyphicon-save"></span>
            Descargar
            <span class="caret"></span>
            </button>
          <ul class="dropdown-menu">
            <li><a @click="generar_pdf">PDF</a></li>
            <li><a @click="generar_ods_csv('ods')">ODS</a></li>
            <li><a @click="generar_ods_csv('csv')">CSV</a></li>
          </ul>
        </div>
      </div>

      </div>
      <div class="page-header" id="materiales-data"></div>
      <template v-if="this.datos && this.datos.detalle">
        <div class="form-inline">
          <div class="form-group pull-right">
            <label class="radio-inline"><input type="radio" value="detalle" v-model="tipo">Inventario General</label>
            <label class="radio-inline"><input type="radio" value="resumen" v-model="tipo">Resumen</label>
          </div>
        </div>
        <div class="row reporte reporte-10">
          <div class="col-sm-12">
            <table class="table table-condensed table-bordered valorado table-hover">
              <thead>
                <tr class="vertical-align info">
                  <th class="text-center" rowspan="2">CÓDIGO</th>
                  <th class="text-center" rowspan="2">GRUPO CONTABLE</th>
                  <th class="text-center" rowspan="2">UNIDAD</th>
                  <th class="text-center" colspan="4">FÍSICO</th>
                  <th class="text-center" colspan="4">VALORADO</th>
                </tr>
                <tr class="vertical-align info">
                  <th class="text-center">Inicio</th>
                  <th class="text-center">Ingreso</th>
                  <th class="text-center">Egreso</th>
                  <th class="text-center">Final</th>
                  <th class="text-center">Inicio</th>
                  <th class="text-center">Ingreso</th>
                  <th class="text-center">Egreso</th>
                  <th class="text-center">Final</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item) in this.datos.detalle" v-bind:key="item.id" v-bind:class="[(item.grupo) ? 'warning' : ''] ">
                  <template v-if="item.grupo">
                    <th>{{item.code_material}}</th>
                    <th>{{item.description}}</th>
                    <th></th>
                    <component v-bind:is="(tipo === 'detalle' && item.grupo) ? 'th' : 'td'" class="number">{{ item.fisico_inicial | mostrar_entero_flotante }}</component>
                    <component v-bind:is="(tipo === 'detalle' && item.grupo) ? 'th' : 'td'" class="number">{{ item.fisico_ingreso | mostrar_entero_flotante }}</component>
                    <component v-bind:is="(tipo === 'detalle' && item.grupo) ? 'th' : 'td'" class="number">{{ item.fisico_egreso | mostrar_entero_flotante }}</component>
                    <component v-bind:is="(tipo === 'detalle' && item.grupo) ? 'th' : 'td'" class="number">{{ item.fisico_final | mostrar_entero_flotante }}</component>
                    <component v-bind:is="(tipo === 'detalle' && item.grupo) ? 'th' : 'td'" class="number">{{ item.valorado_inicial | numeros_con_delimitador }}</component>
                    <component v-bind:is="(tipo === 'detalle' && item.grupo) ? 'th' : 'td'" class="number">{{ item.valorado_ingreso | numeros_con_delimitador }}</component>
                    <component v-bind:is="(tipo === 'detalle' && item.grupo) ? 'th' : 'td'" class="number">{{ item.valorado_egreso | numeros_con_delimitador }}</component>
                    <component v-bind:is="(tipo === 'detalle' && item.grupo) ? 'th' : 'td'" class="number">{{ item.valorado_final | numeros_con_delimitador }}</component>
                  </template>
                  <template v-else>
                    <template v-if="tipo == 'detalle'">
                      <td>{{item.code_subarticle}}</td>
                      <td>{{item.description}}</td>
                      <td>{{item.unit | mayusculas}}</td>
                      <td class="number">{{item.fisico_inicial | mostrar_entero_flotante }}</td>
                      <td class="number">{{item.fisico_ingreso | mostrar_entero_flotante }}</td>
                      <td class="number">{{item.fisico_egreso | mostrar_entero_flotante }}</td>
                      <td class="number">{{item.fisico_final | mostrar_entero_flotante }}</td>
                      <td class="number">{{ item.valorado_inicial | numeros_con_delimitador }}</td>
                      <td class="number">{{ item.valorado_ingreso | numeros_con_delimitador }}</td>
                      <td class="number">{{ item.valorado_egreso | numeros_con_delimitador }}</td>
                      <td class="number">{{ item.valorado_final | numeros_con_delimitador }}</td>  
                    </template>
                    
                  </template>
                </tr>
                <tr>
                  <th class="text-center" colspan="7">TOTALES</th>
                  <th class="number">{{ datos.total_valorado_inicial | numeros_con_delimitador }}</th>
                  <th class="number">{{ datos.total_valorado_ingreso | numeros_con_delimitador }}</th>
                  <th class="number">{{ datos.total_valorado_egreso | numeros_con_delimitador }}</th>
                  <th class="number">{{ datos.total_valorado_final | numeros_con_delimitador }}</th>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import ReportesServicios from '../../../services/reportes'
import 'bootstrap-multiselect/dist/js/bootstrap-multiselect.js'
import 'bootstrap-multiselect/dist/css/bootstrap-multiselect.css'
import auxiliarMixins from 'mixins/auxiliarMixins'
const reportesServicio = new ReportesServicios();

export default {
  name: 'Inventario',
  mixins: [auxiliarMixins],
  props: ['cuentas', 'urlBase'],
  data () {
    return {
      msg: 'Resumen Físico Valorado',
      fecha_inicio: this.fechaInicioAnio(),
      fecha_fin: this.fechaActual(),
      datos: [],
      ceros: true,
      mostrar_cabecera: false,
      disabled_descargable: true,
      tipo: 'detalle'
    }
  },
  watch: {
    fecha_inicio() {
      this.disabled_descargable = true
      this.mostrar_cabecera = false
    },
    fecha_fin() {
      this.disabled_descargable = true
      this.mostrar_cabecera = false
    },
    ceros() {
      this.disabled_descargable = true
      this.mostrar_cabecera = false
    },
    tipo() {
      console.log(`presiono: ${this.tipo}`)
    }
  },
  methods: {
    iniciar () {
      const _ = this;
      window.onload = function() {
        $(".date").datepicker({
          autoclose: true,
          format: "dd-mm-yyyy",
          language: "es"
        })
        .on('changeDate', function(event) {
          event.target.dispatchEvent(new Event('input', {'bubbles': true}))
        })
        $("#cuenta-contable").multiselect({
          numberDisplayed: 0,
          nonSelectedText: 'Seleccionar...',
          selectAllText: 'Todos',
          allSelectedText: 'Todos seleccionados',
          nSelectedText: 'seleccionados',
          includeSelectAllOption: true,
          selectAllNumber: false,
          maxHeight: 400,
          dropUp: true
        });
        $("#cuenta-contable").on('change', function() {          
          _.disabled_descargable = true
          _.mostrar_cabecera = false
        })
      }
    },
    generarReporte() {
      this.disabled_descargable = true;
      if (this.validacion_filtros()) { 
        Spinner.show()
        this.datos = [];
        const data = {
          fisico_valorado: {
            cuenta_ids: $("#cuenta-contable").val(),
            fecha_inicio: this.fecha_inicio,
            fecha_fin: this.fecha_fin,
            ceros: this.ceros
          }
        }
        reportesServicio.obtiene_fisico_valorado({ url: '/api/v2/almacenes/reportes/fisico_valorado', datos: data})
            .then(response => {
              if(response.data.finalizado === true) {
                this.disabled_descargable = false;
                this.datos = response.data.datos;
                Spinner.hide()
                this.mostrar_cabecera = true;
              } else {
                this.disabled_descargable = true;
                new Notices({
                  ele: 'div.main'
                }).danger(response.data.mensaje);
                this.enviando = false
                Spinner.hide()
              }
            })
            .catch(error => {
              this.disabled_descargable = true;
              new Notices({
                  ele: 'div.main'
                }).danger("Se ha producido un error.");
              Spinner.hide()
            });
      }
    },
    generar_pdf() {
      let datos = {
        reporte: this.datos,
      }
      datos["fecha_desde"] = this.fecha_inicio
      datos["fecha_hasta"] = this.fecha_fin
      datos["tipo"] = this.tipo
      reportesServicio.obtiene_fisico_valorado_descargable({ url: '/api/v2/almacenes/reportes/fisico_valorado_pdf.pdf', datos: datos })
            .then(response => {
              const url = window.URL.createObjectURL(new Blob([response.data]));
              const link = document.createElement('a');
              link.href = url;
              link.setAttribute('download',`${ this.tipo == 'detalle' ? 'inventario-general' : 'resumen' }-fisico-valorado-${this.fecha_inicio}_${this.fecha_fin}.pdf`);
              document.body.appendChild(link);
              link.click();
              new Notices({
                ele: 'div.main'
              }).success("Se ha generado exitosamente el archivo");
            })
            .catch(error => {
              new Notices({
                  ele: 'div.main'
                }).danger("Se ha producido un error.");
            });
    },
    generar_ods_csv(extension) {
      let datos = {
        reporte: this.datos,
      }
      datos["fecha_desde"] = this.fecha_inicio
      datos["fecha_hasta"] = this.fecha_fin
      datos["tipo"] = this.tipo

      reportesServicio.obtiene_fisico_valorado_descargable({ url:'/api/v2/almacenes/reportes/fisico_valorado_ods_csv' + '.' + extension, datos: datos })
            .then(response => {
              const url = window.URL.createObjectURL(new Blob([response.data]));
              const link = document.createElement('a');
              link.href = url;
              link.setAttribute('download',`${ this.tipo == 'detalle' ? 'inventario-general' : 'resumen' }-fisico-valorado-${this.fecha_inicio}_${this.fecha_fin}.${extension}`);
              document.body.appendChild(link);
              link.click();
              new Notices({
                ele: 'div.main'
              }).success("Se ha generado exitosamente el archivo");
            })
            .catch(error => {
              new Notices({
                  ele: 'div.main'
                }).danger("Se ha producido un error.");
            });
    },
    validacion_filtros() {
      let respuesta =  true;
      if ( $("#cuenta-contable").val() === null || $("#cuenta-contable").val() === [] ) {
        new Notices({
            ele: 'div.main'
          }).danger("Debe seleccionar al menos una cuenta contable.");
        respuesta = false;
      }

      if ( !this.formatoFecha(this.fecha_inicio) ) {
        new Notices({
            ele: 'div.main'
          }).danger("El formato de su fecha Desde es incorrecto.");
        respuesta = false;
      }

      if ( !this.formatoFecha(this.fecha_fin) ) {
        new Notices({
            ele: 'div.main'
          }).danger("El formato de su fecha Hasta es incorrecto.");
        respuesta = false;
      }
      return respuesta;
    },
  },
  mounted () {
    this.iniciar()
  }
}
</script>

<style>
  label {
    font-weight: bold;
    margin-top: 10px;
  }
</style>