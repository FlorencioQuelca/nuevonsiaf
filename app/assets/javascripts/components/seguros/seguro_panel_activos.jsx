class SeguroPanelActivos extends React.Component {
  constructor(props) {
    super(props);
    this.asegurar = this.asegurar.bind(this);
    this.verificaAsegurado = this.verificaAsegurado.bind(this);
  }

  verificaAsegurado() {
    return (this.props.seguro.state == "asegurado" ? true : false);
  }

  asegurar() {
    window.location = this.props.urls.asegurar
  }

  render() {
    let titulo;
    let datos_seguro;
    let boton_asegurar;
    let boton_incorporar;
    let incorporaciones;
    if(this.verificaAsegurado()){
      let poliza = this.props.seguro.numero_poliza;
      let fecha_factura = new Date(this.props.seguro.factura_fecha);
      const incorporacion = this.props.incorporacion;
      boton_asegurar =
        <div>
          <a className='btn btn-success pull-right' href='#' title='Asegurado'>
            <i aria-hidden='true' className='fas fa-lock fa-2x'></i>
          </a>
          <div className='clearfix visible-xs-block'></div>
          <br />
          <a className='btn btn-primary btn-xs pull-right' title='Editar' href={this.props.seguro.urls.edit}>
            <span className='glyphicon glyphicon-edit'></span>
          </a>
        </div>;
      datos_seguro =
        <div>
          <div className="col-lg-4 col-md-5 col-sm-12">
            <dl className="dl-horizontal">
              <dt>Número de contrato</dt>
              <dd>{this.props.seguro.numero_contrato}</dd>
              <dt>{this.props.seguro.supplier ? 'Proveedor' : ''}</dt>
              <dd>{this.props.seguro.supplier ? this.props.seguro.supplier.name : ''}</dd>
              <dt>{this.props.seguro.supplier ? 'NIT' : ''}</dt>
              <dd>{this.props.seguro.supplier ? this.props.seguro.supplier.nit : ''}</dd>
              <dt>{this.props.seguro.supplier ? 'Teléfono' : ''}</dt>
              <dd>{this.props.seguro.supplier ? this.props.seguro.supplier.telefono : ''}</dd>
            </dl>
          </div>
          <div className="col-lg-4 col-md-5 col-sm-12">
            <dl className="dl-horizontal">
              <dt>Número de factura</dt>
              <dd>{this.props.seguro.factura_numero}</dd>
              <dt>Número de autorización</dt>
              <dd>{this.props.seguro.factura_autorizacion}</dd>
              <dt>Fecha de factura</dt>
              <dd>{moment(fecha_factura).format("DD/MM/YYYY")}</dd>
              <dt>Monto de factura</dt>
              <dd>{this.props.seguro.factura_monto}</dd>
            </dl>
          </div>
          <div className='pull-right'>
            <h3>{incorporacion=='SI' ? 'INCORPORACIÓN': 'CONTRATO' }</h3>
          </div>
          <div className="clearfix visible-xs-block"></div>
        </div>;
    }
    else {
      boton_asegurar =
        <a className="btn btn-warning pull-right" onClick={this.asegurar} title='Por Asegurar'>
          <i aria-hidden="true" className="fas fa-unlock-alt fa-2x"></i>
        </a>;
    }
    return(
      <div className='row'>
        <div className="col-lg-1 col-md-1 col-sm-12">
          {boton_asegurar}
        </div>
        <div className="col-lg-11 col-md-11 col-sm-12">
          {datos_seguro}
          <SeguroTablaActivos name={this.props.name} activos={this.props.activos} sumatoria={this.props.sumatoria} resumen={this.props.resumen} sumatoria_resumen={this.props.sumatoria_resumen} urls={this.props.urls} links_descarga={this.props.links_descarga} />
        </div>
      </div>
    );
  }
}
