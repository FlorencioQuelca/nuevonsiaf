var Celda = React.createClass({
  render() {
    if(typeof this.props.td != 'undefined'){
      return (
        <td className= { this.props.className } >
          { this.props.td }
        </td>
      );
    }
    else if (typeof this.props.th != 'undefined') {
      return (
        <th className= { this.props.className }>
          { this.props.th }
        </th>
      );
    }
    else {
      return(
        <td></td>
      );
    }
  }
});

var Opcion = React.createClass({
  render() {
    var clave = this.props.opcion.clave;
    var descripcion = this.props.opcion.descripcion;
    return(
        <option value = { clave }>
          { descripcion }
        </option>
    );
  }
});

var Fila = React.createClass({
  render() {
    var indice = this.props.indice;
    var codigo = this.props.fila.codigo;
    var factura = this.props.fila.factura;
    var fecha = this.props.fila.fecha;
    var descripcion = this.props.fila.descripcion;
    var cuenta = this.props.fila.cuenta;
    var precio = this.props.fila.precio;
    var lugar = this.props.fila.lugar;
    return (
      <tr>
        <Celda td = { indice } className = "text-right"/>
        <Celda td = { codigo } className = "text-center"/>
        <Celda td = { factura } className = "text-center"/>
        <Celda td = { fecha } className = "text-center"/>
        <Celda td = { descripcion }/>
        <Celda td = { cuenta }/>
        <Celda td = { lugar }/>
        <Celda td = { precio } className = "number"/>
      </tr>
    );
  }
});

var TablaReportes = React.createClass({
  componentDidUpdate(){
    var blob, blobURL, csv;
    csv = '';
    $('table > thead').find('tr').each(function() {
      var sep;
      sep = '';
      $(this).find('th').each(function() {
        csv += sep + $(this)[0].innerHTML;
        return sep = ';';
      });
      return csv += '\n';
    });
    $('table > tbody').find('tr').each(function() {
      var sep;
      sep = '';
      $(this).find('td').each(function() {
        csv += sep + $(this)[0].innerHTML;
        return sep = ';';
      });
      return csv += '\n';
    });
    $('table > tbody').find('tr:last').each(function() {
      var sep;
      sep = ';;;;';
      $(this).find('th').each(function() {
        csv += sep + $(this)[0].innerHTML;
        return sep = ';';
      });
      csv += '\n';
    });
    window.URL = window.URL || window.webkiURL;
    blob = new Blob([csv]);
    blobURL = window.URL.createObjectURL(blob);
    return $('#obtiene_csv').attr('href', blobURL).attr('download', 'data.csv');
  },

  mostrarTotal (){
    return(
      <tr>
        <th colSpan ='6' ></th>
        <th>TOTAL:</th>
        <th className = "number">{ this.props.total }</th>
      </tr>
    );
  },

  render() {
    if(this.props.tabla.length > 0){
      var filas = this.props.tabla.map((fila, i) => {
        return (
          <Fila key = { i + 1 }
                indice = { i + 1 }
                fila = { fila }/>
        )
      });
      return (
        <div>
          <div className="pull-right">
            <span >Descargar:</span>
            <div className="btn-group btn-group-xs">
              <a id="obtiene_csv" className="btn btn-default">CSV</a>
              <a id="obtiene_pdf" className="btn btn-default" href = {this.props.url_pdf}>PDF</a>
            </div>
          </div>
          <table className = "table table-condensed table-striped table-bordered valorado">
            <thead>
              <tr>
                <th className = "text-right">Nro</th>
                <th className = "text-center">Código</th>
                <th className = "text-center">Factura</th>
                <th className = "text-center">Fecha</th>
                <th>Descripción</th>
                <th>Cuenta</th>
                <th>Ubicación</th>
                <th className = "number"> Precio</th>
              </tr>
            </thead>
            <tbody>
              { filas }
              { this.mostrarTotal() }
            </tbody>
          </table>
        </div>
      );
    }
    else {
      return (
        <table className = "table table-condensed table-striped table-bordered valorado">
          <thead>
            <tr>
              <th className = "text-right">Nro</th>
              <th className = "text-center">Código</th>
              <th className = "text-center">Factura</th>
              <th className = "text-center">Fecha</th>
              <th>Descripción</th>
              <th>Cuenta</th>
                <th>Ubicación</th>
              <th className = "number"> Precio</th>
            </tr>
          </thead>
          <tbody>
          </tbody>
        </table>
      );
    }
  }
});

