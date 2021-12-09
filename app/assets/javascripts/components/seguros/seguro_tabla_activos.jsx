class SeguroTablaActivos extends React.Component{
  constructor(props) {
    super(props);
    this.generarCSV = this.generarCSV.bind(this);
    this.generarTipoCSV = this.generarTipoCSV.bind(this);
  }

  tabla_detalle(cantidad) {
      const activos = this.props.activos.map((activo, i) => {
        return (
          <tr key = {i}>
            <td className="text-center">
              { i + 1 }
            </td>
            <td className="text-center">
              { activo.code }
            </td>
            <td>
              { activo.description }
            </td>
            <td>
              { activo.cuenta }
            </td>
            <td className = "number">
              { activo.precio }
            </td>
          </tr>
        )
      });

      const sumatoria = (
            <tr key>
              <td colSpan='3'>
              </td>
              <td className = "text-right">
                <strong>
                  TOTAL:
                </strong>
              </td>
              <td className = "number">
                <strong>
                  {this.props.sumatoria}
              </strong>
              </td>
            </tr>
      );

    return(
      <table className={'table table-bordered table-striped table-hover table-condensed tabla-detalle-' + this.props.name}>
        <thead>
          <tr>
            <th className="text-center">
              <strong className="badge" title="Total">
                {cantidad}
              </strong>
            </th>
            <th className="text-center">Código</th>
            <th>Descripción</th>
            <th>Cuenta</th>
            <th className="text-right">Precio</th>
          </tr>
        </thead>
        <tbody>
          { activos }
          { sumatoria }
        </tbody>
      </table>
    );
  }

  tabla_resumen(){
    let cantidad_total = 0;
    const cuentas = this.props.resumen.map((cuenta, i) => {
      cantidad_total = cantidad_total + cuenta.cantidad;
      return (
        <tr key = {i}>
          <td className="text-center">
            {i + 1}
          </td>
          <td>
            {cuenta.nombre}
          </td>
          <td className = "number">
            {cuenta.cantidad}
          </td>
          <td className="number">
            {cuenta.sumatoria}
          </td>
        </tr>
      )
    });

    const sumatoria_resumen = (
          <tr key>
            <td>
            </td>
            <td className = "text-right">
              <strong>
                TOTAL:
              </strong>
            </td>
            <td className = "number">
              <strong>
                {cantidad_total}
              </strong>
            </td>
            <td className = "number">
              <strong>
                {this.props.sumatoria_resumen}
              </strong>
            </td>
          </tr>
    );

    return(
      <table className={'table table-bordered table-striped table-hover table-condensed tabla-resumen-' +this.props.name}>
        <thead>
          <tr>
            <th></th>
            <th>Cuenta</th>
            <th className="text-right">Cantidad</th>
            <th className="text-right">Monto</th>
          </tr>
        </thead>
        <tbody>
          {cuentas}
          {sumatoria_resumen}
        </tbody>
      </table>
    );
  }

  componentDidMount() {
    if(this.props.links_descarga == 'SI'){
      this.generarCSV("resumen", this.props.name);
      $('.pdf-' + this.props.name).attr('href', this.props.urls.resumen);
    }
  }

  generarTipoCSV(e) {
    if(this.props.links_descarga == 'SI'){
      this.generarCSV(e.target.getAttribute("data-type"), this.props.name);
      if(e.target.getAttribute("data-type")=="resumen"){
        $('.pdf-' + this.props.name).attr('href', this.props.urls.resumen);
      }
      else {
        $('.pdf-' + this.props.name).attr('href', this.props.urls.activos);
      }
    }
  }

  generarCSV(tipo, name) {
    let blob, blobURL, csv;
    csv = '';
    $('table.tabla-' + tipo + '-' + name + ' > thead').find('tr').each(function() {
      var sep;
      sep = '';
      $(this).find('th').each(function() {
        if($(this).find('strong').length > 0){
          csv += sep + $(this).find('strong')[0].innerHTML;
        }
        else{
          csv += sep + $(this)[0].innerHTML;
        }
        return sep = ';';
      });
      return csv += '\n';
    });
    $('table.tabla-' + tipo + '-' + name + ' > tbody').find('tr').each(function() {
      var sep;
      sep = '';
      $(this).find('td').each(function() {
        if($(this).find('strong').length > 0){
          csv += sep + $(this).find('strong')[0].innerHTML;
        }
        else{
          csv += sep + $(this)[0].innerHTML;
        }
        return sep = ';';
      });
      return csv += '\n';
    });
    window.URL = window.URL || window.webkiURL;
    blob = new Blob([csv]);
    blobURL = window.URL.createObjectURL(blob);
    return $('.csv-' + name).attr('href', blobURL).attr('download', 'data.csv');
  }

  render() {
    let botones_descarga = <div></div>;
    if(this.props.links_descarga=='SI'){
      botones_descarga =  <div className="pull-right">
                            <span>Descargar:</span>
                            <div className="btn-group btn-group-xs">
                              <a className={'btn btn-default ' + 'csv-' + this.props.name}>CSV</a>
                              <a className={'btn btn-default ' + 'pdf-' + this.props.name} href = {this.props.urls.activos}>PDF</a>
                            </div>
                          </div>;
    }
    const cantidad_activos  = this.props.activos.length;
    if(cantidad_activos > 0){
      return (
        <div role="tabpanel">
          {botones_descarga}
          <ul className="nav nav-tabs" role="tablist">
            <li className="nav-item active">
              <a ref="resumen" aria-controls={'resumen-' + this.props.name} aria-expanded="true" className="nav-link active" data-type="resumen" data-toggle="tab" href={'#resumen-' + this.props.name} id={'resumen-' + this.props.name + '-tab'} role="tab" onClick={this.generarTipoCSV}>Resumen</a>
            </li>
            <li className="nav-item">
              <a ref="detalle" aria-controls={'detalle-' + this.props.name} aria-expanded="false" className="nav-link" data-type="detalle" data-toggle="tab" href={'#detalle-' + this.props.name} id={'detalle-' + this.props.name + '-tab'} role="tab" onClick={this.generarTipoCSV}>Detalle</a>
            </li>
          </ul>
          <div className="tab-content">
            <div aria-expanded="true" aria-labelledby={'resumen-' + this.props.name + '-tab'} className="tab-pane fade active in" id={'resumen-' + this.props.name} role="tabpanel">
              {this.tabla_resumen()}
            </div>
            <div aria-expanded="false" aria-labelledby={'detalle-' + this.props.name + '-tab'} className="tab-pane fade" id={'detalle-' + this.props.name} role="tabpanel">
              {this.tabla_detalle(cantidad_activos)}
            </div>
          </div>
        </div>
      );
    }
    else {
      return(
        <div>
        </div>
      );
    }
  }
}
