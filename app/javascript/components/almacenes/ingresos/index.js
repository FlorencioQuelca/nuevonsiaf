/* eslint no-console: 0 */
import Vue from 'vue'
import Axios from 'axios'
import Editar from './Editar.vue'
import Vuelidate from 'vuelidate'

Vue.use(Vuelidate)
Vue.prototype.$http = Axios

Vue.filter('formatoMoneda', function(string){
  let valor = parseFloat(string);
  return valor.toFixed(2);
})

document.addEventListener('DOMContentLoaded', () => {
  const elemento = document.getElementById('v-editar')
  if (elemento != null) {
    const props = JSON.parse(elemento.getAttribute('data'))
    const app = new Vue({
      el: elemento,
      components: { Editar },
      render(createElement) { 
        return createElement('editar', { props })
      },
    })
  }
})
