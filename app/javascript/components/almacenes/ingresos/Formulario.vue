<template>
  <div>
    <div class="simple_form form-horizontal edit_note_entry" id="edit_note_entry_6" novalidate="novalidate" action="/note_entries/6" accept-charset="UTF-8" method="post">

      <div v-if="ingreso.tipo_ingreso == 'donacion_transferencia'">
        <div class="col-sm-12 col-md-8 col-lg-8">
          <div class="form-group string optional">
              <label class="string optional col-sm-3 col-md-3 col-lg-3 control-label" for="note_entry_entidad_donante"> Entidad donante </label>
              <div class="controls col-sm-9 col-md-9 col-lg-9">
                <input v-model="ingreso.entidad_donante" class="string optional form-control" placeholder="Entidad donante" type="text" autocomplete="off">
              </div>
          </div>
        </div>
      </div>
      <div class="row" data-action="note_entry" v-if="ingreso.tipo_ingreso == 'compra'">
          <div class="col-sm-12 col-md-8 col-lg-8">
            <div class="form-group string required disabled note_entry_supplier_id">
                <label class="string required disabled col-sm-3 col-md-3 col-lg-3 control-label" for="note_entry_supplier_id"><abbr title="required">*</abbr> Proveedor</label>
                <div class="controls col-sm-9 col-md-9 col-lg-9">
                  <span class="twitter-typeahead" style="position: relative; display: inline-block; direction: ltr;">
                      <input v-model="ingreso.supplier.name" class="string required disabled form-control tt-input" disabled="disabled" required="required" aria-required="true" type="text" name="note_entry[supplier_id]" id="note_entry_supplier_id" autocomplete="off" spellcheck="false" dir="auto" style="position: relative; vertical-align: top; background-color: transparent;">
                      <pre aria-hidden="true" style="position: absolute; visibility: hidden; white-space: pre; font-family: arial; font-size: 12px; font-style: normal; font-variant: normal; font-weight: 400; word-spacing: 0px; letter-spacing: 0px; text-indent: 0px; text-rendering: auto; text-transform: none;"></pre>
                  </span>
                </div>
            </div>
          </div>
          <!-- <div class="col-sm-12 col-md-4 col-lg-4">
            <div class="form-group boolean optional note_entry_reingreso">
                <div class="controls col-sm-9 col-md-9 col-lg-9">
                  <label class="checkbox">
                  <input v-model="ingreso.reingreso" type="checkbox" value="1" name="note_entry[reingreso]" id="note_entry_reingreso" @click="actualizarReingreso">
                  ¿Reingreso?
                  </label>
                </div>
            </div>
          </div> -->
      </div>
      <div class="row" v-if="ingreso.tipo_ingreso == 'compra'">
          <div class="col-sm-12 col-md-8 col-lg-8">
            <div class="form-group string optional note_entry_c31">
                <label class="string optional col-sm-3 col-md-3 col-lg-3 control-label" for="note_entry_c31">Nº requerimiento/Nº preventivo</label>
                <div class="controls col-sm-9 col-md-9 col-lg-9">
                  <input v-model="ingreso.c31" class="string optional form-control" placeholder="Nº requerimiento/Nº preventivo" type="text" id="note_entry_c31" autocomplete="off">
                </div>
            </div>
          </div>
          <div class="col-sm-12 col-md-4 col-lg-4">
            <div class="form-group string optional note_entry_c31_fecha" :class="{ 'has-error': $v.ingreso.c31_fecha.$error}">
                <div class="controls col-sm-9 col-md-9 col-lg-9">
                  <div class="input-group note_entry_c31_fecha date">
                      <input v-model.trim="$v.ingreso.c31_fecha.$model" class="string optional form-control" placeholder="Fecha Nº requerimiento/Nº preventivo" type="text" autocomplete="off">
                      <span class="input-group-addon glyphicon glyphicon-calendar"></span>
                  </div>
                  <span class="help-block" v-if="!$v.ingreso.c31_fecha.formatoFecha">Debe tener el siguiente formato DD/MM/AAAA</span>
                </div>
            </div>
          </div>
      </div>
      <div class="row" v-if="ingreso.tipo_ingreso == 'compra'">
          <div class="col-sm-12 col-md-8 col-lg-8">
            <div class="form-group string optional note_entry_delivery_note_number">
                <label class="string optional col-sm-3 col-md-3 col-lg-3 control-label" for="note_entry_delivery_note_number">Nota de Entrega</label>
                <div class="controls col-sm-9 col-md-9 col-lg-9">
                  <input v-model="ingreso.delivery_note_number" class="string optional form-control" placeholder="Número de nota de entrega" type="text" autocomplete="off">
                </div>
            </div>
          </div>
          <div class="col-sm-12 col-md-4 col-lg-4">
            <div class="form-group string optional note_entry_delivery_note_date" :class="{ 'has-error': $v.ingreso.delivery_note_date.$error}">
                <div class="controls col-sm-9 col-md-9 col-lg-9">
                  <div class="input-group note_entry_delivery_note_date date">
                    <input v-model.trim="$v.ingreso.delivery_note_date.$model" class="string optional form-control" placeholder="Fecha nota entrega" type="text" autocomplete="off">
                    <span class="input-group-addon glyphicon glyphicon-calendar"></span>
                  </div>
                  <span class="help-block" v-if="!$v.ingreso.delivery_note_date.formatoFecha">Debe tener el siguiente formato DD/MM/AAAA</span>
                </div>
            </div>
          </div>

      </div>
      <div class="row">
          <div class="col-sm-12 col-md-8 col-lg-8">
            <div class="form-group string optional note_entry_invoice_number">
                <label class="string optional col-sm-3 col-md-3 col-lg-3 control-label" for="note_entry_invoice_number"> {{ etiquetas.factura_etiqueta }} </label>
                <div class="controls col-sm-4 col-md-4 col-lg-4">
                  <input v-model="ingreso.invoice_number" class="form-control" :placeholder="etiquetas.factura_placeholder" type="text" autocomplete="off">
                </div>
                <div class="controls col-sm-5 col-md-5 col-lg-5" v-if="ingreso.tipo_ingreso == 'compra'">
                  <input v-model="ingreso.invoice_autorizacion" class="form-control" placeholder="Número de autorización" type="text" autocomplete="off">
                </div>
            </div>
          </div>
          <div class="col-sm-12 col-md-4 col-lg-4">
            <div class="form-group string optional note_entry_invoice_date" :class="{ 'has-error': $v.ingreso.invoice_date.$error }">
                <div class="controls col-sm-9 col-md-9 col-lg-9">
                  <div class="input-group note_entry_invoice_date date">
                    <input v-model.trim="$v.ingreso.invoice_date.$model" class="string optional form-control" :placeholder="etiquetas.factura_fecha_placeholder" type="text" autocomplete="off">
                    <span class="input-group-addon glyphicon glyphicon-calendar"></span>
                  </div>
                  <span class="help-block" v-if="!$v.ingreso.invoice_date.formatoFecha">Debe tener el siguiente formato DD/MM/AAAA</span>
                </div>
            </div>
          </div>
      </div>
      <div class="row">
        <div class="col-sm-12 col-md-8 col-lg-8">
          <div class="form-group string">
              <label class="string optional col-sm-3 col-md-3 col-lg-3 control-label">Observaciones</label>
              <div class="col-xs-9 col-sm-9 col-md-9">
                <textarea v-model="ingreso.observacion" class="form-control" placeholder="Observaciones y/o información adicional"></textarea>
              </div>
          </div>
        </div>
      </div>
      <div class="row">
          <div class="col-sm-12 col-md-8 col-lg-8">
            <div class="form-group">
                <label class="col-sm-3 col-md-3 col-lg-3 control-label">Artículo</label>
                <div class="col-xs-9 col-sm-9 col-md-9">

                  <input type="text"
                    class="Typeahead__input form-control tt-input"
                    placeholder="Código o Descripción del Artículo"
                    autocomplete="off"
                    v-model="query"
                    @keydown.down="down"
                    @keydown.up="up"
                    @keydown.enter="hit"
                    @keydown.esc="reset"
                    @blur="reset"
                    @input="update"/>
                  <span v-if="items.length > 0" class="tt-dropdown-menu" style="position: absolute; top: 100%; left: 0px; z-index: 100; display: block; right: auto;">
                    <div class="tt-dataset-0">
                        <span class="tt-suggestions" style="display: block;">
                            <div class="tt-suggestion" v-for="(item, $item) in items" :key="item.id" :class="activeClass($item)" @mousedown="hit" @mousemove="setActive($item)">
                                <p style="white-space: normal;"><strong>{{item.code}}</strong> - <em>{{item.description}}</em></p>
                            </div>
                        </span>
                    </div>
                  </span>
                  <span v-if="query && items.length == 0" class="tt-dropdown-menu" style="position: absolute; top: 100%; left: 0px; z-index: 100; display: block; right: auto;">
                    <div class="tt-dataset-0">
                        <span class="tt-suggestions" style="display: block;">
                            <div class="tt-suggestion">
                                <p style="white-space: normal;"><strong>No se encontraron elementos.</strong></p>
                            </div>
                        </span>
                    </div>
                  </span>
                </div>
            </div>
          </div>
      </div>
      <table class="table table-bordered">
          <thead>
            <tr class="info vertical-align">
                <th class="text-center">CÓDIGO</th>
                <th class="text-center">UNIDAD</th>
                <th class="text-center description">DETALLE</th>
                <th class="text-center">CANTIDAD</th>
                <th class="text-center">PRECIO UNITARIO</th>
                <th class="text-center">PRECIO TOTAL</th>
                <th></th>
            </tr>
          </thead>
          <tbody id="subarticles">
            <tr class="subarticle" v-for="(item, indice) in $v.ingreso.entry_subarticles.$each.$iter" v-bind:key="item.id">
                <td class="text-center">{{item.$model.subarticle.code}}</td>
                <td class="text-center">{{item.$model.subarticle.unit}}</td>
                <td>{{item.$model.subarticle.description}}</td>
                <td class="col-sm-1 col-md-1 note">
                  <input v-model.trim="item.amount.$model" type="number" pattern="\d*" class="form-control amount text-right" :class="{ 'error-input': item.amount.$error }" step="1" autocomplete="off">
                </td>
                <td class="col-sm-1 col-md-1 note">
                  <input v-model.trim="item.unit_cost.$model" type="number" class="form-control unit_cost text-right" :class="{ 'error-input': item.unit_cost.$error }" step="0.1" autocomplete="off">
                </td>
                <td class="col-sm-1 col-md-1 number">
                  <span class="total-parcial">{{ item.$model.total_cost | formatoMoneda }}</span>
                </td>
                <td class="text-center">
                  <span class="glyphicon glyphicon-remove" @click="removerIngresoItem(indice)" title="Eliminar"></span>
                </td>
            </tr>
            <tr class="subtotal-sum">
              <td colspan="4"></td>
              <th class="text-right">SUBTOTAL</th>
              <th class="subtotal-suma number">{{ ingreso.subtotal | formatoMoneda }}</th>
            </tr>
            <tr>
              <td colspan="4"></td>
              <th class="text-right">DESCUENTO</th>
              <th class="col-xs-1 number note">
                <input v-model.trim="$v.ingreso.descuento.$model" class="form-control text-right descuento" :class="{ 'error-input': $v.ingreso.descuento.$error }" placeholder="Descuento" type="text" autocomplete="off">
              </th>
            </tr>
            <tr>
              <td colspan="4"></td>
              <th class="text-right">TOTAL</th>
              <th class="total-suma number">{{ ingreso.total | formatoMoneda }}</th>
            </tr>
          </tbody>
      </table>
      <div id="edit_save_note_entry">
          <div class="form-group">
            <div class="col-sm-offset-5 col-sm-9">
                <button @click="guardarDatos" :disabled='enviando' class="btn btn-primary">
                  <span class="glyphicon glyphicon-ok"></span>
                  Guardar
                </button>
                <a class="btn btn-danger" href="/note_entries">
                  <span class="glyphicon glyphicon-remove"></span>
                  Cancelar
                </a>
            </div>
          </div>
      </div>
    </div>
    <!-- <pre>{{$v.ingreso}}</pre>
    <pre>{{datos}}</pre> -->
  </div>
