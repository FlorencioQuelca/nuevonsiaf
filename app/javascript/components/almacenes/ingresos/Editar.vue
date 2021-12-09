<template>
    <div>
        <div class="page-header">
            <h2>Editar Nota de Ingreso # {{ingreso.ingreso.nro_nota_ingreso}}</h2>
        </div>
        <formulario v-bind:datos="ingreso" v-bind:urlBase="urlBase"/>
    </div>
</template>

<script>
    import Formulario from './Formulario.vue';
    export default {
        name: 'Editar',
        props: ['ingreso', 'urlBase'],
        components: {
            Formulario
        }
    }
</script>

<style lang="scss" scoped>

</style>