var ReportesBuscadorBasico = React.createClass({
  aplicandoBuscador(){
    var host = this.props.url;
    var cuenta = this.refs.cuenta.value;
    var desde = this.refs.desde.value;
    var hasta = this.refs.hasta.value;
    var col = this.refs.col.value;
    var q = this.refs.q.value;
    parametros = "?col=" + col + "&q=" + q + "&cu=" + cuenta + "&desde=" + desde + "&hasta=" + hasta;
    url = host + parametros;
    $.ajax({
        url:  url,
        type: 'GET',
        success: (response) => {
          this.props.actualizacionTabla(response);
          this.props.actualizacionUrlPDF({
                                          url: host + ".pdf" + parametros
                                        });
        },
        error:(xhr) => {
          this.props.actualizacionTabla({
                                          activos: [],
                                          total: ""
                                        });
          this.props.actualizacionUrlPDF({
                                          url: url + ".pdf" + parametros
                                        });
        }
    });
  },

  render(){
    if(this.props.cuentas.length > 0){
      var cuentas = this.props.cuentas.map((opcion, i) => {
        return (
          <Opcion key = { i }
                  opcion = { opcion }/>
        )
      });
    }
    var columnas = this.props.columnas.map((opcion, i) => {
      return (
        <Opcion key = { i }
                opcion = { opcion }/>
      )
    });
    return(
      <div>
        <div className="pull-right">
          <div className="form-group">
            <label className="sr-only" htmlFor= "columnas">columnas</label>
            <select ref = "col" name = "col" id="columnas" className = "form-control">
              { columnas }
            </select>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only" htmlFor="buscar">Buscar</label>
            <input ref = "q" type="text" name="q" id="q" className="form-control" placeholder="Buscar" autoComplete="off"/>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only" htmlFor="cuenta">cuenta</label>
            <select ref = "cuenta" name = "cuenta" id ="cuenta" className = "form-control">
              { cuentas }
            </select>
          </div>
          &nbsp;
          <div className="form-group">
            <label htmlFor="fecha-desde">Fechas</label>
            <input ref = "desde" type="text" name="desde" id="fecha-desde" className="form-control fecha-buscador" placeholder="Desde fecha" autoComplete="off"/>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only" htmlFor="fecha-hasta">Hasta</label>
            <input ref = "hasta" type="text" name="hasta" id="fecha-hasta" className="form-control fecha-buscador" placeholder="Hasta fecha" autoComplete="off"/>
          </div>
          &nbsp;
          <button className="btn btn-primary" title="Generar kardexes de todos los artículos" type="#" onClick={ this.aplicandoBuscador } >
            <span className="glyphicon glyphicon-search"></span>
          </button>
        </div>
      </div>
    );
  }
});

var ReportesBuscadorAvanzado = React.createClass({
  aplicandoBuscador(){
    var host = this.props.url;
    var cuenta = this.refs.cuenta.value;
    var desde = this.refs.desde.value;
    var hasta = this.refs.hasta.value;
    var codigo = this.refs.codigo.value;
    var numero_factura = this.refs.numero_factura.value;
    var descripcion = this.refs.descripcion.value;
    var precio = this.refs.precio.value;
    var ubicacion = this.refs.ubicacion.value;
    parametros = "?co=" + codigo + "&nf=" + numero_factura + "&de=" + descripcion +  "&cu=" + cuenta +  "&pr=" + precio + "&desde=" + desde + "&hasta=" + hasta + '&ub=' + ubicacion;
    url = host + parametros;
    $.ajax({
        url:  url,
        type: 'GET',
        success: (response) => {
          this.props.actualizacionTabla(response);
          this.props.actualizacionUrlPDF({
                                          url: host + ".pdf" + parametros
                                        });
        },
        error:(xhr) => {
          this.props.actualizacionTabla({
                                          activos: [],
                                          total: ""
                                        });
          this.props.actualizacionUrlPDF({
                                          url: url + ".pdf" + parametros
                                        });

        }
    });
  },

  render(){
    if(this.props.cuentas.length > 0){
      var cuentas = this.props.cuentas.map((opcion, i) => {
        return (
          <Opcion key = { i }
                  opcion = { opcion }/>
        )
      });
    }
    return(
      <div >
        <div className = "pull-right">
          <div className="form-group">
            <label className="sr-only">Código</label>
            <input ref = "ubicacion" type="text" name="ubicacion" id="ubicacion" className="form-control" placeholder="Ubicación" autoComplete="off"/>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only">Código</label>
            <input ref = "codigo" type="text" name="codigo" id="codigo" className="form-control" placeholder="Código" autoComplete="off"/>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only">Factura</label>
            <input ref = "numero_factura" type="text" name="numero_factura" id="factura" className="form-control" placeholder="Número Factura" autoComplete="off"/>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only">Descripción</label>
            <input ref = "descripcion" type="text" name="descripcion" id="descripcion" className="form-control" placeholder="Descripción" autoComplete="off"/>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only">Precio</label>
            <input ref = "precio" type="text" name="precio" id="precio" className="form-control" placeholder="Precios" autoComplete="off"/>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only" htmlFor="cuenta">cuenta</label>
            <select ref = "cuenta" id="cuenta" name = "cuenta" className = "form-control">
              { cuentas }
            </select>
          </div>
          &nbsp;
          <div className="form-group">
            <label htmlFor="fecha-hasta">Fechas</label>
            <input ref = "desde" type="text" name="desde" className="form-control fecha-buscador" placeholder="Desde fecha" autoComplete="off"/>
          </div>
          &nbsp;
          <div className="form-group">
            <label className="sr-only" htmlFor="fecha-hasta">Hasta</label>
            <input ref = "hasta" type="text" name="hasta" className="form-control fecha-buscador" placeholder="Hasta fecha" autoComplete="off"/>
          </div>
          &nbsp;
          <button className="btn btn-primary" title="Generar kardexes de todos los artículos" type="#" onClick={ this.aplicandoBuscador } >
            <span className="glyphicon glyphicon-search"></span>
          </button>
        </div>
      </div>
    );
  }
});

