const auxiliarMixins = {
    methods: { 
        fechaInicioAnio () {
            const today = new Date();
            const first_day = new Date(today.getFullYear(), 0, 1);
            const dd = String(first_day.getDate()).padStart(2, '0');
            const mm = String(first_day.getMonth() + 1).padStart(2, '0'); //January is 0!
            const yyyy = first_day.getFullYear();
            return dd + '-' + mm + '-' + yyyy;
        },  
        fechaActual () {
            const today = new Date();
            const dd = String(today.getDate()).padStart(2, '0');
            const mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            const yyyy = today.getFullYear();
            return dd + '-' + mm + '-' + yyyy;
        },
        formatoFecha (value) {
            if (value) {
                const formato = /^(((0[1-9]|[12]\d|3[01])\-(0[13578]|1[02])\-((19|[2-9]\d)\d{2}))|((0[1-9]|[12]\d|30)\-(0[13456789]|1[012])\-((19|[2-9]\d)\d{2}))|((0[1-9]|1\d|2[0-8])\-02\-((19|[2-9]\d)\d{2}))|(29\-02\-((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|(([1][26]|[2468][048]|[3579][26])00))))$/
                return( value.match(formato) ? true : false )
            } else {
                return false;
            }
        }
    }
}

export default auxiliarMixins;