</template>

<script>
import VueTypeahead from 'vue-typeahead'
import IngresosServicios from '../../../services/ingresos'
const { required, minLength, minValue, requiredIf, decimal } = require('vuelidate/lib/validators')
const ingresosServicio = new IngresosServicios();


const formatoFecha = (value) => {
  if (value) {
    const formato = /^(((0[1-9]|[12]\d|3[01])\/(0[13578]|1[02])\/((19|[2-9]\d)\d{2}))|((0[1-9]|[12]\d|30)\/(0[13456789]|1[012])\/((19|[2-9]\d)\d{2}))|((0[1-9]|1\d|2[0-8])\/02\/((19|[2-9]\d)\d{2}))|(29\/02\/((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|(([1][26]|[2468][048]|[3579][26])00))))$/
    return( value.match(formato) ? true : false )
  } else {
    return true;
  }
}
const esEntero = (value) => {
  return parseFloat(value) === parseInt(value)
}

export default {
  extends: VueTypeahead,
  name: 'Formulario',
  props: ['datos', 'urlBase'],
  data () {
    return {
      src: '/subarticles/get_subarticles.json',
      limit: 10,
      minChars: 3,
      query:'',
      enviando: false,
      ingreso: this.datos.ingreso,
      etiquetas: {
        factura_etiqueta: 'Factura',
        factura_placeholder: 'Número de factura',
        factura_fecha_placeholder: 'Fecha factura'
      }
    }
  },
  methods: {
    iniciar () {
      window.onload = function() {
        $(".date").datepicker({
          autoclose: true,
          format: "dd/mm/yyyy",
          language: "es"
        })
        .on('changeDate', function(event) {
          let inputFields = event.target.getElementsByTagName('input');
          for (let i = 0; i < inputFields.length; i++) {
              inputFields[i].dispatchEvent(new Event('input', {'bubbles': true}));
          }
        })
      }
    },
    existe_subarticulo (code) {
      if (this.ingreso && this.ingreso.entry_subarticles) {
        const respuesta = this.ingreso.entry_subarticles.filter(item => item.subarticle.code === code)
        if(respuesta.length > 0){
          return true
        } else {
          return false
        }
      } else {
        return false
      }
    },
    adicionarIngresoItem (item) {
      if(this.existe_subarticulo(item.code)) {
        new Notices({
          ele: 'div.main'
        }).danger("Ya existe el subarticulo.");
      } else {
        let nuevoIngresoItem = {
          amount: 0,
          unit_cost: 0,
          total_cost: 0,
          subarticle: {
            id: item.id,
            code: item.code,
            description: item.description,
            unit: item.unit
          },
          note_entry_id: this.ingreso.id,
        }
        this.ingreso.entry_subarticles.push(nuevoIngresoItem)
      }
    },
    removerIngresoItem (indice) {
      this.ingreso.entry_subarticles.splice(indice, 1);
      this.$v.$touch()
    },
    obtenerTotalIngresoItem (item) {
      item.total_cost = item.amount * item.unit_cost;
      return item.total_cost;
    },
    actualizarReingreso () {
      if (this.ingreso.reingreso) {
        this.etiquetas.factura_etiqueta = 'Informe';
        this.etiquetas.factura_placeholder = 'Número de informe';
        this.etiquetas.factura_fecha_placeholder = 'Fecha informe';
      } else {
        this.etiquetas.factura_etiqueta = 'Factura';
        this.etiquetas.factura_placeholder = 'Número de factura';
        this.etiquetas.factura_fecha_placeholder = 'Fecha factura';
      }
    },
    guardarDatos () {
      this.enviando = true
      this.$v.$touch()
      if(this.$v.$invalid ){
        if(this.$v.ingreso.entry_subarticles.$error){
          new Notices({
            ele: 'div.main'
          }).danger("Debe registrar al menos un artículo valido.");
        }
        new Notices({
          ele: 'div.main'
        }).danger("Complete los campos correctamente.");
        if (!this.ingreso.delivery_note_date && !this.ingreso.invoice_date && !this.ingreso.c31_fecha) {
          new Notices({
            ele: 'div.main'
          }).danger("Al menos debe introducir una fecha.");
        }
        this.enviando = false
      } else {
        ingresosServicio.actualiza({ url: '/api/v2/almacenes/ingresos/' + this.ingreso.id, datos: { ingreso: this.ingreso } })
            .then(response => {
              if(response.data.finalizado === true) {
                new Notices({
                  ele: 'div.main'
                }).success(response.data.mensaje);
                window.location = '/note_entries/' + this.ingreso.id
              } else {
                new Notices({
                  ele: 'div.main'
                }).danger(response.data.mensaje);
                this.enviando = false
              }
            })
            .catch(error => {
              new Notices({
                  ele: 'div.main'
                }).danger("Se ha producido un error.");
            });
      }
    },
    // función del vue-typeahead
    onHit (item) {
      let listaOpciones = $('.tt-dropdown-menu');
      listaOpciones.map((i, opcion) => { opcion.style.display = 'none'; })
      this.adicionarIngresoItem(item);
      this.$v.$touch()
    },
    // función del vue-typeahead
    prepareResponseData (data) {
      let listaOpciones = $('.tt-dropdown-menu');
      listaOpciones.map((i, opcion) => { opcion.style.display = 'block'; })
      return data;
    }
  },
  mounted () {
    this.iniciar()
  },
  watch: {
    'ingreso.entry_subarticles': {
      handler(val){
        this.ingreso.entry_subarticles.map(function(item, i) {
          item.total_cost = parseFloat(item.amount) * parseFloat(item.unit_cost);
        })
        if(this.ingreso && this.ingreso.entry_subarticles && this.ingreso.entry_subarticles.length > 0) {
          let sumatoria = this.ingreso.entry_subarticles.reduce((a, b) => ({total_cost: a.total_cost + b.total_cost}))
          this.ingreso.subtotal = sumatoria.total_cost
        } else {
          this.ingreso.subtotal = 0
        }
        this.ingreso.total = this.ingreso.subtotal - parseFloat(this.ingreso.descuento)
      },
      deep: true
    },
    'ingreso.descuento': {
      handler(val){
        this.ingreso.total = this.ingreso.subtotal - parseFloat(this.ingreso.descuento)
      }
    }
  },
  validations: {
    ingreso: {
      c31_fecha:{
        formatoFecha,
        required: requiredIf(function () {
          return !this.ingreso.delivery_note_date && !this.ingreso.invoice_date
        })
      },
      delivery_note_date: {
        formatoFecha,
        required: requiredIf(function () {
          return !this.ingreso.c31_fecha && !this.ingreso.invoice_date
        })
      },
      invoice_date: {
        formatoFecha,
        required: requiredIf(function () {
          return !this.ingreso.c31_fecha && !this.ingreso.delivery_note_date
        })
      },
      descuento: {
        minValue: minValue(0),
        decimal,
        required
      },
      entry_subarticles: {
        required,
        minLength: minLength(1),
        $each: {
          amount: {
            esEntero,
            required,
            minValue: minValue(1)
          },
          unit_cost: {
            minValue: minValue(0),
            decimal,
            required
          }
        }
      }
    }
  }
}
</script>