var ReportesBuscador = React.createClass({
  getInitialState() {
    return { tipo_buscador: "basico"}
  },

  componentDidUpdate(){
    $(".fecha-buscador").datepicker({
      autoclose: true,
      format: "dd-mm-yyyy",
      language: "es"
    });
  },

  cambioBuscador(){
    if(this.state.tipo_buscador == "basico"){
      this.setState({ tipo_buscador: "avanzado" });
    }
    else{
      this.setState({ tipo_buscador: "basico" });
    }
  },

  render(){
    if(this.state.tipo_buscador == "basico"){
      return(
          <div className="page-header">
            <div className= 'form-inline'>
              <h2>Reporte de Activos Fijos</h2>
              <ReportesBuscadorBasico cuentas = { this.props.cuentas }
                                      columnas = { this.props.columnas }
                                      actualizacionTabla = { this.props.actualizacionTabla }
                                      actualizacionUrlPDF = { this.props.actualizacionUrlPDF }
                                      url = { this.props.url }/>
              <div className="clearfix"></div>
              <div className="pull-right">
                <a onClick= { this.cambioBuscador }>Búsqueda Avanzada</a>
              </div>
            </div>
            <br/>
          </div>
      );
    }
    else {
      if(this.props.columnas.length > 0){
        return(
            <div className="page-header">
              <div className= 'form-inline'>
                <h2>Reporte de Activos Fijos</h2>
                <ReportesBuscadorAvanzado cuentas = { this.props.cuentas}
                                          actualizacionTabla = { this.props.actualizacionTabla}
                                          actualizacionUrlPDF = { this.props.actualizacionUrlPDF }
                                          url = { this.props.url }/>
                <div className="clearfix"></div>
                <div className="pull-right">
                  <a onClick= { this.cambioBuscador }>Búsqueda Básica</a>
                </div>
                <div className="clearfix"></div>
              </div>
            </div>
        );
      }
    }
  }
});

var ReporteActivos = React.createClass({
  getInitialState() {
    return { tabla: [],
             total: "",
             url_pdf: ""
           }
  },
  componentWillMount() {
    $.getJSON(this.props.url, (response) => {
      this.setState({ tabla: response.activos,
                      total: response.total,
                      url_pdf: this.props.url + ".pdf"
                    })
    });
  },

  actualizarTabla(tabla) {
      this.setState({
          tabla: tabla.activos,
          total: tabla.total
      });
  },
  actualizacionUrlPDF(data) {
      this.setState({
          url_pdf: data.url
      });
  },

  render() {
    return (
      <div>
        <ReportesBuscador url =  { this.props.url }
                          actualizacionTabla = { this.actualizarTabla }
                          actualizacionUrlPDF = { this.actualizacionUrlPDF }
                          cuentas = { this.props.cuentas }
                          columnas = { this.props.columnas }/>
        <div className='row'>
          <div className='col-sm-12'>
            <TablaReportes key = "1"
                           tabla = { this.state.tabla }
                           total = { this.state.total }
                           url_pdf = { this.state.url_pdf }/>
          </div>
        </div>
      </div>
    );
  }
});
