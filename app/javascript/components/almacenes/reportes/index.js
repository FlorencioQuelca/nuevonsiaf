import Vue from 'vue'
import Inventario from './InventarioFisicoValoradoV2.vue';

Vue.filter('mayusculas', function(cadena){
  return cadena.toUpperCase();
})

Vue.filter('numeros_con_delimitador', function(numero){
  return parseFloat(numero).toLocaleString('en-US', {minimumFractionDigits: 2})
})

Vue.filter('mostrar_entero_flotante', function(numero){
  return parseFloat(numero) % 1 == 0 ? parseInt(numero).toString() : numero
})

document.addEventListener('DOMContentLoaded', () => {
  const elementoInventario = document.getElementById('v-inventario-fisico-valorado-v2')
  if (elementoInventario != null && JSON.parse(elementoInventario.getAttribute('data-ingreso')) != null) {
    const props = { "cuentas": JSON.parse(elementoInventario.getAttribute('data-ingreso')), "urlBase": elementoInventario.getAttribute('data-urlBase') }
    const app = new Vue({
      el: elementoInventario,
      components: { Inventario },
      render(createElement) { 
        return createElement('inventario', { props });
      },
    })
  }
})